extends RefCounted
## Tree shootout, variant A (evaluation only; the game does not use this yet):
## a parametric Mexican fan palm (Washingtonia robusta) and a wind-shaped
## Monterey cypress (Hesperocyparis macrocarpa). Each tree has LOD0, a cheaper
## LOD1 and a far impostor: a quad that turns to face the camera, textured with
## an image of LOD0 baked by tools/tree_shootout/bake_impostors.gd. Foliage is
## alpha-scissor cards on generated atlases (tools/tree_shootout/prepare_textures.gd).
## Units are metres; a tree's origin is the base of its trunk on the ground.

const DIR := "res://game/resources/vegetation_shootout/"
const FOLIAGE_SHADER := preload("res://game/resources/vegetation_shootout/foliage.gdshader")
const IMPOSTOR_SHADER := preload("res://game/resources/vegetation_shootout/impostor.gdshader")

# Atlas cells as UV rects; prepare_textures.gd writes this layout.
const PALM_FAN := Rect2(0.0, 0.0, 0.5, 0.5)
const PALM_FAN_OLD := Rect2(0.5, 0.5, 0.5, 0.5)
const PALM_DEAD := [Rect2(0.5, 0.0, 0.25, 0.5), Rect2(0.75, 0.0, 0.25, 0.5)]
## Inset a little so mipmaps don't pull the neighbouring cells' transparency
## into the boot where it wraps around the trunk.
const PALM_BOOT := Rect2(0.004, 0.504, 0.492, 0.492)
## The fan leaf's hastula (where the blade meets the petiole), from the top of its cell.
const FAN_HASTULA := 0.77
const CYPRESS_CLUMP := Rect2(0.0, 0.0, 0.5, 1.0)
const CYPRESS_PLATE := Rect2(0.5, 0.0, 0.5, 1.0)

## Side of one repeat of each square bark texture.
const PALM_BARK_METRES := 0.62
const CYPRESS_BARK_METRES := 1.0

const PALM := {
	"seed": 1,
	"height": 17.0,  # ground to the top of the trunk, where the crown starts
	"lean": 0.35,  # how far the top of the trunk leans over
	"bow": 0.12,  # sideways bow of the trunk
	"radius_low": 0.21,
	"radius_top": 0.17,
	"flare": 0.17,  # extra radius of the swollen base
	"fronds": 38,
	"petiole": 1.0,
	"blade": 1.65,  # fan leaf card size
	"boot": 1.7,  # leaf-base boot under the crown
	"skirt": true,  # dead fronds hanging under the crown
	"skirt_length": 2.4,
}

const CYPRESS := {
	"seed": 1,
	"height": 13.0,  # top of the canopy
	"spread": 17.0,  # canopy width
	"trunk_radius": 0.5,
	"fork": 2.4,  # where the trunk splits into leaders
	"leaders": 4,
	# Leeward direction (x, z). Treasure Island's prevailing wind is westerly,
	# so crowns reach further east (+X).
	"wind": Vector2(1.0, 0.0),
	"shear": 0.3,  # how much further the crown reaches leeward than windward
}

## Visibility ranges in metres: LOD0 until x, LOD1 until y, the impostor until z.
const PALM_RANGES := Vector3(30.0, 75.0, 3000.0)
const CYPRESS_RANGES := Vector3(40.0, 85.0, 3000.0)

var _materials := {}
var _frames := {}


## One mesh surface under construction.
class Surf:
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var uv2s := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()

	func add(position: Vector3, normal: Vector3, uv: Vector2, color := Color.WHITE, uv2 := Vector2.ZERO) -> int:
		verts.append(position)
		normals.append(normal.normalized())
		uvs.append(uv)
		uv2s.append(uv2)
		colors.append(color)
		return verts.size() - 1

	## Triangle a-b-c with its front (clockwise, in Godot) side toward outward.
	func tri(a: int, b: int, c: int, outward: Vector3) -> void:
		if (verts[b] - verts[a]).cross(verts[c] - verts[a]).dot(outward) > 0.0:
			indices.append_array(PackedInt32Array([a, c, b]))
		else:
			indices.append_array(PackedInt32Array([a, b, c]))

	func quad(a: int, b: int, c: int, d: int, outward: Vector3) -> void:
		tri(a, b, c, outward)
		tri(a, c, d, outward)

	func commit(mesh: ArrayMesh, material: Material, with_uv2 := false) -> void:
		if indices.is_empty():
			return
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = verts
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		if with_uv2:
			arrays[Mesh.ARRAY_TEX_UV2] = uv2s
		arrays[Mesh.ARRAY_COLOR] = colors
		arrays[Mesh.ARRAY_INDEX] = indices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, material)


# --- Trees as nodes --------------------------------------------------------


