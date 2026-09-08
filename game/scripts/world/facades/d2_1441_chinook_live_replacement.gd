class_name D21441ChinookLiveReplacement
extends RefCounted

## Fail-closed paired live translation of the independently reviewed 1441
## Chinook standalone hero. The actual supplied chunk is claimed before row
## dispatch, the reviewed factory runs once, and its exact structural shell is
## repartitioned into one wall spray receiver and one roof rejection/landing
## owner. Decorative relief remains render-only.

const PROTOTYPE := preload("res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd")
const CONFIG_PATH := "res://game/resources/facades/d2_1441_chinook_live_replacement.json"
const EXPECTED_CONFIG_SHA256 := "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111"
const SOURCE_KEY := "w95934105"
const WALL_KEY := "building:w95934105:wall"
const ROOF_KEY := "building:w95934105:roof"
const TARGET_CHUNK_ID := "x_-1__z_-1"
const TARGET_CHUNK_SHA256 := "5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b"
const SOURCE_GEOMETRY_SHA256 := "952df7a4edca5dbaec7d74cb795b564cb1fa5567ea737d1a861e222b29ddf07f"
const CANONICAL_WALL_RECORD_SHA256 := "00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c"
const CANONICAL_ROOF_RECORD_SHA256 := "e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55"
const EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 := "53cc01f0cb52e07d11469d9d5ed6fd06a1e3f223c63aff64de9168f126b981e6"
const EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256 := "0533c706c798ffd00dc7cacbc3f5f47cafd460a1490dbe4af51ff07f17b8f3b5"
const EXPECTED_WALL_PROJECTION_SHA256 := "2f89ec3b90d7ab5999d79f92e7ebbae1265cf0b93e3931f8968e348ad91d8a5a"
const EXPECTED_ROOF_PROJECTION_SHA256 := "41a9b67b0c65aa26ca241183d37932e481f12bdc75b6253d928e4a1623013214"
const EXPECTED_GEOMETRY_SIGNATURE := "b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195"
const EXPECTED_LIVE_OWNERSHIP_SIGNATURE := "fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d"
const STANDALONE_APPROVAL_RECEIPT_ID := "d2-1441-chinook-standalone-hero-independent-pass-2026-09-04"
const STANDALONE_APPROVAL_RECEIPT_SHA256 := "8b259934a3771642efb5902c1fcbba590613e8f1f80e4b7d00a1b4a391862c55"
const PACKAGE_AUDIT_RECEIPT_SHA256 := "285ad681634bfa4ec800be0a935bb17b3e850e384581300357ce1e56b1ff09b1"
const PACKAGE_PROMOTION_RECEIPT_SHA256 := "74052c247c5d2dbd6828301aca29eed2e842cb90d5a1c3aa9db5c1b743aeadfb"
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const EXPECTED_MESH_INSTANCES := 9
const EXPECTED_SURFACES := 9
const EXPECTED_VISUAL_TRIANGLES := 1578
const EXPECTED_WALL_VISUAL_TRIANGLES := 1568
const EXPECTED_ROOF_VISUAL_TRIANGLES := 10
const EXPECTED_DECORATIVE_TRIANGLES := 1536
const EXPECTED_COLLISION_TRIANGLES := 42
const EXPECTED_WALL_COLLISION_TRIANGLES := 32
const EXPECTED_ROOF_COLLISION_TRIANGLES := 10
const WALL_COLLISION_TRIANGLE_RANGE := [0, 31]
const ROOF_COLLISION_TRIANGLE_RANGE := [32, 41]
const ROOF_MESH_NAME := "ExactPlanShallowGableRoof"
const SOURCE_WALL_MESH_NAMES := ["ProtectedExactWallRuns", "MappedSSEExactStuccoWallRuns"]
const EXPECTED_BATCH_TRIANGLES := {
	"ProtectedExactWallRuns": 24,
	"MappedSSEExactStuccoWallRuns": 8,
	"ExactPlanShallowGableRoof": 10,
	"MappedSSEBroadEaves": 48,
	"ProjectingWingOpaqueOpenings": 144,
	"ProjectingWingPaleOpeningFrames": 720,
	"RecessedTwoLevelOpaqueVoids": 48,
	"RecessedBalconySlabs": 48,
	"RecessedSimpleMetalRails": 528,
}
const EXPECTED_MATERIALS := {
	"ProtectedExactWallRuns": {"path": "res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres", "name": "site_12_protected_neutral_nonclaim", "color": Color(0.54, 0.55, 0.53, 1.0), "metallic": 0.0, "roughness": 0.91},
	"MappedSSEExactStuccoWallRuns": {"path": "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres", "name": "site_12_warm_ivory_stucco_meter_repeat", "color": Color(0.96, 0.94, 0.87, 1.0), "metallic": 0.0, "roughness": 0.88, "texture": "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png", "uv_scale": Vector3(0.333333, 0.333333, 1.0)},
	"ExactPlanShallowGableRoof": {"path": "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres", "name": "site_12_dark_brown_roof_albedo_surrogate", "color": Color(0.40, 0.28, 0.20, 1.0), "metallic": 0.0, "roughness": 0.9, "texture": "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg", "uv_scale": Vector3(0.2, 0.2, 1.0)},
	"MappedSSEBroadEaves": {"path": "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres", "name": "site_12_dark_brown_roof_albedo_surrogate", "color": Color(0.40, 0.28, 0.20, 1.0), "metallic": 0.0, "roughness": 0.9, "texture": "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg", "uv_scale": Vector3(0.2, 0.2, 1.0)},
	"ProjectingWingOpaqueOpenings": {"path": "res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres", "name": "site_12_opaque_blue_gray_opening", "color": Color(0.105, 0.145, 0.16, 1.0), "metallic": 0.0, "roughness": 0.47},
	"ProjectingWingPaleOpeningFrames": {"path": "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres", "name": "site_12_warm_ivory_stucco_meter_repeat", "color": Color(0.96, 0.94, 0.87, 1.0), "metallic": 0.0, "roughness": 0.88, "texture": "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png", "uv_scale": Vector3(0.333333, 0.333333, 1.0)},
	"RecessedTwoLevelOpaqueVoids": {"path": "res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres", "name": "site_12_opaque_recess_shadow", "color": Color(0.105, 0.092, 0.078, 1.0), "metallic": 0.0, "roughness": 0.83},
	"RecessedBalconySlabs": {"path": "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres", "name": "site_12_warm_ivory_stucco_meter_repeat", "color": Color(0.96, 0.94, 0.87, 1.0), "metallic": 0.0, "roughness": 0.88, "texture": "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png", "uv_scale": Vector3(0.333333, 0.333333, 1.0)},
	"RecessedSimpleMetalRails": {"path": "res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres", "name": "site_12_dark_simple_metal", "color": Color(0.075, 0.068, 0.06, 1.0), "metallic": 0.38, "roughness": 0.57},
}
const SOURCE_DEPENDENCY_HASHES := {
	"res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd": "6c0bf201bbb38a424453f753471cb7cb8060d0323e2386a9fda3bad84acd5933",
	"res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json": "ebb6be74a630ad405030938dc7d27bc6fed46b2d6892a847ee653d374df57f75",
	"res://game/scripts/world/facades/site_12_housing_kit.gd": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
	"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres": "81fd15832670516b2cc752e89310acda201f30705b01297639703f76f2111a64",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres": "d97d7b4a442ffe8ad9a0b003e5c1d6466f9ef9effc7cdb2be8ef966195e66782",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres": "389c01066767b085ef8ed8ae4c5e1b06062d9ffb135e3e6a7bfa968b963717d7",
	"res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres": "4159f82cc5c4c17c0d8173eddbc171120326fbd99578aa68012275b1274ce02d",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres": "eddc4900c351dc3a75d163bd380a8b3a39bf6a1c1c3647299e3af19634a60ead",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres": "75c13aa30a4e3c9f49980d78abe41f40c6c7ab270be6152c201eb8a72ebe8720",
	"res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png": "af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg": "fa09ed33d59c3bb90ef70d36352207e2e1ca5564cfc61295c0124d1a7d785808",
}


