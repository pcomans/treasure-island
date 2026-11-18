extends SceneTree
## The street detail's large batches (game/scripts/world/street_detail_batches.gd, with
## street_vegetation_builder.gd and street_clutter_builder.gd), built headless from
## hand-placed rows: trees alone and sharing a small cell, low plants, a hedge, cones
## and parked cars alone and together.
## - For camera points round them (on every level's hand-over and past it, near and far,
##   low and high), every level draws exactly the instances its small cell's own node
##   drew: the small cell's range from its box's centre, against the batch's coarse range
##   from the batch's box centre and then each instance's band, as the shaders test it
##   (vegetation_band.gdshaderinc: the small cell's centre in the custom data and the
##   level's range on the level mesh's materials; a merged hedge's centres per vertex in
##   CUSTOM0; a lone car's or yard piece's own centre and range on its batch's material).
## - Every placed instance is in exactly one batch of each of its levels.
## - The interactive refs (bending trees, parked cars a car can take) name the batch and
##   index whose instance stands at the row's placement.
## - The vegetation, hedge and clutter shaders carry the band test.

const VEGETATION_KIT := preload("res://game/scripts/world/street_vegetation_kit.gd")
const CLUTTER_KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
const BATCHES := preload("res://game/scripts/world/street_detail_batches.gd")
const TREE_CELL_M := 16.0
const GRASS_CELL_M := 32.0
const SHADOW_CELL_M := 48.0

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_shaders()
	var vegetation := StreetVegetationBuilder.new().build({"rows": _vegetation_rows()})
	if not vegetation.ok:
		_fail("the vegetation did not build: %s" % vegetation.get("message", ""))
	else:
		var node: Node3D = vegetation.node
		root.add_child(node)
		_check_vegetation(node)
		_check_hedges(node)
		_check_bending(node)
	var clutter := StreetClutterBuilder.new().build({"rows": _clutter_rows()})
	if not clutter.ok:
		_fail("the clutter did not build: %s" % clutter.get("message", ""))
	else:
		var node: Node3D = clutter.node
		root.add_child(node)
		_check_clutter(node)
	await process_frame
	if failures.is_empty():
		print("PASS: street-detail batches draw every tree, plant, hedge and lone car at the levels its small cell drew, from every camera point tried (hand-overs and ends, near and far, low and high); each placed instance is in one batch per level; bending trees and parked cars find their own instances; the vegetation, hedge and clutter shaders test the bands")
		quit(0)
	else:
		for failure: String in failures:
			push_error("FAIL: " + failure)
		quit(1)


func _fail(message: String) -> void:
	if failures.size() < 30:
		failures.append(message)


# --- Fixtures -----------------------------------------------------------------------


func _plant(id: String, prop: String, variant: int, x: float, z: float, yaw := 0.0, scale := 1.0) -> Dictionary:
	var params := {"variant": variant, "scale": scale, "lift_m": 0.0, "foot_spread_m": 0.0, "well_m": 0.0}
	return {"id": id, "status": "placed", "layer": "vegetation", "kind": str((VEGETATION_KIT.PROPS[prop].kinds as Array)[0]), "prop": prop,
		"prop_params": params, "position_m": [x, 1.5, z], "surface": {"bias_m": 0.0}, "yaw_radians": yaw}


func _vegetation_rows() -> Array:
	return [
		# Two young gums sharing a tree cell, one alone; they bend under a car.
		_plant("gum_a", "sydney_blue_gum_young", 0, 3.0, 4.0, 0.3),
		_plant("gum_b", "sydney_blue_gum_young", 0, 13.0, 11.0, 1.9),
		_plant("gum_c", "sydney_blue_gum_young", 0, 41.0, 6.0),
		# Big broadleaves (a shadow mesh each): two in one tree cell and shadow cell, one alone.
		_plant("oak_a", "spreading_broadleaf", 1, 70.0, 66.0, 0.5),
		_plant("oak_b", "spreading_broadleaf", 1, 78.0, 75.0, 2.5, 0.9),
		_plant("oak_c", "spreading_broadleaf", 1, -130.0, 210.0),
		# Low plants: three in one grass cell, one far off.
		_plant("sedge_a", "dense_sedge", 0, 100.0, 4.0),
		_plant("sedge_b", "dense_sedge", 0, 110.0, 20.0, 1.0),
		_plant("sedge_c", "dense_sedge", 0, 125.0, 30.0, 2.0),
		_plant("sedge_d", "dense_sedge", 0, -300.0, -260.0),
		# A hedge across two tree cells.
		{"id": "hedge_a", "status": "placed", "layer": "vegetation", "kind": "hedge", "geometry": "polyline", "prop": "clipped_hedge",
			"prop_params": {"variant": 0, "ground_y_m": [1.5, 1.5, 1.5]}, "points_m": [[-20.0, 1.5, -20.0], [-2.0, 1.5, -18.0], [12.0, 1.5, -30.0]]},
	]


