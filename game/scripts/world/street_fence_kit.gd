extends RefCounted
## The street-fence kit: procedural posts, rails, panels, fabric and collision for
## the fence rows of PlayableWorld/StreetDetail/Fences
## (tools/lib/street-fence-generation.mjs places them). One shared kit for every
## fence type: plain chain-link, chain-link with barbed wire (industrial),
## chain-link with a privacy windscreen and temporary chain-link panels
## (construction), a wood board fence (housing), and chain-link with privacy
## slats woven through it, with its gates standing open (storage yards).
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
##
## Each bay's own geometry (rails, fabric, screen, slats, boards, pickets or a
## panel's frame, not the posts and stands it shares) is a run of vertices in
## its cell's builders, which commit() keeps in order; add_run reports each
## bay's runs, so a car can break one bay of a merged cell mesh
## (game/scripts/vehicles/street_fence_breaker.gd), and bay_only builds a bay
## alone, as the debris it leaves. "breakable": false in a row's params keeps a
## fence whole (the Job Corps perimeter, owner 2026-11-08).

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
	"chain_link_slatted": {"height_m": 1.83, "half_thickness_m": 0.06, "collision_half_m": 0.06},
	"chain_link": {"height_m": 1.83, "half_thickness_m": 0.06, "collision_half_m": 0.06},
	"chain_link_barbed": {"height_m": 2.13, "half_thickness_m": 0.25, "collision_half_m": 0.06},
	"chain_link_screened": {"height_m": 1.83, "half_thickness_m": 0.06, "collision_half_m": 0.06},
	"construction_panel": {"height_m": 1.83, "half_thickness_m": 0.3, "collision_half_m": 0.22},
	"wood_privacy": {"height_m": 1.83, "half_thickness_m": 0.08, "collision_half_m": 0.08},
	"steel_picket": {"height_m": 1.37, "half_thickness_m": 0.05, "collision_half_m": 0.05},
}
const INSIDE := ["left", "right", "center"]
## Windscreen colours (sRGB, multiplied with the soft grey screen texture) and
## opacity: the photographed "black" screen reads as a smooth, neutral to
## slightly cool mid-dark grey on its sunlit and its shaded face alike (about
## 29/30/30 and 28/30/34 % in the Sep 2025 photos), with the site faintly
## visible through it. The knitted fabric is translucent, so sunlight through
## it lights the shaded face (SCREEN_BACKLIGHT, about half the sun in linear
## terms). The black tint leans blue because the island's sun and ambient light
## are warm. Orange is the safety mesh of construction sites (9th St, Sep 2025):
## a saturated safety orange, about as opaque as the windscreens. The grey
## windscreen texture would darken it to brick red, so it is drawn plain
## (SCREEN_PLAIN): its colour is its albedo.
const SCREENS := {"black": Color(0.32, 0.32, 0.43), "green": Color(0.34, 0.5, 0.4), "orange": Color(1.0, 0.45, 0.05)}
const SCREEN_OPACITY := {"black": 0.92, "green": 0.92, "orange": 0.92}
const SCREEN_PLAIN := ["orange"]
## A screen may stop below the fence top (screen_height_m), at least this tall.
const SCREEN_MIN_M := 0.6
## Privacy slat colours (sRGB, multiplied with the slat stripes), from the
## photos: dark teal-green (9th St, Sep 2025; Avenue M, Mar 2025), brown
## (12th St, Jul 2023), black.
const SLATS := {"green": Color(0.19, 0.3, 0.29), "brown": Color(0.3, 0.26, 0.21), "black": Color(0.08, 0.08, 0.085)}
## Slatted fences come 6 or 8 ft tall (tools/lib/street-fence-generation.mjs).
const SLATTED_HEIGHTS := [1.83, 2.44]
## A slat tile: eight slats across SLAT_TILE_M, one fabric height tall.
const SLAT_TILE_M := 0.4
## A gate leaf's collision half thickness (GATE_LEAF_HALF_M in
## tools/lib/street-fence-generation.mjs, which the clearance checks read), and
## how far its bottom rail stands over its post's foot (GATE_LEAF_LIFT_M, which
## the validator holds the ground under the leaf to).
const GATE_LEAF_HALF_M := 0.04
const GATE_LEAF_LIFT_M := 0.05
## Fence types that take open gate leaves, and banners (white sheets tied to
## the fabric: Gate 5, Nov 2025).
const GATED_TYPES := ["chain_link_slatted", "chain_link", "chain_link_screened"]
const BANNER_COLOR := Color(0.9, 0.9, 0.88)
## The printed banners (tools/lib/street-fence-generation.mjs STREET_FENCE_BANNER_ART_CELLS).
const BANNER_ART := preload("res://game/resources/textures/world/street/street_fence_banners.png")
const BANNER_BACK_UV := Vector2(0.52, 0.52)
const BANNER_ART_COLUMNS := 2
const BANNER_ART_ROWS := 4
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
## Black powder-coated steel pickets (the Mersea grounds, Sep 2025).
const PICKET_BLACK := Color(0.06, 0.062, 0.068)
## Pickets stand about this far apart (m).
const PICKET_SPACING_M := 0.125
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
var _slats: Dictionary = {}
var _banner: StandardMaterial3D
var _banner_art: StandardMaterial3D


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
		screen.albedo_texture = null if colour in SCREEN_PLAIN else SCREEN
		screen.albedo_color = Color(SCREENS[colour], float(SCREEN_OPACITY[colour]))
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
	# Privacy slats: opaque stripes, one slat per mesh column with a dark
	# seam between, a little uneven in tone (a texture made here, no file).
	var stripes := Image.create_empty(64, 16, false, Image.FORMAT_RGBA8)
	for x in 64:
		var slat := x / 8
		var tone := 0.86 + 0.14 * float((slat * 37 + 11) % 7) / 6.0
		for y in 16:
			var seam := x % 8 == 7
			var value := 0.32 if seam else tone * (0.97 + 0.03 * float((x * 13 + y * 7) % 5) / 4.0)
			stripes.set_pixel(x, y, Color(value, value, value))
	stripes.generate_mipmaps()
	var stripe_texture := ImageTexture.create_from_image(stripes)
	for colour: String in SLATS:
		var slat_material := StandardMaterial3D.new()
		slat_material.resource_name = "street_fence_slats_" + colour
		slat_material.albedo_texture = stripe_texture
		slat_material.albedo_color = SLATS[colour]
		slat_material.roughness = 0.82
		slat_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		slat_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		_slats[colour] = slat_material
	_banner = StandardMaterial3D.new()
	_banner.resource_name = "street_fence_banner"
	_banner.albedo_color = BANNER_COLOR
	_banner.roughness = 0.8
	_banner.cull_mode = BaseMaterial3D.CULL_DISABLED
	# The printed panels of the Mersea promenade's fence: an original atlas, its cells
	# in rows of BANNER_ART_COLUMNS; vinyl, a little glossier than a bedsheet.
	_banner_art = StandardMaterial3D.new()
	_banner_art.resource_name = "street_fence_banner_art"
	_banner_art.albedo_texture = BANNER_ART
	_banner_art.roughness = 0.62
	_banner_art.cull_mode = BaseMaterial3D.CULL_DISABLED
	_banner_art.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
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
	if (params as Dictionary).has("breakable") and not (params as Dictionary).breakable is bool:
		return "fence params breakable must be true or false"
	if type == "chain_link_screened":
		if str((params as Dictionary).get("screen", "black")) not in SCREENS:
			return "unknown screen colour %s" % (params as Dictionary).get("screen")
		var screen_height: Variant = (params as Dictionary).get("screen_height_m", TYPES.chain_link_screened.height_m)
		if not (screen_height is float or screen_height is int) or float(screen_height) < SCREEN_MIN_M or float(screen_height) > float(TYPES.chain_link_screened.height_m):
			return "screen_height_m must be %.1f..%.2f" % [SCREEN_MIN_M, TYPES.chain_link_screened.height_m]
	if type == "chain_link_slatted":
		if str((params as Dictionary).get("slats", "")) not in SLATS:
			return "slatted fence needs slats green, brown or black"
		var height: Variant = (params as Dictionary).get("height_m", 1.83)
		if not (height is float or height is int) or not SLATTED_HEIGHTS.any(func(value: float) -> bool: return is_equal_approx(value, float(height))):
			return "slatted fence height_m must be 1.83 or 2.44"
	return ""


