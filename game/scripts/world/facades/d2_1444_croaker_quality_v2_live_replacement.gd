class_name D21444CroakerQualityV2LiveReplacement
extends RefCounted

## Fail-closed paired live translation of the independently reviewed 1444
## Croaker standalone hero. The supplied chunk is preflighted before row
## dispatch, the pinned factory runs once, and its exact shell is partitioned
## into one wall spray receiver and one input-only roof landing/blocking owner.
## Closed recesses remain noneligible solid blockers; other relief is render-only. The sealed factory predates Godot's
## clockwise roof-front correction, so this live seam reverses only the roof
## index order while retaining exact vertices, UVs, normals, and material.

const PROTOTYPE := preload("res://game/scripts/world/facades/d2_1444_croaker_quality_v2_prototype.gd")
const CONFIG_PATH := "res://game/resources/facades/d2_1444_croaker_quality_v2_live_replacement.json"
const EXPECTED_CONFIG_SHA256 := "472f82f5a3d98b0778aca758ae8277f8b8ba9b4a39875ff54f67781280965135"
const ADAPTER_ID := "active-adapter:d2-1444-live:building:w95934117:wall"
const SOURCE_KEY := "w95934117"
const WALL_KEY := "building:w95934117:wall"
const ROOF_KEY := "building:w95934117:roof"
const TARGET_CHUNK_ID := "x_-2__z_-1"
const TARGET_CHUNK_SHA256 := "6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2"
const SOURCE_GEOMETRY_SHA256 := "52c844ec3cbeae52b97e12014dac8761c8518b6b4e5ce6df5eeee64256eadcc4"
const CANONICAL_WALL_RECORD_SHA256 := "5a872a7e700aec63a2c276bb28c341e3f501ac8122f51267b05fb8a620d15950"
const CANONICAL_ROOF_RECORD_SHA256 := "0119a96ef2f8baf3e7a66a3db952cfd34930490b86dd25bf3693472728dadae1"
const EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 := "2728b7cc57ec026e457ffdb508d50f846a84af4bb5a403b73d553bbaf1d31c5c"
const EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256 := "78b0c328ae438d2d69769c31b9d08c0b3ce54816ae0e39a5802ab741fb967b95"
const EXPECTED_WALL_PROJECTION_SHA256 := "1497487d53fc7eeb98f8399fd8fc47c159c2652e68a486ce496b860fddcfffb6"
const EXPECTED_ROOF_PROJECTION_SHA256 := "a4e69552758e9f2927c40a5d4021c8b4cd7dcf7c065f3b78c235219e4fe0eb7a"
const EXPECTED_GEOMETRY_SIGNATURE := "1dba8f84003a0818c2ddb91504f41c3437a63fe0856ade70d1c194ca1be8d141"
const EXPECTED_LIVE_OWNERSHIP_SIGNATURE := "979910c4d53486b86db04cdf04528789f668a01c41dc27114e481c843b91b92d"
const STANDALONE_APPROVAL_RECEIPT_ID := "d2-1444-quality-v2-isolated-art-pass-2026-09-09"
const STANDALONE_APPROVAL_RECEIPT_SHA256 := "385a544210717ee104458e23123e534291fc73149d1910a73a90dcb923e956a5"
const PACKAGE_AUDIT_RECEIPT_SHA256 := "285ad681634bfa4ec800be0a935bb17b3e850e384581300357ce1e56b1ff09b1"
const PACKAGE_PROMOTION_RECEIPT_SHA256 := "74052c247c5d2dbd6828301aca29eed2e842cb90d5a1c3aa9db5c1b743aeadfb"
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const EXPECTED_MESH_INSTANCES := 11
const EXPECTED_SURFACES := 11
const EXPECTED_VISUAL_TRIANGLES := 726
const EXPECTED_WALL_VISUAL_TRIANGLES := 716
const EXPECTED_ROOF_VISUAL_TRIANGLES := 10
const EXPECTED_DECORATIVE_TRIANGLES := 612
const EXPECTED_COLLISION_TRIANGLES := 114
const EXPECTED_WALL_COLLISION_TRIANGLES := 104
const EXPECTED_ROOF_COLLISION_TRIANGLES := 10
const EXPECTED_ELIGIBLE_WALL_TRIANGLES := 64
const EXPECTED_CLOSED_RECESS_TRIANGLES := 40
const CLOSED_RECESS_MESH_NAMES := ["BlankEndUndercroftOpaqueShadow", "BlankEndUndercroftOchreFrame", "FarEndRecessedTwoLevelOpaqueVoids", "FarEndBalconyOchreSlabs"]
const ROOF_MESH_NAME := "ExactPlanShallowGableRoof"
const SOURCE_WALL_MESH_NAMES := ["ProtectedExactWallRuns", "MappedWSWExactOchreStuccoWallRuns"]
const EXPECTED_BATCH_TRIANGLES := {
	"BlankEndUndercroftOchreFrame": 16,
	"BlankEndUndercroftOpaqueShadow": 4,
	"ExactPlanShallowGableRoof": 10,
	"FarEndBalconyOchreSlabs": 16,
	"FarEndRecessedTwoLevelOpaqueVoids": 4,
	"FarEndSimpleMetalRails": 96,
	"MappedWSWBroadEaves": 84,
	"MappedWSWExactOchreStuccoWallRuns": 34,
	"ProtectedExactWallRuns": 30,
	"SparseReturnOchreOpeningFrames": 360,
	"SparseReturnOpaqueOpenings": 72
}
const EXPECTED_MATERIALS := {
	"ProtectedExactWallRuns": {"path": "res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres", "name": "site_12_protected_neutral_nonclaim", "color": Color(0.54, 0.55, 0.53, 1.0), "metallic": 0.0, "roughness": 0.91},
	"MappedWSWExactOchreStuccoWallRuns": {"path": "res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres", "name": "site_12_ochre_tan_stucco_shared_micro_surface", "color": Color(0.78, 0.61, 0.42, 1.0), "metallic": 0.0, "roughness": 0.88, "texture": "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png", "uv_scale": Vector3(0.333333, 0.333333, 1.0)},
	"ExactPlanShallowGableRoof": {"path": "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres", "name": "site_12_dark_brown_roof_albedo_surrogate", "color": Color(0.40, 0.28, 0.20, 1.0), "metallic": 0.0, "roughness": 0.9, "texture": "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg", "uv_scale": Vector3(0.2, 0.2, 1.0)},
	"MappedWSWBroadEaves": {"path": "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres", "name": "site_12_dark_brown_roof_albedo_surrogate", "color": Color(0.40, 0.28, 0.20, 1.0), "metallic": 0.0, "roughness": 0.9, "texture": "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg", "uv_scale": Vector3(0.2, 0.2, 1.0)},
	"BlankEndUndercroftOpaqueShadow": {"path": "res://game/resources/materials/world/site_12_housing/d2_1444_quality_v2_recess_backing.tres", "name": "d2_1444_neutral_opaque_exterior_recess_backing", "color": Color(0.28, 0.25, 0.21, 1.0), "metallic": 0.0, "roughness": 0.86},
	"BlankEndUndercroftOchreFrame": {"path": "res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres", "name": "site_12_ochre_tan_stucco_shared_micro_surface", "color": Color(0.78, 0.61, 0.42, 1.0), "metallic": 0.0, "roughness": 0.88, "texture": "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png", "uv_scale": Vector3(0.333333, 0.333333, 1.0)},
	"SparseReturnOpaqueOpenings": {"path": "res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres", "name": "site_12_opaque_blue_gray_opening", "color": Color(0.105, 0.145, 0.16, 1.0), "metallic": 0.0, "roughness": 0.47},
	"SparseReturnOchreOpeningFrames": {"path": "res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres", "name": "site_12_ochre_tan_stucco_shared_micro_surface", "color": Color(0.78, 0.61, 0.42, 1.0), "metallic": 0.0, "roughness": 0.88, "texture": "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png", "uv_scale": Vector3(0.333333, 0.333333, 1.0)},
	"FarEndRecessedTwoLevelOpaqueVoids": {"path": "res://game/resources/materials/world/site_12_housing/d2_1444_quality_v2_recess_backing.tres", "name": "d2_1444_neutral_opaque_exterior_recess_backing", "color": Color(0.28, 0.25, 0.21, 1.0), "metallic": 0.0, "roughness": 0.86},
	"FarEndBalconyOchreSlabs": {"path": "res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres", "name": "site_12_ochre_tan_stucco_shared_micro_surface", "color": Color(0.78, 0.61, 0.42, 1.0), "metallic": 0.0, "roughness": 0.88, "texture": "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png", "uv_scale": Vector3(0.333333, 0.333333, 1.0)},
	"FarEndSimpleMetalRails": {"path": "res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres", "name": "site_12_dark_simple_metal", "color": Color(0.075, 0.068, 0.06, 1.0), "metallic": 0.38, "roughness": 0.57},
}
const SOURCE_DEPENDENCY_HASHES := {
	"res://game/scripts/world/facades/d2_1444_croaker_quality_v2_prototype.gd": "afe74e5254af720cd855fb8dbadcb71a283d0c8b2d0f79c9565dd2e62b6e9d42",
	"res://game/resources/facades/d2_1444_croaker_quality_v2_prototype.json": "22efb2fa24ea1db245f8fe204e3f029312da59a7a67644d2f1464f02661046ef",
	"res://game/scripts/world/facades/site_12_housing_kit.gd": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
	"res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres": "9486ccf52e1f2aff9fc940f60644733d5cf9bf1cb03cebb5332bcc1d7c0aaaf6",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres": "d97d7b4a442ffe8ad9a0b003e5c1d6466f9ef9effc7cdb2be8ef966195e66782",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres": "389c01066767b085ef8ed8ae4c5e1b06062d9ffb135e3e6a7bfa968b963717d7",
	"res://game/resources/materials/world/site_12_housing/d2_1444_quality_v2_recess_backing.tres": "796b27c2821e62f554232d2b355adb566d96aa3cd5ed8ef7fb765317f190721a",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres": "eddc4900c351dc3a75d163bd380a8b3a39bf6a1c1c3647299e3af19634a60ead",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres": "75c13aa30a4e3c9f49980d78abe41f40c6c7ab270be6152c201eb8a72ebe8720",
	"res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png": "af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg": "fa09ed33d59c3bb90ef70d36352207e2e1ca5564cfc61295c0124d1a7d785808",
	"res://game/scripts/player/player_camera.gd": "1d53f11cc3d9de00d4bb580aa6322c6f53b0080e5b9e1e3b18baeefd52125cc3",
	"res://game/scenes/player/player.tscn": "a37b00ecc620b4f3106a14d1dc9ec22a519f81481e5e6c68252389e13488a793"
}