func _clutter_rows() -> Array:
	var car := func(id: String, body: String, x: float, z: float, yaw: float) -> Dictionary:
		return {"id": id, "status": "placed", "layer": "clutter", "prop": "parked_car", "prop_params": {"body": body, "paint": "white", "finish": "solid", "dirt": 0.2},
			"position_m": [x, 1.5, z], "surface": {"bias_m": 0.0, "kind": "road"}, "yaw_radians": yaw}
	var cone := func(id: String, x: float, z: float) -> Dictionary:
		return {"id": id, "status": "placed", "layer": "clutter", "prop": "traffic_cone", "prop_params": {}, "position_m": [x, 1.5, z], "surface": {"bias_m": 0.0}, "yaw_radians": 0.0}
	return [
		car.call("car_a", "sedan", 5.0, 5.0, 0.0), car.call("car_b", "sedan", 9.0, 15.0, 1.2),
		car.call("car_c", "sedan", 300.0, 40.0, 2.0), car.call("car_d", "suv", -200.0, -70.0, 0.4),
		cone.call("cone_a", 50.0, 50.0), cone.call("cone_b", 52.0, 53.0), cone.call("cone_c", 400.0, -150.0),
	]


# --- The rule each side draws by ----------------------------------------------------


## Whether the renderer draws a node seen from camera: its visibility range from its
## box centre (fade off, no margins: begin <= distance <= end).
static func _node_draws(begin_m: float, end_m: float, centre: Vector3, camera: Vector3) -> bool:
	var away := camera.distance_to(centre)
	return (end_m <= 0.0 or away <= end_m) and (begin_m <= 0.0 or away >= begin_m)


## The band test of vegetation_band.gdshaderinc and the clutter shaders.
static func _band_draws(band: Vector2, reference: Vector3, extra_m: float, camera: Vector3) -> bool:
	var away := camera.distance_to(reference)
	return away >= band.x and away <= band.y + extra_m


## Camera points round a set of references: on each level's begin and end (just
## inside and outside), and a spread of distances, low and high.
static func _cameras(references: Array, distances: Array) -> Array[Vector3]:
	var cameras: Array[Vector3] = []
	var directions := [Vector3(1, 0, 0), Vector3(-0.6, 0, 0.8), Vector3(0, 0, -1), Vector3(0.7, 0.2, 0.69).normalized()]
	for reference: Vector3 in references:
		for distance: float in distances:
			for offset: float in [-0.05, 0.05]:
				for direction: Vector3 in directions:
					cameras.append(reference + direction * maxf(0.0, distance + offset) + Vector3(0, 1.7, 0))
	for x in range(-600, 601, 150):
		for z in range(-600, 601, 150):
			for y: float in [3.0, 60.0]:
				cameras.append(Vector3(x, y, z))
	return cameras


# --- Vegetation ------------------------------------------------------------------


