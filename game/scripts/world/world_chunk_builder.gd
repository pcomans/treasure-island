class_name WorldChunkBuilder
extends RefCounted

const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1
const WESTERN_BRIDGE_REPLACEMENT_MAX_X_M := 500.0
const POLYHAVEN_DEFAULT_NORMAL_STRENGTH := 0.2
const HAWKINS_MASSING := preload("res://game/scripts/world/massing/hawkins_77_bruton_massing.gd")
const BUILDING_3_MASSING := preload("res://game/scripts/world/massing/building_3_600_california_massing.gd")
const NAVY_CHAPEL_187_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd")
const ISLE_HOUSE_HIGH_FACADE_SCENE := preload("res://game/scenes/world/facades/isle_house/isle_house_high_facade.tscn")
const ISLE_HOUSE_LOW_LIVE_ATTACHMENT := preload("res://game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd")
const D1_B201_LIVE_ATTACHMENT := preload("res://game/scripts/world/facades/d1_b201_live_attachment.gd")
const ACCEPTED_MATERIAL_RUN_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const W34313564_LIVE_MODULES := preload("res://game/scripts/world/facades/w34313564_live_modules.gd")
const W34313515_LIVE_MODULES := preload("res://game/scripts/world/facades/w34313515_live_modules.gd")
const W291196370_LIVE_MODULES := preload("res://game/scripts/world/facades/w291196370_live_modules.gd")
const W34313520_LIVE_MODULES := preload("res://game/scripts/world/facades/w34313520_live_modules.gd")
const W34313525_LIVE_MODULES := preload("res://game/scripts/world/facades/w34313525_live_modules.gd")
const BUILDING_1_HERO_MODEL := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const POLYHAVEN_TEXTURE_SETS := {
	"clean_asphalt": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_rough_1k.jpg"),
		"source_dimension_m": 2.1,
		"repeat_dimension_m": 2.1,
	},
	"concrete_pavement": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_rough_1k.jpg"),
		"source_dimension_m": 1.8,
		"repeat_dimension_m": 1.8,
	},
	"concrete_floor_03": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_rough_1k.jpg"),
		"source_dimension_m": 2.5,
		"repeat_dimension_m": 2.5,
	},
	"sparse_grass": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_rough_1k.jpg"),
		"source_dimension_m": 2.0,
		"repeat_dimension_m": 5.0,
	},
	"plaster_grey_04": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_rough_1k.jpg"),
		"source_dimension_m": 1.5,
		"repeat_dimension_m": 0.75,
		"normal_strength": 0.1,
	},
	"bitumen": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/bitumen/bitumen_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/bitumen/bitumen_rough_1k.jpg"),
		"source_dimension_m": 20.0,
		"repeat_dimension_m": 10.0,
	},
}
const POLYHAVEN_MATERIAL_TEXTURE_SET := {
	"road_path": "clean_asphalt",
	"road_path_pedestrian": "concrete_pavement",
	"major_area_paved": "concrete_floor_03",
	"land_ground": "sparse_grass",
	"major_area_landuse": "sparse_grass",
	"major_area_leisure": "sparse_grass",
	"context_ybi": "sparse_grass",
	"building_wall": "plaster_grey_04",
	"building_part_wall": "plaster_grey_04",
	"building_roof": "bitumen",
	"building_part_roof": "bitumen",
}

var _materials: Dictionary = {}


