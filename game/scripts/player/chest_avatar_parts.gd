extends RefCounted
## Geometry and materials of the player's treasure-chest character
## (chest_avatar.gd): a wooden chest with iron straps and brass fittings, a barrel
## lid carrying two cartoon eyes, a heap of gold inside, rubber-hose limbs with
## white gloves and big shoes, and a small brass jetpack on its back. Everything
## is built once in code from a few primitives; each part is one mesh of a few
## surfaces sharing a handful of materials (two generated textures, see
## game/resources/textures/player/README.md). Dark inverted-hull outlines give
## the 1930s rubber-hose cartoon look.
##
## Dimensions in metres are production inference for a cartoon character sized
## to the stock player's capsule (0.35 m radius, 1.8 m tall); the chest stands
## about 1.55 m to the top of its eyes.
##
## Frames. Avatar: origin at the player's feet, +Y up, +Z forward (the face), +X
## the chest's own left. Body: origin at the centre of the chest's bottom.
## Lid: origin on the hinge line at the back of the lid; the closed lid spans
## +Z. Hand: origin at the wrist, the hand along -Y, palm towards -X for the left
## hand (side +1). Foot: origin at the sole centre on the ground, toe along +Z.

const BODY_W := 0.74
const BODY_H := 0.52
const BODY_D := 0.52
const WALL := 0.03
const HIP_HEIGHT := 0.56
const LID_W := 0.76
const LID_D := 0.54
const LID_LIP := 0.05
const LID_ARCH := 0.18
const HINGE := Vector3(0.0, BODY_H, -LID_D * 0.5)
const SHOULDER := Vector3(BODY_W * 0.5, 0.34, 0.0)
const HIP := Vector3(0.17, 0.0, 0.0)
const NOZZLE := Vector3(0.12, 0.0, -BODY_D * 0.5 - 0.085)
## Shoes and gloves are drawn this much larger than their modelled size.
const SHOE_SCALE := 1.18
const GLOVE_SCALE := 1.15
const ANKLE := Vector3(0.0, 0.105, -0.035) * SHOE_SCALE
const GOLD_BASE := 0.47
const ARM_LENGTH := 0.48
const LEG_LENGTH := 0.47
const ARM_RADIUS := 0.038
const LEG_RADIUS := 0.046
const EYE_CENTER := Vector3(0.076, 0.2, 0.43)
const EYE_RADII := Vector3(0.071, 0.095, 0.052)
const EYE_TILT := 0.30
const COIN_RADIUS := 0.03
const COIN_THICK := 0.007
const PLANK_TILE := 0.64
const COIN_TILE := 0.25
const OUTLINE := 0.012

const WOOD_OUTER := Color(0.92, 0.78, 0.66)
const WOOD_INNER := Color(0.46, 0.36, 0.30)
const IRON := Color(0.17, 0.17, 0.19)
const BRASS := Color(0.90, 0.68, 0.30)
const GOLD := Color(1.0, 0.80, 0.26)
const LEATHER := Color(0.40, 0.22, 0.12)
const INK := Color(0.03, 0.025, 0.025)
const GLOVE := Color(0.97, 0.96, 0.93)
const SHOE := Color(0.70, 0.13, 0.11)
const SOLE := Color(0.16, 0.11, 0.09)
const RUBY := Color(0.86, 0.06, 0.16)
const EMERALD := Color(0.08, 0.70, 0.34)
const PEARL := Color(0.95, 0.93, 0.88)
const OUTLINE_COLOR := Color(0.06, 0.04, 0.035)

const WOOD_TEXTURE := preload("res://game/resources/textures/player/chest_wood.png")
const GOLD_TEXTURE := preload("res://game/resources/textures/player/gold_coins.png")
const HOSE_SHADER := preload("res://game/resources/player/hose_limb.gdshader")
const EYE_SHADER := preload("res://game/resources/player/chest_eye.gdshader")
const FLAME_SHADER := preload("res://game/resources/player/jet_flame.gdshader")

## Surface slots of the body mesh.
enum { S_WOOD, S_METAL, S_PAINT, S_GOLD, S_GEM }


## The shared materials of one avatar (see make_materials()).
class Materials:
	extends RefCounted
	var wood: StandardMaterial3D
	var metal: StandardMaterial3D
	var paint: StandardMaterial3D
	var gold: StandardMaterial3D
	var gem: StandardMaterial3D
	var outline: StandardMaterial3D
	var eye: ShaderMaterial
	var flame: ShaderMaterial


## One surface's arrays, filled in place.
class Surface:
	extends RefCounted
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var uv2s := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()


