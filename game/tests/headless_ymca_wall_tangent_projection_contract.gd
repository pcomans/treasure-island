extends SceneTree

const CHUNK_PATH := "res://generated/world/chunks/x_0__z_-2.json"
const RECEIVER_KEY := "building:w34313547:wall"
const MATERIAL_PATH := "res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres"
const SHADER_PATH := "res://game/resources/materials/world/ti_ymca/ti_ymca_wall_tangent_aperiodic_field.gdshader"
const ACCEPTED_RUNS := [3, 4, 5, 6, 7, 8, 9, 10, 11]
const ACCEPTED_CHAINS := [[3, 4, 5, 6, 7], [8, 9, 10, 11]]
const EXPECTED_MATERIAL_SHA256 := "b5e44afcf4feb6df6ffba46f4e3b60a25fa6043c07c12c33e31c483cb2bf2399"
const EXPECTED_SHADER_SHA256 := "8943853363f5a2571ebf15a6e9711c6310b706d2e4415f3e1f314d8643d55f6c"

const PROTECTED_RESOURCE_SHA256 := {
	"res://game/resources/materials/world/batch_02_04_aperiodic_field.gdshader": "324ba33a7c78f4b05038168a479ebb8e875c56704236492a050cee8da8e5f798",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
	"res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres": "fb50d3989b7aa41421753ad4db5d195366d9a2c25c15087e5e3a2b7863c69602",
	"res://game/resources/materials/world/fire_station_48/fire_station_48_primary.tres": "515135c3d0da6bb8eb8681e69d7e3f7818d896d948fe5dcc7c2bd8c6d076b188",
	"res://game/resources/materials/world/fire_training_b600/fire_training_primary.tres": "fd1437ed9c0e00508d10d9a3c5d859d9a07c73fb28edc3fad62c473e9d865483",
	"res://game/resources/materials/world/building_3/building_3_teal_door.tres": "dfb3114e6c419e3f1519364b58aa19d7aa3f65e08cb5fc64945ffe24874a0846",
	"res://game/resources/materials/world/building_3/building_3_white_primary.tres": "5b76d33ed0f8ae940bc9761989c8fda43c1106059bc93029a994a1ebf8edc49b",
	"res://game/resources/materials/world/hawkins/hawkins_base_ribbed.tres": "3fdd57da8d860edf5b8a59d9eb9ac7330cddacf5f96d335d2c75fd000e298709",
	"res://game/resources/materials/world/hawkins/hawkins_base_smooth.tres": "94b73c60e1d43bcc2bfac0ecf0803c021ec34c88b6579799a58b8bf7f3e617dc",
	"res://game/resources/materials/world/hawkins/hawkins_frame_charcoal.tres": "2e99cc73385650e19bd957f0f6fa92826e2cef2e53c88653910f64a81efc244a",
	"res://game/resources/materials/world/hawkins/hawkins_garage_dark.tres": "db479ea790823d13f09df35d9fa558afa53fde5ca09585aa68160a98b3569501",
	"res://game/resources/materials/world/hawkins/hawkins_glass_proxy.tres": "10bcc87b347aa51557e0597476c97d4173f74c67f2bdb9883418026e60e49c63",
	"res://game/resources/materials/world/hawkins/hawkins_pearl_fluted.gdshader": "82de521449dc386ed9ad5630abc8e1a874585a56731fa95fbfa3b984c0a6b330",
	"res://game/resources/materials/world/hawkins/hawkins_pearl_fluted.tres": "171cb1d9c8ba31b19622ad7ccf2d005eed94d7793f59e1d90882291ec9ce5415",
	"res://game/resources/materials/world/hawkins/hawkins_pearl_plain.tres": "ca16d8e5ae23097f449040a61c6682fe7552d47eaf310acdffa78a3994b77546",
	"res://game/resources/materials/world/hawkins/hawkins_sign_letters.tres": "6954194a853d4440ccb2e544870c18ab21c7ffdeaa7420ee83f1aa5b32dceb6c",
	"res://game/resources/materials/world/hawkins/hawkins_spandrel_pale.tres": "55319e2dfb543173a212b4f79653f5622e4db6f40e0941821e6cdfd7a5a55a15",
	"res://game/resources/materials/world/isle_house/isle_house_dark_charcoal.tres": "6910208cb7130a86fbe8a063a6e8fa8e96cfa657d493e02449379b981ce961fe",
	"res://game/resources/materials/world/isle_house/isle_house_glass_proxy.tres": "19adff893d82c8c76542140b0ed6f1b3e08fa5e5b75101c0bb55c08b69f2c7ce",
	"res://game/resources/materials/world/isle_house/isle_house_identifier.tres": "40078e3cf6209c128372cdcbd85ead7f852dd88ab33fddfdecddc34130586b5f",
	"res://game/resources/materials/world/isle_house/isle_house_podium_light.tres": "52c57cff2f596f23222ec4f21cdc2a3791d62b667c34d6abb966ca06a0831d7f",
	"res://game/resources/materials/world/isle_house/isle_house_support_grey.tres": "55cb958134db30d533ad311a6a73f10aa523502c8099caf38edb17e30fb4fc04",
	"res://game/resources/materials/world/isle_house/isle_house_tower_accent.tres": "a1f60aa46ff59101166ae0af0ee15f79a7115a2279b906d813f30355fe3f7e81",
	"res://game/resources/materials/world/isle_house/isle_house_tower_light.tres": "713d582eb572d7a828af002fe4a855e32b5bebdd1fea862b1a564914c7ae6850",
	"res://game/scripts/world/world_chunk_builder.gd": "e3d0ca4b6c9d39a444aa5b55592d63a32e7794bae3e12f1f3fac125243839d42",
	# Current helper includes the independently accepted-with-limitation Batch 06
	# field partitions; YMCA's accepted runs/material/projection remain unchanged.
	"res://game/scripts/world/facades/accepted_material_run_trials.gd": "d2d4909d5f8cc8a26e7ca77757ceaeebe337131dc33eaece3c7756e2b3d76c9c",
	"res://game/resources/facades/batch_02_material_registry.json": "e7d1167869640867e2857de1f08df81e878e68230b59feff3fb947b16ff56cb7",
	"res://discovery/facades/BATCH_02_RUN_MAPPING.json": "d076ee125168cd3dfe499bc56e94c324019d7ba70bb731b9c23c045ca6759b5f",
	"res://generated/world/chunks/x_0__z_-2.json": "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(MATERIAL_PATH) == EXPECTED_MATERIAL_SHA256, "YMCA material bytes drifted.") \
	or not _require(FileAccess.get_sha256(SHADER_PATH) == EXPECTED_SHADER_SHA256, "YMCA wall-tangent shader bytes drifted.") \
	or not _require(_protected_resources_match(), "A protected shared/non-YMCA resource drifted."):
		_finish()
		return
	var material := load(MATERIAL_PATH) as ShaderMaterial
	if not _require(_material_contract_matches(material), "YMCA approved material identity or target-specific shader binding drifted."):
		_finish()
		return
	var shader_source := FileAccess.get_file_as_string(SHADER_PATH)
	if not _require(_shader_projection_contract_matches(shader_source), "YMCA shader no longer uses the exact wall-tangent/vertical metre projection."):
		_finish()
		return
	var record := _load_record()
	if not _require(not record.is_empty(), "YMCA generated receiver record is missing.") \
	or not _require(_physical_projection_matches(record), "YMCA run projection is not one wall-local tangent/vertical unit per generated metre.") \
	or not _require(_run_scope_and_boundaries_match(record), "YMCA accepted chains, corner, or run 11 to 12 boundary drifted."):
		_finish()
		return
	print("PASS: YMCA alone uses a generated-normal wall-tangent/vertical metre projection on exact runs 3..11; SSE 3..7 and ENE 8..11 each preserve collinear phase and physical scale, the orthogonal 7-to-8 corner and accepted-to-placeholder 11-to-12 boundary remain exact, and all protected shared/non-YMCA resources are unchanged")
	_finish()


func _protected_resources_match() -> bool:
	for path: String in PROTECTED_RESOURCE_SHA256:
		if FileAccess.get_sha256(path) != str(PROTECTED_RESOURCE_SHA256[path]):
			push_error("Protected resource drift at %s." % path)
			return false
	return true


func _material_contract_matches(material: ShaderMaterial) -> bool:
	return material != null and material.resource_path == MATERIAL_PATH \
		and material.shader != null and material.shader.resource_path == SHADER_PATH \
		and material.get_shader_parameter("base_color") == Color(0.25, 0.22, 0.19, 1.0) \
		and material.get_shader_parameter("secondary_color") == Color(0.16, 0.15, 0.14, 1.0) \
		and is_equal_approx(float(material.get_shader_parameter("roughness_value")), 0.91) \
		and int(material.get_shader_parameter("field_kind")) == 5 \
		and is_equal_approx(float(material.get_shader_parameter("primary_scale_m")), 0.42) \
		and is_equal_approx(float(material.get_shader_parameter("secondary_scale_m")), 0.095) \
		and is_equal_approx(float(material.get_shader_parameter("relief_strength")), 0.08) \
		and is_equal_approx(float(material.get_shader_parameter("color_variation")), 0.065) \
		and is_equal_approx(float(material.get_shader_parameter("filter_start_cycles_per_pixel")), 0.12) \
		and is_equal_approx(float(material.get_shader_parameter("filter_end_cycles_per_pixel")), 0.34)


func _shader_projection_contract_matches(source: String) -> bool:
	return "vec2 horizontal_normal = normalize(NORMAL.xz);" in source \
		and "vec2 wall_tangent = vec2(horizontal_normal.y, -horizontal_normal.x);" in source \
		and "field_position_m = vec2(dot(VERTEX.xz, wall_tangent), VERTEX.y);" in source \
		and not "field_position_m = VERTEX.xy;" in source \
		and not "UV" in source


func _physical_projection_matches(record: Dictionary) -> bool:
	var vertices := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	if vertices.size() != 30 * 12 or normals.size() != vertices.size():
		return false
	for run_index: int in ACCEPTED_RUNS:
		var offset := run_index * 12
		var start := Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2]))
		var end := Vector3(float(vertices[offset + 3]), float(vertices[offset + 4]), float(vertices[offset + 5]))
		var top_end := Vector3(float(vertices[offset + 6]), float(vertices[offset + 7]), float(vertices[offset + 8]))
		var top_start := Vector3(float(vertices[offset + 9]), float(vertices[offset + 10]), float(vertices[offset + 11]))
		var normal_xz := Vector2(float(normals[offset]), float(normals[offset + 2])).normalized()
		var tangent := Vector2(normal_xz.y, -normal_xz.x)
		var horizontal_delta := Vector2(end.x - start.x, end.z - start.z)
		var length_m := horizontal_delta.length()
		if absf(horizontal_delta.dot(tangent) - length_m) > 0.002 \
		or absf(horizontal_delta.dot(normal_xz)) > 0.006 \
		or absf((top_start.y - start.y) - start.distance_to(top_start)) > 0.002 \
		or absf((top_end.y - end.y) - end.distance_to(top_end)) > 0.002:
			return false
	return true


