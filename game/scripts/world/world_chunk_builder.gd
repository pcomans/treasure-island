class_name WorldChunkBuilder
extends RefCounted

const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1
const WESTERN_BRIDGE_REPLACEMENT_MAX_X_M := 500.0
## The modern eastern span (tools/lib/east-span-generation.mjs) colours each
## face by its UV, which picks one texel of this palette, in order: light
## concrete for the tower, columns, caps and cables; the girders' sides mid
## grey; their undersides darker; the roadway on top road grey.
const BAY_BRIDGE_PALETTE: Array[Color] = [Color("c4c1b9"), Color("8a8883"), Color("75736e"), Color("5d6164")]
## The Clipper Cove marina basin past the outline (OSM w644986117, boundary-attached
## context) is water: the bay water (world_root.tscn ContextWorld/Water) draws it.
const MARINA_BASIN_MATERIAL_KEY := "context_boundary_marina"
const POLYHAVEN_DEFAULT_NORMAL_STRENGTH := 0.2
const HAWKINS_MASSING := preload("res://game/scripts/world/massing/hawkins_77_bruton_massing.gd")
const BUILDING_3_MASSING := preload("res://game/scripts/world/massing/building_3_600_california_massing.gd")
const NAVY_CHAPEL_187_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd")
const D5_1308_GATEVIEW_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/d5_1308_gateview_live_replacement.gd")
const D5_1394_GATEVIEW_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/d5_1394_gateview_live_replacement.gd")
const NORTHERN_CANOPY_FREE_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/northern_canopy_free_live_replacement.gd")
const NORTHPOINT_1238_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/northpoint_1238_live_replacement.gd")
const MARINER_1206_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/mariner_1206_live_replacement.gd")
const MARINER_1219_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/mariner_1219_live_replacement.gd")
const MARINER_1212_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/mariner_1212_live_replacement.gd")
const BAYSIDE_1220_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/bayside_1220_live_replacement.gd")
const NORTHPOINT_1239_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/northpoint_1239_live_replacement.gd")
const BAYSIDE_1222_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/bayside_1222_live_replacement.gd")
const NORTHPOINT_1227_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/northpoint_1227_live_replacement.gd")
const MARINER_1202_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/mariner_1202_live_replacement.gd")
const NORTHPOINT_1234_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/northpoint_1234_live_replacement.gd")
const NORTHPOINT_1232_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/northpoint_1232_live_replacement.gd")
const MARINER_1221_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/mariner_1221_live_replacement.gd")
const NORTHPOINT_1241_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/northpoint_1241_live_replacement.gd")
const NORTHPOINT_1240_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/northpoint_1240_live_replacement.gd")
const GATEVIEW_1397_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/gateview_1397_live_replacement.gd")
const BAYSIDE_1226_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/bayside_1226_live_replacement.gd")
const BAYSIDE_1215_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/bayside_1215_live_replacement.gd")
const FIRE_TRAINING600_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/fire_training_600_live_replacement.gd")
const FIRE_STATION48_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/fire_station48_live_replacement.gd")
const D5_1317_GATEVIEW_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/d5_1317_gateview_live_replacement.gd")
const ISLE_HOUSE_FORM := preload("res://game/scripts/world/facades/isle_house_form.gd")
const B201_MARKET_LIVE_REPLACEMENT := preload("res://game/scripts/world/facades/b201_market_live_replacement.gd")
const D1_B225_LIVE_ATTACHMENT := preload("res://game/scripts/world/facades/d1_b225_live_attachment.gd")
const PANEL_HALL_FACADE := preload("res://game/scripts/world/facades/panel_hall_facade.gd")
const YMCA_ENTRY_SITE := preload("res://game/scripts/world/facades/ymca_entry_site.gd")
const ACCEPTED_MATERIAL_RUN_TRIALS := preload("res://game/scripts/world/facades/accepted_material_run_trials.gd")
const BUILDING_1_HERO_MODEL := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const BUILDING_2_HERO_MODEL := preload("res://game/scripts/world/facades/building_2_hero_model.gd")
const GROUND_COVER := preload("res://game/scripts/world/ground_cover.gd")
## The shoreline riprap overlay (tools/lib/shoreline-generation.mjs): the band
## inside the outline is the dry dirt verge at the top of the riprap, in the
## ground cover family the shoreline's shoulder continues past the outline
## (ShorelineBuilder.BAND_GROUND_FAMILY); the shoreline's cobbles are set in it.
const SHORELINE_RIPRAP_OVERLAY := "terrain_riprap"
## What is left of the flat breakwater overlay: land the aerial shows as stone
## (the shoreline config's rock_grounds), drawn as the riprap's bare rock.
const SHORELINE_ROCK_OVERLAY := "terrain_breakwater"
## Street ground (tools/lib/street-ground-generation.mjs): road paint is opaque
## with a cut-out for worn paint, asphalt wear is a blended decal; parking lanes
## reuse the road asphalt. Decal material key -> its shader and textures.
const STREET_DECAL_MATERIALS := {
	"street_marking": {
		"shader": preload("res://game/resources/materials/world/street/street_paint.gdshader"),
		"textures": {
			"paint_wear": preload("res://game/resources/textures/world/street/street_paint_wear.png"),
			"tactile": preload("res://game/resources/textures/world/street/street_tactile.png"),
			"stop_legend": preload("res://game/resources/textures/world/street/street_stop_legend.png"),
			"legends": preload("res://game/resources/textures/world/street/street_legends.png"),
		},
	},
	"street_wear": {
		"shader": preload("res://game/resources/materials/world/street/street_decal.gdshader"),
		"textures": {"wear_atlas": preload("res://game/resources/textures/world/street/street_wear_atlas.png")},
	},
}
## Raised street-ground tops in their own generated textures, which carry the
## colour (no tint, so neither renderer pushes them past white): sidewalk concrete
## in 1.5 m poured panels with saw-cut joints (UV unit = one panel; the texture
## holds two by two), mulch in planting strips (2 m tiles) and banded plaza
## pavers (UV unit = one texture).
const STREET_GROUND_SURFACES := {
	"street_kerb_concrete": {"albedo": preload("res://game/resources/textures/world/street/street_concrete_panels.png"), "uv_scale": 0.5, "roughness": 0.9},
	# The Johnson St lot's curb: the same panels, darkened to the weathered grey of
	# the owner's November 2026 photographs (a tint under 1 stays clear of white).
	"street_kerb_lot": {"albedo": preload("res://game/resources/textures/world/street/street_concrete_panels.png"), "uv_scale": 0.5, "roughness": 0.9, "tint": Color(0.68, 0.65, 0.62)},
	"street_kerb_planting": {"albedo": preload("res://game/resources/textures/world/street/street_mulch.png"), "uv_scale": 1.0, "roughness": 1.0},
	"street_plaza_pavers": {"albedo": preload("res://game/resources/textures/world/street/street_plaza_pavers.png"), "uv_scale": 1.0, "roughness": 0.85},
	# Park ground (park_* records): grey pea gravel along the riprap (the
	# vegetation kit's park texture), the new dark asphalt paths and the
	# decomposed-granite paths in 2 m tiles of the world UV, the promenade and
	# garden paths in 3 m poured panels (one UV unit a panel, warm buff
	# concrete), and the pink-painted concrete stripes under the Canopy of Sky
	# (ph05, Sep 2025). The beds' mulch is PARK_BED below.
	"park_asphalt": {"albedo": preload("res://game/resources/textures/world/street/park_asphalt.png"), "uv_scale": 5.0, "roughness": 0.92},
	"park_paint_pink": {"albedo": preload("res://game/resources/textures/world/street/street_paint_wear.png"), "uv_scale": 5.0, "roughness": 0.85, "tint": Color(0.86, 0.55, 0.58)},
	"park_gravel": {"albedo": preload("res://game/resources/textures/world/vegetation/park_gravel.png"), "uv_scale": 5.0, "roughness": 0.95},
	"park_concrete": {"albedo": preload("res://game/resources/textures/world/street/street_concrete_panels.png"), "uv_scale": 0.5, "roughness": 0.9, "tint": Color(1.0, 0.96, 0.9)},
	"park_dg": {"albedo": preload("res://game/resources/textures/world/street/park_dg.png"), "uv_scale": 5.0, "roughness": 1.0},
	# Garden Walk (owner photos Nov 2026), UV in metres: pale exposed-aggregate
	# paving in 5 m scored bays, the walk's poured concrete in 2.5 m panels with
	# the joint across the tile's middle, so a walk 2.5 m wide has none down it,
	# and the dark red brick band in courses that follow its line; the yellow
	# tactile strips, the curb-ramp pads' domes in 0.5 m tiles of the world UV.
	"park_aggregate": {"albedo": preload("res://game/resources/textures/world/street/paseo_aggregate.png"), "uv_scale": 0.2, "roughness": 0.95, "tint": Color(0.785, 0.79, 0.795)},
	"park_walk": {"albedo": preload("res://game/resources/textures/world/street/paseo_walk.png"), "uv_scale": 0.4, "roughness": 0.9, "tint": Color(0.735, 0.73, 0.715)},
	"park_brick": {"albedo": preload("res://game/resources/textures/world/street/paseo_brick.png"), "uv_scale": 1.0, "roughness": 0.85, "tint": Color(0.92, 1.0, 0.86)},
	"park_tactile": {"albedo": preload("res://game/resources/textures/world/street/street_tactile.png"), "uv_scale": 20.0, "roughness": 0.8},
	# The yards' shared ground (yard surfaces of street-detail-zones.json, May 2026
	# aerial): worn asphalt as the parking lots draw it (2.1 m Poly Haven tiles,
	# the lots' tint), the older lots' pale, sun-bleached asphalt (the same tiles,
	# lightened), compacted pale gravel (the park gravel lightened), the pale
	# grey of a fresh crushed-aggregate pad (its own generated texture, 2 m
	# tiles, warmed and darkened until a top-down render samples like the May
	# 2026 aerial; Gate 5's pad is the palest ground there), grey concrete
	# rubble (the shoreline riprap, lighter, 1.25 m tiles), black plastic
	# sheeting over earth (the bitumen map darkened, with a sheen), plain
	# poured concrete (the Poly Haven floor concrete greyed, 2.5 m tiles), and
	# generated pale graded sand (tinted the same way), dark excavated soil (2 m
	# tiles) and shallow murky green-grey ponds (5 m tiles, wet).
	"yard_asphalt": {"albedo": preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_diff_1k.jpg"), "uv_scale": 4.76, "roughness": 1.0, "tint": Color(1.04, 1.05, 1.05)},
	"yard_asphalt_pale": {"albedo": preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_diff_1k.jpg"), "uv_scale": 4.76, "roughness": 1.0, "tint": Color(1.5, 1.49, 1.44)},
	# The Johnson St lot's new, dark asphalt (the same tiles, darkened and a little warmer).
	"yard_asphalt_fresh": {"albedo": preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_diff_1k.jpg"), "uv_scale": 4.76, "roughness": 1.0, "tint": Color(0.76, 0.74, 0.73)},
	# The Mersea promenade's verges (owner video IMG_0960, 2026-11-06): buff decomposed
	# granite, grey-brown bark mulch and dark crushed rock, and the warm poured slab at
	# its south end, low in specular so the sky's sheen doesn't wash them out at a
	# walker's grazing angle. Its asphalt is PROMENADE_PAVEMENT's.
	"promenade_dg": {"albedo": preload("res://game/resources/textures/world/street/park_dg.png"), "uv_scale": 5.0, "roughness": 1.0, "specular": 0.2, "tint": Color(0.52, 0.545, 0.57)},
	"promenade_mulch": {"albedo": preload("res://game/resources/textures/world/street/promenade_bark_mulch.png"), "uv_scale": 5.5, "roughness": 1.0, "specular": 0.2, "tint": Color(0.42, 0.405, 0.375)},
	"promenade_rock": {"albedo": preload("res://game/resources/textures/world/vegetation/park_gravel.png"), "uv_scale": 5.0, "roughness": 0.95, "specular": 0.25, "tint": Color(0.62, 0.61, 0.57)},
	"promenade_slab": {"albedo": preload("res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_diff_1k.jpg"), "uv_scale": 4.0, "roughness": 0.95, "specular": 0.25, "tint": Color(0.71, 0.69, 0.65)},
	"yard_gravel": {"albedo": preload("res://game/resources/textures/world/vegetation/park_gravel.png"), "uv_scale": 5.0, "roughness": 0.97, "tint": Color(1.22, 1.2, 1.15)},
	"yard_gravel_pale": {"albedo": preload("res://game/resources/textures/world/street/yard_gravel_pale.png"), "uv_scale": 5.0, "roughness": 0.97, "tint": Color(0.91, 0.87, 0.75)},
	# The Johnson St lot's shoulder: the same fine aggregate at the greys of the
	# owner's November 2026 photographs, the gravel and the narrow dark lip against the curb.
	"yard_shoulder_gravel": {"albedo": preload("res://game/resources/textures/world/street/yard_shoulder_gravel.png"), "uv_scale": 6.0, "roughness": 0.97, "specular": 0.25, "tint": Color(0.55, 0.54, 0.52)},
	"yard_shoulder_band": {"albedo": preload("res://game/resources/textures/world/street/yard_shoulder_gravel.png"), "uv_scale": 6.0, "roughness": 0.97, "specular": 0.25, "tint": Color(0.36, 0.35, 0.34)},
	"yard_concrete": {"albedo": preload("res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_diff_1k.jpg"), "uv_scale": 4.0, "roughness": 0.9, "tint": Color(1.18, 1.38, 1.46)},
	"yard_sand_pale": {"albedo": preload("res://game/resources/textures/world/street/yard_sand_pale.png"), "uv_scale": 5.0, "roughness": 0.98, "tint": Color(0.77, 0.76, 0.65)},
	"yard_soil_dark": {"albedo": preload("res://game/resources/textures/world/street/yard_soil_dark.png"), "uv_scale": 5.0, "roughness": 0.95},
	"yard_pond": {"albedo": preload("res://game/resources/textures/world/street/yard_pond.png"), "uv_scale": 2.0, "roughness": 0.15},
	"rubble_grey": {"albedo": preload("res://game/resources/textures/world/shoreline/riprap_albedo.png"), "uv_scale": 8.0, "roughness": 0.95, "tint": Color(1.12, 1.12, 1.1)},
	"black_plastic": {"albedo": preload("res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg"), "uv_scale": 2.0, "roughness": 0.45, "tint": Color(0.3, 0.3, 0.32)},
	# Poured concrete outside the street ground, on records whose UVs are the
	# world in 10 m units. Pier decks (Pier 1 as context past the playable
	# boundary, the other piers' overlays and decks) and a marina's paved
	# grounds: weathered light-grey concrete, the Poly Haven grey plaster's
	# mottling and stains spread over 20 m, tinted until a top-down sunlit
	# render samples like the May 2026 aerial (decks about 196/193/180, the
	# marina's grounds darker, about 178/176/165) and the dated Pier 1 Street
	# View's light grey. Those marina grounds (w110183752) stay concrete, not
	# ground cover: the aerial shows an old apron with slab joints, rectangular
	# foundation outlines and tyre tracks. The concrete driveway skin (an OSM
	# surface=concrete vehicle way, the Gate 5 apron in the Nov 2025 Street
	# View): the sidewalk panels at 1.5 m, a shade under the sidewalks.
	"context_boundary_pier": {"albedo": preload("res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_diff_1k.jpg"), "uv_scale": 0.5, "roughness": 0.92, "tint": Color(0.98, 1.0, 0.97)},
	"terrain_pier": {"albedo": preload("res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_diff_1k.jpg"), "uv_scale": 0.5, "roughness": 0.92, "tint": Color(0.98, 1.0, 0.97)},
	"terrain_marina": {"albedo": preload("res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_diff_1k.jpg"), "uv_scale": 0.5, "roughness": 0.92, "tint": Color(0.885, 0.91, 0.895)},
	"road_path_concrete": {"albedo": preload("res://game/resources/textures/world/street/street_concrete_panels.png"), "uv_scale": 3.33, "roughness": 0.9, "tint": Color(0.96, 0.94, 0.86)},
}
## The Mersea promenade's pavement: the old road and its fresh seal, under one
## pavement shader (promenade_pavement.gdshader) drawing the road's wear on a generated
## tile of worn aggregate: the old road's at full scale, the seal's fine and flat.
const PROMENADE_PAVEMENT_SHADER := preload("res://game/resources/materials/world/street/promenade_pavement.gdshader")
const PROMENADE_AGGREGATE := preload("res://game/resources/textures/world/street/promenade_aggregate.png")
const PROMENADE_PAVEMENT := {
	"promenade_asphalt": {"tile_m": 1.15, "contrast": 1.0, "tone": Color(0.51, 0.53, 0.56), "wear": 1.0},
	"promenade_seal": {"tile_m": 0.62, "contrast": 0.55, "tone": Color(0.485, 0.51, 0.54), "wear": 0.3},
}

## A park's planted beds (park_mulch records): the vegetation kit's dark
## grey-brown shredded mulch in 2 m tiles of the world UV, blending to the
## beds' planted colour beyond the low plants' range
## (game/resources/materials/world/street/park_bed.gdshader).
const PARK_BED_MATERIAL_KEY := "park_mulch"
const PARK_BED_SHADER := preload("res://game/resources/materials/world/street/park_bed.gdshader")
const PARK_BED_MULCH := preload("res://game/resources/textures/world/vegetation/park_mulch.png")
const PARK_BED_UV_SCALE := 5.0
## Painted park plazas (park_plaza_* records): game/resources/materials/world/street/park_paving.gdshader
## draws the pattern in the plaza's own frame (UV in metres); colours read from the dated photos.
const PARK_PAVING_SHADER := preload("res://game/resources/materials/world/street/park_paving.gdshader")
const PARK_PAVING_MATERIALS := {
	"park_plaza_zigzag": {"pattern": 0, "color_light": Color(0.88, 0.88, 0.86), "color_mid": Color(0.66, 0.67, 0.66), "color_dark": Color(0.36, 0.37, 0.37)},
	"park_plaza_lens": {"pattern": 1, "color_light": Color(0.8, 0.8, 0.78), "color_mid": Color(0.5, 0.5, 0.5), "color_dark": Color(0.2, 0.2, 0.21)},
}
const POLYHAVEN_TEXTURE_SETS := {
	"clean_asphalt": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_rough_1k.jpg"),
		"source_dimension_m": 2.1,
		"repeat_dimension_m": 2.1,
	},
	"concrete_pavement": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_rough_1k.jpg"),
		"source_dimension_m": 1.8,
		"repeat_dimension_m": 1.8,
	},
	"concrete_floor_03": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_rough_1k.jpg"),
		"source_dimension_m": 2.5,
		"repeat_dimension_m": 2.5,
	},
	"sparse_grass": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_rough_1k.jpg"),
		"source_dimension_m": 2.0,
		"repeat_dimension_m": 5.0,
	},
	"plaster_grey_04": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_rough_1k.jpg"),
		"source_dimension_m": 1.5,
		"repeat_dimension_m": 0.75,
		"normal_strength": 0.1,
	},
	"bitumen": {
		"albedo": preload("res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg"),
		"normal": preload("res://game/resources/textures/world/polyhaven/bitumen/bitumen_nor_gl_1k.jpg"),
		"roughness": preload("res://game/resources/textures/world/polyhaven/bitumen/bitumen_rough_1k.jpg"),
		"source_dimension_m": 20.0,
		"repeat_dimension_m": 10.0,
	},
}
const POLYHAVEN_MATERIAL_TEXTURE_SET := {
	"road_path": "clean_asphalt",
	"road_path_pedestrian": "concrete_pavement",
	"major_area_paved": "clean_asphalt",
	"major_area_court": "concrete_floor_03",
	"street_parking": "clean_asphalt",
	"street_gutter": "concrete_floor_03",
	"context_ybi": "sparse_grass",
	"building_wall": "plaster_grey_04",
	"building_part_wall": "plaster_grey_04",
	"building_roof": "bitumen",
	"building_part_roof": "bitumen",
}