## A small mesh builder. Triangles take an outward hint and are wound
## clockwise as seen from it (Godot's front face), whatever order they come in.
class Builder:
	extends RefCounted
	var surfaces: Array[Surface] = []
	## Grows every primitive by this much (the inverted-hull outline copies).
	var grow := 0.0
	## Uniformly scales every vertex position (normals are unchanged).
	var scale := 1.0

	func _init(count: int) -> void:
		for _i in count:
			surfaces.append(Surface.new())

	func vertex(s: int, position: Vector3, normal: Vector3, uv: Vector2, color: Color, uv2 := Vector2.ZERO) -> int:
		var surface := surfaces[s]
		surface.vertices.append(position * scale)
		surface.normals.append(normal)
		surface.uvs.append(uv)
		surface.uv2s.append(uv2)
		surface.colors.append(color)
		return surface.vertices.size() - 1

	func tri(s: int, a: int, b: int, c: int, outward: Vector3) -> void:
		var surface := surfaces[s]
		var pa := surface.vertices[a]
		var normal := (surface.vertices[b] - pa).cross(surface.vertices[c] - pa)
		if normal.dot(outward) > 0.0:
			surface.indices.append_array(PackedInt32Array([a, c, b]))
		else:
			surface.indices.append_array(PackedInt32Array([a, b, c]))

	func quad(s: int, a: int, b: int, c: int, d: int, outward: Vector3) -> void:
		tri(s, a, b, c, outward)
		tri(s, a, c, d, outward)

	## A flat convex polygon (points in order) facing `normal`, fanned from its
	## centre; UV is the point projected on uv_x and uv_y.
	func polygon(s: int, points: PackedVector3Array, normal: Vector3, color: Color, uv_x := Vector3.ZERO, uv_y := Vector3.ZERO) -> void:
		var centre := Vector3.ZERO
		for point in points:
			centre += point
		centre /= float(points.size())
		var hub := vertex(s, centre, normal, Vector2(centre.dot(uv_x), centre.dot(uv_y)), color)
		var ring := PackedInt32Array()
		for point in points:
			ring.append(vertex(s, point, normal, Vector2(point.dot(uv_x), point.dot(uv_y)), color))
		for i in ring.size():
			tri(s, hub, ring[i], ring[(i + 1) % ring.size()], normal)

	## A box (grown by `grow`) in the frame `xform`, with flat faces.
	func box(s: int, xform: Transform3D, half: Vector3, color: Color) -> void:
		var h := half + Vector3.ONE * grow
		for axis in 3:
			for sign_value: float in [-1.0, 1.0]:
				var n := Vector3.ZERO
				n[axis] = sign_value
				var u := Vector3.ZERO
				u[(axis + 1) % 3] = h[(axis + 1) % 3]
				var v := Vector3.ZERO
				v[(axis + 2) % 3] = h[(axis + 2) % 3]
				var centre := n * h[axis]
				var world_n := (xform.basis * n).normalized()
				var ids := PackedInt32Array()
				for corner: Vector3 in [centre - u - v, centre + u - v, centre + u + v, centre - u + v]:
					ids.append(vertex(s, xform * corner, world_n, Vector2.ZERO, color))
				quad(s, ids[0], ids[1], ids[2], ids[3], world_n)

	## A parametric sheet. `fn(u, v)` returns [position, normal] and optionally
	## a UV and a UV2 (else UV is (u, v)); quads face their averaged normal.
	func sheet(s: int, rows: int, cols: int, fn: Callable, color: Color) -> void:
		var ids: Array[PackedInt32Array] = []
		var normals: Array[PackedVector3Array] = []
		for r in rows + 1:
			var row := PackedInt32Array()
			var row_normals := PackedVector3Array()
			for c in cols + 1:
				var u := float(c) / float(cols)
				var v := float(r) / float(rows)
				var sample: Array = fn.call(u, v)
				var uv: Vector2 = sample[2] if sample.size() > 2 else Vector2(u, v)
				var uv2: Vector2 = sample[3] if sample.size() > 3 else Vector2.ZERO
				row.append(vertex(s, sample[0], sample[1], uv, color, uv2))
				row_normals.append(sample[1])
			ids.append(row)
			normals.append(row_normals)
		for r in rows:
			for c in cols:
				var outward: Vector3 = normals[r][c] + normals[r][c + 1] + normals[r + 1][c] + normals[r + 1][c + 1]
				if outward.length_squared() < 1e-8:
					continue
				quad(s, ids[r][c], ids[r][c + 1], ids[r + 1][c + 1], ids[r + 1][c], outward)

	## An ellipsoid (grown by `grow`) centred in `xform`; v_from..v_to clip it
	## from the -Y pole (0) to the +Y pole (1).
	func ellipsoid(s: int, xform: Transform3D, radii: Vector3, color: Color, rows := 10, cols := 16, v_from := 0.0, v_to := 1.0) -> void:
		var r := radii + Vector3.ONE * grow
		var basis := xform.basis
		var fn := func(u: float, v: float) -> Array:
			var lat := lerpf(-PI * 0.5, PI * 0.5, lerpf(v_from, v_to, v))
			var lon := u * TAU
			var unit := Vector3(cos(lat) * sin(lon), sin(lat), cos(lat) * cos(lon))
			var normal := Vector3(unit.x / r.x, unit.y / r.y, unit.z / r.z)
			return [xform * (unit * r), (basis * normal).normalized()]
		sheet(s, rows, cols, fn, color)

	## A tube from `a` to `b` (radii ra, rb, grown by `grow`), optionally capped.
	func tube(s: int, a: Vector3, b: Vector3, ra: float, rb: float, color: Color, sides := 12, cap_a := false, cap_b := false) -> void:
		var axis := b - a
		var length := axis.length()
		var dir := axis / length
		var basis := basis_y(dir)
		var side := basis.x
		var up := basis.z
		var ga := ra + grow
		var gb := rb + grow
		var start := a - dir * (grow if cap_a else 0.0)
		var finish := b + dir * (grow if cap_b else 0.0)
		var slope := (ga - gb) / maxf(length, 0.0001)
		var fn := func(u: float, v: float) -> Array:
			var angle := u * TAU
			var radial := side * cos(angle) + up * sin(angle)
			return [start.lerp(finish, v) + radial * lerpf(ga, gb, v), (radial + dir * slope).normalized()]
		sheet(s, 1, sides, fn, color)
		if cap_a:
			disc(s, start, -dir, side, up, ga, sides, color)
		if cap_b:
			disc(s, finish, dir, side, up, gb, sides, color)

	func disc(s: int, centre: Vector3, normal: Vector3, side: Vector3, up: Vector3, radius: float, sides: int, color: Color) -> void:
		var points := PackedVector3Array()
		for i in sides:
			var angle := TAU * float(i) / float(sides)
			points.append(centre + (side * cos(angle) + up * sin(angle)) * radius)
		polygon(s, points, normal, color)

	## A capsule from `a` to `b` of radius r (grown by `grow`).
	func capsule(s: int, a: Vector3, b: Vector3, radius: float, color: Color, sides := 10) -> void:
		var basis := basis_y((b - a).normalized())
		tube(s, a, b, radius, radius, color, sides)
		ellipsoid(s, Transform3D(basis, b), Vector3.ONE * radius, color, 4, sides, 0.5, 1.0)
		ellipsoid(s, Transform3D(basis, a), Vector3.ONE * radius, color, 4, sides, 0.0, 0.5)

	## A torus round `axis` through `centre` (tube radius grown by `grow`).
	func torus(s: int, centre: Vector3, axis: Vector3, ring_radius: float, tube_radius: float, color: Color, segments := 16, sides := 8) -> void:
		var basis := basis_y(axis.normalized())
		var r := tube_radius + grow
		var fn := func(u: float, v: float) -> Array:
			var around := u * TAU
			var turn := v * TAU
			var radial := Vector3(sin(around), 0.0, cos(around))
			var normal := radial * cos(turn) + Vector3.UP * sin(turn)
			return [centre + basis * (radial * ring_radius + normal * r), (basis * normal).normalized()]
		sheet(s, sides, segments, fn, color)

	func commit(materials: Array) -> ArrayMesh:
		var mesh := ArrayMesh.new()
		for i in surfaces.size():
			var surface := surfaces[i]
			if surface.vertices.is_empty():
				continue
			var arrays := []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = surface.vertices
			arrays[Mesh.ARRAY_NORMAL] = surface.normals
			arrays[Mesh.ARRAY_TEX_UV] = surface.uvs
			arrays[Mesh.ARRAY_TEX_UV2] = surface.uv2s
			arrays[Mesh.ARRAY_COLOR] = surface.colors
			arrays[Mesh.ARRAY_INDEX] = surface.indices
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			mesh.surface_set_material(mesh.get_surface_count() - 1, materials[i])
		return mesh

	## An orthonormal basis whose Y axis is `dir`.
	static func basis_y(dir: Vector3) -> Basis:
		var x := Vector3.UP.cross(dir) if absf(dir.dot(Vector3.UP)) < 0.9 else Vector3.RIGHT.cross(dir)
		x = x.normalized()
		return Basis(x, dir, x.cross(dir).normalized())


