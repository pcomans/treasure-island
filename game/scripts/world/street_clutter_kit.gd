extends RefCounted
## The street-clutter kit: meshes, collision and the shared material for the
## items of PlayableWorld/StreetDetail/Clutter (parked cars, cones, A-frame
## barricades, dumpsters, stock-tank planters). The meshes are built offline by
## tools/lib/street-clutter-kit.mjs and street-car-kit.mjs into
## street_clutter_kit.glb, two detail levels each (a car's: near, wheels and all,
## and far) and a car's shadow caster; one shader (street_clutter.gdshader)
## colours their parts from a palette texture, and each parked car is a
## MultiMesh instance whose custom data picks its paint and style and carries
## its suspension twist (the generator settles each car on its four tyres; the
## twist is what a rigid body cannot take up on uneven ground).
##
## A car's hero level (street_car_hero_kit.glb: body with cabin and underbody,
## see-through glass, one wheel and one brake drawn four times) is what the
## driven car and the parked cars nearest the camera draw
## (game/scripts/vehicles/car_hero_level.gd). hero_level_enabled() is the one
## switch: off in the web build, whose pack leaves that file out
## (export_presets.cfg), so there every car draws the near and far levels with
## their opaque glass.
##
## Prop frame: origin on the visible ground under the middle of the item, +Y up,
## front -Z (a car's nose), +X its right side.

const KIT_SCENE := preload("res://game/resources/models/street/street_clutter_kit.glb")
const SHADER := preload("res://game/resources/materials/world/street/street_clutter.gdshader")
const GLASS_SHADER := preload("res://game/resources/materials/world/street/street_car_glass.gdshader")
const CAR_DRIVER := preload("res://game/scripts/vehicles/car_driver.gd")
## Loaded only where the hero level draws (never preloaded: the web pack has no such file).
const HERO_KIT_PATH := "res://game/resources/models/street/street_car_hero_kit.glb"