func build_chunk(chunk: Dictionary, category_parents: Dictionary) -> Dictionary:
	var chunk_root := Node3D.new()
	chunk_root.name = str(chunk.chunk_id).validate_node_name()
	# Claim the target chunk before per-row dispatch so a drifted/missing B201
	# wall cannot silently fall through to generic construction.
	var b201_chunk_validation := D1_B201_LIVE_ATTACHMENT.validate_chunk_records(chunk)
	if not bool(b201_chunk_validation.get("ok", false)):
		chunk_root.free()
		return b201_chunk_validation
	# Pair-preflight the actual supplied chunk before any generic node exists.
	# This prevents either Chapel row from borrowing its mate from disk or from
	# being suppressed alone when the other row is missing or drifted.
	var chapel_pair := NAVY_CHAPEL_187_LIVE_REPLACEMENT.prepare_chunk_records(chunk.records as Array)
	if not bool(chapel_pair.get("ok", false)):
		chunk_root.free()
		return chapel_pair
	var chapel_plan := NAVY_CHAPEL_187_LIVE_REPLACEMENT.build_chunk_plan(chapel_pair)
	if not bool(chapel_plan.get("ok", false)):
		chunk_root.free()
		return chapel_plan
	var report := {
		"ok": true,
		"node": chunk_root,
		"mesh_instances": 0,
		"surfaces": 0,
		"triangles": 0,
		"static_bodies": 0,
		"shapes": 0,
		"source_keys": {},
	}
	for record_value: Variant in chunk.records:
		var record: Dictionary = record_value
		var parent_key := _parent_key_for_feature(str(record.feature_kind))
		if not category_parents.has(parent_key):
			NAVY_CHAPEL_187_LIVE_REPLACEMENT.free_unconsumed(chapel_plan)
			chunk_root.free()
			return {"ok": false, "code": "builder_parent", "message": "Missing world category parent %s." % parent_key, "source_keys": record.source_keys}
		var record_result := _build_record(record, false, chapel_plan)
		if not record_result.ok:
			NAVY_CHAPEL_187_LIVE_REPLACEMENT.free_unconsumed(chapel_plan)
			chunk_root.free()
			return record_result
		var record_node: Node3D = record_result.node
		var category_proxy := Node3D.new()
		category_proxy.name = "%s__%s" % [str(chunk.chunk_id), str(record.object_key).validate_node_name()]
		category_proxy.add_child(record_node)
		category_proxy.set_meta("target_parent", category_parents[parent_key])
		chunk_root.add_child(category_proxy)
		report.mesh_instances += int(record_result.get("mesh_instances", 1))
		report.surfaces += int(record_result.get("surfaces", 1))
		report.triangles += int(record_result.triangles)
		report.static_bodies += int(record_result.get("static_bodies", 1 if str(record.collision_kind) == "world_solid" else 0))
		report.shapes += int(record_result.get("shapes", 1 if str(record.collision_kind) == "world_solid" else 0))
		for key_value: Variant in record.source_keys:
			report.source_keys[str(key_value)] = true
	if not NAVY_CHAPEL_187_LIVE_REPLACEMENT.plan_was_fully_consumed(chapel_plan):
		NAVY_CHAPEL_187_LIVE_REPLACEMENT.free_unconsumed(chapel_plan)
		chunk_root.free()
		return {"ok": false, "code": "navy_chapel_187_live_unconsumed_pair", "message": "The supplied Chapel pair was not consumed exactly once.", "source_keys": ["w291189336"]}
	return report


func attach_built_chunk(report: Dictionary, _category_parents: Dictionary) -> void:
	var chunk_root: Node3D = report.node
	while chunk_root.get_child_count() > 0:
		var proxy := chunk_root.get_child(0) as Node3D
		chunk_root.remove_child(proxy)
		var target: Node3D = proxy.get_meta("target_parent") as Node3D
		proxy.set_meta("target_parent", null)
		target.add_child(proxy)
	chunk_root.free()


