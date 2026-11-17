extends RefCounted
## Wood-chip mulch: one shared material per mulch surface kind of the generated world
## (the street trees' pits share the planting strips'), drawing the shared chip tile
## (tools/bake_mulch_chips.mjs) in world metres with mulch.gdshader, graded per kind
## from that kind's dated photos. The ground dressing (ground_dressing.gd) finds these
## surfaces by their shader and lays loose chips on them near the camera.
##
## Which surfaces are mulch is GRADES; every other key keeps the builder's own
## material. The brown ground that is not wood mulch keeps its own: the grey gravel
## patch by the forked log (park_chips_pale), the bare and dry ground-cover families
## (construction fill, yards, the boules court), excavated soil (yard_soil_dark), the
## worked yards' sand, gravel and rubble, decomposed granite (park_dg, promenade_dg),
## gravel and crushed rock (park_gravel, promenade_rock), the red marsh floor
## (terrain_wetland), the old sand courts (terrain_sand) and the grass verges
## (street_kerb_verge).

const SHADER := preload("res://game/resources/materials/world/street/mulch.gdshader")
const CHIPS := preload("res://game/resources/textures/world/street/mulch_chips.png")
## The chip tile's width on the ground, metres (tools/bake_mulch_chips.mjs TILE_M).
const TILE_M := 1.25
## The tile's mean of the gaps' rise, weighted by the chips' brightness
## (tools/bake_mulch_chips.mjs GAP_COVER), for mulch.gdshaderinc's far gaps.
const GAP_COVER := 0.991

## Per key: tint (a linear multiplier of the chips' colour), saturation (the share of
## the chips' own colour kept, 0 grey), damp (darker and glossier), relief_m (the pile's
## relief), fresh_share (how much of the bed is fresher, browner mulch), gap_albedo
## (the deepest gaps' colour as a share, per channel), gap_ao (the sky light they keep),
## gap_light (the share of the sun they lose with it) and planted (a park zone's planted
## bed, which blends to its planted colour far off). Production inference, set so each
## kind renders, beside a surface the game already draws, in the ratio its dated photo
## shows (each line names its photos), with the recorded noon sun.
const GRADES := {
	# The park outside Isle House (owner video 2026-11-15, f_076, f_090, f_103):
	# shredded chips, weathered silver-grey on top of browner ones, dark gaps; the bed at
	# f_090's matched pose renders within a few levels of the frame's mean and luminance
	# percentiles.
	"park_chips": {"tint": Vector3(0.7, 0.62, 0.51), "saturation": 0.85, "damp": 0.0, "relief_m": 0.013, "fresh_share": 0.45, "gap_albedo": Vector3(0.5, 0.42, 0.32), "gap_ao": 0.4, "gap_light": 0.45, "planted": false},
	# Its stormwater basin, damp after rain (f_038, f_051, f_058): darker, browner.
	"park_chips_damp": {"tint": Vector3(0.62, 0.55, 0.46), "saturation": 0.95, "damp": 0.35, "relief_m": 0.011, "fresh_share": 0.3, "gap_albedo": Vector3(0.5, 0.42, 0.32), "gap_ao": 0.4, "gap_light": 0.45, "planted": false},
	# A park zone's planted beds: Cityside Park's (Google Maps contributor photos ph04
	# and ph08, Sep 2025: dark grey-brown shredded bark with very dark gaps, about 0.7 of
	# the bike path's asphalt in ph08 and paler in ph04's full sun; rendered between the
	# two), Garden Walk's and the Mersea lot's 9th Street strip (Street View Sep 2025,
	# pano zSYuqR9R0oyboW2wFZ-wEw: the same dark bark, worn flatter).
	"park_mulch": {"tint": Vector3(0.315, 0.279, 0.23), "saturation": 0.85, "damp": 0.0, "relief_m": 0.012, "fresh_share": 0.35, "gap_albedo": Vector3(0.3, 0.26, 0.19), "gap_ao": 0.3, "gap_light": 0.6, "planted": true},
	# The Mersea promenade's bark mulch (owner video IMG_0960, 2026-11-06, t=248 and
	# t=262: pale grey-brown bark, about the tone of the old road beside it, a little
	# warmer); at t=262's matched pose it renders within about a tenth of the road's tone.
	"promenade_mulch": {"tint": Vector3(0.422, 0.353, 0.268), "saturation": 0.7, "damp": 0.0, "relief_m": 0.011, "fresh_share": 0.25, "gap_albedo": Vector3(0.55, 0.48, 0.38), "gap_ao": 0.45, "gap_light": 0.4, "planted": false},
	# The street planting strips (Street View Sep 2025, ih02 at 5286 Ave of the Palms:
	# dark brown bark between the grasses, about half the sidewalk's brightness; Cityside's
	# ph08 has its bark at 0.4 of the concrete beside it): rendered at about 0.45. The
	# street trees' pits in paving draw this material too (street_vegetation_builder.gd):
	# no dated photo shows a pit's surface closely, so theirs is production inference.
	"street_kerb_planting": {"tint": Vector3(0.455, 0.403, 0.318), "saturation": 0.8, "damp": 0.0, "relief_m": 0.011, "fresh_share": 0.3, "gap_albedo": Vector3(0.4, 0.35, 0.27), "gap_ao": 0.35, "gap_light": 0.5, "planted": false},
}

static var _materials: Dictionary = {}


static func is_mulch(material_key: String) -> bool:
	return GRADES.has(material_key)


## The shared material for a mulch surface.
static func material(material_key: String) -> ShaderMaterial:
	if _materials.has(material_key):
		return _materials[material_key]
	var made := ShaderMaterial.new()
	made.resource_name = material_key
	made.shader = SHADER
	apply(made, material_key)
	_materials[material_key] = made
	return made


## Sets a mulch material's chip tile and grade.
static func apply(made: ShaderMaterial, material_key: String) -> void:
	var grade: Dictionary = GRADES[material_key]
	made.set_shader_parameter("mulch_chips", CHIPS)
	made.set_shader_parameter("chip_tile_m", TILE_M)
	made.set_shader_parameter("mulch_gap_cover", GAP_COVER)
	made.set_shader_parameter("mulch_tint", grade.tint)
	made.set_shader_parameter("mulch_saturation", float(grade.saturation))
	made.set_shader_parameter("mulch_damp", float(grade.damp))
	made.set_shader_parameter("mulch_relief_m", float(grade.relief_m))
	made.set_shader_parameter("mulch_fresh_share", float(grade.fresh_share))
	made.set_shader_parameter("mulch_gap_albedo", grade.gap_albedo)
	made.set_shader_parameter("mulch_gap_ao", float(grade.gap_ao))
	made.set_shader_parameter("mulch_gap_light", float(grade.gap_light))
	made.set_shader_parameter("planted_far", bool(grade.planted))
