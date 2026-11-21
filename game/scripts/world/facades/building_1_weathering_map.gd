extends RefCounted
## Building 1's weathering map: a plan-view picture of the building that its surface
## shader (building_1_public_stucco.gdshader, weathering_map) reads at each wall's
## plan position, so streaks, darkened copings, splash and polished kick plates fall
## where the building's own drip edges, tops and ground are, on every instance of a
## shared material, with no unwrapped texture and no change to the meshes.
##
## One cell every cell_m metres (CELL_M unless the options give one), half floats:
## - R: the top of the mass behind a wall (metres): the highest point of any face over
##   the cell, slivers no face covers between two roofs (up to GAP_REACH_M each way)
##   filled with the lower roof's, then one cell of growth so a wall's own top
##   reaches the cell inside it; the options' "flat_tops" meshes (the tower block on
##   the drum's roof, close behind its coping) join after the growth, so their tops
##   never spread into the roof round them;
## - G: unused (0);
## - B: the exposure of that part of the building (0 to 1: its paint's age and shelter),
##   from the nearest source wall run's class within RUN_REACH_M; farther in (the drum
##   and the stepped blocks behind the outer walls) one interior exposure when the
##   options give it, so an inner wall never crosses the boundaries between the outer
##   runs' classes; then softened over exposure_blur_m, so where two classes meet the
##   paint's age changes over a few metres, not at a straight line;
## - A: the ground at the foot of the nearest run (metres): its base, as the source
##   record levelled it.
## tools/bake_building_1_weathering.gd bakes it from the hero model's built records
## (each run's class and exposure in game/resources/facades/building_1_weathering.json)
## into the materials that read it; the game never builds it at load.
## Grids are local packed arrays each helper returns, so they are never written
## through a copy.

## The map's resolution: a cell is 0.25 m (the web's copy takes "cell_m" 0.5).
const CELL_M := 0.25
## Margin round the building's plan bounds (m).
const MARGIN_M := 2.0
## How far from a run its class and ground reach before cells take their nearest
## assigned neighbour's (m).
const RUN_REACH_M := 3.0
## How far (m, each way) a sliver between two roofs is looked across.
const GAP_REACH_M := 1.0