## Part colours (sRGB), in the order of the car kit's parts
## (tools/lib/street-car-parts.mjs CAR_PARTS, whose first sixteen every kit
## shares): paint and roof are placeholders (the instance paint replaces them;
## a black roof takes gloss black, dark rims the hub's colour).
const PART_COLORS := [
	Color(0.5, 0.5, 0.5), # paint
	Color(0.5, 0.5, 0.5), # roof
	Color(0.055, 0.065, 0.07), # glass, opaque (the near and far levels): the dark cabin behind it; the sky shows in its reflection
	Color(0.1, 0.1, 0.105), # tire
	Color(0.74, 0.75, 0.77), # rim (alloy)
	Color(0.1, 0.1, 0.11), # hub, the wheel's barrel, dark rims
	Color(0.085, 0.09, 0.095), # trim: black plastic, cladding, mirrors' feet
	Color(0.86, 0.87, 0.88), # chrome
	Color(0.58, 0.6, 0.62), # head lamp lens over its reflector (near and far)
	Color(0.5, 0.035, 0.035), # tail lamp
	Color(0.88, 0.88, 0.85), # plate
	Color(0.05, 0.05, 0.05), # under: wheel wells, underbody
	Color(0.055, 0.055, 0.06), # grille
	Color(0.95, 0.42, 0.08), # orange: cones, barricade boards
	Color(0.92, 0.92, 0.9), # white: reflective collars, stripes, sign panels
	Color(0.66, 0.67, 0.68), # metal: galvanised frames
	Color(0.02, 0.02, 0.022), # gap: panel gaps and shut lines
	Color(0.11, 0.11, 0.115), # cabin: dashboard, door cards, carpet
	Color(0.16, 0.16, 0.165), # seat upholstery
	Color(0.5, 0.5, 0.49), # headliner
	Color(0.02, 0.02, 0.023), # gloss black: pillar covers, grille surrounds, a black roof
	Color(0.3, 0.31, 0.33), # lamp housing: the smoked reflector bowl
	Color(0.95, 0.95, 0.92), # daytime running light
	Color(0.75, 0.03, 0.02), # tail light bar
	Color(0.7, 0.36, 0.06), # amber reflector
	Color(0.52, 0.52, 0.54), # brake disc
	Color(0.2, 0.2, 0.21), # caliper
	Color(0.24, 0.23, 0.22), # exhaust, subframes and suspension steel
	Color(0.02, 0.025, 0.035), # screen
	Color(0.045, 0.045, 0.045), # rubber: wiper blades
	Color(0.8, 0.82, 0.84), # mirror glass
	Color(0.82, 0.82, 0.8), # reversing lamp
]
## Car paints by name (sRGB), sampled from the dated pilot photos (Sep and Nov
## 2025): mostly white, silver and grey, some black and dark, the odd blue or red.
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
## The finish index the shader reads as matte (weathered painted steel): a
## dumpster's body and lids, which take the instance paint like a car's.
const MATTE_FINISH := 3
## Car bodies of the kit (tools/lib/street-clutter-kit.mjs CAR_BODIES); a
## prop's collision box is its near mesh's bounds.
const CAR_BODIES := ["crossover", "suv", "sedan", "fastback", "hatchback", "wagon", "pickup", "utility", "van"]
## Detail levels: the near mesh within LOD_NEAR_M of its cell's centre, the
## far mesh beyond, to the prop's range.
const LOD_NEAR_M := 60.0
## The largest suspension twist a parked car's row may carry (metres; the
## generator keeps it within MAX_TWIST_M of tools/lib/street-clutter-generation.mjs).
const MAX_TWIST_M := 0.05
## A parked car draws its hero level while the camera is nearer than
## HERO_NEAR_M and until it is HERO_FAR_M away (the gap keeps a car at the edge
## from flickering between levels); at most HERO_MAX_CARS at once, the nearest.
const HERO_NEAR_M := 13.0
const HERO_FAR_M := 15.0
const HERO_MAX_CARS := 6
## The caliper's place on a brake, from the car's rear toward up
## (tools/lib/street-car-parts.mjs CALIPER_ANGLE): a left-hand brake is the
## right-hand one turned half round and then this far round its axle.
const CALIPER_ANGLE := deg_to_rad(32.0)
const PROPS := {
	"parked_car": {"range_m": 260.0, "shadow": true},
	"traffic_cone": {"range_m": 90.0, "shadow": true},
	"barricade": {"range_m": 110.0, "shadow": true},
	"dumpster": {"range_m": 120.0, "shadow": true},
	"stock_tank_planter": {"range_m": 110.0, "shadow": true},
}

var _material: ShaderMaterial
## The hero level's own materials: a wheel's (its tyre's tread) and the glass.
var _wheel_material: ShaderMaterial
var _glass_material: ShaderMaterial
var _meshes: Dictionary = {}
var _shapes: Dictionary = {}
## A car body's collision pieces (car_hulls): body -> Array of ConvexPolygonShape3D.
var _hulls: Dictionary = {}
## The kit's empty nodes by name: the drivable car's wheel centres.
var _markers: Dictionary = {}
var _hero_loaded := false


func _init() -> void:
	var image := Image.create_empty(32, 2, false, Image.FORMAT_RGBA8)
	for index in PART_COLORS.size():
		image.set_pixel(index, 0, PART_COLORS[index])
	var names := paint_names()
	for index in names.size():
		image.set_pixel(index, 1, PAINTS[names[index]])
	var palette := ImageTexture.create_from_image(image)
	_material = ShaderMaterial.new()
	_material.resource_name = "street_clutter"
	_material.shader = SHADER
	_material.set_shader_parameter("palette", palette)
	_wheel_material = ShaderMaterial.new()
	_wheel_material.resource_name = "street_car_wheel"
	_wheel_material.shader = SHADER
	_wheel_material.set_shader_parameter("palette", palette)
	_wheel_material.set_shader_parameter("wheel_local", true)
	_glass_material = ShaderMaterial.new()
	_glass_material.resource_name = "street_car_glass"
	_glass_material.shader = GLASS_SHADER
	_read_scene(KIT_SCENE)


