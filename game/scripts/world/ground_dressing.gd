extends Node3D
## Grass and small stones on the island's ground, generated round the camera while
## playing. There are no stored plants: the ground says where they grow, and this
## draws them.
##
## Two top-down captures of the real ground meshes, in a private world, read what
## the ground draws in a window round the camera: the ground-cover shader run once
## more (ground_dressing_capture.gdshaderinc) gives its colour, and its height, how
## thickly tufts stand and how tall they grow or how thickly stones lie, from the same
## cover map, family and patch logic that colour the ground. So the dressing follows
## any change to the map or the ground, its colour is the ground's, and its end can't
## show. Grass is kept uneven by rule, nothing placed: the capture lays thin and long
## patches and mottles the colour, and the blade shader varies each tuft's size, width
## and colour, lets a few go to seed and grows tufts long against edges. The worked
## yards' surfaces draw theirs by material (YARD_DRESS,
## ground_dressing_yard.gdshader). Paths, kerbs, paving, buildings and the feet of
## street props draw over the surface capture as a mask
## (ground_dressing_mask.gdshader), which stops grass cleanly at their edges.
##
## The grass (ground_dressing_blades.gdshader) is opaque tufts of blades and the stones
## (ground_dressing_stones.gdshader) opaque low-poly rocks, each in MultiMesh cells.
## The instances are only a repeating tile of points and a rank, shared by every cell,
## and the vertex shader stands each one on the capture. Cells form a quadtree round the
## camera, so draws stay few and far cells are large. Point i of a tile has rank
## i / count and is the same point in every cell, whatever its size: the shader thins
## points by rank with distance (density falling as distance squared), and a cell
## holds only the ranks that still stand at its nearest point, so nothing pops as
## cells change. Levels in LEVELS trade density for cost.
##
## No collision and no shadows. Everything here is drawn on its own render layer, so
## reflection probes skip it. Runs only on Forward+ (not the web's Compatibility
## renderer) and not headless.

const GROUND_COVER := preload("res://game/scripts/world/ground_cover.gd")
## Loaded in configure(), so a run that draws none (the web) never loads them.
const BLADE_SHADER_PATH := "res://game/resources/materials/world/ground_cover/ground_dressing_blades.gdshader"
const STONE_SHADER_PATH := "res://game/resources/materials/world/ground_cover/ground_dressing_stones.gdshader"
const MASK_SHADER_PATH := "res://game/resources/materials/world/ground_cover/ground_dressing_mask.gdshader"
const YARD_SHADER_PATH := "res://game/resources/materials/world/ground_cover/ground_dressing_yard.gdshader"

const DENSITY_SETTING := "treasure_island/ground_dressing/density"
const DENSITY_FLAG := "--ground-dressing"
const OFF := "off"
## What draws the grass: opaque blades, or the alpha-scissor cards kept as the fallback
## if blades cost too much on some machine. Stones may be left out to time them apart.
const CARDS_SETTING := "treasure_island/ground_dressing/cards"
const GRASS_SETTING := "treasure_island/ground_dressing/grass"
const STONES_SETTING := "treasure_island/ground_dressing/stones"
const RENDER_PRIORITY_SETTING := "treasure_island/ground_dressing/render_priority"
## tufts_m2: tufts per square metre at full density; ring_m: where the grass ends;
## width_scale: blade width, so a thinner level keeps its coverage; stones_m2 and
## stone_ring_m the same for stones (0 for none).
const LEVELS := {
	"low": {"tufts_m2": 56.0, "ring_m": 72.0, "width_scale": 1.7, "stones_m2": 0.0, "stone_ring_m": 0.0},
	"medium": {"tufts_m2": 100.0, "ring_m": 88.0, "width_scale": 1.27, "stones_m2": 7.0, "stone_ring_m": 40.0},
	"high": {"tufts_m2": 160.0, "ring_m": 104.0, "width_scale": 1.0, "stones_m2": 12.0, "stone_ring_m": 56.0},
}

## Each ground-cover family's dressing: how thickly tufts stand (0-1), their height
## in metres, and how thickly stones lie on its bare ground. A map recipe draws
## its family's dressing like its colours. From the dated photos: the maintained
## lawns mown to a few centimetres; the dry fields thin stems to about the shin over
## soil, stones lying where the soil shows.
const DRESS := {
	"lawn": Vector3(1.0, 0.058, 0.0),
	"park_lawn": Vector3(1.0, 0.052, 0.0),
	"sports": Vector3(1.0, 0.045, 0.0),
	"watered_pitch": Vector3(1.0, 0.048, 0.0),
	# A mown pitch keeps its blades short whatever their colour.
	"mown_pitch": Vector3(1.0, 0.04, 0.0),
	# Synthetic turf grows nothing: its pile is the ground's own even green.
	"turf": Vector3(0.0, 0.0, 0.0),
	"field": Vector3(0.6, 0.24, 0.3),
	"straw": Vector3(0.62, 0.2, 0.2),
	"rough_grass": Vector3(0.7, 0.32, 0.2),
	"dry_meadow": Vector3(0.5, 0.22, 0.3),
	"dry_field": Vector3(0.38, 0.2, 0.4),
	"bare": Vector3(0.04, 0.14, 0.45),
	"red_marsh": Vector3(0.0, 0.0, 0.0),
	"sand_pad": Vector3(0.12, 0.16, 0.25),
	"verge": Vector3(0.3, 0.2, 0.5),
}
## The same for the worked yards' surfaces, by material. A stones share over 1 is
## rubble: the share over 1 lies in piles of broken pieces in the surface's own texture.
const YARD_DRESS := {
	"yard_sand_pale": Vector3(0.14, 0.18, 0.3),
	"yard_gravel": Vector3(0.05, 0.14, 0.14),
	"yard_gravel_pale": Vector3(0.05, 0.14, 0.14),
	"yard_soil_dark": Vector3(0.08, 0.18, 0.3),
	"rubble_grey": Vector3(0.0, 0.0, 1.9),
}
## The tallest grass on a kerb verge, kept low whatever grows behind it.
const KERB_HEIGHT_LIMIT_M := 0.09
## A street prop masks grass only below this height of its own.
const PROP_MASK_M := 1.0

