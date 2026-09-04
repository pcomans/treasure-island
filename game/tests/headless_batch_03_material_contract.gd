extends SceneTree

const REGISTRY_PATH := "res://game/resources/facades/batch_03_material_registry.json"
const SHADER_PATH := "res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader"
const CORRECTION_SHADER_PATH := "res://game/resources/materials/world/batch_02_04_aperiodic_field.gdshader"
const BATCH_02_REGISTRY_PATH := "res://game/resources/facades/batch_02_material_registry.json"
const BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const MANIFEST_PATH := "res://generated/world/manifest.json"
const FIRE_STATION_REVIEW_PATH := "res://discovery/facades/ACCEPTED_MATERIAL_RUN_TRIALS_ART_REVIEW.md"
const EXPECTED_REGISTRY_SHA256 := "31983ae1529e6248e93ec8d231d2b870de3979778b35eef6019cd19e1a964516"
const EXPECTED_SHADER_SHA256 := "1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5"
const EXPECTED_CORRECTION_SHADER_SHA256 := "324ba33a7c78f4b05038168a479ebb8e875c56704236492a050cee8da8e5f798"
const EXPECTED_BATCH_02_REGISTRY_SHA256 := "e7d1167869640867e2857de1f08df81e878e68230b59feff3fb947b16ff56cb7"
const EXPECTED_BUILDER_SHA256 := "28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682"
const EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const EXPECTED_HAWKINS_SIGNATURE := "d311c103c9273b94fc982588f46bae6ab67ba6be54b0d0a111dd305e39c22219"
const EXPECTED_BUILDING_3_SIGNATURE := "e0b30339bd2ca8642a7b49b5e6153f52017ec4a840e9b0dc1e3841f5373ca5f8"
# Independently emitted by the accepted Isle all-side focused contract.
const EXPECTED_ISLE_SIGNATURE := "e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1"
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_BUILDING_WALL := 1 << 1

const TARGETS := [
	{
		"source_key": "r133347", "receiver_key": "building:r133347:wall",
		"chunk": "res://generated/world/chunks/x_0__z_1.json",
		"material": "res://game/resources/materials/world/personnel_support_detachment/psd_outer.tres",
		"material_hash": "ec103e8a030903e17c3d863e80f6c904fafd0806b24db0385c8aac999c821692",
		"field_kind": 4, "roughness": 0.72, "scale_m": 1.2, "relief": 0.0,
		"segments": 28, "vertex_values": 336, "index_values": 168, "min_y": 3.612, "max_y": 10.051,
	},
	{
		"source_key": "w34313548", "receiver_key": "building:w34313548:wall",
		"chunk": "res://generated/world/chunks/x_1__z_-2.json",
		"material": "res://game/resources/materials/world/fire_training_b600/fire_training_primary.tres",
		"material_hash": "fd1437ed9c0e00508d10d9a3c5d859d9a07c73fb28edc3fad62c473e9d865483",
		"field_kind": 0, "roughness": 0.84, "scale_m": 0.38, "relief": 0.018,
		"segments": 24, "vertex_values": 288, "index_values": 144, "min_y": 3.660, "max_y": 10.064,
	},
	{
		"source_key": "w764313741", "receiver_key": "building:w764313741:wall",
		"chunk": "res://generated/world/chunks/x_0__z_-2.json",
		"material": "res://game/resources/materials/world/fire_station_48/fire_station_48_primary.tres",
		"material_hash": "515135c3d0da6bb8eb8681e69d7e3f7818d896d948fe5dcc7c2bd8c6d076b188",
		"field_kind": 4, "roughness": 0.81, "scale_m": 1.8, "relief": 0.0,
		"segments": 26, "vertex_values": 312, "index_values": 156, "min_y": 3.336, "max_y": 9.501,
	},
]

