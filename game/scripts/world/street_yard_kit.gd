extends RefCounted
## The yard kit: the large clutter of the island's storage, truck and
## construction yards (tools/lib/street-yard-kit.mjs has the registry,
## tools/lib/street-yard-meshes.mjs the meshes, built into
## street_yard_kit.glb with two detail levels each). One shader
## (street_yard.gdshader) colours every part from a palette texture; a
## piece's MultiMesh custom data picks its three paints and its weathering.
##
## pieces() turns one placed row (a prop key and its params) into the meshes to
## instance and the collision shapes to add, all in the row's prop frame:
## origin on the ground under the middle of the plan rectangle, +Y up, front
## -Z, +X right. Long props are modules repeated along Z (shed and fabric-shed
## bays, berm and ridge modules), container stacks and walls are several
## containers, a barge is its hull modules plus its crane or cargo.
## StreetClutterBuilder draws them (rows of the clutter layer).

const KIT_SCENE := preload("res://game/resources/models/street/street_yard_kit.glb")
const SHADER := preload("res://game/resources/materials/world/street/street_yard.gdshader")
const CLUTTER_KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
const SLOTS := 64
## Detail levels: the near mesh within LOD_NEAR_M of its cell's centre (the
## street-clutter kit's hand-over, so both kits switch at one distance).
const LOD_NEAR_M := CLUTTER_KIT.LOD_NEAR_M

## Part colours (sRGB), in the order of YARD_KIT_PARTS; parts painted by the
## instance (SOURCE in the shader) keep a placeholder grey.
const PART_COLORS := [
	Color(0.5, 0.5, 0.5), # paint
	Color(0.5, 0.5, 0.5), # roof
	Color(0.1, 0.115, 0.135), # glass
	Color(0.12, 0.12, 0.125), # tire
	Color(0.72, 0.73, 0.74), # rim
	Color(0.11, 0.11, 0.12), # hub
	Color(0.09, 0.095, 0.1), # trim
	Color(0.86, 0.87, 0.88), # chrome
	Color(0.58, 0.6, 0.62), # head_lamp
	Color(0.55, 0.05, 0.05), # tail_lamp
	Color(0.88, 0.88, 0.85), # plate
	Color(0.05, 0.05, 0.05), # under
	Color(0.07, 0.07, 0.075), # grille
	Color(0.95, 0.42, 0.08), # orange
	Color(0.92, 0.92, 0.9), # white
	Color(0.66, 0.67, 0.68), # metal
	Color(0.5, 0.5, 0.5), # corrugated
	Color(0.5, 0.5, 0.5), # container_roof
	Color(0.5, 0.5, 0.5), # container_door
	Color(0.5, 0.5, 0.5), # container_frame
	Color(0.55, 0.56, 0.57), # lock_bar
	Color(0.5, 0.5, 0.5), # accent
	Color(0.5, 0.5, 0.5), # rollup
	Color(0.5, 0.5, 0.5), # shed_wall
	Color(0.5, 0.5, 0.5), # shed_roof
	Color(0.5, 0.5, 0.5), # fabric
	Color(0.44, 0.38, 0.3), # timber: weathered fir
	Color(0.6, 0.5, 0.37), # earth: the tan soil of the 2025 yard photos
	Color(0.4, 0.4, 0.39), # gravel: dark crushed aggregate
	Color(0.66, 0.63, 0.58), # rubble: broken concrete
	Color(0.045, 0.045, 0.05), # plastic: black sheeting
	Color(0.5, 0.5, 0.5), # concrete
	Color(0.5, 0.5, 0.5), # crane_red
	Color(0.5, 0.5, 0.5), # hull
	Color(0.07, 0.08, 0.11), # tarp: black-blue tarps (Avenue N, Nov 2025)
	Color(0.5, 0.5, 0.5), # deck
	Color(0.5, 0.5, 0.5), # cab_paint
	Color(0.06, 0.06, 0.06), # inside
	Color(0.5, 0.5, 0.5), # fiberglass
	Color(0.5, 0.5, 0.5), # canvas
	Color(0.2, 0.2, 0.21), # window_frame
	Color(0.06, 0.06, 0.06), # seal
	Color(0.9, 0.9, 0.88), # white_body
	Color(0.78, 0.78, 0.76), # vent
	Color(0.5, 0.5, 0.5), # tank
	Color(0.06, 0.06, 0.065), # belt
]
## Named paints (sRGB): the params' colour names (YARD_COLOURS) and a few the
## kit picks itself. Container and wall colours are sampled from the dated
## photos (Sep 2025 9th St and Avenue I, Mar and Nov 2025 Avenue M, Mar 2025
## 3rd St, Jul 2023 Avenue E and 12th St).
const COLOURS := {
	"beige": Color(0.66, 0.6, 0.48),
	"black": Color(0.05, 0.05, 0.055),
	"blue": Color(0.14, 0.3, 0.58),
	"blue_grey": Color(0.5, 0.58, 0.65),
	"brown": Color(0.33, 0.23, 0.16),
	"cream": Color(0.86, 0.83, 0.74),
	"dark_grey": Color(0.22, 0.23, 0.24),
	"green": Color(0.18, 0.3, 0.27),
	"grey": Color(0.56, 0.58, 0.59),
	"light_grey": Color(0.72, 0.73, 0.72),
	"orange": Color(0.78, 0.38, 0.13),
	"red": Color(0.5, 0.16, 0.13),
	"rust": Color(0.48, 0.24, 0.14),
	"silver": Color(0.66, 0.68, 0.7),
	"tan": Color(0.66, 0.58, 0.44),
	"white": Color(0.86, 0.87, 0.86),
	"yellow": Color(0.86, 0.64, 0.1),
	"concrete_light": Color(0.7, 0.69, 0.66),
	"concrete_dark": Color(0.48, 0.48, 0.47),
	"door_grey": Color(0.6, 0.61, 0.62),
	"plank": Color(0.5, 0.43, 0.33),
}