func _read_scene(packed: PackedScene) -> void:
	var scene := packed.instantiate()
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		_meshes[str(node.name)] = (node as MeshInstance3D).mesh
	for pattern: String in ["car_*_axle_*", "car_*_driver_*"]:
		for node: Node in scene.find_children(pattern, "Node3D", true, false):
			if not node is MeshInstance3D:
				_markers[str(node.name)] = (node as Node3D).position
	scene.free()


## The one switch for the cars' hero level: the desktop builds draw it, the web
## build (whose pack has no hero kit) draws the near level with its opaque glass.
static func hero_level_enabled() -> bool:
	return not OS.has_feature("web") and ResourceLoader.exists(HERO_KIT_PATH)


## How dirty a car is, 0 (just washed) to 1 (filthy), from its row's id: so a
## car looks the same wherever it is drawn, at every level and when it is
## driven. The id's hash is mixed first (ids next to each other in a row differ
## only in its low bits, which left whole rows equally dirty), and the sixth
## power of that even spread keeps most cars nearly clean and a few dirty
## (owner, 2026-11-13: fewer dirty cars): about three in four below 0.2, one in
## eleven over 0.5.
static func car_dirt(row_id: String) -> float:
	if row_id == "":
		return 0.0
	var h := row_id.hash() & 0xFFFFFFFF
	h = (((h >> 16) ^ h) * 0x45D9F3B) & 0xFFFFFFFF
	h = (((h >> 16) ^ h) * 0x45D9F3B) & 0xFFFFFFFF
	h = (h >> 16) ^ h
	return pow(float(h & 0xFFFF) / 65535.0, 6.0)


## A parked car's instance custom data (paint, style, suspension twist, dirt)
## from its row params and id: {ok, custom} or {ok: false, message}. A drivable
## car takes the same with no twist (its suspension takes up the ground). An
## optional params.dirt (0 to 1) stands in for the id's (a gallery's own levels).
static func car_custom(params: Dictionary, twist_override: Variant = null, row_id := "") -> Dictionary:
	var body := str(params.get("body", ""))
	var paint := str(params.get("paint", ""))
	var finish := FINISHES.find(str(params.get("finish", "")))
	if not body in CAR_BODIES or not PAINTS.has(paint) or finish < 0:
		return {"ok": false, "message": "parked_car needs a known body, paint and finish: %s" % [params]}
	var style := finish
	if str(params.get("roof", "body")) == "black":
		style |= 4
	if str(params.get("rims", "alloy")) == "dark":
		style |= 8
	var twist: Variant = params.get("twist", 0.0) if twist_override == null else twist_override
	if not (twist is float or twist is int) or absf(float(twist)) > MAX_TWIST_M:
		return {"ok": false, "message": "parked_car twist must be a number within %.2f m: %s" % [MAX_TWIST_M, params]}
	var dirt: Variant = params.get("dirt", car_dirt(row_id))
	if not (dirt is float or dirt is int) or float(dirt) < 0.0 or float(dirt) > 1.0:
		return {"ok": false, "message": "parked_car dirt must be a number from 0 to 1: %s" % [params]}
	var paint_index := paint_names().find(paint)
	return {"ok": true, "custom": Color((float(paint_index) + 0.5) / 32.0, (float(style) + 0.5) / 16.0, float(twist), float(dirt))}


