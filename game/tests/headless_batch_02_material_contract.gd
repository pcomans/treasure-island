extends SceneTree

const NAVY_CHAPEL_187_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd")
const REGISTRY_PATH := "res://game/resources/facades/batch_02_material_registry.json"
const SHADER_PATH := "res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader"
const CORRECTION_SHADER_PATH := "res://game/resources/materials/world/batch_02_04_aperiodic_field.gdshader"
const YMCA_WALL_TANGENT_SHADER_PATH := "res://game/resources/materials/world/ti_ymca/ti_ymca_wall_tangent_aperiodic_field.gdshader"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const EXPECTED_REGISTRY_SHA256 := "e7d1167869640867e2857de1f08df81e878e68230b59feff3fb947b16ff56cb7"
const EXPECTED_SHADER_SHA256 := "1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5"
const EXPECTED_CORRECTION_SHADER_SHA256 := "324ba33a7c78f4b05038168a479ebb8e875c56704236492a050cee8da8e5f798"
const EXPECTED_YMCA_WALL_TANGENT_SHADER_SHA256 := "8943853363f5a2571ebf15a6e9711c6310b706d2e4415f3e1f314d8643d55f6c"
const EXPECTED_BUILDER_SHA256 := "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_HAWKINS_SIGNATURE := "d311c103c9273b94fc982588f46bae6ab67ba6be54b0d0a111dd305e39c22219"
const EXPECTED_BUILDING_3_SIGNATURE := "e0b30339bd2ca8642a7b49b5e6153f52017ec4a840e9b0dc1e3841f5373ca5f8"
# Independently emitted by the accepted Isle all-side focused contract.
const EXPECTED_ISLE_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_BUILDING_WALL := 1 << 1