static func make_materials() -> Materials:
	var m := Materials.new()
	m.wood = _toon("chest_wood", 0.82, 0.0)
	m.wood.albedo_texture = WOOD_TEXTURE
	m.metal = _toon("chest_metal", 0.34, 0.7)
	m.paint = _toon("chest_paint", 0.5, 0.0)
	m.gold = _toon("chest_gold", 0.32, 0.55)
	m.gold.albedo_texture = GOLD_TEXTURE
	m.gem = _toon("chest_gem", 0.08, 0.15)
	m.outline = StandardMaterial3D.new()
	m.outline.resource_name = "chest_outline"
	m.outline.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.outline.cull_mode = BaseMaterial3D.CULL_FRONT
	m.outline.albedo_color = OUTLINE_COLOR
	m.eye = ShaderMaterial.new()
	m.eye.resource_name = "chest_eye"
	m.eye.shader = EYE_SHADER
	m.flame = ShaderMaterial.new()
	m.flame.resource_name = "chest_jet_flame"
	m.flame.shader = FLAME_SHADER
	return m


## One rubber-hose limb's material (each limb sets its own curve).
static func hose_material(radius: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.resource_name = "chest_hose"
	material.shader = HOSE_SHADER
	material.set_shader_parameter("radius", radius)
	return material


static func _toon(name: String, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.roughness = roughness
	material.metallic = metallic
	material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	material.specular_mode = BaseMaterial3D.SPECULAR_TOON
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material


## A coin: a short closed cylinder along the frame's Y.
static func _coin(b: Builder, s: int, xform: Transform3D, color: Color) -> void:
	var half := xform.basis.y.normalized() * COIN_THICK * 0.5
	b.tube(s, xform.origin - half, xform.origin + half, COIN_RADIUS, COIN_RADIUS, color, 12, true, true)


# --- The body: wooden chest, iron straps, brass fittings, belt, jetpack, gold.

static func body(m: Materials) -> ArrayMesh:
	var b := Builder.new(5)
	_body_wood(b)
	_body_metal(b)
	_body_trim(b)
	_jetpack(b)
	_gold(b)
	return b.commit([m.wood, m.metal, m.paint, m.gold, m.gem])


static func body_outline(m: Materials) -> ArrayMesh:
	var b := Builder.new(1)
	b.grow = OUTLINE
	b.box(0, Transform3D(Basis.IDENTITY, Vector3(0.0, BODY_H * 0.5, 0.0)), Vector3(BODY_W, BODY_H, BODY_D) * 0.5, OUTLINE_COLOR)
	for side: float in [-1.0, 1.0]:
		var x := side * NOZZLE.x
		b.tube(0, Vector3(x, 0.10, NOZZLE.z), Vector3(x, 0.38, NOZZLE.z), 0.075, 0.075, OUTLINE_COLOR, 12, true, false)
		b.ellipsoid(0, Transform3D(Basis.IDENTITY, Vector3(x, 0.38, NOZZLE.z)), Vector3(0.075, 0.06, 0.075), OUTLINE_COLOR, 4, 12, 0.5, 1.0)
	return b.commit([m.outline])


static func _wood_uv(point: Vector3, u_axis: Vector3) -> Vector2:
	return Vector2(point.dot(u_axis), BODY_H - point.y) / PLANK_TILE


static func _body_wood(b: Builder) -> void:
	var hw := BODY_W * 0.5
	var hd := BODY_D * 0.5
	# Outer walls: planks run horizontally, three boards to the chest's height.
	for wall: Array in [
		[Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(0, 0, hd), hw],
		[Vector3(0, 0, -1), Vector3(-1, 0, 0), Vector3(0, 0, -hd), hw],
		[Vector3(1, 0, 0), Vector3(0, 0, -1), Vector3(hw, 0, 0), hd],
		[Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(-hw, 0, 0), hd],
	]:
		var n: Vector3 = wall[0]
		var u: Vector3 = wall[1]
		var origin: Vector3 = wall[2]
		var half: float = wall[3]
		var outer: Array[Vector3] = [origin - u * half, origin + u * half, origin + u * half + Vector3.UP * BODY_H, origin - u * half + Vector3.UP * BODY_H]
		var ids := PackedInt32Array()
		for corner in outer:
			ids.append(b.vertex(S_WOOD, corner, n, _wood_uv(corner, u), WOOD_OUTER))
		b.quad(S_WOOD, ids[0], ids[1], ids[2], ids[3], n)
		# The inside of the same wall, from the rim down under the gold.
		var io := origin - n * WALL
		var ih := half - WALL
		var low := Vector3.UP * (GOLD_BASE - 0.03)
		var inner: Array[Vector3] = [io - u * ih + low, io + u * ih + low, io + u * ih + Vector3.UP * BODY_H, io - u * ih + Vector3.UP * BODY_H]
		ids = PackedInt32Array()
		for corner in inner:
			ids.append(b.vertex(S_WOOD, corner, -n, _wood_uv(corner, u), WOOD_INNER))
		b.quad(S_WOOD, ids[0], ids[1], ids[2], ids[3], -n)
		# The rim: the top edge of the wall's thickness.
		ids = PackedInt32Array()
		for corner in [outer[3], outer[2], inner[2], inner[3]]:
			ids.append(b.vertex(S_WOOD, corner, Vector3.UP, Vector2(corner.dot(u), corner.dot(n)) / PLANK_TILE, WOOD_OUTER))
		b.quad(S_WOOD, ids[0], ids[1], ids[2], ids[3], Vector3.UP)
	var base := PackedVector3Array([Vector3(-hw, 0, -hd), Vector3(hw, 0, -hd), Vector3(hw, 0, hd), Vector3(-hw, 0, hd)])
	b.polygon(S_WOOD, base, Vector3.DOWN, WOOD_INNER, Vector3(1.0 / PLANK_TILE, 0, 0), Vector3(0, 0, 1.0 / PLANK_TILE))


static func _body_metal(b: Builder) -> void:
	var hw := BODY_W * 0.5
	var hd := BODY_D * 0.5
	# Two iron straps wrap front, bottom and back (0.010 proud of the wood).
	for x: float in [-0.20, 0.20]:
		b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(x, BODY_H * 0.5, hd + 0.005)), Vector3(0.03, BODY_H * 0.5, 0.005), IRON)
		b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(x, BODY_H * 0.5, -hd - 0.005)), Vector3(0.03, BODY_H * 0.5, 0.005), IRON)
		b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(x, -0.005, 0.0)), Vector3(0.03, 0.005, hd + 0.01), IRON)
	# Corner guards on the four vertical edges (0.013 proud).
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(sx * (hw - 0.02), BODY_H * 0.5, sz * (hd + 0.0065))), Vector3(0.0335, BODY_H * 0.5, 0.0065), IRON)
			b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(sx * (hw + 0.0065), BODY_H * 0.5, sz * (hd - 0.02))), Vector3(0.0065, BODY_H * 0.5, 0.0335), IRON)
	# The rim band round the top of the walls (0.016 proud, over the rest).
	var band_y := BODY_H - 0.022
	b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(0, band_y, hd + 0.008)), Vector3(hw + 0.016, 0.022, 0.008), IRON)
	b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(0, band_y, -hd - 0.008)), Vector3(hw + 0.016, 0.022, 0.008), IRON)
	b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(hw + 0.008, band_y, 0)), Vector3(0.008, 0.022, hd), IRON)
	b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(-hw - 0.008, band_y, 0)), Vector3(0.008, 0.022, hd), IRON)
	# The brass lock plate; brass grommets where the limbs come out.
	b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(0, BODY_H - 0.11, hd + 0.021)), Vector3(0.055, 0.072, 0.005), BRASS)
	for side: float in [-1.0, 1.0]:
		b.torus(S_METAL, Vector3(side * (hw + 0.004), SHOULDER.y, SHOULDER.z), Vector3(side, 0, 0), 0.05, 0.016, BRASS)
		b.torus(S_METAL, Vector3(side * HIP.x, -0.004, HIP.z), Vector3.DOWN, 0.056, 0.016, BRASS)
	# Brass rivets on the straps.
	for x: float in [-0.20, 0.20]:
		for y: float in [0.06, 0.25]:
			for sz: float in [-1.0, 1.0]:
				var out := Vector3(0, 0, sz)
				b.ellipsoid(S_METAL, Transform3D(Builder.basis_y(out), Vector3(x, y, sz * (hd + 0.01))), Vector3.ONE * 0.009, BRASS, 3, 6, 0.5, 1.0)


