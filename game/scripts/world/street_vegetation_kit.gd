extends RefCounted
## The street-vegetation kit: generated trees, grasses, perennials and shrubs
## for PlayableWorld/StreetDetail/Vegetation. street_vegetation_builder.gd places
## them from the vegetation rows tools/lib/street-vegetation-generation.mjs
## writes; this kit draws them. It grew out of the 2026-11-02 tree shootout's
## code-generated variant A, which the owner chose.
##
## Only species photographed or recorded on Treasure Island (dated evidence in
## tools/config/street-detail-zones.json and data/street_detail/set_pieces.json):
##   mexican_fan_palm  Washingtonia robusta: a slim grey ringed trunk, slightly
##                     curved, swelling to a rooted foot; a small tight grey-green
##                     crown over a short brown skirt of dead fronds.
##   canary_date_palm  Phoenix canariensis: a thick trunk of diamond leaf scars,
##                     the trimmed "pineapple" knob and a full arching crown.
##   monterey_cypress  Hesperocyparis macrocarpa: the wind-shaped, flat-topped
##                     old tree, and dense young conical ones.
##   clump_grass       the clumping ornamental grasses of the mulch beds.
## Cityside Park's planting (Phase 1, opened Sep 2025; CMG and TIDA site plans,
## Google Maps contributor photos Sep 2025-Jun 2026 and iNaturalist records in
## the park 2025-09 to 2026-10), drawn as it stands in November, late in the dry
## season, when most flowering is over:
##   sydney_blue_gum_young  Eucalyptus saligna in the windrow plazas' double rows.
##   island_oak_young       Quercus tomentella, young trees in the beds.
##   pacific_reedgrass, dense_sedge, rush, bronze_clump_grass: the stormwater
##                     beds' grasses, sedges and rushes, in clump_grass's look.
##   seaside_daisy, sea_thrift, seaside_woolly_sunflower, california_sagebrush,
##   shrubby_sage, california_buckwheat, blue_eyed_grass, seep_monkeyflower,
##   dune_tansy        the strand garden's and the beds' perennials and shrubs.
##   white_umbel_perennial  a yarrow-like plant with flat white heads seen in a
##                     CMG photo of the strand garden; its species is not
##                     confirmed, so the form is inference.
## The island-wide rollout's trees, shrubs and hedges (vegetation species pass,
## 2026-11-05; dated Street View crops p1-p6, c2-c4, b1-b8, n1-n2, s1-s3, h1-h2
## kept with the vegetation-inventory work notes, outside Git):
##   monterey_pine     Pinus radiata: a dense, rounded-to-domed crown of brush-like
##                     needle tufts on a short, thick, bent trunk of dark furrowed
##                     bark; the residential form branching low (Keppler, Mar 2025)
##                     and the wind-pruned low domes of the SFFD frontage (9th
##                     Street, Sep 2025).
##   spreading_broadleaf  the commonest big residential tree, its species
##                     unresolved, so the photographed form: a short thick grey
##                     trunk forking low into wide sinuous limbs under a layered,
##                     cloud-like crown of drooping clumps of narrow glossy olive
##                     leaves with reddish-bronze patches; old (leaning, very wide)
##                     and mid (round) forms (Gateview and Northpoint, Mar and Sep
##                     2025).
##   nz_christmas_tree Metrosideros excelsa: smooth pale multi-stem trunks leaning
##                     from near the ground under a very dense dark crown with a
##                     few red brush flowers (Sturgeon, Mar 2025).
##   eucalyptus_mature the Job Corps entrance tree (the owner's identification,
##                     2026-11-05; 2025 gallery photo): two or three tall trunks
##                     under an open, irregular crown of drooping tassels, the
##                     young gum's generator grown up.
##   norfolk_island_pine  Araucaria heterophylla, young: whorled tiers of level
##                     branches with upturned soft branchlets (Chinook, Mar 2025).
##   indian_hawthorn, pittosporum_tobira  the Avenue N seawall's mounded shrubs:
##                     leathery leaves with a few pale pink flower clusters, and
##                     glossy rosettes (Nov 2025).
##   red_tip_shrub, conical_shrub  two more Avenue N forms whose species are
##                     unresolved: a slender upright shrub with red new growth,
##                     and a narrow conical one of olive leaves with bronze tips.
##   nz_flax           a dark red New Zealand flax (Phormium) fan of stiff straps,
##                     as in the Mersea lot's planters (Sep 2025).
##   clipped_hedge     a hedge strip along a line: the residential small-leaved,
##                     flat-topped, rounded hedge on leggy dark stems (Mariner,
##                     Mar 2025), and a solid glossy box (Job Corps, 2025 gallery).
##                     Not a point prop: hedge_into() lays it along a polyline.
## Each prop has a few fixed variants whose meshes every instance shares; an
## instance only turns about +Y and scales uniformly. A species' variants run
## from its smallest (0) to its largest. Shapes and sizes are production
## inference from the photos, not survey data.
##
## Composing a bed of the low plants (what the reviewed Cityside demonstrator
## beds used; the zone placer's own rules decide the real ones): the shrubs
## (woolly sunflower, sagebrush, sage, buckwheat) in drifts of 3-7 set inward,
## about 0.65 x their summed widths apart so the crowns overlap, with more
## sagebrush and woolly sunflower than the rest for the strand garden's grey
## mass; the grass accents (reedgrass, rush, bronze) in ones to threes repeated
## through the bed, or as their drift (variant 3) in the stormwater beds; then
## the groundcovers (dense_sedge, whose variants 3 and 4 are drifts, and
## seaside_daisy, blue_eyed_grass and sea_thrift, whose variant 3 is) filling the
## bare ground, largest variant first, about 0.55 x their summed widths apart, to
## about 80-85 % canopy cover with a few 0.35-0.5 m gaps; thrift and
## blue-eyed grass in the gravel; rows within 0.1 m of a bed's edge, so the
## wider plants spill over it; variants mixed and scaled 0.85-1.15.
##
## Trees have LOD0, LOD1 and a far level: a palm keeps a low trunk under a
## camera-facing crown impostor, a cypress, gum or oak becomes one impostor; the
## images are baked from LOD0 by tools/vegetation/bake_impostors.gd. The rollout's
## shrubs and flax have the same three levels (their far impostor ends at a short
## range), and a hedge's far level is its plain core. Cityside's low plants
## (grasses, perennials, shrubs) have one level that dissolves away before its
## range ends. Collision is the trunk only (capsules), so crowns never stop a
## jetpack flight; shrubs, flax, hedges and low plants have none.
## Units are metres. A prototype's origin is the foot of its trunk on the visible
## ground; the trunk runs on BURY_M below it, so a foot on slightly uneven ground
## sinks in a little instead of showing a gap.

const TEXTURES := "res://game/resources/textures/world/vegetation/"
const BARK_SHADER := preload("res://game/resources/materials/world/vegetation/vegetation_bark.gdshader")
const FOLIAGE_SHADER := preload("res://game/resources/materials/world/vegetation/vegetation_foliage.gdshader")
const IMPOSTOR_SHADER := preload("res://game/resources/materials/world/vegetation/vegetation_impostor.gdshader")

const BURY_M := 0.35
## A mulch pit round a tree in paving lies this far above the paving's plane
## (street_vegetation_builder.gd draws it), clear of the paving's decals.
const WELL_LIFT_M := 0.015
## The uniform scale and foot settling the generator may give an instance
## (tools/lib/street-vegetation-generation.mjs).
## Plain floats, not a Vector2: its 32-bit 0.8 is a hair above 0.8 and would
## turn away a generated scale of exactly 0.8.
const SCALE_MIN := 0.8
const SCALE_MAX := 1.25
const MAX_FOOT_SPREAD_M := 0.25
const MAX_LIFT_M := 0.6

# Atlas cells as UV rects; tools/vegetation/prepare_textures.gd writes this layout.
const FAN_LIVE := Rect2(0.0, 0.0, 0.5, 0.5)
const FAN_OLD := Rect2(0.5, 0.5, 0.5, 0.5)
const FAN_DEAD := [Rect2(0.5, 0.0, 0.25, 0.5), Rect2(0.75, 0.0, 0.25, 0.5)]
## Inset a little so mipmaps don't pull the neighbouring cells' transparency
## into the boot where it wraps around the trunk.
const FAN_BOOT := Rect2(0.004, 0.504, 0.492, 0.492)
## The fan leaf's hastula (where the blade meets the petiole), from the top of its cell.
const FAN_HASTULA := 0.77
const CANARY_FRONDS := [Rect2(0.0, 0.0, 0.5, 1.0), Rect2(0.5, 0.0, 0.5, 1.0)]
const CYPRESS_CLUMP := Rect2(0.0, 0.0, 0.5, 1.0)
const CYPRESS_PLATE := Rect2(0.5, 0.0, 0.5, 1.0)
const GRASS_CELLS := {"green": Rect2(0.0, 0.0, 0.5, 1.0), "straw": Rect2(0.5, 171.0 / 512.0, 0.5, 341.0 / 512.0)}
## Low-plant atlas cells: name -> [material, UV rect]. The meadow atlas
## (2048 x 2048) holds whole clumps, shrubs and flower stalks seen from the
## side, drawn on crossed upright cards, and the litter; the perennial atlas
## (2048 x 1536) holds face-on clusters of foliage, drawn on the cards round a
## mound, and the top views drawn on caps and domes.
## tools/vegetation/prepare_textures.gd packs both.
const LOW_CELLS := {
	"reedgrass": ["meadow", Rect2(0.0, 0.0, 0.25, 0.25)],
	"sedge": ["meadow", Rect2(0.25, 0.0, 0.25, 0.25)],
	"rush": ["meadow", Rect2(0.5, 0.0, 0.25, 0.25)],
	"bronze": ["meadow", Rect2(0.75, 0.0, 0.25, 0.25)],
	"blue_eyed": ["meadow", Rect2(0.0, 0.25, 0.25, 0.25)],
	"thrift_stalks": ["meadow", Rect2(0.25, 0.25, 0.25, 0.25)],
	"umbel_stalks": ["meadow", Rect2(0.5, 0.25, 0.25, 0.25)],
	"buckwheat_mound": ["meadow", Rect2(0.75, 0.25, 0.25, 0.25)],
	"woolly_stalks": ["meadow", Rect2(0.0, 0.5, 0.25, 0.25)],
	"monkey_stalks": ["meadow", Rect2(0.25, 0.5, 0.25, 0.25)],
	"tansy_stalks": ["meadow", Rect2(0.5, 0.5, 0.25, 0.25)],
	"buckwheat_stalks": ["meadow", Rect2(0.75, 0.5, 0.25, 0.25)],
	"sagebrush_wands": ["meadow", Rect2(0.0, 0.75, 0.25, 0.25)],
	"sage_stems": ["meadow", Rect2(0.25, 0.75, 0.25, 0.25)],
	"litter": ["meadow", Rect2(0.5, 0.75, 0.25, 0.25)],
	"daisy": ["perennial", Rect2(0.0, 0.0, 0.25, 1.0 / 3.0)],
	"thrift": ["perennial", Rect2(0.25, 0.0, 0.25, 1.0 / 3.0)],
	"woolly": ["perennial", Rect2(0.5, 0.0, 0.25, 1.0 / 3.0)],
	"sagebrush": ["perennial", Rect2(0.75, 0.0, 0.25, 1.0 / 3.0)],
	"yarrow": ["perennial", Rect2(0.0, 1.0 / 3.0, 0.25, 1.0 / 3.0)],
	"buckwheat": ["perennial", Rect2(0.25, 1.0 / 3.0, 0.25, 1.0 / 3.0)],
	"monkeyflower": ["perennial", Rect2(0.5, 1.0 / 3.0, 0.25, 1.0 / 3.0)],
	"tansy": ["perennial", Rect2(0.75, 1.0 / 3.0, 0.25, 1.0 / 3.0)],
	"tussock_top": ["perennial", Rect2(0.0, 2.0 / 3.0, 0.25, 1.0 / 3.0)],
	"bronze_top": ["perennial", Rect2(0.25, 2.0 / 3.0, 0.25, 1.0 / 3.0)],
	"daisy_flowers": ["perennial", Rect2(0.5, 2.0 / 3.0, 0.25, 1.0 / 3.0)],
}
## The young trees' foliage atlas: a hanging spray of gum leaves, a cluster of oak leaves.
const GUM_SPRAY := Rect2(0.0, 0.0, 0.5, 1.0)
const OAK_CLUSTER := Rect2(0.5, 0.0, 0.5, 1.0)
## The pine's atlas: a branch end of needle tufts from the side, and a face-on
## cluster of tufts from outside the crown.
const PINE_TUFTS := Rect2(0.0, 0.0, 0.5, 1.0)
const PINE_FACE := Rect2(0.5, 0.0, 0.5, 1.0)
## The broadleaf atlas: the spreading broadleaf's drooping olive clump and its
## bronze-tipped clump; the Christmas tree's leaf rosettes, plain and in flower.
const BROADLEAF_CLUMP := Rect2(0.0, 0.0, 0.5, 0.5)
const BROADLEAF_BRONZE := Rect2(0.5, 0.0, 0.5, 0.5)
const CHRISTMAS_CLUMP := Rect2(0.0, 0.5, 0.5, 0.5)
const CHRISTMAS_FLOWERS := Rect2(0.5, 0.5, 0.5, 0.5)
## The set pieces' atlas: a eucalyptus's drooping tassel (a tall cell, its twig
## along the top edge), and a Norfolk Island pine branch from above and from the
## side (its axis along the cell's middle, from the trunk on the left).
const EUCALYPTUS_TASSEL := Rect2(0.0, 0.0, 0.5, 1.0)
const NORFOLK_TOP := Rect2(0.5, 0.0, 0.5, 0.5)
const NORFOLK_SIDE := Rect2(0.5, 0.5, 0.5, 0.5)
## The shrub atlas (2048 x 1024, 512 x 512 cells): face-on foliage clusters of
## the Avenue N shrubs, the hedges' sprigs and bare stems seen from the side,
## and one dark red flax leaf.
const SHRUB_CELLS := {
	"hawthorn": Rect2(0.0, 0.0, 0.25, 0.5),
	"pittosporum": Rect2(0.25, 0.0, 0.25, 0.5),
	"red_tip": Rect2(0.5, 0.0, 0.25, 0.5),
	"upright_shrub": Rect2(0.75, 0.0, 0.25, 0.5),
	"hedge_sprigs": Rect2(0.0, 0.5, 0.25, 0.5),
	"glossy_sprigs": Rect2(0.25, 0.5, 0.25, 0.5),
	"hedge_stems": Rect2(0.5, 0.5, 0.25, 0.5),
	"flax_leaf": Rect2(0.75, 0.5, 0.25, 0.5),
}

## Side of one repeat of each square bark texture.
const FAN_BARK_M := 0.6
const CANARY_BARK_M := 0.8
const CANARY_KNOB_M := 0.55
const CYPRESS_BARK_M := 1.0
const GUM_BARK_M := 0.7
const OAK_BARK_M := 0.5
const PINE_BARK_M := 1.0
const BROADLEAF_BARK_M := 0.9
const CHRISTMAS_BARK_M := 0.8
const EUCALYPTUS_BARK_M := 1.2
## A hedge's clipped leaf surface repeats every HEDGE_TILE_M along and up it.
const HEDGE_TILE_M := 0.7

## How far a trunk top sways downwind per metre of height (the wind shader's
## UV2.x): palms rock, the cypress barely moves.
const PALM_SWAY := 0.011
const CYPRESS_SWAY := 0.0025
## The young gums' slender trunks rock in the wind (ph10, Sep 2025); the oaks are stiff.
const GUM_SWAY := 0.012
const OAK_SWAY := 0.004
## The big pines and broadleaves barely rock; the tall eucalyptus and the young
## Norfolk Island pine sway more; shrubs only flutter.
const PINE_SWAY := 0.003
const BROADLEAF_SWAY := 0.003
const MATURE_GUM_SWAY := 0.007
const NORFOLK_SWAY := 0.008
const SHRUB_SWAY := 0.008

## Variants. height is the trunk from the ground to where the crown (fan palm)
## or the knob (date palm) starts. Avenue of the Palms fan palms are young
## (variants 0-3, Sep and Nov 2025 photos); the tall old ones stand at
## Building 1 (4-5, Sep 2025 and Jul 2023 photos).
const FAN_PALMS := [
	{"seed": 11, "height": 4.6, "lean": 0.16, "bow": 0.07, "radius_low": 0.17, "radius_top": 0.15, "swell": 0.05, "flare": 0.12, "roots": 16, "fronds": 32, "petiole": 0.58, "blade": 1.0, "boot": 0.7, "skirt": 0.62, "skirt_cards": 12},
	{"seed": 12, "height": 5.4, "lean": 0.24, "bow": 0.1, "radius_low": 0.18, "radius_top": 0.155, "swell": 0.06, "flare": 0.13, "roots": 16, "fronds": 33, "petiole": 0.6, "blade": 1.03, "boot": 0.75, "skirt": 0.7, "skirt_cards": 13},
	{"seed": 13, "height": 6.2, "lean": 0.3, "bow": 0.12, "radius_low": 0.185, "radius_top": 0.155, "swell": 0.07, "flare": 0.13, "roots": 18, "fronds": 34, "petiole": 0.62, "blade": 1.06, "boot": 0.8, "skirt": 0.78, "skirt_cards": 13},
	{"seed": 14, "height": 7.0, "lean": 0.34, "bow": 0.14, "radius_low": 0.19, "radius_top": 0.16, "swell": 0.08, "flare": 0.14, "roots": 18, "fronds": 34, "petiole": 0.64, "blade": 1.08, "boot": 0.85, "skirt": 0.85, "skirt_cards": 14},
	{"seed": 15, "height": 15.5, "lean": 0.45, "bow": 0.22, "radius_low": 0.2, "radius_top": 0.165, "swell": 0.1, "flare": 0.16, "roots": 20, "fronds": 36, "petiole": 0.72, "blade": 1.14, "boot": 1.1, "skirt": 1.15, "skirt_cards": 16},
	{"seed": 16, "height": 18.5, "lean": 0.6, "bow": 0.28, "radius_low": 0.21, "radius_top": 0.165, "swell": 0.11, "flare": 0.17, "roots": 20, "fronds": 36, "petiole": 0.74, "blade": 1.16, "boot": 1.2, "skirt": 1.25, "skirt_cards": 16},
]
## Building 1's date palms range from a low one by the forecourt corner to the
## tall row along Treasure Island Road (Sep 2025 photos).
const CANARY_PALMS := [
	{"seed": 21, "height": 3.6, "lean": 0.08, "radius_low": 0.4, "radius_top": 0.38, "flare": 0.16, "knob": 1.35, "knob_radius": 0.58, "fronds": 66, "frond": 4.4},
	{"seed": 22, "height": 5.6, "lean": 0.12, "radius_low": 0.41, "radius_top": 0.38, "flare": 0.17, "knob": 1.45, "knob_radius": 0.6, "fronds": 68, "frond": 4.7},
	{"seed": 23, "height": 7.6, "lean": 0.16, "radius_low": 0.42, "radius_top": 0.39, "flare": 0.18, "knob": 1.55, "knob_radius": 0.62, "fronds": 70, "frond": 4.9},
	{"seed": 24, "height": 9.8, "lean": 0.2, "radius_low": 0.44, "radius_top": 0.4, "flare": 0.19, "knob": 1.65, "knob_radius": 0.65, "fronds": 72, "frond": 5.1},
	# Mature palms like the Avenue N seawall row (Street View Nov 2025 and Jul 2023):
	# thick, shaggy, slightly leaning and bowed trunks of stepped leaf bases under
	# dense globes of fronds whose lowest droop well below level. shag is how far the
	# trunk's surface is knobbled out (a fraction of its radius), low the oldest
	# fronds' angle in degrees, droop how far they bend down, width a frond's width
	# over its length.
	{"seed": 25, "height": 7.6, "lean": 0.45, "bow": 0.2, "radius_low": 0.5, "radius_top": 0.53, "flare": 0.2, "knob": 1.6, "knob_radius": 0.72, "fronds": 104, "frond": 5.0,
		"shag": 0.09, "low": -46.0, "droop": 0.55, "width": 0.25},
	{"seed": 26, "height": 9.8, "lean": 0.6, "bow": 0.25, "radius_low": 0.52, "radius_top": 0.56, "flare": 0.21, "knob": 1.7, "knob_radius": 0.74, "fronds": 110, "frond": 5.3,
		"shag": 0.1, "low": -48.0, "droop": 0.58, "width": 0.25},
]
## Two old wind-shaped cypresses (Building 1 grounds, Sep 2025 and Jul 2023),
## a young conical one (the Waterfront Plaza, Sep 2025) and two smaller young
## ones (Cityside Park's beds: ph08 Sep 2025, cmg08; 2-4 m).
const CYPRESSES := [
	{"form": "old", "seed": 1, "height": 13.0, "spread": 17.0, "trunk_radius": 0.5, "fork": 2.4, "leaders": 4, "shear": 0.3},
	{"form": "old", "seed": 7, "height": 11.0, "spread": 12.5, "trunk_radius": 0.42, "fork": 2.0, "leaders": 3, "shear": 0.4},
	{"form": "young", "seed": 5, "height": 4.6, "spread": 3.0, "trunk_radius": 0.14},
	{"form": "young", "seed": 8, "height": 3.4, "spread": 2.3, "trunk_radius": 0.1},
	{"form": "young", "seed": 9, "height": 2.6, "spread": 1.8, "trunk_radius": 0.075},
]
## The Treasure Island prevailing wind is westerly, so old crowns reach east (+X).
const CYPRESS_LEE := Vector2(1.0, 0.0)
const GRASSES := [
	{"seed": 31, "cell": "green", "height": 0.72, "width": 0.92, "cards": 4},
	{"seed": 32, "cell": "green", "height": 0.92, "width": 1.15, "cards": 5},
	{"seed": 33, "cell": "straw", "height": 0.62, "width": 1.0, "cards": 4},
	{"seed": 34, "cell": "straw", "height": 0.82, "width": 1.25, "cards": 5},
]

