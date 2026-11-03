extends RefCounted
## The street-vegetation kit: generated trees and grass clumps for
## PlayableWorld/StreetDetail/Vegetation. street_vegetation_builder.gd places
## them from the vegetation rows tools/lib/street-vegetation-generation.mjs
## writes; this kit draws them. It grew out of the 2026-11-02 tree shootout's
## code-generated variant A, which the owner chose.
##
## Only species photographed on Treasure Island (dated evidence in
## tools/config/street-detail-zones.json and data/street_detail/set_pieces.json):
##   mexican_fan_palm  Washingtonia robusta: a slim grey ringed trunk, slightly
##                     curved, swelling to a rooted foot; a small tight grey-green
##                     crown over a short brown skirt of dead fronds.
##   canary_date_palm  Phoenix canariensis: a thick trunk of diamond leaf scars,
##                     the trimmed "pineapple" knob and a full arching crown.
##   monterey_cypress  Hesperocyparis macrocarpa: the wind-shaped, flat-topped
##                     old tree, and a dense young conical one.
##   clump_grass       the clumping ornamental grasses of the mulch beds.
## Each prop has a few fixed variants whose meshes every instance shares; an
## instance only turns about +Y and scales uniformly. Shapes and sizes are
## production inference from the photos, not survey data.
##
## Trees have LOD0, LOD1 and a far level: a palm keeps a low trunk under a
## camera-facing crown impostor, a cypress becomes one impostor; the images are
## baked from LOD0 by tools/vegetation/bake_impostors.gd. Grass has one level.
## Collision is the trunk only (capsules), so crowns never stop a jetpack flight.
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
const SCALE_RANGE := Vector2(0.8, 1.25)
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

## Side of one repeat of each square bark texture.
const FAN_BARK_M := 0.6
const CANARY_BARK_M := 0.8
const CANARY_KNOB_M := 0.55
const CYPRESS_BARK_M := 1.0

## How far a trunk top sways downwind per metre of height (the wind shader's
## UV2.x): palms rock, the cypress barely moves.
const PALM_SWAY := 0.011
const CYPRESS_SWAY := 0.0025

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
]
## Two old wind-shaped cypresses (Building 1 grounds, Sep 2025 and Jul 2023)
## and a young conical one (the Waterfront Plaza, Sep 2025).
const CYPRESSES := [
	{"form": "old", "seed": 1, "height": 13.0, "spread": 17.0, "trunk_radius": 0.5, "fork": 2.4, "leaders": 4, "shear": 0.3},
	{"form": "old", "seed": 7, "height": 11.0, "spread": 12.5, "trunk_radius": 0.42, "fork": 2.0, "leaders": 3, "shear": 0.4},
	{"form": "young", "seed": 5, "height": 4.6, "spread": 3.0, "trunk_radius": 0.14},
]
## The Treasure Island prevailing wind is westerly, so old crowns reach east (+X).
const CYPRESS_LEE := Vector2(1.0, 0.0)
const GRASSES := [
	{"seed": 31, "cell": "green", "height": 0.72, "width": 0.92, "cards": 4},
	{"seed": 32, "cell": "green", "height": 0.92, "width": 1.15, "cards": 5},
	{"seed": 33, "cell": "straw", "height": 0.62, "width": 1.0, "cards": 4},
	{"seed": 34, "cell": "straw", "height": 0.82, "width": 1.25, "cards": 5},
]

## Per prop: its variants, visibility ranges in metres (LOD0 until the first,
## LOD1 until the second, the far level until the third; grass has only LOD0)
## and the radius of its foot on the ground, which the generator settles on the
## visible surface (tools/lib/street-vegetation-generation.mjs keeps the same
## variant counts and foot radii). The far impostors are baked from these forms:
## re-run tools/vegetation/bake_impostors.gd after any kit geometry change.
const PROPS := {
	"mexican_fan_palm": {"kinds": ["palm_slot", "tree"], "variants": FAN_PALMS, "ranges": [35.0, 95.0, 900.0], "foot_m": 0.45},
	"canary_date_palm": {"kinds": ["palm_slot", "tree"], "variants": CANARY_PALMS, "ranges": [45.0, 110.0, 900.0], "foot_m": 0.7},
	"monterey_cypress": {"kinds": ["tree"], "variants": CYPRESSES, "ranges": [45.0, 110.0, 900.0], "foot_m": 0.8},
	"clump_grass": {"kinds": ["grass_clump"], "variants": GRASSES, "ranges": [70.0], "foot_m": 0.3},
}

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