func build_context(context: Dictionary, context_parents: Dictionary) -> Dictionary:
	var staging := Node3D.new()
	staging.name = "ValidatedContext"
	var report := {
		"ok": true,
		"node": staging,
		"mesh_instances": 0,
		"surfaces": 0,
		"triangles": 0,
		"static_bodies": 0,
		"shapes": 0,
		"source_keys": {},
	}
	var context_records: Array = context.records.duplicate()
	context_records.append_array(context.boundary_attached_visuals)
	for record_value: Variant in context_records:
		var record: Dictionary = record_value
		var adapted := record.duplicate(true)
		adapted["feature_kind"] = str(record.context_kind)
		var record_result := _build_record(adapted, true)
		if not record_result.ok:
			staging.free()
			return record_result
		var proxy := Node3D.new()
		proxy.name = str(record.object_key).validate_node_name()
		proxy.add_child(record_result.node)
		proxy.set_meta("target_parent", context_parents[str(record.context_kind)])
		staging.add_child(proxy)
		report.mesh_instances += int(record_result.get("mesh_instances", 1))
		report.surfaces += int(record_result.get("surfaces", 1))
		report.triangles += int(record_result.triangles)
		for key_value: Variant in record.source_keys:
			report.source_keys[str(key_value)] = true
	return report