const TARGETS := [
	{
		"source_key": "w24274434", "receiver_key": "building:w24274434:wall",
		"chunk": "res://generated/world/chunks/x_1__z_2.json",
		"material": "res://game/resources/materials/world/building_2/building_2_primary.tres",
		"material_hash": "e936dc561b653e43eafdef633dc2260c7489a713b5d8da5521b5b118a9b8f8a9",
		"field_kind": 0, "roughness": 0.80, "scale_m": 1.35,
		"segments": 46, "vertex_values": 552, "index_values": 276, "min_y": 3.198, "max_y": 23.56,
	},
	{
		"source_key": "w1272162518", "receiver_key": "building:w1272162518:wall",
		"chunk": "res://generated/world/chunks/x_-1__z_1.json",
		"material": "res://game/resources/materials/world/490_avenue_palms/490_thin_brick.tres",
		"material_hash": "76ae45e057f1d6502c09c6a937d45256c388ee01a67c450a249dffce82cbce39",
		"field_kind": 1, "roughness": 0.84, "scale_m": 0.24,
		"segments": 26, "vertex_values": 312, "index_values": 156, "min_y": 0.606, "max_y": 15.818,
	},
	{
		"source_key": "w1212173437", "receiver_key": "building:w1212173437:wall",
		"chunk": "res://generated/world/chunks/x_-1__z_0.json",
		"material": "res://game/resources/materials/world/star_view_court/star_view_grey_base.tres",
		"material_hash": "c7cd8fc95b76539a9bf20d6aa05cba5b494efdbb27ff93ba74a9a0077f60dc9c",
		"field_kind": 2, "roughness": 0.82, "scale_m": 0.085,
		"segments": 26, "vertex_values": 312, "index_values": 156, "min_y": 1.619, "max_y": 25.485,
	},
	{
		"source_key": "r19685981", "receiver_key": "building:r19685981:wall",
		"chunk": "res://generated/world/chunks/x_-1__z_1.json",
		"material": "res://game/resources/materials/world/maceo_may/maceo_may_sse_rib.tres",
		"material_hash": "da68584fa85647d611f825743e3e58164133b51312199fd7955267bc047721bf",
		"field_kind": 3, "roughness": 0.72, "scale_m": 0.08,
		"segments": 40, "vertex_values": 480, "index_values": 240, "min_y": 2.093, "max_y": 22.43,
	},
	{
		"source_key": "w291189336", "receiver_key": "building:w291189336:wall",
		"chunk": "res://generated/world/chunks/x_-1__z_2.json",
		"material": "res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
		"material_hash": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
		"field_kind": 4, "roughness": 0.76, "scale_m": 1.65,
		"segments": 34, "vertex_values": 408, "index_values": 204, "min_y": 3.921, "max_y": 14.04,
	},
	{
		"source_key": "w34313547", "receiver_key": "building:w34313547:wall",
		"chunk": "res://generated/world/chunks/x_0__z_-2.json",
		"material": "res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres",
		"material_hash": "b5e44afcf4feb6df6ffba46f4e3b60a25fa6043c07c12c33e31c483cb2bf2399",
		"field_kind": 5, "roughness": 0.91, "scale_m": 0.42,
		"segments": 30, "vertex_values": 360, "index_values": 180, "min_y": 3.711, "max_y": 13.102,
	},
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Batch 02 registry bytes drifted.") \
	or not _require(FileAccess.get_sha256(SHADER_PATH) == EXPECTED_SHADER_SHA256, "Batch 02 shader bytes drifted.") \
	or not _require(FileAccess.get_sha256(CORRECTION_SHADER_PATH) == EXPECTED_CORRECTION_SHADER_SHA256, "Rejected-only correction shader bytes drifted.") \
	or not _require(FileAccess.get_sha256(YMCA_WALL_TANGENT_SHADER_PATH) == EXPECTED_YMCA_WALL_TANGENT_SHADER_SHA256, "YMCA-only wall-tangent shader bytes drifted.") \
	or not _require(FileAccess.get_sha256(BUILDER_PATH) == EXPECTED_BUILDER_SHA256, "Runtime builder drifted outside the exact accepted material run trial implementation.") \
	or not _require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	if not _require(_registry_matches(registry), "Batch 02 identity, scope, scale, or non-attachment registry drifted.") \
	or not _require(_shader_contract_matches(), "Batch 02 shader lost its opaque, deterministic, facade-scale-free, derivative-filtered contract."):
		_finish()
		return
	var builder := WorldChunkBuilder.new()
	for index in TARGETS.size():
		var expected := TARGETS[index] as Dictionary
		var registry_target := (registry.targets as Array)[index] as Dictionary
		if not _require(_material_matches(expected, registry_target), "Material contract failed for %s." % str(expected.source_key)):
			_finish()
			return
		var chunk := JSON.parse_string(FileAccess.get_file_as_string(str(expected.chunk))) as Dictionary
		var record := _record_for_key(chunk.records, str(expected.receiver_key))
		if not _require(_source_record_matches(record, expected), "Frozen source receiver drifted for %s." % str(expected.source_key)):
			_finish()
			return
		# The accepted Chapel replacement consumes its wall and roof as one
		# fail-closed transaction. Its historical material trial remains an exact
		# input, but an isolated wall build is intentionally invalid.
		if str(expected.source_key) == "w291189336":
			continue
		var first_result := builder._build_record(record, false)
		var second_result := builder._build_record(record, false)
		if not _require(bool(first_result.get("ok", false)) and bool(second_result.get("ok", false)), "Runtime control build failed for %s." % str(expected.source_key)):
			_free_result(first_result)
			_free_result(second_result)
			_finish()
			return
		var first := first_result.node as Node3D
		var second := second_result.node as Node3D
		if not _require(_generic_receiver_matches(first, record, expected), "Massing/foundation/material/collision/spray or exact accepted-trial control failed for %s." % str(expected.source_key)) \
		or not _require(_two_builds_match(first, second), "Runtime assignment is nondeterministic for %s." % str(expected.source_key)):
			first.free()
			second.free()
			_finish()
			return
		root.add_child(first)
		await physics_frame
		await physics_frame
		if not _require(_spray_ray_hits_source_wall(first, record), "Spray collision ownership drifted for %s." % str(expected.source_key)):
			root.remove_child(first)
			first.free()
			second.free()
			_finish()
			return
		root.remove_child(first)
		first.free()
		second.free()
	if not _require(_active_chapel_pair_contract(builder), "Accepted Navy Chapel paired-wall/roof material or ownership contract drifted.") \
	or not _require(_prior_accepted_signatures_match(builder), "An accepted Hawkins, Building 3, or Isle House signature changed.") \
	or not _require(_active_building_1_and_oasis_contract(builder), "Building 1 exact active hero or Oasis generic control drifted."):
		_finish()
		return
	print("PASS: six evidence-bounded Batch 02 material prototypes remain byte-stable and motif-free; the Chapel trial remains an exact input to its accepted paired live hero and YMCA remains scoped to aggregate/background runs 3..11, while all other Batch 02 receivers, collision, navigation, spray, generated bytes, accepted prior facades, exact-current Building 1 hero, generic Oasis, and non-targets remain unchanged")
	_finish()


func _registry_matches(registry: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.batch-02-material-prototypes/1" \
	or str(registry.get("review_status", "")) != "ready_for_independent_review_not_self_accepted" \
	or str(registry.get("runtime_attachment_policy", "")) != "none_until_exact_observed_region_endpoints_are_reconciled":
		return false
	var proof := registry.get("controlled_proof_contract", {}) as Dictionary
	var correction := registry.get("correction_shader", {}) as Dictionary
	if str(proof.get("receiver_kind", "")) != "controlled_flat_proof_panel" \
	or not bool(proof.get("proof_scales_are_reversible_assumptions", false)) \
		or not is_equal_approx(float(proof.get("one_local_unit_m", 0.0)), 1.0) \
		or str(correction.get("path", "")) != CORRECTION_SHADER_PATH \
		or str(correction.get("sha256", "")) != EXPECTED_CORRECTION_SHADER_SHA256 \
		or bool(correction.get("external_resources", true)):
		return false
	var targets := registry.get("targets", []) as Array
	if targets.size() != TARGETS.size():
		return false
	var observed_sources: Array[String] = []
	for index in targets.size():
		var target := targets[index] as Dictionary
		var expected := TARGETS[index] as Dictionary
		observed_sources.append(str(target.get("source_key", "")))
		if str(target.get("source_key", "")) != str(expected.source_key) \
		or str(target.get("receiver_key", "")) != str(expected.receiver_key) \
		or str(target.get("material_path", "")) != str(expected.material) \
		or str(target.get("runtime_attachment", "")) != "prototype_only" \
		or int(target.get("field_kind", -1)) != int(expected.field_kind) \
		or not is_equal_approx(float(target.get("proof_primary_scale_m", 0.0)), float(expected.scale_m)) \
		or not str(target.get("scale_status", "")).ends_with("proof_only"):
			return false
	var expected_sources: Array[String] = []
	for value: Variant in TARGETS:
		expected_sources.append(str((value as Dictionary).source_key))
	if observed_sources != expected_sources or "w291189918" in observed_sources or "r16681702" in observed_sources:
		return false
	var non_targets := registry.get("explicit_non_targets", {}) as Dictionary
	return non_targets.has("w291189918") and non_targets.has("r16681702") \
		and (registry.get("forbidden_content", []) as Array).size() == 9


func _shader_contract_matches() -> bool:
	var source := FileAccess.get_file_as_string(SHADER_PATH)
	var correction := FileAccess.get_file_as_string(CORRECTION_SHADER_PATH)
	var ymca_wall_tangent := FileAccess.get_file_as_string(YMCA_WALL_TANGENT_SHADER_PATH)
	if not "render_mode depth_draw_opaque, cull_back" in source \
	or source.count("fwidth(") < 2 \
	or not "METALLIC = 0.0" in source \
	or not "NORMAL_MAP" in source:
		return false
	if not "render_mode depth_draw_opaque, cull_back" in correction \
	or not "hash21" in correction \
	or not "value_noise" in correction \
	or correction.count("fwidth(") < 1 \
	or not "METALLIC = 0.0" in correction \
	or not "NORMAL_MAP" in correction:
		return false
	if not "vec2 horizontal_normal = normalize(NORMAL.xz);" in ymca_wall_tangent \
	or not "vec2 wall_tangent = vec2(horizontal_normal.y, -horizontal_normal.x);" in ymca_wall_tangent \
	or not "field_position_m = vec2(dot(VERTEX.xz, wall_tangent), VERTEX.y);" in ymca_wall_tangent \
	or "field_position_m = VERTEX.xy;" in ymca_wall_tangent:
		return false
	for shader_source: String in [source, correction, ymca_wall_tangent]:
		for forbidden in ["discard", "ALPHA =", "TIME", "SCREEN_TEXTURE", "sampler2D", "heightmap", "vertex displacement"]:
			if forbidden in shader_source:
				return false
	return true


func _material_matches(expected: Dictionary, registry_target: Dictionary) -> bool:
	if FileAccess.get_sha256(str(expected.material)) != str(expected.material_hash):
		return false
	var material := load(str(expected.material)) as ShaderMaterial
	var expected_shader := YMCA_WALL_TANGENT_SHADER_PATH if str(expected.source_key) == "w34313547" else SHADER_PATH
	if material == null or material.shader == null or material.shader.resource_path != expected_shader:
		return false
	var roughness := float(material.get_shader_parameter("roughness_value"))
	var range_values := registry_target.roughness_range as Array
	return material.resource_name.ends_with("_prototype") \
		and int(material.get_shader_parameter("field_kind")) == int(expected.field_kind) \
		and is_equal_approx(roughness, float(expected.roughness)) \
		and roughness >= float(range_values[0]) and roughness <= float(range_values[1]) \
		and is_equal_approx(float(material.get_shader_parameter("primary_scale_m")), float(expected.scale_m)) \
		and float(material.get_shader_parameter("filter_start_cycles_per_pixel")) < float(material.get_shader_parameter("filter_end_cycles_per_pixel")) \
		and (material.get_shader_parameter("base_color") as Color).a == 1.0 \
		and (material.get_shader_parameter("secondary_color") as Color).a == 1.0


func _source_record_matches(record: Dictionary, expected: Dictionary) -> bool:
	return not record.is_empty() \
		and record.source_keys == [str(expected.source_key)] \
		and str(record.get("object_key", "")) == str(expected.receiver_key) \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("material_key", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and int(record.get("exterior_foundation_segments", -1)) == int(expected.segments) \
		and int(record.get("shared_wall_segments", -1)) == 0 \
		and (record.vertices as Array).size() == int(expected.vertex_values) \
		and (record.indices as Array).size() == int(expected.index_values) \
		and is_equal_approx(_record_height(record, true), float(expected.min_y)) \
		and is_equal_approx(_record_height(record, false), float(expected.max_y))


func _generic_receiver_matches(node: Node3D, record: Dictionary, expected: Dictionary) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var body := node.get_node_or_null("Collision") as StaticBody3D
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var shape := shape_node.shape as ConcavePolygonShape3D if shape_node != null else null
	if mesh_instance == null or body == null or shape == null or not (mesh_instance.mesh is ArrayMesh):
		return false
	var mesh := mesh_instance.mesh as ArrayMesh
	var arrays := mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var material := mesh.surface_get_material(0) as StandardMaterial3D
	var is_accepted_trial := AcceptedMaterialRunTrials.matches_record(record)
	var attachment_matches := not node.has_meta("accepted_material_run_trial")
	if is_accepted_trial:
		var accepted_material := mesh.surface_get_material(1) as ShaderMaterial if mesh.get_surface_count() == 2 else null
		attachment_matches = node.get_meta("accepted_material_run_trial", {}) == AcceptedMaterialRunTrials.metadata_for(str(expected.receiver_key)) \
			and accepted_material != null and accepted_material.resource_path == str(expected.material) \
			and mesh.surface_get_name(0) == AcceptedMaterialRunTrials.PLACEHOLDER_SURFACE_NAME \
			and mesh.surface_get_name(1) == AcceptedMaterialRunTrials.ACCEPTED_SURFACE_NAME
	return node.get_child_count() == 2 \
		and mesh.get_surface_count() == (2 if is_accepted_trial else 1) \
		and vertices.size() == int(expected.vertex_values) / 3 \
		and mesh.get_faces().size() == int(expected.index_values) \
		and shape.get_faces().size() == int(expected.index_values) \
		and material != null and material.resource_name == "building_wall" \
		and attachment_matches \
		and mesh_instance.layers == RENDER_BUILDING_WALL \
		and body.collision_layer == (1 | PHYSICS_SPRAY_SURFACE) and body.collision_mask == 0 \
		and body.is_in_group("spray_receiver_wall") \
		and str(body.get_meta("receiver_kind", "")) == "building_wall" \
		and str(body.get_meta("derived_object_key", "")) == str(expected.receiver_key) \
		and body.get_meta("source_keys", []) == [str(expected.source_key)] \
		and (node.find_children("*", "CollisionObject3D", true, false) as Array).size() == 1 \
		and (node.find_children("*", "NavigationRegion3D", true, false) as Array).is_empty() \
		and (node.find_children("*Facade*", "Node", true, false) as Array).is_empty() \
		and is_equal_approx(_packed_vector_height(vertices, true), _record_height(record, true)) \
		and is_equal_approx(_packed_vector_height(vertices, false), _record_height(record, false))


func _two_builds_match(first: Node3D, second: Node3D) -> bool:
	var first_mesh := (first.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	var second_mesh := (second.get_node("Mesh") as MeshInstance3D).mesh as ArrayMesh
	if first_mesh.get_surface_count() != second_mesh.get_surface_count():
		return false
	for surface_index in first_mesh.get_surface_count():
		if first_mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_VERTEX] != second_mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_VERTEX] \
		or first_mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] != second_mesh.surface_get_arrays(surface_index)[Mesh.ARRAY_INDEX] \
		or first_mesh.surface_get_material(surface_index).resource_path != second_mesh.surface_get_material(surface_index).resource_path:
			return false
	return (first.get_node("Collision/Shape") as CollisionShape3D).shape.get_faces() == (second.get_node("Collision/Shape") as CollisionShape3D).shape.get_faces()


func _spray_ray_hits_source_wall(node: Node3D, record: Dictionary) -> bool:
	var values := record.vertices as Array
	var point := Vector3.ZERO
	for index in 4:
		point += Vector3(float(values[index * 3]), float(values[index * 3 + 1]), float(values[index * 3 + 2]))
	point /= 4.0
	var normals := record.normals as Array
	var normal := Vector3(float(normals[0]), float(normals[1]), float(normals[2])).normalized()
	var query := PhysicsRayQueryParameters3D.create(point + normal * 2.0, point - normal * 2.0, PHYSICS_SPRAY_SURFACE)
	var hit := node.get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit.get("collider") == node.get_node("Collision") \
		and str((hit.collider as CollisionObject3D).get_meta("derived_object_key", "")) == str(record.object_key)


func _active_chapel_pair_contract(builder: WorldChunkBuilder) -> bool:
	var chunk_value: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/x_-1__z_2.json"))
	if not (chunk_value is Dictionary):
		return false
	var parents := {"ground": Node3D.new(), "roads": Node3D.new(), "buildings": Node3D.new()}
	var report := builder.build_chunk(chunk_value as Dictionary, parents)
	if not bool(report.get("ok", false)):
		for parent: Node3D in parents.values():
			parent.free()
		return false
	var staging := report.get("node", null) as Node3D
	if staging == null:
		for parent: Node3D in parents.values():
			parent.free()
		return false
	var walls := _nodes_for_key(staging, "building:w291189336:wall")
	var roofs := _nodes_for_key(staging, "building:w291189336:roof")
	var matches := walls.size() == 1 and roofs.size() == 1
	if matches:
		var wall := walls[0] as Node3D
		var roof := roofs[0] as Node3D
		var wall_body := wall.get_node_or_null("Collision") as StaticBody3D
		var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
		var metadata := wall.get_meta("navy_chapel_187_live_replacement", {}) as Dictionary
		matches = wall.name == "NavyChapel187LiveWallVisualAndCollisionReplacement" \
			and roof.name == "NavyChapel187LiveRoofCollisionReplacement" \
			and wall.find_children("*", "MeshInstance3D", true, false).size() == 6 \
			and roof.find_children("*", "MeshInstance3D", true, false).is_empty() \
			and wall_body != null and roof_body != null \
			and wall_body.is_in_group("spray_receiver_wall") and not roof_body.is_in_group("spray_receiver_wall") \
			and str(metadata.get("geometry_signature", "")) == NAVY_CHAPEL_187_LIVE_REPLACEMENT.EXPECTED_GEOMETRY_SIGNATURE \
			and str(metadata.get("live_ownership_signature", "")) == NAVY_CHAPEL_187_LIVE_REPLACEMENT.EXPECTED_LIVE_OWNERSHIP_SIGNATURE \
			and NAVY_CHAPEL_187_LIVE_REPLACEMENT.material_semantics_match(wall) \
			and not bool(metadata.get("fallback_allowed", true)) and not bool(metadata.get("stack_allowed", true))
	staging.free()
	for parent: Node3D in parents.values():
		parent.free()
	return matches


func _nodes_for_key(root_node: Node, key: String) -> Array[Node]:
	var result: Array[Node] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if node.has_meta("feature_kind") and str(node.get_meta("derived_object_key", "")) == key:
			result.append(node)
	return result


func _prior_accepted_signatures_match(builder: WorldChunkBuilder) -> bool:
	var controls := [
		{"chunk": "res://generated/world/chunks/x_-1__z_1.json", "key": "building:w1249412093:wall", "child": "Hawkins77BrutonFacade", "signature": EXPECTED_HAWKINS_SIGNATURE},
		{"chunk": "res://generated/world/chunks/x_1__z_1.json", "key": "building:w34313540:wall", "child": "Building3600CaliforniaFacade", "signature": EXPECTED_BUILDING_3_SIGNATURE},
		{"chunk": "res://generated/world/chunks/x_-1__z_2.json", "key": "building-composite:w1249412094:w1282547786:wall", "child": "IsleHouse39BrutonHighFacade", "signature": EXPECTED_ISLE_SIGNATURE},
	]
	for value: Variant in controls:
		var control := value as Dictionary
		var chunk := JSON.parse_string(FileAccess.get_file_as_string(str(control.chunk))) as Dictionary
		var record := _record_for_key(chunk.records, str(control.key))
		var result := builder._build_record(record, false)
		if not bool(result.get("ok", false)):
			_free_result(result)
			return false
		var node := result.node as Node3D
		var facade := node.get_node_or_null(str(control.child))
		var matches := facade != null and str(facade.get_meta("deterministic_signature", "")) == str(control.signature)
		node.free()
		if not matches:
			return false
	return true


func _active_building_1_and_oasis_contract(builder: WorldChunkBuilder) -> bool:
	var building_chunk := JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/x_-1__z_2.json")) as Dictionary
	var building_result := builder._build_record(_record_for_key(building_chunk.records, "building:r16681702:wall"), false)
	if not bool(building_result.get("ok", false)):
		_free_result(building_result)
		return false
	var building_node := building_result.node as Node3D
	var building_body := building_node.get_node_or_null("Collision") as StaticBody3D
	var building_shape := building_node.get_node_or_null("Collision/Shape") as CollisionShape3D
	var building_matches := str(building_node.get_meta("building_1_hero_component", "")) == "building_wall" \
		and str(building_node.get_meta("model_id", "")) == "TREASURE-ISLAND-BUILDING-1-HERO-01" \
		and bool(building_node.get_meta("runtime_supersedes_generated_placeholder", false)) \
		and bool(building_node.get_meta("horizontal_source_geometry_preserved", false)) \
		and int(building_node.get_meta("mesh_instances", -1)) == 6 \
		and int(building_node.get_meta("surfaces", -1)) == 6 \
		and int(building_node.get_meta("triangles", -1)) == 8806 \
		and int(building_node.get_meta("collision_face_vertices", -1)) == 2046 \
		and bool(building_node.get_meta("public_front_believability_pass", false)) \
		and int(building_node.get_meta("relief_proxy_count", -1)) == 0 \
		and int(building_node.get_meta("neutral_end_relief_location_field_count", -1)) == 2 \
		and int(building_node.get_meta("misleading_cruciform_proxy_count", -1)) == 0 \
		and building_body != null and building_shape != null \
		and building_body.collision_layer == ((1 << 0) | (1 << 2)) \
		and building_body.is_in_group("spray_receiver_wall") \
		and (building_shape.shape as ConcavePolygonShape3D).get_faces().size() == 2046
	building_node.free()
	if not building_matches:
		return false
	var oasis_chunk := JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/x_0__z_1.json")) as Dictionary
	var oasis_result := builder._build_record(_record_for_key(oasis_chunk.records, "building:w291189918:wall"), false)
	if not bool(oasis_result.get("ok", false)):
		_free_result(oasis_result)
		return false
	var oasis_node := oasis_result.node as Node3D
	var oasis_matches := oasis_node.get_child_count() == 2 \
		and (oasis_node.find_children("*Facade*", "Node", true, false) as Array).is_empty() \
		and (oasis_node.get_node("Mesh") as MeshInstance3D).mesh.surface_get_material(0).resource_name == "building_wall"
	oasis_node.free()
	return oasis_matches


func _record_height(record: Dictionary, minimum: bool) -> float:
	var result := INF if minimum else -INF
	var values := record.vertices as Array
	for index in range(1, values.size(), 3):
		result = minf(result, float(values[index])) if minimum else maxf(result, float(values[index]))
	return result


func _packed_vector_height(values: PackedVector3Array, minimum: bool) -> float:
	var result := INF if minimum else -INF
	for value: Vector3 in values:
		result = minf(result, value.y) if minimum else maxf(result, value.y)
	return result


func _record_for_key(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		var record := value as Dictionary
		if str(record.get("object_key", "")) == key:
			return record
	return {}


func _free_result(result: Dictionary) -> void:
	var node := result.get("node", null) as Node
	if node != null and not node.is_inside_tree():
		node.free()


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error(message)
	return false


func _finish() -> void:
	quit(1 if _failed else 0)