## Props: far range (m), whether they cast shadows, their variants (mesh
## names or shapes) in index order. Must match YARD_KIT_PROPS.
const PROPS := {
	"shipping_container": {"range_m": 1500.0, "variants": ["container_20ft", "container_40ft", "container_40ft_hc", "container_20ft_rollup", "container_40ft_office", "container_10ft"]},
	"container_wall": {"range_m": 1500.0, "variants": ["single", "double"]},
	"storage_shed_row": {"range_m": 1500.0, "variants": ["double", "single", "wide"]},
	"rv": {"range_m": 700.0, "variants": ["rv_class_a", "rv_class_c", "rv_travel_trailer", "rv_fifth_wheel"]},
	"bus": {"range_m": 700.0, "variants": ["bus_coach", "bus_shuttle"]},
	"box_truck": {"range_m": 700.0, "variants": ["box_truck_medium", "box_truck_large"]},
	"van": {"range_m": 600.0, "variants": ["van_cargo", "van_step"]},
	"food_truck": {"range_m": 600.0, "variants": ["food_truck_step_van", "food_truck_trailer"]},
	"boat_on_trailer": {"range_m": 600.0, "variants": ["runabout", "cabin"]},
	"trailer": {"range_m": 700.0, "variants": ["trailer_cargo", "trailer_utility", "trailer_semi", "trailer_office"]},
	"fabric_shed": {"range_m": 1500.0, "variants": ["span10", "span15", "span20", "span30"]},
	"equipment": {"range_m": 700.0, "variants": ["excavator", "wheel_loader", "crane_mats", "cylinder_section", "open_bin", "hopper", "conveyor"]},
	"material_pile": {"range_m": 1500.0, "variants": ["gravel", "rubble", "soil", "tarp", "ridge"]},
	"plastic_berm": {"range_m": 1500.0, "variants": ["low", "high"]},
	"crane_barge": {"range_m": 2500.0, "variants": ["crane", "deck", "pier_crane"]},
}
## Plan sizes (x, z) and heights of the fixed-size props, as yardPropFootprint
## gives them: a vehicle's collision box is its plan rectangle to its height.
const PLANS := {
	"rv": [[2.55, 11.6, 3.75], [2.4, 8.5, 3.45], [2.44, 9.0, 3.25], [2.5, 10.5, 3.9]],
	"bus": [[2.6, 13.7, 3.7], [2.4, 8.2, 3.2]],
	"box_truck": [[2.4, 7.4, 3.5], [2.6, 10.4, 4.0]],
	"van": [[2.02, 5.93, 2.65], [2.4, 7.0, 3.0]],
	"food_truck": [[2.4, 7.3, 3.3], [2.44, 6.2, 3.0]],
	"boat_on_trailer": [[2.5, 7.3, 2.2], [2.6, 8.8, 2.9]],
	"trailer": [[2.6, 7.3, 3.0], [2.4, 4.5, 1.55], [2.6, 16.2, 4.1], [3.66, 14.6, 3.5]],
	"equipment": [[3.2, 10.0, 3.2], [3.0, 8.0, 3.5], [1.2, 9.1, 1.2], [1.8, 1.8, 1.3], [2.44, 6.9, 1.85], [4.0, 4.0, 8.0], [1.4, 0.0, 0.0]],
}
## Containers (tools/lib/street-yard-kit.mjs): width, heights, lengths.
const CONTAINER_W := 2.438
const CONTAINER_H := 2.591
const CONTAINER_HC_H := 2.896
const CONTAINER_LENGTHS := {"40ft": 12.192, "20ft": 6.058, "10ft": 2.991}
const WALL_GAP_M := 0.12
const MAX_WALL_GAP_M := 0.6
## Shed rows, fabric sheds, berms and ridges (tools/lib/street-yard-meshes.mjs).
const SHED_BAY_M := 3.05
const SHED_END_M := 0.15
const SHEDS := {
	"double": {"hw": 3.66, "eave": 2.62, "ridge": 3.1, "mono": false},
	"single": {"hw": 2.285, "eave": 2.44, "front": 2.86, "mono": true},
	"wide": {"hw": 6.095, "eave": 2.9, "ridge": 3.8, "mono": false},
}
const FABRIC_BAY_M := 5.0
const FABRIC_END_M := 0.2
const FABRICS := {
	"span10": {"hw": 5.0, "eave": 3.5, "ridge": 5.2},
	"span15": {"hw": 7.5, "eave": 4.0, "ridge": 6.4},
	"span20": {"hw": 10.0, "eave": 4.5, "ridge": 7.6},
	"span30": {"hw": 15.0, "eave": 5.0, "ridge": 9.6},
}
const BERM_MODULE_M := 6.0
const RIDGE_MODULE_M := 4.0
## A conveyor: 6 m truss modules rising at 16 degrees from a foot 1.2 m up.
const CONVEYOR_MODULE_M := 6.0
const CONVEYOR_INCLINE := deg_to_rad(16.0)
const CONVEYOR_FOOT_M := 1.2
const BARGE_RAKE_M := 3.0
const BARGE_FREEBOARD_M := 1.0
## Default weathering (0..1) by prop; a row's weathering param overrides it.
const WEATHERING := {
	"shipping_container": 0.6, "container_wall": 0.5, "storage_shed_row": 0.35, "fabric_shed": 0.3,
	"crane_barge": 0.85, "equipment": 0.45, "trailer": 0.3,
}

