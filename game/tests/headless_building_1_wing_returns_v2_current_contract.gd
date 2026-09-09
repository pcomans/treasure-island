extends SceneTree

## Current authority bridge for accepted B1 returns v2. The original candidate contract remains immutable.
## Only current authority pins below differ; all geometry/material/collision mutation predicates are retained.

## B1 returns v2 candidate source contract. Frozen v1 programs remain unchanged.

const HERO := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const MAIN_CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const CONFIG_PATH := "res://game/resources/facades/building_1_public_front_believability.json"
const ADAPTER_PATH := "res://game/scripts/world/facades/building_1_hero_model.gd"
const MATERIAL_PATHS := [
	"res://game/resources/materials/world/building_1/building_1_projecting_base_stone.tres",
	"res://game/resources/materials/world/building_1/building_1_reveal_shadow.tres",
	"res://game/resources/materials/world/building_1/building_1_canopy_underside.tres",
	"res://game/resources/materials/world/building_1/building_1_light_trim.tres",
	"res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres",
]
const EXPECTED_CONFIG_SHA256 := "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb"
const EXPECTED_ADAPTER_SHA256 := "ce2f21dab02163b5f45d9d7e457f5d0ce96089bc55cca6e65aa9924c9f199c5a"
const EXPECTED_MATERIAL_SHA256 := [
	"8bdd85aa10ac78c9225c59aad5ed9d26266ae517ea3f5910b8be3daf41f131ab",
	"2e1f36f163c037fe060a1ecfcdcc5dd062849290a96c508970384585b176e14a",
	"661a7b8cfaef2394e47a42f9bbd04df5fdfbb2cd4be9e6733d5bf3101817cea9",
	"6e543d57ff078c267e952f633f4cee232e0743e30218d2f341dc3f31e4a4c8d9",
	"41c1c31d4a78da25d4abfac59e82fe919fbb539afa479ab7601d0fb51939d59f",
]
const EXPECTED_WALL_COLLISION_SHA256 := "21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5"
const EXPECTED_ROOF_COLLISION_SHA256 := "bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337"
const EXPECTED_COMPONENT_TOPOLOGY := {
	"building:r16681702:wall": {"meshes": 6, "surfaces": 6, "triangles": 10246, "bodies": 1, "shapes": 1, "collision_face_vertices": 2046},
	"building:r16681702:roof": {"meshes": 3, "surfaces": 3, "triangles": 1131, "bodies": 1, "shapes": 1, "collision_face_vertices": 1737},
}
const EXPECTED_WALL_MESH_TRIANGLES := {
	"HeroIvory": 636,
	"HeroProjectingBase": 322,
	"HeroPublicFrontReveals": 168,
	"HeroGlass": 624,
	"HeroTrim": 8244,
	"HeroBronze": 252,
}
const EXPECTED_UNCHANGED_WALL_MESH_SHA256 := {
	"HeroBronze": "d7cc78de3148592c03b38f022d9744f7cd0c08495b69a6fe80d12498cf581e15",
	"HeroGlass": "7d7606c94e9aea27af5da01dbd047fc6378d2fb9f5d6cb59cd7b03e282340218",
	"HeroIvory": "9b2dcbf15a763c65047c99b9babae305cb566aaf920672075dc0ace085270f0c",
	"HeroProjectingBase": "0db13654d5261e6a2066d12be00447a9c55ea4a483ee8657cdede076ac52948b",
	"HeroPublicFrontReveals": "ca176003fd3f48d2fb3f08d40232398dfbda33949995cd9a47dec52e4a4de7de",
}
const EXPECTED_UNCHANGED_ROOF_MESH_SHA256 := {
	"HeroEntranceCanopy": "96301224bc182199306c560db5fd399552562e4d606fe87f3e13ec5d75cfa1c9",
	"HeroEntranceCanopyUnderside": "4655f16f18aa16b2f391535035ad0531562efbbce3dd2044ad80f46c1aed3e10",
	"HeroSteppedRoof": "bedbe6a66504ed798d1cd4532edbfc50391c811b43ada10d90fe4957bdf279f8",
}
const EXPECTED_EXISTING_TRIM_SHA256 := "8a1f4ba50ab041457f420a95ee371a304b2cd0d4509b9d644b89ed722262a6e3"
const EXPECTED_CANDIDATE_TRIM_SHA256 := "72f4b3305ec451504c9cafda98ba1439fcee02b50c529c036e54defe0cd179b0"
const EXISTING_TRIM_BOXES := 567
const WING_OPENINGS := 30
const RETURN_BOXES_PER_OPENING := 4
const TOTAL_TRIM_BOXES := EXISTING_TRIM_BOXES + WING_OPENINGS * RETURN_BOXES_PER_OPENING
const TRIM_MATERIAL_PATH := "res://game/resources/materials/world/building_1/building_1_light_trim.tres"
const GLASS_MATERIAL_PATH := "res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres"
const EXPECTED_ROOF_MESH_TRIANGLES := {
	"HeroSteppedRoof": 303,
	"HeroEntranceCanopy": 552,
	"HeroEntranceCanopyUnderside": 276,
}