## Cityside Park's young Sydney blue gums in the windrow plazas' double rows
## (ph10 Sep 2025, cmg01, cmg08, cmg14): a slender pale trunk, bare for its
## lowest 2-3.5 m and leaning downwind, under a narrow, wind-tossed grey-green
## crown of drooping lance leaves on ascending branches, staked. clear is the
## bare trunk as a fraction of the height, crown the crown's width, lean the
## top's lean in metres.
const GUMS := [
	{"seed": 41, "height": 5.0, "trunk_radius": 0.06, "clear": 0.42, "crown": 1.7, "branches": 10, "lean": 0.45},
	{"seed": 42, "height": 6.0, "trunk_radius": 0.07, "clear": 0.45, "crown": 2.0, "branches": 12, "lean": 0.6},
	{"seed": 43, "height": 7.0, "trunk_radius": 0.085, "clear": 0.48, "crown": 2.3, "branches": 14, "lean": 0.75},
]
## The windrow gums' tree stakes (ph10): two posts either side of the trunk,
## STAKE_M tall and STAKE_SPACING_M apart, tied to it near the top.
const STAKE_M := 2.3
const STAKE_SPACING_M := 0.7
const STAKE_RADIUS_M := 0.03
## Young island oaks in the beds (named on the 2024 art-location plan and in the
## 2025 acceptance minutes; no dated photo, so the form is a young oak of the
## species' habit, production inference): two or three stems branching low into
## a dense, rounded, lumpy crown of small dark leaves, about as wide as it is
## tall. clear is the bare stem in metres, lobes the smaller crown lobes round
## the main one, lopsided how far the crown sits off its stems (a fraction of
## its width), so no two read as the same clipped ball.
const OAKS := [
	# A low, wide one; a narrow upright one; a broad, lopsided one.
	{"seed": 51, "height": 2.3, "crown": 2.5, "trunk_radius": 0.04, "clear": 0.3, "stems": 2, "lobes": 3, "lopsided": 0.18, "cards": 120},
	{"seed": 52, "height": 3.4, "crown": 2.0, "trunk_radius": 0.05, "clear": 0.4, "stems": 3, "lobes": 3, "lopsided": 0.1, "cards": 130},
	{"seed": 53, "height": 4.0, "crown": 3.4, "trunk_radius": 0.065, "clear": 0.45, "stems": 2, "lobes": 6, "lopsided": 0.28, "cards": 210},
]
## Monterey pines: three residential trees (p5/p6, Keppler, Mar 2025: 10-14 m
## tall, 8-12 m crowns, branching low) and three wind-pruned low domes (p2-p4,
## the SFFD frontage, Sep 2025: 6-9 m tall and as wide over 1.5-2.5 m of clear,
## leaning trunk). clear is the bare trunk under the crown, fork where the
## trunk splits into leaders, lean the trunk's lean at the fork in metres (the
## pruned trees' downwind), shear how far the wind has pushed the crown
## downwind and pruned its windward side (a fraction of its spread), lobes the
## crown's sub-domes.
const PINES := [
	{"form": "residential", "seed": 201, "height": 10.0, "spread": 8.5, "clear": 1.2, "fork": 2.2, "trunk_radius": 0.27, "leaders": 2, "lean": 0.5, "shear": 0.0, "lobes": 10},
	{"form": "residential", "seed": 202, "height": 12.0, "spread": 10.5, "clear": 1.4, "fork": 2.6, "trunk_radius": 0.33, "leaders": 3, "lean": 0.7, "shear": 0.0, "lobes": 12},
	{"form": "residential", "seed": 203, "height": 14.0, "spread": 12.0, "clear": 1.6, "fork": 3.0, "trunk_radius": 0.4, "leaders": 3, "lean": 0.9, "shear": 0.0, "lobes": 14},
	{"form": "pruned", "seed": 204, "height": 6.5, "spread": 6.5, "clear": 1.6, "fork": 1.7, "trunk_radius": 0.22, "leaders": 2, "lean": 0.6, "shear": 0.1, "lobes": 8},
	{"form": "pruned", "seed": 205, "height": 7.8, "spread": 8.0, "clear": 2.0, "fork": 2.1, "trunk_radius": 0.26, "leaders": 3, "lean": 0.8, "shear": 0.12, "lobes": 9},
	{"form": "pruned", "seed": 206, "height": 9.0, "spread": 9.0, "clear": 2.4, "fork": 2.5, "trunk_radius": 0.3, "leaders": 3, "lean": 1.0, "shear": 0.14, "lobes": 10},
]
## The spreading broadleaf (species unresolved, the photographed form): two mid
## trees (b1/b4, Northpoint, Mar 2025: 7-10 m, a round 8-10 m crown on a trunk
## forking at about 2 m into upright limbs) and two old ones (c2/c3 Gateview,
## Sep 2025; c4/b8 the Avenue B park: 10-13 m tall, 14-18 m wide, leaning, wide
## sinuous limbs under layered clouds of foliage). fork is the trunk's height to
## its first fork, lean the fork's offset in metres, limbs the main limbs, rise
## how steeply they climb (1 straight up, 0 level), clouds the side clouds each
## limb carries, cloud a cloud's reach as a fraction of the spread, flat its
## height over its reach, spacing how far apart its clumps sit (a fraction of a
## clump's width), bronze the share of clouds tipped reddish-bronze.
const BROADLEAVES := [
	{"seed": 301, "height": 7.5, "spread": 8.0, "fork": 1.8, "trunk_radius": 0.24, "limbs": 3, "lean": 0.35, "rise": 0.7, "clouds": 2, "cloud": 0.26, "flat": 0.62, "spacing": 0.62, "bronze": 0.35},
	{"seed": 302, "height": 9.5, "spread": 10.0, "fork": 2.0, "trunk_radius": 0.32, "limbs": 3, "lean": 0.5, "rise": 0.65, "clouds": 2, "cloud": 0.25, "flat": 0.6, "spacing": 0.62, "bronze": 0.35},
	{"seed": 303, "height": 11.0, "spread": 15.0, "fork": 2.2, "trunk_radius": 0.42, "limbs": 4, "lean": 1.2, "rise": 0.45, "clouds": 3, "cloud": 0.2, "flat": 0.55, "spacing": 0.66, "bronze": 0.3},
	{"seed": 304, "height": 12.5, "spread": 17.5, "fork": 2.4, "trunk_radius": 0.5, "limbs": 5, "lean": 2.2, "rise": 0.4, "clouds": 3, "cloud": 0.19, "flat": 0.55, "spacing": 0.66, "bronze": 0.3},
]
## New Zealand Christmas trees (b5/b6, Sturgeon, Mar 2025): 3-5 smooth pale
## stems leaning out from the ground under a very dense, dark, rounded crown,
## 7-9 m tall and 7-8 m wide; flowers is the share of outer clusters showing a
## few red brushes in November.
const CHRISTMAS_TREES := [
	{"seed": 311, "height": 7.0, "spread": 7.0, "stems": 3, "fork": 0.5, "trunk_radius": 0.14, "limbs": 3, "lean": 0.3, "rise": 0.7, "clouds": 2, "cloud": 0.3, "flat": 0.72, "spacing": 0.64, "flowers": 0.14},
	{"seed": 312, "height": 8.5, "spread": 8.0, "stems": 4, "fork": 0.6, "trunk_radius": 0.16, "limbs": 4, "lean": 0.4, "rise": 0.7, "clouds": 2, "cloud": 0.28, "flat": 0.72, "spacing": 0.64, "flowers": 0.12},
]
## The Job Corps entrance tree, a mature eucalyptus (the owner's identification,
## 2026-11-05; n2, 2025 gallery photo): two or three tall trunks from near the
## ground, a full but open, irregular crown about 8 m wide of drooping tassels
## on ascending branches, from low on the trunks to the top, 15-18 m tall. crown
## is its width, clear the bare trunk as a fraction of the height, branches its
## branches, droop how far a branch's outer part bends down (a fraction of its
## reach).
const MATURE_GUMS := [
	{"seed": 401, "height": 15.5, "crown": 7.5, "stems": 2, "trunk_radius": 0.24, "clear": 0.18, "branches": 30, "lean": 0.7, "droop": 0.35},
	{"seed": 402, "height": 17.5, "crown": 8.5, "stems": 3, "trunk_radius": 0.27, "clear": 0.16, "branches": 36, "lean": 0.9, "droop": 0.4},
]
## Young Norfolk Island pines (n1, Chinook, Mar 2025: about 5 m tall, a crown
## 2-2.5 m wide): a straight trunk with a whorl of level branches every tier
## metres, branches per whorl, from near the ground to the leader.
const NORFOLK_PINES := [
	{"seed": 501, "height": 4.2, "spread": 2.0, "trunk_radius": 0.07, "tier": 0.52, "branches": 5},
	{"seed": 502, "height": 5.2, "spread": 2.4, "trunk_radius": 0.085, "tier": 0.58, "branches": 6},
]
## The Avenue N seawall's shrubs (s1-s3, Nov 2025). shape: mound (a lumpy dome
## clothed in crossed clusters), upright (slender stems, crossed side-view
## cards) or cone (a narrow ogive on a short stem); cell is the shrub atlas
## cell, width and height its size, lobes its mound's sub-domes.
const HAWTHORNS := [
	# Rhaphiolepis: round leathery mounds 1.2-1.8 m tall and 2-3 m wide, a few pale pink flower clusters.
	{"seed": 601, "shape": "mound", "cell": "hawthorn", "height": 1.2, "width": 2.0, "lobes": 4},
	{"seed": 602, "shape": "mound", "cell": "hawthorn", "height": 1.5, "width": 2.5, "lobes": 5},
	{"seed": 603, "shape": "mound", "cell": "hawthorn", "height": 1.8, "width": 3.0, "lobes": 6},
]
const PITTOSPORUMS := [
	# Pittosporum tobira: glossy mounds 1-1.5 m tall and 1.5-2.5 m wide.
	{"seed": 611, "shape": "mound", "cell": "pittosporum", "height": 1.0, "width": 1.5, "lobes": 3},
	{"seed": 612, "shape": "mound", "cell": "pittosporum", "height": 1.25, "width": 2.0, "lobes": 4},
	{"seed": 613, "shape": "mound", "cell": "pittosporum", "height": 1.5, "width": 2.5, "lobes": 5},
]
const RED_TIPS := [
	# Slender, to 1.5 m, red new growth at the tips (species unresolved).
	{"seed": 621, "shape": "upright", "cell": "red_tip", "height": 1.1, "width": 0.7, "stems": 7},
	{"seed": 622, "shape": "upright", "cell": "red_tip", "height": 1.5, "width": 0.9, "stems": 8},
]
const CONICAL_SHRUBS := [
	# A narrow cone of olive leaves with bronze tips, 3-4 m tall and 2 m wide (species unresolved).
	{"seed": 631, "shape": "cone", "cell": "upright_shrub", "height": 3.0, "width": 1.7},
	{"seed": 632, "shape": "cone", "cell": "upright_shrub", "height": 3.8, "width": 2.1},
]
## Dark red New Zealand flax (the Mersea lot's planters, Sep 2025): a fan of
## stiff straps (leaves of them, each width wide) standing to about height.
const FLAXES := [
	{"seed": 701, "height": 0.9, "leaves": 40, "width": 0.07},
	{"seed": 702, "height": 1.2, "leaves": 48, "width": 0.08},
	{"seed": 703, "height": 1.5, "leaves": 56, "width": 0.09},
]
## Clipped hedges, laid along a line (hedge_into): style rounded (a flat top
## with rounded shoulders and bulging sides) or box (flat top, upright sides);
## the leafy canopy from canopy_base to height, depth deep; under a rounded
## hedge's canopy, leggy dark stems. surface and sprigs are its materials'
## keys and its sprig cell.
const HEDGES := [
	# Residential (h1, Mariner, Mar 2025): small leaves, 1.0-1.2 m tall, 0.8-1 m deep, on leggy stems.
	{"seed": 801, "style": "rounded", "height": 1.1, "depth": 0.9, "canopy_base": 0.36, "surface": "hedge_leaves", "sprigs": "hedge_sprigs"},
	# Job Corps (h2, 2025 gallery): a solid box 1.2-1.5 m tall of small glossy dark leaves, down to the ground.
	{"seed": 802, "style": "box", "height": 1.35, "depth": 1.0, "canopy_base": 0.0, "surface": "glossy_hedge_leaves", "sprigs": "glossy_sprigs"},
]
## Cityside Park's low plants as they stand in late November, built in layers
## (_build_low): crossed side-view cards for clumps, shrubs' wands and flower
## stalks, shell cards round a mound for foliage, and a dish of litter under the
## shrubs. Flowers stand on their own stalk cards over the foliage, few or none
## now the season is over. Sizes are in metres; lean tips a plant over by that
## fraction of its height. A drift variant packs several of the species' plants
## into one row, so a groundcover can reach dense cover with few rows.
const REEDGRASSES := [
	# Calamagrostis nutkaensis (iNat 352893747, 352887700, Apr 2026): a coarse dark
	# green fountain under a few weathered grey-tan plumes.
	{"seed": 61, "lean": 0.06, "layers": [{"kind": "crossed", "cell": "reedgrass", "cards": 4, "width": 0.85, "height": 0.8, "splay_deg": 10.0, "flop_deg": 22.0, "flutter": 0.06},
		{"kind": "cap", "cell": "tussock_top", "width": 0.54, "height": 0.265, "drop": 0.5}]},
	{"seed": 62, "lean": 0.1, "layers": [{"kind": "crossed", "cell": "reedgrass", "cards": 5, "width": 1.05, "height": 1.0, "splay_deg": 10.0, "flop_deg": 28.0, "flutter": 0.065},
		{"kind": "cap", "cell": "tussock_top", "width": 0.662, "height": 0.318, "drop": 0.5}]},
	{"seed": 63, "lean": 0.08, "layers": [{"kind": "crossed", "cell": "reedgrass", "cards": 5, "width": 1.3, "height": 1.2, "splay_deg": 12.0, "flop_deg": 28.0, "flutter": 0.07},
		{"kind": "cap", "cell": "tussock_top", "width": 0.806, "height": 0.371, "drop": 0.5}]},
	# A drift of four clumps grown together, about 2.2 m across.
	{"seed": 110, "drift": [[0.0, 0.0, 2, 1.0, 0.0], [0.85, 0.35, 1, 0.95, 1.7], [-0.75, 0.45, 0, 1.05, 3.1], [0.2, -0.85, 1, 0.9, 4.4]]},
]
const SEDGES := [
	# Carex densa (iNat 352894107, Apr 2026): a soft green tussock in the mulch.
	# Each size a slightly different green, so a drift is not one colour.
	{"seed": 64, "hue": 0.14, "layers": [{"kind": "crossed", "cell": "sedge", "cards": 4, "width": 0.55, "height": 0.3, "splay_deg": 18.0, "flutter": 0.035, "tint": Color(0.96, 0.98, 0.84)},
		{"kind": "cap", "cell": "tussock_top", "width": 0.374, "height": 0.133, "drop": 0.5, "tint": Color(0.96, 0.98, 0.84)}]},
	{"seed": 65, "hue": 0.14, "lean": 0.08, "layers": [{"kind": "crossed", "cell": "sedge", "cards": 4, "width": 0.75, "height": 0.45, "splay_deg": 18.0, "flop_deg": 30.0, "flutter": 0.04},
		{"kind": "cap", "cell": "tussock_top", "width": 0.504, "height": 0.185, "drop": 0.5}]},
	{"seed": 66, "hue": 0.14, "lean": 0.06, "layers": [{"kind": "crossed", "cell": "sedge", "cards": 5, "width": 0.95, "height": 0.58, "splay_deg": 16.0, "flop_deg": 34.0, "flutter": 0.045, "tint": Color(0.82, 0.88, 0.85)},
		{"kind": "cap", "cell": "tussock_top", "width": 0.634, "height": 0.239, "drop": 0.5, "tint": Color(0.82, 0.88, 0.85)}]},
	# A drift of five tussocks about 1.5 m across.
	{"seed": 67, "drift": [[0.0, 0.0, 1, 1.0, 0.0], [0.55, 0.25, 0, 1.1, 1.3], [-0.5, 0.3, 1, 0.9, 2.1], [0.15, -0.55, 2, 0.85, 0.7], [-0.35, -0.45, 0, 1.0, 3.0]]},
	# A drift of twelve tussocks of every size, about 2.5 m across.
	{"seed": 113, "drift": [[0.0, 0.0, 2, 1.0, 0.0], [0.62, 0.1, 1, 0.95, 0.9], [-0.6, 0.18, 1, 1.05, 1.8], [0.2, 0.6, 0, 1.1, 2.7], [-0.25, -0.58, 2, 0.85, 3.6], [0.55, -0.52, 0, 1.0, 4.5],
		[-0.95, -0.2, 0, 0.9, 5.4], [0.98, 0.42, 0, 1.15, 0.4], [-0.5, 0.82, 1, 0.9, 1.3], [0.35, 1.05, 0, 0.8, 2.2], [0.05, -1.1, 1, 1.0, 3.1], [-1.05, 0.55, 0, 0.95, 4.0]]},
]
const RUSHES := [
	# Juncus (iNat 346410332, Mar 2026): stiff upright stems with brown flower tufts.
	{"seed": 68, "layers": [{"kind": "crossed", "cell": "rush", "cards": 3, "width": 0.45, "height": 0.55, "curl": 0.04, "splay_deg": 4.0, "flutter": 0.025}]},
	{"seed": 69, "lean": 0.05, "layers": [{"kind": "crossed", "cell": "rush", "cards": 5, "width": 0.6, "height": 0.75, "curl": 0.04, "splay_deg": 5.0, "flop_deg": 14.0, "flutter": 0.03}]},
	{"seed": 70, "lean": 0.04, "layers": [{"kind": "crossed", "cell": "rush", "cards": 5, "width": 0.75, "height": 1.0, "curl": 0.04, "splay_deg": 6.0, "flop_deg": 16.0, "flutter": 0.035}]},
	# A drift of six clumps about 1.5 m across.
	{"seed": 111, "drift": [[0.0, 0.0, 1, 1.0, 0.0], [0.45, 0.2, 0, 1.1, 1.2], [-0.42, 0.25, 2, 0.9, 2.4], [0.15, -0.48, 0, 1.0, 3.6], [-0.3, -0.4, 1, 0.95, 4.8], [0.55, -0.25, 0, 0.85, 5.9]]},
]
const BRONZE_GRASSES := [
	# The copper clumps among the green ones in the stormwater meadow (ph08, Sep 2025).
	{"seed": 71, "layers": [{"kind": "crossed", "cell": "bronze", "cards": 3, "width": 0.5, "height": 0.3, "splay_deg": 16.0, "flutter": 0.04},
		{"kind": "cap", "cell": "bronze_top", "width": 0.331, "height": 0.119, "drop": 0.5}]},
	{"seed": 72, "lean": 0.08, "layers": [{"kind": "crossed", "cell": "bronze", "cards": 4, "width": 0.62, "height": 0.4, "splay_deg": 16.0, "flop_deg": 30.0, "flutter": 0.045},
		{"kind": "cap", "cell": "bronze_top", "width": 0.418, "height": 0.159, "drop": 0.5}]},
	{"seed": 73, "lean": 0.06, "layers": [{"kind": "crossed", "cell": "bronze", "cards": 4, "width": 0.75, "height": 0.5, "splay_deg": 14.0, "flop_deg": 30.0, "flutter": 0.05},
		{"kind": "cap", "cell": "bronze_top", "width": 0.504, "height": 0.199, "drop": 0.5}]},
	# A drift of five tufts about 1.6 m across.
	{"seed": 112, "drift": [[0.0, 0.0, 1, 1.0, 0.0], [0.5, 0.25, 0, 1.1, 1.3], [-0.48, 0.3, 2, 0.9, 2.6], [0.1, -0.5, 0, 1.0, 3.9], [-0.4, -0.38, 1, 0.9, 5.1]]},
]
const BLUE_EYED_GRASSES := [
	# Sisyrinchium bellum (iNat 387980572, Aug 2026): bluish iris-like fans, a flower or none in November.
	{"seed": 74, "layers": [{"kind": "crossed", "cell": "blue_eyed", "cards": 3, "width": 0.22, "height": 0.2, "splay_deg": 14.0, "flutter": 0.02},
		{"kind": "cap", "cell": "tussock_top", "width": 0.13, "height": 0.066, "drop": 0.5, "tint": Color(0.8, 0.9, 0.92)}]},
	{"seed": 75, "layers": [{"kind": "crossed", "cell": "blue_eyed", "cards": 3, "width": 0.28, "height": 0.25, "splay_deg": 14.0, "flutter": 0.025},
		{"kind": "cap", "cell": "tussock_top", "width": 0.158, "height": 0.08, "drop": 0.5, "tint": Color(0.8, 0.9, 0.92)}]},
	{"seed": 76, "lean": 0.08, "layers": [{"kind": "crossed", "cell": "blue_eyed", "cards": 3, "width": 0.34, "height": 0.3, "splay_deg": 14.0, "flop_deg": 30.0, "flutter": 0.025},
		{"kind": "cap", "cell": "tussock_top", "width": 0.187, "height": 0.093, "drop": 0.5, "tint": Color(0.8, 0.9, 0.92)}]},
	# A clump of six tufts grown together, about 0.6 m across.
	{"seed": 77, "drift": [[0.0, 0.0, 1, 1.0, 0.0], [0.16, 0.08, 0, 1.1, 1.2], [-0.15, 0.1, 2, 0.9, 2.3], [0.05, -0.17, 0, 1.0, 3.4], [-0.12, -0.14, 1, 0.85, 4.5], [0.22, -0.12, 0, 0.9, 5.6]]},
]
const DAISIES := [
	# Erigeron glaucus: low grey-green mats, a few lilac daisies still out in
	# October 2026 (iNat 408817767) over brown seed heads; cmg07.
	{"seed": 81, "layers": [{"kind": "shell", "cell": "daisy", "cards": 14, "card": 0.4, "width": 0.55, "height": 0.15, "flat": 0.55, "rough": 0.6}]},
	{"seed": 82, "layers": [{"kind": "shell", "cell": "daisy", "cards": 18, "card": 0.36, "width": 0.8, "height": 0.18, "flat": 0.55, "rough": 0.6},
		{"kind": "shell", "cell": "daisy_flowers", "cards": 3, "card": 0.16, "width": 0.66, "height": 0.21, "flat": 0.95}]},
	{"seed": 83, "layers": [{"kind": "shell", "cell": "daisy", "cards": 24, "card": 0.32, "width": 1.05, "height": 0.21, "flat": 0.55, "rough": 0.6},
		{"kind": "shell", "cell": "daisy_flowers", "cards": 4, "card": 0.13, "width": 0.88, "height": 0.24, "flat": 0.95}]},
	# A drift of five mats about 1.8 m across.
	{"seed": 84, "drift": [[0.0, 0.0, 2, 1.0, 0.0], [0.75, 0.35, 1, 1.0, 1.7], [-0.7, 0.25, 0, 1.1, 0.4], [0.1, -0.7, 1, 0.9, 2.6], [-0.45, -0.55, 0, 1.0, 4.0]]},
]
const THRIFTS := [
	# Armeria maritima (iNat 353060642, 352887520, 345762695): tight needle-leaf
	# cushions hugging the gravel, a smooth bristly dome each; in November a few
	# papery heads on stalks.
	{"seed": 85, "layers": [{"kind": "dome", "cell": "thrift", "width": 0.24, "height": 0.12}]},
	{"seed": 86, "layers": [{"kind": "dome", "cell": "thrift", "width": 0.32, "height": 0.15},
		{"kind": "crossed", "cell": "thrift_stalks", "cards": 1, "width": 0.24, "height": 0.28, "base": 0.06, "flutter": 0.03}]},
	{"seed": 87, "layers": [{"kind": "dome", "cell": "thrift", "width": 0.4, "height": 0.18},
		{"kind": "crossed", "cell": "thrift_stalks", "cards": 1, "width": 0.28, "height": 0.32, "base": 0.08, "flutter": 0.03}]},
	# An irregular cluster: three cushions grown together, three apart.
	{"seed": 88, "drift": [[0.0, 0.0, 1, 1.0, 0.0], [0.2, 0.1, 0, 0.9, 1.1], [0.06, -0.21, 2, 1.0, 2.2], [0.62, 0.32, 0, 1.1, 3.3], [-0.58, 0.4, 1, 0.85, 4.4], [-0.2, -0.62, 0, 0.9, 5.5]]},
]
const WOOLLY_SUNFLOWERS := [
	# Eriophyllum staechadifolium (ph03 Sep 2025, iNat 345762841): a loose, open
	# grey mound with flower clusters on stalks above it, mostly spent and brown.
	{"seed": 89, "lean": 0.05, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.55},
		{"kind": "shell", "cell": "woolly", "cards": 10, "card": 0.55, "width": 0.8, "height": 0.45, "flat": 0.15},
		{"kind": "crossed", "cell": "woolly_stalks", "cards": 1, "width": 0.45, "height": 0.55, "base": 0.12, "flutter": 0.04}]},
	{"seed": 90, "lean": 0.08, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.75},
		{"kind": "shell", "cell": "woolly", "cards": 13, "card": 0.5, "width": 1.15, "height": 0.65, "flat": 0.15},
		{"kind": "crossed", "cell": "woolly_stalks", "cards": 1, "width": 0.62, "height": 0.75, "base": 0.18, "flutter": 0.045}]},
	{"seed": 91, "lean": 0.06, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.95},
		{"kind": "shell", "cell": "woolly", "cards": 17, "card": 0.46, "width": 1.5, "height": 0.85, "flat": 0.15},
		{"kind": "crossed", "cell": "woolly_stalks", "cards": 2, "width": 0.8, "height": 0.95, "base": 0.22, "splay_deg": 10.0, "flutter": 0.05}]},
]
const SAGEBRUSHES := [
	# Artemisia californica (iNat 383028886, 337562529): loose upright and arching
	# wands of feathery grey-green, darker inside, over a low base.
	{"seed": 92, "lean": 0.06, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.5},
		{"kind": "shell", "cell": "sagebrush", "cards": 5, "card": 0.6, "width": 0.5, "height": 0.3, "tint": Color(0.72, 0.76, 0.7)},
		{"kind": "crossed", "cell": "sagebrush_wands", "cards": 5, "width": 0.75, "height": 0.65, "splay_deg": 10.0, "flop_deg": 24.0, "flutter": 0.045},
		{"kind": "cap", "cell": "sagebrush", "width": 0.5, "height": 0.48, "tint": Color(0.7, 0.76, 0.68)}]},
	{"seed": 93, "lean": 0.08, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.7},
		{"kind": "shell", "cell": "sagebrush", "cards": 6, "card": 0.56, "width": 0.7, "height": 0.45, "tint": Color(0.72, 0.76, 0.7)},
		{"kind": "crossed", "cell": "sagebrush_wands", "cards": 5, "width": 1.1, "height": 1.0, "splay_deg": 10.0, "flop_deg": 26.0, "flutter": 0.05},
		{"kind": "cap", "cell": "sagebrush", "width": 0.72, "height": 0.72, "tint": Color(0.7, 0.76, 0.68)}]},
	{"seed": 94, "lean": 0.07, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.9},
		{"kind": "shell", "cell": "sagebrush", "cards": 7, "card": 0.52, "width": 0.9, "height": 0.6, "tint": Color(0.72, 0.76, 0.7)},
		{"kind": "crossed", "cell": "sagebrush_wands", "cards": 6, "width": 1.45, "height": 1.4, "splay_deg": 12.0, "flop_deg": 28.0, "flutter": 0.055},
		{"kind": "cap", "cell": "sagebrush", "width": 0.95, "height": 1.0, "tint": Color(0.7, 0.76, 0.68)}]},
]
const SAGES := [
	# Salvia sp. (iNat 334414817, 334414816, Jan 2026): upright, airy grey-green
	# stems with dried whorls toward their tops.
	{"seed": 95, "lean": 0.05, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.45},
		{"kind": "shell", "cell": "sagebrush", "cards": 4, "card": 0.6, "width": 0.4, "height": 0.25, "tint": Color(0.66, 0.74, 0.64)},
		{"kind": "crossed", "cell": "sage_stems", "cards": 4, "width": 0.6, "height": 0.65, "splay_deg": 6.0, "flop_deg": 16.0, "flutter": 0.04},
		{"kind": "cap", "cell": "sagebrush", "width": 0.4, "height": 0.45, "tint": Color(0.62, 0.7, 0.6)}]},
	{"seed": 96, "lean": 0.07, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.6},
		{"kind": "shell", "cell": "sagebrush", "cards": 5, "card": 0.56, "width": 0.55, "height": 0.35, "tint": Color(0.66, 0.74, 0.64)},
		{"kind": "crossed", "cell": "sage_stems", "cards": 5, "width": 0.85, "height": 0.95, "splay_deg": 7.0, "flop_deg": 18.0, "flutter": 0.045},
		{"kind": "cap", "cell": "sagebrush", "width": 0.55, "height": 0.66, "tint": Color(0.62, 0.7, 0.6)}]},
	{"seed": 97, "lean": 0.06, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.75},
		{"kind": "shell", "cell": "sagebrush", "cards": 6, "card": 0.52, "width": 0.7, "height": 0.45, "tint": Color(0.66, 0.74, 0.64)},
		{"kind": "crossed", "cell": "sage_stems", "cards": 5, "width": 1.1, "height": 1.25, "splay_deg": 8.0, "flop_deg": 20.0, "flutter": 0.05},
		{"kind": "cap", "cell": "sagebrush", "width": 0.7, "height": 0.86, "tint": Color(0.62, 0.7, 0.6)}]},
]
const BUCKWHEATS := [
	# Eriogonum fasciculatum (iNat 352896292): a fine needle-leaf mound with dry
	# rust heads held on stems above it; no inner shell (from low views its dark
	# floor read as a hole), the side-view mound and the cap carry the volume.
	{"seed": 98, "lean": 0.05, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.45},
		{"kind": "crossed", "cell": "buckwheat_mound", "cards": 4, "width": 0.65, "height": 0.45, "splay_deg": 12.0, "flop_deg": 24.0, "flutter": 0.03},
		{"kind": "cap", "cell": "buckwheat", "width": 0.45, "height": 0.32, "tint": Color(0.74, 0.76, 0.7)},
		{"kind": "crossed", "cell": "buckwheat_stalks", "cards": 1, "width": 0.42, "height": 0.52, "base": 0.14, "flutter": 0.035}]},
	{"seed": 99, "lean": 0.06, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.6},
		{"kind": "crossed", "cell": "buckwheat_mound", "cards": 5, "width": 0.95, "height": 0.65, "splay_deg": 14.0, "flop_deg": 26.0, "flutter": 0.035},
		{"kind": "cap", "cell": "buckwheat", "width": 0.65, "height": 0.46, "tint": Color(0.74, 0.76, 0.7)},
		{"kind": "crossed", "cell": "buckwheat_stalks", "cards": 1, "width": 0.58, "height": 0.72, "base": 0.2, "flutter": 0.04}]},
	{"seed": 100, "lean": 0.05, "layers": [{"kind": "litter", "cell": "litter", "radius": 0.8},
		{"kind": "crossed", "cell": "buckwheat_mound", "cards": 5, "width": 1.25, "height": 0.85, "splay_deg": 14.0, "flop_deg": 28.0, "flutter": 0.04},
		{"kind": "cap", "cell": "buckwheat", "width": 0.85, "height": 0.6, "tint": Color(0.74, 0.76, 0.7)},
		{"kind": "crossed", "cell": "buckwheat_stalks", "cards": 2, "width": 0.72, "height": 0.92, "base": 0.26, "splay_deg": 10.0, "flutter": 0.045}]},
]
const MONKEYFLOWERS := [
	# Erythranthe guttata (iNat 353060948, 352898225): low, soft, sprawling green
	# clumps in the wet spots, a yellow flower or two.
	{"seed": 101, "layers": [{"kind": "shell", "cell": "monkeyflower", "cards": 7, "card": 0.6, "width": 0.38, "height": 0.18, "flat": 0.3, "rough": 0.8}]},
	{"seed": 102, "lean": 0.1, "layers": [{"kind": "shell", "cell": "monkeyflower", "cards": 8, "card": 0.55, "width": 0.52, "height": 0.28, "flat": 0.3, "rough": 0.8},
		{"kind": "crossed", "cell": "monkey_stalks", "cards": 1, "width": 0.4, "height": 0.38, "base": 0.05, "flutter": 0.04}]},
	{"seed": 103, "lean": 0.12, "layers": [{"kind": "shell", "cell": "monkeyflower", "cards": 9, "card": 0.5, "width": 0.66, "height": 0.38, "flat": 0.25, "rough": 0.8},
		{"kind": "crossed", "cell": "monkey_stalks", "cards": 1, "width": 0.5, "height": 0.55, "base": 0.08, "flutter": 0.045}]},
]
const TANSIES := [
	# Tanacetum bipinnatum (iNat 336112235, Jan 2026): ferny mid green, buttons gone brown.
	{"seed": 104, "layers": [{"kind": "shell", "cell": "tansy", "cards": 7, "card": 0.62, "width": 0.42, "height": 0.28, "flat": 0.1, "rough": 0.8}]},
	{"seed": 105, "lean": 0.08, "layers": [{"kind": "shell", "cell": "tansy", "cards": 8, "card": 0.56, "width": 0.62, "height": 0.4, "flat": 0.1, "rough": 0.8},
		{"kind": "crossed", "cell": "tansy_stalks", "cards": 1, "width": 0.45, "height": 0.5, "base": 0.08, "flutter": 0.04}]},
	{"seed": 106, "lean": 0.06, "layers": [{"kind": "shell", "cell": "tansy", "cards": 10, "card": 0.5, "width": 0.82, "height": 0.5, "flat": 0.1, "rough": 0.8},
		{"kind": "crossed", "cell": "tansy_stalks", "cards": 2, "width": 0.55, "height": 0.62, "base": 0.1, "flutter": 0.045}]},
]
const WHITE_UMBELS := [
	# Flat heads at 0.4-0.6 m over feathery leaves (cmg09); species unconfirmed.
	{"seed": 107, "layers": [{"kind": "shell", "cell": "yarrow", "cards": 6, "card": 0.75, "width": 0.32, "height": 0.12, "flat": 0.4},
		{"kind": "crossed", "cell": "umbel_stalks", "cards": 2, "width": 0.3, "height": 0.42, "base": 0.04, "splay_deg": 6.0, "flutter": 0.04}]},
	{"seed": 108, "lean": 0.08, "layers": [{"kind": "shell", "cell": "yarrow", "cards": 7, "card": 0.7, "width": 0.42, "height": 0.15, "flat": 0.4},
		{"kind": "crossed", "cell": "umbel_stalks", "cards": 2, "width": 0.36, "height": 0.5, "base": 0.05, "splay_deg": 8.0, "flutter": 0.045}]},
	{"seed": 109, "lean": 0.1, "layers": [{"kind": "shell", "cell": "yarrow", "cards": 8, "card": 0.66, "width": 0.52, "height": 0.18, "flat": 0.4},
		{"kind": "crossed", "cell": "umbel_stalks", "cards": 3, "width": 0.42, "height": 0.6, "base": 0.06, "splay_deg": 8.0, "flop_deg": 20.0, "flutter": 0.05}]},
]
## Low plants stand in grass_clump rows or, spaced wider, in planting_slot rows.
const LOW_KINDS := ["grass_clump", "planting_slot"]
## Per prop: its variants, visibility ranges in metres (LOD0 until the first,
## LOD1 until the second, the far level until the third; a low plant has only
## LOD0), the radius of its foot on the ground, which the generator settles on
## the visible surface (tools/lib/street-vegetation-generation.mjs keeps the same
## variant counts and foot radii), how its variants are built (form) and, for a
## low plant, whether it casts shadows (the taller ones; trees always do). The
## far impostors are baked from these forms: re-run
## tools/vegetation/bake_impostors.gd after any kit geometry change.
const PROPS := {
	"mexican_fan_palm": {"kinds": ["palm_slot", "tree"], "variants": FAN_PALMS, "ranges": [35.0, 95.0, 900.0], "foot_m": 0.45, "form": "fan_palm"},
	"canary_date_palm": {"kinds": ["palm_slot", "tree"], "variants": CANARY_PALMS, "ranges": [45.0, 110.0, 900.0], "foot_m": 0.7, "form": "canary_palm"},
	"monterey_cypress": {"kinds": ["tree"], "variants": CYPRESSES, "ranges": [45.0, 110.0, 900.0], "foot_m": 0.8, "form": "cypress"},
	"sydney_blue_gum_young": {"kinds": ["tree"], "variants": GUMS, "ranges": [40.0, 100.0, 900.0], "foot_m": 0.3, "form": "gum"},
	"island_oak_young": {"kinds": ["tree"], "variants": OAKS, "ranges": [35.0, 90.0, 700.0], "foot_m": 0.3, "form": "oak"},
	"monterey_pine": {"kinds": ["tree"], "variants": PINES, "ranges": [50.0, 120.0, 900.0], "foot_m": 0.6, "form": "pine", "impostor_tint": Color(0.68, 0.68, 0.68)},
	"spreading_broadleaf": {"kinds": ["tree"], "variants": BROADLEAVES, "ranges": [55.0, 130.0, 900.0], "foot_m": 0.7, "form": "broadleaf", "impostor_tint": Color(0.6, 0.6, 0.6)},
	"nz_christmas_tree": {"kinds": ["tree"], "variants": CHRISTMAS_TREES, "ranges": [45.0, 110.0, 800.0], "foot_m": 0.5, "form": "broadleaf", "impostor_tint": Color(0.64, 0.64, 0.64)},
	"eucalyptus_mature": {"kinds": ["tree"], "variants": MATURE_GUMS, "ranges": [55.0, 130.0, 900.0], "foot_m": 0.6, "form": "gum", "impostor_tint": Color(0.68, 0.68, 0.68)},
	"norfolk_island_pine": {"kinds": ["tree"], "variants": NORFOLK_PINES, "ranges": [35.0, 90.0, 600.0], "foot_m": 0.2, "form": "araucaria", "impostor_tint": Color(0.74, 0.74, 0.74)},
	"indian_hawthorn": {"kinds": ["planting_slot"], "variants": HAWTHORNS, "ranges": [30.0, 75.0, 160.0], "foot_m": 0.6, "form": "shrub", "impostor_tint": Color(0.72, 0.72, 0.72)},
	"pittosporum_tobira": {"kinds": ["planting_slot"], "variants": PITTOSPORUMS, "ranges": [30.0, 75.0, 160.0], "foot_m": 0.5, "form": "shrub", "impostor_tint": Color(0.72, 0.72, 0.72)},
	"red_tip_shrub": {"kinds": LOW_KINDS, "variants": RED_TIPS, "ranges": [25.0, 60.0, 140.0], "foot_m": 0.25, "form": "shrub", "impostor_tint": Color(0.8, 0.8, 0.8)},
	"conical_shrub": {"kinds": ["planting_slot", "tree"], "variants": CONICAL_SHRUBS, "ranges": [40.0, 100.0, 300.0], "foot_m": 0.4, "form": "shrub", "impostor_tint": Color(0.75, 0.75, 0.75)},
	"nz_flax": {"kinds": LOW_KINDS, "variants": FLAXES, "ranges": [25.0, 60.0, 140.0], "foot_m": 0.25, "form": "flax", "impostor_tint": Color(0.82, 0.82, 0.82)},
	"clipped_hedge": {"kinds": ["hedge"], "variants": HEDGES, "ranges": [45.0, 100.0, 170.0], "foot_m": 0.45, "form": "hedge"},
	"clump_grass": {"kinds": ["grass_clump"], "variants": GRASSES, "ranges": [70.0], "foot_m": 0.3, "form": "grass"},
	"pacific_reedgrass": {"kinds": LOW_KINDS, "variants": REEDGRASSES, "ranges": [70.0], "foot_m": 0.25, "form": "low", "shadow": true},
	"dense_sedge": {"kinds": LOW_KINDS, "variants": SEDGES, "ranges": [55.0], "foot_m": 0.18, "form": "low"},
	"rush": {"kinds": LOW_KINDS, "variants": RUSHES, "ranges": [60.0], "foot_m": 0.2, "form": "low", "shadow": true},
	"bronze_clump_grass": {"kinds": LOW_KINDS, "variants": BRONZE_GRASSES, "ranges": [55.0], "foot_m": 0.18, "form": "low"},
	"blue_eyed_grass": {"kinds": LOW_KINDS, "variants": BLUE_EYED_GRASSES, "ranges": [40.0], "foot_m": 0.1, "form": "low"},
	"seaside_daisy": {"kinds": LOW_KINDS, "variants": DAISIES, "ranges": [50.0], "foot_m": 0.2, "form": "low"},
	"sea_thrift": {"kinds": LOW_KINDS, "variants": THRIFTS, "ranges": [40.0], "foot_m": 0.12, "form": "low"},
	"seaside_woolly_sunflower": {"kinds": LOW_KINDS, "variants": WOOLLY_SUNFLOWERS, "ranges": [70.0], "foot_m": 0.3, "form": "low", "shadow": true},
	"california_sagebrush": {"kinds": LOW_KINDS, "variants": SAGEBRUSHES, "ranges": [70.0], "foot_m": 0.3, "form": "low", "shadow": true},
	"shrubby_sage": {"kinds": LOW_KINDS, "variants": SAGES, "ranges": [70.0], "foot_m": 0.3, "form": "low", "shadow": true},
	"california_buckwheat": {"kinds": LOW_KINDS, "variants": BUCKWHEATS, "ranges": [65.0], "foot_m": 0.25, "form": "low", "shadow": true},
	"seep_monkeyflower": {"kinds": LOW_KINDS, "variants": MONKEYFLOWERS, "ranges": [45.0], "foot_m": 0.15, "form": "low"},
	"dune_tansy": {"kinds": LOW_KINDS, "variants": TANSIES, "ranges": [50.0], "foot_m": 0.2, "form": "low"},
	"white_umbel_perennial": {"kinds": LOW_KINDS, "variants": WHITE_UMBELS, "ranges": [50.0], "foot_m": 0.15, "form": "low"},
}
## A low plant dissolves over the last LOW_FADE_M of its range. Its vertex
## colour's alpha carries where that range ends, in units of FADE_SCALE_M
## (vegetation_foliage.gdshader's distance_fade).
const LOW_FADE_M := 12.0
const FADE_SCALE_M := 100.0
const GOLDEN_ANGLE := 2.39996323
## How far a drift member's base runs on below the ground (see _build_low).
const DRIFT_BURY_M := 0.15
## The frame of a card drawn in its prop's own space (no lean, no transform).
const IDENTITY_FRAME := {"xf": Transform3D.IDENTITY, "scale": 1.0, "lean": Vector3.ZERO, "height": 1.0, "tint": Color.WHITE}

