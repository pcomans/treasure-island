class_name StreetVegetationBuilder
extends RefCounted
## Builds the trees, shrubs and low plants (grass clumps, perennials and bed shrubs) of
## PlayableWorld/StreetDetail/Vegetation from the placed vegetation rows that
## carry a street-vegetation kit prop (tools/lib/street-vegetation-generation.mjs
## places them and settles each foot on the visible ground;
## street_vegetation_kit.gd draws them). Low plants count as grass_clumps in the
## build report.
##
## Each prop variant's detail level is measured out per square cell: the levels of
## one cell share one box, so they measure their range from the same centre and
## hand over at exactly one distance (no hysteresis, which would draw both levels or
## neither for a moment); the last level's range is extended by the farthest
## instance's offset from that centre, so no tree vanishes early. Trees use small
## cells, so a hand-over happens close to each tree's own distance; low plants use
## larger ones and have a single short range (the newer ones dissolve before it
## ends, in their shader). They are drawn in large batches, one MultiMesh per
## variant, level and StreetDetailBatches.CELL_M cell, in which every instance keeps
## its small cell's range: its custom data holds that cell's centre and its level's
## mesh the range, which the vegetation shaders test (vegetation_band.gdshaderinc),
## so each one shows and hands over exactly where its small cell's MultiMesh did.
##
## A big tree's levels cast no shadow of their own: its kit shadow mesh does, a
## cheap outline drawn only into the shadow maps, measured per variant and
## SHADOW_CELL_M cell and batched like the levels, since most of a dense crown's
## primitives and draw calls were its shadow passes. Its range runs on past the
## impostor switch (the kit's SHADOW_RANGE_M), so the tree keeps its ground shadow
## there.
##
## Collision is the trunk only: capsules on the street-prop layer, which the
## player collides with and the spray ray stops on (never a receiver), while
## the camera arm ignores it, as for the street furniture. Crowns and low plants
## have none, so the jetpack flies through a crown. A tree standing in paving
## gets its round mulch pit, drawn just above the paving's plane in the shared
## wood-chip mulch (mulch_ground.gd).
##
## A tree whose trunk is thinner than the kit's BENDING_TRUNK_RADIUS_M (as its row
## places it) bends out of a car's way (game/scripts/vehicles/street_tree_bender.gd):
## its capsules go on bodies of their own (BendingTrunks__c, meta bends_under_cars),
## the same layers, so the player still stops at it while a live car passes through,
## and the root's bending_rows metadata lists each such tree: id -> {transform,
## radius, top, instances: [[MultiMeshInstance3D name, instance index], ...] (every
## detail level and its shadow mesh), shapes: [[body name, CollisionShape3D name],
## ...]}, in the world generated at startup and in the baked one alike.
##
## A hedge row (a vegetation line row of kind hedge carrying a hedge prop; the
## kit's hedge_into lays it) is cut into pieces of HEDGE_PIECE_STATIONS
## stations, and the pieces in each tree cell are measured out per detail level
## (the leafy core, its sprigs and stems), the levels sharing one box like the
## trees'; the cells' levels are merged into one mesh per level and large cell,
## each vertex carrying its tree cell's centre (_build_hedges). Hedges have no
## collision.

const KIT := preload("res://game/scripts/world/street_vegetation_kit.gd")
const MULCH_GROUND := preload("res://game/scripts/world/mulch_ground.gd")
## The pits draw the street planting strips' mulch material (MULCH_GROUND).
const WELL_MULCH_KEY := "street_kerb_planting"
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


static func _cell(position: Vector3, size_m: float) -> String:
	return "%d_%d" % [floori(position.x / size_m), floori(position.z / size_m)]