static func _body_trim(b: Builder) -> void:
	var hw := BODY_W * 0.5
	var hd := BODY_D * 0.5
	# Keyhole: a disc over a tapered slot, just proud of the lock plate.
	var face := hd + 0.0265
	var hole := PackedVector3Array()
	for i in 12:
		var angle := TAU * float(i) / 12.0
		hole.append(Vector3(cos(angle) * 0.014, BODY_H - 0.118 + sin(angle) * 0.014, face))
	b.polygon(S_PAINT, hole, Vector3.BACK, INK)
	var slot := BODY_H - 0.12
	b.polygon(S_PAINT, PackedVector3Array([Vector3(-0.006, slot, face), Vector3(0.006, slot, face), Vector3(0.011, slot - 0.038, face), Vector3(-0.011, slot - 0.038, face)]), Vector3.BACK, INK)
	# The leather belt that holds the jetpack on, round the chest and behind the
	# tanks, with a brass buckle at the front.
	var y := 0.165
	var t := 0.006
	var off := 0.017
	var back_z := NOZZLE.z - 0.075 - t
	var path: Array[Vector3] = [
		Vector3(-hw - off, y, hd + off), Vector3(hw + off, y, hd + off), Vector3(hw + off, y, -hd - off),
		Vector3(0.20, y, back_z), Vector3(-0.20, y, back_z), Vector3(-hw - off, y, -hd - off),
	]
	var inside := Vector3(0, y, -0.05)
	for i in path.size():
		var a := path[i]
		var c := path[(i + 1) % path.size()]
		var along := c - a
		var mid := (a + c) * 0.5
		var normal := along.cross(Vector3.UP).normalized()
		if normal.dot(mid - inside) < 0.0:
			normal = -normal
		b.box(S_PAINT, Transform3D(Basis(along.normalized(), Vector3.UP, normal), mid), Vector3(along.length() * 0.5 + t, 0.03, t), LEATHER)
	var buckle := Vector3(0, y, hd + off + t + 0.004)
	for edge: Array in [[Vector3(0, 0.034, 0), Vector3(0.04, 0.007, 0.004)], [Vector3(0, -0.034, 0), Vector3(0.04, 0.007, 0.004)], [Vector3(0.034, 0, 0), Vector3(0.007, 0.04, 0.004)], [Vector3(-0.034, 0, 0), Vector3(0.007, 0.04, 0.004)], [Vector3.ZERO, Vector3(0.004, 0.034, 0.003)]]:
		b.box(S_METAL, Transform3D(Basis.IDENTITY, buckle + edge[0]), edge[1], BRASS)


