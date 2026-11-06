extends RefCounted
## Island ground cover: which shared ground-cover family each generated land or
## area record uses, and that family's material. Families only change how the
## shared shader mixes maintained lawn, dry grass and bare soil (a late-spring
## look read from dated Mar/Sep 2025 street views and undated overheads,
## retuned on 2026-11-05 against the 2026-05-26 aerial). Every family also reads
## the world ground-cover map (tools/lib/ground-cover-map.mjs, rules in
## tools/config/ground-cover.json), which draws the lawn, straw, dry-field and
## bare recipes over a record's own mix where its rules place them: the
## residential lawns along the streets and round the buildings, the Job Corps
## dorm and YMCA lawns, the drier industrial core, the Avenue N verge. Mesh
## arrays, collision and every other record keep the builder's handling.

const SHADER := preload("res://game/resources/materials/world/ground_cover/ground_cover.gdshader")
const DETAIL_ALBEDO := preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_diff_1k.jpg")
const DETAIL_NORMAL := preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_nor_gl_1k.jpg")
const DETAIL_ROUGHNESS := preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_rough_1k.jpg")
## The ground-cover map (tools/build_ground_cover_map.mjs) and the world
## rectangle it covers: tools/config/ground-cover.json's map origin and size.
const COVER_MAP := preload("res://game/resources/textures/world/ground_cover/cover_map.png")
const COVER_MAP_ORIGIN := Vector2(-720.0, -960.0)
const COVER_MAP_SIZE_M := Vector2(1440.0, 1920.0)
## The family each map channel draws, as the shader's recipe uniforms (RGBA order).
const COVER_MAP_RECIPES := {"recipe_lawn": "lawn", "recipe_straw": "straw", "recipe_dry_field": "dry_field", "recipe_bare": "bare"}

## Hard courts and the skate park use the builder's light concrete court
## material (parking lots are asphalt).
const PAVED := "paved"