## The small cells' nodes the vegetation was drawn in before its large batches: [{level
## mesh, begin, end (its last level's run on), centre, transforms}], from the rows and
## the kit as street_vegetation_builder.gd measured them.
func _small_cells() -> Array[Dictionary]:
	var kit := VEGETATION_KIT.new()
	var cells: Dictionary = {}
	var shadow_cells: Dictionary = {}
	for row: Dictionary in _vegetation_rows():
		if VEGETATION_KIT.is_hedge(str(row.prop)):
			continue
		var proto := kit.prototype(str(row.prop), int(row.prop_params.variant))
		var foot := Vector3(row.position_m[0], row.position_m[1], row.position_m[2])
		var placement := Transform3D(Basis(Vector3.UP, float(row.yaw_radians)).scaled(Vector3.ONE * float(row.prop_params.scale)), foot)
		var size := GRASS_CELL_M if VEGETATION_KIT.is_low_plant(str(row.prop)) else TREE_CELL_M
		var key := "%s_%d|%d_%d" % [row.prop, int(row.prop_params.variant), floori(foot.x / size), floori(foot.z / size)]
		if not cells.has(key):
			cells[key] = {"levels": proto.levels, "transforms": []}
		(cells[key].transforms as Array).append(placement)
		if proto.has("shadow"):
			var shadow_key := "%s_%d|%d_%d" % [row.prop, int(row.prop_params.variant), floori(foot.x / SHADOW_CELL_M), floori(foot.z / SHADOW_CELL_M)]
			if not shadow_cells.has(shadow_key):
				shadow_cells[shadow_key] = {"levels": [{"name": "shadow", "mesh": proto.shadow.mesh, "begin_m": 0.0, "end_m": proto.shadow.end_m}], "transforms": []}
			(shadow_cells[shadow_key].transforms as Array).append(placement)
	var nodes: Array[Dictionary] = []
	for group: Dictionary in [cells, shadow_cells]:
		for key: String in group:
			var cell: Dictionary = group[key]
			var box := AABB()
			var first := true
			var centres: Array[Vector3] = []
			for xf: Transform3D in cell.transforms:
				var tree := AABB()
				for index in (cell.levels as Array).size():
					var mesh_box: AABB = xf * ((cell.levels[index].mesh as Mesh).get_aabb())
					tree = mesh_box if index == 0 else tree.merge(mesh_box)
				box = tree if first else box.merge(tree)
				first = false
				centres.append(tree.get_center())
			var slack := 0.0
			for centre: Vector3 in centres:
				slack = maxf(slack, centre.distance_to(box.get_center()))
			for index in (cell.levels as Array).size():
				var level: Dictionary = cell.levels[index]
				var last := index == (cell.levels as Array).size() - 1
				nodes.append({"name": str(level.name), "begin": float(level.begin_m), "end": float(level.end_m) + (ceilf(slack) if last else 0.0), "centre": box.get_center(), "transforms": cell.transforms, "kind": key.get_slice("|", 0)})
	return nodes


## Each vegetation batch's instances: [{name (level), kind, transform, reference,
## extra, band, node begin, end and centre}].
func _batched(root_node: Node3D) -> Array[Dictionary]:
	var instances: Array[Dictionary] = []
	for child: Node in root_node.get_children():
		if not child is MultiMeshInstance3D:
			continue
		var node := child as MultiMeshInstance3D
		var multimesh := node.multimesh
		if not multimesh.use_custom_data or not multimesh.use_colors:
			_fail("%s: a vegetation batch carries white colours and custom data (colours %s, custom %s)" % [node.name, multimesh.use_colors, multimesh.use_custom_data])
			continue
		var band := Vector2.ZERO
		for surface in multimesh.mesh.get_surface_count():
			var material := multimesh.mesh.surface_get_material(surface) as ShaderMaterial
			var this_band: Variant = material.get_shader_parameter(BATCHES.BAND_UNIFORM) if material != null else null
			if not this_band is Vector2 or (surface > 0 and this_band != band):
				_fail("%s: surface %d of its mesh has no band or another (%s)" % [node.name, surface, this_band])
			band = this_band if this_band is Vector2 else band
		var parts := str(node.name).rsplit("__c", true, 1)
		var level := parts[0].get_slice("_", parts[0].get_slice_count("_") - 1)
		var kind := parts[0].substr(0, parts[0].length() - level.length() - 1)
		var centre := multimesh.custom_aabb.get_center()
		for index in multimesh.instance_count:
			var read := BATCHES.read(multimesh, index)
			var xf: Transform3D = read[0]
			var custom: Color = read[1]
			if custom.a < 0.5:
				_fail("%s %d has no band (w %s)" % [node.name, index, custom.a])
			instances.append({"name": level, "kind": kind, "transform": xf, "reference": xf.origin + Vector3(custom.r, custom.g, custom.b), "extra": custom.a - 1.0,
				"band": band, "begin": node.visibility_range_begin, "end": node.visibility_range_end, "centre": centre})
	return instances


