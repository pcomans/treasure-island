class_name YbiVegetationBuilder
extends RefCounted
## Yerba Buena Island's procedural trees and scrub (generated/world/context.json
## ybi_vegetation, placed by tools/lib/ybi-context-generation.mjs), drawn with the
## street-vegetation kit's species under ContextWorld/YerbaBuenaIsland. YBI is
## non-playable context: nothing here collides or takes a spray.
##
## Plants within the vegetation's near_limit_m of the playable boundary (the
## generator marks them near) can come within a plant's close range of a player on
## the causeway, so they get the kit's three detail levels in TREE_CELL_M cells, as
## the street vegetation does: a tree's far impostor drawn on to FAR_END_M, with the
## kit's shadow meshes; a shrub's levels to the kit's own last range. Every other
## plant is always at least that far from the player, so it is only ever the far
## impostor: one MultiMesh per species variant for the whole island (a handful of
## draws), a tree's drawn to FAR_END_M and a scrub clump's to SHRUB_FAR_END_M.

const KIT := preload("res://game/scripts/world/street_vegetation_kit.gd")
const TREE_CELL_M := 16.0
const SHADOW_CELL_M := 48.0
const RENDER_WORLD_VISIBLE := 1
## How far a YBI tree's impostor draws: past Treasure Island's far end from YBI.
const FAR_END_M := 4000.0
## How far a far scrub clump's impostor draws: across Treasure Island's west and south
## shores; further off a clump is well under a pixel and the ground cover carries it.
const SHRUB_FAR_END_M := 2000.0
const FIELDS := ["prop", "variant", "x", "y", "z", "yaw_radians", "scale", "stretch", "near"]


static func _cell(position: Vector3, size_m: float) -> String:
	return "%d_%d" % [floori(position.x / size_m), floori(position.z / size_m)]


## What is wrong with a ybi_vegetation document, or "" (the world contract asks too).
static func document_error(document: Variant) -> String:
	if not document is Dictionary:
		return "ybi_vegetation is not an object"
	var doc: Dictionary = document
	if str(doc.get("schema_version", "")) != "ti.ybi-vegetation/1" or doc.get("fields", null) != FIELDS:
		return "ybi_vegetation schema or fields drift"
	if not doc.get("props", null) is Array or not doc.get("instances", null) is Array or (doc.instances as Array).is_empty():
		return "ybi_vegetation has no props or instances"
	if not doc.get("tints", null) is Array or (doc.tints as Array).size() != (doc.props as Array).size():
		return "ybi_vegetation needs one tint per prop"
	for tint: Variant in doc.tints:
		if not tint is Array or (tint as Array).size() != 3:
			return "ybi_vegetation tint is not three numbers"
		for value: Variant in tint:
			if not (value is float or value is int) or float(value) < 0.0 or float(value) > 1.5:
				return "ybi_vegetation tint is out of range"
	for prop: Variant in doc.props:
		if not KIT.PROPS.has(str(prop)) or KIT.is_low_plant(str(prop)) or KIT.is_hedge(str(prop)):
			return "ybi_vegetation names a prop the kit cannot stand: %s" % prop
	for row_value: Variant in doc.instances:
		if not row_value is Array or (row_value as Array).size() != FIELDS.size():
			return "ybi_vegetation instance is not a %d-field row" % FIELDS.size()
		var row: Array = row_value
		for value: Variant in row:
			if not (value is float or value is int) or not is_finite(float(value)):
				return "ybi_vegetation instance has a non-finite field"
		var prop_index := int(row[0])
		if float(row[0]) != floorf(float(row[0])) or prop_index < 0 or prop_index >= (doc.props as Array).size():
			return "ybi_vegetation instance names no prop"
		var prop := str(doc.props[prop_index])
		if float(row[1]) != floorf(float(row[1])) or int(row[1]) < 0 or int(row[1]) >= KIT.variant_count(prop):
			return "ybi_vegetation instance names no %s variant" % prop
		if float(row[6]) < 0.4 or float(row[6]) > 1.8 or float(row[7]) < 1.0 or float(row[7]) > 1.6 \
		or absf(float(row[5])) > PI + 0.001 or not (int(row[8]) == 0 or int(row[8]) == 1):
			return "ybi_vegetation instance scale, stretch, yaw or near flag is out of range"
	return ""


