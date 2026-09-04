extends SceneTree

const TARGET_SOURCE_KEY := "w1249412093"
const TARGET_WALL_KEY := "building:w1249412093:wall"
const TARGET_ROOF_KEY := "building:w1249412093:roof"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_1.json"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const LAYOUT_PATH := "res://game/resources/facades/hawkins_77_bruton_layout.json"
const EXPECTED_CHUNK_SHA256 := "b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_LAYOUT_SHA256 := "4de2239af2e18fe4121930d51dee15e081d2f81a40393da2f1f29c69464761d9"
const EXPECTED_B3_SIGNATURE := "e0b30339bd2ca8642a7b49b5e6153f52017ec4a840e9b0dc1e3841f5373ca5f8"
const EXPECTED_ISLE_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_BUILDING_WALL := 1 << 1
const EXPECTED_MODULE_COUNTS := {
	"W-P": 128, "S-H": 128, "R-C": 10, "W-N": 10,
	"L-G": 1, "D-P": 1, "F-SIGN": 1, "C-B": 1,
	"D-S": 1, "G-G": 1, "G-W": 17,
}
const ACCEPTED_ASSET_HASHES := {
	"res://game/resources/materials/world/hawkins/hawkins_glass_proxy.tres": "10bcc87b347aa51557e0597476c97d4173f74c67f2bdb9883418026e60e49c63",
	"res://game/resources/materials/world/hawkins/hawkins_pearl_fluted.tres": "171cb1d9c8ba31b19622ad7ccf2d005eed94d7793f59e1d90882291ec9ce5415",
	"res://game/resources/materials/world/hawkins/hawkins_frame_charcoal.tres": "2e99cc73385650e19bd957f0f6fa92826e2cef2e53c88653910f64a81efc244a",
	"res://game/resources/materials/world/hawkins/hawkins_base_ribbed.tres": "3fdd57da8d860edf5b8a59d9eb9ac7330cddacf5f96d335d2c75fd000e298709",
	"res://game/resources/materials/world/hawkins/hawkins_spandrel_pale.tres": "55319e2dfb543173a212b4f79653f5622e4db6f40e0941821e6cdfd7a5a55a15",
	"res://game/resources/materials/world/hawkins/hawkins_sign_letters.tres": "6954194a853d4440ccb2e544870c18ab21c7ffdeaa7420ee83f1aa5b32dceb6c",
	"res://game/resources/materials/world/hawkins/hawkins_pearl_fluted.gdshader": "82de521449dc386ed9ad5630abc8e1a874585a56731fa95fbfa3b984c0a6b330",
	"res://game/resources/materials/world/hawkins/hawkins_base_smooth.tres": "94b73c60e1d43bcc2bfac0ecf0803c021ec34c88b6579799a58b8bf7f3e617dc",
	"res://game/resources/materials/world/hawkins/hawkins_pearl_plain.tres": "ca16d8e5ae23097f449040a61c6682fe7552d47eaf310acdffa78a3994b77546",
	"res://game/resources/materials/world/hawkins/hawkins_garage_dark.tres": "db479ea790823d13f09df35d9fa558afa53fde5ca09585aa68160a98b3569501",
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(CHUNK_PATH) == EXPECTED_CHUNK_SHA256, "Serialized Hawkins chunk bytes drifted.") \
	or not _require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted.") \
	or not _require(FileAccess.get_sha256(LAYOUT_PATH) == EXPECTED_LAYOUT_SHA256, "Hawkins layout bytes drifted.") \
	or not _require(_accepted_assets_unchanged(), "Accepted Hawkins material/shader assets changed."):
		_finish()
		return
	var manifest := JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH)) as Dictionary
	var chunk := JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH)) as Dictionary
	var wall := _record_for_key(chunk.records, TARGET_WALL_KEY)
	var roof := _record_for_key(chunk.records, TARGET_ROOF_KEY)
	var other_wall := _other_wall_record(chunk.records)
	if not _require(str(manifest.get("content_sha256", "")) == EXPECTED_CONTENT_SHA256, "Generated content hash drifted.") \
	or not _require(_source_records_match(wall, roof), "Frozen Hawkins receiver/source foundation contract drifted.") \
	or not _require(_pure_massing_matches(wall), "Exact P/Q, area, perimeter, volume, story, wall, roof, or foundation interpolation contract drifted."):
		_finish()
		return

	var builder := WorldChunkBuilder.new()
	var started := Time.get_ticks_msec()
	var first_result := builder._build_record(wall, false)
	var second_result := builder._build_record(wall, false)
	var roof_result := builder._build_record(roof, false)
	var second_roof_result := builder._build_record(roof, false)
	var other_result := builder._build_record(other_wall, false)
	var direct_build_ms := Time.get_ticks_msec() - started
	var results := [first_result, second_result, roof_result, second_roof_result, other_result]
	for result_value: Variant in results:
		if not _require(bool((result_value as Dictionary).get("ok", false)), "A direct Hawkins build/control failed."):
			_free_results(results)
			_finish()
			return
	var first := first_result.node as Node3D
	var second := second_result.node as Node3D
	var target_roof := roof_result.node as Node3D
	var second_roof := second_roof_result.node as Node3D
	var other := other_result.node as Node3D
	var facade := first.get_node_or_null("Hawkins77BrutonFacade") as Hawkins77BrutonFacade
	var second_facade := second.get_node_or_null("Hawkins77BrutonFacade") as Hawkins77BrutonFacade
	if not _require(_runtime_wall_matches(first), "Raised Hawkins wall mesh/collision/spray identity drifted.") \
	or not _require(_runtime_roof_matches(target_roof), "Stepped Hawkins roof mesh/collision/rejection drifted.") \
	or not _require(str(first.get_meta("massing_signature", "")) == str(second.get_meta("massing_signature", "")), "Wall builds are nondeterministic.") \
	or not _require(str(target_roof.get_meta("massing_signature", "")) == str(second_roof.get_meta("massing_signature", "")), "Roof builds are nondeterministic.") \
	or not _require(facade != null and second_facade != null and _facade_matches(facade), "Facade story/module remap or render-only contract drifted.") \
	or not _require(str(facade.get_meta("deterministic_signature", "")) == str(second_facade.get_meta("deterministic_signature", "")), "Facade remap is nondeterministic.") \
	or not _require(other.get_node_or_null("Hawkins77BrutonFacade") == null and not bool(other.get_meta("hawkins_massing_override", false)), "Hawkins massing/facade spilled over.") \
	or not _require(_accepted_cohort_and_museum_unchanged(builder), "Building 3/Isle House changed or Museum gained an attachment."):
		_free_results(results)
		_finish()
		return
	root.add_child(first)
	root.add_child(target_roof)
	await physics_frame
	await physics_frame
	if not _require(_physics_surfaces_match(first, target_roof), "Lower/upper/step/roof physics or spray ownership drifted."):
		root.remove_child(first)
		root.remove_child(target_roof)
		_free_results(results)
		_finish()
		return
	root.remove_child(first)
	root.remove_child(target_roof)
	var facade_signature := str(facade.get_meta("deterministic_signature", ""))
	first.free()
	target_roof.free()
	second.free()
	second_roof.free()
	other.free()
	var reload := await _two_full_reloads_match()
	if not _require(bool(reload.get("ok", false)), str(reload.get("message", "Two full reloads failed."))):
		_finish()
		return
	print("HAWKINS_MASSING_PERF: direct_build_ms=%d full_reload_ms=%s runtime_triangles=50273 facade_signature=%s" % [direct_build_ms, reload.load_msec, facade_signature])
	print("PASS: exact Hawkins-only 21 m six-story main plus 14 m four-story companion runtime massing; 23 wall quads/four roof triangles own matching collision and wall-only spray identity, deterministic remapped facade rows, unchanged source/foundation/material/cohort contracts, and no spillover")
	_finish()