const BATCH_02_MATERIALS := {
	"res://game/resources/materials/world/building_2/building_2_primary.tres": "e936dc561b653e43eafdef633dc2260c7489a713b5d8da5521b5b118a9b8f8a9",
	"res://game/resources/materials/world/490_avenue_palms/490_thin_brick.tres": "76ae45e057f1d6502c09c6a937d45256c388ee01a67c450a249dffce82cbce39",
	"res://game/resources/materials/world/star_view_court/star_view_grey_base.tres": "c7cd8fc95b76539a9bf20d6aa05cba5b494efdbb27ff93ba74a9a0077f60dc9c",
	"res://game/resources/materials/world/maceo_may/maceo_may_sse_rib.tres": "da68584fa85647d611f825743e3e58164133b51312199fd7955267bc047721bf",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres": "4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5",
	"res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres": "b5e44afcf4feb6df6ffba46f4e3b60a25fa6043c07c12c33e31c483cb2bf2399",
}

const EXCLUDED_TARGETS := [
	{"source_key": "w34313513", "chunk": "res://generated/world/chunks/x_0__z_0.json", "receiver_key": "building:w34313513:wall"},
	{"source_key": "w34313544", "chunk": "res://generated/world/chunks/x_0__z_1.json", "receiver_key": "building:w34313544:wall"},
	{"source_key": "w34313521", "chunk": "res://generated/world/chunks/x_-1__z_0.json", "receiver_key": "building:w34313521:wall"},
	{"source_key": "w109905031", "chunk": "res://generated/world/chunks/x_0__z_-1.json", "receiver_key": "building:w109905031:wall"},
	{"source_key": "w34313514", "chunk": "res://generated/world/chunks/x_0__z_1.json", "receiver_key": "building:w34313514:wall"},
]

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Batch 03 registry bytes drifted.") \
	or not _require(FileAccess.get_sha256(SHADER_PATH) == EXPECTED_SHADER_SHA256, "Shared Batch 02 shader bytes drifted.") \
	or not _require(FileAccess.get_sha256(CORRECTION_SHADER_PATH) == EXPECTED_CORRECTION_SHADER_SHA256, "Rejected-only correction shader bytes drifted.") \
	or not _require(FileAccess.get_sha256(BATCH_02_REGISTRY_PATH) == EXPECTED_BATCH_02_REGISTRY_SHA256, "Accepted Batch 02 registry bytes drifted.") \
	or not _require(FileAccess.get_sha256(BUILDER_PATH) == EXPECTED_BUILDER_SHA256, "Runtime builder drifted outside the exact accepted material run trial implementation.") \
	or not _require(FileAccess.get_sha256(MANIFEST_PATH) == EXPECTED_MANIFEST_SHA256, "Generated manifest bytes drifted.") \
	or not _require(_batch_02_materials_unchanged(), "An accepted Batch 02 material changed.") \
	or not _require(_fire_station_rejection_provenance_matches(), "Independent Fire Station receiver rejection/reversion provenance drifted."):
		_finish()
		return
	var registry := JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH)) as Dictionary
	if not _require(_registry_matches(registry), "Batch 03 identity, provenance, classification, scale, exclusions, or prototype registry policy drifted.") \
	or not _require(_shared_shader_contract_matches(), "Shared shader lost its deterministic opaque derivative-filtered material-field contract."):
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
		var first_result := builder._build_record(record, false)
		var second_result := builder._build_record(record, false)
		if not _require(bool(first_result.get("ok", false)) and bool(second_result.get("ok", false)), "Runtime control build failed for %s." % str(expected.source_key)):
			_free_result(first_result)
			_free_result(second_result)
			_finish()
			return
		var first := first_result.node as Node3D
		var second := second_result.node as Node3D
		if not _require(_generic_receiver_matches(first, record, expected), "Massing/foundation/material/collision/navigation/spray or exact trial lifecycle control failed for %s." % str(expected.source_key)) \
		or not _require(str(expected.source_key) != "w764313741" or _fire_station_reverted_live_receiver(first, record), "Rejected Fire Station exact receiver was not fully restored to its generated placeholder.") \
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
	if not _require(_excluded_targets_remain_generic(builder, registry), "A Batch 03 evidence-blocked target gained an asset or runtime attachment.") \
	or not _require(_prior_accepted_signatures_match(builder), "An accepted Hawkins, Building 3, or Isle House signature changed.") \
	or not _require(_active_building_1_and_oasis_contract(builder), "Building 1 exact active hero or Oasis generic control drifted."):
		_finish()
		return
	print("PASS: three evidence-bounded Batch 03 prototypes remain byte-stable and facade-scale-motif-free; independently rejected Fire Station 48 is restored to one generated placeholder surface across all 26 runs with no live accepted material, while collision, navigation, spray, generated bytes, five evidence-blocked targets, exact-current Building 1 hero, generic Oasis, accepted Chapel/Dormitory trials, and non-targets remain unchanged")
	_finish()


