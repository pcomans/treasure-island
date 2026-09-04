extends SceneTree

const HERO := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const MAIN_CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const CONFIG_PATH := "res://game/resources/facades/building_1_public_front_believability.json"
const ADAPTER_PATH := "res://game/scripts/world/facades/building_1_hero_model.gd"
const MATERIAL_PATHS := [
	"res://game/resources/materials/world/building_1/building_1_projecting_base_stone.tres",
	"res://game/resources/materials/world/building_1/building_1_reveal_shadow.tres",
	"res://game/resources/materials/world/building_1/building_1_canopy_underside.tres",
]
const EXPECTED_CONFIG_SHA256 := "fd434eb472f61d93408732841e5993881b23238af8c0518b59181ac0ea535e32"
const EXPECTED_ADAPTER_SHA256 := "e5b11fc7f971ea33bb38c84d3106f8883de0486774f58a5a8310d49d56aa55a5"
const EXPECTED_MATERIAL_SHA256 := [
	"8bdd85aa10ac78c9225c59aad5ed9d26266ae517ea3f5910b8be3daf41f131ab",
	"2e1f36f163c037fe060a1ecfcdcc5dd062849290a96c508970384585b176e14a",
	"661a7b8cfaef2394e47a42f9bbd04df5fdfbb2cd4be9e6733d5bf3101817cea9",
]
const EXPECTED_WALL_COLLISION_SHA256 := "21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5"
const EXPECTED_ROOF_COLLISION_SHA256 := "bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337"
const EXPECTED_COMPONENT_TOPOLOGY := {
	"building:r16681702:wall": {"meshes": 6, "surfaces": 6, "triangles": 8806, "bodies": 1, "shapes": 1, "collision_face_vertices": 2046},
	"building:r16681702:roof": {"meshes": 3, "surfaces": 3, "triangles": 1131, "bodies": 1, "shapes": 1, "collision_face_vertices": 1737},
}
const EXPECTED_WALL_MESH_TRIANGLES := {
	"HeroIvory": 636,
	"HeroProjectingBase": 322,
	"HeroPublicFrontReveals": 168,
	"HeroGlass": 624,
	"HeroTrim": 6804,
	"HeroBronze": 252,
}
const EXPECTED_ROOF_MESH_TRIANGLES := {
	"HeroSteppedRoof": 303,
	"HeroEntranceCanopy": 552,
	"HeroEntranceCanopyUnderside": 276,
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
	print("BUILDING_1_PUBLIC_FRONT_COLLISION_SHA256=%s/%s" % [wall_collision_sha, roof_collision_sha])
	wall.free()
	wall_second.free()
	roof.free()
	roof_second.free()
	if not _failed:
		print("PASS: Building 1 public-front depth/value pass is deterministic, texture-free, and preserves exact source/collision/spray/traversal contracts pending independent bar-raiser re-review")
	quit(1 if _failed else 0)


func _config_truth_contract(config: Dictionary) -> bool:
	var target := config.get("target", {}) as Dictionary
	var geometry := config.get("geometry_production_inference_m", {}) as Dictionary
	var truth := config.get("truth", {}) as Dictionary
	return str(config.get("schema_version", "")) == "ti.building-1-public-front-believability/1" \
		and str(target.get("building_source_key", "")) == "r16681702" \
		and str(target.get("wall_object_key", "")) == HERO.BUILDING_WALL_KEY \
		and str(target.get("roof_object_key", "")) == HERO.BUILDING_ROOF_KEY \
		and (target.get("public_front_chain_runs", []) as Array).size() == 23 \
		and int(geometry.get("pilaster_count", 0)) == 12 \
		and int(geometry.get("pilaster_flutes_per_pilaster", 0)) == 2 \
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
	]
	for index in MATERIAL_PATHS.size():
		var material := load(MATERIAL_PATHS[index]) as StandardMaterial3D
		var expectation := expected[index] as Dictionary
		_require(material != null, "%s is not a scalar StandardMaterial3D." % MATERIAL_PATHS[index])
		if material == null:
			continue
		_require(material.albedo_texture == null and material.normal_texture == null and material.roughness_texture == null and material.metallic_texture == null, "%s unexpectedly consumes an image texture." % MATERIAL_PATHS[index])
		_require(material.albedo_color.is_equal_approx(expectation.color as Color) and is_equal_approx(material.roughness, float(expectation.roughness)), "%s scalar value/roughness drifted." % MATERIAL_PATHS[index])


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