var _materials: Dictionary = {}
var _street_decal_materials: Dictionary = {}
var _street_ground_materials: Dictionary = {}
var _park_paving_materials: Dictionary = {}
var _park_bed: ShaderMaterial
var _generic_roof_material: StandardMaterial3D


func build_chunk(chunk: Dictionary, category_parents: Dictionary) -> Dictionary:
	var chunk_root := Node3D.new()
	chunk_root.name = str(chunk.chunk_id).validate_node_name()
	# B225's production attachment is equally exact-target-only. Validate the
	# complete wall/roof membership before any row from its chunk is staged so a
	# missing, duplicate, moved, or malformed receiver can never fall back generic.
	var b225_chunk_validation := D1_B225_LIVE_ATTACHMENT.validate_chunk_records(chunk)
	if not bool(b225_chunk_validation.get("ok", false)):
		chunk_root.free()
		return b225_chunk_validation
	# Pair-preflight the actual supplied chunk before any generic node exists.
	# This prevents either Chapel row from borrowing its mate from disk or from
	# being suppressed alone when the other row is missing or drifted.
	var chapel_pair := NAVY_CHAPEL_187_LIVE_REPLACEMENT.prepare_chunk_records(chunk.records as Array)
	if not bool(chapel_pair.get("ok", false)):
		chunk_root.free()
		return chapel_pair
	var d5_1308_pair := D5_1308_GATEVIEW_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(d5_1308_pair.get("ok", false)):
		chunk_root.free()
		return d5_1308_pair
	var d5_1394_pair := D5_1394_GATEVIEW_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(d5_1394_pair.get("ok", false)):
		chunk_root.free()
		return d5_1394_pair
	var d5_1317_pair := D5_1317_GATEVIEW_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(d5_1317_pair.get("ok", false)):
		chunk_root.free()
		return d5_1317_pair
	var fire_training600_pair := FIRE_TRAINING600_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(fire_training600_pair.get("ok", false)):
		chunk_root.free()
		return fire_training600_pair
	var b201_market_pair := B201_MARKET_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(b201_market_pair.get("ok", false)):
		chunk_root.free()
		return b201_market_pair
	var fs48_pair := FIRE_STATION48_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(fs48_pair.get("ok", false)):
		chunk_root.free()
		return fs48_pair
	var northern_canopy_pair := NORTHERN_CANOPY_FREE_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(northern_canopy_pair.get("ok", false)):
		chunk_root.free()
		return northern_canopy_pair
	var northpoint_1238_pair := NORTHPOINT_1238_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(northpoint_1238_pair.get("ok", false)):
		chunk_root.free()
		return northpoint_1238_pair
	var mariner_1206_pair := MARINER_1206_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(mariner_1206_pair.get("ok", false)):
		chunk_root.free()
		return mariner_1206_pair
	var mariner_1219_pair := MARINER_1219_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(mariner_1219_pair.get("ok", false)):
		chunk_root.free()
		return mariner_1219_pair
	var mariner_1212_pair := MARINER_1212_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(mariner_1212_pair.get("ok", false)):
		chunk_root.free()
		return mariner_1212_pair
	var bayside_1220_pair := BAYSIDE_1220_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(bayside_1220_pair.get("ok", false)):
		chunk_root.free()
		return bayside_1220_pair
	var northpoint_1239_pair := NORTHPOINT_1239_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(northpoint_1239_pair.get("ok", false)):
		chunk_root.free()
		return northpoint_1239_pair
	var bayside_1222_pair := BAYSIDE_1222_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(bayside_1222_pair.get("ok", false)):
		chunk_root.free()
		return bayside_1222_pair
	var northpoint_1227_pair := NORTHPOINT_1227_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(northpoint_1227_pair.get("ok", false)):
		chunk_root.free()
		return northpoint_1227_pair
	var mariner_1202_pair := MARINER_1202_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(mariner_1202_pair.get("ok", false)):
		chunk_root.free()
		return mariner_1202_pair
	var northpoint_1234_pair := NORTHPOINT_1234_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(northpoint_1234_pair.get("ok", false)):
		chunk_root.free()
		return northpoint_1234_pair
	var northpoint_1232_pair := NORTHPOINT_1232_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(northpoint_1232_pair.get("ok", false)):
		chunk_root.free()
		return northpoint_1232_pair
	var mariner_1221_pair := MARINER_1221_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(mariner_1221_pair.get("ok", false)):
		chunk_root.free()
		return mariner_1221_pair
	var northpoint_1241_pair := NORTHPOINT_1241_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(northpoint_1241_pair.get("ok", false)):
		chunk_root.free()
		return northpoint_1241_pair
	var northpoint_1240_pair := NORTHPOINT_1240_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(northpoint_1240_pair.get("ok", false)):
		chunk_root.free()
		return northpoint_1240_pair
	var gateview_1397_pair := GATEVIEW_1397_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(gateview_1397_pair.get("ok", false)):
		chunk_root.free()
		return gateview_1397_pair
	var bayside_1226_pair := BAYSIDE_1226_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(bayside_1226_pair.get("ok", false)):
		chunk_root.free()
		return bayside_1226_pair
	var bayside_1215_pair := BAYSIDE_1215_LIVE_REPLACEMENT.prepare_chunk_records(chunk)
	if not bool(bayside_1215_pair.get("ok", false)):
		chunk_root.free()
		return bayside_1215_pair
	var rollback_plans: Array[Dictionary] = []
	var chapel_plan := NAVY_CHAPEL_187_LIVE_REPLACEMENT.build_chunk_plan(chapel_pair)
	if not bool(chapel_plan.get("ok", false)):
		chunk_root.free()
		return chapel_plan
	rollback_plans.append({"adapter": NAVY_CHAPEL_187_LIVE_REPLACEMENT, "plan": chapel_plan})
	var d5_1308_plan := D5_1308_GATEVIEW_LIVE_REPLACEMENT.build_chunk_plan(d5_1308_pair, _material_for("building_wall", "building_wall", false), _material_for("building_roof", "building_roof", false))
	if not bool(d5_1308_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return d5_1308_plan
	rollback_plans.append({"adapter": D5_1308_GATEVIEW_LIVE_REPLACEMENT, "plan": d5_1308_plan})
	var d5_1394_plan := D5_1394_GATEVIEW_LIVE_REPLACEMENT.build_chunk_plan(d5_1394_pair, _material_for("building_wall", "building_wall", false), _material_for("building_roof", "building_roof", false))
	if not bool(d5_1394_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return d5_1394_plan
	rollback_plans.append({"adapter": D5_1394_GATEVIEW_LIVE_REPLACEMENT, "plan": d5_1394_plan})
	var d5_1317_plan := D5_1317_GATEVIEW_LIVE_REPLACEMENT.build_chunk_plan(d5_1317_pair, _material_for("building_wall", "building_wall", false), _material_for("building_roof", "building_roof", false))
	if not bool(d5_1317_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return d5_1317_plan
	rollback_plans.append({"adapter": D5_1317_GATEVIEW_LIVE_REPLACEMENT, "plan": d5_1317_plan})
	var fire_training600_plan := FIRE_TRAINING600_LIVE_REPLACEMENT.build_chunk_plan(fire_training600_pair)
	if not bool(fire_training600_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return fire_training600_plan
	rollback_plans.append({"adapter": FIRE_TRAINING600_LIVE_REPLACEMENT, "plan": fire_training600_plan})
	var b201_market_plan := B201_MARKET_LIVE_REPLACEMENT.build_chunk_plan(b201_market_pair)
	if not bool(b201_market_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return b201_market_plan
	rollback_plans.append({"adapter": B201_MARKET_LIVE_REPLACEMENT, "plan": b201_market_plan})
	var fs48_plan := FIRE_STATION48_LIVE_REPLACEMENT.build_chunk_plan(fs48_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(fs48_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return fs48_plan
	rollback_plans.append({"adapter": FIRE_STATION48_LIVE_REPLACEMENT, "plan": fs48_plan})
	var northern_canopy_plan := NORTHERN_CANOPY_FREE_LIVE_REPLACEMENT.build_chunk_plan(northern_canopy_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(northern_canopy_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return northern_canopy_plan
	rollback_plans.append({"adapter": NORTHERN_CANOPY_FREE_LIVE_REPLACEMENT, "plan": northern_canopy_plan})
	var northpoint_1238_plan := NORTHPOINT_1238_LIVE_REPLACEMENT.build_chunk_plan(northpoint_1238_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(northpoint_1238_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return northpoint_1238_plan
	rollback_plans.append({"adapter": NORTHPOINT_1238_LIVE_REPLACEMENT, "plan": northpoint_1238_plan})
	var mariner_1206_plan := MARINER_1206_LIVE_REPLACEMENT.build_chunk_plan(mariner_1206_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(mariner_1206_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return mariner_1206_plan
	rollback_plans.append({"adapter": MARINER_1206_LIVE_REPLACEMENT, "plan": mariner_1206_plan})
	var mariner_1219_plan := MARINER_1219_LIVE_REPLACEMENT.build_chunk_plan(mariner_1219_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(mariner_1219_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return mariner_1219_plan
	rollback_plans.append({"adapter": MARINER_1219_LIVE_REPLACEMENT, "plan": mariner_1219_plan})
	var mariner_1212_plan := MARINER_1212_LIVE_REPLACEMENT.build_chunk_plan(mariner_1212_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(mariner_1212_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return mariner_1212_plan
	rollback_plans.append({"adapter": MARINER_1212_LIVE_REPLACEMENT, "plan": mariner_1212_plan})
	var bayside_1220_plan := BAYSIDE_1220_LIVE_REPLACEMENT.build_chunk_plan(bayside_1220_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(bayside_1220_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return bayside_1220_plan
	rollback_plans.append({"adapter": BAYSIDE_1220_LIVE_REPLACEMENT, "plan": bayside_1220_plan})
	var northpoint_1239_plan := NORTHPOINT_1239_LIVE_REPLACEMENT.build_chunk_plan(northpoint_1239_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(northpoint_1239_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return northpoint_1239_plan
	rollback_plans.append({"adapter": NORTHPOINT_1239_LIVE_REPLACEMENT, "plan": northpoint_1239_plan})
	var bayside_1222_plan := BAYSIDE_1222_LIVE_REPLACEMENT.build_chunk_plan(bayside_1222_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(bayside_1222_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return bayside_1222_plan
	rollback_plans.append({"adapter": BAYSIDE_1222_LIVE_REPLACEMENT, "plan": bayside_1222_plan})
	var northpoint_1227_plan := NORTHPOINT_1227_LIVE_REPLACEMENT.build_chunk_plan(northpoint_1227_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(northpoint_1227_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return northpoint_1227_plan
	rollback_plans.append({"adapter": NORTHPOINT_1227_LIVE_REPLACEMENT, "plan": northpoint_1227_plan})
	var mariner_1202_plan := MARINER_1202_LIVE_REPLACEMENT.build_chunk_plan(mariner_1202_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(mariner_1202_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return mariner_1202_plan
	rollback_plans.append({"adapter": MARINER_1202_LIVE_REPLACEMENT, "plan": mariner_1202_plan})
	var northpoint_1234_plan := NORTHPOINT_1234_LIVE_REPLACEMENT.build_chunk_plan(northpoint_1234_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(northpoint_1234_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return northpoint_1234_plan
	rollback_plans.append({"adapter": NORTHPOINT_1234_LIVE_REPLACEMENT, "plan": northpoint_1234_plan})
	var northpoint_1232_plan := NORTHPOINT_1232_LIVE_REPLACEMENT.build_chunk_plan(northpoint_1232_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(northpoint_1232_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return northpoint_1232_plan
	rollback_plans.append({"adapter": NORTHPOINT_1232_LIVE_REPLACEMENT, "plan": northpoint_1232_plan})
	var mariner_1221_plan := MARINER_1221_LIVE_REPLACEMENT.build_chunk_plan(mariner_1221_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(mariner_1221_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return mariner_1221_plan
	rollback_plans.append({"adapter": MARINER_1221_LIVE_REPLACEMENT, "plan": mariner_1221_plan})
	var northpoint_1241_plan := NORTHPOINT_1241_LIVE_REPLACEMENT.build_chunk_plan(northpoint_1241_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(northpoint_1241_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return northpoint_1241_plan
	rollback_plans.append({"adapter": NORTHPOINT_1241_LIVE_REPLACEMENT, "plan": northpoint_1241_plan})
	var northpoint_1240_plan := NORTHPOINT_1240_LIVE_REPLACEMENT.build_chunk_plan(northpoint_1240_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(northpoint_1240_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return northpoint_1240_plan
	rollback_plans.append({"adapter": NORTHPOINT_1240_LIVE_REPLACEMENT, "plan": northpoint_1240_plan})
	var gateview_1397_plan := GATEVIEW_1397_LIVE_REPLACEMENT.build_chunk_plan(gateview_1397_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(gateview_1397_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return gateview_1397_plan
	rollback_plans.append({"adapter": GATEVIEW_1397_LIVE_REPLACEMENT, "plan": gateview_1397_plan})
	var bayside_1226_plan := BAYSIDE_1226_LIVE_REPLACEMENT.build_chunk_plan(bayside_1226_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(bayside_1226_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return bayside_1226_plan
	rollback_plans.append({"adapter": BAYSIDE_1226_LIVE_REPLACEMENT, "plan": bayside_1226_plan})
	var bayside_1215_plan := BAYSIDE_1215_LIVE_REPLACEMENT.build_chunk_plan(bayside_1215_pair, Callable(self, "_build_unpaired_record"), Callable(self, "_tangents_for"))
	if not bool(bayside_1215_plan.get("ok", false)):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return bayside_1215_plan
	rollback_plans.append({"adapter": BAYSIDE_1215_LIVE_REPLACEMENT, "plan": bayside_1215_plan})
	var report := {
		"ok": true,
		"node": chunk_root,
		"mesh_instances": 0,
		"surfaces": 0,
		"triangles": 0,
		"static_bodies": 0,
		"shapes": 0,
		"source_keys": {},
	}
	for record_value: Variant in chunk.records:
		var record: Dictionary = record_value
		var parent_key := _parent_key_for_feature(str(record.feature_kind))
		if not category_parents.has(parent_key):
			_free_unconsumed_plans(rollback_plans)
			chunk_root.free()
			return {"ok": false, "code": "builder_parent", "message": "Missing world category parent %s." % parent_key, "source_keys": record.source_keys}
		var record_result: Dictionary
		if FIRE_TRAINING600_LIVE_REPLACEMENT.claims_record(record):
			record_result = FIRE_TRAINING600_LIVE_REPLACEMENT.consume_record(record, fire_training600_plan)
		elif B201_MARKET_LIVE_REPLACEMENT.claims_record(record):
			record_result = B201_MARKET_LIVE_REPLACEMENT.consume_record(record, b201_market_plan)
		else:
			record_result = _build_record(record, false, chapel_plan, d5_1308_plan, d5_1394_plan, d5_1317_plan, fs48_plan, northern_canopy_plan, northpoint_1238_plan, mariner_1206_plan, mariner_1219_plan, mariner_1212_plan, bayside_1220_plan, northpoint_1239_plan, bayside_1222_plan, northpoint_1227_plan, mariner_1202_plan, northpoint_1234_plan, bayside_1215_plan, northpoint_1232_plan, northpoint_1241_plan, mariner_1221_plan, northpoint_1240_plan, gateview_1397_plan, bayside_1226_plan)
		if not record_result.ok:
			_free_unconsumed_plans(rollback_plans)
			chunk_root.free()
			return record_result
		var record_node: Node3D = record_result.node
		var category_proxy := Node3D.new()
		category_proxy.name = "%s__%s" % [str(chunk.chunk_id), str(record.object_key).validate_node_name()]
		category_proxy.add_child(record_node)
		category_proxy.set_meta("target_parent", category_parents[parent_key])
		chunk_root.add_child(category_proxy)
		report.mesh_instances += int(record_result.get("mesh_instances", 1))
		report.surfaces += int(record_result.get("surfaces", 1))
		report.triangles += int(record_result.triangles)
		report.static_bodies += int(record_result.get("static_bodies", 1 if str(record.collision_kind) == "world_solid" else 0))
		report.shapes += int(record_result.get("shapes", 1 if str(record.collision_kind) == "world_solid" else 0))
		for key_value: Variant in record.source_keys:
			report.source_keys[str(key_value)] = true
	if not FIRE_TRAINING600_LIVE_REPLACEMENT.plan_was_fully_consumed(fire_training600_plan):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return {"ok": false, "code": "fire_training600_unconsumed", "message": "Building 600 source pair was not fully consumed.", "source_keys": ["w34313548"]}
	if not B201_MARKET_LIVE_REPLACEMENT.plan_was_fully_consumed(b201_market_plan):
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		return {"ok": false, "code": "b201_market_unconsumed", "message": "Building 201 source pair was not fully consumed.", "source_keys": ["w34313545"]}
	var b201_lot := B201_MARKET_LIVE_REPLACEMENT.take_lot(b201_market_plan)
	if not b201_lot.is_empty():
		var lot_proxy := Node3D.new()
		lot_proxy.name = "%s__b201_market_lot" % str(chunk.chunk_id)
		lot_proxy.add_child(b201_lot.node)
		lot_proxy.set_meta("target_parent", category_parents["ground"])
		chunk_root.add_child(lot_proxy)
		report.mesh_instances += int(b201_lot.mesh_instances)
		report.surfaces += int(b201_lot.surfaces)
		report.triangles += int(b201_lot.triangles)
	var chapel_consumed := NAVY_CHAPEL_187_LIVE_REPLACEMENT.plan_was_fully_consumed(chapel_plan)
	var d5_1308_consumed := D5_1308_GATEVIEW_LIVE_REPLACEMENT.plan_was_fully_consumed(d5_1308_plan)
	var d5_1394_consumed := D5_1394_GATEVIEW_LIVE_REPLACEMENT.plan_was_fully_consumed(d5_1394_plan)
	var d5_1317_consumed := D5_1317_GATEVIEW_LIVE_REPLACEMENT.plan_was_fully_consumed(d5_1317_plan)
	var fs48_consumed := FIRE_STATION48_LIVE_REPLACEMENT.plan_was_fully_consumed(fs48_plan)
	var northern_canopy_consumed := NORTHERN_CANOPY_FREE_LIVE_REPLACEMENT.plan_was_fully_consumed(northern_canopy_plan)
	var northpoint_1238_consumed := NORTHPOINT_1238_LIVE_REPLACEMENT.plan_was_fully_consumed(northpoint_1238_plan)
	var mariner_1206_consumed := MARINER_1206_LIVE_REPLACEMENT.plan_was_fully_consumed(mariner_1206_plan)
	var mariner_1219_consumed := MARINER_1219_LIVE_REPLACEMENT.plan_was_fully_consumed(mariner_1219_plan)
	var mariner_1212_consumed := MARINER_1212_LIVE_REPLACEMENT.plan_was_fully_consumed(mariner_1212_plan)
	var bayside_1220_consumed := BAYSIDE_1220_LIVE_REPLACEMENT.plan_was_fully_consumed(bayside_1220_plan)
	var northpoint_1239_consumed := NORTHPOINT_1239_LIVE_REPLACEMENT.plan_was_fully_consumed(northpoint_1239_plan)
	var bayside_1222_consumed := BAYSIDE_1222_LIVE_REPLACEMENT.plan_was_fully_consumed(bayside_1222_plan)
	var northpoint_1227_consumed := NORTHPOINT_1227_LIVE_REPLACEMENT.plan_was_fully_consumed(northpoint_1227_plan)
	var mariner_1202_consumed := MARINER_1202_LIVE_REPLACEMENT.plan_was_fully_consumed(mariner_1202_plan)
	var northpoint_1234_consumed := NORTHPOINT_1234_LIVE_REPLACEMENT.plan_was_fully_consumed(northpoint_1234_plan)
	var northpoint_1232_consumed := NORTHPOINT_1232_LIVE_REPLACEMENT.plan_was_fully_consumed(northpoint_1232_plan)
	var mariner_1221_consumed := MARINER_1221_LIVE_REPLACEMENT.plan_was_fully_consumed(mariner_1221_plan)
	var northpoint_1241_consumed := NORTHPOINT_1241_LIVE_REPLACEMENT.plan_was_fully_consumed(northpoint_1241_plan)
	var northpoint_1240_consumed := NORTHPOINT_1240_LIVE_REPLACEMENT.plan_was_fully_consumed(northpoint_1240_plan)
	var gateview_1397_consumed := GATEVIEW_1397_LIVE_REPLACEMENT.plan_was_fully_consumed(gateview_1397_plan)
	var bayside_1226_consumed := BAYSIDE_1226_LIVE_REPLACEMENT.plan_was_fully_consumed(bayside_1226_plan)
	var bayside_1215_consumed := BAYSIDE_1215_LIVE_REPLACEMENT.plan_was_fully_consumed(bayside_1215_plan)
	if not chapel_consumed or not d5_1308_consumed or not d5_1394_consumed or not d5_1317_consumed or not fs48_consumed or not northern_canopy_consumed or not northpoint_1238_consumed or not mariner_1206_consumed or not mariner_1219_consumed or not mariner_1212_consumed or not bayside_1220_consumed or not northpoint_1239_consumed or not bayside_1222_consumed or not northpoint_1227_consumed or not mariner_1202_consumed or not northpoint_1234_consumed or not bayside_1215_consumed or not northpoint_1232_consumed or not northpoint_1241_consumed or not mariner_1221_consumed or not northpoint_1240_consumed or not gateview_1397_consumed or not bayside_1226_consumed:
		_free_unconsumed_plans(rollback_plans)
		chunk_root.free()
		if not chapel_consumed:
			return {"ok": false, "code": "navy_chapel_187_live_unconsumed_pair", "message": "The supplied Chapel pair was not consumed exactly once.", "source_keys": ["w291189336"]}
		if not d5_1308_consumed:
			return {"ok": false, "code": "d5_1308_live_unconsumed_pair", "message": "The supplied1308pair was not consumed exactly once.", "source_keys": ["w95934123"]}
		if not d5_1394_consumed:
			return {"ok": false, "code": "d5_1394_live_unconsumed_pair", "message": "The supplied1394pair was not consumed exactly once.", "source_keys": ["w96215646"]}
		if not d5_1317_consumed:
			return {"ok": false, "code": "d5_1317_live_unconsumed_pair", "message": "The supplied 1317 pair was not consumed exactly once.", "source_keys": ["w95934125"]}
		if not fs48_consumed:
			return {"ok": false, "code": "fire_station48_unconsumed_pair", "message": "The supplied Station 48 pair was not consumed exactly once.", "source_keys": ["w764313741"]}
		if not northern_canopy_consumed:
			return {"ok": false, "code": "northern_canopy_unconsumed_pair", "message": "The supplied 1201 pair was not consumed exactly once.", "source_keys": ["w96215672"]}
		if not northpoint_1238_consumed:
			return {"ok": false, "code": "northpoint_1238_unconsumed_pair", "message": "The supplied 1238 pair was not consumed exactly once.", "source_keys": ["w96215669"]}
		if not mariner_1206_consumed:
			return {"ok": false, "code": "mariner_1206_unconsumed_pair", "message": "The supplied 1206 pair was not consumed exactly once.", "source_keys": ["w96215677"]}
		if not mariner_1219_consumed:
			return {"ok": false, "code": "mariner_1219_unconsumed_pair", "message": "The supplied 1219 pair was not consumed exactly once.", "source_keys": ["w96215680"]}
		if not mariner_1212_consumed:
			return {"ok": false, "code": "mariner_1212_unconsumed_pair", "message": "The supplied 1212 pair was not consumed exactly once.", "source_keys": ["w96215649"]}
		if not bayside_1220_consumed:
			return {"ok": false, "code": "bayside_1220_unconsumed_pair", "message": "The supplied 1220 pair was not consumed exactly once.", "source_keys": ["w96215652"]}
		if not northpoint_1239_consumed:
			return {"ok": false, "code": "northpoint_1239_unconsumed_pair", "message": "The supplied 1239 pair was not consumed exactly once.", "source_keys": ["w96215658"]}
		if not bayside_1222_consumed:
			return {"ok": false, "code": "bayside_1222_unconsumed_pair", "message": "The supplied 1222 pair was not consumed exactly once.", "source_keys": ["w96215661"]}
		if not northpoint_1227_consumed:
			return {"ok": false, "code": "northpoint_1227_unconsumed_pair", "message": "The supplied 1227 pair was not consumed exactly once.", "source_keys": ["w96215653"]}
		if not northpoint_1234_consumed:
			return {"ok": false, "code": "northpoint_1234_unconsumed_pair", "message": "The supplied 1234 pair was not consumed exactly once.", "source_keys": ["w96215659"]}
		if not northpoint_1232_consumed:
			return {"ok": false, "code": "northpoint_1232_unconsumed_pair", "message": "The supplied 1232 pair was not consumed exactly once.", "source_keys": ["w96215673"]}
		if not mariner_1221_consumed:
			return {"ok": false, "code": "mariner_1221_unconsumed_pair", "message": "The supplied 1221 pair was not consumed exactly once.", "source_keys": ["w96215682"]}
		if not northpoint_1241_consumed:
			return {"ok": false, "code": "northpoint_1241_unconsumed_pair", "message": "The supplied 1241 pair was not consumed exactly once.", "source_keys": ["w96215674"]}
		if not northpoint_1240_consumed:
			return {"ok": false, "code": "northpoint_1240_unconsumed_pair", "message": "The supplied 1240 pair was not consumed exactly once.", "source_keys": ["w96215688"]}
		if not gateview_1397_consumed:
			return {"ok": false, "code": "gateview_1397_unconsumed_pair", "message": "The supplied 1397 pair was not consumed exactly once.", "source_keys": ["w96215670"]}
		if not bayside_1226_consumed:
			return {"ok": false, "code": "bayside_1226_unconsumed_pair", "message": "The supplied 1226 pair was not consumed exactly once.", "source_keys": ["w96215685"]}
		if not bayside_1215_consumed:
			return {"ok": false, "code": "bayside_1215_unconsumed_pair", "message": "The supplied 1215 pair was not consumed exactly once.", "source_keys": ["w96215666"]}
		return {"ok": false, "code": "mariner_1202_unconsumed_pair", "message": "The supplied 1202 pair was not consumed exactly once.", "source_keys": ["w96215651"]}
	return report


func _free_unconsumed_plans(plans: Array[Dictionary]) -> void:
	for entry: Dictionary in plans:
		var adapter: Script = entry.adapter
		var plan: Dictionary = entry.plan
		adapter.free_unconsumed(plan)


func attach_built_chunk(report: Dictionary, _category_parents: Dictionary) -> void:
	var chunk_root: Node3D = report.node
	while chunk_root.get_child_count() > 0:
		var proxy := chunk_root.get_child(0) as Node3D
		chunk_root.remove_child(proxy)
		var target: Node3D = proxy.get_meta("target_parent") as Node3D
		proxy.set_meta("target_parent", null)
		target.add_child(proxy)
	chunk_root.free()


func build_context(context: Dictionary, context_parents: Dictionary) -> Dictionary:
	var staging := Node3D.new()
	staging.name = "ValidatedContext"
	var report := {
		"ok": true,
		"node": staging,
		"mesh_instances": 0,
		"surfaces": 0,
		"triangles": 0,
		"static_bodies": 0,
		"shapes": 0,
		"source_keys": {},
	}
	var context_records: Array = context.records.duplicate()
	context_records.append_array(context.boundary_attached_visuals)
	for record_value: Variant in context_records:
		var record: Dictionary = record_value
		var adapted := record.duplicate(true)
		adapted["feature_kind"] = str(record.context_kind)
		var record_result := _build_record(adapted, true)
		if not record_result.ok:
			staging.free()
			return record_result
		var proxy := Node3D.new()
		proxy.name = str(record.object_key).validate_node_name()
		proxy.add_child(record_result.node)
		proxy.set_meta("target_parent", context_parents[str(record.context_kind)])
		staging.add_child(proxy)
		report.mesh_instances += int(record_result.get("mesh_instances", 1))
		report.surfaces += int(record_result.get("surfaces", 1))
		report.triangles += int(record_result.triangles)
		for key_value: Variant in record.source_keys:
			report.source_keys[str(key_value)] = true
	return report


func _build_record(record: Dictionary, is_context: bool, chapel_plan: Dictionary = {}, d5_1308_plan: Dictionary = {}, d5_1394_plan: Dictionary = {}, d5_1317_plan: Dictionary = {}, fs48_plan: Dictionary = {}, northern_canopy_plan: Dictionary = {}, northpoint_1238_plan: Dictionary = {}, mariner_1206_plan: Dictionary = {}, mariner_1219_plan: Dictionary = {}, mariner_1212_plan: Dictionary = {}, bayside_1220_plan: Dictionary = {}, northpoint_1239_plan: Dictionary = {}, bayside_1222_plan: Dictionary = {}, northpoint_1227_plan: Dictionary = {}, mariner_1202_plan: Dictionary = {}, northpoint_1234_plan: Dictionary = {}, bayside_1215_plan: Dictionary = {}, northpoint_1232_plan: Dictionary = {}, northpoint_1241_plan: Dictionary = {}, mariner_1221_plan: Dictionary = {}, northpoint_1240_plan: Dictionary = {}, gateview_1397_plan: Dictionary = {}, bayside_1226_plan: Dictionary = {}) -> Dictionary:
	# Building 1's generated 20 m slab and terrain-level tower are source-valid
	# horizontal placeholders but visually and physically wrong in the vertical
	# dimension.  Intercept all four independently keyed records before generic
	# mesh/collision construction so no invisible legacy surfaces survive.
	if not is_context and BUILDING_1_HERO_MODEL.matches_record(record):
		return BUILDING_1_HERO_MODEL.build_record(record)
	# Building 2 (w24274434) replaces its exact wall and roof records together with
	# reference-grounded arched hangar massing inside the frozen footprint.
	if not is_context and BUILDING_2_HERO_MODEL.matches_record(record):
		return BUILDING_2_HERO_MODEL.build_record(record)
	# Isle House's two wall records and its low roof are rebuilt by its form producer, receivers
	# following the recessed bases, podium, band, tower folds and slots.
	if not is_context and ISLE_HOUSE_FORM.matches_low_record(record):
		return ISLE_HOUSE_FORM.build_low_record(record)
	if not is_context and ISLE_HOUSE_FORM.matches_high_record(record):
		return ISLE_HOUSE_FORM.build_high_record(record)
	if not is_context and ISLE_HOUSE_FORM.matches_low_roof_record(record):
		return ISLE_HOUSE_FORM.build_low_roof_record(record)
	if not is_context and HAWKINS_MASSING.matches_record(record):
		return HAWKINS_MASSING.build_record(
			record,
			_material_for(str(record.material_key), str(record.feature_kind), false)
		)
	# Building 3's frozen horizontal receiver remains authoritative, while its
	# flat vertical placeholder obscures the landmark hangar family. Replace
	# wall and roof together before generic collision is ever constructed.
	if not is_context and BUILDING_3_MASSING.matches_record(record):
		return BUILDING_3_MASSING.build_record(
			record,
			_material_for(str(record.material_key), str(record.feature_kind), false)
		)
	# Chapel 187 is a paired wall+roof replacement. The plan constructs approved
	# visuals once and splits wall spray collision from roof/cap/cross landing
	# collision; both exact rows are consumed without generic fallback or stack.
	if not is_context and NAVY_CHAPEL_187_LIVE_REPLACEMENT.claims_record(record):
		return NAVY_CHAPEL_187_LIVE_REPLACEMENT.consume_record(record, chapel_plan)
	if not is_context and D5_1308_GATEVIEW_LIVE_REPLACEMENT.claims_record(record):
		return D5_1308_GATEVIEW_LIVE_REPLACEMENT.consume_record(record, d5_1308_plan)
	if not is_context and D5_1394_GATEVIEW_LIVE_REPLACEMENT.claims_record(record):
		return D5_1394_GATEVIEW_LIVE_REPLACEMENT.consume_record(record, d5_1394_plan)
	if not is_context and D5_1317_GATEVIEW_LIVE_REPLACEMENT.claims_record(record):
		return D5_1317_GATEVIEW_LIVE_REPLACEMENT.consume_record(record, d5_1317_plan)
	if not is_context and FIRE_STATION48_LIVE_REPLACEMENT.claims_record(record):
		return FIRE_STATION48_LIVE_REPLACEMENT.consume_record(record, fs48_plan)
	if not is_context and NORTHERN_CANOPY_FREE_LIVE_REPLACEMENT.claims_record(record):
		return NORTHERN_CANOPY_FREE_LIVE_REPLACEMENT.consume_record(record, northern_canopy_plan)
	if not is_context and NORTHPOINT_1238_LIVE_REPLACEMENT.claims_record(record):
		return NORTHPOINT_1238_LIVE_REPLACEMENT.consume_record(record, northpoint_1238_plan)
	if not is_context and MARINER_1206_LIVE_REPLACEMENT.claims_record(record):
		return MARINER_1206_LIVE_REPLACEMENT.consume_record(record, mariner_1206_plan)
	if not is_context and MARINER_1219_LIVE_REPLACEMENT.claims_record(record):
		return MARINER_1219_LIVE_REPLACEMENT.consume_record(record, mariner_1219_plan)
	if not is_context and MARINER_1212_LIVE_REPLACEMENT.claims_record(record):
		return MARINER_1212_LIVE_REPLACEMENT.consume_record(record, mariner_1212_plan)
	if not is_context and BAYSIDE_1220_LIVE_REPLACEMENT.claims_record(record):
		return BAYSIDE_1220_LIVE_REPLACEMENT.consume_record(record, bayside_1220_plan)
	if not is_context and NORTHPOINT_1239_LIVE_REPLACEMENT.claims_record(record):
		return NORTHPOINT_1239_LIVE_REPLACEMENT.consume_record(record, northpoint_1239_plan)
	if not is_context and BAYSIDE_1222_LIVE_REPLACEMENT.claims_record(record):
		return BAYSIDE_1222_LIVE_REPLACEMENT.consume_record(record, bayside_1222_plan)
	if not is_context and NORTHPOINT_1227_LIVE_REPLACEMENT.claims_record(record):
		return NORTHPOINT_1227_LIVE_REPLACEMENT.consume_record(record, northpoint_1227_plan)
	if not is_context and MARINER_1202_LIVE_REPLACEMENT.claims_record(record):
		return MARINER_1202_LIVE_REPLACEMENT.consume_record(record, mariner_1202_plan)
	if not is_context and NORTHPOINT_1234_LIVE_REPLACEMENT.claims_record(record):
		return NORTHPOINT_1234_LIVE_REPLACEMENT.consume_record(record, northpoint_1234_plan)
	if not is_context and NORTHPOINT_1232_LIVE_REPLACEMENT.claims_record(record):
		return NORTHPOINT_1232_LIVE_REPLACEMENT.consume_record(record, northpoint_1232_plan)
	if not is_context and MARINER_1221_LIVE_REPLACEMENT.claims_record(record):
		return MARINER_1221_LIVE_REPLACEMENT.consume_record(record, mariner_1221_plan)
	if not is_context and NORTHPOINT_1241_LIVE_REPLACEMENT.claims_record(record):
		return NORTHPOINT_1241_LIVE_REPLACEMENT.consume_record(record, northpoint_1241_plan)
	if not is_context and NORTHPOINT_1240_LIVE_REPLACEMENT.claims_record(record):
		return NORTHPOINT_1240_LIVE_REPLACEMENT.consume_record(record, northpoint_1240_plan)
	if not is_context and GATEVIEW_1397_LIVE_REPLACEMENT.claims_record(record):
		return GATEVIEW_1397_LIVE_REPLACEMENT.consume_record(record, gateview_1397_plan)
	if not is_context and BAYSIDE_1226_LIVE_REPLACEMENT.claims_record(record):
		return BAYSIDE_1226_LIVE_REPLACEMENT.consume_record(record, bayside_1226_plan)
	if not is_context and BAYSIDE_1215_LIVE_REPLACEMENT.claims_record(record):
		return BAYSIDE_1215_LIVE_REPLACEMENT.consume_record(record, bayside_1215_plan)
	return _build_unpaired_record(record, is_context)

# Preserve the original source producer and pre-packing channel path unchanged.
# The exact-pair adapter receives this callable, avoiding a builder preload cycle.
func _build_unpaired_record(record: Dictionary, is_context: bool) -> Dictionary:
	var b225_prepared: Dictionary = {}
	if not is_context and D1_B225_LIVE_ATTACHMENT.claims_record(record):
		b225_prepared = D1_B225_LIVE_ATTACHMENT.prepare(record)
		if not bool(b225_prepared.get("ok", false)):
			return b225_prepared
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for index in range(0, record.vertices.size(), 3):
		vertices.append(Vector3(float(record.vertices[index]), float(record.vertices[index + 1]), float(record.vertices[index + 2])))
	for index in range(0, record.normals.size(), 3):
		normals.append(Vector3(float(record.normals[index]), float(record.normals[index + 1]), float(record.normals[index + 2])))
	for index in range(0, record.uvs.size(), 2):
		uvs.append(Vector2(float(record.uvs[index]), float(record.uvs[index + 1])))
	if not b225_prepared.is_empty():
		uvs = D1_B225_LIVE_ATTACHMENT.host_uvs(record, b225_prepared)
		if uvs.size() != vertices.size():
			return {"ok": false, "code": "d1_b225_live_host_uv", "message": "Prepared B225 host UVs did not cover the supplied wall.", "source_keys": record.source_keys}
	# The generated contract stores counterclockwise triangles around its
	# outward normals. Godot treats clockwise winding as front-facing, so adapt
	# every triplet once at runtime while preserving the generated bytes/normals.
	for index in range(0, record.indices.size(), 3):
		var first := int(record.indices[index])
		var second := int(record.indices[index + 1])
		var third := int(record.indices[index + 2])
		# The old western span is a disconnected component west of X=500 m.
		# Its imported replacement is owned by world_root.tscn; retain the modern
		# eastern-span component from the same generated context record.
		if is_context and str(record.feature_kind) == "bay_bridge" \
		and vertices[first].x < WESTERN_BRIDGE_REPLACEMENT_MAX_X_M \
		and vertices[second].x < WESTERN_BRIDGE_REPLACEMENT_MAX_X_M \
		and vertices[third].x < WESTERN_BRIDGE_REPLACEMENT_MAX_X_M:
			continue
		indices.append(first)
		indices.append(third)
		indices.append(second)

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	if not uvs.is_empty():
		arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	# Land and area records use the shared ground-cover families; parking,
	# overlays, roads, buildings and context keep their generated material.
	# The ground-cover shader needs UVs and tangents, so a record without UVs
	# falls back to the builder's own material.
	var ground_family := "" if uvs.is_empty() else GROUND_COVER.family_for(record, is_context)
	if ground_family == "" and not uvs.is_empty() and not is_context and str(record.material_key) == SHORELINE_RIPRAP_OVERLAY:
		ground_family = ShorelineBuilder.BAND_GROUND_FAMILY
	if (POLYHAVEN_MATERIAL_TEXTURE_SET.has(str(record.material_key)) or ground_family != "") and not uvs.is_empty():
		arrays[Mesh.ARRAY_TANGENT] = _tangents_for(vertices, normals, uvs, indices)
	var placeholder_material: Material
	if STREET_DECAL_MATERIALS.has(str(record.material_key)):
		placeholder_material = _street_decal_material(str(record.material_key))
	elif str(record.material_key) == PARK_BED_MATERIAL_KEY and not uvs.is_empty():
		placeholder_material = _park_bed_material()
	elif STREET_GROUND_SURFACES.has(str(record.material_key)) and not uvs.is_empty():
		placeholder_material = _street_ground_material(str(record.material_key))
	elif PROMENADE_PAVEMENT.has(str(record.material_key)):
		placeholder_material = _promenade_pavement_material(str(record.material_key))
	elif PARK_PAVING_MATERIALS.has(str(record.material_key)) and not uvs.is_empty():
		placeholder_material = _park_paving_material(str(record.material_key))
	elif str(record.material_key) == SHORELINE_ROCK_OVERLAY and not is_context:
		placeholder_material = ShorelineBuilder.rock_ground_material()
	elif ground_family == GROUND_COVER.PAVED:
		placeholder_material = _material_for("major_area_court", "major_area", false)
	elif ground_family != "":
		placeholder_material = GROUND_COVER.material(ground_family)
	else:
		placeholder_material = _material_for(str(record.material_key), str(record.feature_kind), is_context)
	# Quiet provisional finish for generated roof slabs only. Keep the authored
	# roof inputs and Poly Haven cache intact; neither directional map is used.
	if not is_context and str(record.feature_kind) in ["building_roof", "building_part_roof"]:
		if _generic_roof_material == null:
			_generic_roof_material = StandardMaterial3D.new()
			_generic_roof_material.resource_name = "generic_roof_provisional"
			_generic_roof_material.albedo_color = Color(.62, .62, .59)
			_generic_roof_material.roughness = .96
		placeholder_material = _generic_roof_material
	# Only this actual LAND host receives the B2 cosmetic material pass.
	# Duplicate before partitioning; retain cached base and all node/native identity.
	if not is_context and str(record.object_key) == "land:w26767313:x_0__z_2" and str(record.feature_kind) == "land_ground":
		if placeholder_material.next_pass != null:
			return {"ok": false, "code": "b2_frontage_existing_pass", "message": "B2 LAND already has a next pass; refusing to overwrite it.", "source_keys": record.source_keys}
		placeholder_material = placeholder_material.duplicate() as Material
		placeholder_material.next_pass = BUILDING_2_HERO_MODEL.frontage_material()
	var surface_plan: Dictionary
	if not b225_prepared.is_empty():
		surface_plan = D1_B225_LIVE_ATTACHMENT.partition_host(record, indices, placeholder_material, b225_prepared)
	elif not is_context:
		surface_plan = ACCEPTED_MATERIAL_RUN_TRIALS.partition(record, indices, placeholder_material)
	else:
		surface_plan = {"ok": true, "surfaces": [{"name": "generated_record", "indices": indices, "material": placeholder_material}]}
	if not bool(surface_plan.get("ok", false)):
		return surface_plan
	var mesh := ArrayMesh.new()
	for surface_value: Variant in surface_plan.surfaces:
		var surface := surface_value as Dictionary
		arrays[Mesh.ARRAY_INDEX] = surface.indices as PackedInt32Array
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var surface_index := mesh.get_surface_count() - 1
		mesh.surface_set_name(surface_index, str(surface.name))
		mesh.surface_set_material(surface_index, surface.material as Material)

	var root := Node3D.new()
	root.name = str(record.object_key).validate_node_name()
	root.set_meta("derived_object_key", str(record.object_key))
	root.set_meta("source_keys", record.source_keys.duplicate())
	root.set_meta("feature_kind", str(record.feature_kind))
	# A visible-only surface draped over the land (road, path, area, overlay):
	# its footprint and lift, so visuals can stand on what is drawn rather than
	# on the land collision under it (VisibleGround; the player character's feet).
	if not is_context and record.has("surface_bias_m") and str(record.collision_kind) == "none":
		var footprint := PackedVector2Array()
		for index_value: int in indices:
			footprint.append(Vector2(vertices[index_value].x, vertices[index_value].z))
		root.set_meta(VisibleGround.FOOTPRINT_META, footprint)
		root.set_meta(VisibleGround.LIFT_META, float(record.surface_bias_m))
	if not b225_prepared.is_empty() and surface_plan.has("metadata"):
		root.set_meta("d1_b225_host_partition", (surface_plan.metadata as Dictionary).duplicate(true))
	elif surface_plan.has("metadata"):
		root.set_meta("accepted_material_run_trial", (surface_plan.metadata as Dictionary).duplicate(true))
	var mesh_instances := 0
	var surfaces := 0
	# Street-kerb support ramps are collision only, and the marina basin is the bay
	# water's: no visible mesh.
	if str(record.feature_kind) != "street_kerb_support" and str(record.material_key) != MARINA_BASIN_MATERIAL_KEY:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = "Mesh"
		mesh_instance.mesh = mesh
		mesh_instance.layers = RENDER_BUILDING_WALL if str(record.receiver_kind) == "building_wall" else RENDER_WORLD_VISIBLE
		mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF \
			if str(record.feature_kind) in ["road_path", "major_area", "terrain_overlay", "street_paint"] \
			else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		root.add_child(mesh_instance)
		mesh_instances = 1
		surfaces = mesh.get_surface_count()
	var triangle_count := int(indices.size() / 3)

	if not is_context and str(record.collision_kind) == "world_solid":
		var body := StaticBody3D.new()
		body.name = "Collision"
		body.collision_layer = PHYSICS_WORLD_SOLID
		if bool(record.opaque):
			body.collision_layer |= PHYSICS_SPRAY_SURFACE
		body.collision_mask = 0
		body.set_meta("receiver_kind", str(record.receiver_kind))
		body.set_meta("opaque", bool(record.opaque))
		body.set_meta("derived_object_key", str(record.object_key))
		body.set_meta("source_keys", record.source_keys.duplicate())
		if str(record.receiver_kind) == "building_wall":
			body.add_to_group("spray_receiver_wall")
		var faces := PackedVector3Array()
		for index_value: int in indices:
			faces.append(vertices[index_value])
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(faces)
		shape.set_meta("receiver_kind", str(record.receiver_kind))
		shape.set_meta("opaque", bool(record.opaque))
		shape.set_meta("derived_object_key", str(record.object_key))
		shape.set_meta("source_keys", record.source_keys.duplicate())
		var collision_shape := CollisionShape3D.new()
		collision_shape.name = "Shape"
		collision_shape.shape = shape
		body.add_child(collision_shape)
		root.add_child(body)

	if not is_context and PANEL_HALL_FACADE.matches_record(record):
		var hall_result := PANEL_HALL_FACADE.build(record)
		if not bool(hall_result.get("ok", false)):
			root.free()
			return hall_result
		root.add_child(hall_result.node as Node3D)
		mesh_instances += int(hall_result.mesh_instances)
		surfaces += int(hall_result.surfaces)
		triangle_count += int(hall_result.triangles)

	if not is_context and YMCA_ENTRY_SITE.matches_record(record):
		var entry_result := YMCA_ENTRY_SITE.build(record)
		if not bool(entry_result.get("ok", false)):
			root.free()
			return entry_result
		root.add_child(entry_result.node as Node3D)
		mesh_instances += int(entry_result.mesh_instances)
		surfaces += int(entry_result.surfaces)
		triangle_count += int(entry_result.triangles)

	# B225 keeps the exact generated wall MeshInstance and its already-created
	# sole collision/spray owner. Only after those ordinary host nodes exist do
	# we attach the reviewed, receiver-relative two-batch render detail.
	if not b225_prepared.is_empty():
		var b225_result := D1_B225_LIVE_ATTACHMENT.build_prepared(record, b225_prepared)
		if not bool(b225_result.get("ok", false)):
			root.free()
			return b225_result
		root.add_child(b225_result.node as Node3D)
		root.set_meta("d1_b225_live_attachment", (b225_result.metadata as Dictionary).duplicate(true))
		mesh_instances += int(b225_result.mesh_instances)
		surfaces += int(b225_result.surfaces)
		triangle_count += int(b225_result.triangles)
	return {
		"ok": true,
		"node": root,
		"mesh_instances": mesh_instances,
		"surfaces": surfaces,
		"triangles": triangle_count,
	}


## The shared material for street paint (opaque, cut out where worn) or asphalt wear (blended).
func _street_decal_material(material_key: String) -> ShaderMaterial:
	if _street_decal_materials.has(material_key):
		return _street_decal_materials[material_key]
	var decal: Dictionary = STREET_DECAL_MATERIALS[material_key]
	var material := ShaderMaterial.new()
	material.resource_name = material_key
	material.shader = decal.shader as Shader
	var textures: Dictionary = decal.textures
	for parameter: String in textures:
		material.set_shader_parameter(parameter, textures[parameter])
	_street_decal_materials[material_key] = material
	return material


## The shared material for a raised street-ground top: its generated texture, untinted.
func _street_ground_material(material_key: String) -> StandardMaterial3D:
	if _street_ground_materials.has(material_key):
		return _street_ground_materials[material_key]
	var surface: Dictionary = STREET_GROUND_SURFACES[material_key]
	var material := StandardMaterial3D.new()
	material.resource_name = material_key
	material.albedo_texture = surface.albedo as Texture2D
	material.albedo_color = surface.get("tint", Color.WHITE) as Color
	material.roughness = float(surface.roughness)
	material.metallic_specular = float(surface.get("specular", 0.5))
	var uv_scale := float(surface.uv_scale)
	material.uv1_scale = Vector3(uv_scale, uv_scale, 1.0)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	material.set_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT, true)
	_street_ground_materials[material_key] = material
	return material


## The shared material for the promenade's old road or fresh seal.
func _promenade_pavement_material(material_key: String) -> ShaderMaterial:
	if _street_ground_materials.has(material_key):
		return _street_ground_materials[material_key]
	var pavement: Dictionary = PROMENADE_PAVEMENT[material_key]
	var material := ShaderMaterial.new()
	material.resource_name = material_key
	material.shader = PROMENADE_PAVEMENT_SHADER
	material.set_shader_parameter("aggregate", PROMENADE_AGGREGATE)
	material.set_shader_parameter("tile_m", pavement.tile_m)
	material.set_shader_parameter("contrast", pavement.contrast)
	material.set_shader_parameter("tone", pavement.tone)
	material.set_shader_parameter("wear", pavement.wear)
	_street_ground_materials[material_key] = material
	return material


## The shared material for a park's planted beds.
func _park_bed_material() -> ShaderMaterial:
	if _park_bed == null:
		_park_bed = ShaderMaterial.new()
		_park_bed.resource_name = PARK_BED_MATERIAL_KEY
		_park_bed.shader = PARK_BED_SHADER
		_park_bed.set_shader_parameter("mulch", PARK_BED_MULCH)
		_park_bed.set_shader_parameter("uv_scale", PARK_BED_UV_SCALE)
	return _park_bed


## The shared material for a painted park plaza.
func _park_paving_material(material_key: String) -> ShaderMaterial:
	if _park_paving_materials.has(material_key):
		return _park_paving_materials[material_key]
	var paving: Dictionary = PARK_PAVING_MATERIALS[material_key]
	var material := ShaderMaterial.new()
	material.resource_name = material_key
	material.shader = PARK_PAVING_SHADER
	for parameter: String in paving:
		material.set_shader_parameter(parameter, paving[parameter])
	material.set_shader_parameter("detail", POLYHAVEN_TEXTURE_SETS.concrete_floor_03.roughness)
	_park_paving_materials[material_key] = material
	return material


func _material_for(material_key: String, feature_kind: String, is_context: bool) -> StandardMaterial3D:
	var cache_key := "%s|%s|%s" % [material_key, feature_kind, is_context]
	if _materials.has(cache_key):
		return _materials[cache_key]
	var material := StandardMaterial3D.new()
	material.resource_name = material_key
	material.albedo_color = _color_for(material_key, feature_kind, is_context)
	material.roughness = 0.92
	# Context remains double-sided because it is distant, non-colliding scenery.
	if is_context:
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if feature_kind == "road_path" or material_key in ["street_parking", "major_area_paved"]:
		material.roughness = 1.0
	if material_key == "context_bay_bridge":
		var palette := Image.create(BAY_BRIDGE_PALETTE.size(), 1, false, Image.FORMAT_RGB8)
		for index in BAY_BRIDGE_PALETTE.size():
			palette.set_pixel(index, 0, BAY_BRIDGE_PALETTE[index])
		material.albedo_texture = ImageTexture.create_from_image(palette)
		material.albedo_color = Color.WHITE
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_apply_polyhaven_textures(material, material_key)
	_materials[cache_key] = material
	return material


func _apply_polyhaven_textures(material: StandardMaterial3D, material_key: String) -> void:
	if not POLYHAVEN_MATERIAL_TEXTURE_SET.has(material_key):
		return
	var texture_set_key := str(POLYHAVEN_MATERIAL_TEXTURE_SET[material_key])
	var texture_set: Dictionary = POLYHAVEN_TEXTURE_SETS[texture_set_key]
	var albedo_texture := texture_set.albedo as Texture2D
	var normal_texture := texture_set.normal as Texture2D
	var roughness_texture := texture_set.roughness as Texture2D
	assert(albedo_texture != null and normal_texture != null and roughness_texture != null, "Approved Poly Haven texture set %s did not load." % texture_set_key)
	material.albedo_color = _polyhaven_tint_for(material_key, material.albedo_color)
	material.albedo_texture = albedo_texture
	material.normal_enabled = true
	material.normal_texture = normal_texture
	material.normal_scale = float(texture_set.get("normal_strength", POLYHAVEN_DEFAULT_NORMAL_STRENGTH))
	material.roughness_texture = roughness_texture
	var uv_scale := 10.0 / float(texture_set.repeat_dimension_m)
	material.uv1_scale = Vector3(uv_scale, uv_scale, 1.0)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	material.set_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT, true)
	material.heightmap_enabled = false


## Paving tints multiply the Poly Haven maps. Roads, parking lanes and parking
## lots read as the photographed asphalt: neutral to slightly cool, about
## 38-41 % grey in the dated Sep 2025 Treasure Island Road and Building 1 views,
## one tone across a lot and its aisles. Walks and hard courts stay lighter.
func _polyhaven_tint_for(material_key: String, fallback: Color) -> Color:
	match material_key:
		"road_path", "street_parking", "major_area_paved":
			return Color(0.94, 0.95, 0.95)
		"road_path_pedestrian":
			return Color(1.12, 1.20, 1.28)
		"major_area_court":
			return Color(0.70, 0.76, 0.74)
		"street_gutter":
			# Gutter pans: smoother, slightly darker concrete; cooled so the
			# warm source map does not read pink beside the asphalt.
			return Color(0.84, 0.92, 0.98)
		"context_ybi":
			return Color("d2d8cb")
		"building_wall", "building_part_wall":
			return Color("f7f2eb")
		"building_roof", "building_part_roof":
			return Color("d8d4d0")
	return fallback


func _tangents_for(vertices: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array) -> PackedFloat32Array:
	var tangent_sums := PackedVector3Array()
	var bitangent_sums := PackedVector3Array()
	tangent_sums.resize(vertices.size())
	bitangent_sums.resize(vertices.size())
	for offset in range(0, indices.size(), 3):
		var first := indices[offset]
		var second := indices[offset + 1]
		var third := indices[offset + 2]
		var edge_one := vertices[second] - vertices[first]
		var edge_two := vertices[third] - vertices[first]
		var uv_one := uvs[second] - uvs[first]
		var uv_two := uvs[third] - uvs[first]
		var determinant := uv_one.x * uv_two.y - uv_one.y * uv_two.x
		if absf(determinant) <= 0.00000001:
			continue
		var inverse := 1.0 / determinant
		var tangent := (edge_one * uv_two.y - edge_two * uv_one.y) * inverse
		var bitangent := (edge_two * uv_one.x - edge_one * uv_two.x) * inverse
		for vertex_index in [first, second, third]:
			tangent_sums[vertex_index] += tangent
			bitangent_sums[vertex_index] += bitangent

	var tangents := PackedFloat32Array()
	tangents.resize(vertices.size() * 4)
	for vertex_index in vertices.size():
		var normal := normals[vertex_index].normalized()
		var tangent := tangent_sums[vertex_index] - normal * normal.dot(tangent_sums[vertex_index])
		if tangent.length_squared() <= 0.00000001:
			var reference_axis := Vector3.UP if absf(normal.y) < 0.999 else Vector3.RIGHT
			tangent = reference_axis.cross(normal)
		tangent = tangent.normalized()
		var handedness := -1.0 if normal.cross(tangent).dot(bitangent_sums[vertex_index]) < 0.0 else 1.0
		var tangent_offset := vertex_index * 4
		tangents[tangent_offset] = tangent.x
		tangents[tangent_offset + 1] = tangent.y
		tangents[tangent_offset + 2] = tangent.z
		tangents[tangent_offset + 3] = handedness
	return tangents


func _color_for(material_key: String, feature_kind: String, is_context: bool) -> Color:
	if is_context:
		if feature_kind == "ybi":
			return Color("66765c")
		if feature_kind == "boundary_attached_visual":
			# A pier deck draws its concrete (STREET_GROUND_SURFACES); without UVs,
			# that concrete's mean. The marina basin draws nothing (the bay water's).
			return Color("908e7c")
		return Color("bbb7af")
	match feature_kind:
		"land_ground":
			return Color("8ca777")
		"road_path":
			if material_key == "road_path_pedestrian":
				return Color("8b918e")
			return Color("555b60")
		"building_wall", "building_part_wall":
			return Color("c6b79f")
		"building_roof", "building_part_roof":
			return Color("827468")
		"terrain_overlay":
			if "sand" in material_key:
				return Color("d7c78e")
			if "wet" in material_key:
				return Color("78a49a")
			if "breakwater" in material_key:
				return Color("777a73")
			return Color("8fb486")
		"major_area":
			if "paved" in material_key:
				return Color("707573")
			if "amenity" in material_key:
				return Color("a7a597")
			if "landuse" in material_key:
				return Color("a99b78")
			return Color("79a66d")
		"boundary_blocker":
			return Color(0.0, 0.0, 0.0, 0.0)
	return Color("aeb4ad")


func _parent_key_for_feature(feature_kind: String) -> String:
	if feature_kind == "road_path" or feature_kind.begins_with("street_"):
		return "roads"
	if feature_kind.begins_with("building_") or feature_kind.begins_with("building_part_"):
		return "buildings"
	return "ground"
