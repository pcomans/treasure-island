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
const EXPECTED_CONFIG_SHA256 := "fca8feba243c4b1b1747050852ab2db7102aae668838ad8265524caa20cc6fc1"
const EXPECTED_ADAPTER_SHA256 := "1b3e9086b9a5628a68fe684736010277219b02f931d09e03f1442be15afe35a8"
const EXPECTED_MATERIAL_SHA256 := [
	"8bdd85aa10ac78c9225c59aad5ed9d26266ae517ea3f5910b8be3daf41f131ab",
	"2e1f36f163c037fe060a1ecfcdcc5dd062849290a96c508970384585b176e14a",
	"661a7b8cfaef2394e47a42f9bbd04df5fdfbb2cd4be9e6733d5bf3101817cea9",
]
const EXPECTED_WALL_COLLISION_SHA256 := "21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5"
const EXPECTED_ROOF_COLLISION_SHA256 := "bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337"
const EXPECTED_COMPONENT_TOPOLOGY := {
	"building:r16681702:wall": {"meshes": 6, "surfaces": 6, "triangles": 9166, "bodies": 1, "shapes": 1, "collision_face_vertices": 2046},
	"building:r16681702:roof": {"meshes": 3, "surfaces": 3, "triangles": 1131, "bodies": 1, "shapes": 1, "collision_face_vertices": 1737},
}
const EXPECTED_WALL_MESH_TRIANGLES := {
	"HeroIvory": 636,
	"HeroProjectingBase": 322,
	"HeroPublicFrontReveals": 528,
	"HeroGlass": 624,
	"HeroTrim": 6804,
	"HeroBronze": 252,
}
const EXPECTED_UNCHANGED_WALL_MESH_SHA256 := {
	"HeroBronze": "d7cc78de3148592c03b38f022d9744f7cd0c08495b69a6fe80d12498cf581e15",
	"HeroGlass": "7d7606c94e9aea27af5da01dbd047fc6378d2fb9f5d6cb59cd7b03e282340218",
	"HeroIvory": "9b2dcbf15a763c65047c99b9babae305cb566aaf920672075dc0ace085270f0c",
	"HeroProjectingBase": "0db13654d5261e6a2066d12be00447a9c55ea4a483ee8657cdede076ac52948b",
	"HeroTrim": "8a1f4ba50ab041457f420a95ee371a304b2cd0d4509b9d644b89ed722262a6e3",
}
const EXPECTED_UNCHANGED_ROOF_MESH_SHA256 := {
	"HeroEntranceCanopy": "96301224bc182199306c560db5fd399552562e4d606fe87f3e13ec5d75cfa1c9",
	"HeroEntranceCanopyUnderside": "4655f16f18aa16b2f391535035ad0531562efbbce3dd2044ad80f46c1aed3e10",
	"HeroSteppedRoof": "bedbe6a66504ed798d1cd4532edbfc50391c811b43ada10d90fe4957bdf279f8",
}
const EXPECTED_EXISTING_REVEAL_PREFIX_SHA256 := "ca176003fd3f48d2fb3f08d40232398dfbda33949995cd9a47dec52e4a4de7de"
const EXPECTED_CANDIDATE_REVEAL_SHA256 := "b3fa18f566ac516bdb94e3e70ddf4da155768277ef2d3c700d256719ce53960c"
const EXISTING_REVEAL_BOXES := 14
const WING_REVEAL_BOXES := 30
const TOTAL_REVEAL_BOXES := EXISTING_REVEAL_BOXES + WING_REVEAL_BOXES
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
	var wall_mesh_hashes := _mesh_array_sha256_map(wall)
	var roof_mesh_hashes := _mesh_array_sha256_map(roof)
	var unchanged_wall_hashes := wall_mesh_hashes.duplicate()
	unchanged_wall_hashes.erase("HeroPublicFrontReveals")
	_require(unchanged_wall_hashes == EXPECTED_UNCHANGED_WALL_MESH_SHA256, "A non-reveal Building 1 wall bucket changed: %s" % JSON.stringify(unchanged_wall_hashes))
	_require(roof_mesh_hashes == EXPECTED_UNCHANGED_ROOF_MESH_SHA256, "Building 1 roof/canopy bytes changed: %s" % JSON.stringify(roof_mesh_hashes))
	_require(str(wall_mesh_hashes.get("HeroPublicFrontReveals", "")) == EXPECTED_CANDIDATE_REVEAL_SHA256, "Wing-reveal candidate bytes drifted.")
	_require(_wing_reveal_geometry_contract(wall, wall_record, config), "The exact 30-box wing-window reveal schedule, dimensions, depth, material, or first-14 byte prefix drifted.")
	_require(_candidate_mutation_contract(config), "The B1 wing-reveal schema/schedule/source mutation matrix did not fail closed.")
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
		print("PASS: Building 1 wing-window candidate adds exactly 30 render-only reveal boxes / 360 triangles behind the two 8+7 schedules while preserving all prior reveal bytes, non-reveal geometry, roof, collision, spray, and truth contracts")
	quit(1 if _failed else 0)