static func claims_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) in [WALL_KEY, ROOF_KEY]


static func prepare_chunk_records(chunk: Dictionary) -> Dictionary:
	var records_value: Variant = chunk.get("records", null)
	if not (records_value is Array):
		return _failure("d2_1441_live_chunk_records", "The supplied chunk has no record array.", {})
	var records := records_value as Array
	var target_records: Array[Dictionary] = []
	for record_value: Variant in records:
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
		return _failure("d2_1441_live_chunk_pair_count", "1441 Chinook must remain exactly one wall+roof pair in x_-1__z_-1.", target_records[0] if not target_records.is_empty() else {})
	var wall := _record_for_key(target_records, WALL_KEY)
	var roof := _record_for_key(target_records, ROOF_KEY)
	if wall.is_empty() or roof.is_empty() or not _record_pair_matches(wall, roof):
		return _failure("d2_1441_live_chunk_pair", "The supplied 1441 Chinook pair is missing, duplicated, or drifted.", target_records[0])
	return {"ok": true, "contains_target": true, "wall": wall, "roof": roof}


static func build_chunk_plan(prepared_pair: Dictionary) -> Dictionary:
	if not bool(prepared_pair.get("ok", false)):
		return prepared_pair
	if not bool(prepared_pair.get("contains_target", false)):
		return {"ok": true, "contains_target": false, "records": {}, "pending_keys": {}}
	var wall := prepared_pair.get("wall", {}) as Dictionary
	var roof := prepared_pair.get("roof", {}) as Dictionary
	if not _record_pair_matches(wall, roof):
		return _failure("d2_1441_live_prepared_pair", "The prepared 1441 Chinook pair drifted after chunk preflight.", wall)
	var config_result := _validated_config()
	if not bool(config_result.get("ok", false)):
		return _failure("d2_1441_live_config", str(config_result.get("message", "Live config drifted.")), wall)
	if not runtime_dependency_closure_exists():
		return _failure("d2_1441_live_dependency", "The reviewed executable dependency closure is incomplete.", wall)
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
		return _failure("d2_1441_live_target", "The 1441 Chinook adapter received an unrelated row.", record)
	if not bool(chunk_plan.get("ok", false)) or not bool(chunk_plan.get("contains_target", false)):
		return _failure("d2_1441_live_unprepared_pair", "The validated supplied-chunk plan is required.", record)
	var key := str(record.get("object_key", ""))
	var pending := chunk_plan.get("pending_keys", {}) as Dictionary
	var results := chunk_plan.get("records", {}) as Dictionary
	if not pending.has(key) or not results.has(key):
		return _failure("d2_1441_live_duplicate_consume", "A 1441 Chinook row was missing or consumed twice.", record)
	var expected_runtime := EXPECTED_RUNTIME_WALL_DICTIONARY_SHA256 if key == WALL_KEY else EXPECTED_RUNTIME_ROOF_DICTIONARY_SHA256
	var expected_canonical := CANONICAL_WALL_RECORD_SHA256 if key == WALL_KEY else CANONICAL_ROOF_RECORD_SHA256
	if record_signature(record) != expected_runtime or canonical_record_signature(record) != expected_canonical:
		return _failure("d2_1441_live_supplied_record", "The consumed row differs from the sealed pair plan.", record)
	var result := results[key] as Dictionary
	pending.erase(key)
	results.erase(key)
	return result


