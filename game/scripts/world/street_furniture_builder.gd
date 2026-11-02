class_name StreetFurnitureBuilder
extends RefCounted
## Builds PlayableWorld/StreetDetail/Furniture from the placed street-detail rows
## that carry a kit prop (tools/lib/street-furniture-generation.mjs chooses them;
## street_furniture_kit.gd draws them). Each prop variant is one MultiMesh per
## square cell sized from the prop's visibility range, so it culls by area; Godot
## measures the range to the MultiMesh bounds centre, so each range is extended by
## the farthest instance's offset from that centre and no prop shows up late.
## Each physics cell has one static body with simple shapes for the poles, posts,
## cabinets and hydrants the player walks into. The bodies are on their own
## street-prop layer: the player collides with it and the spray ray stops on it
## (a prop is never a spray receiver), while the camera arm ignores it, so a pole
## between the camera and the player does not pull the camera in. Street names
## are Label3D.

const KIT := preload("res://game/scripts/world/street_furniture_kit.gd")
## Largest render cell (m) and its share of a prop's visibility range.
const CELL_MAX_M := 96.0
const CELL_RANGE_SHARE := 0.4
const PHYSICS_CELL_M := 96.0
const RENDER_WORLD_VISIBLE := 1
const PHYSICS_SPRAY_SURFACE := 1 << 2
const PHYSICS_STREET_PROP := 1 << 3


static func _cell(position: Array, size_m: float) -> String:
	return "%d_%d" % [floori(float(position[0]) / size_m), floori(float(position[2]) / size_m)]


