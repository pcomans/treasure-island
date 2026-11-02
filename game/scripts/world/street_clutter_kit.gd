extends RefCounted
## The street-clutter kit: meshes, collision and the shared material for the
## items of PlayableWorld/StreetDetail/Clutter (parked cars, cones, A-frame
## barricades). The meshes are built offline by tools/lib/street-clutter-kit.mjs
## into street_clutter_kit.glb, two detail levels each; one shader
## (street_clutter.gdshader) colours their parts from a palette texture, and each
## parked car is a MultiMesh instance whose custom data picks its paint and style.
##
## Prop frame: origin on the visible ground under the middle of the item, +Y up,
## front -Z (a car's nose), +X its right side.

const KIT_SCENE := preload("res://game/resources/models/street/street_clutter_kit.glb")
const SHADER := preload("res://game/resources/materials/world/street/street_clutter.gdshader")

## Part colours (sRGB), in the order of the kit's parts (CLUTTER_KIT_PARTS):
## paint and roof are placeholders (the instance paint replaces them), roof's
## black variant and dark rims reuse trim and hub.
const PART_COLORS := [
	Color(0.5, 0.5, 0.5), # paint
	Color(0.5, 0.5, 0.5), # roof
	Color(0.07, 0.085, 0.1), # glass: dark, the sky shows in its reflection
	Color(0.12, 0.12, 0.125), # tire
	Color(0.74, 0.75, 0.77), # rim (alloy)
	Color(0.11, 0.11, 0.12), # hub, spoke gaps, dark rims
	Color(0.09, 0.095, 0.1), # trim: black plastic, cladding, pillars, mirrors
	Color(0.86, 0.87, 0.88), # chrome
	Color(0.58, 0.6, 0.62), # head lamp lens over its reflector
	Color(0.55, 0.05, 0.05), # tail lamp
	Color(0.88, 0.88, 0.85), # plate
	Color(0.05, 0.05, 0.05), # under: wheel wells, underbody
	Color(0.07, 0.07, 0.075), # grille
	Color(0.95, 0.42, 0.08), # orange: cones, barricade boards
	Color(0.92, 0.92, 0.9), # white: reflective collars, stripes, sign panels
	Color(0.66, 0.67, 0.68), # metal: galvanised frames
]
## Car paints by name (sRGB), sampled from the dated pilot photos (Sep and Nov
## 2025): mostly white, black, greys and silvers, some dark and bright blue, red.
const PAINTS := {
	"white": Color(0.9, 0.9, 0.89),
	"pearl_white": Color(0.88, 0.88, 0.85),
	"black": Color(0.05, 0.05, 0.055),
	"silver": Color(0.66, 0.68, 0.7),
	"light_grey": Color(0.55, 0.57, 0.59),
	"grey": Color(0.36, 0.37, 0.39),
	"dark_grey": Color(0.2, 0.21, 0.22),
	"navy": Color(0.1, 0.13, 0.22),
	"blue": Color(0.1, 0.25, 0.62),
	"red": Color(0.5, 0.06, 0.06),
	"beige": Color(0.64, 0.58, 0.47),
	"green": Color(0.16, 0.26, 0.2),
	"brown": Color(0.3, 0.2, 0.14),
}
const FINISHES := ["solid", "metallic", "pearl"]
## Car bodies of the kit (tools/lib/street-clutter-kit.mjs CAR_BODIES); a
## prop's collision box is its near mesh's bounds.
const CAR_BODIES := ["crossover", "suv", "sedan", "fastback", "hatchback", "wagon", "pickup", "utility", "van"]
## Detail levels: the near mesh within LOD_NEAR_M of its cell's centre, the
## far mesh beyond, to the prop's range.
const LOD_NEAR_M := 60.0
const PROPS := {
	"parked_car": {"range_m": 260.0, "shadow": true},
	"traffic_cone": {"range_m": 90.0, "shadow": true},
	"barricade": {"range_m": 110.0, "shadow": true},
}

var _material: ShaderMaterial
var _meshes: Dictionary = {}
var _shapes: Dictionary = {}


func _init() -> void:
	var image := Image.create_empty(32, 2, false, Image.FORMAT_RGBA8)
	for index in PART_COLORS.size():
		image.set_pixel(index, 0, PART_COLORS[index])
	var names := paint_names()
	for index in names.size():
		image.set_pixel(index, 1, PAINTS[names[index]])
	_material = ShaderMaterial.new()
	_material.resource_name = "street_clutter"
	_material.shader = SHADER
	_material.set_shader_parameter("palette", ImageTexture.create_from_image(image))
	var scene := KIT_SCENE.instantiate()
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		_meshes[str(node.name)] = (node as MeshInstance3D).mesh
	scene.free()


static func paint_names() -> Array:
	var names: Array = PAINTS.keys()
	names.sort()
	return names


func material() -> ShaderMaterial:
	return _material


## What to build for one placed row: {ok, meshes: [near, far], custom: Color,
## shape, shape_transform, range_m, shadow} or {ok: false, message}.
func parts(prop: String, params: Dictionary) -> Dictionary:
	if not PROPS.has(prop):
		return {"ok": false, "message": "unknown street-clutter prop %s" % prop}
	var result := {"ok": true, "range_m": float(PROPS[prop].range_m), "shadow": bool(PROPS[prop].shadow), "custom": Color(0, 0, 0, 0)}
	var base := ""
	if prop == "parked_car":
		var body := str(params.get("body", ""))
		var paint := str(params.get("paint", ""))
		var finish := FINISHES.find(str(params.get("finish", "")))
		if not body in CAR_BODIES or not PAINTS.has(paint) or finish < 0:
			return {"ok": false, "message": "parked_car needs a known body, paint and finish: %s" % [params]}
		base = "car_%s" % body
		var style := finish
		if str(params.get("roof", "body")) == "black":
			style |= 4
		if str(params.get("rims", "alloy")) == "dark":
			style |= 8
		var paint_index := paint_names().find(paint)
		result.custom = Color((float(paint_index) + 0.5) / 32.0, (float(style) + 0.5) / 16.0, 0.0, 0.0)
	else:
		base = prop
	var near: Variant = _meshes.get("%s_lod0" % base, null)
	var far: Variant = _meshes.get("%s_lod1" % base, null)
	if not near is Mesh or not far is Mesh:
		return {"ok": false, "message": "the street-clutter kit has no meshes for %s" % base}
	result.meshes = [near, far]
	result.mesh_key = base
	if not _shapes.has(base):
		# A box over the near mesh's bounds, its floor on the ground.
		var bounds: AABB = (near as Mesh).get_aabb()
		var shape := BoxShape3D.new()
		shape.size = Vector3(bounds.size.x, bounds.end.y, bounds.size.z)
		_shapes[base] = {"shape": shape, "transform": Transform3D(Basis.IDENTITY, Vector3(bounds.get_center().x, bounds.end.y * 0.5, bounds.get_center().z))}
	result.shape = _shapes[base].shape
	result.shape_transform = _shapes[base].transform
	return result