static func claims_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in [WALL_KEY, ROOF_KEY]


static func prepare_chunk_records(chunk: Dictionary) -> Dictionary:
	var records_value: Variant = chunk.get("records", null)
	if not (records_value is Array):
		return _failure("d2_1444_live_chunk_records", "The supplied chunk has no record array.", {})
	var target_records: Array[Dictionary] = []
	for record_value: Variant in records_value as Array:
		if not (record_value is Dictionary):
			continue
		var record := record_value as Dictionary
		var object_key := str(record.get("object_key", ""))
		var source_keys_value: Variant = record.get("source_keys", [])
		var source_keys := source_keys_value as Array if source_keys_value is Array else []
		if object_key in [WALL_KEY, ROOF_KEY] or SOURCE_KEY in source_keys:
			target_records.append(record)
	var target_chunk := str(chunk.get("chunk_id", "")) == TARGET_CHUNK_ID
	if target_records.is_empty() and not target_chunk:
		return {"ok": true, "contains_target": false}
	if not target_chunk or target_records.size() != 2:
		return _failure("d2_1444_live_chunk_pair_count", "1444 Croaker must remain exactly one wall+roof pair in x_-2__z_-1.", target_records[0] if not target_records.is_empty() else {})
	var wall := _record_for_key(target_records, WALL_KEY)
	var roof := _record_for_key(target_records, ROOF_KEY)
	if wall.is_empty() or roof.is_empty() or not _record_pair_matches(wall, roof):
		return _failure("d2_1444_live_chunk_pair", "The supplied 1444 Croaker pair is missing, duplicated, or drifted.", target_records[0])
	return {"ok": true, "contains_target": true, "wall": wall, "roof": roof}


static func build_chunk_plan(prepared_pair: Dictionary) -> Dictionary:
	if not bool(prepared_pair.get("ok", false)):
		return prepared_pair
	if not bool(prepared_pair.get("contains_target", false)):
		return {"ok": true, "contains_target": false, "records": {}, "pending_keys": {}}
	var wall := prepared_pair.get("wall", {}) as Dictionary
	var roof := prepared_pair.get("roof", {}) as Dictionary
	if not _record_pair_matches(wall, roof):
		return _failure("d2_1444_live_prepared_pair", "The prepared 1444 pair drifted after chunk preflight.", wall)
	var config_result := _validated_config()
	if not bool(config_result.get("ok", false)):
		return _failure("d2_1444_live_config", str(config_result.get("message", "Live config drifted.")), wall)
	if not runtime_dependency_closure_exists():
		return _failure("d2_1444_live_dependency", "The reviewed executable dependency closure is incomplete.", wall)
	var pair_result := _build_paired_replacement(wall, roof)
	if not bool(pair_result.get("ok", false)):
		return pair_result
	return {
		"ok": true,
		"contains_target": true,
		"records": {WALL_KEY: pair_result.wall_result, ROOF_KEY: pair_result.roof_result},
		"pending_keys": {WALL_KEY: true, ROOF_KEY: true},
	}