## shared_kit: a street-vegetation kit to build the species with (so another builder
## can reuse them), or null for a new one. With level_bands false the batches' instances
## carry no band (custom data w 0: the shaders draw them whenever their batch draws),
## for a gallery that shows one detail level at any distance (building_shots.gd).
func build(document: Dictionary, shared_kit: RefCounted = null, level_bands := true) -> Dictionary:
	var kit: KIT = shared_kit if shared_kit != null else KIT.new()
	var root := Node3D.new()
	root.name = "GeneratedStreetVegetation"
	# batch key -> {prop, variant, levels, cells: {cell -> [Transform3D]}}
	var batches: Dictionary = {}
	# batch key -> {mesh, end_m, cells: {shadow cell -> [Transform3D]}}
	var shadows: Dictionary = {}
	# physics cell -> [{id, shape, transform}], and the same for the trunks that bend
	# under a car
	var shapes: Dictionary = {}
	var bend_shapes: Dictionary = {}
	# id -> a bending tree's entry, its refs by batch key, cell and index until the
	# nodes are named
	var bending: Dictionary = {}
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
		var foot := Vector3(float(position[0]), float(position[1]) + float(surface.get("bias_m", 0.0)) + float(params.lift_m) + float(params.get("stand_m", 0.0)), float(position[2]))
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
		# A tree with a trunk thinner than BENDING_TRUNK_RADIUS_M bends under a car.
		var trunk_m := float((proto.capsules as Array)[0].radius_m) * scale if not (proto.capsules as Array).is_empty() else 0.0
		var bends := trunk_m > 0.0 and trunk_m < KIT.BENDING_TRUNK_RADIUS_M
		var entry: Dictionary = {}
		if bends:
			entry = {"transform": placement, "radius": trunk_m, "top": float(proto.get("top_m", 0.0)) * scale, "instances": [], "shapes": []}
			bending[str(row.id)] = entry
			(entry.instances as Array).append(["levels", key, cell, (cells[cell] as Array).size()])
		(cells[cell] as Array).append(placement)
		if proto.has("shadow"):
			if not shadows.has(key):
				shadows[key] = {"mesh": proto.shadow.mesh, "end_m": proto.shadow.end_m, "cells": {}}
			var shadow_cells: Dictionary = shadows[key].cells
			var shadow_cell := _cell(foot, SHADOW_CELL_M)
			if not shadow_cells.has(shadow_cell):
				shadow_cells[shadow_cell] = []
			if bends:
				(entry.instances as Array).append(["shadow", key, shadow_cell, (shadow_cells[shadow_cell] as Array).size()])
			(shadow_cells[shadow_cell] as Array).append(placement)
		var physics_cell := _cell(foot, PHYSICS_CELL_M)
		var trunk_shapes := bend_shapes if bends else shapes
		for capsule: Dictionary in proto.capsules:
			if not trunk_shapes.has(physics_cell):
				trunk_shapes[physics_cell] = []
			if bends:
				(entry.shapes as Array).append([physics_cell, (trunk_shapes[physics_cell] as Array).size()])
			(trunk_shapes[physics_cell] as Array).append(_capsule(capsules, str(row.id), placement * (capsule.from as Vector3), placement * (capsule.to as Vector3), float(capsule.radius_m) * scale))
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
	# Each small cell's levels go into the large batches (StreetDetailBatches): an
	# instance keeps its small cell's range, from that cell's box centre (its band).
	# batch node name -> its batch; (level name, key, small cell, index) -> [node name,
	# index in the batch], for the bending trees.
	var large: Dictionary = {}
	var placed_at: Dictionary = {}
	var banded: Dictionary = {}
	var bands: Dictionary = {}
	var batch_keys: Array = batches.keys()
	batch_keys.sort()
	for key: String in batch_keys:
		var batch: Dictionary = batches[key]
		var levels: Array = batch.levels
		var level_meshes: Array = levels.map(func(level: Dictionary) -> Mesh: return level.mesh)
		for level_index in levels.size():
			var level: Dictionary = levels[level_index]
			var problem := StreetDetailBatches.band_mesh(level.mesh, float(level.begin_m), float(level.end_m), bands, banded) if level_bands else ""
			if problem != "":
				root.free()
				return {"ok": false, "code": "street_vegetation_band", "message": "%s: %s" % [key, problem], "source_keys": []}
		var cell_keys: Array = (batch.cells as Dictionary).keys()
		cell_keys.sort()
		for cell: String in cell_keys:
			var transforms: Array = batch.cells[cell]
			# One box for every level of the cell (the union of their meshes): its centre
			# is where the small cell measured its levels' ranges from.
			var bounds := _cell_bounds(transforms, level_meshes)
			var centre: Vector3 = (bounds.box as AABB).get_center()
			var boxes: Array = bounds.boxes
			for level_index in levels.size():
				var level: Dictionary = levels[level_index]
				# The last level ran on past its end by the farthest tree's offset.
				var extra := ceilf(float(bounds.slack)) if level_index == levels.size() - 1 else 0.0
				var cast := GeometryInstance3D.SHADOW_CASTING_SETTING_ON if bool(level.shadow) else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				for index in transforms.size():
					var xf: Transform3D = transforms[index]
					var node_name := "%s_%s__c%s" % [key, level.name, StreetDetailBatches.cell(xf.origin)]
					if not large.has(node_name):
						large[node_name] = StreetDetailBatches.batch(level.mesh, cast, float(level.begin_m), float(level.end_m))
					var custom := StreetDetailBatches.vegetation_custom(xf, centre, extra) if level_bands else Color(0, 0, 0, 0)
					var at := StreetDetailBatches.add(large[node_name], xf, boxes[index], centre, extra, custom)
					placed_at["%s|%s|%s|%d" % [level.name, key, cell, index]] = [node_name, at]
	var shadow_keys: Array = shadows.keys()
	shadow_keys.sort()
	for key: String in shadow_keys:
		var batch: Dictionary = shadows[key]
		var problem := StreetDetailBatches.band_mesh(batch.mesh, 0.0, float(batch.end_m), bands, banded) if level_bands else ""
		if problem != "":
			root.free()
			return {"ok": false, "code": "street_vegetation_band", "message": "%s shadow: %s" % [key, problem], "source_keys": []}
		var cell_keys: Array = (batch.cells as Dictionary).keys()
		cell_keys.sort()
		for cell: String in cell_keys:
			# A shadow cell's trees of one variant cast out to end_m past the farthest
			# of them from the cell's centre.
			var transforms: Array = batch.cells[cell]
			var bounds := _cell_bounds(transforms, [batch.mesh])
			var centre: Vector3 = (bounds.box as AABB).get_center()
			var extra := ceilf(float(bounds.slack))
			for index in transforms.size():
				var xf: Transform3D = transforms[index]
				var node_name := "%s_shadow__c%s" % [key, StreetDetailBatches.cell(xf.origin)]
				if not large.has(node_name):
					large[node_name] = StreetDetailBatches.batch(batch.mesh, GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY, 0.0, float(batch.end_m))
				var custom := StreetDetailBatches.vegetation_custom(xf, centre, extra) if level_bands else Color(0, 0, 0, 0)
				var at := StreetDetailBatches.add(large[node_name], xf, bounds.boxes[index], centre, extra, custom)
				placed_at["shadow|%s|%s|%d" % [key, cell, index]] = [node_name, at]
	var multimeshes := 0
	var node_names: Array = large.keys()
	node_names.sort()
	for node_name: String in node_names:
		var instance := StreetDetailBatches.node(large[node_name], node_name, true)
		instance.layers = RENDER_WORLD_VISIBLE
		instance.set_meta("street_detail_layer", "vegetation")
		root.add_child(instance)
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
	_build_hedges(root, kit, hedges, bands if level_bands else {})
	var shape_count := 0
	for trunk_set: Array in [[shapes, "Trunks__c%s", false], [bend_shapes, "BendingTrunks__c%s", true]]:
		var by_cell: Dictionary = trunk_set[0]
		var shape_cells: Array = by_cell.keys()
		shape_cells.sort()
		for cell: String in shape_cells:
			var body := StaticBody3D.new()
			body.name = str(trunk_set[1]) % cell
			body.collision_layer = PHYSICS_STREET_PROP | PHYSICS_SPRAY_SURFACE
			body.collision_mask = 0
			body.set_meta("feature_kind", "street_vegetation")
			body.set_meta("receiver_kind", "none")
			body.set_meta("opaque", true)
			if bool(trunk_set[2]):
				body.set_meta("bends_under_cars", true)
			var ids := PackedStringArray()
			for entry: Dictionary in by_cell[cell]:
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
	# The bending trees' refs: each level's batch and index, then its shadow mesh's.
	for id: String in bending:
		var entry: Dictionary = bending[id]
		var named: Array = []
		for ref: Array in entry.instances:
			if str(ref[0]) == "shadow":
				named.append(placed_at["shadow|%s|%s|%d" % [ref[1], ref[2], ref[3]]])
			else:
				for level: Dictionary in batches[ref[1]].levels:
					named.append(placed_at["%s|%s|%s|%d" % [level.name, ref[1], ref[2], ref[3]]])
		entry.instances = named
		entry.shapes = (entry.shapes as Array).map(func(ref: Array) -> Array: return ["BendingTrunks__c%s" % ref[0], "Shape%d" % ref[1]])
	root.set_meta("bending_rows", bending)
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


