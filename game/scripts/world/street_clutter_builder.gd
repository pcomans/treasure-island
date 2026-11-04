class_name StreetClutterBuilder
extends RefCounted
## Builds PlayableWorld/StreetDetail/Clutter from the placed street-detail rows
## of the clutter layer that carry a kit prop (tools/lib/street-clutter-generation.mjs
## places the parked cars; set pieces the photographed cones and barricades;
## street_clutter_kit.gd draws them). Each prop mesh is one MultiMesh per square
## cell and detail level: the near mesh while the camera is within LOD_NEAR_M of
## the cell's centre, the far mesh beyond, to the prop's range (Godot measures
## visibility ranges to the MultiMesh bounds centre; the far range is extended by
## the farthest instance's offset from that centre so no item vanishes early).
## Every item has a box on the street-prop physics layer: the player collides
## with it and the spray ray stops on it (never a receiver), while the camera arm
## ignores it, as for the street furniture.
## The yard kit's props (street_yard_kit.gd: containers, container walls, shed
## rows, yard vehicles, fabric sheds, equipment, piles, berms, pole flags and
## barges) are built the same way from their rows: each row becomes the kit's
## pieces (one MultiMesh instance each, in the yard material or a piece's own,
## as a flag's, in the yard kit's own cells
## and hand-over distance) and collision shapes, turned by its yaw and resting
## on the ground by its optional pitch, roll and lift. A row on a context deck
## (its surface kind deck: a pier drawn as visual-only context beyond the
## playable boundary) gets no shapes, as the deck has none.

const KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
const YARD_KIT := preload("res://game/scripts/world/street_yard_kit.gd")
## Render cell (m): this share of the near-mesh distance, as the street
## furniture sizes its cells from its ranges, so an item's own hand-over stays
## close to LOD_NEAR_M wherever it stands in its cell.
const CELL_RANGE_SHARE := 0.4
const CELL_M := KIT.LOD_NEAR_M * CELL_RANGE_SHARE
const PHYSICS_CELL_M := 96.0
const RENDER_WORLD_VISIBLE := 1
const PHYSICS_SPRAY_SURFACE := 1 << 2
const PHYSICS_STREET_PROP := 1 << 3


static func _cell(position: Array, size_m: float) -> String:
	return "%d_%d" % [floori(float(position[0]) / size_m), floori(float(position[2]) / size_m)]