func _build_record(record: Dictionary, is_context: bool, chapel_plan: Dictionary = {}) -> Dictionary:
	# Building 1's generated 20 m slab and terrain-level tower are source-valid
	# horizontal placeholders but visually and physically wrong in the vertical
	# dimension.  Intercept all four independently keyed records before generic
	# mesh/collision construction so no invisible legacy surfaces survive.
	if not is_context and BUILDING_1_HERO_MODEL.matches_record(record):
		return BUILDING_1_HERO_MODEL.build_record(record)
	if not is_context and HAWKINS_MASSING.matches_record(record):
		return HAWKINS_MASSING.build_record(
			record,
			_material_for(str(record.material_key), str(record.feature_kind), false)
		)
	# Building 3's frozen horizontal receiver remains authoritative, while its
	# flat vertical placeholder obscures the landmark hangar family. Replace
	# wall and roof together before generic collision is ever constructed.
	if not is_context and BUILDING_3_MASSING.matches_record(record):
		return BUILDING_3_MASSING.build_record(
			record,
			_material_for(str(record.material_key), str(record.feature_kind), false)
		)
	# Chapel 187 is a paired wall+roof replacement. The plan constructs approved
	# visuals once and splits wall spray collision from roof/cap/cross landing
	# collision; both exact rows are consumed without generic fallback or stack.
	if not is_context and NAVY_CHAPEL_187_LIVE_REPLACEMENT.claims_record(record):
		return NAVY_CHAPEL_187_LIVE_REPLACEMENT.consume_record(record, chapel_plan)
	var b201_prepared: Dictionary = {}
	if not is_context and D1_B201_LIVE_ATTACHMENT.claims_record(record):
		b201_prepared = D1_B201_LIVE_ATTACHMENT.prepare(record)
		if not bool(b201_prepared.get("ok", false)):
			return b201_prepared
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for index in range(0, record.vertices.size(), 3):
		vertices.append(Vector3(float(record.vertices[index]), float(record.vertices[index + 1]), float(record.vertices[index + 2])))
	for index in range(0, record.normals.size(), 3):
		normals.append(Vector3(float(record.normals[index]), float(record.normals[index + 1]), float(record.normals[index + 2])))
	for index in range(0, record.uvs.size(), 2):
		uvs.append(Vector2(float(record.uvs[index]), float(record.uvs[index + 1])))
	if not b201_prepared.is_empty():
		uvs = D1_B201_LIVE_ATTACHMENT.host_uvs(record, b201_prepared)
		if uvs.size() != vertices.size():
			return {"ok": false, "code": "d1_b201_live_host_uv", "message": "Prepared B201 host UVs did not cover the supplied wall.", "source_keys": record.source_keys}
	# The generated contract stores counterclockwise triangles around its
	# outward normals. Godot treats clockwise winding as front-facing, so adapt
	# every triplet once at runtime while preserving the generated bytes/normals.
	for index in range(0, record.indices.size(), 3):
		var first := int(record.indices[index])
		var second := int(record.indices[index + 1])
		var third := int(record.indices[index + 2])
		# The old western span is a disconnected component west of X=500 m.
		# Its imported replacement is owned by world_root.tscn; retain the modern
		# eastern-span component from the same generated context record.
		if is_context and str(record.feature_kind) == "bay_bridge" \
		and vertices[first].x < WESTERN_BRIDGE_REPLACEMENT_MAX_X_M \
		and vertices[second].x < WESTERN_BRIDGE_REPLACEMENT_MAX_X_M \
		and vertices[third].x < WESTERN_BRIDGE_REPLACEMENT_MAX_X_M:
			continue
		indices.append(first)
		indices.append(third)
		indices.append(second)

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	if not uvs.is_empty():
		arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	if POLYHAVEN_MATERIAL_TEXTURE_SET.has(str(record.material_key)) and not uvs.is_empty():
		arrays[Mesh.ARRAY_TANGENT] = _tangents_for(vertices, normals, uvs, indices)
	var placeholder_material := _material_for(str(record.material_key), str(record.feature_kind), is_context)
	var surface_plan: Dictionary
	if not b201_prepared.is_empty():
		surface_plan = D1_B201_LIVE_ATTACHMENT.partition_host(record, indices, placeholder_material, b201_prepared)
	elif not is_context:
		surface_plan = ACCEPTED_MATERIAL_RUN_TRIALS.partition(record, indices, placeholder_material)
	else:
		surface_plan = {"ok": true, "surfaces": [{"name": "generated_record", "indices": indices, "material": placeholder_material}]}
	if not bool(surface_plan.get("ok", false)):
		return surface_plan
	var mesh := ArrayMesh.new()
	for surface_value: Variant in surface_plan.surfaces:
		var surface := surface_value as Dictionary
		arrays[Mesh.ARRAY_INDEX] = surface.indices as PackedInt32Array
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var surface_index := mesh.get_surface_count() - 1
		mesh.surface_set_name(surface_index, str(surface.name))
		mesh.surface_set_material(surface_index, surface.material as Material)

	var root := Node3D.new()
	root.name = str(record.object_key).validate_node_name()
	root.set_meta("derived_object_key", str(record.object_key))
	root.set_meta("source_keys", record.source_keys.duplicate())
	root.set_meta("feature_kind", str(record.feature_kind))
	if not b201_prepared.is_empty() and surface_plan.has("metadata"):
		root.set_meta("d1_b201_host_partition", (surface_plan.metadata as Dictionary).duplicate(true))
	elif surface_plan.has("metadata"):
		root.set_meta("accepted_material_run_trial", (surface_plan.metadata as Dictionary).duplicate(true))
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	mesh_instance.mesh = mesh
	mesh_instance.layers = RENDER_BUILDING_WALL if str(record.receiver_kind) == "building_wall" else RENDER_WORLD_VISIBLE
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF \
		if str(record.feature_kind) in ["road_path", "major_area", "terrain_overlay"] \
		else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	root.add_child(mesh_instance)
	var mesh_instances := 1
	var surfaces := mesh.get_surface_count()
	var triangle_count := int(indices.size() / 3)

	if not is_context and str(record.collision_kind) == "world_solid":
		var body := StaticBody3D.new()
		body.name = "Collision"
		body.collision_layer = PHYSICS_WORLD_SOLID
		if bool(record.opaque):
			body.collision_layer |= PHYSICS_SPRAY_SURFACE
		body.collision_mask = 0
		body.set_meta("receiver_kind", str(record.receiver_kind))
		body.set_meta("opaque", bool(record.opaque))
		body.set_meta("derived_object_key", str(record.object_key))
		body.set_meta("source_keys", record.source_keys.duplicate())
		if str(record.receiver_kind) == "building_wall":
			body.add_to_group("spray_receiver_wall")
		var faces := PackedVector3Array()
		for index_value: int in indices:
			faces.append(vertices[index_value])
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(faces)
		shape.set_meta("receiver_kind", str(record.receiver_kind))
		shape.set_meta("opaque", bool(record.opaque))
		shape.set_meta("derived_object_key", str(record.object_key))
		shape.set_meta("source_keys", record.source_keys.duplicate())
		var collision_shape := CollisionShape3D.new()
		collision_shape.name = "Shape"
		collision_shape.shape = shape
		body.add_child(collision_shape)
		root.add_child(body)

	if not is_context and W34313564_LIVE_MODULES.matches_record(record):
		var live_module_result := W34313564_LIVE_MODULES.build(record)
		if not bool(live_module_result.get("ok", false)):
			root.free()
			return live_module_result
		root.add_child(live_module_result.node as Node3D)
		root.set_meta("w34313564_live_modules", (live_module_result.metadata as Dictionary).duplicate(true))
		mesh_instances += int(live_module_result.mesh_instances)
		surfaces += int(live_module_result.surfaces)
		triangle_count += int(live_module_result.triangles)

	if not is_context and W34313515_LIVE_MODULES.matches_record(record):
		var live_module_result := W34313515_LIVE_MODULES.build(record)
		if not bool(live_module_result.get("ok", false)):
			root.free()
			return live_module_result
		root.add_child(live_module_result.node as Node3D)
		root.set_meta("w34313515_live_modules", (live_module_result.metadata as Dictionary).duplicate(true))
		mesh_instances += int(live_module_result.mesh_instances)
		surfaces += int(live_module_result.surfaces)
		triangle_count += int(live_module_result.triangles)

	if not is_context and W291196370_LIVE_MODULES.matches_record(record):
		var live_module_result := W291196370_LIVE_MODULES.build(record)
		if not bool(live_module_result.get("ok", false)):
			root.free()
			return live_module_result
		root.add_child(live_module_result.node as Node3D)
		root.set_meta("w291196370_live_modules", (live_module_result.metadata as Dictionary).duplicate(true))
		mesh_instances += int(live_module_result.mesh_instances)
		surfaces += int(live_module_result.surfaces)
		triangle_count += int(live_module_result.triangles)

	if not is_context and W34313520_LIVE_MODULES.matches_record(record):
		var live_module_result := W34313520_LIVE_MODULES.build(record)
		if not bool(live_module_result.get("ok", false)):
			root.free()
			return live_module_result
		root.add_child(live_module_result.node as Node3D)
		root.set_meta("w34313520_live_modules", (live_module_result.metadata as Dictionary).duplicate(true))
		mesh_instances += int(live_module_result.mesh_instances)
		surfaces += int(live_module_result.surfaces)
		triangle_count += int(live_module_result.triangles)

	if not is_context and W34313525_LIVE_MODULES.matches_record(record):
		var live_module_result := W34313525_LIVE_MODULES.build(record)
		if not bool(live_module_result.get("ok", false)):
			root.free()
			return live_module_result
		root.add_child(live_module_result.node as Node3D)
		root.set_meta("w34313525_live_modules", (live_module_result.metadata as Dictionary).duplicate(true))
		mesh_instances += int(live_module_result.mesh_instances)
		surfaces += int(live_module_result.surfaces)
		triangle_count += int(live_module_result.triangles)

	if not is_context and IsleHouse39BrutonHighFacade.matches_target(record):
		var isle_house_facade := ISLE_HOUSE_HIGH_FACADE_SCENE.instantiate() as IsleHouse39BrutonHighFacade
		var isle_house_result := isle_house_facade.configure(record)
		if not bool(isle_house_result.get("ok", false)):
			isle_house_facade.free()
			root.free()
			return {
				"ok": false,
				"code": "isle_house_high_facade_contract",
				"message": str(isle_house_result.get("message", "Could not build target-specific Isle House high facade.")),
				"source_keys": record.source_keys,
			}
		root.add_child(isle_house_facade)
	if not is_context and ISLE_HOUSE_LOW_LIVE_ATTACHMENT.matches_record(record):
		var isle_house_low_result := ISLE_HOUSE_LOW_LIVE_ATTACHMENT.build(record)
		if not bool(isle_house_low_result.get("ok", false)):
			root.free()
			return isle_house_low_result
		root.add_child(isle_house_low_result.node as Node3D)
		root.set_meta("isle_house_low_live_attachment", (isle_house_low_result.metadata as Dictionary).duplicate(true))
		mesh_instances += int(isle_house_low_result.mesh_instances)
		surfaces += int(isle_house_low_result.surfaces)
		triangle_count += int(isle_house_low_result.triangles)
	# B201 retains its exact generic wall mesh/collider/spray receiver. Only the
	# reviewed public runs receive a host-material partition; all added detail is
	# non-coplanar render-only geometry, claimed and validated fail closed.
	if not b201_prepared.is_empty():
		var b201_result := D1_B201_LIVE_ATTACHMENT.build_prepared(record, b201_prepared)
		if not bool(b201_result.get("ok", false)):
			root.free()
			return b201_result
		root.add_child(b201_result.node as Node3D)
		root.set_meta("d1_b201_live_attachment", (b201_result.metadata as Dictionary).duplicate(true))
		mesh_instances += int(b201_result.mesh_instances)
		surfaces += int(b201_result.surfaces)
		triangle_count += int(b201_result.triangles)
	return {
		"ok": true,
		"node": root,
		"mesh_instances": mesh_instances,
		"surfaces": surfaces,
		"triangles": triangle_count,
	}