## Builds the vegetation node: {ok, node, trees, shrubs, multimesh_batches, near} or
## {ok: false, code, message}. kit: a street-vegetation kit to share (its built
## species are reused), or null for a new one.
func build(document: Dictionary, kit: RefCounted = null) -> Dictionary:
	var problem := document_error(document)
	if problem != "":
		return {"ok": false, "code": "ybi_vegetation", "message": problem, "source_keys": []}
	if kit == null:
		kit = KIT.new()
	var root := Node3D.new()
	root.name = "Vegetation"
	# key -> {levels, cells: {cell -> [Transform3D]}}; far key -> {mesh, end_m, transforms}
	var near_batches: Dictionary = {}
	var far_batches: Dictionary = {}
	var shadows: Dictionary = {}
	var trees := 0
	var shrubs := 0
	var near_count := 0
	var props: Array = document.props
	for row: Array in document.instances:
		var prop := str(props[int(row[0])])
		var variant := int(row[1])
		var proto: Dictionary = kit.prototype(prop, variant)
		if not proto.ok:
			root.free()
			return {"ok": false, "code": "ybi_vegetation", "message": str(proto.message), "source_keys": []}
		# A stretched crown (the blue gums') stands taller by the stretch's root and narrower by it.
		var root_stretch := sqrt(float(row[7]))
		var size := Vector3(1.0 / root_stretch, root_stretch, 1.0 / root_stretch) * float(row[6])
		var placement := Transform3D(Basis(Vector3.UP, float(row[5])).scaled(size), Vector3(float(row[2]), float(row[3]), float(row[4])))
		var key := "%s_%d" % [prop, variant]
		var levels: Array = proto.levels
		var shrub := KIT.is_shrub(prop)
		if shrub:
			shrubs += 1
		else:
			trees += 1
		if int(row[8]) == 1:
			# Near plants: the kit's detail levels in small cells.
			near_count += 1
			if not near_batches.has(key):
				near_batches[key] = {"levels": levels, "far_end": FAR_END_M if not shrub else float((levels[-1] as Dictionary).end_m), "cells": {}}
			var cells: Dictionary = near_batches[key].cells
			var cell := _cell(placement.origin, TREE_CELL_M)
			if not cells.has(cell):
				cells[cell] = []
			(cells[cell] as Array).append(placement)
			if proto.has("shadow") and not shrub:
				if not shadows.has(key):
					shadows[key] = {"mesh": proto.shadow.mesh, "end_m": proto.shadow.end_m, "cells": {}}
				var shadow_cells: Dictionary = shadows[key].cells
				var shadow_cell := _cell(placement.origin, SHADOW_CELL_M)
				if not shadow_cells.has(shadow_cell):
					shadow_cells[shadow_cell] = []
				(shadow_cells[shadow_cell] as Array).append(placement)
			continue
		var far_level: Dictionary = levels[-1]
		if str(far_level.name) != "far":
			root.free()
			return {"ok": false, "code": "ybi_vegetation", "message": "%s has no far impostor for a far YBI plant" % key, "source_keys": []}
		if not far_batches.has(key):
			far_batches[key] = {"mesh": far_level.mesh, "transforms": [], "tint": document.tints[int(row[0])], "end_m": SHRUB_FAR_END_M if shrub else FAR_END_M}
		(far_batches[key].transforms as Array).append(placement)
	var multimeshes := 0
	var near_keys: Array = near_batches.keys()
	near_keys.sort()
	for key: String in near_keys:
		var batch: Dictionary = near_batches[key]
		var levels: Array = batch.levels
		var cell_keys: Array = (batch.cells as Dictionary).keys()
		cell_keys.sort()
		for cell: String in cell_keys:
			var transforms: Array = batch.cells[cell]
			var bounds := _bounds(transforms, levels.map(func(level: Dictionary) -> Mesh: return level.mesh))
			for level_index in levels.size():
				var level: Dictionary = levels[level_index]
				var last := level_index == levels.size() - 1
				var end_m := float(batch.far_end) if last else float(level.end_m)
				root.add_child(_instance("%s_%s__c%s" % [key, level.name, cell], level.mesh, transforms, bounds.box, float(level.begin_m), end_m + (ceilf(float(bounds.slack)) if last else 0.0), bool(level.shadow)))
				multimeshes += 1
	var far_keys: Array = far_batches.keys()
	far_keys.sort()
	for key: String in far_keys:
		var batch: Dictionary = far_batches[key]
		var bounds := _bounds(batch.transforms, [batch.mesh])
		# One draw for the whole island: its plants are never near enough to change level.
		var far := _instance("%s_far__island" % key, batch.mesh, batch.transforms, bounds.box, 0.0, float(batch.end_m) + ceilf(float(bounds.slack)), false)
		far.material_override = _tinted(batch.mesh, batch.tint)
		root.add_child(far)
		multimeshes += 1
	var shadow_keys: Array = shadows.keys()
	shadow_keys.sort()
	for key: String in shadow_keys:
		var batch: Dictionary = shadows[key]
		var cell_keys: Array = (batch.cells as Dictionary).keys()
		cell_keys.sort()
		for cell: String in cell_keys:
			var transforms: Array = batch.cells[cell]
			var bounds := _bounds(transforms, [batch.mesh])
			var instance := _instance("%s_shadow__c%s" % [key, cell], batch.mesh, transforms, bounds.box, 0.0, float(batch.end_m) + ceilf(float(bounds.slack)), true)
			instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
			root.add_child(instance)
			multimeshes += 1
	root.set_meta("trees", trees)
	root.set_meta("shrubs", shrubs)
	root.set_meta("near", near_count)
	root.set_meta("multimesh_batches", multimeshes)
	return {"ok": true, "node": root, "trees": trees, "shrubs": shrubs, "near": near_count, "multimesh_batches": multimeshes}