func _check_vegetation(root_node: Node3D) -> void:
	var small := _small_cells()
	var batched := _batched(root_node)
	# Every placed instance in exactly one batch of each of its levels.
	var expected := {}
	for node: Dictionary in small:
		for xf: Transform3D in node.transforms:
			var key := "%s|%s|%s" % [node.kind, node.name, xf.origin]
			expected[key] = int(expected.get(key, 0)) + 1
	var found := {}
	for instance: Dictionary in batched:
		var key := "%s|%s|%s" % [instance.kind, instance.name, (instance.transform as Transform3D).origin]
		found[key] = int(found.get(key, 0)) + 1
	if expected != found:
		_fail("vegetation instances per level differ: small cells %s, batches %s" % [expected, found])
	var references: Array = []
	for node: Dictionary in small:
		references.append(node.centre)
	var cameras := _cameras(references, [0.0, 25.0, 30.0, 35.0, 40.0, 45.0, 55.0, 60.0, 75.0, 90.0, 95.0, 100.0, 110.0, 160.0, 220.0, 230.0, 700.0, 900.0, 910.0])
	var differ := 0
	for camera: Vector3 in cameras:
		var before := {}
		for node: Dictionary in small:
			if _node_draws(float(node.begin), float(node.end), node.centre, camera):
				for xf: Transform3D in node.transforms:
					before["%s|%s|%s" % [node.kind, node.name, xf.origin]] = true
		var after := {}
		for instance: Dictionary in batched:
			if _node_draws(float(instance.begin), float(instance.end), instance.centre, camera) and _band_draws(instance.band, instance.reference, float(instance.extra), camera):
				after["%s|%s|%s" % [instance.kind, instance.name, (instance.transform as Transform3D).origin]] = true
		if before != after:
			differ += 1
			if differ <= 3:
				_fail("from %s the small cells drew %s but the batches %s" % [camera, before.keys(), after.keys()])
	if differ > 0:
		_fail("%d of %d camera points draw different vegetation" % [differ, cameras.size()])
	print("VEGETATION batches=%d instances=%d small_cell_nodes=%d cameras=%d" % [root_node.get_children().filter(func(n: Node) -> bool: return n is MultiMeshInstance3D).size(), batched.size(), small.size(), cameras.size()])


func _check_hedges(root_node: Node3D) -> void:
	# The hedge as its tree cells drew it: per cell, each level's mesh and the union box.
	var kit := VEGETATION_KIT.new()
	var probe := StreetVegetationBuilder.new()
	var hedges := {}
	for row: Dictionary in _vegetation_rows():
		if VEGETATION_KIT.is_hedge(str(row.prop)):
			probe._add_hedge(hedges, row)
	var ranges: Array = VEGETATION_KIT.PROPS.clipped_hedge.ranges
	var small: Array[Dictionary] = []
	for cell: String in hedges:
		var box := AABB()
		var counts: Array[int] = []
		for lod in 3:
			var surfs := {}
			for piece: Dictionary in hedges[cell]:
				kit.hedge_into(surfs, int(piece.variant), piece.points, float(piece.from_m), float(piece.to_m), lod, int(piece.seed))
			var mesh := ArrayMesh.new()
			var vertices := 0
			for key: String in surfs:
				surfs[key].commit(mesh, kit.material(key))
				vertices += (surfs[key].verts as PackedVector3Array).size() if not (surfs[key].indices as PackedInt32Array).is_empty() else 0
			counts.append(vertices)
			box = mesh.get_aabb() if lod == 0 else box.merge(mesh.get_aabb())
		for lod in 3:
			small.append({"lod": lod, "centre": box.get_center(), "begin": 0.0 if lod == 0 else float(ranges[lod - 1]), "end": float(ranges[lod]), "vertices": counts[lod]})
	# The merged hedges: each surface's vertices by their CUSTOM0 centre.
	var merged: Array[Dictionary] = []
	for child: Node in root_node.get_children():
		if not child is MeshInstance3D or not str(child.name).begins_with("Hedges_"):
			continue
		var node := child as MeshInstance3D
		var lod := ["lod0", "lod1", "far"].find(str(node.name).trim_prefix("Hedges_").get_slice("__", 0))
		var mesh := node.mesh as ArrayMesh
		for surface in mesh.get_surface_count():
			var material := mesh.surface_get_material(surface) as ShaderMaterial
			var band: Variant = material.get_shader_parameter(BATCHES.BAND_UNIFORM) if material != null else null
			if not band is Vector2 or material.get_shader_parameter(BATCHES.BY_VERTEX_UNIFORM) != true:
				_fail("%s surface %d does not test its band by vertex" % [node.name, surface])
				continue
			if mesh.surface_get_format(surface) & Mesh.ARRAY_FORMAT_CUSTOM0 == 0:
				_fail("%s surface %d has no CUSTOM0 centres" % [node.name, surface])
				continue
			var centres: PackedFloat32Array = mesh.surface_get_arrays(surface)[Mesh.ARRAY_CUSTOM0]
			var by_centre := {}
			for at in range(0, centres.size(), 3):
				var centre := Vector3(centres[at], centres[at + 1], centres[at + 2])
				by_centre[centre] = int(by_centre.get(centre, 0)) + 1
			for centre: Vector3 in by_centre:
				merged.append({"lod": lod, "centre": centre, "band": band, "vertices": by_centre[centre], "begin": node.visibility_range_begin, "end": node.visibility_range_end, "node_centre": mesh.custom_aabb.get_center()})
	if merged.is_empty():
		_fail("no merged hedges")
		return
	# Same vertices per cell and level.
	var expected := {}
	for cell: Dictionary in small:
		if int(cell.vertices) > 0:
			expected["%d|%s" % [cell.lod, cell.centre]] = int(cell.vertices)
	var found := {}
	for part: Dictionary in merged:
		var key := "%d|%s" % [part.lod, part.centre]
		found[key] = int(found.get(key, 0)) + int(part.vertices)
	if expected != found:
		_fail("hedge vertices per cell and level differ: cells %s, merged %s" % [expected, found])
	var references: Array = small.map(func(cell: Dictionary) -> Vector3: return cell.centre)
	var differ := 0
	var cameras := _cameras(references, [0.0, 44.0, 45.0, 46.0, 99.0, 100.0, 101.0, 169.0, 170.0, 171.0, 400.0])
	for camera: Vector3 in cameras:
		var before := {}
		for cell: Dictionary in small:
			if int(cell.vertices) > 0 and _node_draws(float(cell.begin), float(cell.end), cell.centre, camera):
				before["%d|%s" % [cell.lod, cell.centre]] = true
		var after := {}
		for part: Dictionary in merged:
			if _node_draws(float(part.begin), float(part.end), part.node_centre, camera) and _band_draws(part.band, part.centre, 0.0, camera):
				after["%d|%s" % [part.lod, part.centre]] = true
		if before != after:
			differ += 1
			if differ <= 3:
				_fail("from %s the hedge's cells drew %s but the merged hedges %s" % [camera, before.keys(), after.keys()])
	if differ > 0:
		_fail("%d of %d camera points draw a different hedge" % [differ, cameras.size()])