## The parts of a body that a drivable car draws (tools/lib/street-car-kit.mjs
## carKitExtras): {ok, chassis (the near mesh without wheels), tyre (one
## right-hand wheel round its own centre, face toward +X), far (the parked far
## mesh, wheels and all), shadow (the shadow caster), front, rear (the
## right-hand front and rear wheel centres in the car frame; the left ones
## mirror them in x), radius, tyre_width, hulls (car_hull_points: what it
## collides as)} or {ok: false, message}. The car's size comes from the chassis
## and tyre boxes, the same at every level.
func drivable(body: String) -> Dictionary:
	var chassis: Variant = _meshes.get("car_%s_chassis_lod0" % body, null)
	var tyre: Variant = _meshes.get("car_%s_tyre_lod0" % body, null)
	var far: Variant = _meshes.get("car_%s_lod1" % body, null)
	var shadow: Variant = _meshes.get("car_%s_shadow" % body, null)
	if not chassis is Mesh or not tyre is Mesh or not far is Mesh or not shadow is Mesh or not _markers.has("car_%s_axle_front" % body) or not _markers.has("car_%s_axle_rear" % body):
		return {"ok": false, "message": "the street-clutter kit has no drivable parts for %s" % body}
	var tyre_box: AABB = (tyre as Mesh).get_aabb()
	return {
		"ok": true, "chassis": chassis, "tyre": tyre, "far": far, "shadow": shadow,
		"front": _markers["car_%s_axle_front" % body], "rear": _markers["car_%s_axle_rear" % body],
		"radius": tyre_box.size.y * 0.5, "tyre_width": tyre_box.size.x,
		"hulls": car_hull_points(body),
	}


## A car body's collision pieces in the car frame (tools/lib/street-car-kit.mjs
## carHullMeshes): the nose to the cowl, the cabin, the deck or bed, each the
## hull of the drawn body over its stretch above the driven car's lower hull's
## bottom, so the player stands on what is drawn. One point list per piece.
func car_hull_points(body: String) -> Array[PackedVector3Array]:
	var pieces: Array[PackedVector3Array] = []
	var index := 0
	while _meshes.has("car_%s_hull%d" % [body, index]):
		var mesh := _meshes["car_%s_hull%d" % [body, index]] as Mesh
		pieces.append(mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array)
		index += 1
	return pieces


## The same pieces as shapes, made once per body and shared by every car of it.
func car_hulls(body: String) -> Array:
	if not _hulls.has(body):
		var shapes: Array = []
		for points: PackedVector3Array in car_hull_points(body):
			var shape := ConvexPolygonShape3D.new()
			shape.points = points
			shapes.append(shape)
		_hulls[body] = shapes
	return _hulls[body]


static func paint_names() -> Array:
	var names: Array = PAINTS.keys()
	names.sort()
	return names


func material() -> ShaderMaterial:
	return _material


## A body's hero level: {ok, body, glass, tyre, brake (meshes), front, rear
## (the right-hand wheel centres)} or {ok: false} where the hero level is off.
func hero(body: String) -> Dictionary:
	if not hero_level_enabled():
		return {"ok": false}
	if not _hero_loaded:
		_hero_loaded = true
		var packed := load(HERO_KIT_PATH) as PackedScene
		if packed != null:
			_read_scene(packed)
	var found := {"ok": true, "front": _markers.get("car_%s_axle_front" % body), "rear": _markers.get("car_%s_axle_rear" % body)}
	# Where a driver sits and holds the wheel (car_driver.gd), where the kit marks it.
	for marker: String in ["seat", "hand_left", "hand_right"]:
		if _markers.has("car_%s_driver_%s" % [body, marker]):
			found["driver_" + marker] = _markers["car_%s_driver_%s" % [body, marker]]
	for piece: String in ["body", "glass", "tyre", "brake"]:
		var mesh: Variant = _meshes.get("car_%s_hero_%s" % [body, piece], null)
		if not mesh is Mesh:
			return {"ok": false}
		found[piece] = mesh
	return found if found.front is Vector3 and found.rear is Vector3 else {"ok": false}