## A tree node with LOD0, LOD1 and (when its image has been baked) the
## impostor as MeshInstance3D children switched by visibility range.
func tree_node(tree: Dictionary, ranges := Vector3.ZERO) -> Node3D:
	var species: String = tree.species
	if ranges == Vector3.ZERO:
		ranges = PALM_RANGES if species == "palm" else CYPRESS_RANGES
	var root := Node3D.new()
	root.name = "%s_A_%d" % [species, int(tree.params.seed)]
	var parts := [["LOD0", tree.lod0, 0.0, ranges.x], ["LOD1", tree.lod1, ranges.x, ranges.y]]
	var impostor := impostor_mesh(tree)
	if impostor != null:
		parts.append(["Impostor", impostor, ranges.y, ranges.z])
	else:
		parts[1][3] = ranges.z
	for part: Array in parts:
		var instance := MeshInstance3D.new()
		instance.name = part[0]
		instance.mesh = part[1]
		instance.visibility_range_begin = part[2]
		instance.visibility_range_end = part[3]
		instance.visibility_range_begin_margin = 2.0 if float(part[2]) > 0.0 else 0.0
		instance.visibility_range_end_margin = 2.0
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		root.add_child(instance)
	return root


func build(species: String, overrides := {}) -> Dictionary:
	return build_palm(overrides) if species == "palm" else build_cypress(overrides)


# --- Mexican fan palm ------------------------------------------------------


func build_palm(overrides := {}) -> Dictionary:
	var p := PALM.duplicate()
	p.merge(overrides, true)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var lean_angle := rng.randf() * TAU
	var bow_angle := lean_angle + rng.randf_range(1.2, 2.0)
	var shape := {
		"p": p,
		"lean": Vector2(cos(lean_angle), sin(lean_angle)) * float(p.lean),
		"bow": Vector2(cos(bow_angle), sin(bow_angle)) * float(p.bow),
	}
	var top := _palm_axis(shape, 1.0)
	var crown := top + Vector3(0.0, 0.5, 0.0)
	var fronds := _palm_fronds(p, rng, top)
	var spears := []
	for i in 3:
		spears.append({"azimuth": rng.randf() * TAU, "tilt": deg_to_rad(rng.randf_range(3.0, 14.0)), "length": rng.randf_range(1.0, 1.5)})
	var skirt := _palm_skirt(p, rng) if bool(p.skirt) else []
	var boot_radius := float(p.radius_top) + 0.16
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var bark := Surf.new()
		var leaves := Surf.new()
		_palm_trunk(bark, shape, 22 if lod == 0 else 7, 12 if lod == 0 else 7)
		_palm_boot(leaves, shape, lod)
		for frond: Dictionary in fronds:
			_palm_frond(bark, leaves, frond, crown, lod)
		if lod == 0:
			for spear: Dictionary in spears:
				_palm_spear(leaves, spear, top)
		for card: Dictionary in skirt:
			if lod == 0 or int(card.index) % 2 == 0:
				_palm_skirt_card(leaves, card, top, boot_radius, lod)
		bark.commit(mesh, material("palm_bark"))
		leaves.commit(mesh, material("palm_foliage"))
		meshes.append(mesh)
	return {"species": "palm", "params": p, "shape": shape, "lod0": meshes[0], "lod1": meshes[1], "top": top, "crown": crown}


func _palm_axis(shape: Dictionary, t: float) -> Vector3:
	var offset: Vector2 = shape.lean * pow(t, 1.7) + shape.bow * sin(PI * t)
	return Vector3(offset.x, t * float(shape.p.height), offset.y)


func _palm_radius(p: Dictionary, t: float) -> float:
	return lerpf(float(p.radius_low), float(p.radius_top), smoothstep(0.0, 1.0, t)) + float(p.flare) * exp(-t * float(p.height) / 0.55)


func _palm_trunk(s: Surf, shape: Dictionary, rings: int, sides: int) -> void:
	var p: Dictionary = shape.p
	var height := float(p.height)
	var points := PackedVector3Array()
	var radii := PackedFloat32Array()
	var colors := PackedColorArray()
	for i in rings + 1:
		var t := pow(float(i) / rings, 1.25)
		var h := t * height
		points.append(_palm_axis(shape, t))
		radii.append(_palm_radius(p, t))
		# Contact shading at the ground and under the crown.
		var ao := lerpf(0.7, 1.0, clampf(h / 0.6, 0.0, 1.0)) * lerpf(1.0, 0.65, clampf((h - (height - 2.0)) / 2.0, 0.0, 1.0))
		colors.append(Color(ao, ao, ao))
	_tube(s, points, radii, colors, sides, maxf(1.0, roundf(TAU * float(p.radius_low) / PALM_BARK_METRES)), PALM_BARK_METRES)