var _material: ShaderMaterial
var _meshes: Dictionary = {}
var _hulls: Dictionary = {}
var _colour_index: Dictionary = {}


func _init() -> void:
	var image := Image.create_empty(SLOTS, 2, false, Image.FORMAT_RGBA8)
	for index in PART_COLORS.size():
		image.set_pixel(index, 0, PART_COLORS[index])
	var names := colour_names()
	for index in names.size():
		image.set_pixel(index, 1, COLOURS[names[index]])
		_colour_index[names[index]] = index
	_material = ShaderMaterial.new()
	_material.resource_name = "street_yard"
	_material.shader = SHADER
	_material.set_shader_parameter("palette", ImageTexture.create_from_image(image))
	var scene := KIT_SCENE.instantiate()
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		_meshes[str(node.name)] = (node as MeshInstance3D).mesh
	scene.free()


static func colour_names() -> Array:
	var names: Array = COLOURS.keys()
	names.sort()
	return names


static func is_prop(prop: String) -> bool:
	return PROPS.has(prop)


func material() -> ShaderMaterial:
	return _material


## A palette column for a colour name (custom data channel value).
func _column(colour: String) -> float:
	return (float(_colour_index.get(colour, _colour_index["grey"])) + 0.5) / float(SLOTS)


## Custom data of one piece: three paints and the weathering level with a seed.
func _custom(primary: String, secondary: String, tertiary: String, level: float, seed: int) -> Color:
	var seed_fraction := float(seed % 9973) / 9973.0
	return Color(_column(primary), _column(secondary), _column(tertiary), (floorf(clampf(level, 0.0, 1.0) * 15.0) + seed_fraction * 0.999) / 16.0)