## The top of a screened fence's windscreen above the ground: its
## screen_height_m, or just under the top rail.
static func screen_top_of(params: Variant) -> float:
	var full := float(TYPES.chain_link_screened.height_m) - 0.07
	if params is Dictionary and (params as Dictionary).has("screen_height_m"):
		return minf(full, float((params as Dictionary).screen_height_m))
	return full


## The height of a fence of this type with these params.
static func height_of(type: String, params: Variant) -> float:
	if type == "chain_link_slatted" and params is Dictionary and (params as Dictionary).has("height_m"):
		return float((params as Dictionary).height_m)
	return float(TYPES[type].height_m)


## Adds one run's geometry to the cell builders (cells: key -> builders, filled
## by cell_of) and returns its collision boxes as [{transform, size}] in world
## space. seed varies the panel jitter between runs.
## Each box also carries its bay's ends (a, b) and its geometry's vertex runs:
## ranges [[cell key, builder key, first vertex, end], ...]. bay_only leaves the
## posts and stands out (a bay built alone, as debris).
func add_run(cells: Dictionary, cell_size_m: float, type: String, params: Dictionary, posts: PackedVector3Array, seed: int, bay_only := false) -> Array[Dictionary]:
	var side := {"left": 1.0, "right": -1.0}.get(str(params.get("inside", "center")), 0.0) as float
	match type:
		"construction_panel":
			return _panels(cells, cell_size_m, posts, side, seed, bay_only)
		"wood_privacy":
			return _wood_fence(cells, cell_size_m, posts, side, bay_only)
		"steel_picket":
			return _picket_fence(cells, cell_size_m, posts, bay_only)
		"chain_link_slatted":
			return _slatted(cells, cell_size_m, posts, side, str(params.get("slats", "green")), height_of(type, params), bay_only)
		_:
			return _chain_link(cells, cell_size_m, type, posts, side, str(params.get("screen", "black")), screen_top_of(params), bay_only)


