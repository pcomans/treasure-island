extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/batch_04_material_registry.json"
const GENERIC_SHADER_PATH := "res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader"
const SIDING_SHADER_PATH := "res://game/resources/materials/world/batch_04/batch_04_horizontal_siding_field.gdshader"
const CORRECTION_SHADER_PATH := "res://game/resources/materials/world/batch_02_04_aperiodic_field.gdshader"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const EXPECTED_REGISTRY_SHA256 := "b4c5983a628d076cda0aaa24d0023fc7a43983fd6c00f82c9806871af0409cf7"
const EXPECTED_GENERIC_SHADER_SHA256 := "1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5"
const EXPECTED_SIDING_SHADER_SHA256 := "63f0be4ab7995f94653298cff1d5a271728209e05ee014c67b76165bc4f0dc8d"
const EXPECTED_CORRECTION_SHADER_SHA256 := "324ba33a7c78f4b05038168a479ebb8e875c56704236492a050cee8da8e5f798"
const EXPECTED_BATCH_02_REGISTRY_SHA256 := "e7d1167869640867e2857de1f08df81e878e68230b59feff3fb947b16ff56cb7"
const EXPECTED_BATCH_03_REGISTRY_SHA256 := "31983ae1529e6248e93ec8d231d2b870de3979778b35eef6019cd19e1a964516"
const EXPECTED_BUILDER_SHA256 := "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_HAWKINS_SIGNATURE := "d311c103c9273b94fc982588f46bae6ab67ba6be54b0d0a111dd305e39c22219"
const EXPECTED_BUILDING_3_SIGNATURE := "e0b30339bd2ca8642a7b49b5e6153f52017ec4a840e9b0dc1e3841f5373ca5f8"
# Independently emitted by the accepted Isle all-side focused contract.
const EXPECTED_ISLE_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_BUILDING_WALL := 1 << 1

const TARGETS := [
	{"source_key": "w291189926", "receiver_key": "building:w291189926:wall", "chunk": "res://generated/world/chunks/x_0__z_1.json", "segments": 72, "vertex_values": 864, "index_values": 432, "min_y": 3.141, "max_y": 9.390, "height": 6.0, "material_count": 3, "status": "current_reference_prototype_only"},
	{"source_key": "w34313512", "receiver_key": "building:w34313512:wall", "chunk": "res://generated/world/chunks/x_0__z_0.json", "segments": 20, "vertex_values": 240, "index_values": 120, "min_y": 3.241, "max_y": 13.619, "height": 10.0, "material_count": 2, "status": "historical_reference_prototype_only"},
	{"source_key": "w34313546", "receiver_key": "building:w34313546:wall", "chunk": "res://generated/world/chunks/x_0__z_-2.json", "segments": 25, "vertex_values": 300, "index_values": 150, "min_y": 2.870, "max_y": 7.247, "height": 4.0, "material_count": 2, "status": "current_reference_prototype_only"},
	{"source_key": "w96698660", "receiver_key": "building:w96698660:wall", "chunk": "res://generated/world/chunks/x_-1__z_-1.json", "segments": 6, "vertex_values": 72, "index_values": 36, "min_y": 3.246, "max_y": 7.298, "height": 4.0, "material_count": 2, "status": "historical_reference_prototype_only"},
	{"source_key": "w34313569", "receiver_key": "building:w34313569:wall", "chunk": "res://generated/world/chunks/x_-1__z_-4.json", "segments": 27, "vertex_values": 324, "index_values": 162, "min_y": 2.791, "max_y": 11.525, "height": 8.0, "material_count": 2, "status": "current_reference_prototype_only"},
	{"source_key": "w95934092", "receiver_key": "building:w95934092:wall", "chunk": "res://generated/world/chunks/x_-3__z_-2.json", "segments": 26, "vertex_values": 312, "index_values": 156, "min_y": 2.116, "max_y": 8.522, "height": 6.0, "material_count": 2, "status": "current_reference_prototype_only"},
	{"source_key": "w96215649", "receiver_key": "building:w96215649:wall", "chunk": "res://generated/world/chunks/x_-1__z_-3.json", "segments": 28, "vertex_values": 336, "index_values": 168, "min_y": 2.528, "max_y": 8.650, "height": 6.0, "material_count": 4, "status": "current_reference_prototype_only"},
]

