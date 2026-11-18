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
## to the main camera (vegetation_band.gdshaderinc; for a parked car or yard piece
## alone in its cell, its own box centre: street_clutter.gdshader and
## street_yard.gdshader). The test reproduces the renderer's own: the same centre,
## the same range ends and the same camera in the colour, shadow and probe passes,
## so every instance shows, and hands over, exactly where it did. The batch's own
## range is only a coarse cull that keeps it while any of its instances may show:
## its level's range widened by the farthest instance centre from the batch's centre.
##
## Interactive rows (bending trees, parked cars a car can take) find their instances
## by node name and index as before (the builders' bending_rows and swappable_rows).

## The large cell (m). One cell size for every batched level; chosen by measurement
## (web/street-detail-regroup-20261118: buffers, draw calls and frame time on the web
## build in the phone rig at 64, 128 and 256 m).
const CELL_M := 128.0
## Metres a batch's coarse range reaches past what its instances need, so float
## rounding never culls a batch while one of its instances is in its range.
const RANGE_PAD_M := 1.0
## The uniform each banded material carries ([begin, end] in metres).
const BAND_UNIFORM := &"street_band"
## The clutter shaders' reference point (the near mesh's box centre, in the
## instance's own frame).
const REFERENCE_UNIFORM := &"street_reference"
## The vegetation shaders' switch to a merged hedge's per-vertex centres.
const BY_VERTEX_UNIFORM := &"street_band_by_vertex"


static func cell(position: Vector3) -> String:
	return "%d_%d" % [floori(position.x / CELL_M), floori(position.z / CELL_M)]


## A batch to fill with add(): its mesh, shadow setting and its level's range.
static func batch(mesh: Mesh, cast: int, begin_m: float, end_m: float) -> Dictionary:
	return {"mesh": mesh, "cast": cast, "begin": begin_m, "end": end_m, "transforms": [], "customs": [], "references": PackedVector3Array(), "extras": PackedFloat32Array(), "box": AABB(), "count": 0}


## Adds an instance (its transform, the box it draws in, the point its range is
## measured from, the metres its range's end reaches past the level's, and its custom
## data) and returns its index in the batch.
static func add(into: Dictionary, transform: Transform3D, box: AABB, reference: Vector3, extra_m: float, custom: Color) -> int:
	var index := int(into.count)
	(into.transforms as Array).append(transform)
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


## The custom data of a vegetation instance whose range the band test measures from
## reference, ending extra_m past its level's end (vegetation_band.gdshaderinc).
static func vegetation_custom(transform: Transform3D, reference: Vector3, extra_m: float) -> Color:
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


## The filled batch as a MultiMeshInstance3D named node_name: its instances with their
## custom data, its box, its coarse range and no fade. With white, every instance also
## has the colour white: Godot 4.7.2's Compatibility renderer reserves an instance's
## colour beside its custom data and multiplies a shader's COLOR by it whether or not
## the MultiMesh uses colours (drivers/gles3/shaders/scene.glsl), leaving it zero or
## stale without them, so a batch whose shaders read COLOR (the vegetation's) needs
## them white. The instances go in as one buffer, which the headless renderer keeps
## too (it drops instances set one at a time), so a headless test can read them back.
static func node(from: Dictionary, node_name: String, white: bool) -> MultiMeshInstance3D:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = white
	multimesh.use_custom_data = true
	multimesh.mesh = from.mesh
	multimesh.instance_count = int(from.count)
	multimesh.buffer = buffer(from.transforms, from.customs, white)
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


## A MultiMesh buffer (TRANSFORM_3D) as Godot lays one out: per instance its basis
## rows with the origin, then (white) the colour white, then its custom data.
static func buffer(transforms: Array, customs: Array, white: bool) -> PackedFloat32Array:
	var stride := 16 + (4 if white else 0)
	var data := PackedFloat32Array()
	data.resize(transforms.size() * stride)
	for index in transforms.size():
		var xf: Transform3D = transforms[index]
		var at := index * stride
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
		if white:
			for channel in 4:
				data[at + 12 + channel] = 1.0
		var custom: Color = customs[index]
		var custom_at := at + (16 if white else 12)
		data[custom_at] = custom.r
		data[custom_at + 1] = custom.g
		data[custom_at + 2] = custom.b
		data[custom_at + 3] = custom.a
	return data


## An instance's transform and custom data read back from a batch's MultiMesh buffer,
## laid out as buffer() lays it out: [Transform3D, Color].
static func read(multimesh: MultiMesh, index: int) -> Array:
	var data := multimesh.buffer
	var stride := 16 + (4 if multimesh.use_colors else 0)
	var at := index * stride
	var xf := Transform3D(Vector3(data[at], data[at + 4], data[at + 8]), Vector3(data[at + 1], data[at + 5], data[at + 9]), Vector3(data[at + 2], data[at + 6], data[at + 10]), Vector3(data[at + 3], data[at + 7], data[at + 11]))
	var custom_at := at + stride - 4
	return [xf, Color(data[custom_at], data[custom_at + 1], data[custom_at + 2], data[custom_at + 3])]


## Whether a material takes the band test (its shader has the band uniform).
static func takes_band(material: Material) -> bool:
	if not material is ShaderMaterial or (material as ShaderMaterial).shader == null:
		return false
	for uniform: Dictionary in (material as ShaderMaterial).shader.get_shader_uniform_list():
		if StringName(uniform.name) == BAND_UNIFORM:
			return true
	return false


## The copy of material that tests the range [begin_m, end_m] (and, given reference,
## measures it from that point of the instance's frame; with by_vertex, from each
## vertex's CUSTOM0, a merged hedge's), one per material, range and way in cache.
static func band_material(material: ShaderMaterial, begin_m: float, end_m: float, cache: Dictionary, reference := Vector3.INF, by_vertex := false) -> ShaderMaterial:
	var key := "%d|%s|%s|%s|%s" % [material.get_instance_id(), begin_m, end_m, reference, by_vertex]
	if not cache.has(key):
		var made := material.duplicate() as ShaderMaterial
		made.set_shader_parameter(BAND_UNIFORM, Vector2(begin_m, end_m))
		if reference.is_finite():
			made.set_shader_parameter(REFERENCE_UNIFORM, reference)
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