## A small repeatable number in [0, 1) from a seed and an index.
static func _unit(seed: int, index: int) -> float:
	var value := (seed * 1103515245 + index * 12345 + 1013904223) & 0x7fffffff
	value = (value ^ (value >> 13)) * 1274126177 & 0x7fffffff
	return float(value % 10007) / 10007.0


## What to build for one placed row: {ok, pieces: [{mesh_key, meshes: [near,
## far], transform, custom}], shapes: [{shape, transform}], range_m,
## lod_near_m, shadow}, or {ok: false, message}. default_seed varies the
## weathering when the row has no seed.
func pieces(prop: String, params: Dictionary, default_seed: int = 0) -> Dictionary:
	if not PROPS.has(prop):
		return {"ok": false, "message": "unknown yard prop %s" % prop}
	var variant_value: Variant = params.get("variant", null)
	var variants: Array = PROPS[prop].variants
	if not (variant_value is int or variant_value is float) or int(variant_value) < 0 or int(variant_value) >= variants.size():
		return {"ok": false, "message": "%s needs a variant 0..%d: %s" % [prop, variants.size() - 1, params]}
	var variant := int(variant_value)
	var seed := int(params.get("seed", default_seed)) & 0x7fffffff
	var level := float(params.get("weathering", WEATHERING.get(prop, 0.2)))
	var result := {"ok": true, "pieces": [], "shapes": [], "range_m": float(PROPS[prop].range_m), "lod_near_m": LOD_NEAR_M, "shadow": true}
	var error := ""
	match prop:
		"shipping_container":
			error = _container_stack(result, variants[variant], params, level, seed)
		"container_wall":
			error = _container_wall(result, variant, params, level, seed)
		"storage_shed_row":
			error = _shed_row(result, variants[variant], params, level, seed)
		"fabric_shed":
			error = _fabric_shed(result, variants[variant], params, level, seed)
		"plastic_berm":
			error = _modules(result, "berm_%s" % variants[variant], int(params.get("modules", 0)), BERM_MODULE_M, _custom("black", "black", "black", level, seed))
		"material_pile":
			error = _pile(result, variants[variant], params, level, seed)
		"crane_barge":
			error = _barge(result, variants[variant], params, level, seed)
		"equipment":
			error = _equipment(result, variant, variants[variant], params, level, seed)
		_:
			error = _vehicle(result, prop, variant, variants[variant], params, level, seed)
	if error != "":
		return {"ok": false, "message": "%s: %s" % [prop, error]}
	return result


func _meshes_for(name: String) -> Array:
	var near: Variant = _meshes.get("%s_lod0" % name, null)
	var far: Variant = _meshes.get("%s_lod1" % name, null)
	if not near is Mesh or not far is Mesh:
		return []
	return [near, far]


## Adds one piece; "" or why it can't.
func _add(result: Dictionary, name: String, transform: Transform3D, custom: Color) -> String:
	var meshes := _meshes_for(name)
	if meshes.is_empty():
		return "the yard kit has no meshes for %s" % name
	(result.pieces as Array).append({"mesh_key": name, "meshes": meshes, "transform": transform, "custom": custom})
	return ""


func _box(result: Dictionary, size: Vector3, center: Vector3, basis: Basis = Basis.IDENTITY) -> void:
	var shape := BoxShape3D.new()
	shape.size = size
	(result.shapes as Array).append({"shape": shape, "transform": Transform3D(basis, center)})


