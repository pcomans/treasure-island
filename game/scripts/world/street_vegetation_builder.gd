class_name StreetVegetationBuilder
extends RefCounted
## Builds the trees, shrubs and low plants (grass clumps, perennials and bed shrubs) of
## PlayableWorld/StreetDetail/Vegetation from the placed vegetation rows that
## carry a street-vegetation kit prop (tools/lib/street-vegetation-generation.mjs
## places them and settles each foot on the visible ground;
## street_vegetation_kit.gd draws them). Low plants count as grass_clumps in the
## build report.
##
## Each prop variant is one MultiMesh per square cell and detail level. The
## levels of one cell share one box, so they measure their visibility range from
## the same centre and hand over at exactly one distance (no hysteresis, which
## would draw both levels or neither for a moment); the far level's range is
## extended by the farthest instance's offset from that centre, so no tree
## vanishes early. Trees use small cells, so a hand-over happens close to each
## tree's own distance; low plants use larger ones and have a single short
## range (the newer ones dissolve before it ends, in their shader).
##
## A big tree's levels cast no shadow of their own: its kit shadow mesh does, a
## cheap outline drawn only into the shadow maps, one MultiMesh per variant and
## SHADOW_CELL_M cell, since most of a dense crown's primitives and draw calls
## were its shadow passes. Its range runs on past the impostor switch (the kit's
## SHADOW_RANGE_M), so the tree keeps its ground shadow there.
##
## Collision is the trunk only: capsules on the street-prop layer, which the
## player collides with and the spray ray stops on (never a receiver), while
## the camera arm ignores it, as for the street furniture. Crowns and low plants
## have none, so the jetpack flies through a crown. A tree standing in paving
## gets its round mulch pit, drawn just above the paving's plane.
##
## A hedge row (a vegetation line row of kind hedge carrying a hedge prop; the
## kit's hedge_into lays it) is cut into pieces of HEDGE_PIECE_STATIONS
## stations, and the pieces in each tree cell are merged into one mesh per
## detail level (the leafy core, its sprigs and stems), the levels sharing one
## box like the trees'. Hedges have no collision.

const KIT := preload("res://game/scripts/world/street_vegetation_kit.gd")
const MULCH := preload("res://game/resources/textures/world/street/street_mulch.png")
const TREE_CELL_M := 16.0
const GRASS_CELL_M := 32.0
const SHADOW_CELL_M := 48.0
const PHYSICS_CELL_M := 96.0
const RENDER_WORLD_VISIBLE := 1
const PHYSICS_SPRAY_SURFACE := 1 << 2
const PHYSICS_STREET_PROP := 1 << 3
## Mulch pits draw within this range; they are flat and small.
const WELL_RANGE_M := 140.0
const WELL_SIDES := 16
## The mulch texture's tile, as on the planting strips (world_chunk_builder.gd).
const MULCH_TILE_M := 2.0


static func _cell(position: Vector3, size_m: float) -> String:
	return "%d_%d" % [floori(position.x / size_m), floori(position.z / size_m)]