func _source_records_match(wall: Dictionary, roof: Dictionary) -> bool:
	return not wall.is_empty() and not roof.is_empty() \
		and wall.source_keys == [TARGET_SOURCE_KEY] and roof.source_keys == [TARGET_SOURCE_KEY] \
		and int(wall.exterior_foundation_segments) == 20 and int(wall.shared_wall_segments) == 0 \
		and (wall.vertices as Array).size() == 240 and (wall.indices as Array).size() == 120 \
		and (roof.vertices as Array).size() == 12 and (roof.indices as Array).size() == 6 \
		and is_equal_approx(_source_max_y(wall), 10.274) and is_equal_approx(_source_max_y(roof), 10.274)


func _pure_massing_matches(wall: Dictionary) -> bool:
	var p := Hawkins77BrutonMassing.split_p()
	var q := Hawkins77BrutonMassing.split_q()
	var p_exact := Hawkins77BrutonMassing.split_p_values()
	var q_exact := Hawkins77BrutonMassing.split_q_values()
	var outer: Array[Vector2] = [Vector2(-118.795, 451.595), Vector2(-79.648, 526.358), Vector2(-41.556, 480.728), Vector2(-69.387, 427.417)]
	var main: Array[Vector2] = [outer[0], p, q, outer[2], outer[3]]
	var companion: Array[Vector2] = [p, outer[1], q]
	var contract := Hawkins77BrutonMassing.massing_contract()
	if absf(p_exact[0] - -90.7771613773) > 0.0000000001 or absf(p_exact[1] - 505.1035107148) > 0.0000000001 \
	or absf(q_exact[0] - -58.4999702509) > 0.0000000001 or absf(q_exact[1] - 501.0250010119) > 0.0000000001 \
	or absf(float(contract.outer_area_m2) - 3970.518805999996) > 0.000000001 \
	or absf(float(contract.main_area_m2) - 3604.806003192094) > 0.000000001 \
	or absf(float(contract.companion_area_m2) - 365.712802807902) > 0.000000001 \
	or absf(float(contract.main_area_m2) + float(contract.companion_area_m2) - float(contract.outer_area_m2)) > 0.000000001 \
	or absf(_area(main) + _area(companion) - _area(outer)) > 0.001 \
	or int(contract.main_story_count) != 6 or int(contract.companion_story_count) != 4 \
	or contract.band_tops_y_m != [7.774, 11.274, 14.774, 18.274, 21.774, 25.274]:
		return false
	var wall_geometry := Hawkins77BrutonMassing.wall_geometry(wall)
	var roof_geometry := Hawkins77BrutonMassing.roof_geometry()
	if not bool(wall_geometry.ok) or not bool(roof_geometry.ok) \
	or (wall_geometry.vertices as PackedVector3Array).size() != 92 \
	or (wall_geometry.indices as PackedInt32Array).size() != 138 \
	or (roof_geometry.indices as PackedInt32Array).size() != 12:
		return false
	var exterior: Array[Dictionary] = []
	var step: Dictionary = {}
	for value: Variant in wall_geometry.quads:
		var quad := value as Dictionary
		if str(quad.role) == "step": step = quad
		else: exterior.append(quad)
	if exterior.size() != 22 or step.is_empty():
		return false
	for index in exterior.size():
		var current := exterior[index].end_bottom as Vector3
		var following := exterior[(index + 1) % exterior.size()].start_bottom as Vector3
		if Vector2(current.x, current.z).distance_to(Vector2(following.x, following.z)) > 0.0000001:
			return false
	var runtime_perimeter := 0.0
	var main_quads := 0
	var companion_quads := 0
	for quad: Dictionary in exterior:
		var start := quad.start_bottom as Vector3
		var end := quad.end_bottom as Vector3
		runtime_perimeter += Vector2(start.x, start.z).distance_to(Vector2(end.x, end.z))
		if str(quad.volume) == "main" and is_equal_approx((quad.start_top as Vector3).y, 25.274): main_quads += 1
		elif str(quad.volume) == "companion" and is_equal_approx((quad.start_top as Vector3).y, 18.274): companion_quads += 1
		else: return false
	var p_bottom := exterior[4].end_bottom as Vector3
	var q_bottom := exterior[10].end_bottom as Vector3
	var roof_heights := _height_set(roof_geometry.vertices)
	var final_ok := absf(runtime_perimeter - _perimeter(outer)) < 0.00001 \
		and main_quads == 16 and companion_quads == 6 \
		and absf(p_bottom.y - 4.227158575) < 0.0000005 \
		and absf(q_bottom.y - 4.156504860) < 0.0000005 \
		and Vector2((step.start_bottom as Vector3).x, (step.start_bottom as Vector3).z).distance_to(p) < 0.0000001 \
		and Vector2((step.end_bottom as Vector3).x, (step.end_bottom as Vector3).z).distance_to(q) < 0.0000001 \
		and is_equal_approx((step.start_bottom as Vector3).y, 18.274) \
		and is_equal_approx((step.start_top as Vector3).y, 25.274) \
		and absf(Vector2((step.end_bottom as Vector3).x - (step.start_bottom as Vector3).x, (step.end_bottom as Vector3).z - (step.start_bottom as Vector3).z).length() - 32.533848657) < 0.00001 \
		and 10.274 not in _height_set(wall_geometry.vertices) \
		and roof_heights.size() == 2 \
		and is_equal_approx(roof_heights[0], 18.274) \
		and is_equal_approx(roof_heights[1], 25.274)
	return final_ok


