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
## are Label3D. The power lines' wires (power_wires rows) hang between the
## crossarms of their built utility poles, in straight pieces of one shared
## wire mesh, with no collision; so do a photographed pole's spur wires to the
## poles its prop_params.wires_to names. A soccer_ball row is the pitch's loose ball,
## a rigid body of its own (soccer_ball.gd) resting on its spot.

const KIT := preload("res://game/scripts/world/street_furniture_kit.gd")
const SOCCER_BALL := preload("res://game/scripts/world/soccer_ball.gd")
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
	# cell -> [{id, shape, transform}] and [{id, text, color, transform}]
	var shapes: Dictionary = {}
	var labels: Dictionary = {}
	var prop_counts: Dictionary = {}
	# A built utility pole's placement and wire attachments, by row id, and the
	# spans [pole id, pole id] of the spurs that photographed poles name.
	var poles: Dictionary = {}
	var wire_rows: Array[Dictionary] = []
	var spurs: Array = []
	var balls: Array[Transform3D] = []
	var props := 0
	for row_value: Variant in document.get("rows", []):
		var row: Dictionary = row_value
		if str(row.get("status", "")) != "placed" or str(row.get("layer", "")) != "furniture" or not row.get("prop", null) is String:
			continue
		var prop := str(row.prop)
		var params: Variant = row.get("prop_params", {})
		if str(row.get("geometry", "")) != "point":
			if prop != "power_wires":
				root.free()
				return {"ok": false, "code": "street_furniture_prop", "message": "%s: %s is not a line prop" % [row.get("id", "?"), prop], "source_keys": []}
			wire_rows.append(row)
			continue
		if prop == SOCCER_BALL.PROP:
			# Resting on the land the row stands on, which the ball rolls on.
			var spot: Array = row.position_m
			balls.append(Transform3D(Basis.IDENTITY, Vector3(float(spot[0]), float(spot[1]) + SOCCER_BALL.RADIUS_M, float(spot[2]))))
			prop_counts[prop] = int(prop_counts.get(prop, 0)) + 1
			props += 1
			continue
		var parts := kit.parts(prop, params if params is Dictionary else {})
		if not parts.ok:
			root.free()
			return {"ok": false, "code": "street_furniture_prop", "message": "%s: %s" % [row.get("id", "?"), parts.message], "source_keys": []}
		var position: Array = row.position_m
		var surface: Dictionary = row.get("surface", {})
		var yaw_value: Variant = row.get("yaw_radians", null)
		var yaw := float(yaw_value) if yaw_value is float or yaw_value is int else 0.0
		var placement := Transform3D(Basis(Vector3.UP, yaw), Vector3(float(position[0]), float(position[1]) + float(surface.get("bias_m", 0.0)), float(position[2])))
		if prop == "utility_pole":
			poles[str(row.id)] = {"placement": placement, "wires": kit.wire_levels(params if params is Dictionary else {})}
			var wires_to: Variant = (params as Dictionary).get("wires_to", []) if params is Dictionary else []
			if not wires_to is Array:
				root.free()
				return {"ok": false, "code": "street_furniture_prop", "message": "%s: wires_to must list pole ids" % row.get("id", "?"), "source_keys": []}
			for target: Variant in wires_to:
				spurs.append([str(row.id), str(target)])
		var range_m := float(parts.range_m)
		var cell := _cell(position, minf(CELL_MAX_M, range_m * CELL_RANGE_SHARE))
		var physics_cell := _cell(position, PHYSICS_CELL_M)
		var label_cell := _cell(position, minf(CELL_MAX_M, KIT.LABEL_RANGE_M * CELL_RANGE_SHARE))
		for piece: Dictionary in parts.pieces:
			var key := str(piece.key)
			if not batches.has(key):
				batches[key] = {"mesh": piece.mesh, "range_m": range_m, "shadow": bool(parts.shadow) and bool(piece.get("shadow", true)), "cells": {}}
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
			(labels[label_cell] as Array).append({"id": str(row.id), "text": str(label.text), "color": label.get("color", Color(0.96, 0.97, 0.95)), "transform": placement * (label.transform as Transform3D)})
		prop_counts[prop] = int(prop_counts.get(prop, 0)) + 1
		props += 1
	var wires := _wire_pieces(wire_rows, spurs, poles)
	if not wires.ok:
		root.free()
		return wires
	if not (wires.cells as Dictionary).is_empty():
		batches["power_wire"] = {"mesh": kit.wire_mesh(), "range_m": KIT.WIRE_RANGE_M, "shadow": false, "cells": wires.cells, "custom": wires.custom}
		prop_counts["power_wires"] = wire_rows.size()
	var multimeshes := 0
	var batch_keys: Array = batches.keys()
	batch_keys.sort()
	for key: String in batch_keys:
		var batch: Dictionary = batches[key]
		var cell_keys: Array = (batch.cells as Dictionary).keys()
		cell_keys.sort()
		for cell: String in cell_keys:
			var transforms: Array = batch.cells[cell]
			# Per-instance custom data where the batch has it (the wires' radii).
			var customs: Array = (batch.get("custom", {}) as Dictionary).get(cell, [])
			var multimesh := MultiMesh.new()
			multimesh.transform_format = MultiMesh.TRANSFORM_3D
			multimesh.use_custom_data = not customs.is_empty()
			multimesh.mesh = batch.mesh
			multimesh.instance_count = transforms.size()
			var mesh_box: AABB = (batch.mesh as Mesh).get_aabb()
			var bounds := AABB()
			var centers := PackedVector3Array()
			for index in transforms.size():
				multimesh.set_instance_transform(index, transforms[index])
				if not customs.is_empty():
					multimesh.set_instance_custom_data(index, customs[index])
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
			label.modulate = entry.color
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
	for spot: Transform3D in balls:
		root.add_child(SOCCER_BALL.create(spot))
	root.set_meta("props", props)
	root.set_meta("prop_counts", prop_counts)
	root.set_meta("wire_spans", wires.spans)
	return {
		"ok": true,
		"node": root,
		"props": props,
		"prop_counts": prop_counts,
		"multimesh_batches": multimeshes,
		"collision_shapes": shape_count,
		"labels": label_count,
		"wire_spans": wires.spans,
	}