## The capture window round the camera, in metres, and its textures. Its corner
## snaps to SNAP_M, so a texel keeps its world place from one capture to the next,
## and it recentres when the camera has gone RECENTRE_M from its centre.
const WINDOW_M := 256.0
const SURFACE_PIXELS := 1024
const COLOUR_PIXELS := 768
const SNAP_M := 8.0
const RECENTRE_M := 22.0
## The capture cameras' height. They look straight down through an orthographic lens,
## so it only has to clear what they copy. The ground shader's capture pass reads the
## near ground's view distance, not theirs, so the capture draws the ground's detail
## (bare-edge noise, crisp edges, soil noise), not each layer's mean colour.
const CAPTURE_HEIGHT_M := 125.0

## The smallest cell, which is also the tile of points every cell repeats.
const CELL_M := 4.0
const MAX_CELL_LEVEL := 6
## A cell splits when the camera is nearer than this many of its sizes.
const SPLIT := 1.5
## Must match the shader: density is full to FULL_DENSITY_M and SHARE_MARGIN keeps the
## last ranks full height until they thin.
const FULL_DENSITY_M := 6.0
const SHARE_MARGIN := 1.15
## The ground's typical height, for the same distance on CPU and GPU.
const GROUND_Y_M := 4.0
## Cells are chosen again when the camera has moved this far.
const RESELECT_M := 1.5

## Blades in a tuft and the mesh levels: a cell's nearest distance, blades, segments.
const TUFT_BLADES := 12
const MID_BLADES := 8
const FAR_BLADES := 5
const MESH_LEVELS := [
	{"until_m": 8.0, "blades": TUFT_BLADES, "segments": 3},
	{"until_m": 24.0, "blades": MID_BLADES, "segments": 2},
	{"until_m": INF, "blades": FAR_BLADES, "segments": 1},
]
const TUFT_SEED := 20261107
const STONE_SEED := 20261108
## Cards in a card tuft, their half width as a share of a blade's, and how many
## fewer card tufts match the blades' coverage (card tuft area x alpha over a blade
## tuft's).
const CARDS_PER_TUFT := 3
## A card's place in its tuft: a plain blade, neither the stem nor one that thins out.
const CARD_BLADE_PLACE := 0.3
const CARD_HALF_WIDTH := 16.0
const CARD_TUFT_SHARE := 0.21

## Blades part round the player within this distance.
const BEND_RADIUS_M := 0.6

## The grass's own render layer (reflection probes draw layers 1 and 2).
const RENDER_DRESSING := 1 << 4

var surface_viewport: SubViewport
var colour_viewport: SubViewport

var _world: Node3D
var _player: Node3D
var _level := OFF
var _blades: Dictionary
var _cards: Dictionary
var _stones: Dictionary
## The ring drawing the grass, _blades or _cards.
var _grass: Dictionary
var _use_cards := false
var _render_priority := 0
var _draw_grass := true
var _draw_stones := true
var _selected_at := Vector3.INF
var _window_centre := Vector2.INF
var _capture_shader: Shader
## A ground family or yard material -> [colour material, surface material].
var _capture_materials := {}
## Every ground-cover material in the world, as keys.
var _ground_materials := {}
var _mask_block: ShaderMaterial
var _mask_pass: ShaderMaterial
var _mask_prop: ShaderMaterial


## The level this run draws, OFF where it isn't drawn at all: the flag on the
## command line, else the project setting.
static func run_level() -> String:
	if DisplayServer.get_name() == "headless" or RenderingServer.get_current_rendering_method() != "forward_plus":
		return OFF
	var choice := density_choice(OS.get_cmdline_user_args(), ProjectSettings.get_setting(DENSITY_SETTING, OFF))
	if not choice.ok:
		push_error(str(choice.message))
		return OFF
	return str(choice.level)


## The density a run asks for: --ground-dressing LEVEL in args, else the setting.
## {"ok": true, "level": ...}, or {"ok": false, "message": ...} for a bad value
## rather than a silent default.
static func density_choice(args: PackedStringArray, setting: Variant) -> Dictionary:
	var level := str(setting)
	var at := args.find(DENSITY_FLAG)
	if at >= 0:
		if at + 1 >= args.size():
			return {"ok": false, "message": "%s needs a value" % DENSITY_FLAG}
		level = args[at + 1]
	if level != OFF and not LEVELS.has(level):
		return {"ok": false, "message": "ground dressing density must be off, low, medium or high, not %s" % level}
	return {"ok": true, "level": level}