## A convex prism over a cross-section ([x, y] points) from z0 to z1.
func _prism(result: Dictionary, section: Array, z0: float, z1: float) -> void:
	var points := PackedVector3Array()
	for point: Array in section:
		points.append(Vector3(point[0], point[1], z0))
		points.append(Vector3(point[0], point[1], z1))
	var shape := ConvexPolygonShape3D.new()
	shape.points = points
	(result.shapes as Array).append({"shape": shape, "transform": Transform3D.IDENTITY})


## A convex hull over a piece's far mesh at a uniform scale, cached per mesh
## and scale (the scale is baked into the points: shapes keep unscaled transforms).
func _hull(result: Dictionary, name: String, offset: Vector3, scale: float = 1.0) -> void:
	var key := "%s@%.3f" % [name, scale]
	if not _hulls.has(key):
		var mesh: Mesh = _meshes_for(name)[1]
		var points := PackedVector3Array()
		for point in mesh.get_faces():
			points.append(point * scale)
		var shape := ConvexPolygonShape3D.new()
		shape.points = points
		_hulls[key] = shape
	(result.shapes as Array).append({"shape": _hulls[key], "transform": Transform3D(Basis.IDENTITY, offset)})


func _colour(params: Dictionary, key: String, fallback: String) -> String:
	var value := str(params.get(key, fallback))
	return value if COLOURS.has(value) else fallback


# ---------------------------------------------------------------- containers

func _container_stack(result: Dictionary, mesh: String, params: Dictionary, level: float, seed: int) -> String:
	var high := mesh == "container_40ft_hc"
	var height := CONTAINER_HC_H if high else CONTAINER_H
	var length := 12.192 if mesh.begins_with("container_40ft") else (2.991 if mesh == "container_10ft" else 6.058)
	var stack := int(params.get("stack", 1))
	var colour := _colour(params, "colour", "white")
	var top := _colour(params, "colour_top", colour)
	for tier in stack:
		var error := _add(result, mesh, Transform3D(Basis.IDENTITY, Vector3(0, height * tier, 0)), _custom(colour if tier == 0 else top, "white", "door_grey", level, seed + tier * 7))
		if error != "":
			return error
	_box(result, Vector3(CONTAINER_W, height * stack, length), Vector3(0, height * stack * 0.5, 0))
	return ""


## The wall's containers: tools/lib/street-yard-kit.mjs containerWallLayout, exactly.
static func wall_layout(length_m: float) -> Array:
	var sizes: Array = []
	var used := -WALL_GAP_M
	for size: String in ["40ft", "20ft", "10ft"]:
		while used + WALL_GAP_M + float(CONTAINER_LENGTHS[size]) <= length_m + 1e-9:
			sizes.append(size)
			used += WALL_GAP_M + float(CONTAINER_LENGTHS[size])
	var gaps := sizes.size() - 1
	var spare := length_m - used
	var gap := minf(MAX_WALL_GAP_M, WALL_GAP_M + spare / gaps) if gaps > 0 else 0.0
	var containers: Array = []
	var at := -length_m / 2.0
	for size: String in sizes:
		var box := float(CONTAINER_LENGTHS[size])
		containers.append({"z_m": at + box / 2.0, "length_m": box, "size": size})
		at += box + gap
	return containers


func _container_wall(result: Dictionary, variant: int, params: Dictionary, level: float, seed: int) -> String:
	var length := float(params.get("length_m", 0.0))
	if length < 2.991:
		return "container_wall needs length_m"
	var tiers := 2 if variant == 1 else 1
	var colour := _colour(params, "colour", "green")
	var top := _colour(params, "colour_top", colour)
	var index := 0
	for box: Dictionary in wall_layout(length):
		# Every other box turned end for end, as walls are set out from stock.
		var basis := Basis(Vector3.UP, PI) if index % 2 == 1 else Basis.IDENTITY
		for tier in tiers:
			var tier_level := clampf(level + (_unit(seed, index * 2 + tier) - 0.5) * 0.4, 0.0, 1.0)
			var error := _add(result, "container_%s" % box.size, Transform3D(basis, Vector3(0, CONTAINER_H * tier, float(box.z_m))), _custom(colour if tier == 0 else top, "white", "door_grey", tier_level, seed + index * 13 + tier))
			if error != "":
				return error
		_box(result, Vector3(CONTAINER_W, CONTAINER_H * tiers, float(box.length_m)), Vector3(0, CONTAINER_H * tiers * 0.5, float(box.z_m)))
		index += 1
	return ""