const FROZEN_AUTHORITY_AND_LINEAGE_SHA256 := {
	"res://game/tests/headless_building_1_wing_returns_v2_contract.gd": "3189ccb938d12f86bd27fa7ac8beb7c412d74d60497cb678d89d48e4dad87e92",
	"res://evidence/first-playable/building-1-wing-returns-v2-accepted-2026-09-08-001/acceptance-receipt.json": "257f16bc314151054b120c2b87e6f8cb20577f5e4a7201478b58272a65dc23a4",
	"res://evidence/reviews/building-1-wing-returns-v2-2026-09-08-INDEPENDENT_SOURCE_AUDIT.md": "beced0b7bb42589a1214559e193855e46a90a1a0578f5e2a323995a9f2d77958",
	"res://evidence/reviews/building-1-wing-returns-v2-rehearsal-2026-09-08-INDEPENDENT_MECHANICAL_AUDIT.md": "63a3ca3368929982e82a74b2ed00a7afbf063c408e21acad2cc9ceed5fdcf13b",
	"res://evidence/reviews/building-1-wing-returns-v2-rehearsal-002-INDEPENDENT_VISUAL_AUDIT.md": "98911852167577c750b6b75cb868e228a16f04c1d81e3827e43d5abc23a5c082",

	"res://game/resources/materials/world/building_1/building_1_blue_door.tres": "6554b282d6a77bcc50859b03eaea4889c18868d1f3a1580dbaa4bc2a9a6ff361",
	"res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres": "41c1c31d4a78da25d4abfac59e82fe919fbb539afa479ab7601d0fb51939d59f",
	"res://game/resources/materials/world/building_1/building_1_bronze.tres": "7948c9fca74345f4ff5e57a44191beb59300847b66cc54ddc176c5ca1b315ca3",
	"res://game/resources/materials/world/building_1/building_1_canopy_underside.tres": "661a7b8cfaef2394e47a42f9bbd04df5fdfbb2cd4be9e6733d5bf3101817cea9",
	"res://game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader": "a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09",
	"res://game/resources/materials/world/building_1/building_1_light_trim.tres": "6e543d57ff078c267e952f633f4cee232e0743e30218d2f341dc3f31e4a4c8d9",
	"res://game/resources/materials/world/building_1/building_1_projecting_base_stone.tres": "8bdd85aa10ac78c9225c59aad5ed9d26266ae517ea3f5910b8be3daf41f131ab",
	"res://game/resources/materials/world/building_1/building_1_reveal_shadow.tres": "2e1f36f163c037fe060a1ecfcdcc5dd062849290a96c508970384585b176e14a",
	"res://game/resources/materials/world/building_1/building_1_roof_metal.tres": "8bee442442f8b7bc3004cd3f703ce4e21eb9bc3b1f4d3d8800b02a77268329c8",
	"res://game/resources/materials/world/building_1/building_1_rose_base.tres": "dd0ad6a95267c6be55ae415d8e044847b3ac53b7c1fceb823b12bb1a4fe44514",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory.tres": "572c3165cec91f74a49066873c31c071ae02333f85721bbd6b43981d814cdabb",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres": "12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a",
	"res://game/tests/full_runtime_integration.gd": "c3dfefb96eac27b2cd0b73f97accdd6d333d1203115a4198de8302149044ed38",
	"res://generated/world/chunks/x_-1__z_2.json": "dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce",
	"res://generated/world/chunks/x_0__z_2.json": "886f4e6ecfbf570dac9cb36f682a089a0cfe51b735692e3220df4d5b4ac3d7b6",
	"res://discovery/facades/facade-recognition-catalog.json": "6987ab1db4d58096ae9189803a48b8015dca8154a23b55470ab166af76a2d50c",
	"res://discovery/facades/facade-recognition-catalog.schema.json": "2835742a7f54d4d70e7bc90ff739ce33350954cf9daa69eb01eb1e20588c4687",
	"res://discovery/facades/facade-recognition-validation-report.json": "bc2e6bb25f9de9c5c2007c51b3007c4da63081e32328bc9a99d1aed740448a3b",
	"res://game/resources/facades/facade-runtime-registry.json": "c6780895e339919f7ebe0900814afaa46fd15f31958946ec81b4391091a1d46f",
	"res://game/resources/facades/facade-runtime-adapter-contracts.json": "24efc72b3315540f31dc112949ac108509cdc0e4eb9f5e20ef0d4b45ce41ac49",
	"res://game/scripts/world/facades/facade_runtime_registry_loader.gd": "6571e85914e604e16a8294cc8835dba033454907a3bc1da8bb9d9fd36e35789f",
	"res://tools/build_facade_recognition_registry.mjs": "9b6ee97d19e069a0cfc0dc0e043e856e8618c407361b508527ce764b9a71be37",
	"res://game/resources/facades/d2_1441_chinook_live_replacement.json": "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111",
	"res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd": "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1",
	"res://game/scripts/world/world_chunk_builder.gd": "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a",
	"res://game/resources/facades/building_1_hero_model.json": "f10bc92a6e74cbae41347e742e6c68c50faccddbd52ab3ecce210ac8243bc6e9",
	"res://game/tests/headless_building_1_public_front_believability_contract.gd": "0c73a6dbc9028b7a3cb7fac5e474f93b32cf823dc74a44aefba275723f1184e2",
	"res://game/tests/headless_building_1_hero_model_contract.gd": "24831f23cad27004f36851d7dbbedd02ca607190b7543a2f378897e12ba31bf2",
	"res://game/tests/building_1_wing_window_reveal_candidate_capture.gd": "20363d664e268e4760ba8d5817c71553a9237a6df442931185fdc69c752f05d4",
	"res://game/tests/headless_building_1_wing_window_reveal_candidate_evidence_contract.gd": "0c60baadc8bbb218493c70275b97df5db7ccd074c1a58b043728db20216a6807",
	"res://game/tests/headless_building_1_wing_window_reveal_candidate_package_contract.gd": "fdf42f697312c0149ebbfbb385ece6cc2fa675f623769c4634f37e3311450190",
	"res://evidence/reviews/building-1-wing-window-reveal-candidate-2026-09-08-INDEPENDENT_SOURCE_AUDIT.md": "c70a364dc90746f5e5b6f2e1021f68c8cd94dcc52761516538d19a3edaed24a0",
	"res://evidence/reviews/building-1-wing-window-reveal-rehearsal-004-INDEPENDENT_MECHANICAL_AUDIT.md": "b580e998d350f07368d73cc857f14872a254e99cc1d6aafed1b77add15a87271",
	"res://evidence/reviews/building-1-wing-window-reveal-rehearsal-004-INDEPENDENT_VISUAL_HOLD.md": "26c1327118db37f18e7082c99bd9e0b4c96e76b97b30fb2a7f9fe5fd6c3edcba"
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var config := _json(CONFIG_PATH)
	_require(_config_truth_contract(config), "Building 1 public-front config lost its bounded production-inference truth contract.")
	_hash_contract()
	_material_contract()
	var wall_record := _record(HERO.BUILDING_WALL_KEY)
	var roof_record := _record(HERO.BUILDING_ROOF_KEY)
	_require(not wall_record.is_empty() and not roof_record.is_empty(), "Building 1 wall/roof frozen source records did not resolve.")
	var wall_result := HERO.build_record(wall_record)
	var wall_repeat := HERO.build_record(wall_record)
	var roof_result := HERO.build_record(roof_record)
	var roof_repeat := HERO.build_record(roof_record)
	if not _require(bool(wall_result.get("ok", false)) and bool(wall_repeat.get("ok", false)), "Building 1 believability wall did not build twice.") \
	or not _require(bool(roof_result.get("ok", false)) and bool(roof_repeat.get("ok", false)), "Building 1 believability roof did not build twice."):
		_free_result(wall_result)
		_free_result(wall_repeat)
		_free_result(roof_result)
		_free_result(roof_repeat)
		quit(1)
		return
	var wall := wall_result.node as Node3D
	var wall_second := wall_repeat.node as Node3D
	var roof := roof_result.node as Node3D
	var roof_second := roof_repeat.node as Node3D
	var wall_topology := _topology(wall_result, wall)
	var roof_topology := _topology(roof_result, roof)
	_require(wall_topology == EXPECTED_COMPONENT_TOPOLOGY[HERO.BUILDING_WALL_KEY], "Measured Building 1 wall topology drifted: %s" % JSON.stringify(wall_topology))
	_require(roof_topology == EXPECTED_COMPONENT_TOPOLOGY[HERO.BUILDING_ROOF_KEY], "Measured Building 1 roof topology drifted: %s" % JSON.stringify(roof_topology))
	_require(_mesh_triangle_map(wall) == EXPECTED_WALL_MESH_TRIANGLES, "Public-front material/geometry topology drifted: %s" % JSON.stringify(_mesh_triangle_map(wall)))
	_require(_mesh_triangle_map(roof) == EXPECTED_ROOF_MESH_TRIANGLES, "Canopy depth topology drifted: %s" % JSON.stringify(_mesh_triangle_map(roof)))
	var wall_mesh_hashes := _mesh_array_sha256_map(wall)
	var roof_mesh_hashes := _mesh_array_sha256_map(roof)
	var unchanged_wall_hashes := wall_mesh_hashes.duplicate()
	unchanged_wall_hashes.erase("HeroTrim")
	_require(unchanged_wall_hashes == EXPECTED_UNCHANGED_WALL_MESH_SHA256, "A non-trim Building 1 wall bucket changed: %s" % JSON.stringify(unchanged_wall_hashes))
	_require(roof_mesh_hashes == EXPECTED_UNCHANGED_ROOF_MESH_SHA256, "Building 1 roof/canopy bytes changed: %s" % JSON.stringify(roof_mesh_hashes))
	_require(str(wall_mesh_hashes.get("HeroTrim", "")) == EXPECTED_CANDIDATE_TRIM_SHA256, "Wing-returns v2 trim bytes drifted.")
	_require(_wing_returns_geometry_contract(wall, wall_record), "The exact 30-opening / 120-strip light-return schedule, aperture depth/material, or accepted trim prefix drifted.")
	_require(_candidate_mutation_contract(config, wall, wall_record), "The B1 returns v2 config/source/geometry/collision/authority mutation matrix did not fail closed.")
	_require(_wall_metadata_contract(wall), "Building 1 public-front wall schedule/depth/truth metadata drifted.")
	_require(_roof_metadata_contract(roof), "Building 1 canopy/collision/traversal metadata drifted.")
	_require(_exact_horizontal_plan(wall, wall_record), "Building 1 HeroIvory no longer starts with all 110 exact frozen source runs.")
	_require(_collision_contract(wall, true, 2046), "Building 1 wall collision/spray ownership drifted.")
	_require(_collision_contract(roof, false, 1737), "Building 1 roof/canopy collision ownership drifted.")
	var wall_collision_sha := _collision_sha256(wall)
	var roof_collision_sha := _collision_sha256(roof)
	if not EXPECTED_WALL_COLLISION_SHA256.is_empty():
		_require(wall_collision_sha == EXPECTED_WALL_COLLISION_SHA256, "Building 1 wall collision face bytes drifted.")
	if not EXPECTED_ROOF_COLLISION_SHA256.is_empty():
		_require(roof_collision_sha == EXPECTED_ROOF_COLLISION_SHA256, "Building 1 roof collision face bytes drifted.")
	_require(_geometry_deterministic(wall, wall_second), "Building 1 public-front wall geometry is nondeterministic.")
	_require(_geometry_deterministic(roof, roof_second), "Building 1 public-front roof geometry is nondeterministic.")
	print("BUILDING_1_PUBLIC_FRONT_COMPONENT_TOPOLOGY=%s" % JSON.stringify({HERO.BUILDING_WALL_KEY: wall_topology, HERO.BUILDING_ROOF_KEY: roof_topology}))
	print("BUILDING_1_PUBLIC_FRONT_MESH_TRIANGLES=%s" % JSON.stringify({"wall": _mesh_triangle_map(wall), "roof": _mesh_triangle_map(roof)}))
	print("BUILDING_1_PUBLIC_FRONT_MESH_ARRAY_SHA256=%s" % JSON.stringify({"wall": wall_mesh_hashes, "roof": roof_mesh_hashes}))
	print("BUILDING_1_PUBLIC_FRONT_COLLISION_SHA256=%s/%s" % [wall_collision_sha, roof_collision_sha])
	wall.free()
	wall_second.free()
	roof.free()
	roof_second.free()
	if not _failed:
		print("PASS: B1 returns v2 has 30 openings / 120 light strips / 1440 render-only triangles under unchanged frame silhouettes, 168 accepted center reveal triangles, exact glazing and accepted trim prefix, protected scope, collision, spray, authority and mutation controls")
	quit(1 if _failed else 0)


func _config_truth_contract(config: Dictionary) -> bool:
	var target := config.get("target", {}) as Dictionary
	var geometry := config.get("geometry_production_inference_m", {}) as Dictionary
	var truth := config.get("truth", {}) as Dictionary
	return str(config.get("schema_version", "")) == "ti.building-1-public-front-believability/3" \
		and str(target.get("building_source_key", "")) == "r16681702" \
		and str(target.get("wall_object_key", "")) == HERO.BUILDING_WALL_KEY \
		and str(target.get("roof_object_key", "")) == HERO.BUILDING_ROOF_KEY \
		and (target.get("public_front_chain_runs", []) as Array).size() == 23 \
		and int(geometry.get("pilaster_count", 0)) == 12 \
		and int(geometry.get("pilaster_flutes_per_pilaster", 0)) == 2 \
		and str(config.get("pass_id", "")) == "building-1-wing-window-returns-v2-2026-09-08" \
		and is_equal_approx(float(geometry.get("wing_window_jamb_frame_overlap", -1.0)), 0.005) \
		and is_equal_approx(float(geometry.get("wing_window_jamb_rear_overlap", -1.0)), 0.01) \
		and is_equal_approx(float(geometry.get("entrance_group_gap", -1.0)), 0.90) \
		and is_equal_approx(float(geometry.get("projecting_base_depth", -1.0)), 0.28) \
		and is_equal_approx(float(geometry.get("canopy_primary_depth", -1.0)), 2.25) \
		and not bool(truth.get("surveyed_dimensions", true)) \
		and not bool(truth.get("surveyed_facade_coordinates", true)) \
		and not bool(truth.get("as_built_fidelity_claimed", true)) \
		and not bool(truth.get("interior_modeled", true)) \
		and not bool(truth.get("horizontal_source_geometry_changed", true)) \
		and not bool(truth.get("vertical_massing_changed", true)) \
		and not bool(truth.get("collision_geometry_changed", true)) \
		and not bool(truth.get("spray_ownership_changed", true)) \
		and not bool(truth.get("roof_traversal_changed", true)) \
		and not bool(truth.get("image_texture_used", true)) \
		and not bool(truth.get("genai_texture_candidate_consumed", true)) \
		and bool(truth.get("misleading_cruciform_proxy_removed", false)) \
		and bool(truth.get("quiet_neutral_relief_location_field_used", false)) \
		and str(truth.get("review_status", "")) == "pending_independent_bar_raiser_re_review_not_self_accepted"


func _hash_contract() -> void:
	if not EXPECTED_CONFIG_SHA256.is_empty():
		_require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "Public-front config bytes drifted.")
	if not EXPECTED_ADAPTER_SHA256.is_empty():
		_require(FileAccess.get_sha256(ADAPTER_PATH) == EXPECTED_ADAPTER_SHA256, "Building 1 adapter bytes drifted.")
	for index in MATERIAL_PATHS.size():
		if not str(EXPECTED_MATERIAL_SHA256[index]).is_empty():
			_require(FileAccess.get_sha256(MATERIAL_PATHS[index]) == str(EXPECTED_MATERIAL_SHA256[index]), "%s bytes drifted." % MATERIAL_PATHS[index])