func build(document: Dictionary) -> Dictionary:
	var kit := KIT.new()
	var yard: Variant = null
	var root := Node3D.new()
	root.name = "GeneratedStreetClutter"
	# batch key -> {meshes, range_m, shadow, material, cells: {cell -> [[Transform3D, Color]]}}
	var batches: Dictionary = {}
	var shapes: Dictionary = {}
	var prop_counts: Dictionary = {}
	var items := 0
	for row_value: Variant in document.get("rows", []):
		var row: Dictionary = row_value
		if str(row.get("status", "")) != "placed" or str(row.get("layer", "")) != "clutter" or not row.get("prop", null) is String:
			continue
		var prop := str(row.prop)
		var params: Variant = row.get("prop_params", {})
		if YARD_KIT.is_prop(prop):
			if yard == null:
				yard = YARD_KIT.new()
			var added := _add_yard_row(yard, row, prop, params if params is Dictionary else {}, batches, shapes)
			if added != "":
				root.free()
				return {"ok": false, "code": "street_clutter_prop", "message": "%s: %s" % [row.get("id", "?"), added], "source_keys": []}
			prop_counts[prop] = int(prop_counts.get(prop, 0)) + 1
			items += 1
			continue
		var parts := kit.parts(prop, params if params is Dictionary else {})
		if not parts.ok:
			root.free()
			return {"ok": false, "code": "street_clutter_prop", "message": "%s: %s" % [row.get("id", "?"), parts.message], "source_keys": []}
		var position: Array = row.position_m
		var surface: Dictionary = row.get("surface", {})
		var yaw_value: Variant = row.get("yaw_radians", null)
		var yaw := float(yaw_value) if yaw_value is float or yaw_value is int else 0.0
		var basis := Basis(Vector3.UP, yaw)
		var lift := 0.0
		var tilt: Dictionary = params if params is Dictionary else {}
		if prop == "parked_car":
			# A car settles on its four wheels: pitch raises its nose, roll its left side.
			basis = basis * Basis(Vector3.RIGHT, float(tilt.get("pitch", 0.0))) * Basis(Vector3.BACK, -float(tilt.get("roll", 0.0)))
			lift = float(tilt.get("lift", 0.0))
		var placement := Transform3D(basis, Vector3(float(position[0]), float(position[1]) + float(surface.get("bias_m", 0.0)) + lift, float(position[2])))
		var key := str(parts.mesh_key)
		if not batches.has(key):
			batches[key] = {"meshes": parts.meshes, "range_m": float(parts.range_m), "shadow": bool(parts.shadow), "material": kit.material(), "lod_near_m": KIT.LOD_NEAR_M, "cells": {}}
		var cells: Dictionary = batches[key].cells
		var cell := _cell(position, CELL_M)
		if not cells.has(cell):
			cells[cell] = []
		(cells[cell] as Array).append([placement, parts.custom])
		var physics_cell := _cell(position, PHYSICS_CELL_M)
		if not shapes.has(physics_cell):
			shapes[physics_cell] = []
		(shapes[physics_cell] as Array).append({"id": str(row.id), "shape": parts.shape, "transform": placement * (parts.shape_transform as Transform3D)})
		prop_counts[prop] = int(prop_counts.get(prop, 0)) + 1
		items += 1
	var multimeshes := 0
	var batch_keys: Array = batches.keys()
	batch_keys.sort()
	for key: String in batch_keys:
		var batch: Dictionary = batches[key]
		var cell_keys: Array = (batch.cells as Dictionary).keys()
		cell_keys.sort()
		for cell: String in cell_keys:
			var entries: Array = batch.cells[cell]
			# One box for both levels (the near mesh's), so both measure their
			# range from the same centre and hand over at exactly one distance.
			var near_box: AABB = (batch.meshes[0] as Mesh).get_aabb()
			var bounds := AABB()
			for index in entries.size():
				var box: AABB = (entries[index][0] as Transform3D) * near_box
				bounds = box if index == 0 else bounds.merge(box)
			var slack := 0.0
			for entry: Array in entries:
				slack = maxf(slack, ((entry[0] as Transform3D) * near_box).get_center().distance_to(bounds.get_center()))
			for level in 2:
				var multimesh := MultiMesh.new()
				multimesh.transform_format = MultiMesh.TRANSFORM_3D
				multimesh.use_custom_data = true
				multimesh.mesh = batch.meshes[level]
				multimesh.instance_count = entries.size()
				for index in entries.size():
					multimesh.set_instance_transform(index, entries[index][0])
					multimesh.set_instance_custom_data(index, entries[index][1])
				multimesh.custom_aabb = bounds
				var instance := MultiMeshInstance3D.new()
				instance.name = "%s_lod%d__c%s" % [key, level, cell]
				instance.multimesh = multimesh
				instance.material_override = batch.material
				instance.layers = RENDER_WORLD_VISIBLE
				instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if bool(batch.shadow) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				# No margins: a margin is hysteresis, which would let both levels
				# (or neither) draw for a moment at the hand-over.
				if level == 0:
					instance.visibility_range_end = float(batch.lod_near_m)
				else:
					instance.visibility_range_begin = float(batch.lod_near_m)
					instance.visibility_range_end = float(batch.range_m) + ceilf(slack)
				instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
				instance.set_meta("street_detail_layer", "clutter")
				instance.set_meta("placement_count", entries.size())
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
		body.set_meta("feature_kind", "street_clutter")
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
			ids.append(str(entry.id))
			shape_count += 1
		body.set_meta("street_detail_ids", ids)
		root.add_child(body)
	root.set_meta("items", items)
	root.set_meta("prop_counts", prop_counts)
	return {
		"ok": true,
		"node": root,
		"items": items,
		"prop_counts": prop_counts,
		"multimesh_batches": multimeshes,
		"collision_shapes": shape_count,
	}


## Adds one yard-kit row's pieces to the render batches and its shapes to the
## physics cells; "" or why it can't be built.
func _add_yard_row(yard: Variant, row: Dictionary, prop: String, params: Dictionary, batches: Dictionary, shapes: Dictionary) -> String:
	var built: Dictionary = yard.pieces(prop, params, hash(str(row.id)) & 0x7fffffff)
	if not built.ok:
		return str(built.message)
	var position: Array = row.position_m
	var surface: Dictionary = row.get("surface", {})
	var yaw_value: Variant = row.get("yaw_radians", null)
	var yaw := float(yaw_value) if yaw_value is float or yaw_value is int else 0.0
	# Its rest on uneven ground: pitch raises the front (-Z), roll the left side, lift the whole.
	var basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, float(params.get("pitch", 0.0))) * Basis(Vector3.BACK, -float(params.get("roll", 0.0)))
	var placement := Transform3D(basis, Vector3(float(position[0]), float(position[1]) + float(surface.get("bias_m", 0.0)) + float(params.get("lift", 0.0)), float(position[2])))
	for piece: Dictionary in built.pieces:
		var key := "yard:%s" % piece.mesh_key
		if not batches.has(key):
			batches[key] = {"meshes": piece.meshes, "range_m": float(built.range_m), "shadow": bool(built.shadow), "material": piece.get("material", yard.material()), "lod_near_m": float(built.lod_near_m), "cells": {}}
		var world: Transform3D = placement * (piece.transform as Transform3D)
		var cells: Dictionary = batches[key].cells
		var cell := _cell([world.origin.x, world.origin.y, world.origin.z], float(built.cell_m))
		if not cells.has(cell):
			cells[cell] = []
		(cells[cell] as Array).append([world, piece.custom])
	if str(surface.get("kind", "")) == "deck":
		return ""
	for entry: Dictionary in built.shapes:
		var shape_world: Transform3D = placement * (entry.transform as Transform3D)
		var physics_cell := _cell([shape_world.origin.x, shape_world.origin.y, shape_world.origin.z], PHYSICS_CELL_M)
		if not shapes.has(physics_cell):
			shapes[physics_cell] = []
		(shapes[physics_cell] as Array).append({"id": str(row.id), "shape": entry.shape, "transform": shape_world})
	return ""