func _registry_matches(registry: Dictionary) -> bool:
	if str(registry.get("schema_version", "")) != "ti.batch-03-material-prototypes/1" \
	or str(registry.get("review_status", "")) != "mechanically_ready_visual_review_blocked" \
	or not str(registry.get("runtime_attachment_policy", "")).begins_with("none;"):
		return false
	var shared := registry.get("shared_shader", {}) as Dictionary
	var correction := registry.get("correction_shader", {}) as Dictionary
	var proof := registry.get("controlled_proof_contract", {}) as Dictionary
	if str(shared.get("path", "")) != SHADER_PATH \
	or str(shared.get("sha256", "")) != EXPECTED_SHADER_SHA256 \
	or bool(shared.get("external_resources", true)) \
	or str(correction.get("path", "")) != CORRECTION_SHADER_PATH \
	or str(correction.get("sha256", "")) != EXPECTED_CORRECTION_SHADER_SHA256 \
	or bool(correction.get("external_resources", true)) \
	or str(proof.get("receiver_kind", "")) != "controlled_flat_proof_panel" \
	or str(proof.get("capture_execution", "")) != "approval_gated_not_executed" \
	or not bool(proof.get("proof_scales_are_reversible_assumptions", false)) \
	or not is_equal_approx(float(proof.get("one_local_unit_m", 0.0)), 1.0):
		return false
	var targets := registry.get("targets", []) as Array
	if targets.size() != TARGETS.size():
		return false
	for index in targets.size():
		var target := targets[index] as Dictionary
		var expected := TARGETS[index] as Dictionary
		if str(target.get("source_key", "")) != str(expected.source_key) \
		or str(target.get("receiver_key", "")) != str(expected.receiver_key) \
		or str(target.get("material_path", "")) != str(expected.material) \
		or str(target.get("classification", "")) != "homogeneous_material_tile" \
		or str(target.get("runtime_attachment", "")) != "prototype_only" \
		or int(target.get("field_kind", -1)) != int(expected.field_kind) \
		or not is_equal_approx(float(target.get("proof_primary_scale_m", 0.0)), float(expected.scale_m)) \
		or not str(target.get("scale_status", "")).ends_with("proof_only") \
		or (target.get("observed_reference_provenance", []) as Array).size() != 2 \
		or (target.get("excluded_motifs", []) as Array).is_empty() \
		or (target.get("placement_blockers", []) as Array).is_empty():
			return false
	var excluded := registry.get("explicit_excluded_targets", {}) as Dictionary
	for expected: Dictionary in EXCLUDED_TARGETS:
		if not excluded.has(str(expected.source_key)):
			return false
	return excluded.size() == 5 and (registry.get("forbidden_content", []) as Array).size() == 10


func _shared_shader_contract_matches() -> bool:
	var source := FileAccess.get_file_as_string(SHADER_PATH)
	var correction := FileAccess.get_file_as_string(CORRECTION_SHADER_PATH)
	if not "render_mode depth_draw_opaque, cull_back" in source \
	or source.count("fwidth(") < 2 \
	or not "METALLIC = 0.0" in source \
	or not "NORMAL_MAP" in source:
		return false
	if not "hash21" in correction or not "value_noise" in correction or correction.count("fwidth(") < 1:
		return false
	for shader_source: String in [source, correction]:
		for forbidden in ["discard", "ALPHA =", "TIME", "SCREEN_TEXTURE", "sampler2D", "vertex displacement"]:
			if forbidden in shader_source:
				return false
	return true