func _config_truth_contract(config: Dictionary) -> bool:
	var target := config.get("target", {}) as Dictionary
	var geometry := config.get("geometry_production_inference_m", {}) as Dictionary
	var truth := config.get("truth", {}) as Dictionary
	return str(config.get("schema_version", "")) == "ti.building-1-public-front-believability/2" \
		and str(target.get("building_source_key", "")) == "r16681702" \
		and str(target.get("wall_object_key", "")) == HERO.BUILDING_WALL_KEY \
		and str(target.get("roof_object_key", "")) == HERO.BUILDING_ROOF_KEY \
		and (target.get("public_front_chain_runs", []) as Array).size() == 23 \
		and int(geometry.get("pilaster_count", 0)) == 12 \
		and int(geometry.get("pilaster_flutes_per_pilaster", 0)) == 2 \
		and is_equal_approx(float(geometry.get("wing_window_reveal_border", -1.0)), 0.16) \
		and is_equal_approx(float(geometry.get("wing_window_reveal_front_lag", -1.0)), 0.04) \
		and is_equal_approx(float(geometry.get("wing_window_reveal_rear_overlap", -1.0)), 0.01) \
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
	]
	for index in MATERIAL_PATHS.size():
		var material := load(MATERIAL_PATHS[index]) as StandardMaterial3D
		var expectation := expected[index] as Dictionary
		_require(material != null, "%s is not a scalar StandardMaterial3D." % MATERIAL_PATHS[index])
		if material == null:
			continue
		_require(material.albedo_texture == null and material.normal_texture == null and material.roughness_texture == null and material.metallic_texture == null, "%s unexpectedly consumes an image texture." % MATERIAL_PATHS[index])
		_require(material.albedo_color.is_equal_approx(expectation.color as Color) and is_equal_approx(material.roughness, float(expectation.roughness)), "%s scalar value/roughness drifted." % MATERIAL_PATHS[index])