## The criss-cross sleeve of old leaf bases under the crown.
func _palm_boot(s: Surf, shape: Dictionary, lod: int) -> void:
	var p: Dictionary = shape.p
	var height := float(p.height)
	var length := float(p.boot)
	var sides := 12 if lod == 0 else 6
	var rows := 6 if lod == 0 else 2
	var rings: Array[int] = []
	for j in rows + 1:
		var f := float(j) / rows
		var h := height - length + f * (length + 0.3)
		var t := minf(h / height, 1.0)
		var center := _palm_axis(shape, t) + Vector3(0.0, maxf(0.0, h - height), 0.0)
		# Swells out over the leaf bases, then narrows into the crown.
		var radius := _palm_radius(p, t) + 0.015 + 0.13 * sin(f * PI * 0.8)
		var shade := lerpf(0.8, 0.5, f)
		rings.append(s.verts.size())
		for k in sides + 1:
			var angle := TAU * k / sides
			var direction := Vector3(cos(angle), 0.0, sin(angle))
			var uv := PALM_BOOT.position + Vector2(float(k) / sides, 1.0 - f) * PALM_BOOT.size
			s.add(center + direction * radius, direction + Vector3(0.0, 0.25, 0.0), uv, Color(shade, shade, shade))
	for j in rows:
		for k in sides:
			var a := rings[j] + k
			s.quad(a, a + 1, rings[j + 1] + k + 1, rings[j + 1] + k, s.normals[a])


func _palm_fronds(p: Dictionary, rng: RandomNumberGenerator, top: Vector3) -> Array:
	var fronds := []
	var count := int(p.fronds)
	for i in count:
		var age := float(i) / float(maxi(1, count - 1))  # 0 youngest (top) .. 1 oldest
		var azimuth := i * deg_to_rad(137.508) + rng.randf_range(-0.25, 0.25)
		var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
		fronds.append({
			"age": age,
			"azimuth": azimuth,
			"elevation": deg_to_rad(lerpf(70.0, -28.0, pow(age, 0.85)) + rng.randf_range(-7.0, 7.0)),
			"attach": top + out * 0.12 + Vector3(0.0, 0.55 - age * 0.75, 0.0),
			"petiole": float(p.petiole) * lerpf(0.8, 1.15, age) * rng.randf_range(0.9, 1.1),
			"blade": float(p.blade) * rng.randf_range(0.85, 1.08),
			"roll": rng.randf_range(-0.35, 0.35),
			"old": age > 0.58 and rng.randf() < 0.85,
			"shade": rng.randf_range(0.9, 1.06),
		})
	return fronds


func _palm_frond(bark: Surf, leaves: Surf, f: Dictionary, crown: Vector3, lod: int) -> void:
	var azimuth: float = f.azimuth
	var elevation: float = f.elevation
	var age: float = f.age
	var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
	var direction := out * cos(elevation) + Vector3.UP * sin(elevation)
	var start: Vector3 = f.attach
	var length: float = f.petiole
	# Petioles sag under the blade's weight, older ones more.
	var sag := Vector3(0.0, -(0.06 + 0.3 * age) * length, 0.0)
	var middle := start + direction * length * 0.5 + sag * 0.35
	var end := start + direction * length + sag
	if lod == 0:
		var stalk := Color(0.8, 0.76, 0.56)
		_tube(bark, PackedVector3Array([start, middle, end]), PackedFloat32Array([0.045, 0.035, 0.025]), PackedColorArray([stalk, stalk, stalk]), 3, 1.0, 1.2)
	# The blade continues outward from the petiole, held lower on older fronds.
	var tangent := (end - middle).normalized()
	var blade_elevation := atan2(tangent.y, Vector2(tangent.x, tangent.z).length()) - deg_to_rad(8.0 + 14.0 * age)
	var along := out * cos(blade_elevation) + Vector3.UP * sin(blade_elevation)
	var side := Vector3(-sin(azimuth), 0.0, cos(azimuth))
	var normal := side.cross(along).normalized()
	side = side.rotated(along, float(f.roll))
	normal = normal.rotated(along, float(f.roll))
	var size: float = f.blade
	var cell: Rect2 = PALM_FAN_OLD if bool(f.old) else PALM_FAN
	# The lowest, oldest fronds yellow and brown before they die into the skirt.
	var tint := Color.WHITE.lerp(Color(1.0, 0.8, 0.52), clampf((age - 0.6) / 0.4, 0.0, 1.0)) if bool(f.old) else Color.WHITE
	var columns := 4 if lod == 0 else 2
	var rows := 4 if lod == 0 else 1
	var base := leaves.verts.size()
	for j in rows + 1:
		# Distance along the blade from the hastula, in blade sizes.
		var y := lerpf(FAN_HASTULA - 1.0, FAN_HASTULA, float(j) / rows)
		for i in columns + 1:
			var x := lerpf(-0.5, 0.5, float(i) / columns)
			var r := sqrt(x * x + maxf(y, 0.0) * maxf(y, 0.0))
			# The halves fold up from the midrib; the segment tips droop.
			var lift := 0.16 * absf(x) - 0.55 * pow(maxf(r - 0.3, 0.0), 2.0)
			var position := end + side * (x * size) + along * (y * size) + normal * (lift * size)
			position.y -= 0.12 * age * r * r * size
			var n := normal * 0.45 + (position - crown).normalized() * 0.55
			var shade := clampf(0.56 + 0.44 * (position.y - crown.y + 1.8) / 2.6, 0.55, 1.0) * float(f.shade)
			leaves.add(position, n, cell.position + Vector2(x + 0.5, FAN_HASTULA - y) * cell.size, Color(shade * tint.r, shade * tint.g, shade * tint.b))
	for j in rows:
		for i in columns:
			var a := base + j * (columns + 1) + i
			leaves.quad(a, a + 1, a + columns + 2, a + columns + 1, normal)