const MATERIALS := [
	{"path": "res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_warm_field.tres", "hash": "fb50d3989b7aa41421753ad4db5d195366d9a2c25c15087e5e3a2b7863c69602", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.80, "scale": 1.4, "relief": 0.0},
	{"path": "res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_blue_end.tres", "hash": "03f46e12f4b6b671fc0859e9d68d73ab0fbadd957af97855bbab698b467c4a41", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.80, "scale": 1.25, "relief": 0.0},
	{"path": "res://game/resources/materials/world/job_corps_dormitory_b369/dormitory_b369_green_trim.tres", "hash": "ad4387598f23a327420043f7971ffc4db34274245b639e531071a5f917699ffa", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.65, "scale": 0.85, "relief": 0.0},
	{"path": "res://game/resources/materials/world/449_avenue_h/449_h_historical_siding.tres", "hash": "a4b6858a9f1997874e74321463429546e10acdaf6eac58521d5239f3360ec34d", "shader": SIDING_SHADER_PATH, "field_kind": -1, "roughness": 0.75, "scale": 0.17, "relief": 0.045},
	{"path": "res://game/resources/materials/world/449_avenue_h/449_h_historical_trim.tres", "hash": "10e22c5ce4a5f43140a383b5387e8b83e9eeadcd7672b77a1613f88f22832c68", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.65, "scale": 0.8, "relief": 0.0},
	{"path": "res://game/resources/materials/world/850_avenue_h/850_h_tan_field.tres", "hash": "d92f7137edf2be91b0268659843423764528db58c194cbe5d0b1596a4f8303a8", "shader": CORRECTION_SHADER_PATH, "field_kind": 0, "roughness": 0.80, "scale": 0.75, "relief": 0.0},
	{"path": "res://game/resources/materials/world/850_avenue_h/850_h_teal_edge.tres", "hash": "76cf6b1231952c05362bf41e29ee473452a87aa6aa6f663404b0fed10e42481f", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.67, "scale": 0.75, "relief": 0.0},
	{"path": "res://game/resources/materials/world/810_avenue_d/810_d_historical_siding.tres", "hash": "9c3f2cf0fbc237910652f93fb384444f957b77552f662942f728ec804aae7180", "shader": SIDING_SHADER_PATH, "field_kind": -1, "roughness": 0.74, "scale": 0.18, "relief": 0.04},
	{"path": "res://game/resources/materials/world/810_avenue_d/810_d_historical_brown_trim.tres", "hash": "d8810705d79ba8b79c5fb742b32c65b343a607aba0ed86b989d7aa35760e5a65", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.65, "scale": 0.75, "relief": 0.0},
	{"path": "res://game/resources/materials/world/bldg_461/bldg_461_gray_field.tres", "hash": "e44738c8f1d06a34bfc876b610e2c70a0890c85cbb63342b613094d7b8b80a66", "shader": CORRECTION_SHADER_PATH, "field_kind": 0, "roughness": 0.82, "scale": 0.95, "relief": 0.0},
	{"path": "res://game/resources/materials/world/bldg_461/bldg_461_pale_end.tres", "hash": "fb07e022a7a58c593f97c8aeabede62d849587593dbbaffb629658783dd4874d", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.84, "scale": 1.2, "relief": 0.0},
	{"path": "res://game/resources/materials/world/1318_gateview/1318_gateview_siding.tres", "hash": "abf1e18a2e55ae511957a92aca271bda811fe683f813d09b1591fc7b51d54327", "shader": SIDING_SHADER_PATH, "field_kind": -1, "roughness": 0.75, "scale": 0.17, "relief": 0.04},
	{"path": "res://game/resources/materials/world/1318_gateview/1318_gateview_white_trim.tres", "hash": "30c896ddb23419a590744572fe4396c00fee942c3654985be97e2f33694a7452", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.66, "scale": 0.75, "relief": 0.0},
	{"path": "res://game/resources/materials/world/1212_mariner/1212_mariner_siding.tres", "hash": "fcf16d01599d9152e4c69c29243005efafb7128ebc989f8ef2ca49b2f76e662e", "shader": SIDING_SHADER_PATH, "field_kind": -1, "roughness": 0.75, "scale": 0.17, "relief": 0.04},
	{"path": "res://game/resources/materials/world/1212_mariner/1212_mariner_white_trim.tres", "hash": "21bdf88cbc0acf6de4a6a02a470d4925722ad6232dc7d39eed0b8e0903f23482", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.66, "scale": 0.75, "relief": 0.0},
	{"path": "res://game/resources/materials/world/1212_mariner/1212_mariner_entry_accent.tres", "hash": "8b48483e70b6365b67d3d492d4f2e611ea1d09fc6c3fe8cf74f69628f0170f61", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.65, "scale": 0.85, "relief": 0.0},
	{"path": "res://game/resources/materials/world/1212_mariner/1212_mariner_privacy_accent.tres", "hash": "719ca1fa5e74d298a338e4985a4951551bae47cd3a8a003aee39340a6013d857", "shader": GENERIC_SHADER_PATH, "field_kind": 4, "roughness": 0.75, "scale": 0.9, "relief": 0.0},
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Batch 04 registry bytes drifted.") \
	or not _require(FileAccess.get_sha256(GENERIC_SHADER_PATH) == EXPECTED_GENERIC_SHADER_SHA256, "Accepted shared shader bytes drifted.") \
	or not _require(FileAccess.get_sha256(SIDING_SHADER_PATH) == EXPECTED_SIDING_SHADER_SHA256, "Batch 04 siding shader bytes drifted.") \
	or not _require(FileAccess.get_sha256(CORRECTION_SHADER_PATH) == EXPECTED_CORRECTION_SHADER_SHA256, "Rejected-only correction shader bytes drifted.") \
	or not _require(FileAccess.get_sha256("res://game/resources/facades/batch_02_material_registry.json") == EXPECTED_BATCH_02_REGISTRY_SHA256, "Batch 02 registry drifted.") \
	or not _require(FileAccess.get_sha256("res://game/resources/facades/batch_03_material_registry.json") == EXPECTED_BATCH_03_REGISTRY_SHA256, "Batch 03 registry drifted.") \
	or not _require(FileAccess.get_sha256(BUILDER_PATH) == EXPECTED_BUILDER_SHA256, "Runtime builder drifted outside the exact accepted material run trial implementation.") \
	or not _require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	if not _require(_registry_matches(registry), "Batch 04 identity, temporal state, classification, exclusions, scale, or prototype registry policy drifted.") \
	or not _require(_shader_contracts_match(), "A Batch 04 shader lost its deterministic opaque derivative-filtered material-only contract."):
		_finish()
		return
	var registry_materials := _flatten_registry_materials(registry)
	if not _require(registry_materials.size() == MATERIALS.size(), "Batch 04 registry material count is not 17."):
		_finish()
		return
	for index in MATERIALS.size():
		if not _require(_material_matches(MATERIALS[index] as Dictionary, registry_materials[index] as Dictionary), "Material contract failed for %s." % str((MATERIALS[index] as Dictionary).path)):
			_finish()
			return
	var builder := WorldChunkBuilder.new()
	for expected_value: Variant in TARGETS:
		var expected := expected_value as Dictionary
		var chunk := JSON.parse_string(FileAccess.get_file_as_string(str(expected.chunk))) as Dictionary
		var record := _record_for_key(chunk.records, str(expected.receiver_key))
		if not _require(_source_record_matches(record, expected), "Frozen source receiver drifted for %s." % str(expected.source_key)):
			_finish()
			return
		var first_result := builder._build_record(record, false)
		var second_result := builder._build_record(record, false)
		if not _require(bool(first_result.get("ok", false)) and bool(second_result.get("ok", false)), "Runtime control build failed for %s." % str(expected.source_key)):
			_free_result(first_result)
			_free_result(second_result)
			_finish()
			return
		var first := first_result.node as Node3D
		var second := second_result.node as Node3D
		if not _require(_generic_receiver_matches(first, record, expected), "Massing/foundation/material/collision/navigation/spray or exact accepted-trial control failed for %s." % str(expected.source_key)) \
		or not _require(_two_builds_match(first, second), "Runtime build is nondeterministic for %s." % str(expected.source_key)):
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
	if not _require(_education_29b_remains_generic(builder, registry), "Education Center 29B gained a material or runtime attachment.") \
	or not _require(_prior_accepted_signatures_match(builder), "An accepted Hawkins, Building 3, or Isle House signature changed.") \
	or not _require(_active_building_1_and_oasis_contract(builder), "Building 1 exact active hero or Oasis generic control drifted."):
		_finish()
		return
	print("PASS: 17 evidence-bounded Batch 04 prototype fields remain byte-stable, alias-filtered, facade-scale-motif-free, and temporally explicit; only Dormitory 369 warm wall is attached on exact runs 0..5, while Education 29B, every other Batch 04 receiver, collision, navigation, spray, generated bytes, exact-current Building 1 hero, generic Oasis, and non-targets remain unchanged")
	_finish()


func _registry_matches(registry: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.batch-04-material-prototypes/1" \
	or str(registry.get("review_status", "")) != "mechanically_ready_visual_review_blocked" \
	or not str(registry.get("runtime_attachment_policy", "")).begins_with("none;"):
		return false
	var shaders := registry.get("shader_contracts", []) as Array
	var proof := registry.get("controlled_proof_contract", {}) as Dictionary
	if shaders.size() != 3 \
	or str((shaders[0] as Dictionary).get("sha256", "")) != EXPECTED_GENERIC_SHADER_SHA256 \
	or str((shaders[1] as Dictionary).get("sha256", "")) != EXPECTED_SIDING_SHADER_SHA256 \
	or str((shaders[2] as Dictionary).get("sha256", "")) != EXPECTED_CORRECTION_SHADER_SHA256 \
	or str(proof.get("capture_execution", "")) != "approval_gated_not_executed" \
	or not bool(proof.get("proof_scales_are_reversible_assumptions", false)) \
	or not bool(proof.get("controlled_proofs_are_not_gameplay_or_live_receiver_evidence", false)):
		return false
	var targets := registry.get("targets", []) as Array
	if targets.size() != TARGETS.size():
		return false
	for index in targets.size():
		var target := targets[index] as Dictionary
		var expected := TARGETS[index] as Dictionary
		var materials := target.get("materials", []) as Array
		if str(target.get("source_key", "")) != str(expected.source_key) \
		or str(target.get("receiver_key", "")) != str(expected.receiver_key) \
		or str(target.get("prototype_status", "")) != str(expected.status) \
		or materials.size() != int(expected.material_count) \
		or (target.get("placement_blockers", []) as Array).is_empty() \
		or (target.get("excluded_motifs", []) as Array).is_empty() \
		or (target.get("observed_reference_provenance", []) as Array).size() < 2:
			return false
		if str(expected.status) == "historical_reference_prototype_only":
			if str(target.get("runtime_attachment", "")) != "historical_reference_prototype_only" \
			or not "2011" in str(target.get("temporal_status", "")) \
			or not "never current/live" in str(target.get("temporal_status", "")):
				return false
		elif str(target.get("runtime_attachment", "")) != "prototype_only":
			return false
		for material_value: Variant in materials:
			var material := material_value as Dictionary
			if str(material.get("classification", "")) != "homogeneous_material_tile" \
			or not str(material.get("scale_status", "")).ends_with("proof_only"):
				return false
	var excluded := registry.get("explicit_excluded_targets", {}) as Dictionary
	return excluded.size() == 1 and excluded.has("w34313523") \
		and (registry.get("forbidden_content", []) as Array).size() == 13


func _flatten_registry_materials(registry: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for target_value: Variant in registry.targets:
		for material_value: Variant in (target_value as Dictionary).materials:
			result.append(material_value as Dictionary)
	return result


func _shader_contracts_match() -> bool:
	var generic := FileAccess.get_file_as_string(GENERIC_SHADER_PATH)
	var siding := FileAccess.get_file_as_string(SIDING_SHADER_PATH)
	var correction := FileAccess.get_file_as_string(CORRECTION_SHADER_PATH)
	if not "render_mode depth_draw_opaque, cull_back" in generic or generic.count("fwidth(") < 2:
		return false
	if not "render_mode depth_draw_opaque, cull_back" in siding \
	or siding.count("fwidth(") < 2 \
	or not "field_position_m.y" in siding \
	or not "course_height_m" in siding \
	or not "METALLIC = 0.0" in siding \
	or not "NORMAL_MAP" in siding:
		return false
	if not "hash21" in correction or not "value_noise" in correction or correction.count("fwidth(") < 1:
		return false
	for source: String in [generic, siding, correction]:
		for forbidden in ["discard", "ALPHA =", "TIME", "SCREEN_TEXTURE", "sampler2D", "vertex displacement"]:
			if forbidden in source:
				return false
	return true


func _material_matches(expected: Dictionary, registry_material: Dictionary) -> bool:
	var path := str(expected.path)
	if str(registry_material.get("path", "")) != path \
	or str(registry_material.get("sha256", "")) != str(expected.hash) \
	or FileAccess.get_sha256(path) != str(expected.hash):
		return false
	var source := FileAccess.get_file_as_string(path).to_lower()
	for forbidden in ["texture =", "sampler", "atlas", "module"]:
		if forbidden in source:
			return false
	var material := load(path) as ShaderMaterial
	if material == null or material.shader == null or material.shader.resource_path != str(expected.shader) \
	or not material.resource_name.ends_with("prototype"):
		return false
	var roughness := float(material.get_shader_parameter("roughness_value"))
	var range_values := registry_material.roughness_range as Array
	if not is_equal_approx(roughness, float(expected.roughness)) \
	or roughness < float(range_values[0]) or roughness > float(range_values[1]) \
	or not is_equal_approx(float(material.get_shader_parameter("relief_strength")), float(expected.relief)) \
	or float(material.get_shader_parameter("color_variation")) <= 0.0 \
	or float(material.get_shader_parameter("filter_start_cycles_per_pixel")) >= float(material.get_shader_parameter("filter_end_cycles_per_pixel")):
		return false
	if str(expected.shader) == SIDING_SHADER_PATH:
		return is_equal_approx(float(material.get_shader_parameter("course_height_m")), float(expected.scale)) \
			and (material.get_shader_parameter("base_color") as Color).a == 1.0 \
			and (material.get_shader_parameter("seam_color") as Color).a == 1.0
	return int(material.get_shader_parameter("field_kind")) == int(expected.field_kind) \
		and is_equal_approx(float(material.get_shader_parameter("primary_scale_m")), float(expected.scale)) \
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
		and is_equal_approx(float(record.get("source_height_m", -1.0)), float(expected.height)) \
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
	var vertices := mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var material := mesh.surface_get_material(0) as StandardMaterial3D
	var is_accepted_trial := AcceptedMaterialRunTrials.matches_record(record)
	var attachment_matches := not node.has_meta("accepted_material_run_trial")
	if is_accepted_trial:
		var accepted_material := mesh.surface_get_material(1) as ShaderMaterial if mesh.get_surface_count() == 2 else null
		var metadata := AcceptedMaterialRunTrials.metadata_for(str(expected.receiver_key))
		attachment_matches = node.has_meta("accepted_material_run_trial") \
			and accepted_material != null and accepted_material.resource_path == str(metadata.material_path) \
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


func _education_29b_remains_generic(builder: WorldChunkBuilder, registry: Dictionary) -> bool:
	if not (registry.explicit_excluded_targets as Dictionary).has("w34313523"):
		return false
	var chunk := JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/x_0__z_-1.json")) as Dictionary
	var result := builder._build_record(_record_for_key(chunk.records, "building:w34313523:wall"), false)
	if not bool(result.get("ok", false)):
		_free_result(result)
		return false
	var node := result.node as Node3D
	var matches := _is_generic_unattached(node)
	node.free()
	return matches


func _prior_accepted_signatures_match(builder: WorldChunkBuilder) -> bool:
	var controls := [
		{"chunk": "res://generated/world/chunks/x_-1__z_1.json", "key": "building:w1249412093:wall", "child": "Hawkins77BrutonFacade", "signature": EXPECTED_HAWKINS_SIGNATURE},
		{"chunk": "res://generated/world/chunks/x_1__z_1.json", "key": "building:w34313540:wall", "child": "Building3600CaliforniaFacade", "signature": EXPECTED_BUILDING_3_SIGNATURE},
		{"chunk": "res://generated/world/chunks/x_-1__z_2.json", "key": "building-composite:w1249412094:w1282547786:wall", "child": "IsleHouse39BrutonHighFacade", "signature": EXPECTED_ISLE_SIGNATURE},
	]
	for value: Variant in controls:
		var control := value as Dictionary
		var chunk := JSON.parse_string(FileAccess.get_file_as_string(str(control.chunk))) as Dictionary
		var result := builder._build_record(_record_for_key(chunk.records, str(control.key)), false)
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
	var body := building_node.get_node_or_null("Collision") as StaticBody3D
	var shape := building_node.get_node_or_null("Collision/Shape") as CollisionShape3D
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
		and body != null and shape != null \
		and body.collision_layer == ((1 << 0) | (1 << 2)) and body.is_in_group("spray_receiver_wall") \
		and (shape.shape as ConcavePolygonShape3D).get_faces().size() == 2046
	building_node.free()
	if not building_matches:
		return false
	var oasis_chunk := JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/x_0__z_1.json")) as Dictionary
	var oasis_result := builder._build_record(_record_for_key(oasis_chunk.records, "building:w291189918:wall"), false)
	if not bool(oasis_result.get("ok", false)):
		_free_result(oasis_result)
		return false
	var oasis_node := oasis_result.node as Node3D
	var oasis_matches := _is_generic_unattached(oasis_node)
	oasis_node.free()
	return oasis_matches


func _is_generic_unattached(node: Node3D) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	return node.get_child_count() == 2 \
		and mesh_instance != null \
		and mesh_instance.mesh.surface_get_material(0).resource_name == "building_wall" \
		and (node.find_children("*Facade*", "Node", true, false) as Array).is_empty() \
		and (node.find_children("*", "NavigationRegion3D", true, false) as Array).is_empty()


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