## The four wheels' transforms in the car frame for wheel centres front and rear
## (right-hand; the left mirror them), in the order front left, front right,
## rear left, rear right: a left-hand wheel is the right-hand one turned half
## round. twist lifts the front-left and rear-right wheels and drops the others
## (a parked car's suspension twist); turn_x turns each about its axle (a
## brake's caliper round to the rear on the left side).
static func wheel_transforms(front: Vector3, rear: Vector3, twist: float = 0.0, left_turn_x: float = 0.0) -> Array[Transform3D]:
	var placed: Array[Transform3D] = []
	for centre: Vector3 in [Vector3(-front.x, front.y, front.z), front, Vector3(-rear.x, rear.y, rear.z), rear]:
		var lift := twist * signf(centre.x) * signf(centre.z)
		var basis := Basis.IDENTITY if centre.x > 0.0 else Basis(Vector3.UP, PI) * Basis(Vector3.RIGHT, left_turn_x)
		placed.append(Transform3D(basis, centre + Vector3.UP * lift))
	return placed


## One MultiMesh instance node drawing mesh at the given transforms with the
## instance custom data, in `material`, casting shadows or not.
static func instance_node(node_name: String, mesh: Mesh, transforms: Array[Transform3D], custom: Color, material: Material, shadows: int) -> MultiMeshInstance3D:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for index in transforms.size():
		multimesh.set_instance_transform(index, transforms[index])
		multimesh.set_instance_custom_data(index, custom)
	var instance := MultiMeshInstance3D.new()
	instance.name = node_name
	instance.multimesh = multimesh
	instance.material_override = material
	instance.layers = 1
	instance.cast_shadow = shadows
	return instance


## A car's hero level as a node in the car frame: Body, Glass, Wheels and Brakes
## (none of them cast a shadow: the shadow caster does), or null where the hero
## level is off. twist is a parked car's; a driven car moves Wheels and Brakes.
func hero_visual(body: String, custom: Color, twist: float = 0.0) -> Node3D:
	var found := hero(body)
	if not found.ok:
		return null
	var plain := Color(custom.r, custom.g, 0.0, custom.a)
	var off := GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var one: Array[Transform3D] = [Transform3D.IDENTITY]
	var root := Node3D.new()
	root.name = "Hero"
	root.add_child(instance_node("Body", found.body, one, plain, _material, off))
	root.add_child(instance_node("Glass", found.glass, one, plain, _glass_material, off))
	root.add_child(instance_node("Wheels", found.tyre, wheel_transforms(found.front, found.rear, twist), plain, _wheel_material, off))
	root.add_child(instance_node("Brakes", found.brake, wheel_transforms(found.front, found.rear, twist, 2.0 * CALIPER_ANGLE - PI), plain, _material, off))
	# Where a driver goes (the driven car seats car_driver.gd's figure there).
	for marker: String in ["driver_seat", "driver_hand_left", "driver_hand_right"]:
		if found.has(marker):
			root.set_meta(marker, found[marker])
	return root


## What the world draws for one item at a detail level ("hero", "lod0", "lod1",
## "shadow" for a car's shadow caster drawn as itself, or "driven": the hero
## level with its driver at the wheel), at any distance, at placement: for the
## kit gallery (game/tests/shared/kit_gallery.gd).
func preview(prop: String, params: Dictionary, level: String, placement: Transform3D) -> Node3D:
	var built := parts(prop, params)
	if not built.ok:
		push_error(str(built.message))
		return null
	var root := Node3D.new()
	root.transform = placement
	var one: Array[Transform3D] = [Transform3D.IDENTITY]
	var custom: Color = built.custom
	var on := GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	var off := GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var caster: Variant = built.get("shadow_mesh", null)
	if level == "shadow" and caster is Mesh:
		root.add_child(instance_node("Shadow", caster, one, custom, _material, on))
		return root
	if level in ["hero", "driven"] and prop == "parked_car":
		var visual := hero_visual(str(params.body), custom, float(params.get("twist", 0.0)))
		if visual != null and level == "driven" and visual.has_meta("driver_seat"):
			# A driven car: its driver at the wheel.
			visual.add_child(CAR_DRIVER.build(visual.get_meta("driver_seat"), visual.get_meta("driver_hand_left"), visual.get_meta("driver_hand_right")))
		if visual != null:
			root.add_child(visual)
			root.add_child(instance_node("Shadow", caster, one, custom, _material, GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY))
			return root
	if level == "lod1":
		root.add_child(instance_node("Far", built.meshes[1], one, custom, _material, on))
	elif caster is Mesh:
		root.add_child(instance_node("Near", built.meshes[0], one, custom, _material, off))
		root.add_child(instance_node("Shadow", caster, one, custom, _material, GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY))
	else:
		root.add_child(instance_node("Near", built.meshes[0], one, custom, _material, on))
	return root


