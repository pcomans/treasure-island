extends RefCounted
## The street-fence kit: procedural posts, rails, panels, fabric and collision for
## the fence rows of PlayableWorld/StreetDetail/Fences
## (tools/lib/street-fence-generation.mjs places them). One shared kit for every
## fence type: plain chain-link, chain-link with barbed wire (industrial),
## chain-link with a privacy windscreen and temporary chain-link panels
## (construction), and a wood board fence (housing).
##
## Metal parts are tubes and boxes of the street-furniture kit's builder, sharing
## its galvanised atlas cell; fabric, screens and boards are textured quads tiled
## in metres along the fence. Chain-link and barbed wire are blended from their
## textures' mipmaps (street_fence_mesh.gdshader): crisp wire up close, a faint
## even haze further away. A windscreen is a slightly see-through, translucent
## blended fabric.
## Blended surfaces cast no shadow, so a shadow-only copy of the wire (cut out by
## street_fence_mesh_shadow.gdshader) and of the screens shades the ground.
## Dimensions are US fence-trade sizes (6 ft fabric, 1 7/8 in line posts,
## 6 x 12 ft temporary panels, 8 ft wood bays), production inference, not survey
## data.
##
## A run is a list of posts on the visible ground (world positions). "inside" is
## the side of the run the fenced site lies on, left or right of the walking
## direction from the first post, or center: fabric and screens face that side.

const FURNITURE := preload("res://game/scripts/world/street_furniture_kit.gd")
const FABRIC_SHADER := preload("res://game/resources/materials/world/street/street_fence_mesh.gdshader")
const FABRIC_SHADOW_SHADER := preload("res://game/resources/materials/world/street/street_fence_mesh_shadow.gdshader")
const CHAIN_LINK := preload("res://game/resources/textures/world/street/street_fence_chainlink.png")
const BARBED := preload("res://game/resources/textures/world/street/street_fence_barbed.png")
const SCREEN := preload("res://game/resources/textures/world/street/street_fence_screen.png")
const WOOD := preload("res://game/resources/textures/world/street/street_fence_wood.png")

## The types tools/lib/street-fence-generation.mjs places (STREET_FENCE_TYPES):
## height and clearance half thickness must match it. collision_half_m is the
## half thickness of each bay's collision box: panels are jittered at their
## joints by up to PANEL_JITTER_M, which stays within the clearance.
const TYPES := {
	"chain_link": {"height_m": 1.83, "half_thickness_m": 0.06, "collision_half_m": 0.06},
	"chain_link_barbed": {"height_m": 2.13, "half_thickness_m": 0.25, "collision_half_m": 0.06},
	"chain_link_screened": {"height_m": 1.83, "half_thickness_m": 0.06, "collision_half_m": 0.06},
	"construction_panel": {"height_m": 1.83, "half_thickness_m": 0.3, "collision_half_m": 0.22},
	"wood_privacy": {"height_m": 1.83, "half_thickness_m": 0.08, "collision_half_m": 0.08},
}
const INSIDE := ["left", "right", "center"]
## Windscreen colours (sRGB, multiplied with the soft grey screen texture) and
## opacity: the photographed "black" screen reads as a smooth, neutral to
## slightly cool mid-dark grey on its sunlit and its shaded face alike (about
## 29/30/30 and 28/30/34 % in the Sep 2025 photos), with the site faintly
## visible through it. The knitted fabric is translucent, so sunlight through
## it lights the shaded face (SCREEN_BACKLIGHT, about half the sun in linear
## terms). The black tint leans blue because the island's sun and ambient light
## are warm.
const SCREENS := {"black": Color(0.32, 0.32, 0.43), "green": Color(0.34, 0.5, 0.4)}
const SCREEN_OPACITY := 0.92
const SCREEN_BACKLIGHT := Color(0.73, 0.73, 0.73)
## Visible ranges (m): a fence is long and low, so it reaches as far as a lamp pole.
const RANGE_M := 260.0
## Fabric tile sizes (m): the chain-link texture holds two diamonds each way,
## about 5 cm across each as in 2 in mesh.
const CHAIN_TILE := Vector2(0.10, 0.12)
const SCREEN_TILE_M := 0.5
const WOOD_TILE_M := 0.84
const BARBED_TILE_M := 0.48
## Temporary panels lean in and out at their joints, a few centimetres each way.
const PANEL_JITTER_M := 0.08