func _material_contract() -> void:
	var expected := [
		{"color": Color(0.68, 0.65, 0.58, 1), "roughness": 0.88},
		{"color": Color(0.105, 0.12, 0.125, 1), "roughness": 0.9},
		{"color": Color(0.34, 0.33, 0.30, 1), "roughness": 0.9},
		{"color": Color(0.865, 0.84, 0.76, 1), "roughness": 0.78},
		{"color": Color(0.145, 0.205, 0.235, 1), "roughness": 0.32},
	]
	for index in MATERIAL_PATHS.size():
		var material := load(MATERIAL_PATHS[index]) as StandardMaterial3D
		var expectation := expected[index] as Dictionary
		_require(material != null, "%s is not a scalar StandardMaterial3D." % MATERIAL_PATHS[index])
		if material == null:
			continue
		_require(material.albedo_texture == null and material.normal_texture == null and material.roughness_texture == null and material.metallic_texture == null, "%s unexpectedly consumes an image texture." % MATERIAL_PATHS[index])
		_require(material.albedo_color.is_equal_approx(expectation.color as Color) and is_equal_approx(material.roughness, float(expectation.roughness)), "%s scalar value/roughness drifted." % MATERIAL_PATHS[index])


func _wing_cases_v2() -> Array[Dictionary]:
	return [
		{"runs": HERO.NORTH_WING_WINDOW_RUNS, "count": 8, "margin": 2.2, "y": 16.9, "w": 2.35, "h": 2.8, "projection": 0.13},
		{"runs": HERO.NORTH_WING_WINDOW_RUNS, "count": 7, "margin": 2.5, "y": 10.35, "w": 2.05, "h": 2.45, "projection": 0.23},
		{"runs": HERO.SOUTH_WING_WINDOW_RUNS, "count": 8, "margin": 2.2, "y": 16.9, "w": 2.35, "h": 2.8, "projection": 0.13},
		{"runs": HERO.SOUTH_WING_WINDOW_RUNS, "count": 7, "margin": 2.5, "y": 10.35, "w": 2.05, "h": 2.45, "projection": 0.23},
	]