func build(document: Dictionary) -> Dictionary:
	var kit := KIT.new()
	var root := Node3D.new()
	root.name = "GeneratedStreetVegetation"
	# batch key -> {prop, variant, levels, cells: {cell -> [Transform3D]}}
	var batches: Dictionary = {}
	# batch key -> {mesh, end_m, cells: {shadow cell -> [Transform3D]}}
	var shadows: Dictionary = {}
	# physics cell -> [{id, shape, transform}]
	var shapes: Dictionary = {}
	# render cell -> [{center, radius, slope}]
	var wells: Dictionary = {}
	var capsules: Dictionary = {}
	# tree cell -> [{variant, points, from_m, to_m, seed}]
	var hedges: Dictionary = {}
	var prop_counts: Dictionary = {}
	var trees := 0
	var shrubs := 0
	var grass := 0
	var hedge_rows := 0
	for row_value: Variant in document.get("rows", []):
		var row: Dictionary = row_value
		if str(row.get("status", "")) != "placed" or str(row.get("layer", "")) != "vegetation" or not row.get("prop", null) is String:
			continue
		var prop := str(row.prop)
		var params: Variant = row.get("prop_params", null)
		if KIT.is_hedge(prop):
			var hedge_problem := _add_hedge(hedges, row)
			if hedge_problem != "":
				root.free()
				return {"ok": false, "code": "street_vegetation_prop", "message": "%s: %s" % [row.get("id", "?"), hedge_problem], "source_keys": []}
			prop_counts[prop] = int(prop_counts.get(prop, 0)) + 1
			hedge_rows += 1
			continue
		var problem := KIT.params_error(prop, str(row.get("kind", "")), params)
		if problem != "":
			root.free()
			return {"ok": false, "code": "street_vegetation_prop", "message": "%s: %s" % [row.get("id", "?"), problem], "source_keys": []}
		var variant := int(params.variant)
		var scale := float(params.scale)
		var proto := kit.prototype(prop, variant)
		if not proto.ok:
			root.free()
			return {"ok": false, "code": "street_vegetation_prop", "message": "%s: %s" % [row.get("id", "?"), proto.message], "source_keys": []}
		var position: Array = row.position_m
		var surface: Dictionary = row.get("surface", {})
		# The foot rests at the lowest visible ground round it (lift_m from y + bias).
		var foot := Vector3(float(position[0]), float(position[1]) + float(surface.get("bias_m", 0.0)) + float(params.lift_m), float(position[2]))
		var yaw_value: Variant = row.get("yaw_radians", null)
		var yaw := float(yaw_value) if yaw_value is float or yaw_value is int else 0.0
		var placement := Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3.ONE * scale), foot)
		var is_grass := KIT.is_low_plant(prop)
		var cell := _cell(foot, GRASS_CELL_M if is_grass else TREE_CELL_M)
		var key := "%s_%d" % [prop, variant]
		if not batches.has(key):
			batches[key] = {"levels": proto.levels, "cells": {}}
		var cells: Dictionary = batches[key].cells
		if not cells.has(cell):
			cells[cell] = []
		(cells[cell] as Array).append(placement)
		if proto.has("shadow"):
			if not shadows.has(key):
				shadows[key] = {"mesh": proto.shadow.mesh, "end_m": proto.shadow.end_m, "cells": {}}
			var shadow_cells: Dictionary = shadows[key].cells
			var shadow_cell := _cell(foot, SHADOW_CELL_M)
			if not shadow_cells.has(shadow_cell):
				shadow_cells[shadow_cell] = []
			(shadow_cells[shadow_cell] as Array).append(placement)
		var physics_cell := _cell(foot, PHYSICS_CELL_M)
		for capsule: Dictionary in proto.capsules:
			if not shapes.has(physics_cell):
				shapes[physics_cell] = []
			(shapes[physics_cell] as Array).append(_capsule(capsules, str(row.id), placement * (capsule.from as Vector3), placement * (capsule.to as Vector3), float(capsule.radius_m) * scale))
		var well := float(params.get("well_m", 0.0))
		if well > 0.0:
			var slope: Array = params.well_slope
			if not wells.has(cell):
				wells[cell] = []
			(wells[cell] as Array).append({
				"center": foot + Vector3(0.0, float(params.well_lift_m), 0.0),
				"radius": well * 0.5,
				"slope": Vector2(float(slope[0]), float(slope[1])),
			})
		prop_counts[prop] = int(prop_counts.get(prop, 0)) + 1
		if is_grass:
			grass += 1
		elif KIT.is_shrub(prop):
			shrubs += 1
		else:
			trees += 1
	var multimeshes := 0
	var batch_keys: Array = batches.keys()
	batch_keys.sort()
	for key: String in batch_keys:
		var batch: Dictionary = batches[key]
		var levels: Array = batch.levels
		var cell_keys: Array = (batch.cells as Dictionary).keys()
		cell_keys.sort()
		for cell: String in cell_keys:
			var transforms: Array = batch.cells[cell]
			# One box for every level of the cell (the union of their meshes).
			var bounds := _cell_bounds(transforms, levels.map(func(level: Dictionary) -> Mesh: return level.mesh))
			var box: AABB = bounds.box
			var slack: float = bounds.slack
			for level_index in levels.size():
				var level: Dictionary = levels[level_index]
				var multimesh := MultiMesh.new()
				multimesh.transform_format = MultiMesh.TRANSFORM_3D
				multimesh.mesh = level.mesh
				multimesh.instance_count = transforms.size()
				for index in transforms.size():
					multimesh.set_instance_transform(index, transforms[index])
				multimesh.custom_aabb = box
				var instance := MultiMeshInstance3D.new()
				instance.name = "%s_%s__c%s" % [key, level.name, cell]
				instance.multimesh = multimesh
				instance.layers = RENDER_WORLD_VISIBLE
				instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if bool(level.shadow) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				instance.visibility_range_begin = float(level.begin_m)
				var last := level_index == levels.size() - 1
				instance.visibility_range_end = float(level.end_m) + (ceilf(slack) if last else 0.0)
				instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
				instance.set_meta("street_detail_layer", "vegetation")
				instance.set_meta("placement_count", transforms.size())
				root.add_child(instance)
				multimeshes += 1
	var shadow_keys: Array = shadows.keys()
	shadow_keys.sort()
	for key: String in shadow_keys:
		var batch: Dictionary = shadows[key]
		var cell_keys: Array = (batch.cells as Dictionary).keys()
		cell_keys.sort()
		for cell: String in cell_keys:
			root.add_child(_shadow_instance(key, cell, batch.mesh, float(batch.end_m), batch.cells[cell]))
			multimeshes += 1
	var well_cells: Array = wells.keys()
	well_cells.sort()
	var well_material := _well_material()
	for cell: String in well_cells:
		var instance := MeshInstance3D.new()
		instance.name = "MulchPits__c%s" % cell
		instance.mesh = _wells_mesh(wells[cell], well_material)
		instance.layers = RENDER_WORLD_VISIBLE
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.visibility_range_end = WELL_RANGE_M
		instance.set_meta("street_detail_layer", "vegetation")
		root.add_child(instance)
	var hedge_cells: Array = hedges.keys()
	hedge_cells.sort()
	for cell: String in hedge_cells:
		_build_hedge_cell(root, kit, cell, hedges[cell])
	var shape_count := 0
	var shape_cells: Array = shapes.keys()
	shape_cells.sort()
	for cell: String in shape_cells:
		var body := StaticBody3D.new()
		body.name = "Trunks__c%s" % cell
		body.collision_layer = PHYSICS_STREET_PROP | PHYSICS_SPRAY_SURFACE
		body.collision_mask = 0
		body.set_meta("feature_kind", "street_vegetation")
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
	root.set_meta("trees", trees)
	root.set_meta("shrubs", shrubs)
	root.set_meta("grass_clumps", grass)
	root.set_meta("prop_counts", prop_counts)
	return {
		"ok": true,
		"node": root,
		"trees": trees,
		"shrubs": shrubs,
		"grass_clumps": grass,
		"hedges": hedge_rows,
		"prop_counts": prop_counts,
		"multimesh_batches": multimeshes,
		"mulch_pits": well_cells.size(),
		"collision_shapes": shape_count,
	}