## Shader mix per family. Thresholds are levels of the shader's patch and bare
## noises (both median 0.5, with about 27 % above 0.6, 10 % above 0.7 and 2.5 %
## above 0.8): green lawn turns dry where the patch level passes dry_threshold,
## bare soil shows where the bare level passes bare_threshold (above 1 none;
## the lower it is, the paler the soil, from field dirt to graded fill), and
## green_dryness pulls the remaining green toward olive. Shares (green / dry /
## bare) are of the drawn ground.
const FAMILIES := {
	# Maintained lawn, about 90 / 10 / 0: the parks' and the commons' lawns
	# and, drawn by the map, the residential and Job Corps lawns.
	"lawn": {"dry_threshold": 0.71, "bare_threshold": 2.0, "green_dryness": 0.0, "patch_scale_m": 18.0, "bare_scale_m": 23.0},
	# Irrigated turf lawn, about 98 / 2 / 0: the ferry plaza and Cityside Park
	# lawns, green in the Sep 2025 photos (24, 25) and both dated aerials.
	"park_lawn": {"dry_threshold": 0.80, "bare_threshold": 2.0, "green_dryness": 0.0, "patch_scale_m": 18.0, "bare_scale_m": 23.0},
	# Irrigated ball fields, about 80 / 20 / 0: the Little League fields and the
	# baseball pitch (green in both dated aerials).
	"sports": {"dry_threshold": 0.64, "bare_threshold": 2.0, "green_dryness": 0.1, "patch_scale_m": 28.0, "bare_scale_m": 23.0},
	# GAA Field A: a watered pitch, green with dry patches between its
	# sprinkler heads, 18 m apart on the pitch's axes (2026-05-26 aerial).
	"watered_pitch": {"dry_threshold": 0.6, "bare_threshold": 2.0, "green_dryness": 0.1, "patch_scale_m": 28.0, "bare_scale_m": 23.0, "grid_m": 18.0, "grid_angle": -0.4887, "grid_amount": 0.5},
	# The synthetic-turf soccer pitch on w1252737754 (2026-05-26 aerial: an
	# even dark green field with line markings).
	"turf": {"dry_threshold": 2.0, "bare_threshold": 2.0, "green_dryness": 0.0, "patch_scale_m": 28.0, "bare_scale_m": 23.0, "turf_amount": 1.0},
	# Open land, about 21 / 68 / 12: the default for land and OSM areas, under
	# the map. The 2026-05-26 aerial shows the island's unbuilt land as dry
	# grass, its bare ground mostly whole graded lots and yards (open ground
	# 2-6 % green, 20-45 % dry and 50-75 % pale in most 200 m boxes, the pale
	# share counting gravel and concrete yards); in the fields themselves bare
	# dirt shows in a few patches and along tracks, which these patches stand
	# for (2026-11-05 visual review: evenly spread pale blobs read as desert
	# camouflage from above).
	"field": {"dry_threshold": 0.378, "bare_threshold": 0.69, "green_dryness": 0.35, "patch_scale_m": 32.0, "bare_scale_m": 21.0}, "marsh_amount": 1.0}
	# Dry straw grass, about 11 / 89 / 0: the residential grounds and the
	# Avenue N verge (map), the Job Corps campus, GAA Field B, the old Job
	# Corps ballfield and the dry Avenue D medians. The aerial shows only a
	# handful of dirt patches in the residential grounds.
	"straw": {"dry_threshold": 0.30, "bare_threshold": 0.90, "green_dryness": 0.6, "patch_scale_m": 32.0, "bare_scale_m": 21.0},
	# Rough grass, about 44 / 53 / 3: the west shore parcel, olive to brown.
	"rough_grass": {"dry_threshold": 0.48, "bare_threshold": 0.80, "green_dryness": 0.3, "patch_scale_m": 32.0, "bare_scale_m": 21.0},
	# Dry grass and bare dirt, about 9 / 73 / 18: the Cultural Park, the
	# Marina Plaza grounds round Building 1 and Clipper Cove.
	"dry_meadow": {"dry_threshold": 0.30, "bare_threshold": 0.65, "green_dryness": 0.4, "patch_scale_m": 32.0, "bare_scale_m": 21.0},
	# Dry grass with more bare dirt, about 8 / 72 / 20: the industrial core's
	# land (map) and the Avenue N construction parcel w1252737734.
	"dry_field": {"dry_threshold": 0.29, "bare_threshold": 0.635, "green_dryness": 0.5, "patch_scale_m": 32.0, "bare_scale_m": 21.0},
	"bare": {"dry_threshold": -1.0, "bare_threshold": 0.345, "green_dryness": 0.0, "patch_scale_m": 20.0, "bare_scale_m": 15.0},
	# The seasonal marsh (natural=wetland) east of the Mersea lot. The shader draws
	# its floor and banks from the land's height (marsh_amount), on this family and
	# on the field round it alike.
	"red_marsh": {"dry_threshold": 2.0, "bare_threshold": 2.0, "green_dryness": 0.5, "patch_scale_m": 24.0, "bare_scale_m": 14.0, "marsh_amount": 1.0},
	# The old sand courts (natural=sand) in the residential north: pale bare
	# ground grown over with dry weeds, about 0 / 60 / 40 (2026-05-26 aerial:
	# 78 % dry, 16 % bare of their open ground).
	"sand_pad": {"dry_threshold": -1.0, "bare_threshold": 0.543, "green_dryness": 0.5, "patch_scale_m": 12.0, "bare_scale_m": 9.0},
	# The shoreline verge at the top of the riprap (ShorelineBuilder): the field
	# grown drier and dirtier, with dirt in small patches, so it meets the field
	# without a hard change of tone.
	"verge": {"dry_threshold": 0.25, "bare_threshold": 0.55, "green_dryness": 0.5, "patch_scale_m": 16.0, "bare_scale_m": 7.0},
}