func _material_for(material_key: String, feature_kind: String, is_context: bool) -> StandardMaterial3D:
	var cache_key := "%s|%s|%s" % [material_key, feature_kind, is_context]
	if _materials.has(cache_key):
		return _materials[cache_key]
	var material := StandardMaterial3D.new()
	material.resource_name = material_key
	material.albedo_color = _color_for(material_key, feature_kind, is_context)
	material.roughness = 0.92
	# Context remains double-sided because it is distant, non-colliding scenery.
	if is_context:
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if feature_kind == "road_path":
		material.roughness = 1.0
	_apply_polyhaven_textures(material, material_key)
	_materials[cache_key] = material
	return material


func _apply_polyhaven_textures(material: StandardMaterial3D, material_key: String) -> void:
	if not POLYHAVEN_MATERIAL_TEXTURE_SET.has(material_key):
		return
	var texture_set_key := str(POLYHAVEN_MATERIAL_TEXTURE_SET[material_key])
	var texture_set: Dictionary = POLYHAVEN_TEXTURE_SETS[texture_set_key]
	var albedo_texture := texture_set.albedo as Texture2D
	var normal_texture := texture_set.normal as Texture2D
	var roughness_texture := texture_set.roughness as Texture2D
	assert(albedo_texture != null and normal_texture != null and roughness_texture != null, "Approved Poly Haven texture set %s did not load." % texture_set_key)
	material.albedo_color = _polyhaven_tint_for(material_key, material.albedo_color)
	material.albedo_texture = albedo_texture
	material.normal_enabled = true
	material.normal_texture = normal_texture
	material.normal_scale = float(texture_set.get("normal_strength", POLYHAVEN_DEFAULT_NORMAL_STRENGTH))
	material.roughness_texture = roughness_texture
	var uv_scale := 10.0 / float(texture_set.repeat_dimension_m)
	material.uv1_scale = Vector3(uv_scale, uv_scale, 1.0)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	material.set_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT, true)
	material.heightmap_enabled = false