## The vertex counts of a cell's builders now.
static func _marks(cell: Dictionary) -> Dictionary:
	var marks := {}
	for key: String in cell:
		var builder: Variant = cell[key]
		marks[key] = (builder as FURNITURE.Builder).vertex_count(0) if builder is FURNITURE.Builder else (builder as Quads).size()
	return marks


## A bay's box with its ends and the vertex runs its geometry added to the cell
## since `before` (see add_run).
static func _bay(box: Dictionary, a: Vector3, b: Vector3, cell_key: String, cell: Dictionary, before: Dictionary) -> Dictionary:
	var ranges: Array = []
	var after := _marks(cell)
	for key: String in after:
		if int(after[key]) > int(before.get(key, 0)):
			ranges.append([cell_key, key, int(before.get(key, 0)), int(after[key])])
	box["a"] = a
	box["b"] = b
	box["ranges"] = ranges
	return box


## The meshes of one cell's builders: "solid" (metal and boards, drawn with
## shadows), "fabric" (chain-link, barbed wire and screens, blended, no shadows)
## and "shadow" (a cut-out copy of the wire and an opaque copy of the screens
## that only cast shadows). A mesh is null when it would hold nothing.
## surfaces maps each builder key to where its vertices landed:
## [[mesh ("solid", "fabric" or "shadow"), surface index], ...].
func commit(cell: Dictionary) -> Dictionary:
	var solid: ArrayMesh = (cell.metal as FURNITURE.Builder).commit(_metal, _metal)
	var surfaces := {}
	# The fences' metal is all on the builder's first (opaque) surface.
	if solid.get_surface_count() > 0:
		surfaces["metal"] = [["solid", 0]]
	var fabric := ArrayMesh.new()
	var shadow := ArrayMesh.new()
	_add_surface(solid, cell.wood, _wood, "solid", "wood", surfaces)
	_add_surface(fabric, cell.chain, _chain, "fabric", "chain", surfaces)
	_add_surface(fabric, cell.barbed, _barbed, "fabric", "barbed", surfaces)
	_add_surface(shadow, cell.chain, _chain_shadow, "shadow", "chain", surfaces)
	_add_surface(shadow, cell.barbed, _barbed_shadow, "shadow", "barbed", surfaces)
	for colour: String in SCREENS:
		_add_surface(fabric, cell["screen_" + colour], _screens[colour], "fabric", "screen_" + colour, surfaces)
		_add_surface(shadow, cell["screen_" + colour], _screen_shadow, "shadow", "screen_" + colour, surfaces)
	for colour: String in SLATS:
		_add_surface(solid, cell["slats_" + colour], _slats[colour], "solid", "slats_" + colour, surfaces)
	_add_surface(solid, cell.banner, _banner, "solid", "banner", surfaces)
	_add_surface(solid, cell.banner_art, _banner_art, "solid", "banner_art", surfaces)
	return {
		"solid": solid if solid.get_surface_count() > 0 else null,
		"fabric": fabric if fabric.get_surface_count() > 0 else null,
		"shadow": shadow if shadow.get_surface_count() > 0 else null,
		"surfaces": surfaces,
	}