## What to build for one placed row: {ok, meshes: [near, far], custom: Color,
## shape, shape_transform, range_m, shadow, and for a car shadow_mesh: what
## casts its shadow while the near mesh draws, and shapes: [{shape,
## transform}] its collision pieces, which stand in for the box shape} or
## {ok: false, message}. row_id: the placed row's id (a car's dirt).
func parts(prop: String, params: Dictionary, row_id := "") -> Dictionary:
	if not PROPS.has(prop):
		return {"ok": false, "message": "unknown street-clutter prop %s" % prop}
	var result := {"ok": true, "range_m": float(PROPS[prop].range_m), "shadow": bool(PROPS[prop].shadow), "custom": Color(0, 0, 0, 0)}
	var base := ""
	if prop == "parked_car":
		var car := car_custom(params, null, row_id)
		if not car.ok:
			return car
		base = "car_%s" % params.body
		result.custom = car.custom
	elif prop in ["dumpster", "stock_tank_planter"]:
		# A dumpster's body, a planter's pallet: the instance paint, matte. A
		# dumpster's lids (the roof part) take the body's, or params.lid's paint.
		var bin_paint := str(params.get("paint", ""))
		var lid := str(params.get("lid", "body"))
		if not PAINTS.has(bin_paint) or not (lid == "body" or PAINTS.has(lid)):
			return {"ok": false, "message": "%s needs a known paint (and lid): %s" % [prop, params]}
		base = prop
		var lid_u := 0.0 if lid == "body" else (float(paint_names().find(lid)) + 0.5) / 32.0
		result.custom = Color((float(paint_names().find(bin_paint)) + 0.5) / 32.0, (float(MATTE_FINISH) + 0.5) / 16.0, 0.0, lid_u)
	else:
		base = prop
	var near: Variant = _meshes.get("%s_lod0" % base, null)
	var far: Variant = _meshes.get("%s_lod1" % base, null)
	if not near is Mesh or not far is Mesh:
		return {"ok": false, "message": "the street-clutter kit has no meshes for %s" % base}
	result.meshes = [near, far]
	result.mesh_key = base
	var caster: Variant = _meshes.get("%s_shadow" % base, null)
	if caster is Mesh:
		result.shadow_mesh = caster
	if prop == "parked_car" and not car_hulls(str(params.body)).is_empty():
		# A car collides as the drawn body (car_hulls), in its own frame.
		var pieces: Array = []
		for shape: Variant in car_hulls(str(params.body)):
			pieces.append({"shape": shape, "transform": Transform3D.IDENTITY})
		result.shapes = pieces
	if not _shapes.has(base):
		# A box over the near mesh's bounds, its floor on the ground.
		var bounds: AABB = (near as Mesh).get_aabb()
		var shape := BoxShape3D.new()
		shape.size = Vector3(bounds.size.x, bounds.end.y, bounds.size.z)
		_shapes[base] = {"shape": shape, "transform": Transform3D(Basis.IDENTITY, Vector3(bounds.get_center().x, bounds.end.y * 0.5, bounds.get_center().z))}
	result.shape = _shapes[base].shape
	result.shape_transform = _shapes[base].transform
	return result