## The share of a cell's tufts that still stand at a distance: full to
## FULL_DENSITY_M, then falling as distance squared.
static func share_at(distance: float) -> float:
	var ratio := FULL_DENSITY_M / maxf(distance, FULL_DENSITY_M)
	return minf(1.0, SHARE_MARGIN * ratio * ratio)


## Density tier for a cell: it holds the first tier_share() of each tile's points,
## enough for every rank that stands at the cell's nearest point.
static func tier_at(distance: float) -> int:
	return maxi(0, floori(-2.0 * log(share_at(distance)) / log(2.0)))


## A tier's share of a tile's points: half a power of two per tier, so a cell never
## holds much more than it draws.
static func tier_share(tier: int) -> float:
	return pow(2.0, -0.5 * float(tier))


## The mesh level for a cell whose nearest point is this far away.
static func mesh_level_at(distance: float) -> int:
	for index in MESH_LEVELS.size():
		if distance < float(MESH_LEVELS[index].until_m):
			return index
	return MESH_LEVELS.size() - 1


## The quadtree round a camera: Vector3i(x, z, level) -> distance to its nearest
## point, the cells covering everything within ring_m. A cell of level L is
## CELL_M * 2^L across and (x, z) count cells of its size from the origin.
static func cells_around(at: Vector3, ring_m: float) -> Dictionary:
	var cells := {}
	var size := CELL_M * float(1 << MAX_CELL_LEVEL)
	for x in range(floori((at.x - ring_m) / size), floori((at.x + ring_m) / size) + 1):
		for z in range(floori((at.z - ring_m) / size), floori((at.z + ring_m) / size) + 1):
			_visit_cell(Vector3i(x, z, MAX_CELL_LEVEL), at, ring_m, cells)
	return cells


static func _visit_cell(cell: Vector3i, at: Vector3, ring_m: float, cells: Dictionary) -> void:
	var size := CELL_M * float(1 << cell.z)
	var nearest := Vector3(clampf(at.x, cell.x * size, (cell.x + 1) * size), GROUND_Y_M, clampf(at.z, cell.y * size, (cell.y + 1) * size))
	var distance := at.distance_to(nearest)
	if distance > ring_m:
		return
	if cell.z > 0 and distance < SPLIT * size:
		for child in 4:
			_visit_cell(Vector3i(cell.x * 2 + (child & 1), cell.y * 2 + (child >> 1), cell.z - 1), at, ring_m, cells)
		return
	cells[cell] = distance


## Point i of the tile: a low-discrepancy sequence, so any first share of it covers
## the tile evenly.
static func tile_point(index: int) -> Vector2:
	return Vector2(fposmod(0.5 + float(index) * 0.7548776662466927, 1.0), fposmod(0.5 + float(index) * 0.5698402909980532, 1.0)) * CELL_M


