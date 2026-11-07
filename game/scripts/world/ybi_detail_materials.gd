extends RefCounted
## Materials of Yerba Buena Island's photographed façades and its summit sculpture
## (context records context:ybi-buildings:facade:KEY and context:ybi-buildings:spire,
## tools/lib/ybi-context-generation.mjs). Every other YBI building keeps the neutral L1
## wall and roof of Treasure Island's own generic massing.

const FACADE_SHADER := preload("res://game/resources/materials/world/ybi/ybi_facade.gdshader")
const SPIRE_SHADER := preload("res://game/resources/materials/world/ybi/ybi_spire.gdshader")
const FACADE_PREFIX := "context_ybi_facade_"
const SPIRE_KEY := "context_ybi_spire"

## Each photographed building's façade look, from its dated photos: wall and band
## colours, the dark band within a storey, the light pier's share of a bay, the floors
## that carry bands and the podium's form-board ribs per bay. The generator measures it
## (UVs in bays and storeys: tools/lib/ybi-context-generation.mjs and its config hold the
## storey height and each building's bay width). Bands on the faces no photo shows are
## inferred.
const FACADES := {
	# The Bristol (w813225688): white render, charcoal window bays and balcony frames,
	# six floors over a board-formed podium (Street View Nov 2025, ybi01b and ybi02).
	"bristol": {"wall_color": Color(0.87, 0.86, 0.83), "band_color": Color(0.16, 0.17, 0.18), "band_from": 0.28, "band_to": 0.86, "pier_share": 0.24, "floors": 6.0, "ribs_per_bay": 16.0},
	# The Cove townhouses at 299 Macalla Road (w1228080320): white walls, charcoal projecting
	# window boxes, four floors (Street View Nov 2025, ybi03).
	"cove": {"wall_color": Color(0.88, 0.88, 0.86), "band_color": Color(0.15, 0.16, 0.17), "band_from": 0.22, "band_to": 0.85, "pier_share": 0.55, "floors": 4.0, "ribs_per_bay": 13.0},
	# 36 Meadow Drive (w1228080322): white render with grey-brown panels over a pale brick
	# base, four floors (Street View Sep 2025, ybi04).
	"meadow": {"wall_color": Color(0.86, 0.85, 0.82), "band_color": Color(0.42, 0.38, 0.33), "band_from": 0.3, "band_to": 0.78, "pier_share": 0.5, "floors": 4.0, "ribs_per_bay": 18.0},
}

static var _facades: Dictionary = {}


static func is_detail_key(material_key: String) -> bool:
	return material_key == SPIRE_KEY or (material_key.begins_with(FACADE_PREFIX) and FACADES.has(material_key.trim_prefix(FACADE_PREFIX)))


## The material for a YBI detail record, or null for any other key.
static func material(material_key: String, vertices: PackedVector3Array, uvs: PackedVector2Array) -> ShaderMaterial:
	if material_key == SPIRE_KEY:
		return spire_material(vertices, uvs)
	var style := material_key.trim_prefix(FACADE_PREFIX)
	if not material_key.begins_with(FACADE_PREFIX) or not FACADES.has(style):
		return null
	if _facades.has(style):
		return _facades[style]
	var made := ShaderMaterial.new()
	made.resource_name = material_key
	made.shader = FACADE_SHADER
	var params: Dictionary = FACADES[style]
	for parameter: String in params:
		made.set_shader_parameter(parameter, params[parameter])
	_facades[style] = made
	return made


## The spire's steel and concrete, its axis taken from the mesh: a surface of revolution
## closing on its tip, the one vertex on its axis at the top, and its rim the sculpture's
## ring at height 0 (UV.x below 1 marks the sculpture, UV.y its height above the rim;
## the bed round it carries UV.x of 2 and more). Null when the mesh has no such rim.
static func spire_material(vertices: PackedVector3Array, uvs: PackedVector2Array) -> ShaderMaterial:
	if vertices.is_empty() or uvs.size() != vertices.size():
		return null
	var tip := vertices[0]
	for vertex: Vector3 in vertices:
		if vertex.y > tip.y:
			tip = vertex
	var rim := INF
	for index in vertices.size():
		if uvs[index].x <= 1.0 and absf(uvs[index].y) < 0.0005:
			rim = minf(rim, vertices[index].y)
	if not is_finite(rim):
		return null
	var made := ShaderMaterial.new()
	made.resource_name = SPIRE_KEY
	made.shader = SPIRE_SHADER
	made.set_shader_parameter("axis_base", Vector3(tip.x, rim, tip.z))
	made.set_shader_parameter("height_m", tip.y - rim)
	return made