const GALVANIZED := Color(0.86, 0.87, 0.88)
const STAND_GREY := Color(0.24, 0.24, 0.25)
## Wire is thin: up close the mesh is see-through and far away it is a faint
## haze of its average coverage (about 15 % for the chain-link texture), so the
## tint stays below the posts. Seen obliquely the haze thickens up to
## WIRE_MAX_LAYERS layers of fabric. The shadow copy's alpha gains a little per
## mip level so the thin wire still casts a faint lattice of shade.
const WIRE_TINT := Color(0.74, 0.75, 0.77)
const WIRE_MAX_LAYERS := 4.0
const WIRE_COVERAGE_BOOST := 0.2
const WIRE_ALPHA_CUT := 0.45

var _metal: StandardMaterial3D
var _chain: ShaderMaterial
var _barbed: ShaderMaterial
var _chain_shadow: ShaderMaterial
var _barbed_shadow: ShaderMaterial
var _wood: StandardMaterial3D
var _screens: Dictionary = {}
var _screen_shadow: StandardMaterial3D


func _init() -> void:
	_metal = StandardMaterial3D.new()
	_metal.resource_name = "street_fence_metal"
	_metal.albedo_texture = FURNITURE.ATLAS
	_metal.vertex_color_use_as_albedo = true
	_metal.vertex_color_is_srgb = true
	_metal.roughness = 0.62
	_metal.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_metal.texture_repeat = false
	_chain = _fabric_material("street_fence_chain_link", CHAIN_LINK)
	_barbed = _fabric_material("street_fence_barbed", BARBED)
	_chain_shadow = _fabric_shadow_material("street_fence_chain_link_shadow", CHAIN_LINK)
	_barbed_shadow = _fabric_shadow_material("street_fence_barbed_shadow", BARBED)
	_wood = StandardMaterial3D.new()
	_wood.resource_name = "street_fence_wood"
	_wood.albedo_texture = WOOD
	_wood.roughness = 0.9
	_wood.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	for colour: String in SCREENS:
		var screen := StandardMaterial3D.new()
		screen.resource_name = "street_fence_screen_" + colour
		screen.albedo_texture = SCREEN
		screen.albedo_color = Color(SCREENS[colour], SCREEN_OPACITY)
		screen.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		screen.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
		screen.roughness = 0.95
		screen.cull_mode = BaseMaterial3D.CULL_DISABLED
		screen.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		screen.backlight_enabled = true
		screen.backlight = SCREEN_BACKLIGHT
		# The screen's own shadow copy would shadow its far face and put out the
		# light through it, so the screens take no shadows.
		screen.disable_receive_shadows = true
		_screens[colour] = screen
	# Blended surfaces cast no shadow: an opaque, shadow-only copy of each screen does.
	_screen_shadow = StandardMaterial3D.new()
	_screen_shadow.resource_name = "street_fence_screen_shadow"
	_screen_shadow.cull_mode = BaseMaterial3D.CULL_DISABLED


func _fabric_material(material_name: String, texture: Texture2D) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.resource_name = material_name
	material.shader = FABRIC_SHADER
	material.set_shader_parameter("wire_texture", texture)
	material.set_shader_parameter("tint", WIRE_TINT)
	material.set_shader_parameter("max_layers", WIRE_MAX_LAYERS)
	# The fabric writes no depth: drawn after the other blended surfaces (water,
	# street paint, screens), none of them can paint over the haze behind it.
	material.render_priority = 1
	return material


func _fabric_shadow_material(material_name: String, texture: Texture2D) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.resource_name = material_name
	material.shader = FABRIC_SHADOW_SHADER
	material.set_shader_parameter("wire_texture", texture)
	material.set_shader_parameter("coverage_boost", WIRE_COVERAGE_BOOST)
	material.set_shader_parameter("alpha_cut", WIRE_ALPHA_CUT)
	return material