static func _jetpack(b: Builder) -> void:
	for side: float in [-1.0, 1.0]:
		var x := side * NOZZLE.x
		var z := NOZZLE.z
		b.tube(S_METAL, Vector3(x, 0.10, z), Vector3(x, 0.38, z), 0.075, 0.075, BRASS, 16)
		b.ellipsoid(S_METAL, Transform3D(Basis.IDENTITY, Vector3(x, 0.38, z)), Vector3(0.075, 0.06, 0.075), BRASS, 5, 16, 0.5, 1.0)
		b.ellipsoid(S_METAL, Transform3D(Basis.IDENTITY, Vector3(x, 0.10, z)), Vector3(0.075, 0.02, 0.075), IRON, 2, 16, 0.0, 0.5)
		for ring_y: float in [0.13, 0.33]:
			b.torus(S_METAL, Vector3(x, ring_y, z), Vector3.UP, 0.075, 0.008, IRON, 16, 6)
		# Nozzle: a throat narrowing below the tank, then a flared bell with a
		# dark lining.
		b.tube(S_METAL, Vector3(x, 0.09, z), Vector3(x, 0.045, z), 0.05, 0.034, IRON, 12)
		b.tube(S_METAL, Vector3(x, 0.045, z), Vector3(x, NOZZLE.y, z), 0.034, 0.052, IRON, 12)
		b.tube(S_PAINT, Vector3(x, NOZZLE.y + 0.004, z), Vector3(x, 0.045, z), 0.046, 0.03, INK, 12)


## Height of the gold heap's surface (body frame); it meets the inner walls just
## below the rim and peaks under the lid's arch.
static func gold_height(x: float, z: float) -> float:
	var hx := BODY_W * 0.5 - WALL
	var hz := BODY_D * 0.5 - WALL
	var dome := 0.11 * maxf(0.0, 1.0 - pow(x / 0.37, 2.0)) * maxf(0.0, 1.0 - pow(z / 0.27, 2.0))
	for lump: Vector3 in [Vector3(0.12, 0.05, 0.022), Vector3(-0.14, -0.06, 0.02), Vector3(0.0, 0.10, 0.016), Vector3(-0.22, 0.10, 0.014), Vector3(0.22, -0.10, 0.016), Vector3(0.05, -0.12, 0.012)]:
		dome += lump.z * exp(-(pow(x - lump.x, 2.0) + pow(z - lump.y, 2.0)) / 0.006)
	var edge := smoothstep(0.0, 0.06, minf(hx - absf(x), hz - absf(z)))
	return GOLD_BASE + 0.035 + dome * edge


static func _gold(b: Builder) -> void:
	var hx := BODY_W * 0.5 - WALL
	var hz := BODY_D * 0.5 - WALL
	var heap := func(u: float, v: float) -> Array:
		var x := lerpf(-hx, hx, u)
		var z := lerpf(hz, -hz, v)
		var e := 0.01
		var dx := (gold_height(x + e, z) - gold_height(x - e, z)) / (2.0 * e)
		var dz := (gold_height(x, z + e) - gold_height(x, z - e)) / (2.0 * e)
		return [Vector3(x, gold_height(x, z), z), Vector3(-dx, 1.0, -dz).normalized(), Vector2(x, z) / COIN_TILE]
	b.sheet(S_GOLD, 12, 16, heap, Color.WHITE)
	# Coins strewn on the heap and two pinched under the front of the lid.
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 11:
		var x := rng.randf_range(-0.27, 0.27)
		var z := rng.randf_range(-0.18, 0.18)
		var tilt := Basis.from_euler(Vector3(rng.randf_range(-0.5, 0.5), rng.randf_range(0, TAU), rng.randf_range(-0.5, 0.5)))
		_coin(b, S_METAL, Transform3D(tilt, Vector3(x, gold_height(x, z) + 0.003, z)), GOLD)
	for x: float in [-0.11, 0.15]:
		_coin(b, S_METAL, Transform3D(Basis.from_euler(Vector3(0.35, 0.3 * x, 0.12)), Vector3(x, BODY_H + 0.004, BODY_D * 0.5 + 0.012)), GOLD)
	_gem(b, Vector3(0.10, gold_height(0.10, 0.06) - 0.004, 0.06), 0.036, RUBY, 0.4)
	_gem(b, Vector3(-0.15, gold_height(-0.15, -0.05) - 0.004, -0.05), 0.032, EMERALD, 1.1)
	# A string of pearls from the heap over the front edge, hanging in a loop.
	var hd := BODY_D * 0.5
	var knots: Array[Vector3] = [
		Vector3(-0.27, BODY_H - 0.04, 0.15), Vector3(-0.27, BODY_H + 0.017, hd + 0.005), Vector3(-0.255, BODY_H - 0.06, hd + 0.027),
		Vector3(-0.205, BODY_H - 0.11, hd + 0.03), Vector3(-0.155, BODY_H - 0.06, hd + 0.027), Vector3(-0.14, BODY_H + 0.017, hd + 0.005),
		Vector3(-0.13, BODY_H - 0.04, 0.15),
	]
	var strand := Curve3D.new()
	for i in knots.size():
		var handle := (knots[mini(i + 1, knots.size() - 1)] - knots[maxi(i - 1, 0)]) * 0.2
		strand.add_point(knots[i], -handle, handle)
	var length := strand.get_baked_length()
	var count := int(length / 0.022)
	for i in count + 1:
		b.ellipsoid(S_GEM, Transform3D(Basis.IDENTITY, strand.sample_baked(length * float(i) / float(count))), Vector3.ONE * 0.0105, PEARL, 4, 8)