func _runtime_wall_matches(node: Node3D) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if mesh_instance == null or body == null or shape == null or not (mesh_instance.mesh is ArrayMesh): return false
	var mesh := mesh_instance.mesh as ArrayMesh
	var vertices := (mesh.surface_get_arrays(0) as Array)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var heights := _height_set(vertices)
	var material := mesh.surface_get_material(0) as StandardMaterial3D
	return vertices.size() == 92 and mesh.get_faces().size() == 138 and shape.get_faces().size() == 138 \
		and mesh_instance.layers == RENDER_BUILDING_WALL and material != null and material.resource_name == "building_wall" \
		and body.collision_layer == (1 | PHYSICS_SPRAY_SURFACE) and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") and str(body.get_meta("receiver_kind", "")) == "building_wall" \
		and str(body.get_meta("derived_object_key", "")) == TARGET_WALL_KEY and body.get_meta("source_keys", []) == [TARGET_SOURCE_KEY] \
		and int(node.get_meta("source_exterior_foundation_segments", 0)) == 20 \
		and int(node.get_meta("runtime_exterior_wall_quads", 0)) == 22 and int(node.get_meta("runtime_exposed_step_quads", 0)) == 1 \
		and is_equal_approx(heights[0], 4.043) and is_equal_approx(heights[heights.size() - 1], 25.274) and 10.274 not in heights \
		and (node.find_children("*", "StaticBody3D", true, false) as Array).size() == 1 \
		and (node.find_children("*", "CollisionShape3D", true, false) as Array).size() == 1