static func plan_was_fully_consumed(chunk_plan: Dictionary) -> bool:
	return not bool(chunk_plan.get("contains_target", false)) \
		or (chunk_plan.get("pending_keys", {}) as Dictionary).is_empty()


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
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and is_equal_approx(float(record.get("source_height_m", -1.0)), 6.0) \
		and is_equal_approx(float(record.get("flat_base_elevation_m", -1.0)), 3.332) \
		and is_equal_approx(float(record.get("top_elevation_m", -1.0)), 9.332) \
		and (record.get("vertices", []) as Array).size() == (192 if wall else 36) \
		and (record.get("normals", []) as Array).size() == (192 if wall else 36) \
		and (record.get("uvs", []) as Array).size() == (128 if wall else 24) \
		and (record.get("indices", []) as Array).size() == (96 if wall else 30) \
		and (not wall or (int(record.get("exterior_foundation_segments", -1)) == 16 and int(record.get("shared_wall_segments", -1)) == 0))


static func _build_paired_replacement(wall: Dictionary, roof: Dictionary) -> Dictionary:
	var prototype_result := PROTOTYPE.build_for_records(wall, roof)
	if not bool(prototype_result.get("ok", false)):
		return _failure("d2_1441_live_factory", str(prototype_result.get("message", "The reviewed geometry factory failed.")), wall)
	var wall_root := prototype_result.get("node", null) as Node3D
	if wall_root == null:
		return _failure("d2_1441_live_factory_node", "The reviewed factory returned no root.", wall)
	if not _factory_contract_matches(wall_root, prototype_result):
		wall_root.free()
		return _failure("d2_1441_live_factory_contract", "The reviewed signature or source topology drifted.", wall)
	if not material_semantics_match(wall_root):
		wall_root.free()
		return _failure("d2_1441_live_material_semantics", "The reviewed material paths or semantics drifted.", wall)
	var roof_mesh := wall_root.get_node_or_null(ROOF_MESH_NAME) as MeshInstance3D
	if roof_mesh == null:
		wall_root.free()
		return _failure("d2_1441_live_roof_mesh", "The exact shallow-gable mesh is absent.", wall)
	var split := _split_collision(wall_root)
	if not bool(split.get("ok", false)):
		wall_root.free()
		return _failure("d2_1441_live_collision_partition", str(split.get("message", "Structural partition failed.")), wall)
	var roof_root := Node3D.new()
	wall_root.remove_child(roof_mesh)
	roof_root.add_child(roof_mesh)
	if _face_signature(split.wall_faces as PackedVector3Array) != _mesh_face_signature(wall_root, SOURCE_WALL_MESH_NAMES) \
	or _oriented_face_signature(split.roof_faces as PackedVector3Array) != _mesh_oriented_face_signature(roof_root, [ROOF_MESH_NAME]):
		wall_root.free()
		roof_root.free()
		return _failure("d2_1441_live_collision_congruence", "Wall face sets or ordered gable collision faces differ from the reviewed structural visuals.", wall)
	wall_root.add_child(split.wall_body as StaticBody3D)
	roof_root.add_child(split.roof_body as StaticBody3D)
	_apply_live_metadata(wall_root, roof_root)
	var measured := _measure([wall_root, roof_root])
	if not _measured_contract_matches(measured):
		wall_root.free()
		roof_root.free()
		return _failure("d2_1441_live_topology", "The paired live topology or ownership drifted: %s" % measured, wall)
	if not material_semantics_match(wall_root, roof_root):
		wall_root.free()
		roof_root.free()
		return _failure("d2_1441_live_postsplit_material", "Material semantics drifted during the live split.", wall)
	var ownership_signature := live_ownership_signature()
	if ownership_signature != EXPECTED_LIVE_OWNERSHIP_SIGNATURE:
		wall_root.free()
		roof_root.free()
		return _failure("d2_1441_live_ownership_signature", "Live ownership signature drifted (%s)." % ownership_signature, wall)
	var metadata := {
		"schema_version": "ti.d2-1441-chinook-live-replacement/1",
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
		"package_audit_receipt_sha256": PACKAGE_AUDIT_RECEIPT_SHA256,
		"package_promotion_receipt_sha256": PACKAGE_PROMOTION_RECEIPT_SHA256,
		"replacement_mode": "atomic_pair_visual_replacement_with_split_exact_wall_and_gable_collision",
		"fallback_allowed": false,
		"partial_pair_allowed": false,
		"stack_allowed": false,
		"mesh_instances": EXPECTED_MESH_INSTANCES,
		"surfaces": EXPECTED_SURFACES,
		"visual_triangles": EXPECTED_VISUAL_TRIANGLES,
		"decorative_noncolliding_triangles": EXPECTED_DECORATIVE_TRIANGLES,
		"structural_owner_count": 2,
		"shape_count": 2,
		"wall_collision_triangles": EXPECTED_WALL_COLLISION_TRIANGLES,
		"roof_collision_triangles": EXPECTED_ROOF_COLLISION_TRIANGLES,
		"spray_owner_count": 1,
		"roof_spray_receiver_count": 0,
		"roof_spray_ray_blocking": true,
		"roof_landing_world_solid": true,
		"navigation_owner_count": 0,
		"accepted_authority_schema": "ti.facade-runtime-registry/8",
		"accepted_recognition_metric": "8/213",
		"candidate_recognition_credit": 0,
		"recognition_accepted": false,
		"believability_accepted": false,
		"as_built_fidelity_claimed": false,
		"independent_live_review_status": "pending",
		"live_technical_evidence_status": "pending",
		"measured": measured.duplicate(true),
	}
	wall_root.set_meta("d2_1441_chinook_live_replacement", metadata.duplicate(true))
	roof_root.set_meta("d2_1441_chinook_live_replacement", metadata.duplicate(true))
	return {
		"ok": true,
		"wall_result": {"ok": true, "node": wall_root, "metadata": metadata, "mesh_instances": 8, "surfaces": 8, "triangles": EXPECTED_WALL_VISUAL_TRIANGLES, "static_bodies": 1, "shapes": 1},
		"roof_result": {"ok": true, "node": roof_root, "metadata": metadata, "mesh_instances": 1, "surfaces": 1, "triangles": EXPECTED_ROOF_VISUAL_TRIANGLES, "static_bodies": 1, "shapes": 1},
	}