## meshes: every MeshInstance3D of the building that its tops come from; runs:
## [{"start": Vector3, "end": Vector3, "exposure": float}] the source wall runs' foot
## segments; options: "cell_m" (the cell size, m; absent: CELL_M), "interior_exposure"
## (0 to 1, for cells farther than RUN_REACH_M from every run; absent: the nearest
## run's, as the ground), "exposure_blur_m" (absent or 0: none) and "flat_tops" (an
## Array of MeshInstance3D whose tops are not grown). Returns {"image", "bounds":
## Vector4(x0, z0, size_x, size_z) for the shader's weathering_map_bounds}, or {} when
## there is nothing to map.
static func build(meshes: Array, runs: Array, options: Dictionary = {}) -> Dictionary:
	var box := AABB()
	var started := false
	var flat: Array = options.get("flat_tops", [])
	for node: Variant in meshes + flat:
		var instance := node as MeshInstance3D
		if instance == null or instance.mesh == null:
			continue
		var world_box := instance.global_transform * instance.mesh.get_aabb()
		box = world_box if not started else box.merge(world_box)
		started = true
	if not started:
		return {}
	var cell := float(options.get("cell_m", CELL_M))
	var x0 := floorf(box.position.x - MARGIN_M)
	var z0 := floorf(box.position.z - MARGIN_M)
	var width := int(ceilf((box.size.x + 2.0 * MARGIN_M) / cell / 4.0)) * 4
	var depth := int(ceilf((box.size.z + 2.0 * MARGIN_M) / cell / 4.0)) * 4
	var grid := {"x0": x0, "z0": z0, "w": width, "h": depth, "cell": cell}
	var top := PackedFloat32Array()
	top.resize(width * depth)
	for node: Variant in meshes:
		top = _with_tops(node as MeshInstance3D, grid, top)
	top = _gaps_filled(top, width, depth, int(roundf(GAP_REACH_M / cell)))
	top = _grown(top, width, depth)
	if not flat.is_empty():
		var flat_top := PackedFloat32Array()
		flat_top.resize(width * depth)
		for node: Variant in flat:
			flat_top = _with_tops(node as MeshInstance3D, grid, flat_top)
		for index in top.size():
			top[index] = maxf(top[index], flat_top[index])
	# Each run's class and ground over the cells within RUN_REACH_M of its foot, the
	# nearest run winning; then cells no run reached take their nearest reached
	# neighbour's (breadth first), so roofs and inner walls follow the walls round them.
	var exposure := PackedFloat32Array()
	exposure.resize(width * depth)
	exposure.fill(-1.0)
	var ground := PackedFloat32Array()
	ground.resize(width * depth)
	var nearest := PackedFloat32Array()
	nearest.resize(width * depth)
	nearest.fill(INF)
	for value: Variant in runs:
		var run := value as Dictionary
		var start := run.start as Vector3
		var end := run.end as Vector3
		var i0 := maxi(int(floorf((minf(start.x, end.x) - RUN_REACH_M - x0) / cell)), 0)
		var i1 := mini(int(floorf((maxf(start.x, end.x) + RUN_REACH_M - x0) / cell)), width - 1)
		var j0 := maxi(int(floorf((minf(start.z, end.z) - RUN_REACH_M - z0) / cell)), 0)
		var j1 := mini(int(floorf((maxf(start.z, end.z) + RUN_REACH_M - z0) / cell)), depth - 1)
		var segment := Vector2(end.x - start.x, end.z - start.z)
		var length_squared := maxf(segment.length_squared(), 1e-9)
		for j in range(j0, j1 + 1):
			for i in range(i0, i1 + 1):
				var p := Vector2(x0 + (float(i) + 0.5) * cell - start.x, z0 + (float(j) + 0.5) * cell - start.z)
				var along := clampf(p.dot(segment) / length_squared, 0.0, 1.0)
				var distance := (p - segment * along).length()
				var index := j * width + i
				if distance > RUN_REACH_M or distance >= nearest[index]:
					continue
				nearest[index] = distance
				exposure[index] = float(run.exposure)
				ground[index] = lerpf(start.y, end.y, along)
	var frontier: Array[int] = []
	for index in exposure.size():
		if exposure[index] >= 0.0:
			frontier.append(index)
	while not frontier.is_empty():
		var next: Array[int] = []
		for index in frontier:
			var i := index % width
			var j := index / width
			for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var ni := i + offset.x
				var nj := j + offset.y
				if ni < 0 or nj < 0 or ni >= width or nj >= depth:
					continue
				var neighbour := nj * width + ni
				if exposure[neighbour] < 0.0:
					exposure[neighbour] = exposure[index]
					ground[neighbour] = ground[index]
					next.append(neighbour)
		frontier = next
	if options.has("interior_exposure"):
		var interior := clampf(float(options.interior_exposure), 0.0, 1.0)
		for index in exposure.size():
			if nearest[index] == INF:
				exposure[index] = interior
	var blur_cells := int(roundf(float(options.get("exposure_blur_m", 0.0)) / cell))
	if blur_cells > 0:
		# Two box passes each way: a soft, triangle-like falloff.
		for _pass in 2:
			exposure = _box_blur(exposure, width, depth, blur_cells, true)
			exposure = _box_blur(exposure, width, depth, blur_cells, false)
	var image := Image.create_empty(width, depth, false, Image.FORMAT_RGBAH)
	for j in depth:
		for i in width:
			var index := j * width + i
			image.set_pixel(i, j, Color(top[index], 0.0, maxf(exposure[index], 0.0), ground[index]))
	return {
		"image": image,
		"bounds": Vector4(x0, z0, float(width) * cell, float(depth) * cell),
	}