## The box round a small cell's instances (the union of the meshes at each), each
## instance's own box and the farthest instance's offset from the box's centre:
## {box, boxes, slack}.
func _cell_bounds(transforms: Array, meshes: Array) -> Dictionary:
	var box := AABB()
	var boxes: Array[AABB] = []
	for index in transforms.size():
		var tree_box := AABB()
		for mesh_index in meshes.size():
			var mesh_box: AABB = (transforms[index] as Transform3D) * (meshes[mesh_index] as Mesh).get_aabb()
			tree_box = mesh_box if mesh_index == 0 else tree_box.merge(mesh_box)
		box = tree_box if index == 0 else box.merge(tree_box)
		boxes.append(tree_box)
	var slack := 0.0
	for tree_box: AABB in boxes:
		slack = maxf(slack, tree_box.get_center().distance_to(box.get_center()))
	return {"box": box, "boxes": boxes, "slack": slack}


## Checks a hedge row and files its pieces under the tree cells of their
## middles: {variant, points (x, the visible ground's height, z), from_m, to_m,
## seed}. Returns what is wrong with the row, or "".
func _add_hedge(hedges: Dictionary, row: Dictionary) -> String:
	var points_value: Variant = row.get("points_m", null)
	if str(row.get("geometry", "")) != "polyline" or not points_value is Array:
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