## The impostor bake turns the breeze off on every material it draws.
var wind_strength := 1.0

var _materials := {}
var _prototypes := {}
var _trees := {}


## One mesh surface under construction. UV2 carries the wind weights: x the
## sway downwind in metres, y the flutter along the normal in metres.
class Surf:
	var verts := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var uv2s := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()

	func add(position: Vector3, normal: Vector3, uv: Vector2, color := Color.WHITE, wind := Vector2.ZERO) -> int:
		verts.append(position)
		normals.append(normal.normalized())
		uvs.append(uv)
		uv2s.append(wind)
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

	func commit(mesh: ArrayMesh, material: Material) -> void:
		if indices.is_empty():
			return
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = verts
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		arrays[Mesh.ARRAY_TEX_UV2] = uv2s
		arrays[Mesh.ARRAY_COLOR] = colors
		arrays[Mesh.ARRAY_INDEX] = indices
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		mesh.surface_set_material(mesh.get_surface_count() - 1, material)


# --- Prototypes ----------------------------------------------------------------


static func variant_count(prop: String) -> int:
	return (PROPS[prop].variants as Array).size() if PROPS.has(prop) else 0


## Whether a prop is a low plant (a grass, perennial or shrub): one detail level, no trunk.
static func is_low_plant(prop: String) -> bool:
	return PROPS.has(prop) and (PROPS[prop].ranges as Array).size() == 1


## What is wrong with a planted row's prop for this kit, or "" (the generated
## world contract and the builder both ask before building it).
static func params_error(prop: String, kind: String, params: Variant) -> String:
	if not PROPS.has(prop):
		return "unknown street-vegetation prop %s" % prop
	if kind not in PROPS[prop].kinds or is_hedge(prop):
		return "%s does not stand in a %s row" % [prop, kind]
	if not params is Dictionary:
		return "%s params must be an object" % prop
	var p: Dictionary = params
	var variant_problem := _variant_error(prop, p.get("variant", null))
	if variant_problem != "":
		return variant_problem
	for field: String in ["scale", "lift_m", "foot_spread_m", "well_m"]:
		var value: Variant = p.get(field, null)
		if not (value is float or value is int) or not is_finite(float(value)):
			return "%s params need a finite %s" % [prop, field]
	if float(p.scale) < SCALE_MIN or float(p.scale) > SCALE_MAX:
		return "%s scale %s is out of range" % [prop, p.scale]
	if absf(float(p.lift_m)) > MAX_LIFT_M or float(p.foot_spread_m) < 0.0 or float(p.foot_spread_m) > MAX_FOOT_SPREAD_M or float(p.well_m) < 0.0:
		return "%s foot settling is out of range" % prop
	if float(p.well_m) > 0.0:
		var slope: Variant = p.get("well_slope", null)
		var lift: Variant = p.get("well_lift_m", null)
		if not (lift is float or lift is int) or not is_finite(float(lift)) or not slope is Array or (slope as Array).size() != 2 \
		or not ((slope[0] is float or slope[0] is int) and (slope[1] is float or slope[1] is int)) or not is_finite(float(slope[0])) or not is_finite(float(slope[1])):
			return "%s mulch pit needs well_lift_m and a well_slope [x, z]" % prop
	return ""


static func _variant_error(prop: String, variant: Variant) -> String:
	if not (variant is int or (variant is float and float(variant) == floorf(float(variant)))) or int(variant) < 0 or int(variant) >= variant_count(prop):
		return "%s has no variant %s" % [prop, variant]
	return ""


## Whether a prop is laid along a line (a hedge) rather than planted at a point.
static func is_hedge(prop: String) -> bool:
	return PROPS.has(prop) and str(PROPS[prop].form) == "hedge"


## What is wrong with a hedge row for this kit, or "": a vegetation line row of
## kind hedge whose params are {variant, ground_y_m}, ground_y_m the visible
## ground's height under each of its point_count points (where the hedge stands;
## the line's own points lie on the land under it). The generated world
## contract and the builder both ask before laying it.
static func line_params_error(prop: String, kind: String, params: Variant, point_count: int) -> String:
	if not is_hedge(prop) or kind not in PROPS[prop].kinds:
		return "%s is not laid along a %s line" % [prop, kind]
	if not params is Dictionary:
		return "%s params must be an object" % prop
	var p: Dictionary = params
	var variant_problem := _variant_error(prop, p.get("variant", null))
	if variant_problem != "":
		return variant_problem
	var ground: Variant = p.get("ground_y_m", null)
	if not ground is Array or (ground as Array).size() != point_count or point_count < 2:
		return "%s needs a ground_y_m for each of its points" % prop
	for value: Variant in ground:
		if not (value is float or value is int) or not is_finite(float(value)):
			return "%s ground_y_m must be finite" % prop
	return ""


## What the builder needs for one variant of a prop: {ok, levels: [{name, mesh,
## begin_m, end_m, shadow}], capsules: [{radius_m, from, to}] in the prop's
## frame, foot_m}, or {ok: false, message}. Shared by every instance.
func prototype(prop: String, variant: int) -> Dictionary:
	if not PROPS.has(prop):
		return {"ok": false, "message": "unknown street-vegetation prop %s" % prop}
	if variant < 0 or variant >= variant_count(prop):
		return {"ok": false, "message": "%s has no variant %d" % [prop, variant]}
	if is_hedge(prop):
		return {"ok": false, "message": "%s is laid along a line (hedge_into), not planted at a point" % prop}
	var key := "%s_%d" % [prop, variant]
	if _prototypes.has(key):
		return _prototypes[key]
	var tree := build(prop, variant)
	var ranges: Array = PROPS[prop].ranges
	var levels: Array[Dictionary] = [{"name": "lod0", "mesh": tree.lod0, "begin_m": 0.0, "end_m": float(ranges[0]), "shadow": ranges.size() > 1 or bool(PROPS[prop].get("shadow", false))}]
	if ranges.size() > 1:
		var far := impostor_mesh(prop, variant)
		levels.append({"name": "lod1", "mesh": tree.lod1, "begin_m": float(ranges[0]), "end_m": float(ranges[1] if far != null else ranges[2]), "shadow": true})
		if far != null:
			levels.append({"name": "far", "mesh": far, "begin_m": float(ranges[1]), "end_m": float(ranges[2]), "shadow": false})
	var result := {"ok": true, "levels": levels, "capsules": tree.capsules, "foot_m": float(PROPS[prop].foot_m), "top_m": tree.top_m}
	_prototypes[key] = result
	return result


## The tree itself: {prop, variant, params, lod0, lod1, capsules, top_m,
## crown_surface (the surface index of its crown, for the impostor; -1 for the
## whole mesh), ...}. Cached: the impostor frame and the bake reuse it.
func build(prop: String, variant: int) -> Dictionary:
	var key := "%s_%d" % [prop, variant]
	if _trees.has(key):
		return _trees[key]
	var params: Dictionary = (PROPS[prop].variants as Array)[variant]
	var tree: Dictionary
	match str(PROPS[prop].form):
		"fan_palm":
			tree = _build_fan_palm(params)
		"canary_palm":
			tree = _build_canary_palm(params)
		"cypress":
			tree = _build_cypress(params)
		"gum":
			tree = _build_gum(params)
		"oak":
			tree = _build_oak(params)
		"pine":
			tree = _build_pine(params)
		"broadleaf":
			tree = _build_broadleaf(params)
		"araucaria":
			tree = _build_araucaria(params)
		"shrub":
			tree = _build_shrub(params)
		"flax":
			tree = _build_flax(params)
		"hedge":
			# A straight sample run, for form sheets; the world lays hedges with hedge_into().
			tree = _build_hedge_sample(variant)
		"low":
			# A layered low plant dissolves away before its one range ends.
			tree = _build_low(prop, params, float(PROPS[prop].ranges[0]))
		_:
			tree = _build_grass(params)
	tree.prop = prop
	tree.variant = variant
	tree.params = params
	_trees[key] = tree
	return tree


# --- Palm trunks (both palms) --------------------------------------------------------


## A palm's axis at t (0 foot .. 1 top): a lean that grows toward the top plus a sideways bow.
func _palm_axis(shape: Dictionary, t: float) -> Vector3:
	var offset: Vector2 = shape.lean * pow(t, 1.7) + shape.bow * sin(PI * t)
	return Vector3(offset.x, t * float(shape.height), offset.y)


func _palm_shape(p: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var lean_angle := rng.randf() * TAU
	var bow_angle := lean_angle + rng.randf_range(1.2, 2.0)
	return {
		"height": float(p.height),
		"lean": Vector2(cos(lean_angle), sin(lean_angle)) * float(p.get("lean", 0.0)),
		"bow": Vector2(cos(bow_angle), sin(bow_angle)) * float(p.get("bow", 0.0)),
	}


## A palm trunk from BURY_M under its foot to its top: rings along the axis
## (denser near the ground, where the radius changes fastest), radius(h) in
## metres above the foot, bark tiled tile_m, swaying with sway_top at its top.
func _palm_trunk(s: Surf, shape: Dictionary, rings: int, sides: int, radius: Callable, tile_m: float, sway_top: float, shade: Callable) -> void:
	var height := float(shape.height)
	var points := PackedVector3Array([_palm_axis(shape, 0.0) + Vector3.DOWN * BURY_M])
	var radii := PackedFloat32Array([float(radius.call(0.0)) * 1.04])
	var colors := PackedColorArray([shade.call(0.0)])
	var winds := PackedVector2Array([Vector2.ZERO])
	for i in rings + 1:
		var t := pow(float(i) / rings, 1.6)
		var h := t * height
		points.append(_palm_axis(shape, t))
		radii.append(float(radius.call(h)))
		colors.append(shade.call(h))
		winds.append(Vector2(sway_top * t * t, 0.0))
	_tube(s, points, radii, colors, winds, sides, maxf(1.0, roundf(TAU * radii[1] / tile_m)), tile_m)


## Roots spreading from a palm's foot into the ground (LOD0 only): short tapered
## spokes that leave the swollen base and dive under the surface.
func _palm_roots(s: Surf, count: int, base_radius: float, rng: RandomNumberGenerator, color: Color) -> void:
	for i in count:
		var azimuth := TAU * i / count + rng.randf_range(-0.25, 0.25)
		var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
		var start := out * base_radius * 0.7 + Vector3.UP * rng.randf_range(0.06, 0.2)
		var reach := base_radius + rng.randf_range(0.08, 0.24)
		var middle := out * (base_radius * 0.7 + reach) * 0.55 + Vector3.UP * rng.randf_range(0.0, 0.04)
		var end := out * reach + Vector3.DOWN * 0.12
		var thickness := rng.randf_range(0.018, 0.034)
		var shade := color * rng.randf_range(0.82, 1.0)
		_tube(s, PackedVector3Array([start, middle, end]), PackedFloat32Array([thickness, thickness * 0.75, thickness * 0.35]),
			PackedColorArray([shade, shade, shade * 0.9]), PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]), 4, 1.0, FAN_BARK_M)


# --- Mexican fan palm ------------------------------------------------------------------