## A cut gem: an octagonal crown and pavilion with flat facets.
static func _gem(b: Builder, centre: Vector3, radius: float, color: Color, yaw: float) -> void:
	var girdle := PackedVector3Array()
	var table := PackedVector3Array()
	for i in 8:
		var angle := yaw + TAU * float(i) / 8.0
		girdle.append(centre + Vector3(cos(angle), 0.0, sin(angle)) * radius)
		table.append(centre + Vector3(cos(angle) * radius * 0.55, radius * 0.5, sin(angle) * radius * 0.55))
	var culet := centre + Vector3.DOWN * radius * 0.9
	b.polygon(S_GEM, table, Vector3.UP, color)
	for i in 8:
		var j := (i + 1) % 8
		var crown_n := ((girdle[i] + girdle[j] + table[i] + table[j]) * 0.25 - centre).normalized()
		var ids := PackedInt32Array()
		for p in [girdle[i], girdle[j], table[j], table[i]]:
			ids.append(b.vertex(S_GEM, p, crown_n, Vector2.ZERO, color))
		b.quad(S_GEM, ids[0], ids[1], ids[2], ids[3], crown_n)
		var pavilion_n := ((girdle[i] + girdle[j] + culet) / 3.0 - centre).normalized()
		var dark := color.darkened(0.3)
		var a := b.vertex(S_GEM, girdle[i], pavilion_n, Vector2.ZERO, dark)
		var c := b.vertex(S_GEM, girdle[j], pavilion_n, Vector2.ZERO, dark)
		var d := b.vertex(S_GEM, culet, pavilion_n, Vector2.ZERO, dark)
		b.tri(S_GEM, a, c, d, pavilion_n)


# --- The lid: a hollow barrel lid on the hinge line, with straps and the hasp.

## The lid's outer profile (or, inset by `inset`, inner; a negative inset grows
## it) in its (z, y) plane, from the back lip's bottom over the arch to the front
## lip's bottom, as rows [z, y, outward normal z, normal y, arc length].
static func lid_profile(inset: float, steps: int) -> Array:
	var a := LID_D * 0.5 - inset
	var arch := LID_ARCH - inset
	var z0 := LID_D * 0.5
	var points := [[z0 - a, 0.0, -1.0, 0.0]]
	for i in steps + 1:
		var angle := PI - PI * float(i) / float(steps)
		var normal := Vector2(cos(angle) / a, sin(angle) / arch).normalized()
		points.append([z0 + a * cos(angle), LID_LIP + arch * sin(angle), normal.x, normal.y])
	points.append([z0 + a, 0.0, 1.0, 0.0])
	var rows := []
	var arc := 0.0
	for i in points.size():
		if i > 0:
			arc += Vector2(points[i][0] - points[i - 1][0], points[i][1] - points[i - 1][1]).length()
		rows.append([points[i][0], points[i][1], points[i][2], points[i][3], arc])
	return rows


## A profile extruded along X from x0 to x1 (normals flipped when `flip`).
static func _lid_sheet(b: Builder, s: int, profile: Array, x0: float, x1: float, color: Color, flip := false) -> void:
	var rows := profile.size() - 1
	var sign_value := -1.0 if flip else 1.0
	var fn := func(u: float, v: float) -> Array:
		var row: Array = profile[int(round(v * rows))]
		var p := Vector3(lerpf(x0, x1, u), row[1], row[0])
		return [p, Vector3(0.0, row[3], row[2]) * sign_value, Vector2(p.x, row[4]) / PLANK_TILE]
	b.sheet(s, rows, 1, fn, color)