static func consume_record(record: Dictionary, chunk_plan: Dictionary) -> Dictionary:
	if not claims_record(record):
		return _failure("d2_1444_live_target", "The 1444 adapter received an unrelated row.", record)
	if not bool(chunk_plan.get("ok", false)) or not bool(chunk_plan.get("contains_target", false)):
		return _failure("d2_1444_live_unprepared_pair", "The validated supplied-chunk plan is required.", record)
	var key := str(record.get("object_key", ""))
	var pending := chunk_plan.get("pending_keys", {}) as Dictionary
	var results := chunk_plan.get("records", {}) as Dictionary
	if not pending.has(key) or not results.has(key):
		return _failure("d2_1444_live_duplicate_consume", "A 1444 row was missing or consumed twice.", record)
	var expected_runtime := EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 if key == WALL_KEY else EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256
	var expected_canonical := CANONICAL_WALL_RECORD_SHA256 if key == WALL_KEY else CANONICAL_ROOF_RECORD_SHA256
	if record_signature(record) != expected_runtime or canonical_record_signature(record) != expected_canonical:
		return _failure("d2_1444_live_supplied_record", "The consumed row differs from the sealed pair plan.", record)
	var result := results[key] as Dictionary
	pending.erase(key)
	results.erase(key)
	return result


static func plan_was_fully_consumed(chunk_plan: Dictionary) -> bool:
	return not bool(chunk_plan.get("contains_target", false)) or (chunk_plan.get("pending_keys", {}) as Dictionary).is_empty()


static func free_unconsumed(chunk_plan: Dictionary) -> void:
	var results := chunk_plan.get("records", {}) as Dictionary
	for key: Variant in results.keys():
		var result := results[key] as Dictionary
		var node := result.get("node", null) as Node
		if node != null and not node.is_inside_tree():
			node.free()
	results.clear()
	(chunk_plan.get("pending_keys", {}) as Dictionary).clear()


static func record_signature(record: Dictionary) -> String:
	return JSON.stringify(record).sha256_text()


static func canonical_record_signature(record: Dictionary) -> String:
	return (_stable_json(record, 0) + "\n").sha256_text()


static func _stable_json(value: Variant, depth: int) -> String:
	match typeof(value):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "true" if bool(value) else "false"
		TYPE_INT:
			return str(int(value))
		TYPE_FLOAT:
			var number := float(value)
			return str(int(number)) if number == floor(number) else JSON.stringify(number)
		TYPE_STRING, TYPE_STRING_NAME:
			return JSON.stringify(str(value))
		TYPE_ARRAY:
			var values := value as Array
			if values.is_empty():
				return "[]"
			var lines: Array[String] = []
			for item: Variant in values:
				lines.append(" ".repeat((depth + 1) * 2) + _stable_json(item, depth + 1))
			return "[\n%s\n%s]" % [",\n".join(lines), " ".repeat(depth * 2)]
		TYPE_DICTIONARY:
			var object := value as Dictionary
			if object.is_empty():
				return "{}"
			var keys: Array[String] = []
			for key: Variant in object.keys():
				keys.append(str(key))
			keys.sort()
			var lines: Array[String] = []
			for key: String in keys:
				lines.append(" ".repeat((depth + 1) * 2) + JSON.stringify(key) + ": " + _stable_json(object[key], depth + 1))
			return "{\n%s\n%s}" % [",\n".join(lines), " ".repeat(depth * 2)]
	return JSON.stringify(value)


static func _record_pair_matches(wall: Dictionary, roof: Dictionary) -> bool:
	return _record_shape_matches(wall, true) and _record_shape_matches(roof, false) \
		and canonical_record_signature(wall) == CANONICAL_WALL_RECORD_SHA256 \
		and canonical_record_signature(roof) == CANONICAL_ROOF_RECORD_SHA256 \
		and record_signature(wall) == EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 \
		and record_signature(roof) == EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256 \
		and PROTOTYPE.record_signature(wall) == EXPECTED_WALL_PROJECTION_SHA256 \
		and PROTOTYPE.record_signature(roof) == EXPECTED_ROOF_PROJECTION_SHA256 \
		and PROTOTYPE.matches_record_pair(wall, roof)


static func _record_shape_matches(record: Dictionary, wall: bool) -> bool:
	var expected_keys: Array[String] = [
		"collision_kind", "feature_kind", "flat_base_elevation_m", "indices", "material_key",
		"normals", "object_key", "opaque", "receiver_kind", "source_height_m", "source_keys",
		"top_elevation_m", "uvs", "vertices",
	]
	if wall:
		expected_keys.append_array(["exterior_foundation_segments", "shared_wall_segments"])
	expected_keys.sort()
	var actual_keys: Array[String] = []
	for key: Variant in record.keys():
		actual_keys.append(str(key))
	actual_keys.sort()
	return actual_keys == expected_keys \
		and str(record.get("object_key", "")) == (WALL_KEY if wall else ROOF_KEY) \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == ("building_wall" if wall else "building_roof") \
		and str(record.get("material_key", "")) == ("building_wall" if wall else "building_roof") \
		and str(record.get("receiver_kind", "")) == ("building_wall" if wall else "none") \
		and str(record.get("collision_kind", "")) == "world_solid" and bool(record.get("opaque", false)) \
		and is_equal_approx(float(record.get("source_height_m", -1.0)), 6.0) \
		and is_equal_approx(float(record.get("flat_base_elevation_m", -1.0)), 2.521) \
		and is_equal_approx(float(record.get("top_elevation_m", -1.0)), 8.521) \
		and (record.get("vertices", []) as Array).size() == (264 if wall else 36) \
		and (record.get("normals", []) as Array).size() == (264 if wall else 36) \
		and (record.get("uvs", []) as Array).size() == (176 if wall else 24) \
		and (record.get("indices", []) as Array).size() == (132 if wall else 30) \
		and (not wall or (int(record.get("exterior_foundation_segments", -1)) == 22 and int(record.get("shared_wall_segments", -1)) == 0))