func _polyhaven_tint_for(material_key: String, fallback: Color) -> Color:
	match material_key:
		"road_path":
			return Color("b0b4b8")
		"road_path_pedestrian":
			return Color("d8d6cf")
		"major_area_paved":
			return Color("adb0ae")
		"land_ground":
			return Color("f2f3ee")
		"major_area_landuse":
			return Color("f4ebdd")
		"major_area_leisure":
			return Color("eaf8e5")
		"context_ybi":
			return Color("d2d8cb")
		"building_wall", "building_part_wall":
			return Color("f7f2eb")
		"building_roof", "building_part_roof":
			return Color("d8d4d0")
	return fallback


func _tangents_for(vertices: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array) -> PackedFloat32Array:
	var tangent_sums := PackedVector3Array()
	var bitangent_sums := PackedVector3Array()
	tangent_sums.resize(vertices.size())
	bitangent_sums.resize(vertices.size())
	for offset in range(0, indices.size(), 3):
		var first := indices[offset]
		var second := indices[offset + 1]
		var third := indices[offset + 2]
		var edge_one := vertices[second] - vertices[first]
		var edge_two := vertices[third] - vertices[first]
		var uv_one := uvs[second] - uvs[first]
		var uv_two := uvs[third] - uvs[first]
		var determinant := uv_one.x * uv_two.y - uv_one.y * uv_two.x
		if absf(determinant) <= 0.00000001:
			continue
		var inverse := 1.0 / determinant
		var tangent := (edge_one * uv_two.y - edge_two * uv_one.y) * inverse
		var bitangent := (edge_two * uv_one.x - edge_one * uv_two.x) * inverse
		for vertex_index in [first, second, third]:
			tangent_sums[vertex_index] += tangent
			bitangent_sums[vertex_index] += bitangent

	var tangents := PackedFloat32Array()
	tangents.resize(vertices.size() * 4)
	for vertex_index in vertices.size():
		var normal := normals[vertex_index].normalized()
		var tangent := tangent_sums[vertex_index] - normal * normal.dot(tangent_sums[vertex_index])
		if tangent.length_squared() <= 0.00000001:
			var reference_axis := Vector3.UP if absf(normal.y) < 0.999 else Vector3.RIGHT
			tangent = reference_axis.cross(normal)
		tangent = tangent.normalized()
		var handedness := -1.0 if normal.cross(tangent).dot(bitangent_sums[vertex_index]) < 0.0 else 1.0
		var tangent_offset := vertex_index * 4
		tangents[tangent_offset] = tangent.x
		tangents[tangent_offset + 1] = tangent.y
		tangents[tangent_offset + 2] = tangent.z
		tangents[tangent_offset + 3] = handedness
	return tangents