## The wire pieces of the power lines and spurs: {ok, spans, cells: {cell ->
## [Transform3D]}, custom: {cell -> [Color(radius, 0, 0, 0)]}} for the shared
## wire mesh (a unit tube along +Z; its shader reads each piece's radius from
## the custom data). Each line's
## prop_params.poles lists its poles in order along it (null where a vertex has
## none); a span joins each two consecutive built poles, and each spur its two
## poles. At each end it takes the crossarm squarest to the span, and pairs the
## two ends' insulators in order across the span, so no two conductors cross;
## the lower cable hangs from the poles' brackets.
func _wire_pieces(rows: Array[Dictionary], spurs: Array, poles: Dictionary) -> Dictionary:
	# [from id, to id, owner id] for every span.
	var pairs: Array = []
	for row: Dictionary in rows:
		var params: Variant = row.get("prop_params", null)
		if not params is Dictionary or not (params as Dictionary).get("poles", null) is Array:
			return {"ok": false, "code": "street_furniture_prop", "message": "%s: power_wires needs its pole list" % row.get("id", "?"), "source_keys": []}
		var ids: Array = params.poles
		for index in range(1, ids.size()):
			if ids[index - 1] is String and ids[index] is String:
				pairs.append([ids[index - 1], ids[index], str(row.get("id", "?"))])
	for spur: Array in spurs:
		pairs.append([spur[0], spur[1], spur[0]])
	var cells: Dictionary = {}
	var custom: Dictionary = {}
	var spans := 0
	for pair: Array in pairs:
		if not poles.has(pair[0]) or not poles.has(pair[1]):
			return {"ok": false, "code": "street_furniture_prop", "message": "%s: span pole %s or %s is not a built utility pole" % [pair[2], pair[0], pair[1]], "source_keys": []}
		var a: Dictionary = poles[pair[0]]
		var b: Dictionary = poles[pair[1]]
		var origin_a: Vector3 = (a.placement as Transform3D).origin
		var origin_b: Vector3 = (b.placement as Transform3D).origin
		var span := origin_b - origin_a
		span.y = 0.0
		if span.length() < 1.0:
			continue
		var across := Vector3.UP.cross(span.normalized())
		var tops_a := _across_order(_attachments(a, span), across)
		var tops_b := _across_order(_attachments(b, -span), across)
		for conductor in mini(tops_a.size(), tops_b.size()):
			_hang(cells, custom, tops_a[conductor], tops_b[conductor], KIT.WIRE_SAG, KIT.WIRE_RADIUS_M)
		var lower_a: Vector3 = (a.placement as Transform3D) * (a.wires.lower as Vector3)
		var lower_b: Vector3 = (b.placement as Transform3D) * (b.wires.lower as Vector3)
		_hang(cells, custom, lower_a, lower_b, KIT.WIRE_LOWER_SAG, KIT.WIRE_LOWER_RADIUS_M)
		spans += 1
	return {"ok": true, "spans": spans, "cells": cells, "custom": custom}