static func _build_paired_replacement(wall: Dictionary, roof: Dictionary) -> Dictionary:
	var prototype_result := PROTOTYPE.build_for_records(wall, roof)
	if not bool(prototype_result.get("ok", false)):
		return _failure("d2_1444_live_factory", str(prototype_result.get("message", "The reviewed geometry factory failed.")), wall)
	var wall_root := prototype_result.get("node", null) as Node3D
	if wall_root == null:
		return _failure("d2_1444_live_factory_node", "The reviewed factory returned no root.", wall)
	if not _factory_contract_matches(wall_root, prototype_result):
		wall_root.free()
		return _failure("d2_1444_live_factory_contract", "The reviewed signature, batch contract, or pinned historical roof order drifted.", wall)
	if not material_semantics_match(wall_root):
		wall_root.free()
		return _failure("d2_1444_live_material_semantics", "The reviewed material paths or semantics drifted.", wall)
	var roof_mesh := wall_root.get_node_or_null(ROOF_MESH_NAME) as MeshInstance3D
	if roof_mesh == null or not _normalize_live_roof_winding(roof_mesh):
		wall_root.free()
		return _failure("d2_1444_live_roof_winding", "The pinned roof could not be normalized to Godot's visible clockwise top order.", wall)
	var split := _split_collision(wall_root)
	if not bool(split.get("ok", false)):
		wall_root.free()
		return _failure("d2_1444_live_collision_partition", str(split.get("message", "Structural partition failed.")), wall)
	var roof_root := Node3D.new()
	wall_root.remove_child(roof_mesh)
	roof_root.add_child(roof_mesh)
	if _face_signature(split.wall_faces as PackedVector3Array) != _mesh_face_signature(wall_root, SOURCE_WALL_MESH_NAMES) \
	or _face_signature(split.closure_faces as PackedVector3Array) != _mesh_face_signature(wall_root, CLOSED_RECESS_MESH_NAMES) \
	or _oriented_face_signature(split.roof_faces as PackedVector3Array) != _mesh_oriented_face_signature(roof_root, [ROOF_MESH_NAME]):
		wall_root.free()
		roof_root.free()
		(split.wall_body as StaticBody3D).free()
		(split.roof_body as StaticBody3D).free()
		return _failure("d2_1444_live_collision_congruence", "Wall face sets or ordered roof collision faces differ from reviewed structural visuals.", wall)
	wall_root.add_child(split.wall_body as StaticBody3D)
	roof_root.add_child(split.roof_body as StaticBody3D)
	_apply_live_metadata(wall_root, roof_root)
	var measured := _measure([wall_root, roof_root])
	if not _measured_contract_matches(measured):
		wall_root.free()
		roof_root.free()
		return _failure("d2_1444_live_topology", "The paired live topology or ownership drifted: %s" % measured, wall)
	if not material_semantics_match(wall_root, roof_root):
		wall_root.free()
		roof_root.free()
		return _failure("d2_1444_live_postsplit_material", "Material semantics drifted during the live split.", wall)
	var ownership_signature := live_ownership_signature()
	if ownership_signature != EXPECTED_LIVE_OWNERSHIP_SIGNATURE:
		wall_root.free()
		roof_root.free()
		return _failure("d2_1444_live_ownership_signature", "Live ownership signature drifted (%s)." % ownership_signature, wall)
	var metadata := {
		"schema_version": "ti.d2-1444-croaker-live-replacement/1",
		"adapter_id": ADAPTER_ID,
		"source_key": SOURCE_KEY,
		"wall_object_key": WALL_KEY,
		"roof_object_key": ROOF_KEY,
		"canonical_wall_record_sha256": CANONICAL_WALL_RECORD_SHA256,
		"canonical_roof_record_sha256": CANONICAL_ROOF_RECORD_SHA256,
		"runtime_wall_dictionary_sha256": EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256,
		"runtime_roof_dictionary_sha256": EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256,
		"geometry_signature": EXPECTED_GEOMETRY_SIGNATURE,
		"live_ownership_signature": ownership_signature,
		"standalone_approval_receipt_id": STANDALONE_APPROVAL_RECEIPT_ID,
		"standalone_approval_receipt_sha256": STANDALONE_APPROVAL_RECEIPT_SHA256,
		"shared_stucco_historical_package_audit_receipt_sha256": PACKAGE_AUDIT_RECEIPT_SHA256,
		"shared_stucco_historical_package_promotion_receipt_sha256": PACKAGE_PROMOTION_RECEIPT_SHA256,
		"replacement_mode": "atomic_pair_visual_replacement_with_split_exact_wall_and_normalized_gable_collision",
		"fallback_allowed": false,
		"partial_pair_allowed": false,
		"stack_allowed": false,
		"mesh_instances": EXPECTED_MESH_INSTANCES,
		"surfaces": EXPECTED_SURFACES,
		"visual_triangles": EXPECTED_VISUAL_TRIANGLES,
		"decorative_noncolliding_triangles": EXPECTED_DECORATIVE_TRIANGLES,
		"structural_owner_count": 2,
		"shape_count": 3,
		"wall_collision_triangles": EXPECTED_WALL_COLLISION_TRIANGLES,
		"eligible_wall_collision_triangles": EXPECTED_ELIGIBLE_WALL_TRIANGLES,
		"closed_recess_collision_triangles": EXPECTED_CLOSED_RECESS_TRIANGLES,
		"roof_collision_triangles": EXPECTED_ROOF_COLLISION_TRIANGLES,
		"spray_owner_count": 1,
		"roof_spray_receiver_count": 0,
		"roof_spray_ray_blocking": true,
		"roof_landing_world_solid": true,
		"roof_winding_normalized_from_pinned_factory": true,
		"navigation_owner_count": 0,
		"accepted_authority_schema": "ti.facade-runtime-registry/9",
		"accepted_recognition_metric": "9/213",
		"candidate_recognition_credit": 0,
		"recognition_accepted": false,
		"believability_accepted": false,
		"as_built_fidelity_claimed": false,
		"independent_live_review_status": "pending",
		"live_technical_evidence_status": "pending",
		"mapped_public_run_indices": PROTOTYPE.TARGET_RUNS.duplicate(),
		"undercroft_run_indices": PROTOTYPE.BLANK_END_RUNS.duplicate(),
		"sparse_opening_run_indices": PROTOTYPE.SPARSE_OPENING_RUNS.duplicate(),
		"balcony_run_indices": PROTOTYPE.BALCONY_RUNS.duplicate(),
		"quiet_mapped_run_indices": PROTOTYPE.QUIET_MAPPED_RUNS.duplicate(),
		"protected_run_indices": PROTOTYPE.PROTECTED_RUNS.duplicate(),
		"measured": measured.duplicate(true),
	}
	wall_root.set_meta("d2_1444_croaker_live_replacement", metadata.duplicate(true))
	roof_root.set_meta("d2_1444_croaker_live_replacement", metadata.duplicate(true))
	return {
		"ok": true,
		"wall_result": {"ok": true, "node": wall_root, "metadata": metadata, "mesh_instances": 10, "surfaces": 10, "triangles": EXPECTED_WALL_VISUAL_TRIANGLES, "static_bodies": 1, "shapes": 2},
		"roof_result": {"ok": true, "node": roof_root, "metadata": metadata, "mesh_instances": 1, "surfaces": 1, "triangles": EXPECTED_ROOF_VISUAL_TRIANGLES, "static_bodies": 1, "shapes": 1},
	}