# ---------------------------------------------------------------- sheds

func _shed_row(result: Dictionary, variant: String, params: Dictionary, level: float, seed: int) -> String:
	var bays := int(params.get("bays", 0))
	if bays < 2:
		return "storage_shed_row needs bays >= 2"
	var spec: Dictionary = SHEDS[variant]
	var custom := _custom(_colour(params, "wall", "beige"), _colour(params, "roof", "beige"), _colour(params, "doors", "white"), level, seed)
	var length := bays * SHED_BAY_M
	var z0 := -length / 2.0
	var error := _add(result, "shed_%s_end_neg" % variant, Transform3D(Basis.IDENTITY, Vector3(0, 0, z0)), custom)
	for bay in bays:
		error += _add(result, "shed_%s_bay" % variant, Transform3D(Basis.IDENTITY, Vector3(0, 0, z0 + SHED_BAY_M * (bay + 0.5))), custom)
	error += _add(result, "shed_%s_end_pos" % variant, Transform3D(Basis.IDENTITY, Vector3(0, 0, -z0)), custom)
	var hw := float(spec.hw)
	var section: Array
	if spec.mono:
		section = [[-hw, 0.0], [hw, 0.0], [hw, float(spec.front)], [-hw, float(spec.eave)]]
	else:
		section = [[-hw, 0.0], [hw, 0.0], [hw, float(spec.eave)], [0.0, float(spec.ridge)], [-hw, float(spec.eave)]]
	_prism(result, section, z0, -z0)
	return error


func _fabric_shed(result: Dictionary, span: String, params: Dictionary, level: float, seed: int) -> String:
	var bays := int(params.get("bays", 0))
	if bays < 2:
		return "fabric_shed needs bays >= 2"
	var spec: Dictionary = FABRICS[span]
	var fabric := _colour(params, "fabric", "white")
	var custom := _custom(fabric, fabric, fabric, level, seed)
	var length := bays * FABRIC_BAY_M
	var z0 := -length / 2.0
	var error := _add(result, "fabric_%s_end_neg" % span, Transform3D(Basis.IDENTITY, Vector3(0, 0, z0)), custom)
	for bay in bays:
		error += _add(result, "fabric_%s_bay" % span, Transform3D(Basis.IDENTITY, Vector3(0, 0, z0 + FABRIC_BAY_M * (bay + 0.5))), custom)
	error += _add(result, "fabric_%s_end_pos" % span, Transform3D(Basis.IDENTITY, Vector3(0, 0, -z0)), custom)
	var hw := float(spec.hw)
	_prism(result, [[-hw, 0.0], [hw, 0.0], [hw, float(spec.eave)], [0.0, float(spec.ridge)], [-hw, float(spec.eave)]], z0 - FABRIC_END_M, -z0 + FABRIC_END_M)
	return error


## A modular ridge (berm or windrow): two rounded ends (half a module each)
## and modules - 1 middles, each with its own convex hull.
func _modules(result: Dictionary, base: String, modules: int, module_m: float, custom: Color) -> String:
	if modules < 1:
		return "%s needs at least one module" % base
	var length := modules * module_m
	var half := module_m / 2.0
	var error := ""
	var placements: Array = [["%s_end_neg" % base, -length / 2.0 + half]]
	for index in modules - 1:
		placements.append(["%s_mid" % base, -length / 2.0 + half + module_m * (index + 0.5)])
	placements.append(["%s_end_pos" % base, length / 2.0 - half])
	for placement: Array in placements:
		var transform := Transform3D(Basis.IDENTITY, Vector3(0, 0, float(placement[1])))
		error += _add(result, str(placement[0]), transform, custom)
		if error == "":
			_hull(result, str(placement[0]), transform.origin)
	return error