## The hedge pieces of each tree cell, merged per detail level (the kit's
## clipped_hedge ranges): a cell's levels share the union of their boxes, so they
## hand over at one distance from its centre. The cells' levels are merged further,
## into one mesh per StreetDetailBatches.CELL_M cell and level, each vertex carrying
## its tree cell's centre (CUSTOM0), which the vegetation shaders test the level's
## range from (vegetation_band.gdshaderinc), so each cell's hedges show and hand
## over exactly where the cell's own meshes did. bands: the band materials (empty:
## no band test, for a gallery that shows one level at any distance).
func _build_hedges(root: Node3D, kit: KIT, hedges: Dictionary, bands: Dictionary) -> void:
	var ranges: Array = KIT.PROPS.clipped_hedge.ranges
	var names := ["lod0", "lod1", "far"]
	# large cell -> [per level: {material key -> merged arrays}], and its batches
	# (StreetDetailBatches) for each level's box and coarse range.
	var merged: Dictionary = {}
	var batches: Dictionary = {}
	var cells: Array = hedges.keys()
	cells.sort()
	for cell: String in cells:
		var pieces: Array = hedges[cell]
		var levels: Array[Dictionary] = []
		var box := AABB()
		for lod in 3:
			var surfs := {}
			for piece: Dictionary in pieces:
				kit.hedge_into(surfs, int(piece.variant), piece.points, float(piece.from_m), float(piece.to_m), lod, int(piece.seed))
			levels.append(surfs)
			var level_box := _surfs_box(surfs)
			box = level_box if lod == 0 else box.merge(level_box)
		var centre := box.get_center()
		var large := StreetDetailBatches.cell(centre)
		if not merged.has(large):
			merged[large] = [{}, {}, {}]
			batches[large] = []
			for lod in 3:
				var cast := GeometryInstance3D.SHADOW_CASTING_SETTING_ON if lod < 2 else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				(batches[large] as Array).append(StreetDetailBatches.batch(null, cast, 0.0 if lod == 0 else float(ranges[lod - 1]), float(ranges[lod])))
		for lod in 3:
			var into: Dictionary = merged[large][lod]
			var keys: Array = levels[lod].keys()
			keys.sort()
			for key: String in keys:
				_merge_surf(into, key, levels[lod][key], centre)
			StreetDetailBatches.add(batches[large][lod], Transform3D.IDENTITY, box, centre, 0.0, Color(0, 0, 0, 0))
			batches[large][lod]["pieces"] = int(batches[large][lod].get("pieces", 0)) + pieces.size()
	var large_cells: Array = merged.keys()
	large_cells.sort()
	for large: String in large_cells:
		for lod in 3:
			var batch: Dictionary = batches[large][lod]
			var mesh := ArrayMesh.new()
			var keys: Array = (merged[large][lod] as Dictionary).keys()
			keys.sort()
			for key: String in keys:
				var arrays_of: Dictionary = merged[large][lod][key]
				var arrays := []
				arrays.resize(Mesh.ARRAY_MAX)
				arrays[Mesh.ARRAY_VERTEX] = arrays_of.verts
				arrays[Mesh.ARRAY_NORMAL] = arrays_of.normals
				arrays[Mesh.ARRAY_TEX_UV] = arrays_of.uvs
				arrays[Mesh.ARRAY_TEX_UV2] = arrays_of.uv2s
				arrays[Mesh.ARRAY_COLOR] = arrays_of.colors
				arrays[Mesh.ARRAY_INDEX] = arrays_of.indices
				var flags := 0
				var material: Material = kit.material(key)
				if not bands.is_empty():
					arrays[Mesh.ARRAY_CUSTOM0] = arrays_of.centres
					flags = Mesh.ARRAY_CUSTOM_RGB_FLOAT << Mesh.ARRAY_FORMAT_CUSTOM0_SHIFT
					material = StreetDetailBatches.band_material(material as ShaderMaterial, float(batch.begin), float(batch.end), bands, Vector3.INF, true)
				mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, flags)
				mesh.surface_set_material(mesh.get_surface_count() - 1, material)
			mesh.custom_aabb = batch.box
			var instance := MeshInstance3D.new()
			instance.name = "Hedges_%s__c%s" % [names[lod], large]
			instance.mesh = mesh
			instance.layers = RENDER_WORLD_VISIBLE
			instance.cast_shadow = batch.cast
			var coarse := StreetDetailBatches.coarse_range(batch)
			instance.visibility_range_begin = coarse.x
			instance.visibility_range_end = coarse.y
			instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
			instance.set_meta("street_detail_layer", "vegetation")
			instance.set_meta("placement_count", int(batch.pieces))
			root.add_child(instance)