## One tuft at unit height, as the blade shader reads it. Every level draws the same
## first blades, so a cell changing mesh level keeps its tufts' shape. The first blade
## is a long stem with a seed head, which the shader shows in long grass; those only
## the near meshes have lie along the ground, a thatch under the rest; and the nearest
## mesh's extra blades, which end sooner, thicken the grass under the camera.
static func tuft_mesh(blades: int, segments: int, material: Material) -> ArrayMesh:
	var random := RandomNumberGenerator.new()
	random.seed = TUFT_SEED
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var roots := PackedVector2Array()
	var colours := PackedColorArray()
	var indices := PackedInt32Array()
	for blade in TUFT_BLADES:
		var angle := float(blade) * 2.39996 + random.randf_range(-0.4, 0.4)
		var root := Vector2(cos(angle), sin(angle)) * sqrt((float(blade) + 0.5) / float(TUFT_BLADES))
		var lean_angle := angle + random.randf_range(-0.6, 0.6)
		var lean_direction := Vector2(cos(lean_angle), sin(lean_angle))
		var lean := random.randf_range(0.1, 0.95)
		var length := random.randf_range(0.7, 1.0)
		var side := lean_direction.orthogonal().rotated(random.randf_range(-0.7, 0.7))
		var blade_width := random.randf_range(0.45, 1.7)
		var one_blade := random.randf()
		if blade >= blades:
			continue
		var stem := blade == 0
		var rise := 1.0
		if stem:
			length = 1.6
			lean = 0.25
			blade_width = 0.9
		elif blade >= FAR_BLADES and blade < MID_BLADES:
			lean = 1.2 + 0.7 * one_blade
			rise = 0.3
			blade_width = 1.3
		var side_3d := Vector3(side.x, 0.0, side.y)
		var first := vertices.size()
		var rows := _blade_rows(mini(segments, 2) if blade >= MID_BLADES else segments, stem)
		for row: Vector2 in rows:
			var t := row.x
			var point := _blade_point(t, lean_direction, lean, length, rise)
			var normal := side_3d.cross(_blade_point(minf(t + 0.05, 1.05), lean_direction, lean, length, rise) - _blade_point(t - 0.05, lean_direction, lean, length, rise)).normalized()
			if normal.y < 0.0:
				normal = -normal
			var colour := Color(side.x * 0.5 + 0.5, side.y * 0.5 + 0.5, one_blade, float(blade) / float(TUFT_BLADES))
			var half_widths := [0.0] if row.y == 0.0 else [-row.y, row.y]
			for half_width: float in half_widths:
				vertices.append(point)
				normals.append(normal)
				uvs.append(Vector2(half_width * blade_width, t))
				roots.append(root)
				colours.append(colour)
		for row in rows.size() - 2:
			var at := first + row * 2
			indices.append_array(PackedInt32Array([at, at + 1, at + 2, at + 1, at + 3, at + 2]))
		var last := first + (rows.size() - 2) * 2
		indices.append_array(PackedInt32Array([last, last + 1, last + 2]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_TEX_UV2] = roots
	arrays[Mesh.ARRAY_COLOR] = colours
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	return mesh


## A blade's rows, Vector2(t along it, half width), from root to a tip of no width. A
## blade tapers; a stem runs thin up to its seed head.
static func _blade_rows(segments: int, stem: bool) -> PackedVector2Array:
	if stem and segments >= 3:
		return PackedVector2Array([Vector2(0.0, 0.5), Vector2(0.4, 0.45), Vector2(0.68, 0.4), Vector2(0.76, 1.1), Vector2(0.88, 0.8), Vector2(1.0, 0.0)])
	if stem and segments == 2:
		return PackedVector2Array([Vector2(0.0, 0.5), Vector2(0.62, 0.42), Vector2(0.78, 1.0), Vector2(1.0, 0.0)])
	var rows := PackedVector2Array()
	for row in segments:
		var t := float(row) / float(segments)
		rows.append(Vector2(t, 1.0 - t * t))
	rows.append(Vector2(1.0, 0.0))
	return rows


## A blade's centre line at t of its length, at unit height: it rises, then leans.
static func _blade_point(t: float, direction: Vector2, lean: float, length: float, rise: float) -> Vector3:
	var along := clampf(t, 0.0, 1.0)
	var out := lean * pow(along, 1.8)
	return Vector3(direction.x * out, rise * length * (along - 0.3 * minf(lean, 1.0) * along * along), direction.y * out)


## One rock at unit radius, as the stone shader reads it: a jittered icosahedron,
## closed so a piece tipped on a slope shows no hollow, and its contact skirt (UV.x 1).
static func stone_mesh(material: Material) -> ArrayMesh:
	var random := RandomNumberGenerator.new()
	random.seed = STONE_SEED
	var golden := (1.0 + sqrt(5.0)) * 0.5
	var corners := PackedVector3Array()
	for corner: Vector3 in [Vector3(-1, golden, 0), Vector3(1, golden, 0), Vector3(-1, -golden, 0), Vector3(1, -golden, 0), Vector3(0, -1, golden), Vector3(0, 1, golden), Vector3(0, -1, -golden), Vector3(0, 1, -golden), Vector3(golden, 0, -1), Vector3(golden, 0, 1), Vector3(-golden, 0, -1), Vector3(-golden, 0, 1)]:
		corners.append(corner.normalized() * random.randf_range(0.8, 1.15))
	var faces := PackedInt32Array([0, 11, 5, 0, 5, 1, 0, 1, 7, 0, 7, 10, 0, 10, 11, 1, 5, 9, 5, 11, 4, 11, 10, 2, 10, 7, 6, 7, 1, 8, 3, 9, 4, 3, 4, 2, 3, 2, 6, 3, 6, 8, 3, 8, 9, 4, 9, 5, 2, 4, 11, 6, 2, 10, 8, 6, 7, 9, 8, 1])
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	for face in range(0, faces.size(), 3):
		var a := corners[faces[face]]
		var b := corners[faces[face + 1]]
		var c := corners[faces[face + 2]]
		var normal := (b - a).cross(c - a).normalized()
		# Godot's front faces wind clockwise seen from outside.
		if normal.dot(a + b + c) > 0.0:
			var swap := b
			b = c
			c = swap
			normal = (b - a).cross(c - a).normalized() * -1.0
		else:
			normal = -normal
		vertices.append_array(PackedVector3Array([a, b, c]))
		normals.append_array(PackedVector3Array([normal, normal, normal]))
		uvs.append_array(PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]))
	const SKIRT_SIDES := 6
	for side in SKIRT_SIDES:
		var from := float(side) / float(SKIRT_SIDES) * TAU
		var to := float(side + 1) / float(SKIRT_SIDES) * TAU
		var inner_a := Vector3(cos(from), 0.0, sin(from)) * 0.8
		var inner_b := Vector3(cos(to), 0.0, sin(to)) * 0.8
		var outer_a := Vector3(cos(from), 0.0, sin(from)) * 1.45
		var outer_b := Vector3(cos(to), 0.0, sin(to)) * 1.45
		vertices.append_array(PackedVector3Array([inner_a, outer_a, inner_b, inner_b, outer_a, outer_b]))
		for _corner in 6:
			normals.append(Vector3.UP)
		uvs.append_array(PackedVector2Array([Vector2(1.0, 1.0), Vector2(1.0, 0.0), Vector2(1.0, 1.0), Vector2(1.0, 1.0), Vector2(1.0, 0.0), Vector2(1.0, 0.0)]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	return mesh


## The fallback's tuft: crossed cards the blade shader treats as very wide blades.
static func card_mesh(material: Material) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var roots := PackedVector2Array()
	var colours := PackedColorArray()
	var indices := PackedInt32Array()
	for card in CARDS_PER_TUFT:
		var angle := float(card) / float(CARDS_PER_TUFT) * PI
		var first := vertices.size()
		for corner in 4:
			vertices.append(Vector3(0.0, float(corner >> 1), 0.0))
			normals.append(Vector3.UP)
			uvs.append(Vector2(CARD_HALF_WIDTH * (-1.0 if corner & 1 == 0 else 1.0), float(corner >> 1)))
			roots.append(Vector2.ZERO)
			colours.append(Color(cos(angle) * 0.5 + 0.5, sin(angle) * 0.5 + 0.5, float(card) / float(CARDS_PER_TUFT), CARD_BLADE_PLACE))
		indices.append_array(PackedInt32Array([first, first + 1, first + 2, first + 1, first + 3, first + 2]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_TEX_UV2] = roots
	arrays[Mesh.ARRAY_COLOR] = colours
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	return mesh


## The cards' image, drawn here: blades rising from the bottom edge, red their shade.
static func card_texture() -> ImageTexture:
	const SIZE := 128
	var image := Image.create_empty(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var random := RandomNumberGenerator.new()
	random.seed = TUFT_SEED
	for blade in 44:
		var foot := random.randf_range(0.08, 0.92) * float(SIZE)
		var lean := random.randf_range(-0.25, 0.25) * float(SIZE)
		var rows := random.randf_range(0.55, 1.0) * float(SIZE)
		var half_width := random.randf_range(1.2, 2.2)
		var shade := random.randf_range(0.7, 1.0)
		for row in int(rows):
			var t := float(row) / rows
			var at := foot + lean * t * t
			for x in range(maxi(0, floori(at - half_width * (1.0 - t * t))), mini(SIZE - 1, ceili(at + half_width * (1.0 - t * t))) + 1):
				image.set_pixel(x, SIZE - 1 - row, Color(shade * lerpf(0.72, 1.0, t), 0.0, 0.0, 1.0))
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)


func configure(world: Node3D, player: Node3D, level: String) -> void:
	_world = world
	_player = player
	var meshes: Array[Mesh] = []
	var blades := _ring_material("ground_dressing_blades", load(BLADE_SHADER_PATH))
	for entry: Dictionary in MESH_LEVELS:
		meshes.append(tuft_mesh(int(entry.blades), int(entry.segments), blades))
	_blades = _new_ring(blades, meshes, true)
	var stones := _ring_material("ground_dressing_stones", load(STONE_SHADER_PATH))
	var stone_meshes: Array[Mesh] = [stone_mesh(stones)]
	_stones = _new_ring(stones, stone_meshes, false)
	_use_cards = bool(ProjectSettings.get_setting(CARDS_SETTING, false))
	_draw_grass = bool(ProjectSettings.get_setting(GRASS_SETTING, true))
	_draw_stones = bool(ProjectSettings.get_setting(STONES_SETTING, true))
	_render_priority = int(ProjectSettings.get_setting(RENDER_PRIORITY_SETTING, 0))
	var started := Time.get_ticks_msec()
	_build_captures()
	print("GROUND_DRESSING level=%s surface_copies=%d colour_copies=%d build_ms=%d" % [level, surface_viewport.get_child_count() - 1, colour_viewport.get_child_count() - 1, Time.get_ticks_msec() - started])
	_share_captures(blades)
	_share_captures(stones)
	set_render_priority(_render_priority)
	_pick_grass()
	set_level(level)


func _ring_material(material_name: String, shader: Shader) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.resource_name = material_name
	material.shader = shader
	return material


## Gives a ring's material the captures and the placement settings it shares.
func _share_captures(material: ShaderMaterial) -> void:
	material.set_shader_parameter("ground_surface", surface_viewport.get_texture())
	material.set_shader_parameter("ground_colour", colour_viewport.get_texture())
	material.set_shader_parameter("tile_m", CELL_M)
	material.set_shader_parameter("full_density_m", FULL_DENSITY_M)
	material.set_shader_parameter("share_margin", SHARE_MARGIN)
	material.set_shader_parameter("ground_y_m", GROUND_Y_M)


## _grass from _use_cards. The cards are built only if something asks for them.
func _pick_grass() -> void:
	if _use_cards and _cards.is_empty():
		var shader := Shader.new()
		shader.code = "#define GROUND_DRESSING_CARDS\n" + (_blades.material.shader as Shader).code
		var cards := _ring_material("ground_dressing_cards", shader)
		cards.set_shader_parameter("card_texture", card_texture())
		cards.render_priority = _render_priority
		_share_captures(cards)
		var meshes: Array[Mesh] = [card_mesh(cards)]
		_cards = _new_ring(cards, meshes, false)
	_grass = _cards if _use_cards else _blades
	_window_centre = Vector2.INF


func _rings() -> Array[Dictionary]:
	var rings: Array[Dictionary] = [_blades, _stones]
	if not _cards.is_empty():
		rings.append(_cards)
	return rings


## Switches to a level of LEVELS, or OFF.
func set_level(level: String) -> void:
	if level == _level:
		return
	_level = level
	_selected_at = Vector3.INF
	for ring: Dictionary in _rings():
		_clear_ring(ring)
	if level == OFF:
		_set_lawn_threads(true)
		return
	var settings: Dictionary = LEVELS[level]
	_set_lawn_threads(false)
	if _draw_grass:
		_set_ring(_grass, float(settings.tufts_m2) * (CARD_TUFT_SHARE if _use_cards else 1.0), float(settings.ring_m))
	if _draw_stones:
		_set_ring(_stones, float(settings.stones_m2), float(settings.stone_ring_m))
	(_grass.material as ShaderMaterial).set_shader_parameter("width_scale", float(settings.width_scale))
	_warm_variants()


## The ground's lawn has tan threads painted through it, which stand for blades of
## straw and show as paint between real blades: with grass on, they take the colour of
## its green blades. Its distance mean moves by under one part in a hundred.
func _set_lawn_threads(shown: bool) -> void:
	for material: ShaderMaterial in _ground_materials:
		if shown:
			material.set_shader_parameter("lawn_straw", null)
		else:
			var blade: Variant = material.get_shader_parameter("lawn_blade")
			if blade == null:
				blade = RenderingServer.shader_get_parameter_default(material.shader.get_rid(), "lawn_blade")
			material.set_shader_parameter("lawn_straw", blade)


func get_level() -> String:
	return _level


## What draws: blades or cards, and whether grass and stones draw at all. For timing them.
func set_parts(cards: bool, grass: bool, stones: bool) -> void:
	var level := _level
	set_level(OFF)
	_use_cards = cards
	_draw_grass = grass
	_draw_stones = stones
	_pick_grass()
	set_level(level)


func set_render_priority(priority: int) -> void:
	_render_priority = priority
	for ring: Dictionary in _rings():
		(ring.material as ShaderMaterial).render_priority = priority


## Sets a uniform of the grass and of the ground captures, for tuning shots.
func set_parameter(uniform: String, value: Variant) -> void:
	for ring: Dictionary in _rings():
		(ring.material as ShaderMaterial).set_shader_parameter(uniform, value)
	for pair: Array in _capture_materials.values():
		for material: Material in pair:
			if material is ShaderMaterial:
				(material as ShaderMaterial).set_shader_parameter(uniform, value)
	_window_centre = Vector2.INF


## The captures' viewports, to read their render times and images.
func capture_viewports() -> Array[SubViewport]:
	return [surface_viewport, colour_viewport]


func _process(_delta: float) -> void:
	if _level == OFF:
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var at := camera.global_position
	if _player != null:
		var feet := _player.global_position
		(_grass.material as ShaderMaterial).set_shader_parameter("bend_centre", Vector4(feet.x, feet.y, feet.z, BEND_RADIUS_M))
	if at.y - GROUND_Y_M <= maxf(float(_grass.ring_m), float(_stones.ring_m)) and maxf(absf(at.x - _window_centre.x), absf(at.z - _window_centre.y)) > RECENTRE_M:
		_capture(at)
	if at.distance_to(_selected_at) > RESELECT_M:
		_selected_at = at
		_select_cells(_grass, at)
		_select_cells(_stones, at)


func _capture(at: Vector3) -> void:
	_window_centre = Vector2(snappedf(at.x, SNAP_M), snappedf(at.z, SNAP_M))
	for viewport: SubViewport in capture_viewports():
		(viewport.get_node("Camera") as Camera3D).position = Vector3(_window_centre.x, CAPTURE_HEIGHT_M, _window_centre.y)
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var window := Vector3(_window_centre.x - WINDOW_M * 0.5, _window_centre.y - WINDOW_M * 0.5, 1.0 / WINDOW_M)
	for ring: Dictionary in _rings():
		(ring.material as ShaderMaterial).set_shader_parameter("ground_window", window)


func _new_ring(material: ShaderMaterial, meshes: Array[Mesh], mesh_levels: bool) -> Dictionary:
	# cells: Vector3i(x, z, level) -> its MultiMeshInstance3D; variants:
	# Vector3i(level, tier, mesh level) -> MultiMesh; mesh_levels: whether a cell's mesh
	# changes with distance (MESH_LEVELS), or it has the one.
	return {"material": material, "meshes": meshes, "mesh_levels": mesh_levels, "tile_points": 0, "ring_m": 0.0, "cells": {}, "variants": {}, "pool": []}


func _set_ring(ring: Dictionary, points_m2: float, ring_m: float) -> void:
	ring.tile_points = ceili(points_m2 * CELL_M * CELL_M)
	ring.ring_m = ring_m
	(ring.material as ShaderMaterial).set_shader_parameter("tile_points", float(ring.tile_points))
	(ring.material as ShaderMaterial).set_shader_parameter("ring_end_m", ring_m)


func _clear_ring(ring: Dictionary) -> void:
	for cell: Vector3i in (ring.cells as Dictionary).keys():
		_release_cell(ring, cell)
	(ring.variants as Dictionary).clear()
	ring.tile_points = 0
	ring.ring_m = 0.0


## Fits a ring's cells to the camera.
func _select_cells(ring: Dictionary, at: Vector3) -> void:
	var cells: Dictionary = ring.cells
	var wanted := {} if int(ring.tile_points) == 0 else cells_around(at, float(ring.ring_m))
	for cell: Vector3i in cells.keys():
		if not wanted.has(cell):
			_release_cell(ring, cell)
	for cell: Vector3i in wanted:
		var distance: float = wanted[cell]
		# The camera may come RESELECT_M nearer before cells are chosen again.
		var multimesh := _variant(ring, cell.z, tier_at(distance - RESELECT_M), mesh_level_at(distance) if ring.mesh_levels else 0)
		if not cells.has(cell):
			cells[cell] = _claim_cell(ring, cell)
		var node: MultiMeshInstance3D = cells[cell]
		if node.multimesh != multimesh:
			node.multimesh = multimesh


func _claim_cell(ring: Dictionary, cell: Vector3i) -> MultiMeshInstance3D:
	var pool: Array = ring.pool
	var node: MultiMeshInstance3D = null
	if pool.is_empty():
		node = MultiMeshInstance3D.new()
		node.layers = RENDER_DRESSING
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		node.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
		add_child(node)
	else:
		node = pool.pop_back()
		node.visible = true
	var size := CELL_M * float(1 << cell.z)
	node.position = Vector3(float(cell.x) * size, 0.0, float(cell.y) * size)
	# The shader moves instances from their place to the ground and out of the cell
	# by up to a tuft's reach, as wide as a far blade grows.
	node.custom_aabb = AABB(Vector3(-3.0, -2.0, -3.0), Vector3(size + 6.0, 32.0, size + 6.0))
	return node


func _release_cell(ring: Dictionary, cell: Vector3i) -> void:
	var node: MultiMeshInstance3D = ring.cells[cell]
	node.visible = false
	(ring.cells as Dictionary).erase(cell)
	(ring.pool as Array).append(node)


## Builds every cell variant a ring can need now, so moving never waits on one. A
## level's cells stand from their split distance to twice that, a cell's diagonal on.
func _warm_variants() -> void:
	for ring: Dictionary in [_grass, _stones]:
		if int(ring.tile_points) == 0:
			continue
		for level in MAX_CELL_LEVEL + 1:
			var size := CELL_M * float(1 << level)
			var from_m := 0.0 if level == 0 else SPLIT * size
			var to_m := minf(float(ring.ring_m), 2.0 * SPLIT * size + 1.5 * size)
			var distance := from_m
			while distance <= to_m:
				_variant(ring, level, tier_at(distance - RESELECT_M), mesh_level_at(distance) if ring.mesh_levels else 0)
				distance += 0.5


## The instances of a cell of this level, tier and mesh level: for each tile of the
## cell, its first tier_share() of points. Their y is the point's rank.
func _variant(ring: Dictionary, level: int, tier: int, mesh_level: int) -> MultiMesh:
	var variants: Dictionary = ring.variants
	var key := Vector3i(level, tier, mesh_level)
	if variants.has(key):
		return variants[key]
	var tile_points: int = ring.tile_points
	var per_tile := maxi(1, ceili(float(tile_points) * tier_share(tier)))
	var tiles := 1 << level
	var data := PackedFloat32Array()
	data.resize(tiles * tiles * per_tile * 12)
	var at := 0
	for tile_x in tiles:
		for tile_z in tiles:
			for index in per_tile:
				var point := tile_point(index) + Vector2(float(tile_x), float(tile_z)) * CELL_M
				data[at] = 1.0
				data[at + 3] = point.x
				data[at + 5] = 1.0
				data[at + 7] = (float(index) + 0.5) / float(tile_points)
				data[at + 10] = 1.0
				data[at + 11] = point.y
				at += 12
	var made := MultiMesh.new()
	made.transform_format = MultiMesh.TRANSFORM_3D
	made.mesh = ring.meshes[mesh_level]
	made.instance_count = tiles * tiles * per_tile
	made.buffer = data
	variants[key] = made
	return made


func _make_viewport(viewport_name: String, pixels: int) -> SubViewport:
	var viewport := SubViewport.new()
	viewport.name = viewport_name
	viewport.size = Vector2i(pixels, pixels)
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	# Linear half floats: metres survive, and no sRGB curve touches them.
	viewport.use_hdr_2d = true
	viewport.msaa_3d = Viewport.MSAA_DISABLED
	viewport.positional_shadow_atlas_size = 0
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	viewport.gui_disable_input = true
	add_child(viewport)
	var camera := Camera3D.new()
	camera.name = "Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = WINDOW_M
	camera.near = 1.0
	camera.far = 300.0
	camera.rotation = Vector3(-PI * 0.5, 0.0, 0.0)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color.BLACK
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	camera.environment = environment
	viewport.add_child(camera)
	camera.make_current()
	return viewport


## Copies the ground, roads, buildings and street props into the captures' private
## worlds.
func _build_captures() -> void:
	surface_viewport = _make_viewport("GroundSurface", SURFACE_PIXELS)
	colour_viewport = _make_viewport("GroundColour", COLOUR_PIXELS)
	_capture_shader = Shader.new()
	_capture_shader.code = "#define GROUND_DRESSING_CAPTURE\n" + (GROUND_COVER.SHADER as Shader).code
	var mask_shader: Shader = load(MASK_SHADER_PATH)
	_mask_block = _ring_material("ground_dressing_mask", mask_shader)
	_mask_pass = _ring_material("ground_dressing_mask_pass", mask_shader)
	_mask_pass.set_shader_parameter("factor", Vector4.ONE)
	_mask_prop = _ring_material("ground_dressing_mask_prop", mask_shader)
	_mask_prop.set_shader_parameter("below_m", PROP_MASK_M)
	for parent_name: String in ["ground_and_areas", "roads_and_paths", "buildings"]:
		var parent: Node = _world.get(parent_name)
		for node: Node in parent.find_children("*", "MeshInstance3D", true, false):
			var source := node as MeshInstance3D
			if source.mesh != null and source.is_visible_in_tree():
				_copy_mesh(source)
	var street_detail: Node = _world.get("street_detail")
	for layer: String in ["Furniture", "Clutter"]:
		for node: Node in street_detail.get_node(layer).find_children("*", "MultiMeshInstance3D", true, false):
			var source := node as MultiMeshInstance3D
			# Of a prop's two detail levels the near one is enough.
			if source.multimesh != null and source.visibility_range_begin == 0.0:
				var copy := MultiMeshInstance3D.new()
				copy.multimesh = source.multimesh
				copy.material_override = _mask_prop
				copy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
				copy.transform = source.global_transform
				surface_viewport.add_child(copy)


func _copy_mesh(source: MeshInstance3D) -> void:
	var kerb := str(source.get_parent().get_meta("feature_kind", "")) == "street_kerb"
	var surface_materials: Array[Material] = []
	var colour_materials: Array[Material] = []
	var on_ground := false
	for index in source.mesh.get_surface_count():
		var pair := _capture_pair(source.get_active_material(index), kerb)
		if pair.is_empty():
			surface_materials.append(_mask_block)
			colour_materials.append(_mask_pass)
		else:
			colour_materials.append(pair[0])
			surface_materials.append(pair[1])
			on_ground = true
	_add_copy(surface_viewport, source, surface_materials)
	if on_ground:
		_add_copy(colour_viewport, source, colour_materials)


func _add_copy(viewport: SubViewport, source: MeshInstance3D, materials: Array[Material]) -> void:
	var copy := MeshInstance3D.new()
	copy.mesh = source.mesh
	copy.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	copy.transform = source.global_transform
	for index in materials.size():
		copy.set_surface_override_material(index, materials[index])
	viewport.add_child(copy)


## A surface material's capture materials, [colour, surface], or [] where nothing grows.
func _capture_pair(material: Material, kerb: bool) -> Array:
	if material == null:
		return []
	var shader_material := material as ShaderMaterial
	if shader_material != null and shader_material.shader != null and shader_material.shader.resource_path == (GROUND_COVER.SHADER as Shader).resource_path:
		return _ground_capture(shader_material, shader_material.resource_name.trim_prefix("ground_cover_"), kerb)
	if material is BaseMaterial3D and YARD_DRESS.has(material.resource_name):
		return _yard_capture(material as BaseMaterial3D)
	return []


## A family's capture materials: its own settings on the capture shader.
func _ground_capture(source: ShaderMaterial, family: String, kerb: bool) -> Array:
	_ground_materials[source] = true
	var key := family + ("/kerb" if kerb else "")
	if _capture_materials.has(key):
		return _capture_materials[key]
	var pair: Array = []
	for capture_surface: bool in [false, true]:
		var made := ShaderMaterial.new()
		made.shader = _capture_shader
		for uniform: Dictionary in source.shader.get_shader_uniform_list():
			var value: Variant = source.get_shader_parameter(uniform.name)
			if value != null:
				made.set_shader_parameter(uniform.name, value)
		made.set_shader_parameter("capture_surface", capture_surface)
		made.set_shader_parameter("dress_own", DRESS.get(family, Vector3.ZERO))
		for recipe: String in GROUND_COVER.COVER_MAP_RECIPES:
			var recipe_family: String = GROUND_COVER.COVER_MAP_RECIPES[recipe]
			made.set_shader_parameter("dress_" + recipe_family, DRESS[recipe_family])
		if kerb:
			made.set_shader_parameter("dress_height_limit", KERB_HEIGHT_LIMIT_M)
		pair.append(made)
	_capture_materials[key] = pair
	return pair


## A yard surface's capture materials: its own look unshaded, and its YARD_DRESS.
func _yard_capture(source: BaseMaterial3D) -> Array:
	if _capture_materials.has(source.resource_name):
		return _capture_materials[source.resource_name]
	var colour := source.duplicate() as BaseMaterial3D
	colour.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var surface := _ring_material("ground_dressing_yard", load(YARD_SHADER_PATH))
	surface.set_shader_parameter("dress", YARD_DRESS[source.resource_name])
	var pair := [colour, surface]
	var dress: Vector3 = YARD_DRESS[source.resource_name]
	if dress.z > 1.0:
		# Pieces of rubble wear the texture of the heap they lie in.
		var stones: ShaderMaterial = _stones.material
		stones.set_shader_parameter("rubble_albedo", source.albedo_texture)
		stones.set_shader_parameter("rubble_tint", source.albedo_color)
		stones.set_shader_parameter("rubble_tile_m", 10.0 / source.uv1_scale.x)
	_capture_materials[source.resource_name] = pair
	return pair