func _wing_reveal_geometry_contract(node: Node3D, record: Dictionary, config: Dictionary) -> bool:
	var reveal_instance := node.get_node_or_null("HeroPublicFrontReveals") as MeshInstance3D
	if reveal_instance == null or not (reveal_instance.mesh is ArrayMesh):
		return false
	var mesh := reveal_instance.mesh as ArrayMesh
	if mesh.get_surface_count() != 1 \
	or mesh.surface_get_material(0) == null \
	or mesh.surface_get_material(0).resource_path != MATERIAL_PATHS[1] \
	or FileAccess.get_sha256(MATERIAL_PATHS[1]) != EXPECTED_MATERIAL_SHA256[1]:
		return false
	var arrays := mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var uvs := arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array
	var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
	print("BUILDING_1_WING_REVEAL_DIAGNOSTIC: material=%s v/n/uv/i=%d/%d/%d/%d prefix=%s" % [mesh.surface_get_material(0).resource_path, vertices.size(), normals.size(), uvs.size(), indices.size(), _mesh_box_prefix_sha256(mesh, EXISTING_REVEAL_BOXES)])
	if vertices.size() != TOTAL_REVEAL_BOXES * 24 \
	or normals.size() != vertices.size() or uvs.size() != vertices.size() \
	or indices.size() != TOTAL_REVEAL_BOXES * 36 \
	or int(indices.size() / 3) != 528 \
	or _mesh_box_prefix_sha256(mesh, EXISTING_REVEAL_BOXES) != EXPECTED_EXISTING_REVEAL_PREFIX_SHA256:
		return false
	var front := config.get("geometry_production_inference_m", {}) as Dictionary
	if not is_equal_approx(float(front.get("wing_window_reveal_border", -1.0)), 0.16) \
	or not is_equal_approx(float(front.get("wing_window_reveal_front_lag", -1.0)), 0.04) \
	or not is_equal_approx(float(front.get("wing_window_reveal_rear_overlap", -1.0)), 0.01):
		return false
	var cases: Array[Dictionary] = [
		{"label": "north_upper", "runs": HERO.NORTH_WING_WINDOW_RUNS, "count": 8, "margin": 2.2, "center_y": 16.9, "width": 2.35, "height": 2.8, "projection": 0.13},
		{"label": "north_lower", "runs": HERO.NORTH_WING_WINDOW_RUNS, "count": 7, "margin": 2.5, "center_y": 10.35, "width": 2.05, "height": 2.45, "projection": 0.23},
		{"label": "south_upper", "runs": HERO.SOUTH_WING_WINDOW_RUNS, "count": 8, "margin": 2.2, "center_y": 16.9, "width": 2.35, "height": 2.8, "projection": 0.13},
		{"label": "south_lower", "runs": HERO.SOUTH_WING_WINDOW_RUNS, "count": 7, "margin": 2.5, "center_y": 10.35, "width": 2.05, "height": 2.45, "projection": 0.23},
	]
	var box_index := EXISTING_REVEAL_BOXES
	var measured_centers := {}
	for case: Dictionary in cases:
		var runs := _int_array(case.runs as Array)
		var count := int(case.count)
		var margin := float(case.margin)
		var length := _chain_length(record, runs)
		if count < 2 or length <= margin * 2.0:
			return false
		var chain_centers: Array[float] = []
		for index in count:
			var chain_m := lerpf(margin, length - margin, float(index) / float(count - 1))
			var frame := _chain_frame(record, runs, chain_m)
			if frame.is_empty() or not _reveal_box_matches(vertices, box_index, frame, case):
				return false
			chain_centers.append(chain_m)
			box_index += 1
		if chain_centers.size() != count \
		or not is_equal_approx(chain_centers[0], margin) \
		or not is_equal_approx(chain_centers[-1], length - margin):
			return false
		var spacing := (length - margin * 2.0) / float(count - 1)
		for index in range(1, chain_centers.size()):
			if not is_equal_approx(chain_centers[index] - chain_centers[index - 1], spacing):
				return false
		measured_centers[str(case.label)] = chain_centers
	print("BUILDING_1_WING_REVEAL_CHAIN_CENTERS_M=%s" % JSON.stringify(measured_centers))
	return box_index == TOTAL_REVEAL_BOXES