## Family per generated material key. Parking, roads, buildings, the shore
## overlays (breakwater, riprap, pier, the marina yard) and the Yerba Buena
## context keep their existing materials.
const FAMILY_BY_MATERIAL_KEY := {
	"land_ground": "field",
	# Back slopes of the raised street ground and planted kerb verges match the
	# land (planting strips are mulch); the map gives them the weights of the
	# ground beside them.
	"street_kerb_verge": "field",
	# Of the landuse areas only the residential relation r17241151 keeps this
	# (the map draws its lawns and straw); the construction parcels, the yard
	# and the landuse=grass strips are routed by source below.
	"major_area_landuse": "field",
	"major_area_leisure": "lawn",
	# The SFFD training facility w1043836449 (Job Corps has its own family below).
	"major_area_amenity": "field",
	# A park zone's lawn (tools/lib/street-ground-generation.mjs park surfaces).
	"park_lawn": "park_lawn",
	# Terrain overlays on the land: the old sand courts and the marsh east of the
	# Mersea lot.
	"terrain_sand": "sand_pad",
	"terrain_wetland": "red_marsh",
}

## Frozen 2026-08-27 OSM areas whose tags the generated material keys merge.
const FAMILY_BY_SOURCE := {
	"w775820810": "bare", # landuse=construction: redevelopment parcel, overheads show bare fill soil
	"w775820811": "bare", # landuse=construction: same
	"w899364786": "bare", # landuse=construction: same
	"w899364787": "bare", # landuse=construction: same
	"w1252737732": "bare", # landuse=construction: same
	"r17241152": "rough_grass", # landuse=construction: the west shore parcel is rough grass and trees (2026-05-26 aerial: 77 % dry, 21 % green)
	"w1252737734": "dry_field", # landuse=construction: dry grass and bare ground (2026-05-26 aerial: 44 % dry, 42 % bare)
	"w1252737750": "straw", # amenity=college, Job Corps: dry grass (2026-05-26 aerial: 71-90 % dry, 8-23 % bare, 2-7 % lawn of the open ground); its dorm lawns are drawn by the map
	"w1252737754": "turf", # landuse=construction: a finished synthetic-turf soccer pitch (2026-05-26 aerial: even dark green with white lines; Street View Sep 2025 at 749 9th St: goals and floodlights behind the windscreen); its apron is drawn bare by the map
	"w269856850": "bare", # landuse=industrial: yard, overheads show gravel and bare ground
	"w545387428": "bare", # leisure=pitch sport=boules: gravel court
	"w28356842": PAVED, # leisure=pitch sport=basketball: hard court
	"w96665888": PAVED, # leisure=pitch sport=basketball: hard court
	"w96665934": PAVED, # leisure=pitch sport=basketball: hard court
	"w1163035324": PAVED, # leisure=pitch sport=basketball: hard court
	"w1307988013": PAVED, # leisure=pitch sport=basketball: hard court
	"w1102656842": PAVED, # leisure=pitch sport=tennis: hard court
	"w1061513876": PAVED, # leisure=pitch sport=skateboard surface=concrete: skate park
	"w99060807": "watered_pitch", # leisure=pitch, GAA Field A: green with dry sprinkler-grid patches (2026-05-26 aerial)
	"w99060801": "straw", # leisure=pitch, GAA Field B: dry tan (2026-05-26 aerial: 97 % dry)
	"w133809962": "sports", # leisure=pitch sport=baseball: natural grass field
	"w133809964": "straw", # leisure=pitch sport=baseball: the old Job Corps ballfield, dry grass (2026-05-26 aerial: 90 % dry)
	"w28353177": "sports", # leisure=sports_centre sport=baseball, Tepper Little League Field #1
	"w109022547": "sports", # leisure=sports_centre, Ketcham Little League Field #2
	"w1428380754": "park_lawn", # leisure=park, Waterfront Plaza: the ferry plaza's green lawns
	"w1428380762": "dry_meadow", # leisure=park, Cultural Park: dry grass and bare ground (2026-05-26 aerial: 67 % dry, 20 % bare)
	"w1428380764": "dry_meadow", # leisure=park, Clipper Cove: dry verges by the marina (2026-05-26 aerial: 34 % dry, 10 % bare, 2 % lawn)
	"r19585233": "dry_meadow", # leisure=park, Marina Plaza round Building 1: dry grass (Sep 2025 photo at 17 Treasure Island Rd); its east field is drawn bare by the map
	# The landuse=grass strips: medians and verges along Avenue D (x -140..80,
	# z -35..372), beside the storage yard (x -200..-88, z -153..-54) and by the
	# south-west park (x -444..-358, z 59..124). 2026-05-26 aerial (May 2026 z19
	# tiles), share of each strip's open ground: most are dry straw with trees
	# and shrubs; two near the middle of Avenue D hold green grass.
	"w1098437822": "straw", # 91 % dry, 9 % bare
	"w1098437829": "straw", # 66 % dry, 34 % bare (half the strip shaded by the yard fence)
	"w1098437839": "straw", # 72 % dry, 28 % bare
	"w1098437845": "straw", # 36 % dry, 34 % green, 30 % bare under its palms (canopy 34 % of the strip)
	"w1098437846": "straw", # 60 % dry, 16 % green, 24 % bare under its palms (canopy 37 %)
	"w1098437861": "straw", # 94 % dry
	"w1098437862": "straw", # 88 % dry, 12 % bare
	"w1098437863": "straw", # 86 % dry under a tree
	"w1098437864": "straw", # 70 % dry, 30 % bare
	"w1098437865": "straw", # 85 % dry, 15 % bare
	"w1098437866": "straw", # 58 % dry, 42 % bare (12 m2)
	"w1098437867": "straw", # 94 % dry
	"w1098437868": "rough_grass", # 53 % green, 44 % dry: olive median grass
	"w1098437869": "lawn", # 89 % green
	"w1098437870": "straw", # 80 % dry, 14 % green
	"w1098437871": "straw", # 89 % dry
	"w1098437872": "straw", # 66 % dry, 26 % green round its shrubs
	"w1098437879": "straw", # 94 % dry
}

