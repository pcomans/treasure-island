extends RefCounted
## Island ground cover: which shared ground-cover family each generated land or
## area record uses, and that family's material. Families only change how the
## shared shader mixes maintained lawn, dry grass and bare soil (a late-spring
## look read from dated Mar/Sep 2025 street views and undated overheads).
## Mesh arrays, collision and every other record keep the builder's handling.

const SHADER := preload("res://game/resources/materials/world/ground_cover/ground_cover.gdshader")
const DETAIL_ALBEDO := preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_diff_1k.jpg")
const DETAIL_NORMAL := preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_nor_gl_1k.jpg")
const DETAIL_ROUGHNESS := preload("res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_rough_1k.jpg")

## Hard courts reuse the builder's existing parking material.
const PAVED := "paved"

## Shader mix per family. Thresholds are levels of the shader's patch noise
## (median 0.5): about 10% of a lawn turns dry, 22% of residential grounds,
## 40% of sports fields, 68% of open fields; bare soil covers about 18% of
## fields and 82% of bare ground.
const FAMILIES := {
	"lawn": {"dry_threshold": 0.71, "bare_threshold": 2.0, "green_dryness": 0.0, "patch_scale_m": 18.0, "bare_scale_m": 23.0},
	"residential": {"dry_threshold": 0.63, "bare_threshold": 2.0, "green_dryness": 0.0, "patch_scale_m": 24.0, "bare_scale_m": 23.0},
	"sports": {"dry_threshold": 0.55, "bare_threshold": 2.0, "green_dryness": 0.15, "patch_scale_m": 28.0, "bare_scale_m": 23.0},
	"field": {"dry_threshold": 0.42, "bare_threshold": 0.66, "green_dryness": 0.35, "patch_scale_m": 32.0, "bare_scale_m": 21.0},
	"bare": {"dry_threshold": -1.0, "bare_threshold": 0.345, "green_dryness": 0.0, "patch_scale_m": 20.0, "bare_scale_m": 15.0},
}

## Family per generated material key. Parking, terrain overlays, roads,
## buildings and the Yerba Buena context keep their existing materials.
const FAMILY_BY_MATERIAL_KEY := {
	"land_ground": "field",
	"major_area_landuse": "residential",
	"major_area_leisure": "lawn",
	"major_area_amenity": "lawn",
}

## Frozen 2026-08-27 OSM areas whose tags the generated material keys merge.
const FAMILY_BY_SOURCE := {
	"r17241152": "bare", # landuse=construction: redevelopment parcel, overheads show bare fill soil
	"w775820810": "bare", # landuse=construction: same
	"w775820811": "bare", # landuse=construction: same
	"w899364786": "bare", # landuse=construction: same
	"w899364787": "bare", # landuse=construction: same
	"w1252737732": "bare", # landuse=construction: same
	"w1252737734": "bare", # landuse=construction: same
	"w1252737754": "bare", # landuse=construction: same
	"w269856850": "bare", # landuse=industrial: yard, overheads show gravel and bare ground
	"w545387428": "bare", # leisure=pitch sport=boules: gravel court
	"w28356842": PAVED, # leisure=pitch sport=basketball: hard court
	"w96665888": PAVED, # leisure=pitch sport=basketball: hard court
	"w96665934": PAVED, # leisure=pitch sport=basketball: hard court
	"w1163035324": PAVED, # leisure=pitch sport=basketball: hard court
	"w1307988013": PAVED, # leisure=pitch sport=basketball: hard court
	"w1102656842": PAVED, # leisure=pitch sport=tennis: hard court
	"w1061513876": PAVED, # leisure=pitch sport=skateboard surface=concrete: skate park
	"w99060807": "sports", # leisure=pitch, GAA Field A: natural grass, drier in the overhead
	"w99060801": "sports", # leisure=pitch, GAA Field B: same
	"w133809962": "sports", # leisure=pitch sport=baseball: natural grass field
	"w133809964": "sports", # leisure=pitch sport=baseball: natural grass field
	"w28353177": "sports", # leisure=sports_centre sport=baseball, Tepper Little League Field #1
	"w109022547": "sports", # leisure=sports_centre, Ketcham Little League Field #2
	"w1043836449": "field", # amenity=school, SFFD training facility: no reference for a lawn
}

static var _materials: Dictionary = {}


## The family for a generated land or area record: a FAMILIES key, PAVED, or ""
## when the builder keeps its own material.
static func family_for(record: Dictionary, is_context: bool) -> String:
	if is_context:
		return ""
	var feature := str(record.get("feature_kind", ""))
	if feature == "major_area":
		var sources: Array = record.get("source_keys", [])
		if sources.size() == 1 and FAMILY_BY_SOURCE.has(str(sources[0])):
			return str(FAMILY_BY_SOURCE[str(sources[0])])
	elif feature != "land_ground":
		return ""
	return str(FAMILY_BY_MATERIAL_KEY.get(str(record.get("material_key", "")), ""))


## One shared ShaderMaterial per family.
static func material(family: String) -> ShaderMaterial:
	if _materials.has(family):
		return _materials[family]
	var made := ShaderMaterial.new()
	made.resource_name = "ground_cover_" + family
	made.shader = SHADER
	made.set_shader_parameter("detail_albedo", DETAIL_ALBEDO)
	made.set_shader_parameter("detail_normal", DETAIL_NORMAL)
	made.set_shader_parameter("detail_roughness", DETAIL_ROUGHNESS)
	var preset: Dictionary = FAMILIES[family]
	for parameter: String in preset:
		made.set_shader_parameter(parameter, preset[parameter])
	_materials[family] = made
	return made