func _runtime_roof_matches(node: Node3D) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if mesh_instance == null or body == null or shape == null or not (mesh_instance.mesh is ArrayMesh): return false
	var mesh := mesh_instance.mesh as ArrayMesh
	var heights := _height_set((mesh.surface_get_arrays(0) as Array)[Mesh.ARRAY_VERTEX])
	return mesh.get_faces().size() == 12 and shape.get_faces().size() == 12 \
		and body.collision_layer == (1 | PHYSICS_SPRAY_SURFACE) and not body.is_in_group("spray_receiver_wall") \
		and str(body.get_meta("receiver_kind", "x")) == "none" and str(body.get_meta("derived_object_key", "")) == TARGET_ROOF_KEY \
		and node.get_node_or_null("Hawkins77BrutonFacade") == null \
		and heights.size() == 2 and is_equal_approx(heights[0], 18.274) and is_equal_approx(heights[1], 25.274)


func _facade_matches(facade: Hawkins77BrutonFacade) -> bool:
	if facade.get_meta("module_counts", {}) != EXPECTED_MODULE_COUNTS \
	or int(facade.get_meta("foundation_segment_count", 0)) != 20 \
	or int(facade.get_meta("runtime_exterior_wall_quads", 0)) != 22 or int(facade.get_meta("runtime_exposed_step_quads", 0)) != 1 \
	or not bool(facade.get_meta("render_only", false)) \
	or not facade.find_children("*", "CollisionObject3D", true, false).is_empty() \
	or not facade.find_children("*", "NavigationRegion3D", true, false).is_empty(): return false
	var fields := facade.get_node_or_null("FacadeFields") as MeshInstance3D
	if fields == null or fields.layers != RENDER_BUILDING_WALL or int(fields.get_meta("exact_receiver_segments", 0)) != 23: return false
	var field_mesh := fields.mesh as ArrayMesh
	var field_vertices := 0
	var field_triangles := 0
	for surface_index in field_mesh.get_surface_count():
		var arrays := field_mesh.surface_get_arrays(surface_index)
		field_vertices += (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
		field_triangles += (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
	if field_mesh.get_surface_count() != 3 or field_vertices != 180 or field_triangles != 90 or not _field_material_coverage_matches(field_mesh): return false
	var expected_sides := {
		"side_wsw": {"segments": 8, "upper": "pearl_fluted"},
		"side_se": {"segments": 4, "upper": "pearl_fluted"},
		"side_ene": {"segments": 6, "upper": "pearl_plain"},
		"side_nnw": {"segments": 4, "upper": "pearl_plain"},
	}
	for side_id_value: Variant in expected_sides:
		var side_id := str(side_id_value)
		var side := facade.get_node_or_null(side_id) as Node3D
		var expected := expected_sides[side_id] as Dictionary
		var base := side.get_node_or_null("Field_Base") as Node3D if side != null else null
		var upper := side.get_node_or_null("Field_Upper") as Node3D if side != null else null
		if side == null or base == null or upper == null \
		or int(side.get_meta("foundation_segment_count", 0)) != int(expected.segments) \
		or str(base.get_meta("material_key", "")) != "base_smooth" \
		or str(upper.get_meta("material_key", "")) != str(expected.upper):
			return false
	for side_id: String in ["side_ene", "side_nnw", "side_step"]:
		var side := facade.get_node_or_null(side_id) as Node3D
		if side == null or str(side.get_meta("module_policy", "")) != "material_only" or not _module_nodes(side).is_empty(): return false
	return _module_rows_match(facade.get_node("side_wsw") as Node3D, "side_wsw", 75, 9) \
		and _module_rows_match(facade.get_node("side_se") as Node3D, "side_se", 20, 24) \
		and _connector_edges_match(facade.get_node("side_wsw") as Node3D, 59.675, 60.4) \
		and _connector_edges_match(facade.get_node("side_se") as Node3D, 33.725, 33.0)


func _field_material_coverage_matches(mesh: ArrayMesh) -> bool:
	var expected_vertices := {
		"hawkins_base_smooth.tres": 88,
		"hawkins_pearl_fluted.tres": 48,
		"hawkins_pearl_plain.tres": 44,
	}
	var seen: Dictionary = {}
	var exact_quads: Dictionary = {}
	for surface_index in mesh.get_surface_count():
		var material := mesh.surface_get_material(surface_index) as Material
		var filename := material.resource_path.get_file() if material != null else ""
		var arrays := mesh.surface_get_arrays(surface_index)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		if filename not in expected_vertices or seen.has(filename) or vertices.size() != int(expected_vertices[filename]) or vertices.size() % 4 != 0:
			return false
		seen[filename] = true
		for quad_index in int(vertices.size() / 4):
			var corners: Array[String] = []
			for corner_index in 4:
				var corner := vertices[quad_index * 4 + corner_index]
				corners.append("%.5f,%.5f,%.5f" % [corner.x, corner.y, corner.z])
			corners.sort()
			var token := "|".join(corners)
			if exact_quads.has(token):
				return false
			exact_quads[token] = true
	return seen.size() == 3 and exact_quads.size() == 45


func _module_rows_match(side: Node3D, side_id: String, expected_main: int, expected_companion: int) -> bool:
	var main := 0
	var companion := 0
	for module: Node in _module_nodes(side):
		if str(module.get_meta("module_kind", "")) != "W-P": continue
		if str(module.get_meta("side_id", "")) != side_id or str(module.get_meta("window_subdivision", "")) != "horizontal_transom_lower_pane": return false
		var y := (module as Node3D).transform.origin.y
		var role := str(module.get_meta("volume_role", ""))
		if role == "main" and _float_in(y, [9.524, 13.024, 16.524, 20.024, 23.524]): main += 1
		elif role == "companion" and _float_in(y, [9.524, 13.024, 16.524]): companion += 1
		else: return false
	return main == expected_main and companion == expected_companion


func _connector_edges_match(side: Node3D, center: float, split_u: float) -> bool:
	var count := 0
	for module: Node in _module_nodes(side):
		if str(module.get_meta("module_kind", "")) != "R-C": continue
		count += 1
		var u := float(module.get_meta("side_u_m", -1.0))
		var width := float(module.get_meta("width_m", 0.0))
		var edge := u + width * 0.5 if center < split_u else u - width * 0.5
		if not is_equal_approx(u, center) or not is_equal_approx(edge, split_u) or str(module.get_meta("volume_role", "")) != "main": return false
	return count == 5


func _physics_surfaces_match(wall: Node3D, roof: Node3D) -> bool:
	var wsw_start := Vector3(-118.795, 0.0, 451.595)
	var wsw_tangent := Vector3(39.147, 0.0, 74.763).normalized()
	var wsw_normal := Vector3(-0.886, 0.0, 0.464).normalized()
	var se_start := Vector3(-79.648, 0.0, 526.358)
	var se_tangent := Vector3(38.092, 0.0, -45.63).normalized()
	var se_normal := Vector3(0.768, 0.0, 0.641).normalized()
	var p := Hawkins77BrutonMassing.split_p()
	var q := Hawkins77BrutonMassing.split_q()
	var step_normal := Vector3(0.1253620420, 0.0, 0.9921110615).normalized()
	var step_point := Vector3((p.x + q.x) * 0.5, 21.0, (p.y + q.y) * 0.5)
	for ray: Array in [
		[se_start + se_tangent * 15.5 + Vector3.UP * 5.8, se_normal],
		[wsw_start + wsw_tangent * 35.0 + Vector3.UP * 20.024, wsw_normal],
		[se_start + se_tangent * 15.0 + Vector3.UP * 13.024, se_normal],
		[step_point, step_normal],
	]:
		var hit := _ray((ray[0] as Vector3) + (ray[1] as Vector3) * 3.0, (ray[0] as Vector3) - (ray[1] as Vector3) * 3.0)
		if hit.is_empty() or hit.get("collider") != wall.get_node("Collision"): return false
	var main_roof := _ray(Vector3(-70.0, 30.0, 470.0), Vector3(-70.0, 20.0, 470.0))
	var companion_roof := _ray(Vector3(-75.0, 22.0, 510.0), Vector3(-75.0, 15.0, 510.0))
	return not main_roof.is_empty() and main_roof.get("collider") == roof.get_node("Collision") \
		and not companion_roof.is_empty() and companion_roof.get("collider") == roof.get_node("Collision") \
		and str((roof.get_node("Collision") as StaticBody3D).get_meta("receiver_kind", "")) == "none" \
		and not (roof.get_node("Collision") as StaticBody3D).is_in_group("spray_receiver_wall")


func _accepted_cohort_and_museum_unchanged(builder: WorldChunkBuilder) -> bool:
	var b3_chunk := JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/x_1__z_1.json")) as Dictionary
	var isle_chunk := JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/x_-1__z_2.json")) as Dictionary
	var b3 := builder._build_record(_record_for_key(b3_chunk.records, "building:w34313540:wall"), false)
	var isle := builder._build_record(_record_for_key(isle_chunk.records, "building-composite:w1249412094:w1282547786:wall"), false)
	var museum := builder._build_record(_record_for_key(isle_chunk.records, "building:r16681702:wall"), false)
	var results := [b3, isle, museum]
	if not bool(b3.get("ok", false)) or not bool(isle.get("ok", false)) or not bool(museum.get("ok", false)):
		_free_results(results)
		return false
	var b3_facade := (b3.node as Node3D).get_node_or_null("Building3600CaliforniaFacade") as Building3600CaliforniaFacade
	var isle_facade := (isle.node as Node3D).get_node_or_null("IsleHouse39BrutonHighFacade") as IsleHouse39BrutonHighFacade
	var ok := b3_facade != null and isle_facade != null \
		and str(b3_facade.get_meta("deterministic_signature", "")) == EXPECTED_B3_SIGNATURE \
		and str(isle_facade.get_meta("deterministic_signature", "")) == EXPECTED_ISLE_SIGNATURE \
		and (museum.node as Node3D).find_children("*Facade*", "Node", true, false).is_empty()
	_free_results(results)
	return ok


func _two_full_reloads_match() -> Dictionary:
	var packed := load("res://game/scenes/world/world_root.tscn") as PackedScene
	if packed == null: return {"ok": false, "message": "Could not load WorldRoot."}
	var world := packed.instantiate() as WorldLoader
	var reports: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: reports.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, source_keys: Array) -> void: failures.append({"code": code, "message": message, "source_keys": source_keys}))
	root.add_child(world)
	var signatures: Array[String] = []
	var load_times: Array[int] = []
	for reload_index in 2:
		var started := Time.get_ticks_msec()
		world.load_world(MANIFEST_PATH)
		await process_frame
		await process_frame
		load_times.append(Time.get_ticks_msec() - started)
		if not failures.is_empty() or reports.size() != reload_index + 1:
			root.remove_child(world)
			world.free()
			return {"ok": false, "message": "Full reload failed: %s" % [failures]}
		var walls := _nodes_for_key(world, TARGET_WALL_KEY)
		var roofs := _nodes_for_key(world, TARGET_ROOF_KEY)
		if walls.size() != 1 or roofs.size() != 1:
			root.remove_child(world)
			world.free()
			return {"ok": false, "message": "Reload retained duplicate/stale Hawkins roots."}
		var facade := (walls[0] as Node3D).get_node_or_null("Hawkins77BrutonFacade") as Hawkins77BrutonFacade
		var mesh := (walls[0] as Node3D).get_node("Mesh") as MeshInstance3D
		if facade == null or mesh.mesh.get_faces().size() != 138:
			root.remove_child(world)
			world.free()
			return {"ok": false, "message": "Reload did not attach raised Hawkins mass/facade."}
		signatures.append("%s|%s" % [(walls[0] as Node3D).get_meta("massing_signature", ""), facade.get_meta("deterministic_signature", "")])
	var ok := signatures.size() == 2 and signatures[0] == signatures[1]
	root.remove_child(world)
	world.free()
	return {"ok": ok, "message": "Two reload signatures differed.", "load_msec": load_times}


