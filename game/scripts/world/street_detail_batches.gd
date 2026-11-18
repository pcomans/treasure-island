class_name StreetDetailBatches
extends RefCounted
## Street detail in large batches: one MultiMesh per mesh, detail level and CELL_M
## cell, in place of one per mesh, level and small cell (owner, 2026-11-18: the
## iPhone's web page is killed at its 2048 MB limit, and the page's graphics memory
## follows the number of GL buffers it holds, one a MultiMesh; the small cells held
## about 8,500, most with one tree or car in them).
##
## The small cells were small because a batch's visibility range is measured from
## its box's centre, and the detail levels hand over by those ranges: a tree's lod0
## within 35-60 m of its 16 m cell's centre, its far impostor from 90-140 m. A large
## batch can't say which of its instances shows, so each instance keeps the range
## its small cell gave it and its shader tests it, from that small cell's box centre
## to the main camera (vegetation_band.gdshaderinc; for a parked car or yard piece,
## the clutter shaders: street_clutter.gdshader and street_yard.gdshader). The test
## reproduces the renderer's own: the same centre,
## the same range ends and the same camera in the colour, shadow and probe passes,
## so every instance shows, and hands over, exactly where it did. The batch's own
## range is only a coarse cull that keeps it while any of its instances may show:
## its level's range widened by the farthest instance centre from the batch's centre.
##
## Interactive rows (bending trees, parked cars a car can take) find their instances
## by node name and index as before (the builders' bending_rows and swappable_rows).

## The large cell (m) for every batched level but the trees' far impostors; chosen
## by measurement (web/street-detail-regroup-20261118: the web build in the phone rig
## at 64, 128 and 256 m held 40,268, 38,227 and 36,826 GL buffers and drew 3,650,
## 3,551 and 3,480 calls a frame on the corner route, against 43,422 and 3,805
## before, with the frame time the same within the runs' noise).
const CELL_M := 256.0
## The far impostors' cell (m): drawn out to 600-900 m, they are in range from most
## of the island anyway, and each is one quad, so a large cell costs nothing.
const FAR_CELL_M := 1024.0
## Metres a batch's coarse range reaches past what its instances need, so float
## rounding never culls a batch while one of its instances is in its range.
const RANGE_PAD_M := 1.0
## The uniform each banded material carries ([begin, end] in metres).
const BAND_UNIFORM := &"street_band"
## The vegetation shaders' switch to a merged hedge's per-vertex centres.
const BY_VERTEX_UNIFORM := &"street_band_by_vertex"


static func cell(position: Vector3, size_m := CELL_M) -> String:
	return "%d_%d" % [floori(position.x / size_m), floori(position.z / size_m)]


## A batch to fill with add(): its mesh, shadow setting and its level's range.
static func batch(mesh: Mesh, cast: int, begin_m: float, end_m: float) -> Dictionary:
	return {"mesh": mesh, "cast": cast, "begin": begin_m, "end": end_m, "transforms": [], "colors": [], "customs": [], "references": PackedVector3Array(), "extras": PackedFloat32Array(), "box": AABB(), "count": 0}


## Adds an instance (its transform, the box it draws in, the point its range is
## measured from, the metres its range's end reaches past the level's, its custom
## data and its colour) and returns its index in the batch.
static func add(into: Dictionary, transform: Transform3D, box: AABB, reference: Vector3, extra_m: float, custom: Color, color := Color(1, 1, 1, 1)) -> int:
	var index := int(into.count)
	(into.transforms as Array).append(transform)
	(into.colors as Array).append(color)
	(into.customs as Array).append(custom)
	# A packed array read out of a Dictionary is a copy: append, then put it back.
	var references: PackedVector3Array = into.references
	references.append(reference)
	into.references = references
	var extras: PackedFloat32Array = into.extras
	extras.append(extra_m)
	into.extras = extras
	into.box = box if index == 0 else (into.box as AABB).merge(box)
	into.count = index + 1
	return index


## What the band test reads of an instance whose range it measures from reference,
## ending extra_m past its level's end: that point less the instance's origin and 1
## plus extra_m (a vegetation instance's custom data, vegetation_band.gdshaderinc; a
## clutter instance's colour, street_clutter.gdshader and street_yard.gdshader).
static func band_data(transform: Transform3D, reference: Vector3, extra_m: float) -> Color:
	var offset := reference - transform.origin
	return Color(offset.x, offset.y, offset.z, 1.0 + extra_m)


## The batch's coarse range: [begin, end] in metres from its box's centre, so that it
## draws whenever one of its instances is in its level's range from its own point.
static func coarse_range(from: Dictionary) -> Vector2:
	var centre := (from.box as AABB).get_center()
	var reach := 0.0
	var farthest := 0.0
	var references: PackedVector3Array = from.references
	var extras: PackedFloat32Array = from.extras
	for index in references.size():
		var offset := references[index].distance_to(centre)
		reach = maxf(reach, offset)
		farthest = maxf(farthest, float(from.end) + extras[index] + offset)
	var begin := float(from.begin) - reach - RANGE_PAD_M
	return Vector2(begin if begin > 0.0 and float(from.begin) > 0.0 else 0.0, farthest + RANGE_PAD_M)