func _reveal_box_matches(vertices: PackedVector3Array, box_index: int, frame: Dictionary, case: Dictionary) -> bool:
	var start := box_index * 24
	if start < 0 or start + 24 > vertices.size():
		return false
	var tangent := frame.tangent as Vector3
	var normal := frame.normal as Vector3
	var anchor := frame.wall_anchor as Vector3
	anchor.y = float(case.center_y)
	var projection := float(case.projection)
	var glass_center := maxf(0.035, projection - 0.10)
	var reveal_front := glass_center + 0.07 * 0.5 - 0.04
	var reveal_rear := -0.01
	var reveal_center := (reveal_front + reveal_rear) * 0.5
	var expected_center := anchor + normal * reveal_center
	var actual_center := Vector3.ZERO
	var actual_front_center := Vector3.ZERO
	var actual_rear_center := Vector3.ZERO
	var min_tangent := INF
	var max_tangent := -INF
	var min_y := INF
	var max_y := -INF
	var min_normal := INF
	var max_normal := -INF
	for offset in range(start, start + 24):
		var point := vertices[offset]
		actual_center += point
		if offset < start + 4:
			actual_front_center += point
		elif offset < start + 8:
			actual_rear_center += point
		var relative := point - anchor
		var tangent_value := relative.dot(tangent)
		var normal_value := relative.dot(normal)
		min_tangent = minf(min_tangent, tangent_value)
		max_tangent = maxf(max_tangent, tangent_value)
		min_y = minf(min_y, point.y)
		max_y = maxf(max_y, point.y)
		min_normal = minf(min_normal, normal_value)
		max_normal = maxf(max_normal, normal_value)
	actual_center /= 24.0
	actual_front_center /= 4.0
	actual_rear_center /= 4.0
	var actual_front := (actual_front_center - anchor).dot(normal)
	var actual_rear := (actual_rear_center - anchor).dot(normal)
	var expected_width := float(case.width) + 0.32
	var expected_height := float(case.height) + 0.32
	var matches := actual_center.distance_to(expected_center) < 0.001 \
		and absf((max_tangent - min_tangent) - expected_width) < 0.001 \
		and absf((max_y - min_y) - expected_height) < 0.001 \
		and absf(actual_front - reveal_front) < 0.001 \
		and absf(actual_rear - reveal_rear) < 0.001 \
		and absf((actual_front - actual_rear) - (reveal_front - reveal_rear)) < 0.001
	if not matches:
		print("BUILDING_1_WING_REVEAL_BOX_DIAGNOSTIC: box=%d center=%s expected=%s width=%.6f/%.6f height=%.6f/%.6f front=%.6f/%.6f rear=%.6f/%.6f extents=%.6f..%.6f" % [box_index, actual_center, expected_center, max_tangent - min_tangent, expected_width, max_y - min_y, expected_height, actual_front, reveal_front, actual_rear, reveal_rear, min_normal, max_normal])
	return matches


func _candidate_mutation_contract(config: Dictionary) -> bool:
	if not HERO._bar_config_valid(config):
		return false
	for key in ["wing_window_reveal_border", "wing_window_reveal_front_lag", "wing_window_reveal_rear_overlap"]:
		var missing := config.duplicate(true)
		(missing.geometry_production_inference_m as Dictionary).erase(key)
		if HERO._bar_config_valid(missing):
			return false
		var substituted := config.duplicate(true)
		var substituted_geometry := substituted.geometry_production_inference_m as Dictionary
		substituted_geometry.erase(key)
		substituted_geometry["substituted_%s" % key] = 0.16
		if HERO._bar_config_valid(substituted):
			return false
	for mutation: Dictionary in [
		{"field": "wing_window_reveal_border", "value": 0.15},
		{"field": "wing_window_reveal_front_lag", "value": 0.03},
		{"field": "wing_window_reveal_rear_overlap", "value": 0.02},
	]:
		var changed := config.duplicate(true)
		(changed.geometry_production_inference_m as Dictionary)[str(mutation.field)] = mutation.value
		if HERO._bar_config_valid(changed):
			return false
	var old_schema := config.duplicate(true)
	old_schema.schema_version = "ti.building-1-public-front-believability/1"
	if HERO._bar_config_valid(old_schema):
		return false
	var hero_config := _json(HERO.CONFIG_PATH)
	if not HERO._config_valid(hero_config):
		return false
	for mutation: Dictionary in [
		{"field": "upper_windows_per_wing", "value": 9},
		{"field": "lower_windows_per_wing", "value": 6},
		{"field": "north_wing_window_runs", "value": [10, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]},
		{"field": "south_wing_window_runs", "value": [44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 57]},
	]:
		var changed_hero := hero_config.duplicate(true)
		(changed_hero.facade_schedule as Dictionary)[str(mutation.field)] = mutation.value
		if HERO._config_valid(changed_hero):
			return false
	var missing_count := hero_config.duplicate(true)
	(missing_count.facade_schedule as Dictionary).erase("upper_windows_per_wing")
	if HERO._config_valid(missing_count):
		return false
	var source := FileAccess.get_file_as_string(ADAPTER_PATH)
	if not _candidate_source_contract(source):
		return false
	var source_mutations: Array[Dictionary] = [
		{"needle": "building_1_reveal_shadow.tres", "replacement": "building_1_light_trim.tres"},
		{"needle": "_append_box(reveal, anchor + normal * reveal_center", "replacement": "_append_box(trim, anchor + normal * reveal_center"},
		{"needle": "_append_box(reveal, anchor + normal * reveal_center", "replacement": "_append_box(collision, anchor + normal * reveal_center"},
		{"needle": "float(front.wing_window_reveal_border)", "replacement": "0.0"},
		{"needle": "glass_front - float(front.wing_window_reveal_front_lag)", "replacement": "glass_front"},
		{"needle": "-float(front.wing_window_reveal_rear_overlap)", "replacement": "float(front.wing_window_reveal_rear_overlap)"},
		{"needle": "_append_wing_window_schedule(glass, reveal, trim, record, wing_runs, int(schedule.upper_windows_per_wing)", "replacement": "_append_wing_window_schedule(glass, trim, reveal, record, wing_runs, int(schedule.upper_windows_per_wing)"},
		{"needle": "_append_window(glass, trim, tall_frame, 14.2, tall_width, 11.25, 4, 5, 0.16)", "replacement": "_append_wing_window(glass, reveal, trim, tall_frame, 14.2, tall_width, 11.25, 4, 5, 0.16, front)"},
	]
	for mutation: Dictionary in source_mutations:
		var needle := str(mutation.needle)
		if source.count(needle) != 1:
			return false
		if _candidate_source_contract(source.replace(needle, str(mutation.replacement))):
			return false
	return true