## Why a fence row's type and params are unusable, or "".
static func params_error(type: String, params: Variant) -> String:
	if not TYPES.has(type):
		return "unknown fence type %s" % type
	if not params is Dictionary or str((params as Dictionary).get("inside", "")) not in INSIDE:
		return "fence params need inside left, right or center"
	if type == "chain_link_screened" and str((params as Dictionary).get("screen", "black")) not in SCREENS:
		return "unknown screen colour %s" % (params as Dictionary).get("screen")
	return ""


## Adds one run's geometry to the cell builders (cells: key -> builders, filled
## by cell_of) and returns its collision boxes as [{transform, size}] in world
## space. seed varies the panel jitter between runs.
func add_run(cells: Dictionary, cell_size_m: float, type: String, params: Dictionary, posts: PackedVector3Array, seed: int) -> Array[Dictionary]:
	var side := {"left": 1.0, "right": -1.0}.get(str(params.get("inside", "center")), 0.0) as float
	match type:
		"construction_panel":
			return _panels(cells, cell_size_m, posts, side, seed)
		"wood_privacy":
			return _wood_fence(cells, cell_size_m, posts, side)
		_:
			return _chain_link(cells, cell_size_m, type, posts, side, str(params.get("screen", "black")))


## The meshes of one cell's builders: "solid" (metal and boards, drawn with
## shadows), "fabric" (chain-link, barbed wire and screens, blended, no shadows)
## and "shadow" (a cut-out copy of the wire and an opaque copy of the screens
## that only cast shadows). A mesh is null when it would hold nothing.
func commit(cell: Dictionary) -> Dictionary:
	var solid: ArrayMesh = (cell.metal as FURNITURE.Builder).commit(_metal, _metal)
	var fabric := ArrayMesh.new()
	var shadow := ArrayMesh.new()
	_add_surface(solid, cell.wood, _wood)
	_add_surface(fabric, cell.chain, _chain)
	_add_surface(fabric, cell.barbed, _barbed)
	_add_surface(shadow, cell.chain, _chain_shadow)
	_add_surface(shadow, cell.barbed, _barbed_shadow)
	for colour: String in SCREENS:
		_add_surface(fabric, cell["screen_" + colour], _screens[colour])
		_add_surface(shadow, cell["screen_" + colour], _screen_shadow)
	return {
		"solid": solid if solid.get_surface_count() > 0 else null,
		"fabric": fabric if fabric.get_surface_count() > 0 else null,
		"shadow": shadow if shadow.get_surface_count() > 0 else null,
	}


func _add_surface(mesh: ArrayMesh, quads: Quads, material: Material) -> void:
	if quads.is_empty():
		return
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, quads.arrays())
	mesh.surface_set_material(mesh.get_surface_count() - 1, material)


static func cell_key(position: Vector3, cell_size_m: float) -> String:
	return "%d_%d" % [floori(position.x / cell_size_m), floori(position.z / cell_size_m)]


func _cell(cells: Dictionary, cell_size_m: float, position: Vector3) -> Dictionary:
	var key := cell_key(position, cell_size_m)
	if not cells.has(key):
		cells[key] = {
			"metal": FURNITURE.Builder.new(FURNITURE.CELL_WHITE),
			"chain": Quads.new(),
			"barbed": Quads.new(),
			"wood": Quads.new(),
			"screen_black": Quads.new(),
			"screen_green": Quads.new(),
		}
	return cells[key]


## Seen from above with north (-Z) up, the left of a horizontal direction (dx, dz).
static func _left(direction: Vector3) -> Vector3:
	return Vector3(direction.z, 0.0, -direction.x)


static func _flat(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0.0, vector.z).normalized()


## A post is a terminal post at a run's ends and where the run turns.
static func _terminal(posts: PackedVector3Array, index: int) -> bool:
	if index == 0 or index == posts.size() - 1:
		return true
	var before := _flat(posts[index] - posts[index - 1])
	var after := _flat(posts[index + 1] - posts[index])
	return before.dot(after) < cos(deg_to_rad(20.0))