func _pile(result: Dictionary, material: String, params: Dictionary, level: float, seed: int) -> String:
	var custom := _custom("grey", "grey", "grey", level, seed)
	if material == "ridge":
		var length := float(params.get("length_m", 0.0))
		return _modules(result, "ridge", maxi(1, roundi(length / RIDGE_MODULE_M)), RIDGE_MODULE_M, custom)
	var shape := clampi(int(params.get("shape", 0)), 0, 2)
	var scale := clampf(float(params.get("scale", 1.0)), 0.5, 3.0)
	var name := "pile_%s_%d" % [material, shape]
	var transform := Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * scale), Vector3.ZERO)
	var error := _add(result, name, transform, custom)
	if error == "":
		_hull(result, name, Vector3.ZERO, scale)
	return error


# ---------------------------------------------------------------- vehicles and equipment

func _vehicle(result: Dictionary, prop: String, variant: int, mesh: String, params: Dictionary, level: float, seed: int) -> String:
	var primary := "white"
	var secondary := "white"
	var tertiary := "dark_grey"
	match prop:
		"rv":
			primary = _colour(params, "paint", "white")
			secondary = _colour(params, "stripe", "grey")
		"bus":
			primary = _colour(params, "paint", "white")
			var accent := str(params.get("accent", "none"))
			secondary = primary if accent == "none" else _colour(params, "accent", primary)
		"box_truck":
			primary = _colour(params, "cab", "white")
			secondary = _colour(params, "box", "white")
			tertiary = "door_grey"
		"van", "food_truck":
			primary = _colour(params, "paint", "white")
			tertiary = "door_grey"
		"trailer":
			primary = _colour(params, "paint", "white")
			secondary = "plank"
			tertiary = "grey"
		"boat_on_trailer":
			primary = _colour(params, "hull", "white")
			var cover := str(params.get("cover", "none"))
			secondary = "grey" if cover == "none" else _colour(params, "cover", "blue")
			mesh = "boat_%s_%s" % [mesh, "open" if cover == "none" else "covered"]
	var error := _add(result, mesh, Transform3D.IDENTITY, _custom(primary, secondary, tertiary, level, seed))
	var plan: Array = PLANS[prop][variant]
	_box(result, Vector3(plan[0], plan[2], plan[1]), Vector3(0, float(plan[2]) * 0.5, 0))
	return error


func _equipment(result: Dictionary, variant: int, mesh: String, params: Dictionary, level: float, seed: int) -> String:
	if mesh == "conveyor":
		return _conveyor(result, float(params.get("length_m", 0.0)), level, seed)
	if mesh == "cylinder_section":
		var tone := "concrete_dark" if str(params.get("tone", "light")) == "dark" else "concrete_light"
		var cylinder := CylinderShape3D.new()
		cylinder.radius = 0.9
		cylinder.height = 1.3
		(result.shapes as Array).append({"shape": cylinder, "transform": Transform3D(Basis.IDENTITY, Vector3(0, 0.65, 0))})
		return _add(result, mesh, Transform3D.IDENTITY, _custom(tone, tone, tone, level, seed))
	# A hopper is white unless the row paints it; machines take the paint (yellow by default).
	var paint := _colour(params, "paint", "white" if mesh == "hopper" else "yellow")
	if mesh == "excavator":
		# The machine, and its boom and bucket out in front.
		_box(result, Vector3(3.2, 3.2, 4.9), Vector3(0, 1.6, 0.4))
		_box(result, Vector3(1.3, 3.1, 4.6), Vector3(0.2, 1.55, -3.7))
	else:
		var plan: Array = PLANS.equipment[variant]
		_box(result, Vector3(plan[0], plan[2], plan[1]), Vector3(0, float(plan[2]) * 0.5, 0))
	return _add(result, mesh, Transform3D.IDENTITY, _custom(paint, paint, "dark_grey", level, seed))