## The filled batch as a MultiMeshInstance3D named node_name: its instances with
## their colours and custom data, its box, its coarse range and no fade. A batch
## always has colours: Godot 4.7.2's Compatibility renderer reserves an instance's
## colour beside its custom data and multiplies a shader's COLOR by it whether or
## not the MultiMesh uses colours (drivers/gles3/shaders/scene.glsl), leaving it
## zero or stale without them, so the vegetation's (whose shaders read COLOR) are
## white, and the clutter's carry its band (band_data). The instances go in as one
## buffer, which the headless renderer keeps too (it drops instances set one at a
## time), so a headless test can read them back.
static func node(from: Dictionary, node_name: String) -> MultiMeshInstance3D:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.use_custom_data = true
	multimesh.mesh = from.mesh
	multimesh.instance_count = int(from.count)
	multimesh.buffer = buffer(from.transforms, from.colors, from.customs)
	multimesh.custom_aabb = from.box
	var instance := MultiMeshInstance3D.new()
	instance.name = node_name
	instance.multimesh = multimesh
	instance.cast_shadow = from.cast
	var coarse := coarse_range(from)
	instance.visibility_range_begin = coarse.x
	instance.visibility_range_end = coarse.y
	instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
	instance.set_meta("placement_count", int(from.count))
	return instance


## A MultiMesh buffer (TRANSFORM_3D, colours and custom data) as Godot lays one out:
## per instance its basis rows with the origin, then its colour, then its custom data.
static func buffer(transforms: Array, colors: Array, customs: Array) -> PackedFloat32Array:
	var data := PackedFloat32Array()
	data.resize(transforms.size() * 20)
	for index in transforms.size():
		var xf: Transform3D = transforms[index]
		var at := index * 20
		data[at] = xf.basis.x.x
		data[at + 1] = xf.basis.y.x
		data[at + 2] = xf.basis.z.x
		data[at + 3] = xf.origin.x
		data[at + 4] = xf.basis.x.y
		data[at + 5] = xf.basis.y.y
		data[at + 6] = xf.basis.z.y
		data[at + 7] = xf.origin.y
		data[at + 8] = xf.basis.x.z
		data[at + 9] = xf.basis.y.z
		data[at + 10] = xf.basis.z.z
		data[at + 11] = xf.origin.z
		var color: Color = colors[index]
		var custom: Color = customs[index]
		for channel in 4:
			data[at + 12 + channel] = color[channel]
			data[at + 16 + channel] = custom[channel]
	return data


## A MultiMesh buffer (TRANSFORM_3D, no colours or custom data) of transforms.
static func transform_buffer(transforms: Array) -> PackedFloat32Array:
	var data := PackedFloat32Array()
	data.resize(transforms.size() * 12)
	for index in transforms.size():
		var xf: Transform3D = transforms[index]
		var at := index * 12
		for row in 3:
			data[at + row * 4] = xf.basis[0][row]
			data[at + row * 4 + 1] = xf.basis[1][row]
			data[at + row * 4 + 2] = xf.basis[2][row]
			data[at + row * 4 + 3] = xf.origin[row]
	return data


## An instance's transform, custom data and colour read back from a batch's MultiMesh
## buffer, laid out as buffer() lays it out: [Transform3D, Color, Color].
static func read(multimesh: MultiMesh, index: int) -> Array:
	var data := multimesh.buffer
	var at := index * 20
	var xf := Transform3D(Vector3(data[at], data[at + 4], data[at + 8]), Vector3(data[at + 1], data[at + 5], data[at + 9]), Vector3(data[at + 2], data[at + 6], data[at + 10]), Vector3(data[at + 3], data[at + 7], data[at + 11]))
	return [xf, Color(data[at + 16], data[at + 17], data[at + 18], data[at + 19]), Color(data[at + 12], data[at + 13], data[at + 14], data[at + 15])]


## Whether a material takes the band test (its shader has the band uniform).
static func takes_band(material: Material) -> bool:
	if not material is ShaderMaterial or (material as ShaderMaterial).shader == null:
		return false
	for uniform: Dictionary in (material as ShaderMaterial).shader.get_shader_uniform_list():
		if StringName(uniform.name) == BAND_UNIFORM:
			return true
	return false


## The copy of material that tests the range [begin_m, end_m] (with by_vertex, from
## each vertex's CUSTOM0, a merged hedge's), one per material, range and way in cache.
static func band_material(material: ShaderMaterial, begin_m: float, end_m: float, cache: Dictionary, by_vertex := false) -> ShaderMaterial:
	var key := "%d|%s|%s|%s" % [material.get_instance_id(), begin_m, end_m, by_vertex]
	if not cache.has(key):
		var made := material.duplicate() as ShaderMaterial
		made.set_shader_parameter(BAND_UNIFORM, Vector2(begin_m, end_m))
		if by_vertex:
			made.set_shader_parameter(BY_VERTEX_UNIFORM, true)
		cache[key] = made
	return cache[key]


## Gives every surface of mesh its material's copy that tests [begin_m, end_m]: the
## band rides on the level's own mesh, which only that level of that prop draws. ""
## or what is wrong (a surface whose material has no band test, or a mesh already
## given another range). banded: mesh -> its range, across calls.
static func band_mesh(mesh: Mesh, begin_m: float, end_m: float, cache: Dictionary, banded: Dictionary) -> String:
	var band := Vector2(begin_m, end_m)
	if banded.has(mesh):
		return "" if banded[mesh] == band else "%s draws two ranges, %s and %s" % [mesh.resource_name, banded[mesh], band]
	for surface in mesh.get_surface_count():
		var material := mesh.surface_get_material(surface)
		if not takes_band(material):
			return "%s surface %d has no band test (%s)" % [mesh.resource_name, surface, material]
	for surface in mesh.get_surface_count():
		mesh.surface_set_material(surface, band_material(mesh.surface_get_material(surface) as ShaderMaterial, begin_m, end_m, cache))
	banded[mesh] = band
	return ""