## What is wrong with a planted row's prop for this kit, or "" (the generated
## world contract and the builder both ask before building it).
static func params_error(prop: String, kind: String, params: Variant) -> String:
	if not PROPS.has(prop):
		return "unknown street-vegetation prop %s" % prop
	if kind not in PROPS[prop].kinds:
		return "%s does not stand in a %s row" % [prop, kind]
	if not params is Dictionary:
		return "%s params must be an object" % prop
	var p: Dictionary = params
	var variant: Variant = p.get("variant", null)
	if not (variant is int or (variant is float and float(variant) == floorf(float(variant)))) or int(variant) < 0 or int(variant) >= variant_count(prop):
		return "%s has no variant %s" % [prop, variant]
	for field: String in ["scale", "lift_m", "foot_spread_m", "well_m"]:
		var value: Variant = p.get(field, null)
		if not (value is float or value is int) or not is_finite(float(value)):
			return "%s params need a finite %s" % [prop, field]
	if float(p.scale) < SCALE_RANGE.x or float(p.scale) > SCALE_RANGE.y:
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


## What the builder needs for one variant of a prop: {ok, levels: [{name, mesh,
## begin_m, end_m, shadow}], capsules: [{radius_m, from, to}] in the prop's
## frame, foot_m}, or {ok: false, message}. Shared by every instance.
func prototype(prop: String, variant: int) -> Dictionary:
	if not PROPS.has(prop):
		return {"ok": false, "message": "unknown street-vegetation prop %s" % prop}
	if variant < 0 or variant >= variant_count(prop):
		return {"ok": false, "message": "%s has no variant %d" % [prop, variant]}
	var key := "%s_%d" % [prop, variant]
	if _prototypes.has(key):
		return _prototypes[key]
	var tree := build(prop, variant)
	var ranges: Array = PROPS[prop].ranges
	var levels: Array[Dictionary] = [{"name": "lod0", "mesh": tree.lod0, "begin_m": 0.0, "end_m": float(ranges[0]), "shadow": prop != "clump_grass"}]
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
	match prop:
		"mexican_fan_palm":
			tree = _build_fan_palm(params)
		"canary_date_palm":
			tree = _build_canary_palm(params)
		"monterey_cypress":
			tree = _build_cypress(params)
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
			"elevation": deg_to_rad(lerpf(60.0, -24.0, pow(age, 0.75)) + rng.randf_range(-7.0, 7.0)),
			"attach": top + axis_top * knob * attach_f + Vector3(cos(azimuth), 0.0, sin(azimuth)) * float(knob_radius_at.call(attach_f)) * 0.8,
			"length": length,
			"droop": lerpf(0.1, 0.4, age) * rng.randf_range(0.85, 1.15),
			"width": length * 0.21 * rng.randf_range(0.9, 1.04),
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
	var cards := _cypress_cards(rng, skeleton.clusters, str(p.form) == "young")
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
## rather than a clipped hedge.
func _cypress_young_skeleton(p: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var height := float(p.height)
	var radius := float(p.spread) * 0.5
	var trunk_radius := float(p.trunk_radius)
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
			clusters.append({"center": tip, "reach": maxf(0.38, reach * rng.randf_range(0.45, 0.62)), "half_height": rng.randf_range(0.3, 0.48)})
	clusters.append({"center": lean + Vector3.UP * (height * 0.93), "reach": 0.32, "half_height": 0.42})
	return {"branches": branches, "clusters": clusters, "crown": _cloud_centroid(clusters), "radius": radius, "height": height, "young": true}


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
## round their rims (a young tree has only the clumps).
func _cypress_cards(rng: RandomNumberGenerator, clusters: Array, young: bool) -> Array:
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
				"size": rng.randf_range(0.9, 1.3) if young else rng.randf_range(1.0, 1.5),
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
## geometry); a cypress's is the whole tree. The bake renders exactly this frame.
func impostor_frame(prop: String, variant: int) -> Dictionary:
	var tree := build(prop, variant)
	var mesh: ArrayMesh = tree.lod0
	var box := _surface_bounds(mesh, int(tree.crown_surface)) if int(tree.crown_surface) >= 0 else mesh.get_aabb()
	return {"center": box.get_center(), "size": Vector2(maxf(box.size.x, box.size.z), box.size.y) * 1.04, "tree": tree}


static func impostor_texture_path(prop: String, variant: int) -> String:
	return TEXTURES + "impostors/%s_%d.png" % [prop, variant]


## The far mesh of a tree: a palm's low trunk (and knob) under its crown
## impostor, or a cypress's impostor alone; null when the image hasn't been baked.
func impostor_mesh(prop: String, variant: int) -> ArrayMesh:
	if prop == "clump_grass" or not ResourceLoader.exists(impostor_texture_path(prop, variant)):
		return null
	var frame := impostor_frame(prop, variant)
	var tree: Dictionary = frame.tree
	var center: Vector3 = frame.center
	var size: Vector2 = frame.size
	var mesh := ArrayMesh.new()
	if prop != "monterey_cypress":
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