func _candidate_source_contract(source: String) -> bool:
	var schedule_block := _function_block(source, "static func _append_wing_window_schedule(")
	var wing_block := _function_block(source, "static func _append_wing_window(")
	var generic_block := _function_block(source, "static func _append_window(")
	var end_block := _function_block(source, "static func _append_end_composition(")
	return not schedule_block.is_empty() and not wing_block.is_empty() and not generic_block.is_empty() and not end_block.is_empty() \
		and source.count("_append_wing_window_schedule(") == 3 \
		and source.count("_append_wing_window_schedule(glass, reveal, trim, record, wing_runs, int(schedule.upper_windows_per_wing), 2.2, 2.35, 2.8, 2, 5, 0.13, 16.9, front)") == 1 \
		and source.count("_append_wing_window_schedule(glass, reveal, trim, record, wing_runs, int(schedule.lower_windows_per_wing), 2.5, 2.05, 2.45, 2, 3, 0.23, 10.35, front)") == 1 \
		and source.count("const REVEAL_MATERIAL := preload(\"res://game/resources/materials/world/building_1/building_1_reveal_shadow.tres\")") == 1 \
		and source.count("{\"name\": \"HeroPublicFrontReveals\", \"bucket\": reveal, \"material\": REVEAL_MATERIAL") == 1 \
		and schedule_block.count("_append_wing_window(glass, reveal, trim, frame") == 1 \
		and not schedule_block.contains("collision") and not schedule_block.contains("Navigation") and not schedule_block.contains("Decal") \
		and wing_block.count("_append_box(reveal, anchor + normal * reveal_center") == 1 \
		and wing_block.count("_append_window(glass, trim, frame") == 1 \
		and wing_block.contains("var border := float(front.wing_window_reveal_border)") \
		and wing_block.contains("var reveal_front := glass_front - float(front.wing_window_reveal_front_lag)") \
		and wing_block.contains("var reveal_rear := -float(front.wing_window_reveal_rear_overlap)") \
		and not wing_block.contains("collision") and not wing_block.contains("Navigation") and not wing_block.contains("Decal") \
		and not generic_block.contains("reveal") \
		and end_block.count("_append_window(") == 2 and not end_block.contains("_append_wing_window")


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