## The impostor's own material with YBI's tone for its species (Treasure Island's trees
## keep theirs): shared per tint, or null for a mesh that is not a single-surface impostor.
var _tints: Dictionary = {}


func _tinted(mesh: Mesh, tint: Array) -> Material:
	if mesh.get_surface_count() != 1 or not mesh.surface_get_material(0) is ShaderMaterial:
		return null
	var key := "%s|%s" % [mesh.get_instance_id(), tint]
	if not _tints.has(key):
		var made := (mesh.surface_get_material(0) as ShaderMaterial).duplicate() as ShaderMaterial
		made.set_shader_parameter("tint", Color(float(tint[0]), float(tint[1]), float(tint[2]), 1.0))
		_tints[key] = made
	return _tints[key]


func _instance(node_name: String, mesh: Mesh, transforms: Array, box: AABB, begin_m: float, end_m: float, shadow: bool) -> MultiMeshInstance3D:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for index in transforms.size():
		multimesh.set_instance_transform(index, transforms[index])
	multimesh.custom_aabb = box
	var instance := MultiMeshInstance3D.new()
	instance.name = node_name
	instance.multimesh = multimesh
	instance.layers = RENDER_WORLD_VISIBLE
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.visibility_range_begin = begin_m
	instance.visibility_range_end = end_m
	instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
	instance.set_meta("context_kind", "ybi_vegetation")
	instance.set_meta("placement_count", transforms.size())
	return instance


## The box round the instances (the union of the meshes at each) and the farthest
## instance's offset from its centre: {box, slack}.
func _bounds(transforms: Array, meshes: Array) -> Dictionary:
	var box := AABB()
	var centers := PackedVector3Array()
	for index in transforms.size():
		var tree_box := AABB()
		for mesh_index in meshes.size():
			var mesh_box: AABB = (transforms[index] as Transform3D) * (meshes[mesh_index] as Mesh).get_aabb()
			tree_box = mesh_box if mesh_index == 0 else tree_box.merge(mesh_box)
		box = tree_box if index == 0 else box.merge(tree_box)
		centers.append(tree_box.get_center())
	var slack := 0.0
	for center: Vector3 in centers:
		slack = maxf(slack, center.distance_to(box.get_center()))
	return {"box": box, "slack": slack}