func _color_for(material_key: String, feature_kind: String, is_context: bool) -> Color:
	if is_context:
		if feature_kind == "ybi":
			return Color("66765c")
		if feature_kind == "boundary_attached_visual":
			return Color("718b8c") if "marina" in material_key else Color("a4947e")
		return Color("bbb7af")
	match feature_kind:
		"land_ground":
			return Color("8ca777")
		"road_path":
			if material_key == "road_path_pedestrian":
				return Color("8b918e")
			return Color("555b60")
		"building_wall", "building_part_wall":
			return Color("c6b79f")
		"building_roof", "building_part_roof":
			return Color("827468")
		"terrain_overlay":
			if "sand" in material_key:
				return Color("d7c78e")
			if "wet" in material_key or "marina" in material_key:
				return Color("78a49a")
			if "pier" in material_key:
				return Color("8b8174")
			if "breakwater" in material_key:
				return Color("777a73")
			return Color("8fb486")
		"major_area":
			if "paved" in material_key:
				return Color("707573")
			if "amenity" in material_key:
				return Color("a7a597")
			if "landuse" in material_key:
				return Color("a99b78")
			return Color("79a66d")
		"boundary_blocker":
			return Color(0.0, 0.0, 0.0, 0.0)
	return Color("aeb4ad")


func _parent_key_for_feature(feature_kind: String) -> String:
	if feature_kind == "road_path":
		return "roads"
	if feature_kind.begins_with("building_") or feature_kind.begins_with("building_part_"):
		return "buildings"
	return "ground"