func _build_fan_palm(p: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var shape := _palm_shape(p, rng)
	var height := float(p.height)
	var top := _palm_axis(shape, 1.0)
	var crown := top + Vector3(0.0, 0.45, 0.0)
	var sway_top := PALM_SWAY * height
	var fronds := _fan_fronds(p, rng, top)
	var spears := []
	for i in 3:
		spears.append({"azimuth": rng.randf() * TAU, "tilt": deg_to_rad(rng.randf_range(3.0, 12.0)), "length": rng.randf_range(0.8, 1.2)})
	var skirt := _fan_skirt(p, rng)
	var root_seed := rng.randi()
	var radius := func(h: float) -> float:
		var t := clampf(h / height, 0.0, 1.0)
		var r := lerpf(float(p.radius_low), float(p.radius_top), smoothstep(0.0, 1.0, t))
		# A bulbous foot over the lowest metre or so, flaring right at the ground.
		return r + float(p.swell) * exp(-maxf(h, 0.0) / 1.1) + float(p.flare) * exp(-maxf(h, 0.0) / 0.22)
	# Contact shading at the ground and under the crown.
	var shade := func(h: float) -> Color:
		var ao := lerpf(0.72, 1.0, clampf(h / 0.7, 0.0, 1.0)) * lerpf(1.0, 0.72, clampf((h - (height - 1.6)) / 1.6, 0.0, 1.0))
		return Color(ao, ao, ao)
	var boot_radius := float(p.radius_top) + 0.14
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var bark := Surf.new()
		var leaves := Surf.new()
		_palm_trunk(bark, shape, 26 if lod == 0 else 8, 12 if lod == 0 else 7, radius, FAN_BARK_M, sway_top, shade)
		if lod == 0:
			var roots := RandomNumberGenerator.new()
			roots.seed = root_seed
			_palm_roots(bark, int(p.roots), float(radius.call(0.0)), roots, Color(0.68, 0.68, 0.66))
		_fan_boot(leaves, shape, p, lod, sway_top)
		for frond: Dictionary in fronds:
			_fan_frond(bark, leaves, frond, crown, lod, sway_top)
		if lod == 0:
			for spear: Dictionary in spears:
				_fan_spear(leaves, spear, top, sway_top)
		for card: Dictionary in skirt:
			if lod == 0 or int(card.index) % 2 == 0:
				_fan_skirt_card(leaves, card, top, boot_radius, lod, sway_top)
		bark.commit(mesh, material("fan_palm_bark"))
		leaves.commit(mesh, material("fan_palm_foliage"))
		meshes.append(mesh)
	var middle := _palm_axis(shape, 0.5)
	return {
		"lod0": meshes[0],
		"lod1": meshes[1],
		"shape": shape,
		"radius": radius,
		"crown_surface": 1,
		"top_m": crown.y + float(p.blade) * 0.6,
		# The trunk to the crown in two capsules, so a jetpack flight meets the
		# leaning trunk but never the crown.
		"capsules": [
			{"radius_m": float(radius.call(0.4)), "from": Vector3.ZERO, "to": middle},
			{"radius_m": float(p.radius_top) + 0.02, "from": middle, "to": top - Vector3.UP * 0.2},
		],
	}


## The criss-cross sleeve of old leaf bases under the crown.
func _fan_boot(s: Surf, shape: Dictionary, p: Dictionary, lod: int, sway_top: float) -> void:
	var height := float(shape.height)
	var length := float(p.boot)
	var sides := 12 if lod == 0 else 6
	var rows := 5 if lod == 0 else 2
	var rings: Array[int] = []
	for j in rows + 1:
		var f := float(j) / rows
		var h := height - length + f * (length + 0.25)
		var t := minf(h / height, 1.0)
		var center := _palm_axis(shape, t) + Vector3(0.0, maxf(0.0, h - height), 0.0)
		# Swells out a little over the leaf bases, then narrows into the crown.
		var radius := float(p.radius_top) + 0.02 + 0.1 * sin(f * PI * 0.8)
		var shade := lerpf(0.9, 0.74, f)
		rings.append(s.verts.size())
		for k in sides + 1:
			var angle := TAU * k / sides
			var direction := Vector3(cos(angle), 0.0, sin(angle))
			var uv := FAN_BOOT.position + Vector2(float(k) / sides, 1.0 - f) * FAN_BOOT.size
			s.add(center + direction * radius, direction + Vector3(0.0, 0.25, 0.0), uv, Color(shade, shade, shade), Vector2(sway_top * t * t, 0.0))
	for j in rows:
		for k in sides:
			var a := rings[j] + k
			s.quad(a, a + 1, rings[j + 1] + k + 1, rings[j + 1] + k, s.normals[a])


## A small, tight crown: young fronds stand up, the oldest live ones only reach
## a little below horizontal (no hanging dark mop), and few have yellowed.
func _fan_fronds(p: Dictionary, rng: RandomNumberGenerator, top: Vector3) -> Array:
	var fronds := []
	var count := int(p.fronds)
	for i in count:
		var age := float(i) / float(maxi(1, count - 1))  # 0 youngest (top) .. 1 oldest
		var azimuth := i * deg_to_rad(137.508) + rng.randf_range(-0.25, 0.25)
		var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
		fronds.append({
			"age": age,
			"azimuth": azimuth,
			"elevation": deg_to_rad(lerpf(64.0, -14.0, pow(age, 0.85)) + rng.randf_range(-6.0, 6.0)),
			"attach": top + out * 0.1 + Vector3(0.0, 0.42 - age * 0.5, 0.0),
			"petiole": float(p.petiole) * lerpf(0.85, 1.1, age) * rng.randf_range(0.92, 1.08),
			"blade": float(p.blade) * rng.randf_range(0.9, 1.05),
			"roll": rng.randf_range(-0.35, 0.35),
			"old": age > 0.8 and rng.randf() < 0.4,
			"shade": rng.randf_range(0.93, 1.05),
		})
	return fronds


func _fan_frond(bark: Surf, leaves: Surf, f: Dictionary, crown: Vector3, lod: int, sway_top: float) -> void:
	var azimuth: float = f.azimuth
	var elevation: float = f.elevation
	var age: float = f.age
	var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
	var direction := out * cos(elevation) + Vector3.UP * sin(elevation)
	var start: Vector3 = f.attach
	var length: float = f.petiole
	# Petioles sag under the blade's weight, older ones a little more.
	var sag := Vector3(0.0, -(0.05 + 0.2 * age) * length, 0.0)
	var middle := start + direction * length * 0.5 + sag * 0.35
	var end := start + direction * length + sag
	var crown_wind := Vector2(sway_top, 0.0)
	if lod == 0:
		var stalk := Color(0.6, 0.58, 0.5)
		_tube(bark, PackedVector3Array([start, middle, end]), PackedFloat32Array([0.04, 0.032, 0.022]), PackedColorArray([stalk, stalk, stalk]),
			PackedVector2Array([crown_wind, crown_wind + Vector2(0.0, 0.01), crown_wind + Vector2(0.0, 0.025)]), 3, 1.0, 1.2)
	# The blade continues outward from the petiole, held a little lower on older fronds.
	var tangent := (end - middle).normalized()
	var blade_elevation := atan2(tangent.y, Vector2(tangent.x, tangent.z).length()) - deg_to_rad(6.0 + 10.0 * age)
	var along := out * cos(blade_elevation) + Vector3.UP * sin(blade_elevation)
	var side := Vector3(-sin(azimuth), 0.0, cos(azimuth))
	var normal := side.cross(along).normalized()
	side = side.rotated(along, float(f.roll))
	normal = normal.rotated(along, float(f.roll))
	var size: float = f.blade
	var cell: Rect2 = FAN_OLD if bool(f.old) else FAN_LIVE
	# The oldest live fronds turn a little olive before they die into the skirt.
	var tint := Color.WHITE.lerp(Color(1.0, 0.94, 0.8), clampf((age - 0.8) / 0.2, 0.0, 1.0)) if bool(f.old) else Color.WHITE
	var columns := 4 if lod == 0 else 2
	var rows := 4 if lod == 0 else 1
	var base := leaves.verts.size()
	for j in rows + 1:
		# Distance along the blade from the hastula, in blade sizes.
		var y := lerpf(FAN_HASTULA - 1.0, FAN_HASTULA, float(j) / rows)
		for i in columns + 1:
			var x := lerpf(-0.5, 0.5, float(i) / columns)
			var r := sqrt(x * x + maxf(y, 0.0) * maxf(y, 0.0))
			# The halves fold up from the midrib; the segment tips droop a little.
			var lift := 0.16 * absf(x) - 0.45 * pow(maxf(r - 0.3, 0.0), 2.0)
			var position := end + side * (x * size) + along * (y * size) + normal * (lift * size)
			position.y -= 0.08 * age * r * r * size
			var n := normal * 0.45 + (position - crown).normalized() * 0.55
			# Lit through: no heavy darkening of the lower fronds.
			var shade := clampf(0.8 + 0.2 * (position.y - crown.y + 1.5) / 2.2, 0.8, 1.0) * float(f.shade)
			leaves.add(position, n, cell.position + Vector2(x + 0.5, FAN_HASTULA - y) * cell.size, Color(shade * tint.r, shade * tint.g, shade * tint.b), crown_wind + Vector2(0.0, 0.02 + 0.08 * r))
	for j in rows:
		for i in columns:
			var a := base + j * (columns + 1) + i
			leaves.quad(a, a + 1, a + columns + 2, a + columns + 1, normal)


## An unopened leaf standing up from the centre: the middle strip of the fan.
func _fan_spear(s: Surf, spear: Dictionary, top: Vector3, sway_top: float) -> void:
	var azimuth: float = spear.azimuth
	var tilt: float = spear.tilt
	var up := Vector3(cos(azimuth) * sin(tilt), cos(tilt), sin(azimuth) * sin(tilt))
	var side := Vector3(-sin(azimuth), 0.0, cos(azimuth))
	var base := top + Vector3(0.0, 0.32, 0.0)
	var length: float = spear.length
	var cell := Rect2(FAN_LIVE.position + Vector2(0.44, 0.02) * FAN_LIVE.size, Vector2(0.12, FAN_HASTULA - 0.02) * FAN_LIVE.size)
	var first := s.verts.size()
	for corner: Vector2 in [Vector2(-0.5, 0.0), Vector2(0.5, 0.0), Vector2(0.5, 1.0), Vector2(-0.5, 1.0)]:
		var position := base + side * corner.x * 0.14 + up * corner.y * length
		s.add(position, (side.cross(up) + Vector3.UP).normalized(), cell.position + Vector2(corner.x + 0.5, 1.0 - corner.y) * cell.size, Color(0.92, 0.92, 0.92), Vector2(sway_top, 0.03 * corner.y))
	s.quad(first, first + 1, first + 2, first + 3, side.cross(up))


## A short skirt of dead fronds held close under the crown.
func _fan_skirt(p: Dictionary, rng: RandomNumberGenerator) -> Array:
	var cards := []
	var count := int(p.skirt_cards)
	for i in count:
		cards.append({
			"index": i,
			"azimuth": TAU * i / count + rng.randf_range(-0.18, 0.18),
			"drop": 0.08 + (i % 2) * 0.22 + rng.randf_range(0.0, 0.12),
			"length": float(p.skirt) * rng.randf_range(0.75, 1.08),
			"flare": rng.randf_range(0.05, 0.13),
			"cell": rng.randi_range(0, 1),
			"shade": rng.randf_range(0.82, 1.0),
		})
	return cards


func _fan_skirt_card(s: Surf, card: Dictionary, top: Vector3, ring_radius: float, lod: int, sway_top: float) -> void:
	var azimuth: float = card.azimuth
	var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
	var side := Vector3(-sin(azimuth), 0.0, cos(azimuth))
	var length: float = card.length
	var width := length * 0.36
	var cell: Rect2 = FAN_DEAD[int(card.cell)]
	var anchor := top + out * ring_radius + Vector3(0.0, 0.22 - float(card.drop), 0.0)
	var rows := 3 if lod == 0 else 1
	var base := s.verts.size()
	for j in rows + 1:
		var f := float(j) / rows
		var bulge := sin(f * PI) * 0.06 + float(card.flare) * f
		for i in 3:
			var x := (i - 1) * 0.5
			# Hangs close to the trunk, bowing out a little and wrapping round it.
			var position := anchor + side * (x * width) + out * (bulge - 0.35 * x * x) + Vector3.DOWN * (f * length)
			var shade := lerpf(0.72, 0.95, f) * float(card.shade)
			s.add(position, out + Vector3(0.0, 0.3, 0.0) + side * x * 0.6, cell.position + Vector2(x + 0.5, f) * cell.size, Color(shade, shade, shade), Vector2(sway_top, 0.015 * f))
	for j in rows:
		for i in 2:
			var a := base + j * 3 + i
			s.quad(a, a + 1, a + 4, a + 3, out)


# --- Canary Island date palm --------------------------------------------------------------


func _build_canary_palm(p: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var shape := _palm_shape(p, rng)
	var height := float(p.height)
	var knob := float(p.knob)
	var knob_radius := float(p.knob_radius)
	var top := _palm_axis(shape, 1.0)
	var axis_top := (_palm_axis(shape, 1.0) - _palm_axis(shape, 0.96)).normalized()
	var knob_top := top + axis_top * knob
	var sway_top := PALM_SWAY * (height + knob)
	var crown := knob_top + Vector3(0.0, 0.2, 0.0)
	var radius := func(h: float) -> float:
		var t := clampf(h / height, 0.0, 1.0)
		return lerpf(float(p.radius_low), float(p.radius_top), t) + float(p.flare) * exp(-maxf(h, 0.0) / 0.3)
	var shade := func(h: float) -> Color:
		var ao := lerpf(0.74, 1.0, clampf(h / 0.8, 0.0, 1.0))
		return Color(ao, ao, ao)
	var knob_radius_at := func(f: float) -> float:
		# Swells from the trunk into the knob, then narrows into the crown.
		var swell := lerpf(float(p.radius_top), knob_radius, smoothstep(0.0, 0.45, f))
		return swell - knob_radius * 0.42 * smoothstep(0.62, 1.0, f)
	var fronds := []
	var count := int(p.fronds)
	for i in count:
		var age := float(i) / float(maxi(1, count - 1))
		var length := float(p.frond) * lerpf(0.82, 1.08, smoothstep(0.0, 0.35, age)) * rng.randf_range(0.93, 1.07)
		var attach_f := 1.0 - 0.55 * age
		var azimuth := i * deg_to_rad(137.508) + rng.randf_range(-0.2, 0.2)
		fronds.append({
			"age": age,
			"azimuth": azimuth,
			# A full, rounded crown: young fronds rise, the middle ones spread level and
			# arch over, the oldest (the trimmed palms' lowest) hang to about 40 degrees.
			"elevation": deg_to_rad(lerpf(60.0, float(p.get("low", -24.0)), pow(age, 0.75)) + rng.randf_range(-7.0, 7.0)),
			"attach": top + axis_top * knob * attach_f + Vector3(cos(azimuth), 0.0, sin(azimuth)) * float(knob_radius_at.call(attach_f)) * 0.8,
			"length": length,
			"droop": lerpf(0.1, float(p.get("droop", 0.4)), age) * rng.randf_range(0.85, 1.15),
			"width": length * float(p.get("width", 0.21)) * rng.randf_range(0.9, 1.04),
			"fold": deg_to_rad(rng.randf_range(22.0, 34.0)),
			"cell": rng.randi_range(0, 1),
			"shade": rng.randf_range(0.9, 1.06),
		})
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var bark := Surf.new()
		var knob_surf := Surf.new()
		var leaves := Surf.new()
		_palm_trunk(bark, shape, 18 if lod == 0 else 6, 14 if lod == 0 else 7, radius, CANARY_BARK_M, sway_top * pow(height / (height + knob), 2.0), shade)
		if p.has("shag"):
			_shag_trunk(bark, shape, radius, float(p.shag), int(p.seed))
		_canary_knob(knob_surf, top, axis_top, knob, knob_radius_at, 9 if lod == 0 else 4, 14 if lod == 0 else 7, sway_top, height, knob)
		for f_index in fronds.size():
			if lod == 0 or f_index % 2 == 0:
				_canary_frond(leaves, fronds[f_index], crown, 7 if lod == 0 else 3, sway_top)
		bark.commit(mesh, material("canary_bark"))
		knob_surf.commit(mesh, material("canary_knob"))
		leaves.commit(mesh, material("canary_foliage"))
		meshes.append(mesh)
	return {
		"lod0": meshes[0],
		"lod1": meshes[1],
		"shape": shape,
		"radius": radius,
		"knob": {"top": top, "axis": axis_top, "length": knob, "radius": knob_radius_at},
		"crown_surface": 2,
		"top_m": crown.y + float(p.frond) * 0.75,
		"capsules": [
			{"radius_m": float(radius.call(0.5)), "from": Vector3.ZERO, "to": top},
			{"radius_m": knob_radius * 0.92, "from": top, "to": knob_top - axis_top * 0.3},
		],
	}


## Knobbles a mature palm's trunk (every vertex of s so far, the trunk alone):
## each pushed out along its normal by up to shag of the radius there, in lumps
## round and along the trunk and in the stepped ledges of the old leaf bases, so
## its outline is shaggy rather than a smooth column. The lumps come from the
## seed, so both levels match.
func _shag_trunk(s: Surf, shape: Dictionary, radius: Callable, shag: float, seed: int) -> void:
	var phase := Vector2(_hash01(seed, 1, 0) * TAU, _hash01(seed, 2, 0) * TAU)
	var height := float(shape.height)
	for index in s.verts.size():
		var position := s.verts[index]
		if position.y < 0.05 or position.y > height:
			continue
		var normal := s.normals[index]
		var angle := atan2(normal.z, normal.x)
		var h := position.y
		var lump := 0.55 * sin(3.0 * angle + 1.7 * h + phase.x) + 0.45 * sin(5.0 * angle - 2.9 * h + phase.y)
		# The ledges of the trimmed leaf bases, about every quarter metre up the trunk.
		var ledge := fposmod(h / 0.26 + 0.35 * sin(2.0 * angle + phase.x), 1.0) - 0.5
		var fade := clampf(h / 0.6, 0.0, 1.0)
		s.verts[index] = position + normal * (shag * float(radius.call(h)) * fade * (0.6 * lump + 0.8 * ledge))


## The trimmed leaf bases under the crown: a swelling "pineapple" of stubs.
func _canary_knob(s: Surf, top: Vector3, axis: Vector3, length: float, radius_at: Callable, rows: int, sides: int, sway_top: float, height: float, knob: float) -> void:
	var points := PackedVector3Array()
	var radii := PackedFloat32Array()
	var colors := PackedColorArray()
	var winds := PackedVector2Array()
	for j in rows + 1:
		var f := float(j) / rows
		points.append(top + axis * (length * f))
		radii.append(float(radius_at.call(f)))
		var shade := lerpf(0.86, 0.66, f)
		colors.append(Color(shade, shade, shade))
		var t := (height + knob * f) / (height + knob)
		winds.append(Vector2(sway_top * t * t, 0.0))
	_tube(s, points, radii, colors, winds, sides, maxf(1.0, roundf(TAU * float(radius_at.call(0.5)) / CANARY_KNOB_M)), CANARY_KNOB_M)


## One pinnate frond: a ribbon along the arching rachis, folded up into a V
## (the leaflets rise from the midrib), the frond image from its bare petiole
## at the knob to its tip.
func _canary_frond(s: Surf, f: Dictionary, crown: Vector3, segments: int, sway_top: float) -> void:
	var azimuth: float = f.azimuth
	var elevation: float = f.elevation
	var length: float = f.length
	var droop: float = f.droop
	var half: float = float(f.width) * 0.5
	var fold: float = f.fold
	var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
	var side := Vector3(-sin(azimuth), 0.0, cos(azimuth))
	var direction := out * cos(elevation) + Vector3.UP * sin(elevation)
	var start: Vector3 = f.attach
	var cell: Rect2 = CANARY_FRONDS[int(f.cell)]
	var age: float = f.age
	var base := s.verts.size()
	for j in segments + 1:
		var t := float(j) / segments
		var position := start + direction * (t * length) + Vector3.DOWN * (droop * length * t * t)
		var tangent := (direction * length + Vector3.DOWN * (2.0 * droop * length * t)).normalized()
		var up := side.cross(tangent).normalized()
		if up.y < 0.0:
			up = -up
		var left := (side * cos(fold) + up * sin(fold)) * half
		var right := (-side * cos(fold) + up * sin(fold)) * half
		var outward := (position - crown).normalized()
		var height_shade := clampf(0.78 + 0.22 * (position.y - crown.y + 2.0) / 3.0, 0.7, 1.0)
		var shade := height_shade * float(f.shade) * lerpf(1.0, 0.86, age)
		var color := Color(shade, shade, shade)
		var wind := Vector2(sway_top, 0.03 + 0.14 * pow(t, 1.5))
		var v := cell.position.y + (1.0 - t) * cell.size.y
		s.add(position + left, (up * 0.5 + outward * 0.5 + side * 0.15), Vector2(cell.position.x, v), color * 0.97, wind)
		s.add(position, (up * 0.6 + outward * 0.4), Vector2(cell.position.x + cell.size.x * 0.5, v), color * 0.9, wind)
		s.add(position + right, (up * 0.5 + outward * 0.5 - side * 0.15), Vector2(cell.end.x, v), color * 0.97, wind)
	for j in segments:
		var a := base + j * 3
		var b := a + 3
		var facing := side.cross((s.verts[b + 1] - s.verts[a + 1]).normalized())
		if facing.y < 0.0:
			facing = -facing
		s.quad(a, a + 1, b + 1, b, facing)
		s.quad(a + 1, a + 2, b + 2, b + 1, facing)


# --- Monterey cypress --------------------------------------------------------------------------


func _build_cypress(p: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var skeleton := _cypress_skeleton(p, rng) if str(p.form) == "old" else _cypress_young_skeleton(p, rng)
	var cards := _cypress_cards(rng, skeleton.clusters, str(p.form) == "young", float(skeleton.get("card_scale", 1.0)))
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
	var trunk_radius := float(p.trunk_radius)
	var fork := float(p.get("fork", 1.2))
	return {
		"lod0": meshes[0],
		"lod1": meshes[1],
		"crown_surface": -1,
		"top_m": float(p.height),
		"capsules": [{"radius_m": trunk_radius * 1.15, "from": Vector3.ZERO, "to": Vector3(0.0, fork, 0.0)}],
	}


## Trunk, leaders and side branches of an old wind-shaped cypress, plus the
## foliage clouds they carry.
func _cypress_skeleton(p: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var wind := Vector3(CYPRESS_LEE.x, 0.0, CYPRESS_LEE.y).normalized()
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
		"points": PackedVector3Array([Vector3.DOWN * BURY_M, Vector3(0.0, 0.45, 0.0), fork * 0.55, fork, fork + Vector3(0.0, 0.5, 0.0) + wind * 0.08]),
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
	for i in 3:
		var angle := TAU * i / 3 + rng.randf_range(-0.3, 0.3)
		var out := Vector3(cos(angle), 0.0, sin(angle))
		var distance := radius * rng.randf_range(0.25, 0.45) * (1.0 + float(p.shear) * out.dot(wind))
		var center := out * distance + Vector3(0.0, height * rng.randf_range(0.8, 0.88), 0.0) + wind * radius * 0.1
		clusters.append(_cloud(center, rng.randf_range(2.6, 3.2), rng.randf_range(0.55, 0.7), out.dot(wind), height))
	return {"branches": branches, "clusters": clusters, "crown": _cloud_centroid(clusters), "radius": radius, "height": height}


## A young cypress: one leaning stem with short ascending branches, each ending
## in a ragged tuft, so the crown reads as an irregular dark cone with gaps
## rather than a clipped hedge. A tree smaller than the 4.6 m plaza one has
## tufts and cards shrunk with it (card_scale).
func _cypress_young_skeleton(p: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var height := float(p.height)
	var radius := float(p.spread) * 0.5
	var trunk_radius := float(p.trunk_radius)
	var shrink := clampf(height / 4.6, 0.5, 1.0)
	var lean := Vector3(rng.randf_range(-0.25, 0.25), 0.0, rng.randf_range(-0.25, 0.25))
	var stem := PackedVector3Array()
	var radii := PackedFloat32Array()
	for i in 6:
		var s := float(i) / 5.0
		stem.append(Vector3.DOWN * BURY_M * (1.0 - s) + Vector3.UP * (height * 0.9 * s) + lean * s * s)
		radii.append(lerpf(trunk_radius * 1.3, 0.025, pow(s, 0.8)))
	var branches := [{"depth": 0, "points": stem, "radii": radii}]
	var clusters := []
	var tiers := 8
	var phase := rng.randf() * TAU
	for tier in tiers:
		var f := (float(tier) + rng.randf_range(0.2, 0.8)) / tiers
		# Feathered almost to the ground, as the young plaza cypresses are (Sep 2025).
		var y := lerpf(0.3, height * 0.86, f)
		# Widest low down, tapering unevenly to a pointed leader.
		var reach := radius * (1.0 - f * 0.88) * rng.randf_range(0.75, 1.1)
		var count := 3 if f < 0.7 else 2
		for k in count:
			var angle := phase + TAU * (k + 0.5 * tier) / count + rng.randf_range(-0.5, 0.5)
			var out := Vector3(cos(angle), 0.0, sin(angle))
			var origin := lean * f * f + Vector3.UP * maxf(0.15, y - 0.3)
			var tip := origin + out * reach + Vector3.UP * rng.randf_range(0.2, 0.5)
			branches.append({"depth": 2, "points": PackedVector3Array([origin, origin.lerp(tip, 0.55) + Vector3.UP * 0.1, tip]), "radii": PackedFloat32Array([0.035, 0.025, 0.012])})
			clusters.append({"center": tip, "reach": maxf(0.38 * shrink, reach * rng.randf_range(0.45, 0.62)), "half_height": rng.randf_range(0.3, 0.48) * shrink})
	clusters.append({"center": lean + Vector3.UP * (height * 0.93), "reach": 0.32 * shrink, "half_height": 0.42 * shrink})
	return {"branches": branches, "clusters": clusters, "crown": _cloud_centroid(clusters), "radius": radius, "height": height, "young": true, "card_scale": shrink}


func _cloud_centroid(clusters: Array) -> Vector3:
	var crown := Vector3.ZERO
	for cloud: Dictionary in clusters:
		crown += cloud.center
	return crown / maxf(1.0, clusters.size())


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


## Foliage cards for the clouds: wind-flattened plates, and upright clumps
## round their rims (a young tree has only the clumps, card_scale their size).
func _cypress_cards(rng: RandomNumberGenerator, clusters: Array, young: bool, card_scale := 1.0) -> Array:
	var cards := []
	for cloud: Dictionary in clusters:
		var center: Vector3 = cloud.center
		var reach: float = cloud.reach
		var half_height: float = cloud.half_height
		# A young tree is all upright clumps: a flat plate would show edge-on as a stray card.
		var plates := 0 if young else clampi(int(round(reach * reach * 2.8)), 6, 26)
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
		var clumps := clampi(int(round(reach * 7.0)), 5, 9) if young else maxi(2, plates / 4)
		for i in clumps:
			var angle := rng.randf() * TAU
			var out := Vector3(cos(angle), 0.0, sin(angle))
			cards.append({
				"kind": "clump",
				"center": center + out * reach * rng.randf_range(0.6, 0.9) + Vector3(0.0, rng.randf_range(-0.2, 0.3) * half_height, 0.0),
				"normal": (out + Vector3(0.0, rng.randf_range(0.1, 0.45), 0.0)).normalized(),
				"spin": rng.randf_range(-0.3, 0.3),
				"size": rng.randf_range(0.9, 1.3) * card_scale if young else rng.randf_range(1.0, 1.5),
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
	var winds := PackedVector2Array()
	var height := float(p.height)
	var fork := float(p.get("fork", 1.0))
	for point in points:
		# Daylit lower trunk, shaded limbs inside the canopy.
		var ao := lerpf(0.9, 0.5, clampf((point.y - fork) / maxf(0.5, height * 0.6 - fork), 0.0, 1.0)) * lerpf(0.75, 1.0, clampf(point.y / 0.5, 0.0, 1.0))
		colors.append(Color(ao, ao, ao))
		winds.append(Vector2(CYPRESS_SWAY * height * pow(clampf(point.y / height, 0.0, 1.0), 2.0), 0.0))
	var sides: int = [[12, 8, 5], [7, 5, 4]][lod][depth]
	_tube(s, points, radii, colors, winds, sides, maxf(1.0, roundf(TAU * radii[0] / CYPRESS_BARK_M)), CYPRESS_BARK_M)


func _cypress_card(s: Surf, card: Dictionary, skeleton: Dictionary, lod: int) -> void:
	var normal: Vector3 = card.normal
	var plate: bool = card.kind == "plate"
	var size: float = card.size * (1.55 if lod == 1 else 1.0)
	var across: Vector3
	if plate:
		across = Vector3.RIGHT.cross(normal).normalized().rotated(normal, float(card.spin))
	else:
		across = Vector3.UP.cross(normal).normalized().rotated(normal, float(card.spin))
	var upward := normal.cross(across)
	var cell := CYPRESS_PLATE if plate else CYPRESS_CLUMP
	var cloud: Dictionary = card.cloud
	var cloud_center: Vector3 = cloud.center
	var half_height: float = cloud.half_height
	var crown: Vector3 = skeleton.crown
	var radius: float = skeleton.radius
	var height: float = skeleton.height
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
			if skeleton.get("young", false):
				# Young cypresses photograph darker than the old crowns' sunlit tops.
				shade *= 0.74
			var sway := CYPRESS_SWAY * height * pow(clampf(position.y / height, 0.0, 1.0), 2.0)
			s.add(position, n, cell.position + Vector2(x + 0.5, 0.5 - y) * cell.size, Color(shade, shade, shade), Vector2(sway, 0.012))
	for j in grid:
		for i in grid:
			var a := base + j * (grid + 1) + i
			s.quad(a, a + 1, a + grid + 2, a + grid + 1, normal)


# --- Young Sydney blue gum ------------------------------------------------------------------------


## A young Sydney blue gum: a slender pale trunk with a lean and a slight bend,
## bare at the bottom, and ascending branches through its upper part, each with
## hanging sprays of lance leaves (two crossed cards per spray) along its outer
## half, and two sprays on the leader. The crown is narrow and ragged, as the
## wind-tossed windrow trees are; a few sprays carry reddish young leaves.
func _build_gum(p: Dictionary) -> Dictionary:
	if p.has("stems"):
		return _build_mature_gum(p)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var height := float(p.height)
	var trunk_radius := float(p.trunk_radius)
	# Leaning downwind: the prevailing westerly pushes the windrows east (+X).
	var lean_angle := rng.randf_range(-0.6, 0.6)
	var lean := Vector3(cos(lean_angle), 0.0, sin(lean_angle)) * float(p.lean)
	var bow_angle := lean_angle + rng.randf_range(1.2, 2.0)
	var bow := Vector3(cos(bow_angle), 0.0, sin(bow_angle)) * float(p.lean) * 0.3
	var sway_top := GUM_SWAY * height
	var stem := PackedVector3Array([Vector3.DOWN * BURY_M])
	var stem_radii := PackedFloat32Array([trunk_radius * 1.3])
	for i in 9:
		var t := float(i) / 8.0
		stem.append(_gum_axis(height, lean, bow, t))
		# A little flare at the foot, tapering to a whip at the top.
		stem_radii.append(lerpf(trunk_radius, 0.012, pow(t, 0.85)) + trunk_radius * 0.3 * exp(-t * height / 0.25))
	var clear := float(p.clear)
	var half := float(p.crown) * 0.5
	var count := int(p.branches)
	var spray_size := 0.5 + 0.06 * height
	var branches := []
	var sprays := []
	var phase := rng.randf() * TAU
	for b in count:
		var f := (float(b) + rng.randf_range(0.15, 0.85)) / count
		var origin := _gum_axis(height, lean, bow, lerpf(clear, 0.9, f))
		var azimuth := phase + b * GOLDEN_ANGLE + rng.randf_range(-0.4, 0.4)
		var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
		# Longest in the lower crown, short near the top, steeply ascending; the
		# wind-tossed crowns reach a little further downwind (east, +X).
		var reach := half * lerpf(1.05, 0.45, f) * rng.randf_range(0.8, 1.15) * (1.0 + 0.3 * out.x)
		var rise := deg_to_rad(rng.randf_range(35.0, 62.0))
		var tip := origin + out * reach + Vector3.UP * (reach * tan(rise))
		var middle := origin.lerp(tip, 0.5) + out * (reach * 0.1)
		var base_radius := lerpf(trunk_radius * 0.5, 0.014, f)
		branches.append({"points": PackedVector3Array([origin, middle, tip]), "radii": PackedFloat32Array([base_radius, base_radius * 0.6, 0.006]), "big": f < 0.7})
		var along := [0.35, 0.6, 0.8, 1.0] if reach > half * 0.8 else ([0.55, 0.8, 1.0] if reach > half * 0.5 else [0.7, 1.0])
		for k in along.size():
			var at := origin.lerp(tip, float(along[k]))
			sprays.append({
				"at": at + Vector3.DOWN * 0.04,
				"azimuth": azimuth + rng.randf_range(-0.5, 0.5),
				"size": spray_size * rng.randf_range(0.85, 1.15) * lerpf(1.0, 0.8, f),
				"young": k == along.size() - 1 and f > 0.5 and rng.randf() < 0.25,
				"shade": rng.randf_range(0.9, 1.08),
			})
	# Short shoots on the trunk itself fill the crown between the branches.
	for k in 4:
		var at := _gum_axis(height, lean, bow, lerpf(clear + 0.08, 0.85, (float(k) + 0.5) / 4.0))
		sprays.append({"at": at, "azimuth": phase + k * 2.1 + rng.randf_range(-0.5, 0.5), "size": spray_size * 0.8, "young": false, "shade": 0.85})
	var top := _gum_axis(height, lean, bow, 1.0)
	for k in 2:
		sprays.append({"at": top + Vector3.UP * 0.12, "azimuth": phase + PI * k + rng.randf_range(-0.4, 0.4), "size": spray_size * 0.85, "young": k == 0, "shade": 1.04})
	var crown := Vector3.ZERO
	for spray: Dictionary in sprays:
		crown += spray.at
	crown /= maxf(1.0, sprays.size())
	var low_y := _gum_axis(height, lean, bow, clear).y
	# The stakes stand across the lean, so the trunk leans between them.
	var stake_side := Vector3(-lean.z, 0.0, lean.x).normalized() * STAKE_SPACING_M * 0.5
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var bark := Surf.new()
		var leaves := Surf.new()
		var colors := PackedColorArray()
		var winds := PackedVector2Array()
		for point in stem:
			var ao := lerpf(0.78, 1.0, clampf(point.y / 0.6, 0.0, 1.0)) * lerpf(1.0, 0.8, clampf((point.y - low_y) / maxf(0.5, height - low_y), 0.0, 1.0))
			colors.append(Color(ao, ao, ao))
			winds.append(Vector2(sway_top * pow(clampf(point.y / height, 0.0, 1.0), 2.0), 0.0))
		if lod == 0:
			_tube(bark, stem, stem_radii, colors, winds, 10, maxf(1.0, roundf(TAU * trunk_radius / GUM_BARK_M)), GUM_BARK_M)
		else:
			var points := PackedVector3Array()
			var radii := PackedFloat32Array()
			var ring_colors := PackedColorArray()
			var ring_winds := PackedVector2Array()
			for i in [0, 1, 3, 5, 7, 9]:
				points.append(stem[i])
				radii.append(stem_radii[i])
				ring_colors.append(colors[i])
				ring_winds.append(winds[i])
			_tube(bark, points, radii, ring_colors, ring_winds, 6, 1.0, GUM_BARK_M)
		for branch: Dictionary in branches:
			if lod == 1 and not bool(branch.big):
				continue
			var points: PackedVector3Array = branch.points
			var branch_colors := PackedColorArray()
			var branch_winds := PackedVector2Array()
			for point in points:
				var shade := lerpf(0.7, 0.95, clampf((point.y - low_y) / maxf(0.5, height - low_y), 0.0, 1.0))
				branch_colors.append(Color(shade, shade, shade))
				branch_winds.append(Vector2(sway_top * pow(clampf(point.y / height, 0.0, 1.0), 2.0), 0.005))
			_tube(bark, points, branch.radii, branch_colors, branch_winds, 5 if lod == 0 else 3, 1.0, GUM_BARK_M)
		for index in sprays.size():
			# The far level keeps two sprays in three at nearly their size, so the
			# crown stays narrow and open instead of filling into a round head.
			if lod == 1 and index % 3 == 2:
				continue
			var spray: Dictionary = sprays[index]
			for card in 2:
				_gum_spray_card(leaves, spray, float(spray.azimuth) + card * PI * 0.5, float(spray.size) * (1.15 if lod == 1 else 1.0), crown, half, low_y, height, sway_top)
		_gum_stakes(bark, stake_side, lod)
		bark.commit(mesh, material("gum_bark"))
		leaves.commit(mesh, material("young_tree_foliage"))
		meshes.append(mesh)
	return {
		"lod0": meshes[0],
		"lod1": meshes[1],
		"crown_surface": -1,
		"top_m": top.y + spray_size * 0.2,
		"capsules": [
			{"radius_m": trunk_radius * 1.15, "from": Vector3.ZERO, "to": _gum_axis(height, lean, bow, minf(clear, 2.2 / height))},
			{"radius_m": STAKE_RADIUS_M, "from": stake_side, "to": stake_side + Vector3.UP * STAKE_M},
			{"radius_m": STAKE_RADIUS_M, "from": -stake_side, "to": -stake_side + Vector3.UP * STAKE_M},
		],
	}


## The two tree stakes either side of the trunk, pale tan wood (the bark
## texture tinted), joined across the trunk by a tie near their tops.
func _gum_stakes(s: Surf, side: Vector3, lod: int) -> void:
	var wood := Color(0.86, 0.74, 0.56)
	var sides := 5 if lod == 0 else 4
	for sign: float in [1.0, -1.0]:
		var foot := side * sign
		_tube(s, PackedVector3Array([foot + Vector3.DOWN * BURY_M, foot + Vector3.UP * STAKE_M]), PackedFloat32Array([STAKE_RADIUS_M, STAKE_RADIUS_M * 0.9]),
			PackedColorArray([wood * 0.8, wood]), PackedVector2Array([Vector2.ZERO, Vector2.ZERO]), sides, 1.0, GUM_BARK_M)
	var tie_y := Vector3.UP * (STAKE_M - 0.35)
	_tube(s, PackedVector3Array([side + tie_y, -side + tie_y]), PackedFloat32Array([0.012, 0.012]), PackedColorArray([wood * 0.6, wood * 0.6]),
		PackedVector2Array([Vector2.ZERO, Vector2.ZERO]), 4, 1.0, GUM_BARK_M)


## The gum's trunk axis at t (0 foot .. 1 top): a lean growing toward the top plus a slight sideways bend.
func _gum_axis(height: float, lean: Vector3, bow: Vector3, t: float) -> Vector3:
	return Vector3.UP * (height * 0.93 * t) + lean * t * t + bow * sin(PI * t)


## One card of a hanging spray: the twig along its top edge at the spray's
## attachment, its leaves hanging below, facing azimuth. Darker low in the
## crown and toward the trunk; reddish when the spray holds young leaves.
func _gum_spray_card(s: Surf, spray: Dictionary, azimuth: float, size: float, crown: Vector3, half: float, low_y: float, height: float, sway_top: float) -> void:
	var facing := Vector3(cos(azimuth), 0.0, sin(azimuth))
	var across := Vector3(-facing.z, 0.0, facing.x)
	var at: Vector3 = spray.at
	# The leaves hang a little out from the twig, not straight down.
	var down := (Vector3.DOWN + facing * 0.15).normalized()
	var tint := Color(1.0, 0.88, 0.85) if bool(spray.young) else Color.WHITE
	var first := s.verts.size()
	for j in 2:
		for i in 2:
			var x := float(i) - 0.5
			var position := at + across * (x * size) + down * (float(j) * size)
			var height_f := clampf((position.y - low_y) / maxf(0.5, height - low_y), 0.0, 1.0)
			var outward := clampf(Vector2(position.x - crown.x, position.z - crown.z).length() / maxf(0.3, half), 0.0, 1.0)
			var c := float(spray.shade) * lerpf(0.62, 1.0, height_f) * lerpf(0.78, 1.0, outward)
			var n := ((position - crown).normalized() * 0.6 + facing * 0.4).normalized()
			var wind := Vector2(sway_top * pow(clampf(position.y / height, 0.0, 1.0), 2.0), 0.012 + 0.03 * float(j))
			s.add(position, n, GUM_SPRAY.position + Vector2(float(i), float(j)) * GUM_SPRAY.size, Color(c * tint.r, c * tint.g, c * tint.b), wind)
	s.quad(first, first + 1, first + 3, first + 2, facing)


# --- Young island oak ---------------------------------------------------------------------------------


## A young island oak: two or three stems from the ground, forking low into
## scaffold limbs, under a dense, irregular, rounded crown: a main lobe and a
## few smaller ones round it, each filled with crossed leaf-cluster cards,
## darker underneath and inside, so the outline is lumpy rather than a clipped ball.
func _build_oak(p: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var height := float(p.height)
	var crown_width := float(p.crown)
	var clear := float(p.clear)
	var trunk_radius := float(p.trunk_radius)
	var half := Vector3(crown_width * 0.5, (height - clear) * 0.5, crown_width * 0.5)
	var lopsided_angle := rng.randf() * TAU
	var center := Vector3(cos(lopsided_angle), 0.0, sin(lopsided_angle)) * crown_width * float(p.get("lopsided", 0.0)) + Vector3.UP * (clear + half.y)
	var sway_top := OAK_SWAY * height
	var phase := rng.randf() * TAU
	var lobes := [{"center": center, "half": half * 0.8}]
	var lobe_count := int(p.lobes)
	for k in lobe_count:
		var azimuth := phase + TAU * k / lobe_count + rng.randf_range(-0.4, 0.4)
		var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
		var lobe_half := half * rng.randf_range(0.42, 0.7)
		lobes.append({"center": center + out * half.x * rng.randf_range(0.38, 0.5) + Vector3.UP * half.y * rng.randf_range(-0.3, 0.45), "half": lobe_half})
	var stems := []
	var stem_count := int(p.stems)
	for k in stem_count:
		# The stems spread from one root crown, leaning out a little each.
		var out := Vector3(cos(phase + TAU * k / stem_count), 0.0, sin(phase + TAU * k / stem_count)) * (0.0 if stem_count == 1 else 1.0)
		var fork := Vector3(0.0, clear, 0.0) + out * 0.16
		var radius := trunk_radius * (1.0 if k == 0 else 0.8)
		stems.append({"points": PackedVector3Array([Vector3.DOWN * BURY_M + out * 0.02, out * 0.03, out * 0.06 + Vector3.UP * clear * 0.5, fork, fork + Vector3.UP * 0.25]),
			"radii": PackedFloat32Array([radius * 1.25, radius * 1.1, radius, radius * 0.85, radius * 0.6])})
	# Scaffold limbs from the fork out to each lobe.
	var limbs := []
	for lobe: Dictionary in lobes:
		var origin := Vector3(0.0, clear * rng.randf_range(0.9, 1.08), 0.0)
		var tip: Vector3 = (lobe.center as Vector3).lerp(origin, 0.25)
		limbs.append({"points": PackedVector3Array([origin, origin.lerp(tip, 0.5) + Vector3.UP * 0.12, tip]), "radii": PackedFloat32Array([trunk_radius * 0.6, trunk_radius * 0.4, 0.01])})
	# Leaf clusters through the crown's lobes, each of crossed cards: one facing
	# out from the lobe and one turned a quarter about the vertical (a cluster on
	# the crown's top, whose first card lies flat, gets two upright ones), so from
	# any side one card of a cluster faces the viewer and the outline is leaves,
	# not card edges. Most sit near the outside, some deeper in and darker.
	var cards := []
	var total := 0.0
	for lobe: Dictionary in lobes:
		total += pow((lobe.half as Vector3).x, 2.0)
	var cluster := 0
	for lobe: Dictionary in lobes:
		var lobe_center: Vector3 = lobe.center
		var lobe_half: Vector3 = lobe.half
		var count := maxi(4, int(round(float(p.cards) * 0.5 * pow(lobe_half.x, 2.0) / total)))
		for i in count:
			# Round the lobe from its top to its underside, the very bottom left open.
			var t := (float(i) + rng.randf_range(0.2, 0.8)) / count
			var polar := lerpf(0.15, 2.4, t)
			var azimuth := phase + i * GOLDEN_ANGLE + rng.randf_range(-0.3, 0.3)
			var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
			var unit := out * sin(polar) + Vector3.UP * cos(polar)
			var depth := lerpf(0.5, 0.86, sqrt(rng.randf()))
			var position := lobe_center + Vector3(unit.x * lobe_half.x, unit.y * lobe_half.y, unit.z * lobe_half.z) * depth
			var first := (Vector3(unit.x / lobe_half.x, unit.y / lobe_half.y, unit.z / lobe_half.z).normalized() + Vector3(rng.randf_range(-0.3, 0.3), rng.randf_range(-0.2, 0.3), rng.randf_range(-0.3, 0.3))).normalized()
			var normals: Array[Vector3] = [first]
			if absf(first.y) < 0.7:
				normals.append(first.rotated(Vector3.UP, PI * 0.5))
			else:
				var upright := first.rotated(first.cross(out).normalized(), PI * 0.5)
				normals.append(upright)
				normals.append(upright.rotated(Vector3.UP, PI * 0.5))
			var size := minf(0.62, lobe_half.x * rng.randf_range(0.48, 0.62))
			var shade := rng.randf_range(0.88, 1.04) * lerpf(0.72, 1.0, (depth - 0.5) / 0.36)
			for normal: Vector3 in normals:
				cards.append({"center": position, "normal": normal, "out": out, "size": size, "spin": rng.randf_range(-0.6, 0.6), "shade": shade, "cluster": cluster})
			cluster += 1
	var crown_low := center.y - half.y
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var bark := Surf.new()
		var leaves := Surf.new()
		for branch: Dictionary in stems + (limbs if lod == 0 else []):
			var points: PackedVector3Array = branch.points
			var colors := PackedColorArray()
			var winds := PackedVector2Array()
			for point in points:
				var ao := lerpf(0.72, 1.0, clampf(point.y / 0.5, 0.0, 1.0)) * lerpf(1.0, 0.6, clampf((point.y - clear * 0.8) / maxf(0.3, half.y), 0.0, 1.0))
				colors.append(Color(ao, ao, ao))
				winds.append(Vector2(sway_top * pow(clampf(point.y / height, 0.0, 1.0), 2.0), 0.0))
			_tube(bark, points, branch.radii, colors, winds, (8 if lod == 0 else 5) if branch in stems else 4, 1.0, OAK_BARK_M)
		for card: Dictionary in cards:
			# The far level keeps every other cluster, whole and a little larger.
			if lod == 1 and int(card.cluster) % 2 == 1:
				continue
			_shell_card(leaves, IDENTITY_FRAME, card.center, card.normal, card.out, float(card.size) * (1.3 if lod == 1 else 1.0), 0.0, OAK_CLUSTER, float(card.spin), center,
				crown_low, height, float(card.shade), Color.WHITE, 1.0, Vector2(sway_top, 0.015))
		bark.commit(mesh, material("oak_bark"))
		leaves.commit(mesh, material("young_tree_foliage"))
		meshes.append(mesh)
	return {
		"lod0": meshes[0],
		"lod1": meshes[1],
		"crown_surface": -1,
		"top_m": height,
		"capsules": [{"radius_m": trunk_radius * 1.2, "from": Vector3.ZERO, "to": Vector3(0.0, clear, 0.0)}],
	}


# --- Mature eucalyptus (the young gum grown up) -----------------------------------------------------------


## A mature eucalyptus (the Job Corps entrance tree, n2): two or three tall
## trunks leaning apart from near the ground, bare for about a third of their
## height, then branches climbing out at 35-60 degrees whose outer parts bend
## down, each carrying a mass of hanging tassels (crossed cards of drooping
## sickle leaves) at a few heights, so the crown is open and irregular, its
## tips drooping and its trunks showing through it. The young gum's trunk taper,
## bark and breeze, grown tall, without its stakes.
func _build_mature_gum(p: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var height := float(p.height)
	var half := float(p.crown) * 0.5
	var trunk_radius := float(p.trunk_radius)
	var clear := float(p.clear)
	var droop := float(p.droop)
	var sway_top := MATURE_GUM_SWAY * height
	var stems := int(p.stems)
	# Leaning downwind, as the windrow gums do (the prevailing westerly, east is +X).
	var lean_angle := rng.randf_range(-0.6, 0.6)
	var lean := Vector3(cos(lean_angle), 0.0, sin(lean_angle)) * float(p.lean)
	var phase := rng.randf() * TAU
	var branches := []
	var axes: Array[Dictionary] = []
	for k in stems:
		var azimuth := phase + TAU * k / stems + rng.randf_range(-0.3, 0.3)
		var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
		var base := out * 0.12
		var stem_height := height * (1.0 if k == 0 else rng.randf_range(0.82, 0.94))
		var top := base + out * half * rng.randf_range(0.18, 0.32) + lean * rng.randf_range(0.7, 1.1) + Vector3.UP * stem_height
		var radius := trunk_radius * (1.0 if k == 0 else rng.randf_range(0.75, 0.9))
		var axis := {"base": base, "top": top, "bow": Vector3(-out.z, 0.0, out.x) * rng.randf_range(-0.5, 0.5), "radius": radius, "out": out, "height": stem_height}
		axes.append(axis)
		var points := PackedVector3Array([base + Vector3.DOWN * BURY_M])
		var radii := PackedFloat32Array([radius * 1.35])
		for i in 9:
			var t := float(i) / 8.0
			points.append(_mature_gum_axis(axis, t))
			# A flare at the foot, tapering to a slender leader.
			radii.append(lerpf(radius, 0.03, pow(t, 0.9)) + radius * 0.3 * exp(-t * stem_height / 0.4))
		branches.append({"depth": 0, "points": points, "radii": radii})
	var count := int(p.branches)
	var per_stem := ceili(float(count) / stems)
	var tassels := []
	for b in count:
		var axis: Dictionary = axes[b % stems]
		var f := (float(b / stems) + rng.randf_range(0.1, 0.9)) / per_stem
		var origin := _mature_gum_axis(axis, lerpf(clear, 0.93, f))
		var azimuth := phase + b * GOLDEN_ANGLE + rng.randf_range(-0.4, 0.4)
		# Each stem's branches lean out on its own side of the crown.
		var out := (Vector3(cos(azimuth), 0.0, sin(azimuth)) + (axis.out as Vector3) * 0.5).normalized()
		# Longest low in the crown, short near the top: a crown much taller than wide.
		var reach := half * lerpf(1.05, 0.35, f) * rng.randf_range(0.75, 1.15)
		var climb := reach * tan(deg_to_rad(rng.randf_range(35.0, 60.0))) * 0.55
		var tip := origin + out * reach + Vector3.UP * (climb - droop * reach)
		var points := _bezier(origin, origin + out * reach * 0.15 + Vector3.UP * climb * 0.75, origin + out * reach * 0.7 + Vector3.UP * climb, tip, 5)
		branches.append({"depth": 1 if f < 0.7 else 2, "points": points, "radii": _taper(lerpf(float(axis.radius) * 0.5, 0.04, f), 0.012, points.size(), 0.8)})
		# A mass of tassels round the branch's outer part, hanging at a few heights.
		for m in 8 + int(round(reach * 1.8)):
			var at := _polyline_at(points, rng.randf_range(0.4, 1.0)) + Vector3(rng.randf_range(-0.7, 0.7), rng.randf_range(-0.3, 0.3), rng.randf_range(-0.7, 0.7))
			tassels.append({"at": at, "azimuth": azimuth + rng.randf_range(-1.2, 1.2), "size": rng.randf_range(0.9, 1.25) * (0.9 + 0.025 * height), "shade": rng.randf_range(0.86, 1.05)})
	# Each trunk ends in a tuft of tassels.
	for axis: Dictionary in axes:
		for m in 3:
			tassels.append({"at": (axis.top as Vector3) + Vector3(rng.randf_range(-0.3, 0.3), rng.randf_range(-0.1, 0.2), rng.randf_range(-0.3, 0.3)), "azimuth": phase + m * 2.1,
				"size": rng.randf_range(0.7, 0.9) * (0.85 + 0.02 * height), "shade": 1.05})
	var crown := Vector3.ZERO
	for tassel: Dictionary in tassels:
		crown += tassel.at
	crown /= maxf(1.0, tassels.size())
	var low_y := height * clear
	var cards := []
	for index in tassels.size():
		var tassel: Dictionary = tassels[index]
		var at: Vector3 = tassel.at
		var height_f := clampf((at.y - low_y) / maxf(1.0, height - low_y), 0.0, 1.0)
		var radial := clampf(Vector2(at.x - crown.x, at.z - crown.z).length() / maxf(0.5, half), 0.0, 1.0)
		var shade := float(tassel.shade) * lerpf(0.62, 1.0, height_f) * lerpf(0.8, 1.0, radial)
		var size := float(tassel.size)
		for card in 2:
			var facing := Vector3(cos(float(tassel.azimuth) + card * PI * 0.5), 0.0, sin(float(tassel.azimuth) + card * PI * 0.5))
			# The tassel hangs from its twig at the card's top edge, a little out from straight down.
			cards.append(_card(at, facing, (Vector3.UP + facing * 0.12).normalized(), size * 0.75, size * 1.5, 1.0, 0.0, EUCALYPTUS_TASSEL, Color(shade, shade, shade), crown, index, 0.035))
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var bark := Surf.new()
		var leaves := Surf.new()
		_emit_limbs(bark, branches, lod, height, low_y, sway_top, EUCALYPTUS_BARK_M, [[10, 5, 4], [6, 4, 3]])
		_emit_cards(leaves, cards, lod, height, sway_top)
		bark.commit(mesh, material("eucalyptus_bark"))
		leaves.commit(mesh, material("set_piece_foliage"))
		meshes.append(mesh)
	var capsules := []
	for axis: Dictionary in axes:
		capsules.append({"radius_m": float(axis.radius) * 1.15, "from": axis.base, "to": _mature_gum_axis(axis, minf(clear, 3.0 / float(axis.height)))})
	return {"lod0": meshes[0], "lod1": meshes[1], "crown_surface": -1, "top_m": height, "capsules": capsules}


## A mature gum's trunk axis at t (0 foot .. 1 top): straight from its foot to its top, bowed a little sideways.
func _mature_gum_axis(axis: Dictionary, t: float) -> Vector3:
	return (axis.base as Vector3).lerp(axis.top as Vector3, t) + (axis.bow as Vector3) * sin(PI * t)


# --- Shared crown helpers (the rollout's trees and shrubs) --------------------------------------------------


## A foliage card for _emit_cards: centred on center at its anchor (the share
## of its height, from its bottom edge, that sits there: 0 a standing tuft, 0.5
## a clump, 1 a hanging tassel), facing normal with its image upright along up,
## w by h, turned by spin; color its shade, heart where its normals lean from,
## cluster the cluster it belongs to (the far level keeps even clusters),
## flutter how far its free edge flaps.
func _card(center: Vector3, normal: Vector3, up: Vector3, w: float, h: float, anchor: float, spin: float, cell: Rect2, color: Color, heart: Vector3, cluster: int, flutter := 0.02) -> Dictionary:
	return {"center": center, "normal": normal, "up": up, "w": w, "h": h, "anchor": anchor, "spin": spin, "cell": cell, "color": color, "heart": heart, "cluster": cluster, "flutter": flutter}


## Draws cards for one level: LOD0 every card as a cupped 3 x 3 grid; LOD1 the
## cards of even clusters (or every card marked lod1), grown by lod1_grow
## (default 1.3) to close the gaps, each a single quad.
func _emit_cards(s: Surf, cards: Array, lod: int, tree_height: float, sway_top: float) -> void:
	for card: Dictionary in cards:
		if lod == 1 and not bool(card.get("lod1", int(card.cluster) % 2 == 0)):
			continue
		var grow := float(card.get("lod1_grow", 1.3)) if lod == 1 else 1.0
		_foliage_card(s, card.center, card.normal, card.up, float(card.w) * grow, float(card.h) * grow, float(card.anchor), float(card.spin), card.cell, card.color,
			card.heart, float(card.get("heart_weight", 0.55)), tree_height, sway_top, float(card.flutter), lod == 0)


## One foliage card (see _card): a cupped 3 x 3 grid (fine) or a single quad,
## its image's left edge on its left as seen from its front. Normals lean from
## heart by heart_weight; colour brightens a little toward its top edge. The
## crown sways sway_top at tree_height, easing in with the square of height,
## and the card's free edge flutters along its normal.
func _foliage_card(s: Surf, center: Vector3, normal: Vector3, up: Vector3, width: float, height: float, anchor: float, spin: float, cell: Rect2, color: Color,
		heart: Vector3, heart_weight: float, tree_height: float, sway_top: float, flutter: float, fine: bool) -> void:
	var up_axis := up - normal * normal.dot(up)
	if up_axis.length() < 0.2:
		up_axis = _perpendicular(normal)
	up_axis = up_axis.normalized().rotated(normal, spin)
	var across := up_axis.cross(normal).normalized()
	var steps := 2 if fine else 1
	var cup := 0.16 if fine else 0.0
	var first := s.verts.size()
	for j in steps + 1:
		for i in steps + 1:
			var x := float(i) / steps - 0.5
			var y := float(j) / steps
			var position := center + across * (x * width) + up_axis * ((y - anchor) * height) - normal * (cup * width * (x * x + (y - 0.5) * (y - 0.5)))
			var n := ((position - heart).normalized() * heart_weight + normal * (1.0 - heart_weight)).normalized()
			var c := lerpf(0.84, 1.0, y)
			var sway := sway_top * pow(clampf(position.y / maxf(tree_height, 0.1), 0.0, 1.0), 2.0)
			s.add(position, n, cell.position + Vector2(x + 0.5, 1.0 - y) * cell.size, Color(color.r * c, color.g * c, color.b * c), Vector2(sway, flutter * absf(y - anchor)))
	for j in steps:
		for i in steps:
			var a := first + j * (steps + 1) + i
			s.quad(a, a + 1, a + steps + 2, a + steps + 1, normal)


## The normals of a crossed cluster facing out: one card facing out and one
## turned a quarter about the vertical, so from any side one card of the
## cluster faces the viewer and the outline is leaves, not card edges. A
## cluster facing up (its first card nearly flat) gets two upright cards too.
func _cluster_normals(out: Vector3, rng: RandomNumberGenerator, jitter: float) -> Array[Vector3]:
	var first := (out + Vector3(rng.randf_range(-jitter, jitter), rng.randf_range(-jitter * 0.6, jitter), rng.randf_range(-jitter, jitter))).normalized()
	var normals: Array[Vector3] = [first]
	if absf(first.y) < 0.7:
		normals.append(first.rotated(Vector3.UP, PI * 0.5))
	else:
		var level := Vector3(out.x, 0.0, out.z)
		if level.length() < 0.05:
			var angle := rng.randf() * TAU
			level = Vector3(cos(angle), 0.0, sin(angle))
		level = level.normalized()
		normals.append(level)
		normals.append(level.rotated(Vector3.UP, PI * 0.5))
	return normals


## Even sites for foliage cards over the outside of a crown's lobes ({center,
## half: Vector3}): candidates over each lobe's surface (from its top down to
## polar_max radians, never under floor_y), those buried in another lobe
## dropped, then thinned in a seeded order to about spacing apart, so the crown
## is clothed evenly, densely and only where it shows (a site under a lobe's
## rim as well as on its top). Returns [{center, out (the lobe's surface
## normal), lobe}].
func _crown_sites(rng: RandomNumberGenerator, lobes: Array, spacing: float, polar_max: float, floor_y := -INF) -> Array:
	var candidates := []
	for index in lobes.size():
		var lobe: Dictionary = lobes[index]
		var half: Vector3 = lobe.half
		var center: Vector3 = lobe.center
		# About four candidates for every site the sampled part of the lobe could hold.
		var area := 4.0 * PI * (half.x * half.y + half.x * half.z + half.y * half.z) / 3.0 * (1.0 - cos(polar_max)) * 0.5
		var n := maxi(8, ceili(4.0 * area / (spacing * spacing)))
		var phase := rng.randf() * TAU
		for i in n:
			# Even over the surface: cos(polar) stratified, azimuth by the golden angle.
			var polar := acos(clampf(lerpf(1.0, cos(polar_max), (float(i) + rng.randf()) / n), -1.0, 1.0))
			var azimuth := phase + i * GOLDEN_ANGLE
			var unit := Vector3(sin(polar) * cos(azimuth), cos(polar), sin(polar) * sin(azimuth))
			var position := center + Vector3(unit.x * half.x, unit.y * half.y, unit.z * half.z) * rng.randf_range(0.9, 1.0)
			if position.y < floor_y:
				continue
			var buried := false
			for other_index in lobes.size():
				if other_index == index:
					continue
				var other: Dictionary = lobes[other_index]
				if ((position - (other.center as Vector3)) / (other.half as Vector3)).length() < 0.92:
					buried = true
					break
			if not buried:
				candidates.append({"center": position, "out": Vector3(unit.x / half.x, unit.y / half.y, unit.z / half.z).normalized(), "lobe": index})
	# Thinned in a seeded order: a candidate within spacing of a kept site is dropped.
	for i in range(candidates.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: Variant = candidates[i]
		candidates[i] = candidates[j]
		candidates[j] = swap
	var grid := {}
	var sites := []
	for candidate: Dictionary in candidates:
		var position: Vector3 = candidate.center
		var cell := Vector3i(floori(position.x / spacing), floori(position.y / spacing), floori(position.z / spacing))
		var near := false
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				for dz in range(-1, 2):
					for kept: Vector3 in grid.get(cell + Vector3i(dx, dy, dz), []):
						if kept.distance_squared_to(position) < spacing * spacing:
							near = true
							break
					if near:
						break
				if near:
					break
			if near:
				break
		if near:
			continue
		if not grid.has(cell):
			grid[cell] = []
		(grid[cell] as Array).append(position)
		sites.append(candidate)
	return sites


## Dark cards crossed through each lobe's middle, so a crown seen through the
## gaps of its outer foliage looks deep rather than hollow: two upright cards a
## quarter turn apart and one lying flat, size times the lobe's width, shade
## dark, the upright ones kept above floor_y. Every level keeps them.
func _filler_cards(cards: Array, lobes: Array, size: float, cell: Rect2, shade: float, rng: RandomNumberGenerator, floor_y := -INF) -> void:
	for lobe: Dictionary in lobes:
		var half: Vector3 = lobe.half
		var center: Vector3 = lobe.center
		var width := half.x * 2.0 * size
		var tall := minf(minf(width, half.y * 2.0 * size), 2.0 * (center.y - floor_y))
		var turn := rng.randf() * TAU
		for normal: Vector3 in [Vector3(cos(turn), 0.0, sin(turn)), Vector3(-sin(turn), 0.0, cos(turn)), Vector3.UP]:
			var card := _card(center, normal, Vector3.UP if normal.y < 0.5 else Vector3(cos(turn), 0.0, sin(turn)), width, tall if normal.y < 0.5 else width, 0.5,
				rng.randf_range(-0.4, 0.4), cell, Color(shade, shade, shade), center, -1, 0.01)
			card.lod1 = true
			card.lod1_grow = 1.0
			card.heart_weight = 0.2
			cards.append(card)


## Tubes for a form's limbs ({depth, points, radii}): LOD1 keeps depths 0 and 1
## with fewer sides (sides[lod][depth]). Lit on the open trunk, darker inside the
## crown (above crown_low) and at the foot; they sway with the crown.
func _emit_limbs(s: Surf, branches: Array, lod: int, tree_height: float, crown_low: float, sway_top: float, tile_m: float, sides: Array) -> void:
	for branch: Dictionary in branches:
		var depth := int(branch.depth)
		if lod == 1 and depth > 1:
			continue
		var points: PackedVector3Array = branch.points
		var radii: PackedFloat32Array = branch.radii
		var colors := PackedColorArray()
		var winds := PackedVector2Array()
		for point in points:
			var ao := lerpf(0.72, 1.0, clampf(point.y / 0.6, 0.0, 1.0)) * lerpf(1.0, 0.58, clampf((point.y - crown_low) / maxf(1.0, tree_height - crown_low), 0.0, 1.0))
			colors.append(Color(ao, ao, ao))
			winds.append(Vector2(sway_top * pow(clampf(point.y / tree_height, 0.0, 1.0), 2.0), 0.0))
		_tube(s, points, radii, colors, winds, int(sides[lod][mini(depth, 2)]), maxf(1.0, roundf(TAU * radii[0] / tile_m)), tile_m)


## Points along a cubic Bezier from a to d (b and c its handles): segments + 1 of them.
static func _bezier(a: Vector3, b: Vector3, c: Vector3, d: Vector3, segments: int) -> PackedVector3Array:
	var points := PackedVector3Array()
	for i in segments + 1:
		var t := float(i) / segments
		var u := 1.0 - t
		points.append(a * (u * u * u) + b * (3.0 * u * u * t) + c * (3.0 * u * t * t) + d * (t * t * t))
	return points


## count radii tapering from r0 to r1, faster early when power < 1.
static func _taper(r0: float, r1: float, count: int, power: float) -> PackedFloat32Array:
	var radii := PackedFloat32Array()
	for i in count:
		radii.append(lerpf(r0, r1, pow(float(i) / maxf(1.0, count - 1), power)))
	return radii


## A repeatable number in [0, 1) from a seed and two indices.
static func _hash01(seed: int, a: int, b: int) -> float:
	return float(hash([seed, a, b]) & 0xFFFFFF) / 16777216.0


# --- Monterey pine ------------------------------------------------------------------------------------


## A Monterey pine (p1-p6): a short, thick trunk of dark furrowed bark, bent and
## leaning, splitting at fork into a few big ascending leaders under a dense
## dome of lobes. Each lobe is clothed in crossed cards of face-on tuft
## clusters, darker inside and underneath; upright cards of side-view tufts
## bristle out of the upper lobes and the rim, so the outline reads as brush-like
## tufts rather than a smooth ball. Limbs run out from the trunk to the lower
## lobes, where they show under the crown. A pruned tree's crown is pushed
## downwind (east, +X) and its windward side cut back and lowered.
func _build_pine(p: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var height := float(p.height)
	var spread := float(p.spread)
	var clear := float(p.clear)
	var fork_y := float(p.fork)
	var trunk_radius := float(p.trunk_radius)
	var shear := float(p.get("shear", 0.0))
	var sway_top := PINE_SWAY * height
	var lee := Vector3(CYPRESS_LEE.x, 0.0, CYPRESS_LEE.y).normalized()
	var turn := rng.randf()
	var lean_dir := lee.rotated(Vector3.UP, (turn - 0.5) * 1.2) if shear > 0.0 else Vector3(cos(turn * TAU), 0.0, sin(turn * TAU))
	var lean := lean_dir * float(p.lean)
	var bow := lean_dir.rotated(Vector3.UP, PI * 0.5) * float(p.lean) * rng.randf_range(-0.4, 0.4)
	# The trunk, from below the foot to the fork, leaning and bowed, swelling at the foot.
	var trunk := PackedVector3Array()
	var trunk_radii := PackedFloat32Array()
	for i in 7:
		var t := float(i) / 6.0
		var point := Vector3(0.0, -BURY_M + (fork_y + BURY_M) * t, 0.0) + lean * pow(t, 1.6) + bow * sin(PI * t)
		trunk.append(point)
		trunk_radii.append(trunk_radius * (lerpf(1.0, 0.82, t) + 0.35 * exp(-maxf(point.y, 0.0) / 0.35)))
	var fork := trunk[6]
	# It runs on a little past the fork, so the leaders grow out of it.
	trunk.append(fork + (fork - trunk[5]).normalized() * 0.5)
	trunk_radii.append(trunk_radius * 0.55)
	# The crown's envelope: a dome over the crown base, centred over the leaning
	# trunk and pushed downwind; a pruned tree's windward side is cut back and lower.
	var crown_depth := height - clear
	var center := Vector3(0.0, clear + crown_depth * 0.42, 0.0) + lean * 1.15 + lee * (spread * shear)
	# The cards stand out of the lobes by about half their size: the lobes keep
	# that much inside the tree's nominal height and spread.
	var card_size := clampf(spread * 0.15, 1.2, 1.8)
	var radius := spread * 0.5 - card_size * 0.4
	var up_radius := height - center.y - card_size * 0.45
	var down_radius := center.y - clear
	var envelope := func(dir: Vector3) -> Vector3:
		var windward := minf(0.0, dir.x * lee.x + dir.z * lee.z)
		var cut := 1.0 + shear * 2.2 * windward
		return center + Vector3(dir.x * radius * cut, dir.y * (up_radius if dir.y > 0.0 else down_radius) * (1.0 + shear * 1.2 * windward), dir.z * radius * cut)
	# A cap lobe over the top, then lobes round the dome from its shoulders down to the crown base.
	var lobes: Array[Dictionary] = [{"center": center + Vector3(0.0, up_radius * 0.4, 0.0), "half": Vector3(radius * 0.55, up_radius * 0.6, radius * 0.55)}]
	var count := int(p.lobes)
	var phase := rng.randf() * TAU
	for i in count:
		var polar := lerpf(0.45, 2.45, (float(i) + rng.randf_range(0.2, 0.8)) / count)
		var azimuth := phase + i * GOLDEN_ANGLE + rng.randf_range(-0.3, 0.3)
		var surface: Vector3 = envelope.call(Vector3(sin(polar) * cos(azimuth), cos(polar), sin(polar) * sin(azimuth)))
		var size := spread * rng.randf_range(0.2, 0.27)
		lobes.append({"center": center.lerp(surface, rng.randf_range(0.62, 0.74)), "half": Vector3(size, size * rng.randf_range(0.72, 0.9), size)})
	var cards := []
	# Cards of tufts about a seventh of the spread across, closely spaced over the
	# whole outside of the lobes, undersides too, down to the crown base.
	var sites := _crown_sites(rng, lobes, card_size * 0.72, 2.75, clear * 0.85)
	for index in sites.size():
		var site: Dictionary = sites[index]
		var out: Vector3 = site.out
		var position: Vector3 = site.center
		var lobe: Dictionary = lobes[int(site.lobe)]
		# Darker underneath and toward the crown's middle; the sunlit top lightest.
		var height_f := clampf((position.y - clear) / crown_depth, 0.0, 1.0)
		var radial := clampf(Vector2(position.x - center.x, position.z - center.z).length() / radius, 0.0, 1.0)
		var shade := rng.randf_range(0.88, 1.05) * lerpf(0.62, 1.0, height_f) * lerpf(0.8, 1.0, radial) * lerpf(1.0, 0.62, clampf(-out.y, 0.0, 1.0))
		var color := Color(shade, shade, shade)
		var size := card_size * rng.randf_range(0.85, 1.15)
		for normal in _cluster_normals(out, rng, 0.3):
			cards.append(_card(position, normal, Vector3.UP, size, size, 0.5, rng.randf_range(-0.5, 0.5), PINE_FACE, color, lobe.center, index))
		# Tufts bristle out of the upper crown and its rim.
		if out.y > -0.15 and rng.randf() < lerpf(0.3, 0.7, clampf(out.y + 0.15, 0.0, 1.0)):
			var tuft := size * rng.randf_range(0.75, 0.95)
			var rise := (Vector3.UP * 0.7 + out * 0.45).normalized()
			var facing := Vector3(out.x, 0.0, out.z)
			if facing.length() < 0.1:
				facing = Vector3(cos(rng.randf() * TAU), 0.0, sin(rng.randf() * TAU))
			facing = facing.normalized()
			for k in 2:
				cards.append(_card(position + out * size * 0.1, facing.rotated(Vector3.UP, PI * 0.5 * k + rng.randf_range(-0.25, 0.25)), rise, tuft, tuft, 0.25,
					rng.randf_range(-0.15, 0.15), PINE_TUFTS, color * 1.04, lobe.center, index, 0.03))
	_filler_cards(cards, lobes, 0.8, PINE_FACE, 0.38, rng)
	var branches := [{"depth": 0, "points": trunk, "radii": trunk_radii}]
	# Leaders from the fork up into the highest lobes.
	var by_height := range(lobes.size())
	by_height.sort_custom(func(a: int, b: int) -> bool: return (lobes[a].center as Vector3).y > (lobes[b].center as Vector3).y)
	var leader_lobes := {}
	for k in mini(int(p.leaders), lobes.size()):
		var lobe: Dictionary = lobes[by_height[k]]
		leader_lobes[by_height[k]] = true
		var target: Vector3 = (lobe.center as Vector3) - Vector3(0.0, (lobe.half as Vector3).y * 0.3, 0.0)
		var start := fork - Vector3(0.0, 0.18 * k, 0.0)
		var points := _bezier(start, start + Vector3.UP * (target.y - start.y) * 0.45, target.lerp(start, 0.3) + Vector3.UP * 0.4, target, 6)
		branches.append({"depth": 1, "points": points, "radii": _taper(trunk_radius * 0.7, 0.05, points.size(), 0.8)})
	# Limbs from the trunk out to the lower lobes, the low branching under the crown.
	for index in lobes.size():
		var lobe: Dictionary = lobes[index]
		var target: Vector3 = lobe.center
		if leader_lobes.has(index) or target.y > center.y + up_radius * 0.3:
			continue
		var start := _polyline_at(trunk, clampf((target.y - 0.8) / maxf(fork_y, 0.5), 0.35, 1.0) * 6.0 / 7.0)
		var end := target.lerp(Vector3(center.x, target.y, center.z), 0.25)
		var middle := start.lerp(end, 0.5) + Vector3.UP * (0.12 * start.distance_to(end))
		var points := _bezier(start, start.lerp(middle, 0.6), middle.lerp(end, 0.4), end, 4)
		branches.append({"depth": 2, "points": points, "radii": _taper(trunk_radius * 0.42, 0.03, points.size(), 0.8)})
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var bark := Surf.new()
		var leaves := Surf.new()
		_emit_limbs(bark, branches, lod, height, clear, sway_top, PINE_BARK_M, [[10, 7, 5], [6, 4, 3]])
		_emit_cards(leaves, cards, lod, height, sway_top)
		bark.commit(mesh, material("pine_bark"))
		leaves.commit(mesh, material("pine_foliage"))
		meshes.append(mesh)
	return {"lod0": meshes[0], "lod1": meshes[1], "crown_surface": -1, "top_m": height,
		"capsules": [{"radius_m": trunk_radius * 1.1, "from": Vector3.ZERO, "to": fork}]}


# --- Spreading broadleaf and New Zealand Christmas tree -----------------------------------------------


## The spreading broadleaf (c2-c4, b1-b8) and the Christmas tree (b5/b6), one
## builder: a trunk forking low (or, with stems, a few pale stems leaning out
## from the root crown) into limbs that climb and then arch out sinuously to
## clouds of foliage: flattened, lumpy pads, each clothed in crossed cards of
## leaf clumps over its top and sides, the clumps round its rim hanging, its
## underside sparse and dark. Side branches carry smaller clouds, and a few
## clouds close the crown's top. Between the clouds the limbs show. The
## broadleaf's clouds are separate layers with gaps, some tipped bronze; the
## Christmas tree's overlap into one dense, dark, rounded crown with a few red
## brushes.
func _build_broadleaf(p: Dictionary) -> Dictionary:
	var christmas := p.has("stems")
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var height := float(p.height)
	var spread := float(p.spread)
	var fork_y := float(p.fork)
	var trunk_radius := float(p.trunk_radius)
	var sway_top := BROADLEAF_SWAY * height
	var radius := spread * 0.5
	var lean_angle := rng.randf() * TAU
	var lean_dir := Vector3(cos(lean_angle), 0.0, sin(lean_angle))
	var lean := lean_dir * float(p.lean)
	var crown_center := Vector3(0.0, height * 0.62, 0.0) + lean * 1.3
	var branches := []
	# Where the limbs start: {point, out, radius}.
	var starts: Array[Dictionary] = []
	if christmas:
		var stems := int(p.stems)
		for k in stems:
			var azimuth := lean_angle + TAU * k / stems + rng.randf_range(-0.35, 0.35)
			var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
			var tilt := deg_to_rad(rng.randf_range(12.0, 26.0))
			var length := height * rng.randf_range(0.42, 0.55)
			var base := out * 0.14
			var top := base + (out * sin(tilt) + Vector3.UP * cos(tilt)) * length + lean * 0.5
			var side := Vector3(-out.z, 0.0, out.x) * rng.randf_range(-0.55, 0.55)
			var points := _bezier(base + Vector3.DOWN * BURY_M, base + Vector3.UP * length * 0.35 + side - out * 0.2, top - (top - base) * 0.3 - side * 0.6, top, 7)
			var r := trunk_radius * rng.randf_range(0.85, 1.1)
			branches.append({"depth": 0, "points": points, "radii": _taper(r * 1.25, r * 0.65, points.size(), 1.0)})
			starts.append({"point": top, "out": out, "radius": r * 0.65})
	else:
		var bow := lean_dir.rotated(Vector3.UP, PI * 0.5) * float(p.lean) * rng.randf_range(-0.3, 0.3)
		var points := PackedVector3Array()
		var radii := PackedFloat32Array()
		for i in 6:
			var t := float(i) / 5.0
			var point := Vector3(0.0, -BURY_M + (fork_y + BURY_M) * t, 0.0) + lean * pow(t, 1.4) + bow * sin(PI * t)
			points.append(point)
			radii.append(trunk_radius * (lerpf(1.0, 0.88, t) + 0.4 * exp(-maxf(point.y, 0.0) / 0.4)))
		var fork := points[5]
		points.append(fork + (fork - points[4]).normalized() * 0.4)
		radii.append(trunk_radius * 0.6)
		branches.append({"depth": 0, "points": points, "radii": radii})
		starts.append({"point": fork, "out": lean_dir, "radius": trunk_radius * 0.8})
	var rise := float(p.rise)
	var flat := float(p.flat)
	var cloud_reach := spread * float(p.cloud)
	var bronze_share := float(p.get("bronze", 0.0))
	# Clumps about half a cloud's reach across; the clouds keep about half of one
	# under the tree's nominal height, which the clumps' outline meets.
	var card_size := clampf(cloud_reach * 0.55, 0.9, 1.4) if christmas else clampf(cloud_reach * 0.5, 0.9, 1.6)
	var top_y := height - card_size * 0.4
	# Clouds: {center, half: Vector3, accent} (accent: the cloud is tipped bronze).
	var clouds: Array[Dictionary] = []
	var phase := rng.randf() * TAU
	var limbs := int(p.limbs)
	for k in limbs:
		var from: Dictionary = starts[k % starts.size()]
		# Every other limb splits off a little lower.
		var start: Vector3 = (from.point as Vector3) - Vector3(0.0, 0.35 if k % 2 == 1 and not christmas else 0.0, 0.0)
		var out := Vector3(cos(phase + TAU * k / limbs + rng.randf_range(-0.35, 0.35)), 0.0, sin(phase + TAU * k / limbs + rng.randf_range(-0.35, 0.35)))
		if christmas:
			out = (out + (from.out as Vector3) * 0.8).normalized()
		var reach := radius * rng.randf_range(0.5, 0.68)
		var target := Vector3(crown_center.x, 0.0, crown_center.z) + out * reach
		target.y = minf(height * (rng.randf_range(0.5, 0.7) if rise < 0.5 else rng.randf_range(0.6, 0.76)), top_y - cloud_reach * flat * 1.1)
		var side := Vector3(-out.z, 0.0, out.x) * rng.randf_range(-1.0, 1.0)
		# Climbs out of the fork (steeply when rise is high), then arches out to its cloud.
		var points := _bezier(start, start + Vector3.UP * (target.y - start.y) * lerpf(0.3, 0.75, rise) + out * reach * lerpf(0.35, 0.1, rise) + side * 0.6,
			target - out * reach * lerpf(0.25, 0.45, rise) + Vector3.UP * cloud_reach * 0.2 - side * 0.4, target, 7)
		var r0 := float(from.radius) * rng.randf_range(0.9, 1.05)
		branches.append({"depth": 1, "points": points, "radii": _taper(r0, 0.05, points.size(), 1.1)})
		var main_reach := cloud_reach * rng.randf_range(0.95, 1.15)
		clouds.append({"center": target + Vector3(0.0, main_reach * flat * 0.25, 0.0), "half": Vector3(main_reach, main_reach * flat, main_reach), "accent": rng.randf() < bronze_share})
		# Side branches off the limb's outer part, each ending in a smaller cloud.
		for b in int(p.clouds):
			var origin := _polyline_at(points, rng.randf_range(0.4, 0.85))
			var branch_out := out.rotated(Vector3.UP, (1.0 if (b + k) % 2 == 0 else -1.0) * rng.randf_range(0.6, 1.3))
			var length := radius * rng.randf_range(0.28, 0.45)
			var elevation := deg_to_rad(rng.randf_range(-25.0, 18.0))
			var end := origin + (branch_out * cos(elevation) + Vector3.UP * sin(elevation)) * length
			end.y = minf(end.y, top_y - cloud_reach * flat)
			var middle := origin.lerp(end, 0.5) + Vector3.UP * length * 0.12
			var side_points := _bezier(origin, origin.lerp(middle, 0.6), middle.lerp(end, 0.5), end, 4)
			branches.append({"depth": 2, "points": side_points, "radii": _taper(r0 * 0.5, 0.03, side_points.size(), 0.9)})
			var small := cloud_reach * rng.randf_range(0.65, 0.85)
			clouds.append({"center": end + Vector3(0.0, small * flat * 0.2, 0.0), "half": Vector3(small, small * flat * rng.randf_range(0.85, 1.1), small), "accent": rng.randf() < bronze_share})
	# Clouds over the crown's top close it into a layered dome, each on a limb of its own.
	var tops := 4 if christmas else 3
	for i in tops:
		var angle := phase + TAU * (i + 0.5) / tops + rng.randf_range(-0.4, 0.4)
		var top_reach := cloud_reach * rng.randf_range(0.9, 1.1)
		var cloud_center := Vector3(crown_center.x, 0.0, crown_center.z) + Vector3(cos(angle), 0.0, sin(angle)) * radius * rng.randf_range(0.1, 0.3)
		cloud_center.y = top_y - top_reach * flat
		clouds.append({"center": cloud_center, "half": Vector3(top_reach, top_reach * flat, top_reach), "accent": rng.randf() < bronze_share})
		var from: Dictionary = starts[i % starts.size()]
		var start: Vector3 = from.point
		var end := cloud_center - Vector3(0.0, top_reach * flat * 0.5, 0.0)
		var points := _bezier(start, start + Vector3.UP * (end.y - start.y) * 0.6, end - (end - start) * 0.25, end, 6)
		branches.append({"depth": 1, "points": points, "radii": _taper(float(from.radius) * 0.75, 0.04, points.size(), 0.8)})
	if christmas:
		for i in 4:
			var angle := phase + TAU * (i + 0.25) / 4.0 + rng.randf_range(-0.3, 0.3)
			var skirt_reach := cloud_reach * rng.randf_range(0.85, 1.0)
			var skirt := Vector3(crown_center.x, 0.0, crown_center.z) + Vector3(cos(angle), 0.0, sin(angle)) * radius * rng.randf_range(0.5, 0.62)
			skirt.y = height * rng.randf_range(0.3, 0.38)
			clouds.append({"center": skirt, "half": Vector3(skirt_reach, skirt_reach * flat, skirt_reach), "accent": false})
			var from: Dictionary = starts[i % starts.size()]
			var origin: Vector3 = (from.point as Vector3).lerp(Vector3(0.0, 0.4, 0.0), 0.4)
			var skirt_points := _bezier(origin, origin.lerp(skirt, 0.4) + Vector3.UP * 0.4, skirt - (skirt - origin) * 0.2, skirt, 4)
			branches.append({"depth": 2, "points": skirt_points, "radii": _taper(float(from.radius) * 0.6, 0.03, skirt_points.size(), 0.9)})
	var lobes := []
	for cloud in clouds:
		lobes.append({"center": cloud.center, "half": cloud.half})
	# The clumps closely spaced over each cloud's top, sides and underside (the
	# broadleaf's clouds stay apart, so the gaps between them stay open).
	var sites := _crown_sites(rng, lobes, card_size * float(p.spacing), 2.6)
	var flower_share := float(p.get("flowers", 0.0))
	var crown_low := fork_y if not christmas else height * 0.35
	var cards := []
	for index in sites.size():
		var site: Dictionary = sites[index]
		var out: Vector3 = site.out
		var position: Vector3 = site.center
		var cloud: Dictionary = clouds[int(site.lobe)]
		var half: Vector3 = cloud.half
		var height_f := clampf((position.y - crown_low) / maxf(1.0, height - crown_low), 0.0, 1.0)
		var radial := clampf(Vector2(position.x - crown_center.x, position.z - crown_center.z).length() / radius, 0.0, 1.0)
		var shade := rng.randf_range(0.88, 1.06) * lerpf(0.66, 1.0, height_f) * lerpf(0.82, 1.0, radial) * lerpf(1.0, 0.58, clampf(-out.y, 0.0, 1.0))
		var cell := CHRISTMAS_CLUMP if christmas else BROADLEAF_CLUMP
		if christmas and out.y > -0.1 and rng.randf() < flower_share:
			cell = CHRISTMAS_FLOWERS
		elif not christmas and out.y > -0.2 and rng.randf() < (0.45 if bool(cloud.accent) else 0.05):
			cell = BROADLEAF_BRONZE
		var size := card_size * rng.randf_range(0.85, 1.15)
		# Clumps round the rim and under it hang down off their twigs.
		var hanging := out.y < 0.2
		var anchor := 0.75 if hanging else 0.5
		var up := Vector3.UP if hanging else (Vector3.UP + out * 0.3).normalized()
		for normal in _cluster_normals(out + (Vector3.DOWN * 0.3 if hanging else Vector3.ZERO), rng, 0.3):
			cards.append(_card(position, normal, up, size, size, anchor, rng.randf_range(-0.4, 0.4), cell, Color(shade, shade, shade), cloud.center, index, 0.025))
	_filler_cards(cards, lobes, 0.75, CHRISTMAS_CLUMP if christmas else BROADLEAF_CLUMP, 0.36, rng)
	var bark_key := "christmas_bark" if christmas else "broadleaf_bark"
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var bark := Surf.new()
		var leaves := Surf.new()
		_emit_limbs(bark, branches, lod, height, crown_low, sway_top, CHRISTMAS_BARK_M if christmas else BROADLEAF_BARK_M, [[10, 6, 4], [6, 4, 3]])
		_emit_cards(leaves, cards, lod, height, sway_top)
		bark.commit(mesh, material(bark_key))
		leaves.commit(mesh, material("broadleaf_foliage"))
		meshes.append(mesh)
	var capsules := []
	for branch: Dictionary in branches:
		if int(branch.depth) == 0:
			var points: PackedVector3Array = branch.points
			var radii: PackedFloat32Array = branch.radii
			# The stem from the foot to its fork, or its first 2.2 m.
			capsules.append({"radius_m": radii[2] * 1.1, "from": Vector3(points[0].x, 0.0, points[0].z), "to": _polyline_at(points, clampf(2.2 / maxf(points[points.size() - 1].y, 0.1), 0.2, 1.0) * 0.85)})
	return {"lod0": meshes[0], "lod1": meshes[1], "crown_surface": -1, "top_m": height, "capsules": capsules}


# --- Young Norfolk Island pine -----------------------------------------------------------------------


## A young Norfolk Island pine (n1): a straight trunk under whorls of level
## branches, each a frond of soft upturned branchlets on two crossed cards (one
## lying along it, seen from above, one standing along it, seen from the side),
## shortening tier by tier to the leader, so the tree reads as a symmetric stack
## of tiers with the trunk showing between them.
func _build_araucaria(p: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var height := float(p.height)
	var spread := float(p.spread)
	var trunk_radius := float(p.trunk_radius)
	var tier := float(p.tier)
	var per_whorl := int(p.branches)
	var sway_top := NORFOLK_SWAY * height
	var lean := Vector3(rng.randf_range(-0.06, 0.06), 0.0, rng.randf_range(-0.06, 0.06))
	var axis := func(y: float) -> Vector3: return Vector3.UP * y + lean * pow(clampf(y / height, 0.0, 1.0), 2.0)
	var trunk := PackedVector3Array([Vector3.DOWN * BURY_M])
	var trunk_radii := PackedFloat32Array([trunk_radius * 1.25])
	for i in 6:
		var t := float(i) / 5.0
		trunk.append(axis.call(height * t))
		trunk_radii.append(lerpf(trunk_radius, 0.012, pow(t, 0.9)) + trunk_radius * 0.2 * exp(-t * height / 0.3))
	var branches := [{"depth": 0, "points": trunk, "radii": trunk_radii}]
	var cards := []
	var y := tier * 0.9
	var whorl := 0
	while y < height - 0.3:
		var f := y / height
		var length := spread * 0.5 * pow(1.0 - f, 0.8) * rng.randf_range(0.92, 1.06) + 0.12
		var twist := whorl * 0.55 + rng.randf_range(-0.1, 0.1)
		var base: Vector3 = axis.call(y)
		for k in per_whorl:
			var azimuth := twist + TAU * k / per_whorl + rng.randf_range(-0.12, 0.12)
			var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
			var side := Vector3(-out.z, 0.0, out.x)
			var elevation := deg_to_rad(rng.randf_range(4.0, 14.0) + 6.0 * f)
			var along := (out * cos(elevation) + Vector3.UP * sin(elevation)).normalized()
			var shade := rng.randf_range(0.9, 1.05) * lerpf(0.72, 1.0, f)
			var middle := base + along * length * 0.52
			# Seen from above: the frond lies along the branch, its trunk end on the image's left.
			var flat := along.cross(side).normalized()
			if flat.y < 0.0:
				flat = -flat
			var top_card := _card(middle + Vector3.UP * 0.02, flat, -side, length * 1.04, length * 0.36, 0.5, 0.0, NORFOLK_TOP, Color(shade, shade, shade), base + Vector3.UP * 0.4, cards.size(), 0.025)
			# Seen from the side: the branchlets turn up off the branch.
			var side_card := _card(base + along * length * 0.5 - Vector3.UP * 0.03, side, Vector3.UP, length, length * 0.3, 0.2, 0.0, NORFOLK_SIDE, Color(shade, shade, shade) * 0.94, base + Vector3.UP * 0.4, cards.size(), 0.025)
			for card: Dictionary in [top_card, side_card]:
				card.lod1 = true
				card.lod1_grow = 1.0
				card.heart_weight = 0.35
				cards.append(card)
			branches.append({"depth": 2, "points": PackedVector3Array([base, base + along * length * 0.85]), "radii": PackedFloat32Array([0.022, 0.006])})
		y += tier * rng.randf_range(0.9, 1.1)
		whorl += 1
	# The leader's soft tip.
	var tip: Vector3 = axis.call(height)
	for k in 2:
		var facing := Vector3(cos(k * PI * 0.5), 0.0, sin(k * PI * 0.5))
		var leader := _card(tip - Vector3.UP * 0.05, facing, Vector3.UP, 0.32, 0.5, 0.1, PI * 0.5, NORFOLK_TOP, Color(1.02, 1.02, 1.02), tip, cards.size(), 0.03)
		leader.lod1 = true
		leader.lod1_grow = 1.0
		cards.append(leader)
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var bark := Surf.new()
		var leaves := Surf.new()
		_emit_limbs(bark, branches, lod, height, 0.3, sway_top, PINE_BARK_M, [[8, 4, 3], [5, 3, 3]])
		_emit_cards(leaves, cards, lod, height, sway_top)
		bark.commit(mesh, material("pine_bark"))
		leaves.commit(mesh, material("set_piece_foliage"))
		meshes.append(mesh)
	return {"lod0": meshes[0], "lod1": meshes[1], "crown_surface": -1, "top_m": height,
		"capsules": [{"radius_m": trunk_radius * 1.2, "from": Vector3.ZERO, "to": axis.call(minf(1.6, height * 0.5))}]}


# --- Avenue N shrubs --------------------------------------------------------------------------------------


## The Avenue N shrubs (s1-s3): a mound is a lumpy dome of a few lobes clothed
## in crossed clusters of the shrub's foliage down to the ground, over a dark
## floor that hides its hollow; a cone stacks lobes up a narrowing ogive; an
## upright shrub is a few slender stems, each drawn on crossed side-view
## cards. Darker low and inside; the foliage flutters, the crown sways a little.
func _build_shrub(p: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var height := float(p.height)
	var radius := float(p.width) * 0.5
	var cell: Rect2 = SHRUB_CELLS[str(p.cell)]
	var sway_top := SHRUB_SWAY * height
	# Clusters about half the shrub's radius across; the lobes keep about a third
	# of one inside the shrub's nominal size, which the clustered outline meets.
	var card_size := clampf(radius * 0.62, 0.45, 1.0)
	if str(p.shape) != "upright":
		radius -= card_size * 0.3
		height -= card_size * 0.35
	var phase := rng.randf() * TAU
	var heart := Vector3(0.0, height * 0.4, 0.0)
	var cards := []
	var lobes := []
	match str(p.shape):
		"mound":
			# A main dome to the ground and lumps round its shoulders and foot.
			lobes.append({"center": Vector3(0.0, height * 0.42, 0.0), "half": Vector3(radius * 0.82, height * 0.58, radius * 0.82)})
			for k in int(p.lobes):
				var azimuth := phase + TAU * k / int(p.lobes) + rng.randf_range(-0.4, 0.4)
				var lobe_radius := radius * rng.randf_range(0.4, 0.52)
				var lobe_y := height * rng.randf_range(0.25, 0.55)
				lobes.append({"center": Vector3(cos(azimuth), 0.0, sin(azimuth)) * radius * rng.randf_range(0.45, 0.55) + Vector3.UP * lobe_y,
					"half": Vector3(lobe_radius, maxf(lobe_y + 0.05, height * rng.randf_range(0.32, 0.42)), lobe_radius)})
		"cone":
			var levels := maxi(3, int(round(height / (radius * 0.65))))
			for i in levels:
				var f := (float(i) + 0.5) / levels
				# An ogive, widest a little above the ground, narrowing to a soft point.
				var level_radius := radius * sin(PI * lerpf(0.35, 0.97, f))
				var y := height * lerpf(0.1, 0.9, f)
				for k in 3:
					var azimuth := phase + i * 1.3 + TAU * k / 3.0 + rng.randf_range(-0.4, 0.4)
					lobes.append({"center": Vector3(cos(azimuth), 0.0, sin(azimuth)) * level_radius * 0.4 + Vector3.UP * y,
						"half": Vector3(level_radius * 0.66, height / levels * 0.75, level_radius * 0.66)})
	if not lobes.is_empty():
		# Clusters closely spaced over the whole outside down to the ground.
		var sites := _crown_sites(rng, lobes, card_size * (0.55 if str(p.shape) == "mound" else 0.6), PI, 0.06)
		for index in sites.size():
			var site: Dictionary = sites[index]
			var out: Vector3 = site.out
			var position: Vector3 = site.center
			var shade := rng.randf_range(0.88, 1.06) * lerpf(0.55, 1.0, pow(clampf(position.y / height, 0.0, 1.0), 0.7)) * lerpf(1.0, 0.7, clampf(-out.y, 0.0, 1.0))
			var size := card_size * rng.randf_range(0.85, 1.15)
			# A cluster at the foot sits on the ground rather than running into it.
			position.y = maxf(position.y, size * 0.42)
			for normal in _cluster_normals(out, rng, 0.3):
				cards.append(_card(position, normal, Vector3.UP, size, size, 0.5, rng.randf_range(-0.5, 0.5), cell, Color(shade, shade, shade), heart, index, 0.02))
		_filler_cards(cards, lobes, 0.75, cell, 0.34, rng, 0.02)
	else:
		# Upright: slender stems from one base, each on crossed side-view cards.
		var stems := int(p.stems)
		for k in stems:
			var azimuth := phase + TAU * k / stems + rng.randf_range(-0.3, 0.3)
			var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
			var tilt := deg_to_rad(rng.randf_range(4.0, 14.0))
			var length := height * rng.randf_range(0.72, 1.0)
			var up := (Vector3.UP * cos(tilt) + out * sin(tilt)).normalized()
			var shade := rng.randf_range(0.88, 1.04)
			for card in 2:
				var normal := out.rotated(Vector3.UP, PI * 0.5 + card * PI * 0.5 + rng.randf_range(-0.2, 0.2))
				var stem_card := _card(out * 0.05 - Vector3.UP * 0.04, normal, up, radius * rng.randf_range(1.1, 1.4), length, 0.0, 0.0, cell, Color(shade, shade, shade), heart, k, 0.03)
				stem_card.heart_weight = 0.3
				cards.append(stem_card)
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var leaves := Surf.new()
		if str(p.shape) == "mound":
			# A dark floor of the same foliage hides the hollow inside from low views.
			_dish(leaves, IDENTITY_FRAME, cell, 0.05, radius * 0.75, 0.04, Color(0.3, 0.3, 0.3), phase)
		_emit_cards(leaves, cards, lod, height, sway_top)
		leaves.commit(mesh, material("shrub_foliage"))
		meshes.append(mesh)
	return {"lod0": meshes[0], "lod1": meshes[1], "crown_surface": -1, "top_m": height, "capsules": []}


# --- New Zealand flax ---------------------------------------------------------------------------------------


## Dark red New Zealand flax (the Mersea lot's planters, Sep 2025): stiff strap
## leaves in three overlapping fans from one base, the middle ones upright, the
## outer ones leaning out and arching over at their tips; each a ribbon folded
## along its midrib, the leaf image stretched from base to tip.
func _build_flax(p: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var height := float(p.height)
	var width := float(p.width)
	var count := int(p.leaves)
	var cell: Rect2 = SHRUB_CELLS.flax_leaf
	var sway_top := SHRUB_SWAY * height
	var phase := rng.randf() * TAU
	var leaves := []
	for i in count:
		var fan := phase + (i % 3) * PI / 3.0 + rng.randf_range(-0.15, 0.15)
		var in_plane := Vector3(cos(fan), 0.0, sin(fan))
		# Most leaves stand nearly upright; the outer ones lean out.
		var spread := deg_to_rad((1.0 if rng.randf() < 0.5 else -1.0) * pow(rng.randf(), 1.3) * 50.0)
		var outward := absf(spread) / deg_to_rad(50.0)
		var direction := (Vector3.UP * cos(spread) + in_plane * sin(spread)).normalized()
		leaves.append({
			"base": in_plane * rng.randf_range(-0.06, 0.06) + Vector3(rng.randf_range(-0.03, 0.03), -0.05, rng.randf_range(-0.03, 0.03)),
			"direction": direction,
			"length": height * lerpf(1.05, 0.72, outward) * rng.randf_range(0.88, 1.05),
			"droop": 0.06 + 0.3 * pow(outward, 1.5),
			"face": Vector3(-in_plane.z, 0.0, in_plane.x) * (1.0 if rng.randf() < 0.5 else -1.0),
			"width": width * rng.randf_range(0.85, 1.1),
			"shade": rng.randf_range(0.82, 1.06),
		})
	var meshes: Array[ArrayMesh] = []
	for lod in 2:
		var mesh := ArrayMesh.new()
		var s := Surf.new()
		var segments := 6 if lod == 0 else 3
		for index in leaves.size():
			if lod == 1 and index % 2 == 1:
				continue
			var leaf: Dictionary = leaves[index]
			var base: Vector3 = leaf.base
			var direction: Vector3 = leaf.direction
			var length := float(leaf.length)
			var droop := float(leaf.droop)
			var face: Vector3 = leaf.face
			var half := float(leaf.width) * (0.5 if lod == 0 else 0.75)
			var first := s.verts.size()
			for j in segments + 1:
				var t := float(j) / segments
				var position := base + direction * (length * t) + Vector3.DOWN * (droop * length * t * t)
				var tangent := (direction * length + Vector3.DOWN * (2.0 * droop * length * t)).normalized()
				var across := face.cross(tangent).normalized()
				var c := float(leaf.shade) * lerpf(0.55, 1.0, sqrt(t))
				var wind := Vector2(sway_top * t * t, 0.01 + 0.03 * t * t)
				var v := cell.end.y - t * cell.size.y
				# Folded along its midrib: the keel sits a little behind the edges.
				s.add(position - across * half, face, Vector2(cell.position.x, v), Color(c, c, c), wind)
				s.add(position - face * half * 0.35, face, Vector2(cell.position.x + cell.size.x * 0.5, v), Color(c * 0.9, c * 0.9, c * 0.9), wind)
				s.add(position + across * half, face, Vector2(cell.end.x, v), Color(c, c, c), wind)
			for j in segments:
				var a := first + j * 3
				s.quad(a, a + 1, a + 4, a + 3, face)
				s.quad(a + 1, a + 2, a + 5, a + 4, face)
		s.commit(mesh, material("shrub_foliage"))
		meshes.append(mesh)
	return {"lod0": meshes[0], "lod1": meshes[1], "crown_surface": -1, "top_m": height, "capsules": []}


# --- Clipped hedge ------------------------------------------------------------------------------------------


## A hedge's stations are this far apart at LOD0; LOD1 keeps every other and the
## far level every fourth, so a piece cut at a multiple of HEDGE_PIECE_STATIONS
## stations meets its neighbour at every level.
const HEDGE_STEP_M := 0.35
const HEDGE_PIECE_STATIONS := 32


## Lays a clipped hedge of variant along points (its centre line: x, the
## visible ground's height, z) from from_m to to_m of its length into surfs
## (material key -> Surf, added when missing): an opaque leafy core extruded
## along the line (a rounded or boxy profile, lumpy where it was clipped), sprig
## cards along its top shoulders and a few on its sides, and under a rounded
## hedge's canopy its leggy dark stems. lod 2 is the far level: the core alone,
## coarser. The lumps come from seed and each station's index, so pieces of one
## hedge laid separately meet exactly; only the hedge's own ends are capped.
## Bends are rounded off over about a metre.
func hedge_into(surfs: Dictionary, variant: int, points: PackedVector3Array, from_m: float, to_m: float, lod: int, seed: int) -> void:
	var p: Dictionary = HEDGES[variant]
	var lengths := PackedFloat32Array([0.0])
	for i in range(1, points.size()):
		lengths.append(lengths[i - 1] + Vector2(points[i].x - points[i - 1].x, points[i].z - points[i - 1].z).length())
	var total := lengths[lengths.size() - 1]
	from_m = clampf(from_m, 0.0, total)
	to_m = clampf(to_m, from_m, total)
	if to_m - from_m < 0.05:
		return
	var step: float = HEDGE_STEP_M * float([1.0, 2.0, 4.0][lod])
	# The level's grid stations in the stretch, and its ends where they fall between them.
	var stations := PackedFloat64Array()
	var first := ceili(from_m / step - 0.001)
	var last := floori(to_m / step + 0.001)
	if absf(first * step - from_m) > 0.001:
		stations.append(from_m)
	for j in range(first, last + 1):
		stations.append(j * step)
	if absf(last * step - to_m) > 0.001:
		stations.append(to_m)
	var top := float(p.height)
	var base := float(p.canopy_base)
	var d := float(p.depth) * 0.5
	var rounded := str(p.style) == "rounded"
	# The profile across the hedge, [lateral, height] from its left foot over its top to its right foot.
	var profile: Array[Vector2] = []
	if rounded:
		var mid := lerpf(base, top, 0.55)
		var shoulder: Array = [[-0.78, base], [-0.98, lerpf(base, top, 0.22)], [-1.0, mid], [-0.88, top - 0.2], [-0.58, top - 0.05], [-0.2, top]] if lod < 2 else [[-0.85, base], [-1.0, mid], [-0.66, top - 0.06]]
		for entry: Array in shoulder:
			profile.append(Vector2(float(entry[0]) * d, float(entry[1])))
	else:
		profile.append_array([Vector2(-d, -BURY_M), Vector2(-d, top - 0.07), Vector2(-d + 0.07, top)])
	for index in range(profile.size() - 1, -1, -1):
		profile.append(Vector2(-profile[index].x, profile[index].y))
	if rounded:
		# Closed underneath, over the stems.
		profile.append(profile[0])
	var surface_key := str(p.surface)
	if not surfs.has(surface_key):
		surfs[surface_key] = Surf.new()
	var core: Surf = surfs[surface_key]
	var phases := Vector2(_hash01(seed, -1, 0) * TAU, _hash01(seed, -2, 0) * TAU)
	var rings: Array[PackedInt32Array] = []
	var frames: Array[Dictionary] = []
	for station in stations:
		var frame := _hedge_frame(points, lengths, station)
		frames.append(frame)
		var right: Vector3 = frame.right
		var ground: Vector3 = frame.position
		var index := roundi(station / HEDGE_STEP_M)
		var on_grid := absf(station - index * HEDGE_STEP_M) < 0.001
		# Slow lumps along the hedge, and each clipped station a little different.
		var bulge := (0.05 * sin(station * 1.7 + phases.x) + 0.035 * sin(station * 3.9 + phases.y)) * (1.0 if rounded else 0.5)
		var ring := PackedInt32Array()
		var perimeter := 0.0
		for k in profile.size():
			var corner := profile[k]
			if k > 0:
				perimeter += corner.distance_to(profile[k - 1])
			var lateral := corner.x * (1.0 + bulge / maxf(d, 0.1))
			var lift := corner.y
			if on_grid and corner.y > base + 0.05:
				lateral += signf(corner.x) * (_hash01(seed, index, k) - 0.5) * 0.05
				if corner.y > top - 0.25:
					# Soft mounds along a rounded hedge's top, where its shrubs grew together.
					lift += (_hash01(seed, index, k + 100) - 0.5) * 0.05 + bulge * (1.4 if rounded else 0.6)
			var previous := profile[maxi(k - 1, 0)]
			var following := profile[mini(k + 1, profile.size() - 1)]
			var edge := (following - previous).normalized()
			# Outward: the profile runs from the left foot over the top to the right
			# foot (and, rounded, back under), so its normal is the edge turned.
			var outward_2d := Vector2(-edge.y, edge.x)
			var normal := (right * outward_2d.x + Vector3.UP * outward_2d.y).normalized()
			var position := ground + right * lateral + Vector3.UP * lift
			var bottom := lift <= base + 0.01
			var shade := 0.3 if bottom and rounded else lerpf(0.55, 1.0, clampf((lift - base) / maxf(top - base, 0.1), 0.0, 1.0))
			ring.append(core.add(position, normal, Vector2(station / HEDGE_TILE_M, perimeter / HEDGE_TILE_M), Color(shade, shade, shade), Vector2(0.01 * pow(clampf(lift / top, 0.0, 1.0), 2.0), 0.0)))
		rings.append(ring)
	for i in rings.size() - 1:
		for k in profile.size() - 1:
			var a := rings[i][k]
			var b := rings[i][k + 1]
			core.quad(a, rings[i + 1][k], rings[i + 1][k + 1], b, core.normals[a] + core.normals[b])
	# The hedge's own ends are capped, a little rounded.
	for end in 2:
		var station := stations[0] if end == 0 else stations[stations.size() - 1]
		if (end == 0 and station > 0.001) or (end == 1 and station < total - 0.001):
			continue
		var frame: Dictionary = frames[0 if end == 0 else frames.size() - 1]
		var ring: PackedInt32Array = rings[0 if end == 0 else rings.size() - 1]
		var outward: Vector3 = (frame.tangent as Vector3) * (-1.0 if end == 0 else 1.0)
		var centre := Vector3.ZERO
		for vertex in ring:
			centre += core.verts[vertex]
		centre = centre / ring.size() + outward * 0.12
		var middle := core.add(centre, outward, Vector2(0.5, 0.5), Color(0.8, 0.8, 0.8), Vector2(0.005, 0.0))
		for k in profile.size() - 1:
			core.tri(middle, ring[k], ring[k + 1], outward)
	if lod == 2:
		return
	var sprig_cell: Rect2 = SHRUB_CELLS[str(p.sprigs)]
	if not surfs.has("shrub_foliage"):
		surfs["shrub_foliage"] = Surf.new()
	var cards: Surf = surfs["shrub_foliage"]
	var heart_lift := Vector3.UP * (top * 0.4)
	for i in frames.size():
		var station := stations[i]
		var index := roundi(station / HEDGE_STEP_M)
		# A station where two pieces meet carries its cards in the later piece only.
		if absf(station - index * HEDGE_STEP_M) > 0.001 or (lod == 1 and index % 2 == 1) or (station > to_m - 0.001 and to_m < total - 0.001):
			continue
		var frame: Dictionary = frames[i]
		var right: Vector3 = frame.right
		var tangent: Vector3 = frame.tangent
		var ground: Vector3 = frame.position
		# Sprigs stand out of the top shoulders, alternating sides, and a few out of the middle.
		var side := 1.0 if index % 2 == 0 else -1.0
		var along := (_hash01(seed, index, 300) - 0.5) * 0.2
		var at := ground + right * (side * d * 0.55) + tangent * along + Vector3.UP * (top - 0.04)
		var width := 0.55 * lerpf(0.85, 1.15, _hash01(seed, index, 301))
		var tall := 0.3 * lerpf(0.8, 1.2, _hash01(seed, index, 302))
		var shade := lerpf(0.7, 0.86, _hash01(seed, index, 303))
		var up := (Vector3.UP * 0.85 + right * side * 0.35).normalized()
		for k in 2:
			var facing := (right * side).rotated(Vector3.UP, PI * 0.5 * k + (_hash01(seed, index, 304 + k) - 0.5) * 0.5)
			_foliage_card(cards, at, facing, up, width, tall, 0.3, 0.0, sprig_cell, Color(shade, shade, shade), ground + heart_lift, 0.4, top, 0.01, 0.02, lod == 0)
		if lod == 0 and index % 2 == 0:
			# A sprig out of a side face now and then, so the clipped sides aren't smooth.
			var height_on_side := lerpf(base + 0.3, top - 0.25, _hash01(seed, index, 310))
			var lateral := d * (0.98 if rounded else 1.0)
			_foliage_card(cards, ground + right * (side * -1.0 * (lateral + 0.04)) + Vector3.UP * height_on_side, right * -side, Vector3.UP, 0.42, 0.34, 0.5,
				(_hash01(seed, index, 311) - 0.5) * 1.2, sprig_cell, Color(shade * 0.9, shade * 0.9, shade * 0.9), ground + heart_lift, 0.3, top, 0.01, 0.02, true)
		if rounded and index % 2 == 0:
			# The leggy stems under the canopy, on both sides.
			for flank: float in [1.0, -1.0]:
				_foliage_card(cards, ground + right * (flank * d * 0.55) + Vector3.DOWN * 0.06, right * flank, Vector3.UP, 0.9, base + 0.22, 0.0, 0.0,
					SHRUB_CELLS.hedge_stems, Color(0.55, 0.55, 0.55), ground + heart_lift, 0.2, top, 0.0, 0.0, lod == 0)


## Where a hedge stands at distance along its line: {position (the visible
## ground on its centre line), tangent (along it, smoothed over about a metre, so
## bends come out rounded), right}.
func _hedge_frame(points: PackedVector3Array, lengths: PackedFloat32Array, distance: float) -> Dictionary:
	var position := _line_point(points, lengths, distance)
	var ahead := _line_point(points, lengths, minf(distance + 0.5, lengths[lengths.size() - 1]))
	var behind := _line_point(points, lengths, maxf(distance - 0.5, 0.0))
	var tangent := Vector3(ahead.x - behind.x, 0.0, ahead.z - behind.z).normalized()
	return {"position": position, "tangent": tangent, "right": tangent.cross(Vector3.UP).normalized()}


func _line_point(points: PackedVector3Array, lengths: PackedFloat32Array, distance: float) -> Vector3:
	for i in range(1, points.size()):
		if distance <= lengths[i] or i == points.size() - 1:
			var span := maxf(lengths[i] - lengths[i - 1], 0.0001)
			return points[i - 1].lerp(points[i], clampf((distance - lengths[i - 1]) / span, 0.0, 1.0))
	return points[0]


## A straight 4 m run of a hedge variant, for form sheets: {lod0, lod1, far, ...}.
func _build_hedge_sample(variant: int) -> Dictionary:
	var points := PackedVector3Array([Vector3(-2.0, 0.0, 0.0), Vector3(2.0, 0.0, 0.0)])
	var meshes: Array[ArrayMesh] = []
	for lod in 3:
		var surfs := {}
		hedge_into(surfs, variant, points, 0.0, 4.0, lod, 801)
		var mesh := ArrayMesh.new()
		var keys := surfs.keys()
		keys.sort()
		for key: String in keys:
			(surfs[key] as Surf).commit(mesh, material(key))
		meshes.append(mesh)
	return {"lod0": meshes[0], "lod1": meshes[1], "far": meshes[2], "crown_surface": -1, "top_m": float(HEDGES[variant].height), "capsules": []}


# --- Clumping grass ------------------------------------------------------------------------------


## Crossed upright cards of a fountain-shaped clump, curling a little outward
## near the top, the blade tips fluttering.
func _build_grass(p: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = int(p.seed)
	var cell: Rect2 = GRASS_CELLS[str(p.cell)]
	var height := float(p.height)
	var width := float(p.width)
	var cards := int(p.cards)
	var mesh := ArrayMesh.new()
	var leaves := Surf.new()
	var phase := rng.randf() * PI
	for k in cards:
		var angle := phase + PI * k / cards + rng.randf_range(-0.15, 0.15)
		var along := Vector3(cos(angle), 0.0, sin(angle))
		var normal := Vector3(-along.z, 0.0, along.x)
		var card_height := height * rng.randf_range(0.9, 1.08)
		var card_width := width * rng.randf_range(0.9, 1.05)
		var curl := rng.randf_range(-0.12, 0.12)
		var base := leaves.verts.size()
		for j in 3:
			var f := float(j) / 2.0
			var y := lerpf(-0.06, card_height, f)
			for i in 3:
				var x := (float(i) / 2.0 - 0.5) * card_width
				var position := along * x + normal * (curl * f * f * card_width) + Vector3.UP * y
				var outward := Vector3(position.x, 0.0, position.z)
				var n := Vector3.UP * 0.65 + (outward.normalized() * 0.35 if outward.length() > 0.01 else Vector3.ZERO)
				var shade := lerpf(0.58, 1.0, f)
				leaves.add(position, n, cell.position + Vector2(float(i) / 2.0, 1.0 - f) * cell.size, Color(shade, shade, shade), Vector2(0.0, 0.05 * f * f))
		for j in 2:
			for i in 2:
				var a := base + j * 3 + i
				leaves.quad(a, a + 1, a + 4, a + 3, normal)
	leaves.commit(mesh, material("grass"))
	return {"lod0": mesh, "lod1": mesh, "crown_surface": -1, "top_m": height, "capsules": []}


# --- Low plants: Cityside's grasses, perennials and shrubs --------------------------------------------


## A low plant built from the variant's layers, or a drift of several of the
## species' other variants in one mesh ("drift": [[x, z, variant, scale, yaw],
## ...]), so one placed row can carry a whole patch of groundcover. A drift's
## members are not settled one by one, so their bases run on DRIFT_BURY_M below
## the ground: on a bed sloping up to about 10 % none of them floats. Layers:
##   crossed  upright cards of a side-view image (a clump, a shrub's wands, a
##            bunch of flower stalks) crossing at the foot, splayed out from it,
##            one of them flopping further, their tops swaying;
##   shell    face-on foliage cards round a lumpy half-ellipsoid, cupped, sunk
##            in so their ragged edges make the outline and sprawling out over
##            the ground at the rim, over a dark floor that hides the hollow;
##            flat lays them down for a low mat, upright stretches them up;
##   cap      a domed card of a top-view image over a clump or shrub, so it
##            reads as a tuft from above (the jetpack's view), not an X of cards;
##   dome     a low lumpy half-ellipsoid mesh wearing a top-view image, its
##            ragged edge the image's own: a tight cushion;
##   litter   a shallow dish of fallen leaves and stalks round the foot.
## The whole plant leans by lean (a fraction of its height) to one side, and
## each plant takes a slightly different shade and hue from its seed. Colours
## darken toward the ground. Every vertex carries where the plant's dissolve
## ends in its colour's alpha (vegetation_foliage.gdshader's distance_fade).
func _build_low(prop: String, p: Dictionary, fade_m: float) -> Dictionary:
	var surfs := {}
	var top := 0.0
	if p.has("drift"):
		var drift: Array = p.drift
		for index in drift.size():
			var member: Array = drift[index]
			var part: Dictionary = (PROPS[prop].variants as Array)[int(member[2])]
			var scale := float(member[3])
			var frame := {"xf": Transform3D(Basis(Vector3.UP, float(member[4])).scaled(Vector3.ONE * scale), Vector3(float(member[0]), 0.0, float(member[1]))), "scale": scale, "bury": DRIFT_BURY_M / scale}
			# Each member grows from its own seed, so a drift holds no two alike.
			top = maxf(top, _low_layers(part, int(p.seed) * 31 + index, frame, fade_m, surfs) * scale)
	else:
		top = _low_layers(p, int(p.seed), {"xf": Transform3D.IDENTITY, "scale": 1.0}, fade_m, surfs)
	var mesh := ArrayMesh.new()
	var keys := surfs.keys()
	keys.sort()
	for key: String in keys:
		(surfs[key] as Surf).commit(mesh, material(key))
	return {"lod0": mesh, "lod1": mesh, "crown_surface": -1, "top_m": top, "capsules": []}


## Adds one plant's layers to surfs (material key -> Surf) through frame (its
## transform and scale); returns its height.
func _low_layers(p: Dictionary, seed: int, frame: Dictionary, fade_m: float, surfs: Dictionary) -> float:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var height := 0.0
	for layer: Dictionary in p.layers:
		height = maxf(height, float(layer.get("height", 0.0)))
	var lean_angle := rng.randf() * TAU
	frame.lean = Vector3(cos(lean_angle), 0.0, sin(lean_angle)) * float(p.get("lean", 0.0)) * height
	frame.height = maxf(height, 0.05)
	# No two plants of a drift or a bed quite the same shade.
	var shade := rng.randf_range(0.88, 1.0)
	var hue := float(p.get("hue", 0.05))
	frame.tint = Color(shade * rng.randf_range(1.0 - hue, 1.0), shade * rng.randf_range(1.0 - hue * 0.6, 1.0), shade * rng.randf_range(1.0 - hue * 1.4, 1.0))
	var alpha := fade_m / FADE_SCALE_M
	for layer: Dictionary in p.layers:
		var cell: Array = LOW_CELLS[str(layer.cell)]
		if not surfs.has(cell[0]):
			surfs[cell[0]] = Surf.new()
		var surf: Surf = surfs[cell[0]]
		match str(layer.kind):
			"crossed":
				_crossed_layer(surf, rng, layer, cell[1], frame, alpha)
			"shell":
				_shell_layer(surf, rng, layer, cell[1], frame, alpha)
			"dome":
				_dome_layer(surf, rng, layer, cell[1], frame, alpha)
			"cap":
				# Domed over the clump, its rim dipping into the side cards, swaying with
				# the blade tips; shaded like the clump's interior at that height, so from
				# eye height it reads as more of the clump, not a pale disc inside it.
				var at := float(layer.height)
				var tint: Color = layer.get("tint", Color.WHITE)
				var cap_shade := float(layer.get("shade", 0.62))
				_dish(surf, frame, cell[1], at, float(layer.width) * 0.5, at * float(layer.get("drop", 0.35)), Color(cap_shade * tint.r, cap_shade * tint.g, cap_shade * tint.b, alpha), rng.randf() * TAU,
					Vector2(0.0, float(layer.get("flutter", 0.04))))
			"litter":
				var litter := float(layer.get("shade", 0.8))
				_dish(surf, frame, cell[1], 0.012, float(layer.radius), 0.05, Color(litter, litter, litter, alpha), rng.randf() * TAU)
	return height


## Adds a vertex through a low plant's frame: the plant's lean (growing with
## height), then its transform. Returns the vertex index.
func _low_add(s: Surf, frame: Dictionary, position: Vector3, normal: Vector3, uv: Vector2, color: Color, wind: Vector2) -> int:
	# A drift member's parts that reach below the ground run on deeper.
	if position.y < 0.0:
		position.y -= float(frame.get("bury", 0.0))
	var leaned := position + (frame.lean as Vector3) * pow(clampf(position.y / float(frame.height), 0.0, 1.0), 1.5)
	var xf: Transform3D = frame.xf
	var tint: Color = frame.get("tint", Color.WHITE)
	return s.add(xf * leaned, xf.basis * normal, uv, Color(color.r * tint.r, color.g * tint.g, color.b * tint.b, color.a), wind * float(frame.scale))


func _crossed_layer(s: Surf, rng: RandomNumberGenerator, layer: Dictionary, cell: Rect2, frame: Dictionary, alpha: float) -> void:
	var cards := int(layer.cards)
	var width := float(layer.width)
	var height := float(layer.height)
	var base := float(layer.get("base", -0.05))
	var curl_range := float(layer.get("curl", 0.12))
	var splay := tan(deg_to_rad(float(layer.get("splay_deg", 0.0))))
	var flop := tan(deg_to_rad(float(layer.get("flop_deg", 0.0))))
	var flutter := float(layer.get("flutter", 0.05))
	var low := float(layer.get("shade_low", 0.5))
	var tint: Color = layer.get("tint", Color.WHITE)
	var phase := rng.randf() * PI
	for k in cards:
		var angle := phase + PI * k / cards + rng.randf_range(-0.2, 0.2)
		var along := Vector3(cos(angle), 0.0, sin(angle))
		var normal := Vector3(-along.z, 0.0, along.x)
		var card_height := height * rng.randf_range(0.88, 1.08)
		var card_width := width * rng.randf_range(0.88, 1.06)
		var curl := rng.randf_range(-curl_range, curl_range)
		# Alternate cards lean out to either side of the foot; the first flops furthest.
		var lean_out := normal * ((1.0 if k % 2 == 0 else -1.0) * (flop if k == 0 and flop > 0.0 else splay))
		var first := s.verts.size()
		for j in 3:
			var f := float(j) / 2.0
			var y := lerpf(base, card_height, f)
			for i in 3:
				var x := (float(i) / 2.0 - 0.5) * card_width
				var position := along * x + normal * (curl * f * f * card_width) + Vector3.UP * y + lean_out * maxf(y, 0.0)
				var outward := Vector3(position.x, 0.0, position.z)
				var n := Vector3.UP * 0.65 + (outward.normalized() * 0.35 if outward.length() > 0.01 else Vector3.ZERO)
				var shade := lerpf(low, 1.0, f)
				_low_add(s, frame, position, n, cell.position + Vector2(float(i) / 2.0, 1.0 - f) * cell.size, Color(shade * tint.r, shade * tint.g, shade * tint.b, alpha), Vector2(0.0, flutter * f * f))
		for j in 2:
			for i in 2:
				var a := first + j * 3 + i
				s.quad(a, a + 1, a + 4, a + 3, (frame.xf as Transform3D).basis * normal)


func _shell_layer(s: Surf, rng: RandomNumberGenerator, layer: Dictionary, cell: Rect2, frame: Dictionary, alpha: float) -> void:
	var radius := float(layer.width) * 0.5
	var height := float(layer.height)
	var flat := float(layer.get("flat", 0.0))
	var upright := float(layer.get("upright", 0.0))
	# rough (0..1) breaks the outline further: deeper lumps, cards scattered in and out.
	var rough := float(layer.get("rough", 0.0))
	var tint: Color = layer.get("tint", Color.WHITE)
	var count := int(layer.cards)
	var side := float(layer.card) * float(layer.width)
	var heart := Vector3(0.0, height * 0.3, 0.0)
	# The mound sways a little at the top and its leaves flutter.
	var wind := Vector2(0.03 * height, 0.02)
	var phase := rng.randf() * TAU
	# It bulges unevenly round its sides, so no two read as the same egg.
	var lumps := [rng.randf_range(0.08, 0.18) * (1.0 + rough), rng.randf() * TAU, rng.randf_range(0.05, 0.12) * (1.0 + rough), rng.randf() * TAU]
	# A dark floor of the same foliage hides the hollow inside from low views.
	_dish(s, frame, cell, 0.03, radius * 0.75, 0.04, Color(0.32 * tint.r, 0.32 * tint.g, 0.32 * tint.b, alpha), rng.randf() * TAU)
	for i in count:
		# Spread over the dome from its crown to just above the ground, more toward the rim.
		var t := (float(i) + rng.randf_range(0.2, 0.8)) / count
		var polar := lerpf(0.12, 1.42, pow(t, 0.75))
		var azimuth := phase + i * GOLDEN_ANGLE + rng.randf_range(-0.35, 0.35)
		var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
		var bulge := 1.0 + float(lumps[0]) * sin(2.0 * azimuth + float(lumps[1])) + float(lumps[2]) * sin(3.0 * azimuth + float(lumps[3]))
		var surface := out * (radius * bulge * sin(polar)) + Vector3.UP * (height * (0.9 + 0.1 * bulge) * cos(polar))
		var normal := (out * (sin(polar) / radius) + Vector3.UP * (cos(polar) / height)).normalized()
		normal = (normal + Vector3.UP * flat * 2.0).normalized()
		# Low on the mound the cards sprawl out over the ground past the outline.
		var rim := smoothstep(1.0, 1.42, polar)
		var center := surface * rng.randf_range(0.66 - 0.2 * rough, 0.9 + 0.12 * rough) + out * (radius * 0.15 * rim)
		var size := side * rng.randf_range(0.8, 1.2)
		_shell_card(s, frame, center, normal, out, size, upright - flat * 0.45, cell, rng.randf_range(-0.5, 0.5), heart, 0.0, height, rng.randf_range(0.88, 1.05), tint, alpha, wind)


## A tight cushion: a lumpy half-ellipsoid width across and height up, the
## cell's top-view image laid over it from above (its ragged rim on the dome's
## foot), shaded from its heart and darker toward the ground.
func _dome_layer(s: Surf, rng: RandomNumberGenerator, layer: Dictionary, cell: Rect2, frame: Dictionary, alpha: float) -> void:
	var radius := float(layer.width) * 0.5
	var height := float(layer.height)
	var sides := 12
	var lumps := [rng.randf_range(0.04, 0.09), rng.randf() * TAU, rng.randf_range(0.03, 0.06), rng.randf() * TAU]
	var spin := rng.randf() * TAU
	var heart := Vector3(0.0, height * 0.2, 0.0)
	var top := _low_add(s, frame, Vector3.UP * height, Vector3.UP, cell.get_center(), Color(1.0, 1.0, 1.0, alpha), Vector2(0.0, 0.004))
	var previous := PackedInt32Array()
	# A paraboloid that meets the ground at a slant (the top view laid over a
	# vertical skirt would streak down it), its last ring just below the ground.
	var fractions := [0.3, 0.55, 0.75, 0.9, 1.0, 1.06]
	for ring in range(1, fractions.size() + 1):
		var f := float(fractions[ring - 1])
		var current := PackedInt32Array()
		for k in sides:
			var azimuth := TAU * k / sides
			var bulge := 1.0 + float(lumps[0]) * sin(3.0 * azimuth + float(lumps[1])) + float(lumps[2]) * sin(5.0 * azimuth + float(lumps[3]))
			var out := Vector3(cos(azimuth), 0.0, sin(azimuth))
			var position := out * (radius * bulge * f) + Vector3.UP * maxf(height * (1.0 - f * f), -0.03)
			var normal := ((position - heart).normalized() + Vector3.UP * 0.3).normalized()
			# The image laid on from above, a little smaller than the dome so its bristly rim falls on the dome's foot.
			var uv := cell.get_center() + Vector2(position.x, position.z).rotated(spin) / (radius * 2.3) * cell.size
			var shade := lerpf(0.5, 1.0, clampf(position.y / height, 0.0, 1.0))
			current.append(_low_add(s, frame, position, normal, uv, Color(shade, shade, shade, alpha), Vector2(0.0, 0.004 * clampf(position.y / height, 0.0, 1.0))))
		for k in sides:
			var a := current[k]
			var b := current[(k + 1) % sides]
			if ring == 1:
				s.tri(top, a, b, Vector3.UP)
			else:
				s.quad(previous[k], previous[(k + 1) % sides], b, a, (s.verts[a] - (frame.xf as Transform3D) * heart).normalized())
		previous = current


## A shallow dish radius across, its middle at y and its rim drop metres lower:
## on the ground round the foot (a mound's dark floor, a ring of litter), where
## on uneven ground its edge sinks in rather than floats, or over a clump (a cap).
func _dish(s: Surf, frame: Dictionary, cell: Rect2, y: float, radius: float, drop: float, color: Color, spin: float, wind := Vector2.ZERO) -> void:
	var across := Vector3(cos(spin), 0.0, sin(spin))
	var depth := Vector3(-across.z, 0.0, across.x)
	var first := s.verts.size()
	for j in 3:
		for i in 3:
			var u := float(i) - 1.0
			var v := float(j) - 1.0
			var position := (across * u + depth * v) * radius + Vector3.UP * (y - drop * minf(1.0, (u * u + v * v) * 0.5))
			_low_add(s, frame, position, Vector3.UP, cell.position + Vector2(float(i) / 2.0, float(j) / 2.0) * cell.size, color, wind)
	for j in 2:
		for i in 2:
			var a := first + j * 3 + i
			s.quad(a, a + 1, a + 4, a + 3, Vector3.UP)


## One foliage card of a mound or a crown, through frame (a low plant's, or
## IDENTITY_FRAME): side metres across (taller by upright), centred at center
## and facing normal, its image upright along the surface (outward on top),
## turned by spin and cupped back at its corners. Normals lean from heart;
## colour darkens from top_y down to base_y. wind is the UV2 sway and flutter
## at top_y, less below.
func _shell_card(s: Surf, frame: Dictionary, center: Vector3, normal: Vector3, out: Vector3, side: float, upright: float, cell: Rect2, spin: float, heart: Vector3, base_y: float, top_y: float, shade: float, tint: Color, alpha: float, wind: Vector2) -> void:
	var up_axis := Vector3.UP - normal * normal.dot(Vector3.UP)
	if up_axis.length() < 0.25:
		up_axis = out
	up_axis = up_axis.normalized().rotated(normal, spin)
	var across := up_axis.cross(normal).normalized()
	var tall := side * (1.0 + upright)
	var first := s.verts.size()
	for j in 3:
		for i in 3:
			var x := float(i) / 2.0 - 0.5
			var y := float(j) / 2.0 - 0.5
			var position := center + across * (x * side) + up_axis * (y * tall) - normal * (0.18 * side * (x * x + y * y))
			var n := ((position - heart).normalized() * 0.65 + normal * 0.35).normalized()
			var height_f := clampf((position.y - base_y) / maxf(0.01, top_y - base_y), 0.0, 1.0)
			var c := shade * lerpf(0.42, 1.0, pow(height_f, 0.8))
			_low_add(s, frame, position, n, cell.position + Vector2(x + 0.5, 0.5 - y) * cell.size, Color(c * tint.r, c * tint.g, c * tint.b, alpha), wind * height_f)
	for j in 2:
		for i in 2:
			var a := first + j * 3 + i
			s.quad(a, a + 1, a + 4, a + 3, (frame.xf as Transform3D).basis * normal)


# --- Shared geometry --------------------------------------------------------------------------------


## A tube along points with the given radii; u wraps u_repeat times around, v
## advances one per v_metres of length. winds holds each ring's UV2.
func _tube(s: Surf, points: PackedVector3Array, radii: PackedFloat32Array, colors: PackedColorArray, winds: PackedVector2Array, sides: int, u_repeat: float, v_metres: float) -> void:
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
			s.add(points[i] + direction * radii[i], direction, Vector2(u_repeat * k / sides, v), colors[i], winds[i])
	for i in count - 1:
		for k in sides:
			var a := rings[i] + k
			s.quad(a, a + 1, rings[i + 1] + k + 1, rings[i + 1] + k, s.normals[a] + s.normals[rings[i + 1] + k + 1])


func _perpendicular(direction: Vector3) -> Vector3:
	var reference := Vector3.RIGHT if absf(direction.x) < 0.9 else Vector3.FORWARD
	return direction.cross(reference).normalized()


# --- Impostors ---------------------------------------------------------------------------------------


## Where a variant's impostor image is framed on its LOD0: centre and size in
## metres, looking along -Z. A palm's impostor is only its crown (its trunk stays
## geometry); a cypress's, gum's or oak's is the whole tree. The bake renders
## exactly this frame.
func impostor_frame(prop: String, variant: int) -> Dictionary:
	var tree := build(prop, variant)
	var mesh: ArrayMesh = tree.lod0
	var box := _surface_bounds(mesh, int(tree.crown_surface)) if int(tree.crown_surface) >= 0 else mesh.get_aabb()
	return {"center": box.get_center(), "size": Vector2(maxf(box.size.x, box.size.z), box.size.y) * 1.04, "tree": tree}


static func impostor_texture_path(prop: String, variant: int) -> String:
	return TEXTURES + "impostors/%s_%d.png" % [prop, variant]


## The far mesh of a tree: a palm's low trunk (and knob) under its crown
## impostor, or a cypress's, gum's or oak's impostor alone; null for a low plant
## or when the image hasn't been baked.
func impostor_mesh(prop: String, variant: int) -> ArrayMesh:
	if is_low_plant(prop) or not ResourceLoader.exists(impostor_texture_path(prop, variant)):
		return null
	var frame := impostor_frame(prop, variant)
	var tree: Dictionary = frame.tree
	var center: Vector3 = frame.center
	var size: Vector2 = frame.size
	var mesh := ArrayMesh.new()
	if str(PROPS[prop].form) in ["fan_palm", "canary_palm"]:
		var bark := Surf.new()
		var shade := func(_h: float) -> Color: return Color(0.9, 0.9, 0.9)
		var wood := "fan_palm_bark" if prop == "mexican_fan_palm" else "canary_bark"
		_palm_trunk(bark, tree.shape, 4, 5, tree.radius, FAN_BARK_M if prop == "mexican_fan_palm" else CANARY_BARK_M, 0.0, shade)
		if prop == "canary_date_palm":
			var knob: Dictionary = tree.knob
			_canary_knob(bark, knob.top, knob.axis, float(knob.length), knob.radius, 2, 6, 0.0, 1.0, 0.0)
		bark.commit(mesh, material(wood))
	var quad := Surf.new()
	var first := quad.verts.size()
	for corner: Vector2 in [Vector2(-0.5, -0.5), Vector2(0.5, -0.5), Vector2(0.5, 0.5), Vector2(-0.5, 0.5)]:
		# UV2 holds the corner's offset from the pivot (the shader turns the quad).
		quad.add(center, Vector3.BACK, Vector2(corner.x + 0.5, 0.5 - corner.y), Color.WHITE, corner * size)
	quad.indices.append_array(PackedInt32Array([first, first + 1, first + 2, first, first + 2, first + 3]))
	quad.commit(mesh, _impostor_material(prop, variant))
	# The quad turns in the vertex shader; bound every direction it can face.
	var reach := maxf(size.x * 0.5, 0.1)
	mesh.custom_aabb = (tree.lod0 as ArrayMesh).get_aabb().merge(AABB(center - Vector3(reach, size.y * 0.5, reach), Vector3(reach * 2.0, size.y, reach * 2.0)))
	return mesh


func _surface_bounds(mesh: ArrayMesh, surface: int) -> AABB:
	var vertices: PackedVector3Array = mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
	var box := AABB(vertices[0], Vector3.ZERO)
	for vertex in vertices:
		box = box.expand(vertex)
	return box


# --- Materials --------------------------------------------------------------------------------------------


func material(key: String) -> Material:
	if _materials.has(key):
		return _materials[key]
	var made: ShaderMaterial
	match key:
		"fan_palm_bark":
			made = _bark("fan_palm_bark.png", Color(0.84, 0.82, 0.78))
		"canary_bark":
			made = _bark("canary_trunk_bark.png", Color(0.88, 0.85, 0.82))
		"canary_knob":
			made = _bark("canary_knob.png", Color(0.6, 0.53, 0.47))
		"cypress_bark":
			made = _bark("cypress_bark.png", Color(0.92, 0.9, 0.88))
		"fan_palm_foliage":
			made = _foliage("fan_palm_foliage_atlas.png", Color(0.66, 0.7, 0.62), Color(0.09, 0.11, 0.05), Vector2(1024.0, 1024.0), 0.15, 0.82)
		"canary_foliage":
			made = _foliage("canary_frond_atlas.png", Color(0.8, 0.85, 0.74), Color(0.1, 0.13, 0.05), Vector2(512.0, 2048.0), 0.15, 0.82)
		"cypress_foliage":
			made = _foliage("cypress_foliage_atlas.png", Color(0.74, 0.8, 0.6), Color(0.08, 0.12, 0.04), Vector2(1024.0, 512.0), 0.06, 0.95)
		"grass":
			made = _foliage("grass_atlas.png", Color(0.92, 0.94, 0.86), Color(0.18, 0.2, 0.1), Vector2(1024.0, 512.0), 0.1, 0.9)
			made.set_shader_parameter("alpha_cutoff", 0.4)
		"meadow":
			made = _foliage("meadow_atlas.png", Color(0.92, 0.94, 0.86), Color(0.18, 0.2, 0.1), Vector2(2048.0, 2048.0), 0.1, 0.9)
			made.set_shader_parameter("alpha_cutoff", 0.4)
			made.set_shader_parameter("distance_fade", true)
			made.set_shader_parameter("fade_length_m", LOW_FADE_M)
		"perennial":
			made = _foliage("perennial_atlas.png", Color(0.95, 0.95, 0.92), Color(0.12, 0.14, 0.07), Vector2(2048.0, 1536.0), 0.08, 0.92)
			made.set_shader_parameter("distance_fade", true)
			made.set_shader_parameter("fade_length_m", LOW_FADE_M)
		"young_tree_foliage":
			made = _foliage("young_tree_foliage_atlas.png", Color(0.88, 0.92, 0.86), Color(0.1, 0.13, 0.05), Vector2(1024.0, 512.0), 0.12, 0.85)
		"gum_bark":
			made = _bark("gum_bark.png", Color(0.95, 0.95, 0.93))
		"oak_bark":
			made = _bark("oak_bark.png", Color(0.85, 0.83, 0.8))
		"pine_bark":
			made = _bark("pine_bark.png", Color(0.9, 0.88, 0.86))
		"pine_foliage":
			made = _foliage("pine_foliage_atlas.png", Color(0.94, 0.98, 0.9), Color(0.06, 0.09, 0.03), Vector2(1024.0, 512.0), 0.08, 0.9)
		"broadleaf_bark":
			made = _bark("broadleaf_bark.png", Color(0.92, 0.9, 0.88))
		"christmas_bark":
			made = _bark("christmas_bark.png", Color(0.95, 0.94, 0.92))
		"broadleaf_foliage":
			made = _foliage("broadleaf_foliage_atlas.png", Color(0.88, 0.9, 0.84), Color(0.08, 0.1, 0.03), Vector2(1024.0, 1024.0), 0.12, 0.8)
		"eucalyptus_bark":
			made = _bark("eucalyptus_bark.png", Color(0.92, 0.91, 0.9))
		"set_piece_foliage":
			made = _foliage("set_piece_foliage_atlas.png", Color(0.9, 0.92, 0.88), Color(0.08, 0.1, 0.04), Vector2(1024.0, 1024.0), 0.1, 0.85)
		"shrub_foliage":
			made = _foliage("shrub_foliage_atlas.png", Color(0.9, 0.92, 0.88), Color(0.08, 0.1, 0.04), Vector2(2048.0, 1024.0), 0.12, 0.82)
		"hedge_leaves":
			made = _bark("hedge_surface.png", Color(0.74, 0.8, 0.72))
		"glossy_hedge_leaves":
			made = _bark("escallonia_surface.png", Color(0.86, 0.9, 0.86))
			made.set_shader_parameter("specular", 0.35)
			made.set_shader_parameter("roughness", 0.65)
	made.set_shader_parameter("wind_strength", wind_strength)
	made.resource_name = "street_vegetation_" + key
	_materials[key] = made
	return made


func _impostor_material(prop: String, variant: int) -> Material:
	var key := "impostor_%s_%d" % [prop, variant]
	if not _materials.has(key):
		var made := ShaderMaterial.new()
		made.shader = IMPOSTOR_SHADER
		made.set_shader_parameter("albedo_texture", load(impostor_texture_path(prop, variant)))
		# The bake is lit flat, the impostor in the sun without the crown's own shade:
		# a dense crown's far level is darkened to meet its near levels (impostor_tint
		# is sRGB, set from the measured LOD0-to-far brightness at one pose).
		made.set_shader_parameter("tint", PROPS[prop].get("impostor_tint", Color.WHITE))
		made.resource_name = "street_vegetation_" + key
		_materials[key] = made
	return _materials[key]


func _bark(file: String, tint: Color) -> ShaderMaterial:
	var bark := ShaderMaterial.new()
	bark.shader = BARK_SHADER
	bark.set_shader_parameter("albedo_texture", load(TEXTURES + file))
	bark.set_shader_parameter("tint", tint)
	return bark


func _foliage(file: String, tint: Color, translucency: Color, size: Vector2, specular: float, roughness: float) -> ShaderMaterial:
	var foliage := ShaderMaterial.new()
	foliage.shader = FOLIAGE_SHADER
	foliage.set_shader_parameter("albedo_texture", load(TEXTURES + file))
	foliage.set_shader_parameter("tint", tint)
	foliage.set_shader_parameter("translucency", translucency)
	foliage.set_shader_parameter("texture_size", size)
	# Low specular: card normals bend toward the crown silhouette, where a
	# glossy grazing reflection would outline every card in pale sky colour.
	foliage.set_shader_parameter("specular", specular)
	foliage.set_shader_parameter("roughness", roughness)
	return foliage