func _wing_returns_geometry_contract(node: Node3D, record: Dictionary) -> bool:
	var trim_mesh := (node.get_node("HeroTrim") as MeshInstance3D).mesh as ArrayMesh
	var glass_mesh := (node.get_node("HeroGlass") as MeshInstance3D).mesh as ArrayMesh
	if trim_mesh == null or glass_mesh == null or trim_mesh.get_surface_count() != 1 or glass_mesh.get_surface_count() != 1:
		return false
	var trim_material := trim_mesh.surface_get_material(0)
	var glass_material := glass_mesh.surface_get_material(0)
	if trim_material == null or glass_material == null or not _wing_material_roles(trim_material.resource_path, glass_material.resource_path) or not _wing_material_semantics(trim_material, glass_material):
		return false
	var arrays := trim_mesh.surface_get_arrays(0)
	print("B1_RETURNS_V2_ARRAY_COUNTS=%d/%d/%d/%d; accepted_trim_prefix=%s" % [(arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size(), (arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array).size(), (arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array).size(), (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size(), _mesh_box_prefix_sha256(trim_mesh, EXISTING_TRIM_BOXES)])
	return _mesh_box_prefix_sha256(trim_mesh, EXISTING_TRIM_BOXES) == EXPECTED_EXISTING_TRIM_SHA256 \
		and _returns_arrays_match(arrays, glass_mesh.surface_get_arrays(0), record, _wing_cases_v2()) \
		and int(node.get_meta("wing_jamb_return_openings", -1)) == 30 \
		and int(node.get_meta("wing_jamb_return_strips_per_opening", -1)) == 4 \
		and int(node.get_meta("wing_dark_backing_boxes", -1)) == 0 \
		and bool(node.get_meta("wing_glazing_and_existing_frame_geometry_preserved", false))


func _wing_material_roles(trim_path: String, glass_path: String) -> bool:
	return trim_path == TRIM_MATERIAL_PATH and glass_path == GLASS_MATERIAL_PATH


func _wing_material_semantics(trim_material: Material, glass_material: Material) -> bool:
	if not (trim_material is StandardMaterial3D) or not (glass_material is StandardMaterial3D):
		return false
	var light := trim_material as StandardMaterial3D
	var dark := glass_material as StandardMaterial3D
	for material: StandardMaterial3D in [light, dark]:
		if material.albedo_texture != null or material.normal_texture != null or material.roughness_texture != null or material.metallic_texture != null \
		or material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or material.emission_enabled:
			return false
	return light.albedo_color.is_equal_approx(Color(0.865, 0.84, 0.76, 1)) \
		and is_equal_approx(light.roughness, 0.78) and is_zero_approx(light.metallic) \
		and dark.albedo_color.is_equal_approx(Color(0.145, 0.205, 0.235, 1)) \
		and is_equal_approx(dark.roughness, 0.32) and is_equal_approx(dark.metallic, 0.14)


func _returns_arrays_match(arrays: Array, glass_arrays: Array, record: Dictionary, cases: Array[Dictionary]) -> bool:
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var glass_vertices := glass_arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	if vertices.size() != TOTAL_TRIM_BOXES * 24 \
	or (arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array).size() != vertices.size() \
	or (arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array).size() != vertices.size() \
	or (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() != TOTAL_TRIM_BOXES * 36:
		return false
	var opening := 0
	for case: Dictionary in cases:
		var runs := _int_array(case.runs as Array)
		var length := _chain_length(record, runs)
		var count := int(case.count)
		var margin := float(case.margin)
		if count < 2 or length <= margin * 2.0:
			return false
		for index in count:
			var chain_m := lerpf(margin, length - margin, float(index) / float(count - 1))
			var frame := _chain_frame(record, runs, chain_m)
			if frame.is_empty() or not _opening_geometry_matches(vertices, EXISTING_TRIM_BOXES + opening * 4, glass_vertices, 14 + opening, frame, case):
				return false
			opening += 1
	return opening == WING_OPENINGS


func _opening_geometry_matches(vertices: PackedVector3Array, box_index: int, glass: PackedVector3Array, glass_box: int, frame: Dictionary, case: Dictionary) -> bool:
	var width := float(case.w)
	var height := float(case.h)
	var projection := float(case.projection)
	var anchor := frame.wall_anchor as Vector3
	anchor.y = float(case.y)
	var strips := [
		[-width * 0.5, 0.0, 0.105, height + 0.16], [width * 0.5, 0.0, 0.105, height + 0.16],
		[0.0, -height * 0.5, width + 0.16, 0.105], [0.0, height * 0.5, width + 0.16, 0.105],
	]
	for strip in 4:
		var expected := strips[strip] as Array
		if not _box_bounds_match(vertices, box_index + strip, frame, anchor, Vector3(float(expected[0]), float(expected[1]), (projection - 0.075) * 0.5), Vector3(float(expected[2]), float(expected[3]), projection - 0.055)):
			return false
	# Existing dark glazing must stay fully inside the unchanged perimeter frames.
	return _box_bounds_match(glass, glass_box, frame, anchor, Vector3(0, 0, maxf(0.035, projection - 0.10)), Vector3(width, height, 0.07))


func _box_bounds_match(vertices: PackedVector3Array, box_index: int, frame: Dictionary, anchor: Vector3, center: Vector3, dimensions: Vector3) -> bool:
	var start := box_index * 24
	if start < 0 or start + 24 > vertices.size():
		return false
	var low := Vector3(INF, INF, INF)
	var high := Vector3(-INF, -INF, -INF)
	for index in range(start, start + 24):
		var relative := vertices[index] - anchor
		var point := Vector3(relative.dot(frame.tangent as Vector3), relative.y, relative.dot(frame.normal as Vector3))
		low = low.min(point)
		high = high.max(point)
	return low.distance_to(center - dimensions * 0.5) < 0.001 and high.distance_to(center + dimensions * 0.5) < 0.001


func _candidate_mutation_contract(config: Dictionary, wall: Node3D, record: Dictionary) -> bool:
	if not HERO._bar_config_valid(config):
		return false
	for key in ["wing_window_jamb_frame_overlap", "wing_window_jamb_rear_overlap"]:
		var missing := config.duplicate(true)
		(missing.geometry_production_inference_m as Dictionary).erase(key)
		var changed := config.duplicate(true)
		(changed.geometry_production_inference_m as Dictionary)[key] = 0.5
		if HERO._bar_config_valid(missing) or HERO._bar_config_valid(changed):
			return false
	var old := config.duplicate(true)
	old.schema_version = "ti.building-1-public-front-believability/2"
	if HERO._bar_config_valid(old):
		return false
	var hero_config := _json(HERO.CONFIG_PATH)
	if not HERO._config_valid(hero_config):
		return false
	for mutation: Dictionary in [
		{"field": "upper_windows_per_wing", "value": 9}, {"field": "lower_windows_per_wing", "value": 6},
		{"field": "north_wing_window_runs", "value": [10, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]},
		{"field": "south_wing_window_runs", "value": [44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 57]},
		{"field": "north_end_run", "value": 92}, {"field": "south_end_run", "value": 61},
	]:
		var changed := hero_config.duplicate(true)
		(changed.facade_schedule as Dictionary)[str(mutation.field)] = mutation.value
		if HERO._config_valid(changed):
			return false
	var arrays := ((wall.get_node("HeroTrim") as MeshInstance3D).mesh as ArrayMesh).surface_get_arrays(0)
	var glass := ((wall.get_node("HeroGlass") as MeshInstance3D).mesh as ArrayMesh).surface_get_arrays(0)
	# Actual 29/31-opening arrays, not only declared counts.
	for delta in [-1, 1]:
		var changed := arrays.duplicate(true)
		var vertices := changed[Mesh.ARRAY_VERTEX] as PackedVector3Array
		vertices.resize(vertices.size() + delta * 4 * 24)
		changed[Mesh.ARRAY_VERTEX] = vertices
		if _returns_arrays_match(changed, glass, record, _wing_cases_v2()):
			return false
	for runs in [[21, 22, 23], [93], [60], [75], [100, 101]]:
		var cases := _wing_cases_v2()
		cases[0].runs = runs
		if _returns_arrays_match(arrays, glass, record, cases):
			return false
	var cadence := _wing_cases_v2()
	cadence[0].margin = 2.3
	if _returns_arrays_match(arrays, glass, record, cadence):
		return false
	var first_frame := _chain_frame(record, _int_array(HERO.NORTH_WING_WINDOW_RUNS), 2.2)
	var changed_glass := glass.duplicate(true)
	var dark_vertices := changed_glass[Mesh.ARRAY_VERTEX] as PackedVector3Array
	dark_vertices[14 * 24] += (first_frame.tangent as Vector3) * 5.0
	changed_glass[Mesh.ARRAY_VERTEX] = dark_vertices
	var changed_returns := arrays.duplicate(true)
	var light_vertices := changed_returns[Mesh.ARRAY_VERTEX] as PackedVector3Array
	light_vertices[EXISTING_TRIM_BOXES * 24] += (first_frame.normal as Vector3) * 0.2
	changed_returns[Mesh.ARRAY_VERTEX] = light_vertices
	if _returns_arrays_match(arrays, changed_glass, record, _wing_cases_v2()) or _returns_arrays_match(changed_returns, glass, record, _wing_cases_v2()):
		return false
	if _wing_material_roles(GLASS_MATERIAL_PATH, TRIM_MATERIAL_PATH) or _wing_material_roles(MATERIAL_PATHS[1], GLASS_MATERIAL_PATH):
		return false
	var light := load(TRIM_MATERIAL_PATH) as StandardMaterial3D
	var dark := load(GLASS_MATERIAL_PATH) as StandardMaterial3D
	var recolored_light := light.duplicate(true) as StandardMaterial3D
	recolored_light.albedo_color = dark.albedo_color
	var recolored_dark := dark.duplicate(true) as StandardMaterial3D
	recolored_dark.albedo_color = light.albedo_color
	var roughness_change := light.duplicate(true) as StandardMaterial3D
	roughness_change.roughness = 0.1
	# Role paths remain the same; actual loaded/copied values must fail independently.
	if not _wing_material_semantics(light, dark) or _wing_material_semantics(dark, light) \
	or _wing_material_semantics(recolored_light, dark) or _wing_material_semantics(light, recolored_dark) \
	or _wing_material_semantics(roughness_change, dark):
		return false
	var source := FileAccess.get_file_as_string(ADAPTER_PATH)
	if not _candidate_source_contract(source):
		return false
	for mutation: Dictionary in [
		{"needle": "_append_wing_jamb_schedule_v2(trim, record, wing_runs, int(schedule.upper_windows_per_wing)", "replacement": "_append_wing_jamb_schedule_v2(reveal, record, wing_runs, int(schedule.upper_windows_per_wing)"},
		{"needle": "_append_wing_jamb_schedule_v2(trim, record, wing_runs, int(schedule.lower_windows_per_wing)", "replacement": "_append_wing_jamb_schedule_v2(collision, record, wing_runs, int(schedule.lower_windows_per_wing)"},
		{"needle": "_append_wing_jamb_returns_v2(trim, frame, center_y", "replacement": "_append_wing_jamb_returns_v2(reveal, frame, center_y"},
		{"needle": "_append_window(glass, trim, tall_frame, 14.2", "replacement": "_append_wing_jamb_returns_v2(trim, tall_frame, 14.2"},
		{"needle": "2.2, 2.35, 2.8, 0.13, 16.9, front)", "replacement": "2.3, 2.35, 2.8, 0.13, 16.9, front)"},
	]:
		var needle := str(mutation.needle)
		if source.count(needle) != 1 or _candidate_source_contract(source.replace(needle, str(mutation.replacement))):
			return false
	var changed_faces := ((wall.get_node("Collision/Shape") as CollisionShape3D).shape as ConcavePolygonShape3D).get_faces()
	changed_faces[0].y += 0.1
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(changed_faces.to_byte_array())
	if context.finish().hex_encode() == EXPECTED_WALL_COLLISION_SHA256:
		return false
	var hashes := {}
	for path: String in FROZEN_AUTHORITY_AND_LINEAGE_SHA256:
		hashes[path] = FileAccess.get_sha256(path)
	if hashes != FROZEN_AUTHORITY_AND_LINEAGE_SHA256:
		return false
	for path: String in FROZEN_AUTHORITY_AND_LINEAGE_SHA256:
		var changed := hashes.duplicate()
		changed[path] = "mutated"
		if changed == FROZEN_AUTHORITY_AND_LINEAGE_SHA256:
			return false
	print("B1_RETURNS_V2_MUTATIONS=PASS: 29/31 actual geometry; cadence; run/end/center/rear routing; dark outside frame; floating return; light/dark swap; collision; D2/authority/frozen lineage")
	return true


func _candidate_source_contract(source: String) -> bool:
	var schedule := _function_block(source, "static func _append_wing_jamb_schedule_v2(")
	var returns := _function_block(source, "static func _append_wing_jamb_returns_v2(")
	var ends := _function_block(source, "static func _append_end_composition(")
	return not schedule.is_empty() and not returns.is_empty() \
		and source.count("_append_wing_jamb_schedule_v2(") == 3 \
		and source.count("_append_wing_jamb_returns_v2(") == 2 \
		and source.count("_append_wing_jamb_schedule_v2(trim, record, wing_runs, int(schedule.upper_windows_per_wing), 2.2, 2.35, 2.8, 0.13, 16.9, front)") == 1 \
		and source.count("_append_wing_jamb_schedule_v2(trim, record, wing_runs, int(schedule.lower_windows_per_wing), 2.5, 2.05, 2.45, 0.23, 10.35, front)") == 1 \
		and schedule.count("_append_wing_jamb_returns_v2(trim, frame, center_y") == 1 \
		and returns.count("_append_box(trim,") == 2 \
		and not returns.contains("_append_box(reveal") \
		and not returns.contains("collision") and not returns.contains("Navigation") and not returns.contains("Decal") \
		and ends.count("_append_window(") == 2 and not ends.contains("_append_wing_jamb") \
		and not source.contains("_append_wing_window(")


func _function_block(source: String, signature: String) -> String:
	var start := source.find(signature)
	if start < 0:
		return ""
	var finish := source.find("\nstatic func ", start + signature.length())
	return source.substr(start) if finish < 0 else source.substr(start, finish - start)


func _wall_metadata_contract(node: Node3D) -> bool:
	var bands := node.get_meta("public_front_depth_bands_m", []) as Array
	return bool(node.get_meta("public_front_believability_pass", false)) \
		and str(node.get_meta("public_front_believability_config_path", "")) == CONFIG_PATH \
		and str(node.get_meta("public_front_believability_review_status", "")) == "pending_independent_bar_raiser_re_review_not_self_accepted" \
		and str(node.get_meta("recognition_status", "")) == "accepted_before_quality_hardening_and_preserved" \
		and bool(node.get_meta("public_front_depth_created_by_geometry", false)) \
		and bool(node.get_meta("scalar_material_value_separation", false)) \
		and not bool(node.get_meta("image_texture_used_for_pass", true)) \
		and not bool(node.get_meta("genai_texture_candidate_consumed", true)) \
		and int(node.get_meta("central_window_count", -1)) == 11 \
		and int(node.get_meta("central_lights_per_window", -1)) == 18 \
		and int(node.get_meta("central_recessed_glazing_field_count", -1)) == 11 \
		and int(node.get_meta("central_pilaster_count", -1)) == 12 \
		and int(node.get_meta("fluting_ribs_per_pilaster", -1)) == 2 \
		and int(node.get_meta("entrance_groups", -1)) == 3 \
		and int(node.get_meta("doors_per_entrance_group", -1)) == 3 \
		and int(node.get_meta("upper_windows_per_wing", -1)) == 8 \
		and int(node.get_meta("lower_windows_per_wing", -1)) == 7 \
		and int(node.get_meta("end_composition_count", -1)) == 2 \
		and int(node.get_meta("relief_proxy_count", -1)) == 0 \
		and int(node.get_meta("neutral_end_relief_location_field_count", -1)) == 2 \
		and int(node.get_meta("misleading_cruciform_proxy_count", -1)) == 0 \
		and bands.size() == 3 \
		and is_equal_approx(float(bands[0]), 0.14) \
		and is_equal_approx(float(bands[1]), 0.49) \
		and is_equal_approx(float(bands[2]), 0.54) \
		and not bool(node.get_meta("horizontal_source_geometry_changed", true)) \
		and not bool(node.get_meta("vertical_massing_changed", true)) \
		and not bool(node.get_meta("collision_geometry_changed", true)) \
		and not bool(node.get_meta("spray_ownership_changed", true)) \
		and node.get_node_or_null("HeroRoseRelief") == null


func _roof_metadata_contract(node: Node3D) -> bool:
	return bool(node.get_meta("public_front_believability_pass", false)) \
		and str(node.get_meta("recognition_status", "")) == "accepted_before_quality_hardening_and_preserved" \
		and bool(node.get_meta("canopy_collision_congruent", false)) \
		and bool(node.get_meta("canopy_primary_slab_collision_congruent", false)) \
		and bool(node.get_meta("canopy_visual_depth_accents_noncolliding", false)) \
		and not bool(node.get_meta("collision_geometry_changed", true)) \
		and not bool(node.get_meta("roof_traversal_changed", true)) \
		and not bool(node.get_meta("genai_texture_candidate_consumed", true)) \
		and node.get_meta("reachable_roof_tier_y", []) == [14.75, 20.25, 26.281]


func _exact_horizontal_plan(node: Node3D, record: Dictionary) -> bool:
	var mesh_node := node.get_node_or_null("HeroIvory") as MeshInstance3D
	if mesh_node == null:
		return false
	var vertices := ((mesh_node.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array)
	var source := record.vertices as Array
	if vertices.size() < 440:
		return false
	for run_index in range(110):
		var source_offset := run_index * 12
		var mesh_offset := run_index * 4
		if Vector2(vertices[mesh_offset].x, vertices[mesh_offset].z).distance_to(Vector2(float(source[source_offset]), float(source[source_offset + 2]))) > 0.00001 \
		or Vector2(vertices[mesh_offset + 1].x, vertices[mesh_offset + 1].z).distance_to(Vector2(float(source[source_offset + 3]), float(source[source_offset + 5]))) > 0.00001:
			return false
	return true


func _collision_contract(node: Node3D, sprayable: bool, face_vertex_count: int) -> bool:
	var bodies := node.find_children("*", "StaticBody3D", true, false)
	var shapes := node.find_children("*", "CollisionShape3D", true, false)
	if bodies.size() != 1 or shapes.size() != 1:
		return false
	var body := bodies[0] as StaticBody3D
	var shape := (shapes[0] as CollisionShape3D).shape as ConcavePolygonShape3D
	return shape != null \
		and shape.get_faces().size() == face_vertex_count \
		and body.collision_layer == ((1 << 0) | ((1 << 2) if sprayable else 0)) \
		and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") == sprayable \
		and str(body.get_meta("derived_object_key", "")) == str(node.get_meta("derived_object_key", "")) \
		and body.get_meta("source_keys", []) == ["r16681702"]


func _geometry_deterministic(first: Node3D, second: Node3D) -> bool:
	if first.get_child_count() != second.get_child_count():
		return false
	for index in first.get_child_count():
		var left := first.get_child(index)
		var right := second.get_child(index)
		if left.name != right.name or left.get_class() != right.get_class():
			return false
		if left is MeshInstance3D:
			if ((left as MeshInstance3D).mesh as ArrayMesh).surface_get_arrays(0) != ((right as MeshInstance3D).mesh as ArrayMesh).surface_get_arrays(0):
				return false
		elif left is StaticBody3D:
			var left_faces := ((((left as StaticBody3D).get_node("Shape")) as CollisionShape3D).shape as ConcavePolygonShape3D).get_faces()
			var right_faces := ((((right as StaticBody3D).get_node("Shape")) as CollisionShape3D).shape as ConcavePolygonShape3D).get_faces()
			if left_faces != right_faces:
				return false
	return true


func _topology(result: Dictionary, node: Node3D) -> Dictionary:
	return {
		"meshes": int(result.mesh_instances),
		"surfaces": int(result.surfaces),
		"triangles": int(result.triangles),
		"bodies": int(result.static_bodies),
		"shapes": int(result.shapes),
		"collision_face_vertices": int(node.get_meta("collision_face_vertices", -1)),
	}


func _mesh_triangle_map(node: Node3D) -> Dictionary:
	var result := {}
	for child: Node in node.get_children():
		if child is MeshInstance3D:
			var arrays := (((child as MeshInstance3D).mesh as ArrayMesh).surface_get_arrays(0))
			result[str(child.name)] = int((arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3)
	return result


func _mesh_array_sha256_map(node: Node3D) -> Dictionary:
	var result := {}
	for child: Node in node.get_children():
		if child is MeshInstance3D:
			result[str(child.name)] = _mesh_array_sha256((child as MeshInstance3D).mesh as ArrayMesh)
	return result


func _mesh_array_sha256(mesh: ArrayMesh) -> String:
	if mesh == null or mesh.get_surface_count() != 1:
		return ""
	var arrays := mesh.surface_get_arrays(0)
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	for slot in [Mesh.ARRAY_VERTEX, Mesh.ARRAY_NORMAL, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_INDEX]:
		var value: Variant = arrays[slot]
		if value is PackedVector3Array:
			context.update((value as PackedVector3Array).to_byte_array())
		elif value is PackedVector2Array:
			context.update((value as PackedVector2Array).to_byte_array())
		elif value is PackedInt32Array:
			context.update((value as PackedInt32Array).to_byte_array())
	return context.finish().hex_encode()


func _mesh_box_prefix_sha256(mesh: ArrayMesh, box_count: int) -> String:
	if mesh == null or mesh.get_surface_count() != 1 or box_count < 0:
		return ""
	var arrays := mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	var vertex_count := box_count * 24
	var index_count := box_count * 36
	if vertices.size() < vertex_count or normals.size() < vertex_count or uvs.size() < vertex_count or indices.size() < index_count:
		return ""
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(vertices.slice(0, vertex_count).to_byte_array())
	context.update(normals.slice(0, vertex_count).to_byte_array())
	context.update(uvs.slice(0, vertex_count).to_byte_array())
	context.update(indices.slice(0, index_count).to_byte_array())
	return context.finish().hex_encode()


func _chain_length(record: Dictionary, runs: Array[int]) -> float:
	var result := 0.0
	for run_index in runs:
		result += float(_run_frame(record, run_index).length_m)
	return result


func _chain_frame(record: Dictionary, runs: Array[int], chain_m: float) -> Dictionary:
	var accumulated := 0.0
	for run_index in runs:
		var frame := _run_frame(record, run_index)
		var length := float(frame.length_m)
		if chain_m <= accumulated + length + 0.0001:
			var fraction := clampf((chain_m - accumulated) / length, 0.0, 1.0)
			return {
				"wall_anchor": (frame.start as Vector3).lerp(frame.end as Vector3, fraction),
				"tangent": frame.tangent,
				"normal": frame.normal,
				"run_index": run_index,
			}
		accumulated += length
	return {}


func _run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var offset := run_index * 12
	if run_index < 0 or offset + 11 >= values.size():
		return {}
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var horizontal := end - start
	horizontal.y = 0.0
	return {
		"start": start,
		"end": end,
		"length_m": horizontal.length(),
		"tangent": horizontal.normalized(),
		"normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized(),
	}


func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


func _collision_sha256(node: Node3D) -> String:
	var shape_node := node.find_child("Shape", true, false) as CollisionShape3D
	if shape_node == null or not (shape_node.shape is ConcavePolygonShape3D):
		return ""
	var faces := (shape_node.shape as ConcavePolygonShape3D).get_faces()
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(faces.to_byte_array())
	return context.finish().hex_encode()


func _record(key: String) -> Dictionary:
	var chunk := _json(MAIN_CHUNK_PATH)
	for value: Variant in chunk.get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _free_result(result: Dictionary) -> void:
	var node := result.get("node") as Node
	if node != null:
		node.free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false