## top with the highest point of every face of instance over each cell: up-facing
## faces fill the cells they cover, and every edge marks the cells it passes over.
static func _with_tops(instance: MeshInstance3D, grid: Dictionary, top: PackedFloat32Array) -> PackedFloat32Array:
	if instance == null or instance.mesh == null:
		return top
	var xform := instance.global_transform
	var normal_basis := xform.basis.inverse().transposed()
	var width := int(grid.w)
	var depth := int(grid.h)
	var x0 := float(grid.x0)
	var z0 := float(grid.z0)
	var cell := float(grid.cell)
	for surface in instance.mesh.get_surface_count():
		var arrays := instance.mesh.surface_get_arrays(surface)
		var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
		var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
		var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
		for t in range(0, indices.size(), 3):
			var corners: Array[Vector3] = [xform * vertices[indices[t]], xform * vertices[indices[t + 1]], xform * vertices[indices[t + 2]]]
			for k in 3:
				var a := corners[k]
				var b := corners[(k + 1) % 3]
				var steps := maxi(1, int(ceilf(Vector2(b.x - a.x, b.z - a.z).length() / (cell * 0.5))))
				for s in steps + 1:
					var p := a.lerp(b, float(s) / float(steps))
					var i := int(floorf((p.x - x0) / cell))
					var j := int(floorf((p.z - z0) / cell))
					if i >= 0 and j >= 0 and i < width and j < depth and p.y > top[j * width + i]:
						top[j * width + i] = p.y
			if normals.is_empty() or (normal_basis * normals[indices[t]]).normalized().y <= 0.5:
				continue
			# An up-facing face fills the cells whose centres it covers, in plan
			# coordinates relative to its first corner so large values do not cancel.
			var a := corners[0]
			var ab := Vector2(corners[1].x - a.x, corners[1].z - a.z)
			var ac := Vector2(corners[2].x - a.x, corners[2].z - a.z)
			var area := ab.x * ac.y - ab.y * ac.x
			if absf(area) < 1e-8:
				continue
			var i0 := maxi(int(floorf((minf(a.x, minf(corners[1].x, corners[2].x)) - x0) / cell)), 0)
			var i1 := mini(int(floorf((maxf(a.x, maxf(corners[1].x, corners[2].x)) - x0) / cell)), width - 1)
			var j0 := maxi(int(floorf((minf(a.z, minf(corners[1].z, corners[2].z)) - z0) / cell)), 0)
			var j1 := mini(int(floorf((maxf(a.z, maxf(corners[1].z, corners[2].z)) - z0) / cell)), depth - 1)
			for j in range(j0, j1 + 1):
				for i in range(i0, i1 + 1):
					var p := Vector2(x0 + (float(i) + 0.5) * cell - a.x, z0 + (float(j) + 0.5) * cell - a.z)
					var u := (p.x * ac.y - p.y * ac.x) / area
					var v := (ab.x * p.y - ab.y * p.x) / area
					if u < -0.001 or v < -0.001 or u + v > 1.001:
						continue
					var y := a.y + u * (corners[1].y - a.y) + v * (corners[2].y - a.y)
					if y > top[j * width + i]:
						top[j * width + i] = y
	return top


## A box blur of radius `radius` cells along rows (along_x) or columns, by running sums,
## the edge cells repeated past the grid's edges.
static func _box_blur(values: PackedFloat32Array, width: int, depth: int, radius: int, along_x: bool) -> PackedFloat32Array:
	var result := values.duplicate()
	var lines := depth if along_x else width
	var length := width if along_x else depth
	var step := 1 if along_x else width
	var span := float(2 * radius + 1)
	for line in lines:
		var first := line * width if along_x else line
		var sum := 0.0
		for k in range(-radius, radius + 1):
			sum += values[first + clampi(k, 0, length - 1) * step]
		for k in length:
			result[first + k * step] = sum / span
			sum += values[first + mini(k + radius + 1, length - 1) * step] - values[first + maxi(k - radius, 0) * step]
	return result


## Slivers no face covers between two roofs (seams in a roof's triangles): an empty
## cell with a top on both sides of it within `reach` cells, along a row, a column or a
## diagonal, takes the lower of the two (the lowest such pair). A wall's lookup into
## such a seam would otherwise find no top, and its stains would stop in a straight
## strip from coping to ground.
static func _gaps_filled(values: PackedFloat32Array, width: int, depth: int, reach: int) -> PackedFloat32Array:
	var result := values.duplicate()
	var steps: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, -1)]
	for j in depth:
		for i in width:
			if values[j * width + i] != 0.0:
				continue
			var fill := INF
			for step in steps:
				var lower := INF
				for direction: int in [1, -1]:
					var found := 0.0
					for k in range(1, reach + 1):
						var ni := i + step.x * k * direction
						var nj := j + step.y * k * direction
						if ni < 0 or nj < 0 or ni >= width or nj >= depth:
							break
						found = values[nj * width + ni]
						if found != 0.0:
							break
					if found == 0.0:
						lower = INF
						break
					lower = minf(lower, found)
				fill = minf(fill, lower)
			if fill != INF:
				result[j * width + i] = fill
	return result


## One cell of growth: each cell takes the highest of itself and its eight neighbours.
static func _grown(values: PackedFloat32Array, width: int, depth: int) -> PackedFloat32Array:
	var result := values.duplicate()
	for j in depth:
		for i in width:
			var best := values[j * width + i]
			for dj in range(-1, 2):
				for di in range(-1, 2):
					var ni := i + di
					var nj := j + dj
					if ni >= 0 and nj >= 0 and ni < width and nj < depth:
						best = maxf(best, values[nj * width + ni])
			result[j * width + i] = best
	return result