## A conveyor: its truss modules end to end up the incline (rising toward +Z),
## a leg under every joint; the legs are its collision.
func _conveyor(result: Dictionary, length_m: float, level: float, seed: int) -> String:
	if length_m < 12.0:
		return "conveyor needs length_m"
	var modules := maxi(2, roundi(length_m / (CONVEYOR_MODULE_M * cos(CONVEYOR_INCLINE))))
	var plan := modules * CONVEYOR_MODULE_M * cos(CONVEYOR_INCLINE)
	var pitch := Basis(Vector3.RIGHT, -CONVEYOR_INCLINE)
	var custom := _custom("grey", "grey", "grey", level, seed)
	var error := ""
	for index in modules:
		var t := (index + 0.5) * CONVEYOR_MODULE_M
		var centre := Vector3(0, CONVEYOR_FOOT_M + t * sin(CONVEYOR_INCLINE), -plan / 2.0 + t * cos(CONVEYOR_INCLINE))
		error += _add(result, "conveyor_module", Transform3D(pitch, centre), custom)
	for joint in modules + 1:
		var t := joint * CONVEYOR_MODULE_M
		var height := CONVEYOR_FOOT_M + t * sin(CONVEYOR_INCLINE)
		var z := -plan / 2.0 + t * cos(CONVEYOR_INCLINE)
		error += _add(result, "conveyor_leg", Transform3D(Basis.IDENTITY.scaled(Vector3(1, height, 1)), Vector3(0, 0, z)), custom)
		_box(result, Vector3(1.12, height, 0.12), Vector3(0, height * 0.5, z))
	return error


# ---------------------------------------------------------------- barges

## A barge (hull modules, deck cargo, crane, deckhouse) or the pier crane. No
## collision: Pier 1 is visual context outside the playable boundary.
func _barge(result: Dictionary, variant: String, params: Dictionary, level: float, seed: int) -> String:
	var red := _custom("red", "red", "dark_grey", 0.35, seed)
	if variant == "pier_crane":
		return _add(result, "crawler_crane_pier", Transform3D.IDENTITY, red)
	var length := clampf(float(params.get("length_m", 40.0 if variant == "crane" else 36.0)), 15.0, 100.0)
	var width := clampf(float(params.get("width_m", 30.0 if variant == "crane" else 18.0)), 8.0, 40.0)
	var hull := _custom(_colour(params, "hull", "dark_grey"), _colour(params, "deck", "rust"), "dark_grey", level, seed)
	var middle := length - 2.0 * BARGE_RAKE_M
	var error := _add(result, "barge_end_neg", Transform3D(Basis.IDENTITY.scaled(Vector3(width, 1, 1)), Vector3(0, 0, -middle / 2.0)), hull)
	error += _add(result, "barge_mid", Transform3D(Basis.IDENTITY.scaled(Vector3(width, 1, middle)), Vector3.ZERO), hull)
	error += _add(result, "barge_end_pos", Transform3D(Basis.IDENTITY.scaled(Vector3(width, 1, 1)), Vector3(0, 0, middle / 2.0)), hull)
	var deck := BARGE_FREEBOARD_M
	if variant == "crane":
		error += _add(result, "crawler_crane_barge", Transform3D(Basis.IDENTITY, Vector3(0, deck, length / 2.0 - 7.5)), red)
	match str(params.get("cargo", "none")):
		"containers":
			# One red 40 ft box, then white 20 ft boxes, in a row along the deck.
			var z := -length / 2.0 + BARGE_RAKE_M + 1.0
			var index := 0
			while true:
				var forty := index == 0
				var box_length := 12.192 if forty else 6.058
				if z + box_length > length / 2.0 - BARGE_RAKE_M - (16.0 if variant == "crane" else 1.0):
					break
				var colour := "red" if forty else "white"
				error += _add(result, "container_40ft" if forty else "container_20ft", Transform3D(Basis.IDENTITY, Vector3(0, deck, z + box_length / 2.0)), _custom(colour, "white", "door_grey", 0.6, seed + index))
				z += box_length + 0.4
				index += 1
		"materials":
			error += _add(result, "deck_materials", Transform3D(Basis.IDENTITY, Vector3(0, deck, -length / 4.0)), _custom("grey", "grey", "grey", 0.4, seed))
	if str(params.get("deckhouse", "none")) == "small":
		error += _add(result, "deckhouse", Transform3D(Basis.IDENTITY, Vector3(width / 2.0 - 2.4, deck, length / 2.0 - BARGE_RAKE_M - 3.0)), _custom("white", "white", "white", 0.3, seed))
	return error
