extends RefCounted
## Wood-chip mulch: one shared material per mulch surface of the generated world,
## drawing the shared chip tile (tools/bake_mulch_chips.mjs) in world metres with
## mulch.gdshader, graded per material from the dated photos of each kind. The
## ground dressing (ground_dressing.gd) finds these surfaces by their shader and lays
## loose chips on them near the camera. Which surfaces are mulch, and which brown
## ground is not (dirt, gravel, decomposed granite, construction ground), is listed in
## GRADES; a key not in it keeps the builder's own material.

const SHADER := preload("res://game/resources/materials/world/street/mulch.gdshader")
const CHIPS := preload("res://game/resources/textures/world/street/mulch_chips.png")
## The chip tile's width on the ground, metres (tools/bake_mulch_chips.mjs TILE_M).
const TILE_M := 1.25

## Per material key: tint (a linear multiplier of the chips' colour), saturation
## (the share of the chips' own colour kept, 0 grey), damp (darker and glossier),
## relief_m (the pile's relief) and fresh_share (how much of the bed is fresher,
## browner mulch). Production inference: park_chips set so the bed at f_090's matched
## pose (about 10 m) renders within a few levels of the frame's mean and luminance
## percentiles, with the recorded noon sun.
const GRADES := {
	# The park outside Isle House (owner video 2026-11-15, f_076, f_090, f_103):
	# shredded chips, weathered silver-grey on top of browner ones, dark gaps.
	"park_chips": {"tint": Vector3(0.7, 0.62, 0.51), "saturation": 0.85, "damp": 0.0, "relief_m": 0.013, "fresh_share": 0.45},
	# Its stormwater basin, damp after rain (f_038, f_051, f_058): darker, browner.
	"park_chips_damp": {"tint": Vector3(0.62, 0.55, 0.46), "saturation": 0.95, "damp": 0.35, "relief_m": 0.011, "fresh_share": 0.3},
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
	made.set_shader_parameter("mulch_tint", grade.tint)
	made.set_shader_parameter("mulch_saturation", float(grade.saturation))
	made.set_shader_parameter("mulch_damp", float(grade.damp))
	made.set_shader_parameter("mulch_relief_m", float(grade.relief_m))
	made.set_shader_parameter("mulch_fresh_share", float(grade.fresh_share))