static func _factory_contract_matches(root: Node3D, result: Dictionary) -> bool:
	var metadata := result.get("metadata", {}) as Dictionary
	var measured := _measure([root])
	if str(root.get_meta("deterministic_signature", "")) != EXPECTED_GEOMETRY_SIGNATURE \
	or str(metadata.get("deterministic_signature", "")) != EXPECTED_GEOMETRY_SIGNATURE \
	or not bool(root.get_meta("prototype_only", false)) or bool(root.get_meta("runtime_attachment", true)) \
	or int(measured.get("mesh_instances", -1)) != EXPECTED_MESH_INSTANCES \
	or int(measured.get("surfaces", -1)) != EXPECTED_SURFACES \
	or int(measured.get("visual_triangles", -1)) != EXPECTED_VISUAL_TRIANGLES \
	or int(measured.get("static_bodies", -1)) != 1 or int(measured.get("shapes", -1)) != 3 \
	or int(measured.get("collision_triangles", -1)) != EXPECTED_COLLISION_TRIANGLES:
		return false
	var seen := {}
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			var mesh := (child as MeshInstance3D).mesh
			if not EXPECTED_BATCH_TRIANGLES.has(child.name) or mesh == null or mesh.get_surface_count() != 1:
				return false
			if int(mesh.surface_get_array_index_len(0) / 3) != int(EXPECTED_BATCH_TRIANGLES[child.name]):
				return false
			seen[child.name] = true
	var roof_mesh := root.get_node_or_null(ROOF_MESH_NAME) as MeshInstance3D
	return seen.size() == EXPECTED_BATCH_TRIANGLES.size() and pinned_factory_roof_winding_matches(roof_mesh)


static func pinned_factory_roof_winding_matches(instance: MeshInstance3D) -> bool:
	if instance == null or instance.material_override != null or instance.mesh == null \
	or instance.mesh.get_surface_count() != 1 or not (instance.mesh.surface_get_material(0) is BaseMaterial3D):
		return false
	var material := instance.mesh.surface_get_material(0) as BaseMaterial3D
	if material.cull_mode != BaseMaterial3D.CULL_BACK:
		return false
	var arrays := instance.mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	if indices.size() != EXPECTED_ROOF_VISUAL_TRIANGLES * 3 or normals.size() != vertices.size():
		return false
	for offset in range(0, indices.size(), 3):
		var winding := (vertices[indices[offset + 1]] - vertices[indices[offset]]).cross(vertices[indices[offset + 2]] - vertices[indices[offset]])
		if winding.length_squared() <= 0.000001 or winding.normalized().y <= 0.4:
			return false
		for corner in 3:
			if normals[indices[offset + corner]].y <= 0.4:
				return false
	return true


static func _normalize_live_roof_winding(instance: MeshInstance3D) -> bool:
	if not pinned_factory_roof_winding_matches(instance):
		return false
	var source_mesh := instance.mesh
	var arrays := source_mesh.surface_get_arrays(0)
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	for offset in range(0, indices.size(), 3):
		var swap := indices[offset + 1]
		indices[offset + 1] = indices[offset + 2]
		indices[offset + 2] = swap
	arrays[Mesh.ARRAY_INDEX] = indices
	var normalized := ArrayMesh.new()
	normalized.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	normalized.surface_set_name(0, source_mesh.surface_get_name(0))
	normalized.surface_set_material(0, source_mesh.surface_get_material(0))
	instance.mesh = normalized
	return roof_render_front_face_matches(instance)


static func roof_render_front_face_matches(instance: MeshInstance3D) -> bool:
	if instance == null or instance.material_override != null or instance.mesh == null \
	or instance.mesh.get_surface_count() != 1 or not (instance.mesh.surface_get_material(0) is BaseMaterial3D):
		return false
	var material := instance.mesh.surface_get_material(0) as BaseMaterial3D
	if material.cull_mode != BaseMaterial3D.CULL_BACK:
		return false
	var arrays := instance.mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	if indices.size() != EXPECTED_ROOF_VISUAL_TRIANGLES * 3 or normals.size() != vertices.size():
		return false
	for offset in range(0, indices.size(), 3):
		var winding := (vertices[indices[offset + 1]] - vertices[indices[offset]]).cross(vertices[indices[offset + 2]] - vertices[indices[offset]])
		if winding.length_squared() <= 0.000001 or winding.normalized().y >= -0.4:
			return false
		for corner in 3:
			if normals[indices[offset + corner]].y <= 0.4:
				return false
	return true