func _accepted_assets_unchanged() -> bool:
	for path_value: Variant in ACCEPTED_ASSET_HASHES:
		var path := str(path_value)
		if FileAccess.get_sha256(path) != str(ACCEPTED_ASSET_HASHES[path]): return false
	return FileAccess.get_sha256("res://game/resources/facades/building_3_600_california_ene_layout.json") == "a491a3c7916191b9ca5f6adacc6d1f2289c0103f5079516b102b94e3993dae0c" \
		and FileAccess.get_sha256("res://game/resources/facades/isle_house_39_bruton_high_se_layout.json") == "c5e6393e90152cef62f6478d7bd87750f3db5598d6ebc36cd307ce20acaa090d"


func _nodes_for_key(root_node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if str(node.get_meta("derived_object_key", "")) == key and node.get_parent() != null and str(node.get_parent().name).contains("__"):
			result.append(node)
	return result


func _module_nodes(side: Node3D) -> Array[Node]:
	var result: Array[Node] = []
	for child: Node in side.get_children():
		if child.has_meta("module_kind"): result.append(child)
	return result


func _ray(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, PHYSICS_SPRAY_SURFACE)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return root.get_world_3d().direct_space_state.intersect_ray(query)


func _float_in(value: float, values: Array) -> bool:
	for candidate: Variant in values:
		if is_equal_approx(value, float(candidate)): return true
	return false


func _height_set(vertices: PackedVector3Array) -> Array[float]:
	var values: Array[float] = []
	for vertex: Vector3 in vertices:
		var rounded := snappedf(vertex.y, 0.000001)
		if rounded not in values: values.append(rounded)
	values.sort()
	return values


func _source_max_y(record: Dictionary) -> float:
	var result := -INF
	for offset in range(1, (record.vertices as Array).size(), 3): result = maxf(result, float(record.vertices[offset]))
	return result


func _area(points: Array[Vector2]) -> float:
	var twice := 0.0
	for index in points.size():
		var following := (index + 1) % points.size()
		twice += points[index].x * points[following].y - points[following].x * points[index].y
	return absf(twice) * 0.5


func _perimeter(points: Array[Vector2]) -> float:
	var result := 0.0
	for index in points.size(): result += points[index].distance_to(points[(index + 1) % points.size()])
	return result


func _record_for_key(records: Array, object_key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == object_key: return record
	return {}


func _other_wall_record(records: Array) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("feature_kind", "")) == "building_wall" and str(record.get("object_key", "")) != TARGET_WALL_KEY: return record
	return {}


func _free_results(results: Array) -> void:
	for result_value: Variant in results:
		var node := (result_value as Dictionary).get("node", null) as Node
		if node != null and not node.is_inside_tree(): node.free()


func _require(condition: bool, message: String) -> bool:
	if condition: return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