## An unopened leaf standing up from the centre: the middle strip of the fan.
func _palm_spear(s: Surf, spear: Dictionary, top: Vector3) -> void:
	var azimuth: float = spear.azimuth
	var tilt: float = spear.tilt
	var up := Vector3(cos(azimuth) * sin(tilt), cos(tilt), sin(azimuth) * sin(tilt))
	var side := Vector3(-sin(azimuth), 0.0, cos(azimuth))
	var base := top + Vector3(0.0, 0.35, 0.0)
	var length: float = spear.length
	var cell := Rect2(PALM_FAN.position + Vector2(0.44, 0.02) * PALM_FAN.size, Vector2(0.12, FAN_HASTULA - 0.02) * PALM_FAN.size)
	var first := s.verts.size()
	for corner: Vector2 in [Vector2(-0.5, 0.0), Vector2(0.5, 0.0), Vector2(0.5, 1.0), Vector2(-0.5, 1.0)]:
		var position := base + side * corner.x * 0.16 + up * corner.y * length
		s.add(position, (side.cross(up) + Vector3.UP).normalized(), cell.position + Vector2(corner.x + 0.5, 1.0 - corner.y) * cell.size, Color(0.9, 0.9, 0.9))
	s.quad(first, first + 1, first + 2, first + 3, side.cross(up))


func _palm_skirt(p: Dictionary, rng: RandomNumberGenerator) -> Array:
	var cards := []
	var count := 18
	for i in count:
		cards.append({
			"index": i,
			"azimuth": TAU * i / count + rng.randf_range(-0.15, 0.15),
			"drop": 0.05 + (i % 2) * 0.5 + rng.randf_range(0.0, 0.2),
			"length": float(p.skirt_length) * rng.randf_range(0.7, 1.08),
			"flare": rng.randf_range(0.1, 0.24),
			"cell": rng.randi_range(0, 1),
			"shade": rng.randf_range(0.8, 1.0),
		})
	return cards


## A dead frond hanging against the trunk under the crown.
func _palm_skirt_card(s: Surf, card: Dictionary, top: Vector3, ring_radius: float, lod: int) -> void:
	var azimuth: float = card.azimuth
	var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
	var side := Vector3(-sin(azimuth), 0.0, cos(azimuth))
	var length: float = card.length
	var width := length * 0.5
	var cell: Rect2 = PALM_DEAD[int(card.cell)]
	var anchor := top + out * ring_radius + Vector3(0.0, 0.3 - float(card.drop), 0.0)
	var rows := 3 if lod == 0 else 1
	var base := s.verts.size()
	for j in rows + 1:
		var f := float(j) / rows
		var bulge := sin(f * PI) * 0.1 + float(card.flare) * f
		for i in 3:
			var x := (i - 1) * 0.5
			# Bows out, flares at the bottom and wraps a little around the trunk.
			var position := anchor + side * (x * width) + out * (bulge - 0.4 * x * x) + Vector3.DOWN * (f * length)
			var shade := lerpf(0.45, 0.85, f) * float(card.shade)
			s.add(position, out + Vector3(0.0, 0.3, 0.0) + side * x * 0.6, cell.position + Vector2(x + 0.5, f) * cell.size, Color(shade, shade, shade))
	for j in rows:
		for i in 2:
			var a := base + j * 3 + i
			s.quad(a, a + 1, a + 4, a + 3, out)


# --- Monterey cypress ------------------------------------------------------