static func _factory_contract_matches(root: Node3D, result: Dictionary) -> bool:
	var metadata := result.get("metadata", {}) as Dictionary
	var measured := _measure([root])
	if str(root.get_meta("deterministic_signature", "")) != EXPECTED_GEOMETRY_SIGNATURE \
	or str(metadata.get("deterministic_signature", "")) != EXPECTED_GEOMETRY_SIGNATURE \
	or not bool(root.get_meta("prototype_only", false)) \
	or bool(root.get_meta("runtime_attachment", true)) \
	or int(measured.get("mesh_instances", -1)) != EXPECTED_MESH_INSTANCES \
	or int(measured.get("surfaces", -1)) != EXPECTED_SURFACES \
	or int(measured.get("visual_triangles", -1)) != EXPECTED_VISUAL_TRIANGLES \
	or int(measured.get("static_bodies", -1)) != 1 \
	or int(measured.get("shapes", -1)) != 1 \
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
	return seen.size() == EXPECTED_BATCH_TRIANGLES.size() \
		and roof_mesh != null and roof_render_front_face_matches(roof_mesh)


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
		var a := vertices[indices[offset]]
		var b := vertices[indices[offset + 1]]
		var c := vertices[indices[offset + 2]]
		var raster_winding := (b - a).cross(c - a)
		if raster_winding.length_squared() <= 0.000001 or raster_winding.normalized().y >= -0.4:
			return false
		for corner in 3:
			if normals[indices[offset + corner]].y <= 0.4:
				return false
	return true