## The box round a cell's instances (the union of the meshes at each) and the
## farthest instance's offset from its centre: {box, slack}.
func _cell_bounds(transforms: Array, meshes: Array) -> Dictionary:
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


## A shadow cell's trees of one variant: their shadow mesh, drawn only into the
## shadow maps, out to end_m past the farthest of them from the cell's centre.
func _shadow_instance(key: String, cell: String, mesh: Mesh, end_m: float, transforms: Array) -> MultiMeshInstance3D:
	var bounds := _cell_bounds(transforms, [mesh])
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for index in transforms.size():
		multimesh.set_instance_transform(index, transforms[index])
	multimesh.custom_aabb = bounds.box
	var instance := MultiMeshInstance3D.new()
	instance.name = "%s_shadow__c%s" % [key, cell]
	instance.multimesh = multimesh
	instance.layers = RENDER_WORLD_VISIBLE
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	instance.visibility_range_end = end_m + ceilf(float(bounds.slack))
	instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
	instance.set_meta("street_detail_layer", "vegetation")
	instance.set_meta("placement_count", transforms.size())
	return instance


## Checks a hedge row and files its pieces under the tree cells of their
## middles: {variant, points (x, the visible ground's height, z), from_m, to_m,
## seed}. Returns what is wrong with the row, or "".
func _add_hedge(hedges: Dictionary, row: Dictionary) -> String:
	var points_value: Variant = row.get("points_m", null)
	if str(row.get("geometry", "")) != "line" or not points_value is Array:
		return "a hedge needs a line of points_m"
	var line: Array = points_value
	var problem := KIT.line_params_error(str(row.prop), str(row.get("kind", "")), row.get("prop_params", null), line.size())
	if problem != "":
		return problem
	var ground: Array = row.prop_params.ground_y_m
	var points := PackedVector3Array()
	for index in line.size():
		var point: Variant = line[index]
		if not point is Array or (point as Array).size() != 3 or not (point[0] is float or point[0] is int) or not (point[2] is float or point[2] is int):
			return "a hedge point must be [x, y, z]"
		points.append(Vector3(float(point[0]), float(ground[index]), float(point[2])))
	var total := 0.0
	for index in range(1, points.size()):
		total += Vector2(points[index].x - points[index - 1].x, points[index].z - points[index - 1].z).length()
	if total < 0.1:
		return "a hedge must be at least 0.1 m long"
	var piece := KIT.HEDGE_PIECE_STATIONS * KIT.HEDGE_STEP_M
	var seed := hash(str(row.get("id", "")))
	var from := 0.0
	while from < total - 0.001:
		var to := minf(from + piece, total)
		# A tail too short to draw rides on this piece, which then keeps the hedge's end cap.
		if total - to < KIT.HEDGE_MIN_PIECE_M:
			to = total
		var lengths := 0.0
		var middle := points[0]
		# The piece's middle, for its cell.
		for index in range(1, points.size()):
			var span := Vector2(points[index].x - points[index - 1].x, points[index].z - points[index - 1].z).length()
			if lengths + span >= (from + to) * 0.5 or index == points.size() - 1:
				middle = points[index - 1].lerp(points[index], clampf(((from + to) * 0.5 - lengths) / maxf(span, 0.0001), 0.0, 1.0))
				break
			lengths += span
		var cell := _cell(middle, TREE_CELL_M)
		if not hedges.has(cell):
			hedges[cell] = []
		(hedges[cell] as Array).append({"variant": int(row.prop_params.variant), "points": points, "from_m": from, "to_m": to, "seed": seed})
		from = to
	return ""