func _add_surface(mesh: ArrayMesh, quads: Quads, material: Material, part := "", key := "", surfaces: Dictionary = {}) -> void:
	if quads.is_empty():
		return
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, quads.arrays())
	mesh.surface_set_material(mesh.get_surface_count() - 1, material)
	if key != "":
		if not surfaces.has(key):
			surfaces[key] = []
		(surfaces[key] as Array).append([part, mesh.get_surface_count() - 1])


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
			"screen_orange": Quads.new(),
			"slats_green": Quads.new(),
			"slats_brown": Quads.new(),
			"slats_black": Quads.new(),
			"banner": Quads.new(),
			"banner_art": Quads.new(),
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
func _chain_link(cells: Dictionary, cell_size_m: float, type: String, posts: PackedVector3Array, side: float, screen: String, screen_top: float, bay_only := false) -> Array[Dictionary]:
	var spec: Dictionary = TYPES[type]
	var fabric_h := 1.83
	var boxes: Array[Dictionary] = []
	var along_m := 0.0
	for index in 0 if bay_only else posts.size():
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
		var before := _marks(cell)
		var metal: FURNITURE.Builder = cell.metal
		var normal := _left(_flat(b - a))
		metal.tube(PackedVector3Array([a + Vector3(0, fabric_h - 0.02, 0), b + Vector3(0, fabric_h - 0.02, 0)]), PackedFloat32Array([0.021, 0.021]), 8, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		metal.tube(PackedVector3Array([a + Vector3(0, 0.07, 0), b + Vector3(0, 0.07, 0)]), PackedFloat32Array([0.004, 0.004]), 4, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		# Fabric just inside the posts (or through them on a centred fence). Behind
		# a windscreen the wire is barely visible, so the screen stands for both;
		# above a screen lower than the fence the wire shows.
		var shift := normal * side * 0.035
		var wire_from := 0.05
		if type == "chain_link_screened":
			var screen_shift := normal * (side if side != 0.0 else 1.0) * 0.055
			(cell["screen_" + screen] as Quads).wall(a + screen_shift, b + screen_shift, 0.03, screen_top, along_m, Vector2(SCREEN_TILE_M, SCREEN_TILE_M))
			wire_from = screen_top
		if wire_from < fabric_h - 0.1:
			(cell.chain as Quads).wall(a + shift, b + shift, wire_from, fabric_h - 0.04, along_m, CHAIN_TILE)
		if type == "chain_link_barbed":
			var out_a := _post_normal(posts, index) * (-side if side != 0.0 else 1.0)
			var out_b := _post_normal(posts, index + 1) * (-side if side != 0.0 else 1.0)
			var lift := Vector3(0, fabric_h + 0.06, 0)
			var rise := 0.3
			(cell.barbed as Quads).ribbon(a + lift, b + lift, (Vector3.UP + out_a).normalized() * rise / 0.7071, (Vector3.UP + out_b).normalized() * rise / 0.7071, along_m, BARBED_TILE_M)
		boxes.append(_bay(_bay_box(a, b, float(spec.height_m), float(spec.collision_half_m)), a, b, cell_key(middle, cell_size_m), cell, before))
		along_m += length
	return boxes


## The horizontal normal at a post: the left of the run, averaged at a corner.
static func _post_normal(posts: PackedVector3Array, index: int) -> Vector3:
	var before := _flat(posts[index] - posts[index - 1]) if index > 0 else Vector3.ZERO
	var after := _flat(posts[index + 1] - posts[index]) if index < posts.size() - 1 else Vector3.ZERO
	var direction := (before + after).normalized() if (before + after).length() > 0.001 else (after if after != Vector3.ZERO else before)
	return _left(direction)


# ---------------------------------------------------------------- slatted

## Chain-link with privacy slats: line posts with a top rail and a bottom
## tension wire, the slats woven through the fabric (an opaque striped sheet in
## the fabric's plane) and the wire over them on the outside.
func _slatted(cells: Dictionary, cell_size_m: float, posts: PackedVector3Array, side: float, slats: String, height: float, bay_only := false) -> Array[Dictionary]:
	var boxes: Array[Dictionary] = []
	var along_m := 0.0
	for index in 0 if bay_only else posts.size():
		var metal: FURNITURE.Builder = _cell(cells, cell_size_m, posts[index]).metal
		var terminal := _terminal(posts, index)
		var radius := 0.03 if terminal else 0.024
		var top := height + (0.06 if terminal else 0.03)
		var foot := posts[index]
		metal.tube(PackedVector3Array([foot + Vector3(0, -0.3, 0), foot + Vector3(0, top, 0)]), PackedFloat32Array([radius, radius]), 8, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		metal.tube(PackedVector3Array([foot + Vector3(0, top, 0), foot + Vector3(0, top + 0.04, 0)]), PackedFloat32Array([radius + 0.007, radius + 0.004]), 8, GALVANIZED, FURNITURE.CELL_METAL, false, true)
	for index in posts.size() - 1:
		var a := posts[index]
		var b := posts[index + 1]
		var length := Vector2(b.x - a.x, b.z - a.z).length()
		var cell := _cell(cells, cell_size_m, (a + b) * 0.5)
		var before := _marks(cell)
		var metal: FURNITURE.Builder = cell.metal
		var normal := _left(_flat(b - a))
		metal.tube(PackedVector3Array([a + Vector3(0, height - 0.02, 0), b + Vector3(0, height - 0.02, 0)]), PackedFloat32Array([0.021, 0.021]), 8, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		metal.tube(PackedVector3Array([a + Vector3(0, 0.07, 0), b + Vector3(0, 0.07, 0)]), PackedFloat32Array([0.004, 0.004]), 4, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		var shift := normal * side * 0.035
		(cell["slats_" + slats] as Quads).wall(a + shift, b + shift, 0.05, height - 0.04, along_m, Vector2(SLAT_TILE_M, height))
		# The wire on the outside of the slats (outward: away from the inside).
		var wire := normal * (side * 0.035 - (side if side != 0.0 else 1.0) * 0.012)
		(cell.chain as Quads).wall(a + wire, b + wire, 0.05, height - 0.04, along_m, CHAIN_TILE)
		boxes.append(_bay(_bay_box(a, b, height, float(TYPES.chain_link_slatted.collision_half_m)), a, b, cell_key((a + b) * 0.5, cell_size_m), cell, before))
		along_m += length
	return boxes


## An open gate between the solid runs either side of it (a slatted, plain or
## screened chain-link fence): two stout gate posts, and its open leaves as the
## generator lays them out (tools/lib/street-fence-generation.mjs gateLeaves:
## swung square to the fence on its inside, or a sliding leaf parked along it),
## each [{xz: [[hinge x, z], [far x, z]], post}] hanging at its post's height.
## A leaf is filled like its fence: slats and wire, wire, or wire and
## windscreen. Returns the leaves' collision boxes; the opening stays clear.
func add_gate(cells: Dictionary, cell_size_m: float, type: String, params: Dictionary, ends: PackedVector3Array, leaves: Array) -> Array[Dictionary]:
	var boxes: Array[Dictionary] = []
	if ends.size() != 2 or type not in GATED_TYPES:
		return boxes
	var height := height_of(type, params)
	var slats := str(params.get("slats", "green"))
	var screen := str(params.get("screen", "black"))
	for foot: Vector3 in [ends[0], ends[1]]:
		var metal: FURNITURE.Builder = _cell(cells, cell_size_m, foot).metal
		metal.tube(PackedVector3Array([foot + Vector3(0, -0.3, 0), foot + Vector3(0, height + 0.12, 0)]), PackedFloat32Array([0.045, 0.045]), 8, GALVANIZED, FURNITURE.CELL_METAL, false, true)
	for leaf_value: Variant in leaves:
		if not leaf_value is Dictionary:
			continue
		var leaf := leaf_value as Dictionary
		var xz: Array = leaf.get("xz", [])
		if xz.size() != 2:
			continue
		var y := ends[clampi(int(leaf.get("post", 0)), 0, 1)].y
		var hinge := Vector3(float(xz[0][0]), y, float(xz[0][1]))
		var far := Vector3(float(xz[1][0]), y, float(xz[1][1]))
		var direction := _flat(far - hinge)
		var cell := _cell(cells, cell_size_m, (hinge + far) * 0.5)
		var before := _marks(cell)
		var metal: FURNITURE.Builder = cell.metal
		var lift := Vector3(0, GATE_LEAF_LIFT_M, 0)
		var frame := PackedVector3Array([hinge + lift, hinge + lift + Vector3(0, height - 0.08, 0), far + lift + Vector3(0, height - 0.08, 0), far + lift, hinge + lift])
		metal.tube(frame, PackedFloat32Array([0.022, 0.022, 0.022, 0.022, 0.022]), 6, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		metal.tube(PackedVector3Array([hinge + lift + Vector3(0, (height - 0.08) * 0.5, 0), far + lift + Vector3(0, (height - 0.08) * 0.5, 0)]), PackedFloat32Array([0.018, 0.018]), 6, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		match type:
			"chain_link_slatted":
				(cell["slats_" + slats] as Quads).wall(hinge + lift, far + lift, 0.03, height - 0.1, 0.0, Vector2(SLAT_TILE_M, height))
				(cell.chain as Quads).wall(hinge + lift + _left(direction) * 0.012, far + lift + _left(direction) * 0.012, 0.03, height - 0.1, 0.0, CHAIN_TILE)
			"chain_link_screened":
				var screen_top := minf(screen_top_of(params), height - 0.1)
				(cell["screen_" + screen] as Quads).wall(hinge + lift, far + lift, 0.03, screen_top, 0.0, Vector2(SCREEN_TILE_M, SCREEN_TILE_M))
				if screen_top < height - 0.2:
					(cell.chain as Quads).wall(hinge + lift, far + lift, screen_top, height - 0.1, 0.0, CHAIN_TILE)
			_:
				(cell.chain as Quads).wall(hinge + lift, far + lift, 0.03, height - 0.1, 0.0, CHAIN_TILE)
		boxes.append(_bay(_bay_box(hinge, far, height, GATE_LEAF_HALF_M), hinge, far, cell_key((hinge + far) * 0.5, cell_size_m), cell, before))
	return boxes


## A banner tied to a chain-link fence between two grounded ends: a plain white
## sheet height_m tall, centred on the fence's height, on its outer face (the
## side away from the inside; a centred fence's left).
func add_banner(cells: Dictionary, cell_size_m: float, type: String, params: Dictionary, ends: PackedVector3Array, height_m: float, art := -1) -> void:
	if ends.size() != 2 or type not in GATED_TYPES:
		return
	var fence_h := height_of(type, params)
	var side := {"left": 1.0, "right": -1.0}.get(str(params.get("inside", "center")), 0.0) as float
	var outward := _left(_flat(ends[1] - ends[0])) * (-side if side != 0.0 else 1.0)
	var shift := outward * 0.045
	var bottom := maxf(0.1, (fence_h - height_m) * 0.5)
	var cell := _cell(cells, cell_size_m, (ends[0] + ends[1]) * 0.5)
	if art < 0:
		(cell.banner as Quads).wall(ends[0] + shift, ends[1] + shift, bottom, bottom + height_m, 0.0, Vector2(1.0, 1.0))
		return
	# A printed panel reads from the path side: its art runs left to right there.
	var a := ends[0] + shift
	var b := ends[1] + shift
	var u0 := float(art % BANNER_ART_COLUMNS) / float(BANNER_ART_COLUMNS)
	var u1 := u0 + 1.0 / float(BANNER_ART_COLUMNS)
	var v0 := float(art / BANNER_ART_COLUMNS) / float(BANNER_ART_ROWS)
	var v1 := v0 + 1.0 / float(BANNER_ART_ROWS)
	var normal := Vector3(b.z - a.z, 0.0, -(b.x - a.x)).normalized()
	var up := Vector3.UP
	(cell.banner_art as Quads).quad([a + up * bottom, b + up * bottom, b + up * (bottom + height_m), a + up * (bottom + height_m)],
		[Vector2(u1, v1), Vector2(u0, v1), Vector2(u0, v0), Vector2(u1, v0)], normal)
	# Its back is bare pale vinyl: a corner of the plain parchment cell, held a little behind.
	var back := -outward * 0.02
	var plain := BANNER_BACK_UV
	(cell.banner_art as Quads).quad([b + back + up * bottom, a + back + up * bottom, a + back + up * (bottom + height_m), b + back + up * (bottom + height_m)],
		[plain, plain, plain, plain], -normal)


# ---------------------------------------------------------------- panels

## Temporary chain-link panels: a tube frame with chain-link infill between each
## pair of joints, the frames side by side at a joint with a clamp, standing on a
## low stand; the joints lean in and out a little, as hand-set panels do.
func _panels(cells: Dictionary, cell_size_m: float, posts: PackedVector3Array, side: float, seed: int, bay_only := false) -> Array[Dictionary]:
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
		var before := _marks(cell)
		var metal: FURNITURE.Builder = cell.metal
		var inset := minf(0.045, length * 0.1)
		var left_foot := a + along * inset + Vector3(0, lift, 0)
		var right_foot := b - along * inset + Vector3(0, lift, 0)
		var up := Vector3(0, frame_h, 0)
		var frame := PackedVector3Array([left_foot, left_foot + up, right_foot + up, right_foot, left_foot])
		metal.tube(frame, PackedFloat32Array([0.019, 0.019, 0.019, 0.019, 0.019]), 6, GALVANIZED, FURNITURE.CELL_METAL, false, false)
		(cell.chain as Quads).wall(left_foot - Vector3(0, lift, 0), right_foot - Vector3(0, lift, 0), lift + 0.03, lift + frame_h - 0.03, along_m, CHAIN_TILE)
		boxes.append(_bay(_bay_box(a, b, frame_h + lift, float(spec.collision_half_m)), a, b, cell_key((a + b) * 0.5, cell_size_m), cell, before))
		along_m += length
	for index in 0 if bay_only else joints.size():
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
func _wood_fence(cells: Dictionary, cell_size_m: float, posts: PackedVector3Array, side: float, bay_only := false) -> Array[Dictionary]:
	var spec: Dictionary = TYPES.wood_privacy
	var height := float(spec.height_m)
	var outward := -side if side != 0.0 else 0.0
	var boxes: Array[Dictionary] = []
	var along_m := 0.0
	for index in 0 if bay_only else posts.size():
		var cell := _cell(cells, cell_size_m, posts[index])
		var normal := _post_normal(posts, index)
		(cell.wood as Quads).block(posts[index] + Vector3(0, -0.3, 0), normal.cross(Vector3.UP), normal, Vector3(0.09, height + 0.35, 0.09), WOOD_TILE_M)
	for index in posts.size() - 1:
		var a := posts[index]
		var b := posts[index + 1]
		var length := Vector2(b.x - a.x, b.z - a.z).length()
		var cell := _cell(cells, cell_size_m, (a + b) * 0.5)
		var before := _marks(cell)
		var wood: Quads = cell.wood
		var normal := _left(_flat(b - a))
		var face := normal * outward * 0.055
		var back := -normal * outward * 0.065
		wood.skewed(a + face, b + face, 0.05, height, 0.02, normal, along_m, WOOD_TILE_M)
		for rail_y: float in [0.32, height - 0.32]:
			wood.skewed(a + back, b + back, rail_y - 0.045, rail_y + 0.045, 0.04, normal, along_m, WOOD_TILE_M)
		wood.skewed(a, b, height, height + 0.03, 0.14, normal, along_m, WOOD_TILE_M)
		boxes.append(_bay(_bay_box(a, b, height + 0.03, float(spec.collision_half_m)), a, b, cell_key((a + b) * 0.5, cell_size_m), cell, before))
		along_m += length
	return boxes


# ---------------------------------------------------------------- picket

## A black steel picket fence (the Mersea grounds beside its lot, Sep 2025):
## square posts with ball caps on 8 ft bays, a bottom and a top rail, and square
## pickets about 12 cm apart rising past the top rail to points. The pickets
## follow the ground between the posts.
func _picket_fence(cells: Dictionary, cell_size_m: float, posts: PackedVector3Array, bay_only := false) -> Array[Dictionary]:
	var spec: Dictionary = TYPES.steel_picket
	var height := float(spec.height_m)
	var boxes: Array[Dictionary] = []
	for index in 0 if bay_only else posts.size():
		var metal: FURNITURE.Builder = _cell(cells, cell_size_m, posts[index]).metal
		var foot := posts[index]
		metal.tube(PackedVector3Array([foot + Vector3(0, -0.3, 0), foot + Vector3(0, height + 0.04, 0)]), PackedFloat32Array([0.04, 0.04]), 4, PICKET_BLACK, FURNITURE.CELL_METAL, false, true)
		# A square cap plate, a neck and a ball finial (the Mersea lot's posts, Sep 2025).
		var finial := PackedVector3Array()
		var finial_radii := PackedFloat32Array()
		for profile: Vector2 in [Vector2(0.04, 0.055), Vector2(0.06, 0.055), Vector2(0.07, 0.022), Vector2(0.09, 0.04), Vector2(0.115, 0.05), Vector2(0.14, 0.04), Vector2(0.16, 0.0)]:
			finial.append(foot + Vector3(0, height + profile.x, 0))
			finial_radii.append(profile.y)
		metal.tube(finial, finial_radii, 8, PICKET_BLACK, FURNITURE.CELL_METAL, false, true)
	for index in posts.size() - 1:
		var a := posts[index]
		var b := posts[index + 1]
		var length := Vector2(b.x - a.x, b.z - a.z).length()
		var cell := _cell(cells, cell_size_m, (a + b) * 0.5)
		var before := _marks(cell)
		var metal: FURNITURE.Builder = cell.metal
		for rail_y: float in [0.14, height - 0.12]:
			metal.tube(PackedVector3Array([a + Vector3(0, rail_y, 0), b + Vector3(0, rail_y, 0)]), PackedFloat32Array([0.018, 0.018]), 4, PICKET_BLACK, FURNITURE.CELL_METAL, false, false)
		var count := maxi(1, roundi(length / PICKET_SPACING_M))
		for step in range(1, count):
			var foot := a.lerp(b, float(step) / float(count))
			metal.tube(PackedVector3Array([foot + Vector3(0, 0.06, 0), foot + Vector3(0, height - 0.03, 0)]), PackedFloat32Array([0.011, 0.011]), 4, PICKET_BLACK, FURNITURE.CELL_METAL, false, false)
			metal.tube(PackedVector3Array([foot + Vector3(0, height - 0.03, 0), foot + Vector3(0, height + 0.05, 0)]), PackedFloat32Array([0.014, 0.0]), 4, PICKET_BLACK, FURNITURE.CELL_METAL, false, true)
		boxes.append(_bay(_bay_box(a, b, height + 0.05, float(spec.collision_half_m)), a, b, cell_key((a + b) * 0.5, cell_size_m), cell, before))
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

	func size() -> int:
		return _vertices.size()

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