func build_cypress(overrides := {}) -> Dictionary:
	var p := CYPRESS.duplicate()
	p.merge(overrides, true)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var skeleton := _cypress_skeleton(p, rng)
	var cards := _cypress_cards(rng, skeleton.clusters)
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var bark := Surf.new()
		var leaves := Surf.new()
		for branch: Dictionary in skeleton.branches:
			if lod == 0 or int(branch.depth) < 2:
				_cypress_branch(bark, branch, p, lod)
		for card: Dictionary in cards:
			if lod == 0 or bool(card.lod1):
				_cypress_card(leaves, card, skeleton, lod)
		bark.commit(mesh, material("cypress_bark"))
		leaves.commit(mesh, material("cypress_foliage"))
		meshes.append(mesh)
	return {"species": "cypress", "params": p, "lod0": meshes[0], "lod1": meshes[1], "crown": skeleton.crown}


## Trunk, leaders and side branches, plus the foliage clouds they carry.
func _cypress_skeleton(p: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var wind := Vector3(p.wind.x, 0.0, p.wind.y).normalized()
	var height := float(p.height)
	var radius := float(p.spread) * 0.5
	var trunk_radius := float(p.trunk_radius)
	var fork := Vector3(0.0, float(p.fork), 0.0) + wind * 0.3
	var branches := []
	var clusters := []
	# The trunk runs a little past the fork so the leaders grow out of it
	# rather than sitting on an open ring.
	branches.append({
		"depth": 0,
		"points": PackedVector3Array([Vector3.ZERO, Vector3(0.0, 0.45, 0.0), fork * 0.55, fork, fork + Vector3(0.0, 0.5, 0.0) + wind * 0.08]),
		"radii": PackedFloat32Array([trunk_radius * 1.5, trunk_radius * 1.12, trunk_radius, trunk_radius * 0.82, trunk_radius * 0.45]),
	})
	var phase := rng.randf() * TAU
	var leaders := int(p.leaders)
	for k in leaders:
		var azimuth := phase + TAU * k / leaders + rng.randf_range(-0.3, 0.3)
		var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
		var lee := out.dot(wind)
		var reach := radius * (1.0 + float(p.shear) * lee) * rng.randf_range(0.58, 0.7)
		var top_y := height * rng.randf_range(0.7, 0.78) * (1.0 - 0.08 * maxf(-lee, 0.0))
		var side := Vector3(-out.z, 0.0, out.x)
		var wobble := rng.randf() * TAU
		var kink := rng.randf_range(0.25, 0.45)
		var points := PackedVector3Array()
		var radii := PackedFloat32Array()
		var segments := 7
		# Every other leader splits off lower, as on multi-stemmed old cypresses.
		var start := fork - Vector3(0.0, 0.5 + (0.6 if k % 2 == 1 else 0.0), 0.0)
		for i in segments + 1:
			var s := float(i) / segments
			# Rises steeply out of the trunk, then arches out toward the crown's edge,
			# with an irregular sideways wander.
			var rise := (top_y - start.y) * (1.0 - pow(1.0 - s, 2.0))
			var wander := side * (sin(s * PI * 1.6 + wobble) * 0.7 + sin(s * PI * 4.0 + wobble * 2.0) * 0.2) * s
			points.append(start + out * reach * pow(s, 1.35 + kink) + Vector3.UP * rise + wander)
			radii.append(lerpf(trunk_radius * 0.66, 0.06, pow(s, 0.75)))
		branches.append({"depth": 1, "points": points, "radii": radii})
		# Big flattened clouds at the leader's end and two-thirds of the way out.
		clusters.append(_cloud(points[segments] + Vector3(0.0, 0.2, 0.0), rng.randf_range(3.0, 3.6), rng.randf_range(0.65, 0.85), lee, height))
		clusters.append(_cloud(_polyline_at(points, 0.62) + out * 0.8 + Vector3(0.0, 0.2, 0.0), rng.randf_range(2.3, 2.8), rng.randf_range(0.5, 0.7), lee, height))
		for s: float in [0.42, 0.6, 0.76, 0.9]:
			var count := 1 if rng.randf() < 0.35 else 2
			for b in count:
				var origin := _polyline_at(points, s)
				var turn := (1.0 if (b + k) % 2 == 0 else -1.0) * rng.randf_range(0.5, 1.2)
				var branch_out := out.rotated(Vector3.UP, turn)
				var length := rng.randf_range(2.0, 3.6) * (1.0 + 0.25 * branch_out.dot(wind)) * (1.1 - s * 0.4)
				var elevation := deg_to_rad(rng.randf_range(-8.0, 18.0))
				var direction := branch_out * cos(elevation) + Vector3.UP * sin(elevation)
				var end := origin + direction * length
				var start_radius := lerpf(trunk_radius * 0.66, 0.06, pow(s, 0.75)) * 0.55
				branches.append({
					"depth": 2,
					"points": PackedVector3Array([origin, origin + direction * length * 0.5 + Vector3(0.0, 0.18, 0.0), end]),
					"radii": PackedFloat32Array([start_radius, start_radius * 0.6, 0.03]),
				})
				clusters.append(_cloud(end + Vector3(0.0, 0.15, 0.0), rng.randf_range(2.0, 2.7), rng.randf_range(0.45, 0.65), branch_out.dot(wind), height))
	# A ring of clouds across the top closes the flat crown into one dense mass.
	var top_clouds := 3
	for i in top_clouds:
		var angle := TAU * i / top_clouds + rng.randf_range(-0.3, 0.3)
		var out := Vector3(cos(angle), 0.0, sin(angle))
		var distance := radius * rng.randf_range(0.25, 0.45) * (1.0 + float(p.shear) * out.dot(wind))
		var center := out * distance + Vector3(0.0, height * rng.randf_range(0.8, 0.88), 0.0) + wind * radius * 0.1
		clusters.append(_cloud(center, rng.randf_range(2.6, 3.2), rng.randf_range(0.55, 0.7), out.dot(wind), height))
	var crown := Vector3.ZERO
	for cloud: Dictionary in clusters:
		crown += cloud.center
	crown /= clusters.size()
	return {"branches": branches, "clusters": clusters, "crown": crown, "radius": radius, "height": height}


## A flattened foliage cloud. Windward clouds sit lower and flatter.
func _cloud(center: Vector3, reach: float, half_height: float, lee: float, height: float) -> Dictionary:
	if lee < 0.0:
		half_height *= 1.0 + 0.15 * lee
		center.y -= 0.3 * -lee
	center.y = minf(center.y, height - half_height * 0.85)
	return {"center": center, "reach": reach, "half_height": half_height}


func _polyline_at(points: PackedVector3Array, s: float) -> Vector3:
	var x := s * (points.size() - 1)
	var i := mini(int(floor(x)), points.size() - 2)
	return points[i].lerp(points[i + 1], x - i)


func _cypress_cards(rng: RandomNumberGenerator, clusters: Array) -> Array:
	var cards := []
	for cloud: Dictionary in clusters:
		var center: Vector3 = cloud.center
		var reach: float = cloud.reach
		var half_height: float = cloud.half_height
		var plates := clampi(int(round(reach * reach * 2.8)), 6, 26)
		# Wind-flattened layers, tilted a little.
		for i in plates:
			var angle := rng.randf() * TAU
			var distance := sqrt(rng.randf()) * reach * 0.7
			var tilt_axis := Vector3(cos(rng.randf() * TAU), 0.0, sin(rng.randf() * TAU)).normalized()
			cards.append({
				"kind": "plate",
				"center": center + Vector3(cos(angle) * distance, rng.randf_range(-0.1, 0.55) * half_height, sin(angle) * distance),
				"normal": Vector3.UP.rotated(tilt_axis, deg_to_rad(rng.randf_range(0.0, 14.0))),
				"spin": rng.randf() * TAU,
				"size": rng.randf_range(1.4, 2.3),
				"cloud": cloud,
				"lod1": i % 3 == 0,
				"shade": rng.randf_range(0.9, 1.08),
			})
		# Upright clumps around the rim give the clouds their ragged sides.
		for i in maxi(2, plates / 4):
			var angle := rng.randf() * TAU
			var out := Vector3(cos(angle), 0.0, sin(angle))
			cards.append({
				"kind": "clump",
				"center": center + out * reach * rng.randf_range(0.6, 0.9) + Vector3(0.0, rng.randf_range(-0.2, 0.3) * half_height, 0.0),
				"normal": (out + Vector3(0.0, rng.randf_range(0.1, 0.45), 0.0)).normalized(),
				"spin": rng.randf_range(-0.3, 0.3),
				"size": rng.randf_range(1.0, 1.5),
				"cloud": cloud,
				"lod1": i % 3 == 0,
				"shade": rng.randf_range(0.9, 1.08),
			})
	return cards


func _cypress_branch(s: Surf, branch: Dictionary, p: Dictionary, lod: int) -> void:
	var depth := int(branch.depth)
	var points: PackedVector3Array = branch.points
	var radii: PackedFloat32Array = branch.radii
	var colors := PackedColorArray()
	var height := float(p.height)
	var fork := float(p.fork)
	for point in points:
		# Daylit lower trunk, shaded limbs inside the canopy.
		var ao := lerpf(0.9, 0.5, clampf((point.y - fork) / (height * 0.6 - fork), 0.0, 1.0)) * lerpf(0.75, 1.0, clampf(point.y / 0.5, 0.0, 1.0))
		colors.append(Color(ao, ao, ao))
	var sides: int = [[12, 8, 5], [7, 5, 4]][lod][depth]
	var circumference := TAU * radii[0]
	_tube(s, points, radii, colors, sides, maxf(1.0, roundf(circumference / CYPRESS_BARK_METRES)), CYPRESS_BARK_METRES)


func _cypress_card(s: Surf, card: Dictionary, skeleton: Dictionary, lod: int) -> void:
	var normal: Vector3 = card.normal
	var plate: bool = card.kind == "plate"
	var size: float = card.size * (1.55 if lod == 1 else 1.0)
	var across: Vector3
	var upward: Vector3
	if plate:
		across = Vector3.RIGHT.cross(normal).normalized().rotated(normal, float(card.spin))
		upward = normal.cross(across)
	else:
		across = Vector3.UP.cross(normal).normalized().rotated(normal, float(card.spin))
		upward = normal.cross(across)
	var cell := CYPRESS_PLATE if plate else CYPRESS_CLUMP
	var cloud: Dictionary = card.cloud
	var cloud_center: Vector3 = cloud.center
	var half_height: float = cloud.half_height
	var crown: Vector3 = skeleton.crown
	var radius: float = skeleton.radius
	var grid := 2 if plate and lod == 0 else 1
	var center: Vector3 = card.center
	var base := s.verts.size()
	for j in grid + 1:
		for i in grid + 1:
			var x := float(i) / grid - 0.5
			var y := float(j) / grid - 0.5
			var position := center + across * (x * size) + upward * (y * size)
			if plate and grid > 1:
				# Domed: the middle of a layer sits higher than its ragged edge.
				position += normal * size * (0.12 - 0.34 * (x * x + y * y))
			var to_cloud := (position - cloud_center + Vector3(0.0, 0.3 * half_height, 0.0)).normalized()
			var n := normal * 0.3 + to_cloud * 0.45 + (position - crown).normalized() * 0.25
			# Darker underneath each cloud and toward the middle of the tree.
			var inside := clampf((position.y - (cloud_center.y - half_height)) / (2.0 * half_height), 0.0, 1.0)
			var outward := clampf(Vector2(position.x - crown.x, position.z - crown.z).length() / radius, 0.0, 1.0)
			var shade := clampf(lerpf(0.4, 1.0, pow(inside, 0.8)) * lerpf(0.68, 1.0, outward) * float(card.shade), 0.3, 1.0)
			s.add(position, n, cell.position + Vector2(x + 0.5, 0.5 - y) * cell.size, Color(shade, shade, shade))
	for j in grid:
		for i in grid:
			var a := base + j * (grid + 1) + i
			s.quad(a, a + 1, a + grid + 2, a + grid + 1, normal)


# --- Shared geometry --------------------------------------------------------


## A tube along points with the given radii; u wraps u_repeat times around, v
## advances one per v_metres of length.
func _tube(s: Surf, points: PackedVector3Array, radii: PackedFloat32Array, colors: PackedColorArray, sides: int, u_repeat: float, v_metres: float) -> void:
	var count := points.size()
	var tangent := (points[1] - points[0]).normalized()
	var normal := _perpendicular(tangent)
	var v := 0.0
	var rings: Array[int] = []
	for i in count:
		if i > 0:
			v += points[i].distance_to(points[i - 1]) / v_metres
		var next := (points[mini(i + 1, count - 1)] - points[maxi(i - 1, 0)]).normalized()
		var axis := tangent.cross(next)
		if axis.length() > 0.000001:
			normal = normal.rotated(axis.normalized(), tangent.angle_to(next))
		tangent = next
		normal = (normal - tangent * normal.dot(tangent)).normalized()
		var binormal := tangent.cross(normal)
		rings.append(s.verts.size())
		for k in sides + 1:
			var angle := TAU * k / sides
			var direction := normal * cos(angle) + binormal * sin(angle)
			s.add(points[i] + direction * radii[i], direction, Vector2(u_repeat * k / sides, v), colors[i])
	for i in count - 1:
		for k in sides:
			var a := rings[i] + k
			s.quad(a, a + 1, rings[i + 1] + k + 1, rings[i + 1] + k, s.normals[a] + s.normals[rings[i + 1] + k + 1])


func _perpendicular(direction: Vector3) -> Vector3:
	var reference := Vector3.RIGHT if absf(direction.x) < 0.9 else Vector3.FORWARD
	return direction.cross(reference).normalized()


# --- Impostors ---------------------------------------------------------------


## Where a species' impostor image is framed on its representative tree (the
## default parameters): centre and size in metres. The bake renders exactly
## this frame, looking along -Z.
func impostor_frame(species: String) -> Dictionary:
	if _frames.has(species):
		return _frames[species]
	var tree := build(species)
	var mesh: ArrayMesh = tree.lod0
	# The palm's impostor is only its crown (foliage surface); its trunk stays geometry.
	var box := _surface_bounds(mesh, 1) if species == "palm" else mesh.get_aabb()
	var frame := {"center": box.get_center(), "size": Vector2(box.size.x, box.size.y) * 1.04, "reference": tree}
	_frames[species] = frame
	return frame


func impostor_texture_path(species: String) -> String:
	return DIR + species + "_impostor.png"


## The impostor mesh for a tree, or null when its image hasn't been baked.
func impostor_mesh(tree: Dictionary) -> ArrayMesh:
	var species: String = tree.species
	if not ResourceLoader.exists(impostor_texture_path(species)):
		return null
	var frame := impostor_frame(species)
	var reference: Dictionary = frame.reference
	var center: Vector3
	var size: Vector2
	var mesh := ArrayMesh.new()
	if species == "palm":
		var scale := float(tree.params.blade) / float(reference.params.blade)
		center = tree.crown + (frame.center - reference.crown) * scale
		size = frame.size * scale
		var bark := Surf.new()
		_palm_trunk(bark, tree.shape, 3, 4)
		bark.commit(mesh, material("palm_bark"))
	else:
		var scale := Vector3(float(tree.params.spread) / float(reference.params.spread), float(tree.params.height) / float(reference.params.height), float(tree.params.spread) / float(reference.params.spread))
		center = frame.center * scale
		size = frame.size * Vector2(scale.x, scale.y)
	var quad := Surf.new()
	var first := quad.verts.size()
	for corner: Vector2 in [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0.5, 0.5), Vector2(-0.5, 0.5)]:
		quad.add(center, Vector3.BACK, Vector2(corner.x + 0.5, 0.5 - corner.y), Color.WHITE, corner * size)
	quad.indices.append_array(PackedInt32Array([first, first + 1, first + 2, first, first + 2, first + 3]))
	quad.commit(mesh, material(species + "_impostor"), true)
	# The quad turns in the vertex shader; bound every direction it can face.
	var reach := maxf(size.x * 0.5, 0.1)
	var box: AABB = (tree.lod0 as ArrayMesh).get_aabb().merge(AABB(center - Vector3(reach, size.y * 0.5, reach), Vector3(reach * 2.0, size.y, reach * 2.0)))
	mesh.custom_aabb = box
	return mesh