func _batch_02_materials_unchanged() -> bool:
	for path: String in BATCH_02_MATERIALS:
		if FileAccess.get_sha256(path) != str(BATCH_02_MATERIALS[path]):
			return false
	return true


func _fire_station_rejection_provenance_matches() -> bool:
	var review := FileAccess.get_file_as_string(FIRE_STATION_REVIEW_PATH)
	return not review.is_empty() \
		and "Fire Station 48" in review \
		and "REJECT_CORRECTABLE" in review \
		and "May not remain." in review \
		and "broad vertical value bands" in review \
		and "Return this exact live trial to the placeholder" in review


func _material_matches(expected: Dictionary, registry_target: Dictionary) -> bool:
	if FileAccess.get_sha256(str(expected.material)) != str(expected.material_hash):
		return false
	var source := FileAccess.get_file_as_string(str(expected.material))
	for forbidden in ["texture =", "sampler", "window", "door", "portal", "signage", "atlas"]:
		if forbidden in source.to_lower():
			return false
	var material := load(str(expected.material)) as ShaderMaterial
	var expected_shader := CORRECTION_SHADER_PATH if str(expected.source_key) == "w34313548" else SHADER_PATH
	if material == null or material.shader == null or material.shader.resource_path != expected_shader:
		return false
	var roughness := float(material.get_shader_parameter("roughness_value"))
	var range_values := registry_target.roughness_range as Array
	return material.resource_name.ends_with("_prototype") \
		and int(material.get_shader_parameter("field_kind")) == int(expected.field_kind) \
		and is_equal_approx(roughness, float(expected.roughness)) \
		and roughness >= float(range_values[0]) and roughness <= float(range_values[1]) \
		and is_equal_approx(float(material.get_shader_parameter("primary_scale_m")), float(expected.scale_m)) \
		and is_equal_approx(float(material.get_shader_parameter("relief_strength")), float(expected.relief)) \
		and float(material.get_shader_parameter("filter_start_cycles_per_pixel")) < float(material.get_shader_parameter("filter_end_cycles_per_pixel")) \
		and float(material.get_shader_parameter("color_variation")) > 0.0 \
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
		attachment_matches = node.has_meta("accepted_material_run_trial") \
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


func _fire_station_reverted_live_receiver(node: Node3D, record: Dictionary) -> bool:
	var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
	var mesh := mesh_instance.mesh as ArrayMesh if mesh_instance != null else null
	if mesh == null or mesh.get_surface_count() != 1:
		return false
	var material := mesh.surface_get_material(0) as StandardMaterial3D
	var indices := mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array
	return str(record.get("object_key", "")) == "building:w764313741:wall" \
		and record.source_keys == ["w764313741"] \
		and not AcceptedMaterialRunTrials.matches_record(record) \
		and AcceptedMaterialRunTrials.metadata_for("building:w764313741:wall").is_empty() \
		and not node.has_meta("accepted_material_run_trial") \
		and mesh.surface_get_name(0) == "generated_record" \
		and material != null and material.resource_name == "building_wall" \
		and indices.size() == (record.indices as Array).size() \
		and mesh.get_faces().size() == (record.indices as Array).size() \
		and (node.find_children("*", "MeshInstance3D", true, false) as Array).size() == 1


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


func _excluded_targets_remain_generic(builder: WorldChunkBuilder, registry: Dictionary) -> bool:
	var excluded := registry.explicit_excluded_targets as Dictionary
	for value: Variant in EXCLUDED_TARGETS:
		var control := value as Dictionary
		if not excluded.has(str(control.source_key)):
			return false
		var chunk := JSON.parse_string(FileAccess.get_file_as_string(str(control.chunk))) as Dictionary
		var result := builder._build_record(_record_for_key(chunk.records, str(control.receiver_key)), false)
		if not bool(result.get("ok", false)):
			_free_result(result)
			return false
		var node := result.node as Node3D
		var matches := _is_generic_unattached(node)
		node.free()
		if not matches:
			return false
	return true


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