static func _split_collision(root: Node3D) -> Dictionary:
	var original := root.get_node_or_null("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	if original == null or original.get_child_count() != 3:
		return {"ok": false, "message": "Reviewed factory must retain three ordered structural shapes."}
	var names := ["ExactRemainingExteriorWallShape", "ClosedExteriorRecessShape", "ExactRoofShape"]
	var triangle_counts := [EXPECTED_ELIGIBLE_WALL_TRIANGLES, EXPECTED_CLOSED_RECESS_TRIANGLES, EXPECTED_ROOF_COLLISION_TRIANGLES]
	var faces: Array[PackedVector3Array] = []
	for index in 3:
		var node := original.get_child(index) as CollisionShape3D
		if node == null or node.name != names[index] or not (node.shape is ConcavePolygonShape3D):
			return {"ok": false, "message": "Reviewed structural shape order or type drifted."}
		var vertices := (node.shape as ConcavePolygonShape3D).get_faces()
		if vertices.size() != int(triangle_counts[index]) * 3 or str(node.shape.get_meta("receiver_kind", "")) != "none":
			return {"ok": false, "message": "Reviewed structural face count or spray eligibility drifted."}
		faces.append(vertices)
	var roof_faces := PackedVector3Array()
	for offset in range(0, faces[2].size(), 3):
		# Same roof-only winding seam as the frozen earlier live adapter.
		for corner in [0, 2, 1]:
			roof_faces.append(faces[2][offset + int(corner)])
	var roof_shape := original.get_child(2)
	original.remove_child(roof_shape)
	roof_shape.free()
	root.remove_child(original)
	original.name = "Collision"
	_clear_metadata(original)
	original.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
	original.collision_mask = 0
	original.set_meta("receiver_kind", "building_wall")
	original.set_meta("opaque", true)
	original.set_meta("derived_object_key", WALL_KEY)
	original.set_meta("source_keys", [SOURCE_KEY])
	original.set_meta("runtime_attachment", true)
	original.set_meta("prototype_only", false)
	original.set_meta("spray_ownership", "sole_wall_receiver_with_noneligible_closed_recess")
	original.set_meta("spray_ray_blocking", true)
	original.add_to_group("spray_receiver_wall")
	for index in 2:
		var node := original.get_child(index) as CollisionShape3D
		node.name = "Shape" if index == 0 else "ClosedRecessShape"
		node.shape.set_meta("receiver_kind", "building_wall" if index == 0 else "none")
		node.shape.set_meta("derived_object_key", WALL_KEY)
		node.shape.set_meta("source_keys", [SOURCE_KEY])
		node.shape.set_meta("runtime_attachment", true)
		node.shape.set_meta("prototype_only", false)
	return {
		"ok": true, "wall_faces": faces[0], "closure_faces": faces[1], "roof_faces": roof_faces,
		"wall_body": original,
		"roof_body": _collision_body("Collision", roof_faces, ROOF_KEY, "none", false),
	}


static func _collision_body(node_name: String, faces: PackedVector3Array, object_key: String, receiver_kind: String, wall: bool) -> StaticBody3D:
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.set_meta("receiver_kind", receiver_kind)
	shape.set_meta("opaque", true)
	shape.set_meta("derived_object_key", object_key)
	shape.set_meta("source_keys", [SOURCE_KEY])
	shape.set_meta("runtime_attachment", true)
	shape.set_meta("prototype_only", false)
	shape.set_meta("ownership_partition", "exact_source_wall_shell" if wall else "exact_plan_shallow_gable_roof")
	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	shape_node.shape = shape
	var body := StaticBody3D.new()
	body.name = node_name
	body.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
	body.collision_mask = 0
	body.set_meta("receiver_kind", receiver_kind)
	body.set_meta("opaque", true)
	body.set_meta("derived_object_key", object_key)
	body.set_meta("source_keys", [SOURCE_KEY])
	body.set_meta("runtime_attachment", true)
	body.set_meta("prototype_only", false)
	body.set_meta("spray_ownership", "sole_wall_receiver" if wall else "none_roof_rejection_blocker")
	body.set_meta("spray_ray_blocking", true)
	body.set_meta("roof_landing_world_solid", not wall)
	body.set_meta("ownership_partition", "exact_source_wall_shell" if wall else "exact_plan_shallow_gable_roof")
	if wall:
		body.add_to_group("spray_receiver_wall")
	body.add_child(shape_node)
	return body


static func _apply_live_metadata(wall_root: Node3D, roof_root: Node3D) -> void:
	wall_root.name = "D21444CroakerLiveWallReplacement"
	roof_root.name = "D21444CroakerLiveRoofReplacement"
	for root: Node3D in [wall_root, roof_root]:
		_clear_metadata(root)
		root.set_meta("prototype_only", false)
		root.set_meta("runtime_attachment", true)
		root.set_meta("adapter_id", ADAPTER_ID)
		root.set_meta("registry_status", "unregistered_live_candidate_authority_remains_v9")
		root.set_meta("world_builder_status", "directly_attached_uncredited_candidate")
		root.set_meta("technical_evidence_status", "live_capture_pending")
		root.set_meta("independent_live_review_status", "pending")
		root.set_meta("recognition_accepted", false)
		root.set_meta("believability_accepted", false)
		root.set_meta("runtime_supersedes_generated_placeholder", true)
		root.set_meta("superseded_object_keys", [WALL_KEY, ROOF_KEY])
		root.set_meta("source_geometry_sha256", SOURCE_GEOMETRY_SHA256)
		root.set_meta("geometry_signature", EXPECTED_GEOMETRY_SIGNATURE)
		root.set_meta("live_ownership_signature", EXPECTED_LIVE_OWNERSHIP_SIGNATURE)
		root.set_meta("fallback_allowed", false)
		root.set_meta("partial_pair_allowed", false)
		root.set_meta("stack_allowed", false)
	wall_root.set_meta("derived_object_key", WALL_KEY)
	wall_root.set_meta("source_keys", [SOURCE_KEY])
	wall_root.set_meta("feature_kind", "building_wall")
	wall_root.set_meta("receiver_kind", "building_wall")
	roof_root.set_meta("derived_object_key", ROOF_KEY)
	roof_root.set_meta("source_keys", [SOURCE_KEY])
	roof_root.set_meta("feature_kind", "building_roof")
	roof_root.set_meta("receiver_kind", "none")
	for root: Node3D in [wall_root, roof_root]:
		for node: Node in _descendants(root):
			if node is MeshInstance3D:
				_clear_metadata(node)
				node.set_meta("material_role", node.name)
				node.set_meta("prototype_only", false)
				node.set_meta("runtime_attachment", true)
				node.set_meta("derived_object_key", ROOF_KEY if node.name == ROOF_MESH_NAME else WALL_KEY)
				node.set_meta("source_keys", [SOURCE_KEY])
				node.set_meta("collision_ownership", "exact_roof_shape" if node.name == ROOF_MESH_NAME else ("eligible_exterior_wall_shape" if node.name in SOURCE_WALL_MESH_NAMES else ("noneligible_closed_recess_shape" if node.name in CLOSED_RECESS_MESH_NAMES else "render_only_noncolliding_relief")))


static func _clear_metadata(node: Node) -> void:
	for key: StringName in node.get_meta_list():
		node.remove_meta(key)


static func material_semantics_match(wall_root: Node3D, roof_root: Node3D = null) -> bool:
	var seen := {}
	var roots: Array[Node3D] = [wall_root]
	if roof_root != null:
		roots.append(roof_root)
	for root: Node3D in roots:
		for node: Node in _descendants(root):
			if not (node is MeshInstance3D):
				continue
			var instance := node as MeshInstance3D
			if seen.has(instance.name) or not EXPECTED_MATERIALS.has(instance.name) \
			or instance.mesh == null or instance.mesh.get_surface_count() != 1:
				return false
			if not _material_matches(instance.mesh.surface_get_material(0), EXPECTED_MATERIALS[instance.name] as Dictionary):
				return false
			seen[instance.name] = true
	return seen.size() == EXPECTED_MATERIALS.size()


static func _material_matches(material: Material, expected: Dictionary) -> bool:
	if not (material is StandardMaterial3D):
		return false
	var standard := material as StandardMaterial3D
	var expected_texture := str(expected.get("texture", ""))
	var texture_path := "" if standard.albedo_texture == null else standard.albedo_texture.resource_path
	return standard.resource_path == str(expected.path) \
		and standard.resource_name == str(expected.name) \
		and standard.albedo_color.is_equal_approx(expected.color as Color) \
		and is_equal_approx(standard.metallic, float(expected.metallic)) \
		and is_equal_approx(standard.roughness, float(expected.roughness)) \
		and texture_path == expected_texture \
		and standard.normal_texture == null and standard.roughness_texture == null \
		and standard.next_pass == null \
		and (not expected.has("uv_scale") or standard.uv1_scale.is_equal_approx(expected.uv_scale as Vector3))


static func source_dependency_hashes_match() -> bool:
	if FileAccess.get_sha256(CONFIG_PATH) != EXPECTED_CONFIG_SHA256:
		return false
	for path: String in SOURCE_DEPENDENCY_HASHES:
		if FileAccess.get_sha256(path) != str(SOURCE_DEPENDENCY_HASHES[path]):
			return false
	return true


static func runtime_dependency_closure_exists() -> bool:
	if not FileAccess.file_exists(CONFIG_PATH) or not FileAccess.file_exists(PROTOTYPE.CONFIG_PATH):
		return false
	for path: String in SOURCE_DEPENDENCY_HASHES:
		if path.get_extension() == "json":
			if not FileAccess.file_exists(path):
				return false
		elif not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
			return false
	return true


static func _validated_config() -> Dictionary:
	if FileAccess.get_sha256(CONFIG_PATH) != EXPECTED_CONFIG_SHA256:
		return {"ok": false, "message": "Live config bytes drifted."}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	if not (value is Dictionary):
		return {"ok": false, "message": "Live config did not parse."}
	var config := value as Dictionary
	var target := config.get("target", {}) as Dictionary
	var art := config.get("reviewed_art", {}) as Dictionary
	var pair := config.get("live_pair_contract", {}) as Dictionary
	var combined := pair.get("combined", {}) as Dictionary
	var wall := pair.get("wall", {}) as Dictionary
	var roof := pair.get("roof", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var package := config.get("package_boundary", {}) as Dictionary
	if str(config.get("schema_version", "")) != "ti.d2-1444-croaker-live-replacement/1" \
	or str(config.get("adapter_id", "")) != ADAPTER_ID \
	or str(target.get("source_key", "")) != SOURCE_KEY or str(target.get("wall_object_key", "")) != WALL_KEY \
	or str(target.get("roof_object_key", "")) != ROOF_KEY or str(target.get("chunk_id", "")) != TARGET_CHUNK_ID \
	or str(target.get("chunk_sha256", "")) != TARGET_CHUNK_SHA256 or str(target.get("source_geometry_sha256", "")) != SOURCE_GEOMETRY_SHA256 \
	or str(target.get("canonical_wall_record_sha256", "")) != CANONICAL_WALL_RECORD_SHA256 \
	or str(target.get("canonical_roof_record_sha256", "")) != CANONICAL_ROOF_RECORD_SHA256 \
	or str(target.get("prototype_wall_projection_sha256", "")) != EXPECTED_WALL_PROJECTION_SHA256 \
	or str(target.get("prototype_roof_projection_sha256", "")) != EXPECTED_ROOF_PROJECTION_SHA256 \
	or str(art.get("factory_geometry_signature", "")) != EXPECTED_GEOMETRY_SIGNATURE \
	or str(art.get("standalone_bar_raiser_receipt_id", "")) != STANDALONE_APPROVAL_RECEIPT_ID \
	or str(art.get("standalone_bar_raiser_receipt_sha256", "")) != STANDALONE_APPROVAL_RECEIPT_SHA256 \
	or _int_array(art.get("mapped_public_wsw_runs", []) as Array) != PROTOTYPE.TARGET_RUNS \
	or _int_array(art.get("undercroft_runs", []) as Array) != PROTOTYPE.BLANK_END_RUNS \
	or _int_array(art.get("sparse_opening_runs", []) as Array) != PROTOTYPE.SPARSE_OPENING_RUNS \
	or _int_array(art.get("balcony_runs", []) as Array) != PROTOTYPE.BALCONY_RUNS \
	or _int_array(art.get("quiet_mapped_runs", []) as Array) != PROTOTYPE.QUIET_MAPPED_RUNS \
	or _int_array(art.get("protected_runs", []) as Array) != PROTOTYPE.PROTECTED_RUNS \
	or int(combined.get("mesh_instances", -1)) != 11 or int(combined.get("surfaces", -1)) != 11 \
	or int(combined.get("visual_triangles", -1)) != EXPECTED_VISUAL_TRIANGLES or int(combined.get("static_bodies", -1)) != 2 \
	or int(combined.get("shapes", -1)) != 3 or int(combined.get("collision_triangles", -1)) != EXPECTED_COLLISION_TRIANGLES \
	or int(wall.get("shapes", -1)) != 2 or int(wall.get("eligible_exterior_triangles", -1)) != EXPECTED_ELIGIBLE_WALL_TRIANGLES or int(wall.get("noneligible_closed_recess_triangles", -1)) != EXPECTED_CLOSED_RECESS_TRIANGLES \
	or int(wall.get("collision_triangles", -1)) != EXPECTED_WALL_COLLISION_TRIANGLES or int(roof.get("collision_triangles", -1)) != 10 \
	or not bool(roof.get("live_winding_normalized_from_pinned_factory", false)) \
	or not bool(truth.get("runtime_attachment", false)) or not bool(truth.get("candidate_is_uncredited", false)) \
	or str(truth.get("accepted_authority_schema", "")) != "ti.facade-runtime-registry/9" \
	or str(truth.get("accepted_recognition_metric", "")) != "9/213" \
	or bool(truth.get("catalog_or_registry_promoted", true)) or bool(truth.get("recognition_accepted", true)) \
	or bool(truth.get("believability_accepted", true)) or bool(truth.get("as_built_fidelity_claimed", true)) \
	or bool(package.get("standalone_scene_instantiated", true)) or bool(package.get("generic_registry_loader_used", true)) \
	or bool(package.get("flag_or_environment_toggle", true)) or bool(package.get("missing_pair_member_loaded_from_disk", true)):
		return {"ok": false, "message": "Live config semantics drifted."}
	return {"ok": true, "config": config}


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func live_ownership_signature() -> String:
	return JSON.stringify({
		"schema_version": "ti.d2-1444-croaker-live-ownership/1",
		"adapter_id": ADAPTER_ID,
		"geometry_signature": EXPECTED_GEOMETRY_SIGNATURE,
		"wall_record_sha256": CANONICAL_WALL_RECORD_SHA256,
		"roof_record_sha256": CANONICAL_ROOF_RECORD_SHA256,
		"wall_shape_order": ["eligible_exterior", "noneligible_closed_recess"],
		"shape_count": 3,
		"wall_collision_triangles": EXPECTED_WALL_COLLISION_TRIANGLES,
		"eligible_wall_collision_triangles": EXPECTED_ELIGIBLE_WALL_TRIANGLES,
		"closed_recess_collision_triangles": EXPECTED_CLOSED_RECESS_TRIANGLES,
		"roof_collision_triangles": EXPECTED_ROOF_COLLISION_TRIANGLES,
		"wall_mesh_instances": 10,
		"roof_mesh_instances": 1,
		"wall_spray_owner_count": 1,
		"roof_spray_owner_count": 0,
		"decorative_collision_triangles": 0,
		"roof_winding_normalized_from_pinned_factory": true,
		"quiet_mapped_motif_hosts": 0,
	}).sha256_text()


static func _mesh_face_signature(root: Node, names: Array) -> String:
	var faces := PackedVector3Array()
	for name_value: Variant in names:
		var instance := root.get_node_or_null(str(name_value)) as MeshInstance3D
		if instance == null or instance.mesh == null or instance.mesh.get_surface_count() != 1:
			return ""
		var arrays := instance.mesh.surface_get_arrays(0)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		for index: int in indices:
			faces.append(vertices[index])
	return _face_signature(faces)


static func _mesh_oriented_face_signature(root: Node, names: Array) -> String:
	var faces := PackedVector3Array()
	for name_value: Variant in names:
		var instance := root.get_node_or_null(str(name_value)) as MeshInstance3D
		if instance == null or instance.mesh == null or instance.mesh.get_surface_count() != 1:
			return ""
		var arrays := instance.mesh.surface_get_arrays(0)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		for index: int in indices:
			faces.append(vertices[index])
	return _oriented_face_signature(faces)


static func _face_signature(faces: PackedVector3Array) -> String:
	if faces.size() % 3 != 0:
		return ""
	var triangles: Array[String] = []
	for offset in range(0, faces.size(), 3):
		var points: Array[String] = []
		for corner in 3:
			var point := faces[offset + corner]
			points.append("%.5f|%.5f|%.5f" % [point.x, point.y, point.z])
		points.sort()
		triangles.append("/".join(points))
	triangles.sort()
	return "\n".join(triangles).sha256_text()


static func _oriented_face_signature(faces: PackedVector3Array) -> String:
	if faces.size() % 3 != 0:
		return ""
	var triangles: Array[String] = []
	for offset in range(0, faces.size(), 3):
		var points: Array[String] = []
		for corner in 3:
			var point := faces[offset + corner]
			points.append("%.5f|%.5f|%.5f" % [point.x, point.y, point.z])
		triangles.append("/".join(points))
	triangles.sort()
	return "\n".join(triangles).sha256_text()


static func _measure(roots: Array) -> Dictionary:
	var result := {"mesh_instances": 0, "surfaces": 0, "visual_triangles": 0, "static_bodies": 0, "shapes": 0, "collision_triangles": 0, "wall_collision_triangles": 0, "eligible_wall_collision_triangles": 0, "closed_recess_collision_triangles": 0, "roof_collision_triangles": 0, "spray_owners": 0, "roof_spray_owners": 0, "navigation_nodes": 0, "decals": 0}
	for root_value: Variant in roots:
		for node: Node in _descendants(root_value as Node):
			if node is MeshInstance3D:
				result.mesh_instances += 1
				var mesh := (node as MeshInstance3D).mesh
				if mesh != null:
					result.surfaces += mesh.get_surface_count()
					for surface_index in mesh.get_surface_count():
						result.visual_triangles += int(mesh.surface_get_array_index_len(surface_index) / 3)
			elif node is StaticBody3D:
				result.static_bodies += 1
				if node.is_in_group("spray_receiver_wall"):
					result.spray_owners += 1
					if str(node.get_meta("derived_object_key", "")) == ROOF_KEY:
						result.roof_spray_owners += 1
			elif node is CollisionShape3D:
				result.shapes += 1
				var shape := (node as CollisionShape3D).shape
				if shape is ConcavePolygonShape3D:
					var triangles := int((shape as ConcavePolygonShape3D).get_faces().size() / 3)
					result.collision_triangles += triangles
					if str(shape.get_meta("derived_object_key", "")) == WALL_KEY:
						result.wall_collision_triangles += triangles
						if str(shape.get_meta("receiver_kind", "")) == "building_wall":
							result.eligible_wall_collision_triangles += triangles
						else:
							result.closed_recess_collision_triangles += triangles
					elif str(shape.get_meta("derived_object_key", "")) == ROOF_KEY:
						result.roof_collision_triangles += triangles
			elif node is NavigationRegion3D or node is NavigationObstacle3D or node is NavigationLink3D:
				result.navigation_nodes += 1
			elif node is Decal:
				result.decals += 1
	return result


static func _measured_contract_matches(measured: Dictionary) -> bool:
	return int(measured.get("mesh_instances", -1)) == EXPECTED_MESH_INSTANCES \
		and int(measured.get("surfaces", -1)) == EXPECTED_SURFACES \
		and int(measured.get("visual_triangles", -1)) == EXPECTED_VISUAL_TRIANGLES \
		and int(measured.get("static_bodies", -1)) == 2 and int(measured.get("shapes", -1)) == 3 \
		and int(measured.get("collision_triangles", -1)) == EXPECTED_COLLISION_TRIANGLES \
		and int(measured.get("wall_collision_triangles", -1)) == EXPECTED_WALL_COLLISION_TRIANGLES \
		and int(measured.get("eligible_wall_collision_triangles", -1)) == EXPECTED_ELIGIBLE_WALL_TRIANGLES \
		and int(measured.get("closed_recess_collision_triangles", -1)) == EXPECTED_CLOSED_RECESS_TRIANGLES \
		and int(measured.get("roof_collision_triangles", -1)) == EXPECTED_ROOF_COLLISION_TRIANGLES \
		and int(measured.get("spray_owners", -1)) == 1 and int(measured.get("roof_spray_owners", -1)) == 0 \
		and int(measured.get("navigation_nodes", -1)) == 0 and int(measured.get("decals", -1)) == 0


static func _descendants(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	var pending: Array[Node] = [root]
	while not pending.is_empty():
		var current := pending.pop_back() as Node
		result.append(current)
		for child: Node in current.get_children():
			pending.append(child)
	return result


static func _record_for_key(records: Array[Dictionary], object_key: String) -> Dictionary:
	for record: Dictionary in records:
		if str(record.get("object_key", "")) == object_key:
			return record
	return {}


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	var source_keys_value: Variant = record.get("source_keys", [])
	var source_keys := source_keys_value as Array if source_keys_value is Array else []
	return {"ok": false, "code": code, "message": message, "source_keys": source_keys.duplicate()}