func _run_scope_and_boundaries_match(record: Dictionary) -> bool:
	if AcceptedMaterialRunTrials.metadata_for(RECEIVER_KEY).get("accepted_runs", []) != ACCEPTED_RUNS:
		return false
	for chain_value: Variant in ACCEPTED_CHAINS:
		var chain := chain_value as Array
		for chain_index in chain.size() - 1:
			var run_index := int(chain[chain_index])
			var next_run_index := int(chain[chain_index + 1])
			var end := _run_end(record, run_index)
			var next_start := _run_start(record, next_run_index)
			var tangent := _run_tangent(record, run_index)
			var next_tangent := _run_tangent(record, next_run_index)
			if end.distance_to(next_start) > 0.002 \
			or tangent.distance_to(next_tangent) > 0.002 \
			or absf(Vector2(end.x, end.z).dot(tangent) - Vector2(next_start.x, next_start.z).dot(next_tangent)) > 0.002:
				return false
	var corner := _run_end(record, 7)
	var ene_start := _run_start(record, 8)
	var accepted_end := _run_end(record, 11)
	var placeholder_start := _run_start(record, 12)
	return corner.distance_to(ene_start) <= 0.002 \
		and absf(_run_tangent(record, 7).dot(_run_tangent(record, 8))) <= 0.002 \
		and accepted_end.distance_to(placeholder_start) <= 0.002 \
		and not 12 in ACCEPTED_RUNS


func _run_start(record: Dictionary, run_index: int) -> Vector3:
	var values := record.get("vertices", []) as Array
	var offset := run_index * 12
	return Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))


func _run_end(record: Dictionary, run_index: int) -> Vector3:
	var values := record.get("vertices", []) as Array
	var offset := run_index * 12
	return Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))


func _run_tangent(record: Dictionary, run_index: int) -> Vector2:
	var values := record.get("normals", []) as Array
	var offset := run_index * 12
	var normal_xz := Vector2(float(values[offset]), float(values[offset + 2])).normalized()
	return Vector2(normal_xz.y, -normal_xz.x)


func _load_record() -> Dictionary:
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	for value: Variant in chunk.get("records", []):
		var record := value as Dictionary
		if str(record.get("object_key", "")) == RECEIVER_KEY:
			return record
	return {}


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