func _check_bending(root_node: Node3D) -> void:
	var listed: Dictionary = root_node.get_meta("bending_rows", {})
	if not listed.has("gum_a") or not listed.has("gum_b") or not listed.has("gum_c"):
		_fail("the young gums are not listed as bending: %s" % listed.keys())
		return
	var proto := VEGETATION_KIT.new().prototype("sydney_blue_gum_young", 0)
	var expected_refs: int = (proto.levels as Array).size() + (1 if proto.has("shadow") else 0)
	for id: String in listed:
		var entry: Dictionary = listed[id]
		var placement: Transform3D = entry.transform
		var levels := 0
		for ref: Array in entry.instances:
			var node := root_node.get_node_or_null(str(ref[0])) as MultiMeshInstance3D
			if node == null or int(ref[1]) >= node.multimesh.instance_count:
				_fail("bending %s names %s, which is not a batch instance" % [id, ref])
				continue
			var xf: Transform3D = BATCHES.read(node.multimesh, int(ref[1]))[0]
			if not xf.is_equal_approx(placement):
				_fail("bending %s's instance %s stands at %s, not %s" % [id, ref, xf, placement])
			levels += 1
		if levels != expected_refs:
			_fail("bending %s names %d instances, not its %d levels and shadow mesh" % [id, levels, expected_refs])


# --- Clutter ------------------------------------------------------------------------