func build(document: Dictionary) -> Dictionary:
	var kit := KIT.new()
	var root := Node3D.new()
	root.name = "GeneratedStreetFurniture"
	# batch key -> {mesh, range_m, shadow, cells: {cell -> [Transform3D]}}
	var batches: Dictionary = {}
	# cell -> [{id, shape, transform}] and [{id, text, transform}]
	var shapes: Dictionary = {}
	var labels: Dictionary = {}
	var prop_counts: Dictionary = {}
	var props := 0
	for row_value: Variant in document.get("rows", []):
		var row: Dictionary = row_value
		if str(row.get("status", "")) != "placed" or str(row.get("layer", "")) != "furniture" or not row.get("prop", null) is String:
			continue
		var prop := str(row.prop)
		var params: Variant = row.get("prop_params", {})
		var parts := kit.parts(prop, params if params is Dictionary else {})
		if not parts.ok:
			root.free()
			return {"ok": false, "code": "street_furniture_prop", "message": "%s: %s" % [row.get("id", "?"), parts.message], "source_keys": []}
		var position: Array = row.position_m
		var surface: Dictionary = row.get("surface", {})
		var yaw_value: Variant = row.get("yaw_radians", null)
		var yaw := float(yaw_value) if yaw_value is float or yaw_value is int else 0.0
		var placement := Transform3D(Basis(Vector3.UP, yaw), Vector3(float(position[0]), float(position[1]) + float(surface.get("bias_m", 0.0)), float(position[2])))
		var range_m := float(parts.range_m)
		var cell := _cell(position, minf(CELL_MAX_M, range_m * CELL_RANGE_SHARE))
		var physics_cell := _cell(position, PHYSICS_CELL_M)
		var label_cell := _cell(position, minf(CELL_MAX_M, KIT.LABEL_RANGE_M * CELL_RANGE_SHARE))
		for piece: Dictionary in parts.pieces:
			var key := str(piece.key)
			if not batches.has(key):
				batches[key] = {"mesh": piece.mesh, "range_m": range_m, "shadow": parts.shadow, "cells": {}}
			var cells: Dictionary = batches[key].cells
			if not cells.has(cell):
				cells[cell] = []
			(cells[cell] as Array).append(placement * (piece.transform as Transform3D))
		for shape: Dictionary in parts.shapes:
			if not shapes.has(physics_cell):
				shapes[physics_cell] = []
			(shapes[physics_cell] as Array).append({"id": str(row.id), "shape": shape.shape, "transform": placement * (shape.transform as Transform3D)})
		for label: Dictionary in parts.labels:
			if not labels.has(label_cell):
				labels[label_cell] = []
			(labels[label_cell] as Array).append({"id": str(row.id), "text": str(label.text), "transform": placement * (label.transform as Transform3D)})
		prop_counts[prop] = int(prop_counts.get(prop, 0)) + 1
		props += 1
	var multimeshes := 0
	var batch_keys: Array = batches.keys()
	batch_keys.sort()
	for key: String in batch_keys:
		var batch: Dictionary = batches[key]
		var cell_keys: Array = (batch.cells as Dictionary).keys()
		cell_keys.sort()
		for cell: String in cell_keys:
			var transforms: Array = batch.cells[cell]
			var multimesh := MultiMesh.new()
			multimesh.transform_format = MultiMesh.TRANSFORM_3D
			multimesh.mesh = batch.mesh
			multimesh.instance_count = transforms.size()
			var mesh_box: AABB = (batch.mesh as Mesh).get_aabb()
			var bounds := AABB()
			var centers := PackedVector3Array()
			for index in transforms.size():
				multimesh.set_instance_transform(index, transforms[index])
				var box: AABB = (transforms[index] as Transform3D) * mesh_box
				bounds = box if index == 0 else bounds.merge(box)
				centers.append(box.get_center())
			# Godot measures the range to the bounds centre: reach each instance in full.
			var slack := 0.0
			for center: Vector3 in centers:
				slack = maxf(slack, center.distance_to(bounds.get_center()))
			var instance := MultiMeshInstance3D.new()
			instance.name = "%s__c%s" % [key.replace(".", "p"), cell]
			instance.multimesh = multimesh
			instance.layers = RENDER_WORLD_VISIBLE
			instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if bool(batch.shadow) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			instance.visibility_range_end = float(batch.range_m) + ceilf(slack)
			# Hysteresis only: a fading item would draw transparent while it fades.
			instance.visibility_range_end_margin = 10.0
			instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
			instance.set_meta("street_detail_layer", "furniture")
			instance.set_meta("placement_count", transforms.size())
			root.add_child(instance)
			multimeshes += 1
	var shape_count := 0
	var shape_cells: Array = shapes.keys()
	shape_cells.sort()
	for cell: String in shape_cells:
		var body := StaticBody3D.new()
		body.name = "Collision__c%s" % cell
		body.collision_layer = PHYSICS_STREET_PROP | PHYSICS_SPRAY_SURFACE
		body.collision_mask = 0
		body.set_meta("feature_kind", "street_furniture")
		body.set_meta("receiver_kind", "none")
		body.set_meta("opaque", true)
		var ids := PackedStringArray()
		for entry: Dictionary in shapes[cell]:
			var collision := CollisionShape3D.new()
			collision.name = "Shape%d" % body.get_child_count()
			collision.shape = entry.shape
			collision.transform = entry.transform
			collision.set_meta("street_detail_id", entry.id)
			body.add_child(collision)
			if not ids.has(str(entry.id)):
				ids.append(str(entry.id))
			shape_count += 1
		body.set_meta("street_detail_ids", ids)
		root.add_child(body)
	var label_count := 0
	var label_cells: Array = labels.keys()
	label_cells.sort()
	for cell: String in label_cells:
		var group := Node3D.new()
		group.name = "Names__c%s" % cell
		for entry: Dictionary in labels[cell]:
			var label := Label3D.new()
			label.name = "Name%d" % group.get_child_count()
			label.text = entry.text
			label.font_size = KIT.LABEL_FONT_SIZE
			label.pixel_size = KIT.LABEL_PIXEL_M
			label.modulate = Color(0.96, 0.97, 0.95)
			label.outline_size = 0
			label.shaded = true
			label.double_sided = false
			label.alpha_cut = Label3D.ALPHA_CUT_OPAQUE_PREPASS
			label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			label.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			label.layers = RENDER_WORLD_VISIBLE
			label.visibility_range_end = KIT.LABEL_RANGE_M
			label.transform = entry.transform
			label.set_meta("street_detail_id", entry.id)
			group.add_child(label)
			label_count += 1
		root.add_child(group)
	root.set_meta("props", props)
	root.set_meta("prop_counts", prop_counts)
	return {
		"ok": true,
		"node": root,
		"props": props,
		"prop_counts": prop_counts,
		"multimesh_batches": multimeshes,
		"collision_shapes": shape_count,
		"labels": label_count,
	}