## The world insulator tops of the crossarm of a pole squarest to a span
## leaving it along `toward`.
func _attachments(pole: Dictionary, toward: Vector3) -> Array[Vector3]:
	var placement: Transform3D = pole.placement
	var best: Array[Vector3] = []
	var best_score := INF
	for level: Dictionary in pole.wires.levels:
		var axis := placement.basis * (Basis(Vector3.UP, float(level.yaw)) * Vector3.RIGHT)
		var score := absf(axis.normalized().dot(toward.normalized()))
		if score < best_score:
			best_score = score
			best = []
			for point: Vector3 in level.points:
				best.append(placement * point)
	return best


## Points in order along `across`.
func _across_order(points: Array[Vector3], across: Vector3) -> Array[Vector3]:
	var sorted: Array[Vector3] = points.duplicate()
	sorted.sort_custom(func(left: Vector3, right: Vector3) -> bool: return left.dot(across) < right.dot(across))
	return sorted


## One wire from a to b, sagging `sag` of its length at mid span, as straight
## pieces of the unit wire tube (radius `radius`, also kept in custom for the
## shader), filed by their midpoint's cell.
func _hang(cells: Dictionary, custom: Dictionary, a: Vector3, b: Vector3, sag: float, radius: float) -> void:
	var length := a.distance_to(b)
	var pieces := maxi(4, ceili(length / KIT.WIRE_SEGMENT_M))
	var drop := length * sag
	var previous := a
	for step in range(1, pieces + 1):
		var t := float(step) / float(pieces)
		var point := a.lerp(b, t) - Vector3(0.0, 4.0 * drop * t * (1.0 - t), 0.0)
		var along := point - previous
		var x := along.cross(Vector3.UP)
		if x.length() < 1e-6:
			x = Vector3.RIGHT
		x = x.normalized() * radius
		# Right-handed (x, y, along), so the tube keeps its winding.
		var y := along.cross(x).normalized() * radius
		var middle := (previous + point) * 0.5
		var cell := "%d_%d" % [floori(middle.x / CELL_MAX_M), floori(middle.z / CELL_MAX_M)]
		if not cells.has(cell):
			cells[cell] = []
			custom[cell] = []
		(cells[cell] as Array).append(Transform3D(Basis(x, y, along), previous))
		(custom[cell] as Array).append(Color(radius, 0.0, 0.0, 0.0))
		previous = point