static func lid(m: Materials) -> ArrayMesh:
	var b := Builder.new(3)
	var hw := LID_W * 0.5
	var outer := lid_profile(0.0, 14)
	var inner := lid_profile(WALL, 14)
	_lid_sheet(b, S_WOOD, outer, -hw, hw, WOOD_OUTER)
	_lid_sheet(b, S_WOOD, inner, -hw + WALL, hw - WALL, WOOD_INNER, true)
	for side: float in [-1.0, 1.0]:
		var end_outer := PackedVector3Array()
		for row: Array in outer:
			end_outer.append(Vector3(side * hw, row[1], row[0]))
		b.polygon(S_WOOD, end_outer, Vector3(side, 0, 0), WOOD_OUTER, Vector3(0, 0, 1.0 / PLANK_TILE), Vector3(0, -1.0 / PLANK_TILE, 0))
		var end_inner := PackedVector3Array()
		for row: Array in inner:
			end_inner.append(Vector3(side * (hw - WALL), row[1], row[0]))
		b.polygon(S_WOOD, end_inner, Vector3(-side, 0, 0), WOOD_INNER, Vector3(0, 0, 1.0 / PLANK_TILE), Vector3(0, -1.0 / PLANK_TILE, 0))
	# The rim between the outer and inner shells, facing down.
	var o: Array[Vector3] = [Vector3(-hw, 0, 0), Vector3(hw, 0, 0), Vector3(hw, 0, LID_D), Vector3(-hw, 0, LID_D)]
	var n: Array[Vector3] = [Vector3(-hw + WALL, 0, WALL), Vector3(hw - WALL, 0, WALL), Vector3(hw - WALL, 0, LID_D - WALL), Vector3(-hw + WALL, 0, LID_D - WALL)]
	for k in 4:
		var ids := PackedInt32Array()
		for p in [o[k], o[(k + 1) % 4], n[(k + 1) % 4], n[k]]:
			ids.append(b.vertex(S_WOOD, p, Vector3.DOWN, Vector2(p.x, p.z) / PLANK_TILE, WOOD_INNER))
		b.quad(S_WOOD, ids[0], ids[1], ids[2], ids[3], Vector3.DOWN)
	# Iron straps over the arch, matching the body's, with their thin edges.
	var strap := lid_profile(-0.008, 14)
	var rows := strap.size() - 1
	for x: float in [-0.20, 0.20]:
		_lid_sheet(b, S_METAL, strap, x - 0.03, x + 0.03, IRON)
		for edge: float in [-0.03, 0.03]:
			var fn := func(u: float, v: float) -> Array:
				var r := int(round(v * rows))
				var p := Vector3(x + edge, lerpf(outer[r][1], strap[r][1], u), lerpf(outer[r][0], strap[r][0], u))
				return [p, Vector3(signf(edge), 0, 0)]
			b.sheet(S_METAL, rows, 1, fn, IRON)
	# The lid's band round its lip, the hinge barrels and the brass hasp.
	b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(0, 0.018, LID_D + 0.007)), Vector3(hw + 0.014, 0.018, 0.007), IRON)
	b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(0, 0.018, -0.007)), Vector3(hw + 0.014, 0.018, 0.007), IRON)
	b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(hw + 0.007, 0.018, LID_D * 0.5)), Vector3(0.007, 0.018, LID_D * 0.5), IRON)
	b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(-hw - 0.007, 0.018, LID_D * 0.5)), Vector3(0.007, 0.018, LID_D * 0.5), IRON)
	for x: float in [-0.20, 0.20]:
		b.tube(S_METAL, Vector3(x - 0.035, 0.0, -0.016), Vector3(x + 0.035, 0.0, -0.016), 0.016, 0.016, IRON, 10, true, true)
	b.box(S_METAL, Transform3D(Basis.IDENTITY, Vector3(0, -0.02, LID_D + 0.024)), Vector3(0.03, 0.05, 0.005), BRASS)
	b.torus(S_METAL, Vector3(0, -0.07, LID_D + 0.03), Vector3(0, 0, 1), 0.017, 0.006, BRASS, 12, 6)
	return b.commit([m.wood, m.metal, m.paint])


static func lid_outline(m: Materials) -> ArrayMesh:
	var b := Builder.new(1)
	var profile := lid_profile(-OUTLINE, 14)
	var hw := LID_W * 0.5 + OUTLINE
	_lid_sheet(b, 0, profile, -hw, hw, OUTLINE_COLOR)
	for side: float in [-1.0, 1.0]:
		var points := PackedVector3Array()
		for row: Array in profile:
			points.append(Vector3(side * hw, row[1], row[0]))
		b.polygon(0, points, Vector3(side, 0, 0), OUTLINE_COLOR)
	b.polygon(0, PackedVector3Array([Vector3(-hw, 0, -OUTLINE), Vector3(hw, 0, -OUTLINE), Vector3(hw, 0, LID_D + OUTLINE), Vector3(-hw, 0, LID_D + OUTLINE)]), Vector3.DOWN, OUTLINE_COLOR)
	return b.commit([m.outline])


## The two eyes in the lid frame. UV is the eye-front coordinate in -1..1
## (x across, y up); UV2 = (side, front): side +1 for the eye on the chest's
## left, front > 0 on the visible front half.
static func eyes(m: Materials) -> ArrayMesh:
	var b := Builder.new(1)
	for side: float in [-1.0, 1.0]:
		var basis := Basis(Vector3.RIGHT, -EYE_TILT) * Basis(Vector3.UP, side * 0.12)
		var xform := Transform3D(basis, Vector3(side * EYE_CENTER.x, EYE_CENTER.y, EYE_CENTER.z))
		var fn := func(u: float, v: float) -> Array:
			var lat := lerpf(-PI * 0.5, PI * 0.5, v)
			var lon := u * TAU
			var unit := Vector3(cos(lat) * sin(lon), sin(lat), cos(lat) * cos(lon))
			var normal := Vector3(unit.x / EYE_RADII.x, unit.y / EYE_RADII.y, unit.z / EYE_RADII.z)
			return [xform * (unit * EYE_RADII), (basis * normal).normalized(), Vector2(unit.x, unit.y), Vector2(side, unit.z)]
		b.sheet(0, 12, 20, fn, Color.WHITE)
	return b.commit([m.eye])


# --- Hands, feet and limbs.

## A white cartoon glove; side +1 is the chest's left hand (palm towards -X).
static func glove(m: Materials, side: float, outline: bool) -> ArrayMesh:
	var b := Builder.new(1)
	b.scale = GLOVE_SCALE
	var color := OUTLINE_COLOR if outline else GLOVE
	if outline:
		b.grow = OUTLINE * 0.8
	b.tube(0, Vector3(0, 0.005, 0), Vector3(0, -0.05, 0), 0.040, 0.06, color, 14)
	b.torus(0, Vector3(0, -0.05, 0), Vector3.UP, 0.058, 0.013, color, 14, 6)
	b.ellipsoid(0, Transform3D(Basis.IDENTITY, Vector3(0, -0.105, 0)), Vector3(0.033, 0.062, 0.056), color, 8, 14)
	for z: float in [-0.031, 0.0, 0.031]:
		b.capsule(0, Vector3(-0.006 * side, -0.145, z), Vector3(-0.018 * side, -0.205, z * 1.12), 0.0195, color, 8)
	b.capsule(0, Vector3(-0.004 * side, -0.088, 0.045), Vector3(-0.02 * side, -0.118, 0.085), 0.02, color, 8)
	return b.commit([m.outline if outline else m.paint])