## One cell's hedge pieces merged into a mesh per detail level (the kit's
## clipped_hedge ranges), the levels sharing the union of their boxes so they
## hand over at one distance.
func _build_hedge_cell(root: Node3D, kit: KIT, cell: String, pieces: Array) -> void:
	var ranges: Array = KIT.PROPS.clipped_hedge.ranges
	var meshes: Array[ArrayMesh] = []
	var box := AABB()
	for lod in 3:
		var surfs := {}
		for piece: Dictionary in pieces:
			kit.hedge_into(surfs, int(piece.variant), piece.points, float(piece.from_m), float(piece.to_m), lod, int(piece.seed))
		var mesh := ArrayMesh.new()
		var keys: Array = surfs.keys()
		keys.sort()
		for key: String in keys:
			surfs[key].commit(mesh, kit.material(key))
		meshes.append(mesh)
		box = mesh.get_aabb() if lod == 0 else box.merge(mesh.get_aabb())
	for lod in 3:
		var instance := MeshInstance3D.new()
		instance.name = "Hedges_%s__c%s" % [["lod0", "lod1", "far"][lod], cell]
		meshes[lod].custom_aabb = box
		instance.mesh = meshes[lod]
		instance.layers = RENDER_WORLD_VISIBLE
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if lod < 2 else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.visibility_range_begin = 0.0 if lod == 0 else float(ranges[lod - 1])
		instance.visibility_range_end = float(ranges[lod])
		instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
		instance.set_meta("street_detail_layer", "vegetation")
		instance.set_meta("placement_count", pieces.size())
		root.add_child(instance)


## A trunk capsule from one cap centre to the other (world space), shared by
## size: {id, shape, transform}. A capsule shape stands along its local +Y.
func _capsule(cache: Dictionary, id: String, from: Vector3, to: Vector3, radius: float) -> Dictionary:
	var length := from.distance_to(to)
	var key := "r%.3f_h%.3f" % [radius, length]
	if not cache.has(key):
		var shape := CapsuleShape3D.new()
		shape.radius = radius
		shape.height = length + radius * 2.0
		cache[key] = shape
	var direction := (to - from) / maxf(length, 1e-6)
	var basis := Basis(Quaternion(Vector3.UP, direction)) if direction.cross(Vector3.UP).length() > 1e-6 else Basis.IDENTITY
	return {"id": id, "shape": cache[key], "transform": Transform3D(basis, (from + to) * 0.5)}


## Round mulch pits on the plane of the paving round each tree: a fan each.
func _wells_mesh(entries: Array, material: Material) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	for entry: Dictionary in entries:
		var center: Vector3 = entry.center
		var radius: float = entry.radius
		var slope: Vector2 = entry.slope
		var normal := Vector3(-slope.x, 1.0, -slope.y).normalized()
		var first := vertices.size()
		var lift := KIT.WELL_LIFT_M
		vertices.append(center + Vector3(0.0, lift, 0.0))
		normals.append(normal)
		uvs.append(Vector2(center.x, center.z) / MULCH_TILE_M)
		# Darker toward the trunk and at the rim, where the paving edge shades it.
		colors.append(Color(0.82, 0.82, 0.82))
		for side in WELL_SIDES:
			var angle := TAU * side / WELL_SIDES
			var offset := Vector2(cos(angle), sin(angle)) * radius
			vertices.append(center + Vector3(offset.x, lift + slope.x * offset.x + slope.y * offset.y, offset.y))
			normals.append(normal)
			uvs.append(Vector2(center.x + offset.x, center.z + offset.y) / MULCH_TILE_M)
			colors.append(Color(0.7, 0.7, 0.7))
		for side in WELL_SIDES:
			# Clockwise seen from above (Godot's front face), so the pit faces up.
			indices.append_array(PackedInt32Array([first, first + 1 + side, first + 1 + (side + 1) % WELL_SIDES]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	return mesh


func _well_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = "street_vegetation_mulch_pit"
	material.albedo_texture = MULCH
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material