func _surface_bounds(mesh: ArrayMesh, surface: int) -> AABB:
	var vertices: PackedVector3Array = mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
	var box := AABB(vertices[0], Vector3.ZERO)
	for vertex in vertices:
		box = box.expand(vertex)
	return box


# --- Materials ---------------------------------------------------------------


func material(key: String) -> Material:
	if _materials.has(key):
		return _materials[key]
	var made: Material
	match key:
		"palm_bark":
			made = _bark(DIR + "palm_bark.png", Color(1.2, 1.17, 1.12))
		"cypress_bark":
			made = _bark(DIR + "cypress_bark.png", Color(0.92, 0.9, 0.88))
		"palm_foliage":
			made = _foliage(DIR + "palm_foliage_atlas.png", Color(0.68, 0.76, 0.56), Color(0.16, 0.2, 0.05), Vector2(2048.0, 2048.0), 0.22, 0.75)
		"cypress_foliage":
			made = _foliage(DIR + "cypress_foliage_atlas.png", Color(0.74, 0.8, 0.6), Color(0.08, 0.12, 0.04), Vector2(2048.0, 1024.0), 0.06, 0.95)
		"palm_impostor", "cypress_impostor":
			var shader := ShaderMaterial.new()
			shader.shader = IMPOSTOR_SHADER
			shader.set_shader_parameter("albedo_texture", load(impostor_texture_path(key.get_slice("_", 0))))
			made = shader
	_materials[key] = made
	return made


func _bark(path: String, tint: Color) -> StandardMaterial3D:
	var bark := StandardMaterial3D.new()
	bark.albedo_texture = load(path)
	bark.albedo_color = tint
	bark.vertex_color_use_as_albedo = true
	bark.roughness = 0.95
	bark.metallic_specular = 0.25
	bark.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return bark


func _foliage(path: String, tint: Color, translucency: Color, size: Vector2, specular: float, roughness: float) -> ShaderMaterial:
	var foliage := ShaderMaterial.new()
	foliage.shader = FOLIAGE_SHADER
	foliage.set_shader_parameter("albedo_texture", load(path))
	foliage.set_shader_parameter("tint", tint)
	foliage.set_shader_parameter("translucency", translucency)
	foliage.set_shader_parameter("texture_size", size)
	# Low specular: card normals bend toward the crown silhouette, where a
	# glossy grazing reflection would outline every card in pale sky colour.
	foliage.set_shader_parameter("specular", specular)
	foliage.set_shader_parameter("roughness", roughness)
	return foliage