## Distance from (0, 0, -0.005) along `dir` (XZ) to the edge of the shoe's sole:
## the union of a toe ellipse and a heel ellipse, grown by `grow`.
static func _sole_reach(dir: Vector2, grow: float) -> float:
	var best := 0.0
	for e: Array in [[0.078, 0.105, 0.08], [0.064, 0.07, -0.06]]:
		var ax: float = e[0] + grow
		var az: float = e[1] + grow
		var oz: float = -0.005 - float(e[2])
		var qa: float = pow(dir.x / ax, 2.0) + pow(dir.y / az, 2.0)
		var qb: float = 2.0 * oz * dir.y / (az * az)
		var qc: float = pow(oz / az, 2.0) - 1.0
		best = maxf(best, (-qb + sqrt(maxf(qb * qb - 4.0 * qa * qc, 0.0))) / (2.0 * qa))
	return best


## A big round-toed cartoon shoe with a white sock cuff.
static func shoe(m: Materials, outline: bool) -> ArrayMesh:
	var b := Builder.new(1)
	b.scale = SHOE_SCALE
	if outline:
		b.grow = OUTLINE * 0.8
	var upper := OUTLINE_COLOR if outline else SHOE
	var sole := OUTLINE_COLOR if outline else SOLE
	var sock := OUTLINE_COLOR if outline else GLOVE
	b.ellipsoid(0, Transform3D(Basis.IDENTITY, Vector3(0, 0.058, 0.08)), Vector3(0.074, 0.058, 0.102), upper, 8, 16, 0.3, 1.0)
	b.ellipsoid(0, Transform3D(Basis.IDENTITY, Vector3(0, 0.054, -0.06)), Vector3(0.06, 0.052, 0.066), upper, 8, 14, 0.3, 1.0)
	# The sole: the toe and heel outline extruded 24 mm.
	var g := b.grow
	var top := PackedVector3Array()
	var bottom := PackedVector3Array()
	for i in 28:
		var angle := TAU * float(i) / 28.0
		var dir := Vector2(cos(angle), sin(angle))
		var p := Vector3(0, 0, -0.005) + Vector3(dir.x, 0, dir.y) * _sole_reach(dir, g)
		top.append(p + Vector3.UP * (0.024 + g))
		bottom.append(p + Vector3.DOWN * g)
	b.polygon(0, top, Vector3.UP, sole)
	b.polygon(0, bottom, Vector3.DOWN, sole)
	for i in top.size():
		var j := (i + 1) % top.size()
		var outward := ((bottom[i] + bottom[j]) * 0.5 - Vector3(0, 0, -0.005)) * Vector3(1, 0, 1)
		var ids := PackedInt32Array()
		for p in [bottom[i], bottom[j], top[j], top[i]]:
			ids.append(b.vertex(0, p, outward.normalized(), Vector2.ZERO, sole))
		b.quad(0, ids[0], ids[1], ids[2], ids[3], outward)
	var ankle := ANKLE / SHOE_SCALE
	b.tube(0, ankle + Vector3.DOWN * 0.05, ankle + Vector3.UP * 0.008, 0.047, 0.05, sock, 14)
	b.torus(0, ankle + Vector3.UP * 0.008, Vector3.UP, 0.05, 0.011, sock, 14, 6)
	return b.commit([m.outline if outline else m.paint])


## A hose: a tube the hose shader bends along a cubic Bezier. UV.x runs 0..1
## along the hose, UV.y 0..1 around it.
static func hose(material: ShaderMaterial) -> ArrayMesh:
	var b := Builder.new(1)
	var fn := func(u: float, v: float) -> Array:
		var angle := u * TAU
		var radial := Vector3(cos(angle), 0, sin(angle))
		return [radial * 0.04 + Vector3.DOWN * v * 0.5, radial, Vector2(v, u)]
	b.sheet(0, 20, 8, fn, Color.WHITE)
	return b.commit([material])


## The two jet flames below the nozzles in the body frame, one unit long down
## from each nozzle; the flame shader scales and flickers them. UV.y runs 0 at
## the nozzle to 1 at the tip; UV2.x is the flame's index.
static func flames(m: Materials) -> ArrayMesh:
	var b := Builder.new(1)
	for k in 2:
		var centre := Vector3((-1.0 if k == 0 else 1.0) * NOZZLE.x, NOZZLE.y, NOZZLE.z)
		var fn := func(u: float, v: float) -> Array:
			var angle := u * TAU
			var radial := Vector3(cos(angle), 0, sin(angle))
			var radius := 0.05 * (1.0 + 1.2 * v) * pow(1.0 - v, 0.8)
			return [centre + radial * radius + Vector3.DOWN * v, (radial + Vector3.DOWN * 0.3).normalized(), Vector2(u, v), Vector2(float(k), 0.0)]
		b.sheet(0, 10, 12, fn, Color.WHITE)
	return b.commit([m.flame])


## A unit sphere for the jet's smoke puffs.
static func puff(m: Materials) -> ArrayMesh:
	var b := Builder.new(1)
	b.ellipsoid(0, Transform3D.IDENTITY, Vector3.ONE, GLOVE, 6, 10)
	return b.commit([m.paint])


## One coin for the loose, jingling coins.
static func loose_coin(m: Materials) -> ArrayMesh:
	var b := Builder.new(1)
	_coin(b, 0, Transform3D.IDENTITY, GOLD)
	return b.commit([m.metal])


## Rest places of the loose coins on the heap, body frame.
static func loose_coin_rests(count: int) -> Array[Transform3D]:
	var rests: Array[Transform3D] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 23
	for i in count:
		var x := rng.randf_range(-0.22, 0.22)
		var z := rng.randf_range(-0.12, 0.16)
		var tilt := Basis.from_euler(Vector3(rng.randf_range(-0.35, 0.35), rng.randf_range(0, TAU), rng.randf_range(-0.35, 0.35)))
		rests.append(Transform3D(tilt, Vector3(x, gold_height(x, z) + 0.005, z)))
	return rests