## A collision box over one bay: as long as the bay, from just below its lower
## foot to the fence top above its higher one, half_m either side of its line.
static func _bay_box(a: Vector3, b: Vector3, height: float, half_m: float) -> Dictionary:
	var along := _flat(b - a)
	var low := minf(a.y, b.y) - 0.1
	var high := maxf(a.y, b.y) + height
	var basis := Basis(along, Vector3.UP, along.cross(Vector3.UP))
	var middle := (a + b) * 0.5
	return {
		"transform": Transform3D(basis, Vector3(middle.x, (low + high) * 0.5, middle.z)),
		"size": Vector3(Vector2(b.x - a.x, b.z - a.z).length(), high - low, half_m * 2.0),
	}


# ---------------------------------------------------------------- chain-link

## Chain-link on line posts with a top rail and a bottom tension wire; the
## screened type adds a windscreen on the inside, the barbed type angled arms
## with three strands of barbed wire leaning outward.
func _chain_link(cells: Dictionary, cell_size_m: float, type: String, posts: PackedVector3Array, side: float, screen: String) -> Array[Dictionary]:
	var spec: Dictionary = TYPES[type]
	var fabric_h := 1.83
	var boxes: Array[Dictionary] = []
	var along_m := 0.0
	for index in posts.size():
		var cell := _cell(cells, cell_size_m, posts[index])
		var metal: FURNITURE.Builder = cell.metal
		var terminal := _terminal(posts, index)
		var radius := 0.03 if terminal else 0.024
		var top := fabric_h + (0.06 if terminal else 0.03)
		var foot := posts[index]
		metal.tube(PackedVector3Array([foot + Vector3(0, -0.3, 0), foot + Vector3(0, top, 0)]), PackedFloat32Array([radius, radius]), 8, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		metal.tube(PackedVector3Array([foot + Vector3(0, top, 0), foot + Vector3(0, top + 0.04, 0)]), PackedFloat32Array([radius + 0.007, radius + 0.004]), 8, GALVANIZED, FURNITURE.CELL_METAL, false, true)
		if type == "chain_link_barbed":
			var outward := _post_normal(posts, index) * (-side if side != 0.0 else 1.0)
			var arm_end := foot + Vector3(0, top + 0.02, 0) + (Vector3.UP + outward).normalized() * 0.42
			metal.tube(PackedVector3Array([foot + Vector3(0, top, 0), arm_end]), PackedFloat32Array([0.016, 0.014]), 6, GALVANIZED, FURNITURE.CELL_METAL, false, true)
	for index in posts.size() - 1:
		var a := posts[index]
		var b := posts[index + 1]
		var length := Vector2(b.x - a.x, b.z - a.z).length()
		var middle := (a + b) * 0.5
		var cell := _cell(cells, cell_size_m, middle)
		var metal: FURNITURE.Builder = cell.metal
		var normal := _left(_flat(b - a))
		metal.tube(PackedVector3Array([a + Vector3(0, fabric_h - 0.02, 0), b + Vector3(0, fabric_h - 0.02, 0)]), PackedFloat32Array([0.021, 0.021]), 8, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		metal.tube(PackedVector3Array([a + Vector3(0, 0.07, 0), b + Vector3(0, 0.07, 0)]), PackedFloat32Array([0.004, 0.004]), 4, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		# Fabric just inside the posts (or through them on a centred fence). Behind
		# a windscreen the wire is barely visible, so the screen stands for both.
		var shift := normal * side * 0.035
		if type != "chain_link_screened":
			(cell.chain as Quads).wall(a + shift, b + shift, 0.05, fabric_h - 0.04, along_m, CHAIN_TILE)
		if type == "chain_link_screened":
			var screen_shift := normal * (side if side != 0.0 else 1.0) * 0.055
			(cell["screen_" + screen] as Quads).wall(a + screen_shift, b + screen_shift, 0.03, fabric_h - 0.07, along_m, Vector2(SCREEN_TILE_M, SCREEN_TILE_M))
		if type == "chain_link_barbed":
			var out_a := _post_normal(posts, index) * (-side if side != 0.0 else 1.0)
			var out_b := _post_normal(posts, index + 1) * (-side if side != 0.0 else 1.0)
			var lift := Vector3(0, fabric_h + 0.06, 0)
			var rise := 0.3
			(cell.barbed as Quads).ribbon(a + lift, b + lift, (Vector3.UP + out_a).normalized() * rise / 0.7071, (Vector3.UP + out_b).normalized() * rise / 0.7071, along_m, BARBED_TILE_M)
		boxes.append(_bay_box(a, b, float(spec.height_m), float(spec.collision_half_m)))
		along_m += length
	return boxes


## The horizontal normal at a post: the left of the run, averaged at a corner.
static func _post_normal(posts: PackedVector3Array, index: int) -> Vector3:
	var before := _flat(posts[index] - posts[index - 1]) if index > 0 else Vector3.ZERO
	var after := _flat(posts[index + 1] - posts[index]) if index < posts.size() - 1 else Vector3.ZERO
	var direction := (before + after).normalized() if (before + after).length() > 0.001 else (after if after != Vector3.ZERO else before)
	return _left(direction)


# ---------------------------------------------------------------- panels

## Temporary chain-link panels: a tube frame with chain-link infill between each
## pair of joints, the frames side by side at a joint with a clamp, standing on a
## low stand; the joints lean in and out a little, as hand-set panels do.
func _panels(cells: Dictionary, cell_size_m: float, posts: PackedVector3Array, side: float, seed: int) -> Array[Dictionary]:
	var spec: Dictionary = TYPES.construction_panel
	var joints := PackedVector3Array()
	for index in posts.size():
		var lean := 0.0
		if index > 0 and index < posts.size() - 1:
			lean = (_unit_hash(seed, index) * 2.0 - 1.0) * PANEL_JITTER_M
		joints.append(posts[index] + _post_normal(posts, index) * lean)
	var lift := 0.1
	var frame_h := 1.83
	var boxes: Array[Dictionary] = []
	var along_m := 0.0
	for index in joints.size() - 1:
		var a := joints[index]
		var b := joints[index + 1]
		var along := _flat(b - a)
		var length := Vector2(b.x - a.x, b.z - a.z).length()
		var cell := _cell(cells, cell_size_m, (a + b) * 0.5)
		var metal: FURNITURE.Builder = cell.metal
		var inset := minf(0.045, length * 0.1)
		var left_foot := a + along * inset + Vector3(0, lift, 0)
		var right_foot := b - along * inset + Vector3(0, lift, 0)
		var up := Vector3(0, frame_h, 0)
		var frame := PackedVector3Array([left_foot, left_foot + up, right_foot + up, right_foot, left_foot])
		metal.tube(frame, PackedFloat32Array([0.019, 0.019, 0.019, 0.019, 0.019]), 6, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		(cell.chain as Quads).wall(left_foot - Vector3(0, lift, 0), right_foot - Vector3(0, lift, 0), lift + 0.03, lift + frame_h - 0.03, along_m, CHAIN_TILE)
		boxes.append(_bay_box(a, b, frame_h + lift, float(spec.collision_half_m)))
		along_m += length
	for index in joints.size():
		var cell := _cell(cells, cell_size_m, joints[index])
		var metal: FURNITURE.Builder = cell.metal
		var normal := _post_normal(posts, index)
		var basis := Basis(Vector3.UP.cross(normal), Vector3.UP, normal)
		# A low stand across the line under each joint, and a clamp between frames.
		metal.box(joints[index] + Vector3(0, 0.035, 0), basis, Vector3(0.16, 0.07, 0.5), STAND_GREY, FURNITURE.CELL_WHITE)
		if index > 0 and index < joints.size() - 1:
			metal.box(joints[index] + Vector3(0, lift + 1.05, 0), basis, Vector3(0.16, 0.07, 0.07), GALVANIZED, FURNITURE.CELL_METAL)
	return boxes


## A repeatable number in [0, 1) for a seed and an index.
static func _unit_hash(seed: int, index: int) -> float:
	var value := (seed * 1103515245 + index * 12345 + 1013904223) & 0x7fffffff
	value = (value ^ (value >> 13)) * 1274126177 & 0x7fffffff
	return float(value % 10007) / 10007.0


# ---------------------------------------------------------------- wood

## A 6 ft board fence: square posts, two rails on the inside face, boards on the
## outside face and a cap board along the top.
func _wood_fence(cells: Dictionary, cell_size_m: float, posts: PackedVector3Array, side: float) -> Array[Dictionary]:
	var spec: Dictionary = TYPES.wood_privacy
	var height := float(spec.height_m)
	var outward := -side if side != 0.0 else 0.0
	var boxes: Array[Dictionary] = []
	var along_m := 0.0
	for index in posts.size():
		var cell := _cell(cells, cell_size_m, posts[index])
		var normal := _post_normal(posts, index)
		(cell.wood as Quads).block(posts[index] + Vector3(0, -0.3, 0), normal.cross(Vector3.UP), normal, Vector3(0.09, height + 0.35, 0.09), WOOD_TILE_M)
	for index in posts.size() - 1:
		var a := posts[index]
		var b := posts[index + 1]
		var length := Vector2(b.x - a.x, b.z - a.z).length()
		var cell := _cell(cells, cell_size_m, (a + b) * 0.5)
		var wood: Quads = cell.wood
		var normal := _left(_flat(b - a))
		var face := normal * outward * 0.055
		var back := -normal * outward * 0.065
		wood.skewed(a + face, b + face, 0.05, height, 0.02, normal, along_m, WOOD_TILE_M)
		for rail_y: float in [0.32, height - 0.32]:
			wood.skewed(a + back, b + back, rail_y - 0.045, rail_y + 0.045, 0.04, normal, along_m, WOOD_TILE_M)
		wood.skewed(a, b, height, height + 0.03, 0.14, normal, along_m, WOOD_TILE_M)
		boxes.append(_bay_box(a, b, height + 0.03, float(spec.collision_half_m)))
		along_m += length
	return boxes


# ---------------------------------------------------------------- quads

## Textured triangles tiled in metres, for fabric, screens and boards.
class Quads:
	extends RefCounted
	var _vertices := PackedVector3Array()
	var _normals := PackedVector3Array()
	var _uvs := PackedVector2Array()
	var _indices := PackedInt32Array()

	func is_empty() -> bool:
		return _indices.is_empty()

	func arrays() -> Array:
		var result := []
		result.resize(Mesh.ARRAY_MAX)
		result[Mesh.ARRAY_VERTEX] = _vertices
		result[Mesh.ARRAY_NORMAL] = _normals
		result[Mesh.ARRAY_TEX_UV] = _uvs
		result[Mesh.ARRAY_INDEX] = _indices
		return result

	## One quad, corners in order around it, front toward normal.
	func quad(corners: Array[Vector3], uvs: Array[Vector2], normal: Vector3) -> void:
		var base := _vertices.size()
		for index in 4:
			_vertices.append(corners[index])
			_normals.append(normal)
			_uvs.append(uvs[index])
		var winding := (corners[1] - corners[0]).cross(corners[2] - corners[0]).dot(normal)
		# Godot's front faces wind clockwise seen from the front.
		if winding > 0.0:
			_indices.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
		else:
			_indices.append_array(PackedInt32Array([base, base + 1, base + 2, base, base + 2, base + 3]))

	## A vertical sheet between two feet, from bottom to top above each foot,
	## tiled from along_m on along the fence (both faces: drawn double-sided).
	func wall(a: Vector3, b: Vector3, bottom: float, top: float, along_m: float, tile: Vector2) -> void:
		var length := Vector2(b.x - a.x, b.z - a.z).length()
		var normal := Vector3(b.z - a.z, 0.0, -(b.x - a.x)).normalized()
		var u0 := along_m / tile.x
		var u1 := (along_m + length) / tile.x
		quad([a + Vector3(0, bottom, 0), b + Vector3(0, bottom, 0), b + Vector3(0, top, 0), a + Vector3(0, top, 0)],
			[Vector2(u0, -bottom / tile.y), Vector2(u1, -bottom / tile.y), Vector2(u1, -top / tile.y), Vector2(u0, -top / tile.y)], normal)

	## A sloped strip from one edge (a, b) to that edge offset by rise_a, rise_b:
	## the barbed wire on the arms. The texture's height spans the strip.
	func ribbon(a: Vector3, b: Vector3, rise_a: Vector3, rise_b: Vector3, along_m: float, tile_m: float) -> void:
		var length := Vector2(b.x - a.x, b.z - a.z).length()
		var normal := (b - a).cross(rise_a).normalized()
		var u0 := along_m / tile_m
		var u1 := (along_m + length) / tile_m
		quad([a, b, b + rise_b, a + rise_a], [Vector2(u0, 1.0), Vector2(u1, 1.0), Vector2(u1, 0.0), Vector2(u0, 0.0)], normal)

	## A box standing on foot (its bottom centre), across along x and normal z.
	func block(foot: Vector3, across: Vector3, normal: Vector3, size: Vector3, tile_m: float) -> void:
		var x := across.normalized() * size.x * 0.5
		var z := normal.normalized() * size.z * 0.5
		var y := Vector3(0, size.y, 0)
		_hexahedron([foot - x - z, foot + x - z, foot + x + z, foot - x + z], y, tile_m)

	## A slab between two feet whose bottom follows each foot: height bottom..top
	## above them, thickness across the line, tiled from along_m on.
	func skewed(a: Vector3, b: Vector3, bottom: float, top: float, thickness: float, normal: Vector3, along_m: float, tile_m: float) -> void:
		var half := normal.normalized() * thickness * 0.5
		var length := Vector2(b.x - a.x, b.z - a.z).length()
		var lift := Vector3(0, bottom, 0)
		var rise := Vector3(0, top - bottom, 0)
		var corners_low: Array[Vector3] = [a + lift - half, b + lift - half, b + lift + half, a + lift + half]
		var corners_high: Array[Vector3] = []
		for corner in corners_low:
			corners_high.append(corner + rise)
		var u0 := along_m / tile_m
		var u1 := (along_m + length) / tile_m
		var v0 := -bottom / tile_m
		var v1 := -top / tile_m
		# Long faces carry the boards; ends, top and bottom take a strip of them.
		quad([corners_low[0], corners_low[1], corners_high[1], corners_high[0]], [Vector2(u0, v0), Vector2(u1, v0), Vector2(u1, v1), Vector2(u0, v1)], -normal.normalized())
		quad([corners_low[3], corners_low[2], corners_high[2], corners_high[3]], [Vector2(u0, v0), Vector2(u1, v0), Vector2(u1, v1), Vector2(u0, v1)], normal.normalized())
		quad([corners_high[0], corners_high[1], corners_high[2], corners_high[3]], [Vector2(u0, 0), Vector2(u1, 0), Vector2(u1, 0.05), Vector2(u0, 0.05)], Vector3.UP)
		quad([corners_low[0], corners_low[1], corners_low[2], corners_low[3]], [Vector2(u0, 0), Vector2(u1, 0), Vector2(u1, 0.05), Vector2(u0, 0.05)], Vector3.DOWN)
		var along := Vector3(b.x - a.x, 0, b.z - a.z).normalized()
		quad([corners_low[0], corners_low[3], corners_high[3], corners_high[0]], [Vector2(0, v0), Vector2(0.05, v0), Vector2(0.05, v1), Vector2(0, v1)], -along)
		quad([corners_low[1], corners_low[2], corners_high[2], corners_high[1]], [Vector2(0, v0), Vector2(0.05, v0), Vector2(0.05, v1), Vector2(0, v1)], along)

	func _hexahedron(base: Array[Vector3], rise: Vector3, tile_m: float) -> void:
		var top: Array[Vector3] = []
		for corner in base:
			top.append(corner + rise)
		var center := (base[0] + base[2]) * 0.5
		for index in 4:
			var next := (index + 1) % 4
			var width := base[index].distance_to(base[next])
			var outward := ((base[index] + base[next]) * 0.5 - center)
			outward.y = 0.0
			quad([base[index], base[next], top[next], top[index]], [Vector2(0, 0), Vector2(width / tile_m, 0), Vector2(width / tile_m, -rise.y / tile_m), Vector2(0, -rise.y / tile_m)], outward.normalized())
		quad(top, [Vector2(0, 0), Vector2(0.1, 0), Vector2(0.1, 0.1), Vector2(0, 0.1)], Vector3.UP)