func _check_clutter(root_node: Node3D) -> void:
	var kit := CLUTTER_KIT.new()
	var swappable: Dictionary = root_node.get_meta("swappable_rows", {})
	# The small cells as the clutter builder measures them: lone items' levels by
	# their own near box, from the rows.
	var rows := _clutter_rows()
	var cells := {}
	for row: Dictionary in rows:
		var parts := kit.parts(str(row.prop), row.prop_params, str(row.id))
		var position := Vector3(row.position_m[0], row.position_m[1], row.position_m[2])
		var key := "%s|%d_%d" % [parts.mesh_key, floori(position.x / StreetClutterBuilder.CELL_M), floori(position.z / StreetClutterBuilder.CELL_M)]
		if not cells.has(key):
			cells[key] = {"parts": parts, "rows": []}
		(cells[key].rows as Array).append(row)
	var lone := 0
	for key: String in cells:
		var cell: Dictionary = cells[key]
		if (cell.rows as Array).size() != 1:
			continue
		lone += 1
		var row: Dictionary = cell.rows[0]
		var parts: Dictionary = cell.parts
		var near_box: AABB = (parts.meshes[0] as Mesh).get_aabb()
		var levels := [["lod0", 0.0, CLUTTER_KIT.LOD_NEAR_M], ["lod1", CLUTTER_KIT.LOD_NEAR_M, float(parts.range_m)]]
		if parts.has("shadow_mesh"):
			levels.append(["shadow", 0.0, CLUTTER_KIT.LOD_NEAR_M])
		var batched := 0
		for child: Node in root_node.get_children():
			if not child is MultiMeshInstance3D or not str(child.name).begins_with("%s_" % parts.mesh_key) or not "__b" in str(child.name):
				continue
			var node := child as MultiMeshInstance3D
			var level_name := str(node.name).trim_prefix("%s_" % parts.mesh_key).get_slice("__b", 0)
			var level: Array = levels.filter(func(each: Array) -> bool: return each[0] == level_name).front() if levels.any(func(each: Array) -> bool: return each[0] == level_name) else []
			var material := node.material_override as ShaderMaterial
			for index in node.multimesh.instance_count:
				var xf: Transform3D = BATCHES.read(node.multimesh, index)[0]
				# The lone row's own instance (an item of another row may share the batch).
				if not xf.origin.is_equal_approx(Vector3(row.position_m[0], row.position_m[1], row.position_m[2])):
					continue
				batched += 1
				if level.is_empty() or material == null:
					_fail("%s: lone %s in %s has no level or material" % [key, row.id, node.name])
					continue
				var band: Variant = material.get_shader_parameter(BATCHES.BAND_UNIFORM)
				var reference: Variant = material.get_shader_parameter(BATCHES.REFERENCE_UNIFORM)
				if band != Vector2(level[1], level[2]) or not reference is Vector3 or not (reference as Vector3).is_equal_approx(near_box.get_center()):
					_fail("%s %s: band %s and reference %s, not %s and %s" % [row.id, node.name, band, reference, Vector2(level[1], level[2]), near_box.get_center()])
				var centre := (xf * near_box).get_center()
				var node_centre := node.multimesh.custom_aabb.get_center()
				for camera: Vector3 in _cameras([centre], [0.0, 30.0, float(level[1]), float(level[2]), float(level[2]) + 50.0]):
					var before := _node_draws(float(level[1]), float(level[2]), centre, camera)
					var after := _node_draws(node.visibility_range_begin, node.visibility_range_end, node_centre, camera) and _band_draws(band, xf * (reference as Vector3), 0.0, camera)
					if before != after:
						_fail("from %s lone %s's %s drew %s, its batch %s" % [camera, row.id, level_name, before, after])
						break
		if batched != levels.size():
			_fail("lone %s is in %d batches, not its %d levels" % [row.id, batched, levels.size()])
	if lone < 3:
		_fail("only %d lone items in the fixture" % lone)
	for id: String in swappable:
		var entry: Dictionary = swappable[id]
		var placement: Transform3D = entry.transform
		for ref: Array in entry.instances:
			var node := root_node.get_node_or_null(str(ref[0])) as MultiMeshInstance3D
			if node == null or int(ref[1]) >= node.multimesh.instance_count:
				_fail("car %s names %s, which is not a batch instance" % [id, ref])
				continue
			if "__b" in str(ref[0]):
				var xf: Transform3D = BATCHES.read(node.multimesh, int(ref[1]))[0]
				if not xf.is_equal_approx(placement):
					_fail("car %s's instance %s stands at %s, not %s" % [id, ref, xf, placement])
			if (ref.size() > 2) != str(ref[0]).contains("_shadow__"):
				_fail("car %s's ref %s is marked shadow wrongly" % [id, ref])


# --- Shaders ------------------------------------------------------------------------


func _check_shaders() -> void:
	for path: String in ["res://game/resources/materials/world/vegetation/vegetation_bark.gdshader", "res://game/resources/materials/world/vegetation/vegetation_foliage.gdshader", "res://game/resources/materials/world/vegetation/vegetation_impostor.gdshader", "res://game/resources/materials/world/vegetation/vegetation_impostor_unshadowed.gdshader", "res://game/resources/materials/world/street/street_clutter.gdshader", "res://game/resources/materials/world/street/street_yard.gdshader"]:
		var shader := load(path) as Shader
		var names: Array = shader.get_shader_uniform_list().map(func(uniform: Dictionary) -> String: return str(uniform.name))
		if not names.has(str(BATCHES.BAND_UNIFORM)):
			_fail("%s has no %s" % [path, BATCHES.BAND_UNIFORM])