## A level's box as an ArrayMesh of these surfaces would have it (Surf.commit adds
## the surfaces that have triangles; no surface: an empty box at the origin).
static func _surfs_box(surfs: Dictionary) -> AABB:
	var box := AABB()
	var first := true
	for surf: Variant in surfs.values():
		if surf.indices.is_empty():
			continue
		for vertex: Vector3 in surf.verts:
			if first:
				box = AABB(vertex, Vector3.ZERO)
				first = false
			else:
				box = box.expand(vertex)
	return box


## Appends a cell's surface of one material to the large cell's merged arrays, every
## vertex carrying the cell's centre.
static func _merge_surf(into: Dictionary, key: String, surf: Variant, centre: Vector3) -> void:
	if surf.indices.is_empty():
		return
	if not into.has(key):
		into[key] = {"verts": PackedVector3Array(), "normals": PackedVector3Array(), "uvs": PackedVector2Array(), "uv2s": PackedVector2Array(), "colors": PackedColorArray(), "indices": PackedInt32Array(), "centres": PackedFloat32Array()}
	var arrays: Dictionary = into[key]
	var base: int = (arrays.verts as PackedVector3Array).size()
	var verts: PackedVector3Array = arrays.verts
	verts.append_array(surf.verts)
	arrays.verts = verts
	var normals: PackedVector3Array = arrays.normals
	normals.append_array(surf.normals)
	arrays.normals = normals
	var uvs: PackedVector2Array = arrays.uvs
	uvs.append_array(surf.uvs)
	arrays.uvs = uvs
	var uv2s: PackedVector2Array = arrays.uv2s
	uv2s.append_array(surf.uv2s)
	arrays.uv2s = uv2s
	var colors: PackedColorArray = arrays.colors
	colors.append_array(surf.colors)
	arrays.colors = colors
	var indices: PackedInt32Array = arrays.indices
	for index: int in surf.indices:
		indices.append(base + index)
	arrays.indices = indices
	var centres: PackedFloat32Array = arrays.centres
	for _vertex in (surf.verts as PackedVector3Array).size():
		centres.append_array([centre.x, centre.y, centre.z])
	arrays.centres = centres


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
		# Darker toward the trunk and at the rim, where the paving edge shades it.
		colors.append(Color(0.82, 0.82, 0.82))
		for side in WELL_SIDES:
			var angle := TAU * side / WELL_SIDES
			var offset := Vector2(cos(angle), sin(angle)) * radius
			vertices.append(center + Vector3(offset.x, lift + slope.x * offset.x + slope.y * offset.y, offset.y))
			normals.append(normal)
			colors.append(Color(0.7, 0.7, 0.7))
		for side in WELL_SIDES:
			# Clockwise seen from above (Godot's front face), so the pit faces up.
			indices.append_array(PackedInt32Array([first, first + 1 + side, first + 1 + (side + 1) % WELL_SIDES]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	return mesh


## The pits' material: the shared mulch, which takes the pits' vertex colour (the
## shade toward the trunk and the rim) as a multiplier.
func _well_material() -> ShaderMaterial:
	return MULCH_GROUND.material(WELL_MULCH_KEY)