static func _split_collision(root: Node3D) -> Dictionary:
	var original := root.get_node_or_null("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	if original == null or original.get_child_count() != 1:
		return {"ok": false, "message": "Reviewed factory no longer has one named combined collision owner."}
	var shape_node := original.get_node_or_null("ExactFootprintStructuralShape") as CollisionShape3D
	if shape_node == null or not (shape_node.shape is ConcavePolygonShape3D):
		return {"ok": false, "message": "Reviewed combined concave shape is missing."}
	var combined := (shape_node.shape as ConcavePolygonShape3D).get_faces()
	if combined.size() != EXPECTED_COLLISION_TRIANGLES * 3:
		return {"ok": false, "message": "Reviewed combined collision face count drifted."}
	var wall_faces := PackedVector3Array()
	var roof_faces := PackedVector3Array()
	for triangle_index in EXPECTED_COLLISION_TRIANGLES:
		var offset := triangle_index * 3
		if triangle_index <= WALL_COLLISION_TRIANGLE_RANGE[1]:
			for corner in 3:
				wall_faces.append(combined[offset + corner])
		else:
			# The factory emits Godot's clockwise front/top order directly. Keep
			# that winding so the visible roof and landing collider are ordered-
			# congruent instead of silently reversing one side.
			for corner in 3:
				roof_faces.append(combined[offset + corner])
	if wall_faces.size() != EXPECTED_WALL_COLLISION_TRIANGLES * 3 or roof_faces.size() != EXPECTED_ROOF_COLLISION_TRIANGLES * 3:
		return {"ok": false, "message": "Exact 32/10 collision partition failed."}
	root.remove_child(original)
	original.free()
	return {
		"ok": true,
		"wall_faces": wall_faces,
		"roof_faces": roof_faces,
		"wall_body": _collision_body("Collision", wall_faces, WALL_KEY, "building_wall", true),
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
	wall_root.name = "D21441ChinookLiveWallReplacement"
	roof_root.name = "D21441ChinookLiveRoofReplacement"
	for root: Node3D in [wall_root, roof_root]:
		_clear_metadata(root)
		root.set_meta("prototype_only", false)
		root.set_meta("runtime_attachment", true)
		root.set_meta("registry_status", "unregistered_live_candidate_authority_remains_v8")
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
				node.set_meta("collision_ownership", "exact_roof_shape" if node.name == ROOF_MESH_NAME else ("exact_wall_shape" if node.name in SOURCE_WALL_MESH_NAMES else "render_only_noncolliding_relief"))


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
	var transition := config.get("topology_transition", {}) as Dictionary
	var before := transition.get("accepted_b225_v8_baseline", {}) as Dictionary
	var after := transition.get("live_uncredited_candidate", {}) as Dictionary
	var delta := transition.get("delta", {}) as Dictionary
	var truth := config.get("truth_boundary", {}) as Dictionary
	var package := config.get("package_boundary", {}) as Dictionary
	if str(config.get("schema_version", "")) != "ti.d2-1441-chinook-live-replacement/1" \
	or str(target.get("source_key", "")) != SOURCE_KEY \
	or str(target.get("wall_object_key", "")) != WALL_KEY \
	or str(target.get("roof_object_key", "")) != ROOF_KEY \
	or str(target.get("chunk_id", "")) != TARGET_CHUNK_ID \
	or str(target.get("chunk_sha256", "")) != TARGET_CHUNK_SHA256 \
	or str(target.get("source_geometry_sha256", "")) != SOURCE_GEOMETRY_SHA256 \
	or str(target.get("canonical_wall_record_sha256", "")) != CANONICAL_WALL_RECORD_SHA256 \
	or str(target.get("canonical_roof_record_sha256", "")) != CANONICAL_ROOF_RECORD_SHA256 \
	or str(art.get("factory_geometry_signature", "")) != EXPECTED_GEOMETRY_SIGNATURE \
	or _int_array(art.get("mapped_public_sse_runs", []) as Array) != [10, 12, 13, 15] \
	or _int_array(art.get("protected_runs", []) as Array) != [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14] \
	or int(combined.get("mesh_instances", -1)) != 9 or int(combined.get("surfaces", -1)) != 9 \
	or int(combined.get("visual_triangles", -1)) != 1578 or int(combined.get("static_bodies", -1)) != 2 \
	or int(combined.get("shapes", -1)) != 2 or int(combined.get("collision_triangles", -1)) != 42 \
	or not _world_topology_matches(before, 952, 967, 67716) \
	or not _world_topology_matches(after, 959, 974, 69252) \
	or int(delta.get("mesh_instances", -1)) != 7 or int(delta.get("surfaces", -1)) != 7 \
	or int(delta.get("triangles", -1)) != 1536 or int(delta.get("static_bodies", -1)) != 0 or int(delta.get("shapes", -1)) != 0 \
	or not bool(truth.get("runtime_attachment", false)) or not bool(truth.get("candidate_is_uncredited", false)) \
	or str(truth.get("accepted_authority_schema", "")) != "ti.facade-runtime-registry/8" \
	or str(truth.get("accepted_recognition_metric", "")) != "8/213" \
	or bool(truth.get("catalog_or_registry_promoted", true)) or bool(truth.get("recognition_accepted", true)) \
	or bool(truth.get("believability_accepted", true)) or bool(truth.get("as_built_fidelity_claimed", true)) \
	or bool(package.get("standalone_scene_instantiated", true)) \
	or bool(package.get("generic_registry_loader_used", true)) \
	or bool(package.get("flag_or_environment_toggle", true)) \
	or bool(package.get("missing_pair_member_loaded_from_disk", true)):
		return {"ok": false, "message": "Live config semantics drifted."}
	return {"ok": true, "config": config}


static func _world_topology_matches(value: Dictionary, meshes: int, surfaces: int, triangles: int) -> bool:
	return int(value.get("playable_rows", -1)) == 735 \
		and int(value.get("mesh_instances", -1)) == meshes \
		and int(value.get("surfaces", -1)) == surfaces \
		and int(value.get("triangles", -1)) == triangles \
		and int(value.get("static_bodies", -1)) == 466 \
		and int(value.get("shapes", -1)) == 466


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func live_ownership_signature() -> String:
	return JSON.stringify({
		"schema_version": "ti.d2-1441-chinook-live-ownership/1",
		"geometry_signature": EXPECTED_GEOMETRY_SIGNATURE,
		"wall_record_sha256": CANONICAL_WALL_RECORD_SHA256,
		"roof_record_sha256": CANONICAL_ROOF_RECORD_SHA256,
		"wall_triangle_range": WALL_COLLISION_TRIANGLE_RANGE,
		"roof_triangle_range": ROOF_COLLISION_TRIANGLE_RANGE,
		"wall_collision_triangles": EXPECTED_WALL_COLLISION_TRIANGLES,
		"roof_collision_triangles": EXPECTED_ROOF_COLLISION_TRIANGLES,
		"wall_mesh_instances": 8,
		"roof_mesh_instances": 1,
		"wall_spray_owner_count": 1,
		"roof_spray_owner_count": 0,
		"decorative_collision_triangles": 0,
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
	var result := {"mesh_instances": 0, "surfaces": 0, "visual_triangles": 0, "static_bodies": 0, "shapes": 0, "collision_triangles": 0, "wall_collision_triangles": 0, "roof_collision_triangles": 0, "spray_owners": 0, "roof_spray_owners": 0, "navigation_nodes": 0, "decals": 0}
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
		and int(measured.get("static_bodies", -1)) == 2 and int(measured.get("shapes", -1)) == 2 \
		and int(measured.get("collision_triangles", -1)) == EXPECTED_COLLISION_TRIANGLES \
		and int(measured.get("wall_collision_triangles", -1)) == EXPECTED_WALL_COLLISION_TRIANGLES \
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