static var _materials: Dictionary = {}


## The family for a generated land, area, land overlay (sand, marsh) or
## planted street-kerb record: a FAMILIES key, PAVED, or "" when the builder
## keeps its own material.
static func family_for(record: Dictionary, is_context: bool) -> String:
	if is_context:
		return ""
	var feature := str(record.get("feature_kind", ""))
	if feature == "major_area":
		var sources: Array = record.get("source_keys", [])
		if sources.size() == 1 and FAMILY_BY_SOURCE.has(str(sources[0])):
			return str(FAMILY_BY_SOURCE[str(sources[0])])
	elif feature == "terrain_overlay":
		if str(record.get("material_key", "")) not in ["terrain_sand", "terrain_wetland"]:
			return ""
	elif feature != "land_ground" and feature != "street_kerb" and feature != "street_paint":
		return ""
	return str(FAMILY_BY_MATERIAL_KEY.get(str(record.get("material_key", "")), ""))


## One shared ShaderMaterial per family, reading the ground-cover map.
static func material(family: String) -> ShaderMaterial:
	if _materials.has(family):
		return _materials[family]
	var made := ShaderMaterial.new()
	made.resource_name = "ground_cover_" + family
	made.shader = SHADER
	made.set_shader_parameter("detail_albedo", DETAIL_ALBEDO)
	made.set_shader_parameter("detail_normal", DETAIL_NORMAL)
	made.set_shader_parameter("detail_roughness", DETAIL_ROUGHNESS)
	made.set_shader_parameter("cover_map", COVER_MAP)
	made.set_shader_parameter("cover_map_rect", Vector4(COVER_MAP_ORIGIN.x, COVER_MAP_ORIGIN.y, 1.0 / COVER_MAP_SIZE_M.x, 1.0 / COVER_MAP_SIZE_M.y))
	for uniform: String in COVER_MAP_RECIPES:
		var recipe: Dictionary = FAMILIES[COVER_MAP_RECIPES[uniform]]
		made.set_shader_parameter(uniform, Vector3(recipe.dry_threshold, recipe.bare_threshold, recipe.green_dryness))
	var preset: Dictionary = FAMILIES[family]
	for parameter: String in preset:
		made.set_shader_parameter(parameter, preset[parameter])
	_materials[family] = made
	return made
