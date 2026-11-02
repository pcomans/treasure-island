extends RefCounted
## The street-furniture prop kit: procedural meshes, collision and street-name
## labels for the vertical street objects of PlayableWorld/StreetDetail/Furniture
## (lamps, signal poles, signs, hydrants, cabinets). Every painted or printed
## surface shares one atlas material (vertex colour times the generated atlas)
## and lit lenses share one unshaded material, so a prop variant is one mesh of at
## most two surfaces that the builder instances with a MultiMesh.
##
## Dimensions are production inference from the dated pilot photos named in
## tools/config/street-detail-zones.json, not survey data.
##
## Local frame of every prop: origin at its foot on the visible surface, +Y up,
## front -Z (the lamp arm and signal mast arm reach over the road, a sign faces
## its traffic), +X the direction traffic passes a signal pole (its heads face -X).

const ATLAS := preload("res://game/resources/textures/world/street/street_furniture_atlas.png")

## Atlas cells as UV rectangles (1024 x 512 atlas of 256 px cells; see the
## texture README). WHITE is an inset of the plain white cell for vertex-coloured parts.
const CELL_METAL := Rect2(0.0, 0.0, 0.25, 0.5)
const CELL_CABINET := Rect2(0.25, 0.0, 0.25, 0.5)
const CELL_STOP := Rect2(0.5, 0.0, 0.25, 0.5)
const CELL_PED := Rect2(0.75, 0.0, 0.25, 0.5)
const CELL_NO_STOPPING := Rect2(0.0, 0.5, 0.25, 0.5)
const CELL_BUS_STOP := Rect2(0.25, 0.5, 0.25, 0.5)
const CELL_ALL_WAY := Rect2(0.5, 0.5, 0.25, 0.25)
const CELL_NAME_BLADE := Rect2(0.5, 0.75, 0.25, 0.25)
const CELL_WHITE := Rect2(0.82, 0.62, 0.11, 0.26)

## Vertex colours (sRGB), multiplied with the atlas cell they sample.
const GALVANIZED := Color(1.0, 1.0, 1.0)
const CHARCOAL := Color(0.42, 0.43, 0.45)
const SIGNAL_BLACK := Color(0.07, 0.07, 0.075)
const LUMINAIRE_GREY := Color(0.36, 0.37, 0.39)
const LENS_GREY := Color(0.80, 0.82, 0.84)
const SIGN_BACK := Color(0.78, 0.79, 0.80)
const HYDRANT_YELLOW := Color(0.86, 0.65, 0.19)
const HYDRANT_BONNET := Color(0.90, 0.89, 0.85)
const HYDRANT_RUST := Color(0.40, 0.22, 0.14)
## The controller cabinets photograph as a very dark green-grey (about 30-37 /
## 36-45 / 35-45 of 255 in sunlit Sep and Mar 2025 photos). The door texture
## (the atlas cabinet cell, about 0.17 / 0.29 / 0.20) is tinted down to match.
const CABINET_GREEN := Color(0.12, 0.14, 0.13)
const CABINET_DOOR_TINT := Color(0.70, 0.48, 0.65)
const PAD_CONCRETE := Color(0.70, 0.69, 0.66)
const BLADE_GREEN := Color(0.0, 0.42, 0.21)
const LENS_RED_OFF := Color(0.22, 0.03, 0.03)
const LENS_AMBER_OFF := Color(0.26, 0.16, 0.03)
const LENS_GREEN_LIT := Color(0.40, 1.0, 0.62)

## Per prop: visibility range (m) and whether it casts a sun shadow. Tall poles
## keep their shadows and reach; small items fade out early for the web build.
const PROPS := {
	"bus_stop_sign": {"range_m": 110.0, "shadow": false},
	"hydrant": {"range_m": 70.0, "shadow": false},
	"lamp_cobra": {"range_m": 320.0, "shadow": true},
	"lamp_lot": {"range_m": 220.0, "shadow": true},
	"lamp_plaza": {"range_m": 220.0, "shadow": true},
	"name_sign": {"range_m": 120.0, "shadow": false},
	"signal_cabinet": {"range_m": 120.0, "shadow": false},
	"signal_mast": {"range_m": 320.0, "shadow": true},
	"stop_sign": {"range_m": 120.0, "shadow": false},
}
const LABEL_RANGE_M := 60.0
const LABEL_FONT_SIZE := 64
const LABEL_PIXEL_M := 0.0021
const BLADE_HEIGHT_M := 0.24
const BLADE_MARGIN_M := 0.09

var _opaque: StandardMaterial3D
var _lit: StandardMaterial3D
var _meshes: Dictionary = {}
var _shapes: Dictionary = {}


func _init() -> void:
	_opaque = StandardMaterial3D.new()
	_opaque.resource_name = "street_furniture"
	_opaque.albedo_texture = ATLAS
	_opaque.vertex_color_use_as_albedo = true
	_opaque.vertex_color_is_srgb = true
	_opaque.roughness = 0.62
	_opaque.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_opaque.texture_repeat = false
	_lit = StandardMaterial3D.new()
	_lit.resource_name = "street_furniture_lit"
	_lit.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_lit.albedo_texture = ATLAS
	_lit.vertex_color_use_as_albedo = true
	_lit.vertex_color_is_srgb = true
	_lit.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_lit.texture_repeat = false


## What to build for one placed row: {ok, pieces: [{key, mesh, transform}],
## shapes: [{shape, transform}], labels: [{text, transform}], range_m, shadow},
## transforms in the prop's local frame. Meshes are shared between rows whose
## prop and parameters match.
func parts(prop: String, params: Dictionary) -> Dictionary:
	if not PROPS.has(prop):
		return {"ok": false, "message": "unknown street-furniture prop %s" % prop}
	var result := {"ok": true, "pieces": [], "shapes": [], "labels": [], "range_m": float(PROPS[prop].range_m), "shadow": bool(PROPS[prop].shadow)}
	match prop:
		"lamp_cobra":
			var height := _number(params, "height_m", 9.2)
			var arm := _number(params, "arm_m", 2.6)
			_piece(result, "lamp_cobra_h%.1f_a%.1f" % [height, arm], func(b: Builder) -> void: _lamp_cobra(b, height, arm))
			_capsule(result, 0.13, height - 0.9)
		"lamp_lot":
			var lot_height := _number(params, "height_m", 6.0)
			_piece(result, "lamp_lot_h%.1f" % lot_height, func(b: Builder) -> void: _lamp_lot(b, lot_height))
			_capsule(result, 0.08, lot_height)
		"lamp_plaza":
			var plaza_height := _number(params, "height_m", 8.0)
			var heads := int(_number(params, "heads", 4))
			_piece(result, "lamp_plaza_h%.1f_n%d" % [plaza_height, heads], func(b: Builder) -> void: _lamp_plaza(b, plaza_height, heads))
			_capsule(result, 0.1, plaza_height)
		"signal_mast":
			var mast_arm := _number(params, "arm_m", 4.0)
			var head_at := snappedf(_number(params, "head_m", mast_arm * 0.8), 0.05)
			var lamp := bool(params.get("lamp", true))
			var sign_kind := str(params.get("sign", ""))
			_piece(result, "signal_mast_a%.1f_h%.2f_l%d_%s" % [mast_arm, head_at, int(lamp), sign_kind], func(b: Builder) -> void: _signal_mast(b, mast_arm, head_at, lamp, sign_kind))
			_capsule(result, 0.18, 8.4 if lamp else 6.6)
		"stop_sign":
			var all_way := bool(params.get("all_way", false))
			_piece(result, "stop_sign_w%d" % int(all_way), func(b: Builder) -> void: _stop_sign(b, all_way))
			_capsule(result, 0.06, 3.0)
		"name_sign":
			_name_sign(result, params)
		"hydrant":
			_piece(result, "hydrant", func(b: Builder) -> void: _hydrant(b))
			_capsule(result, 0.17, 0.78)
		"signal_cabinet":
			_piece(result, "signal_cabinet", func(b: Builder) -> void: _signal_cabinet(b))
			if not _shapes.has("cabinet_box"):
				var box := BoxShape3D.new()
				box.size = Vector3(0.8, 1.45, 0.55)
				_shapes["cabinet_box"] = box
			result.shapes.append({"shape": _shapes["cabinet_box"], "transform": Transform3D(Basis.IDENTITY, Vector3(0.0, 0.725, 0.0))})
		"bus_stop_sign":
			_piece(result, "bus_stop_sign", func(b: Builder) -> void: _bus_stop_sign(b))
			_capsule(result, 0.06, 3.0)
	return result


func _number(params: Dictionary, key: String, fallback: float) -> float:
	var value: Variant = params.get(key, fallback)
	return float(value) if (value is float or value is int) and is_finite(float(value)) else fallback


func _piece(result: Dictionary, key: String, draw: Callable, transform := Transform3D.IDENTITY) -> void:
	if not _meshes.has(key):
		var builder := Builder.new(CELL_WHITE)
		draw.call(builder)
		var mesh := builder.commit(_opaque, _lit)
		mesh.resource_name = key
		_meshes[key] = mesh
	result.pieces.append({"key": key, "mesh": _meshes[key], "transform": transform})


## An upright capsule from the foot, shared between rows of the same size.
func _capsule(result: Dictionary, radius: float, height: float) -> void:
	var key := "capsule_r%.3f_h%.3f" % [radius, height]
	if not _shapes.has(key):
		var capsule := CapsuleShape3D.new()
		capsule.radius = radius
		capsule.height = maxf(height, radius * 2.0)
		_shapes[key] = capsule
	var shape: CapsuleShape3D = _shapes[key]
	result.shapes.append({"shape": shape, "transform": Transform3D(Basis.IDENTITY, Vector3(0.0, shape.height * 0.5, 0.0))})


# ---------------------------------------------------------------- props

## Galvanised bent-mast pole: a tapered shaft that bends into an arm over the
## road (-Z), ending in a flat LED cobra head (Treasure Island Road, Ave of the Palms).
func _lamp_cobra(b: Builder, height: float, arm: float) -> void:
	var bend_y := height - 1.3
	var path := PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, 0.0, 0), Vector3(0, bend_y * 0.5, 0), Vector3(0, bend_y, 0)])
	var radii := PackedFloat32Array([0.11, 0.11, 0.09, 0.072])
	_append_bend(path, radii, Vector3(0, bend_y, 0), 1.2, 75.0, arm, 0.066, 0.05)
	b.tube(path, radii, 12, GALVANIZED, CELL_METAL, false, true)
	b.tube(PackedVector3Array([Vector3(0, -0.05, 0), Vector3(0, 0.07, 0)]), PackedFloat32Array([0.19, 0.17]), 12, GALVANIZED, CELL_METAL, false, true)
	_cobra_head(b, path[path.size() - 1])


## Appends a quarter bend from vertical toward -Z (radius r, ending end_deg from
## vertical) and a straight arm reaching `reach` metres from the shaft axis.
func _append_bend(path: PackedVector3Array, radii: PackedFloat32Array, start: Vector3, r: float, end_deg: float, reach: float, r0: float, r1: float) -> void:
	var steps := 6
	for step in range(1, steps + 1):
		var angle := deg_to_rad(end_deg * float(step) / float(steps))
		path.append(start + Vector3(0.0, r * sin(angle), -(r - r * cos(angle))))
		radii.append(lerpf(r0, (r0 + r1) * 0.5, float(step) / float(steps)))
	var end_angle := deg_to_rad(end_deg)
	var direction := Vector3(0.0, cos(end_angle), -sin(end_angle))
	var remaining := maxf(0.2, reach - r * (1.0 - cos(end_angle))) / sin(end_angle)
	path.append(path[path.size() - 1] + direction * remaining)
	radii.append(r1)


## A flat LED cobra head hung level from the arm end, reaching on toward -Z.
func _cobra_head(b: Builder, arm_end: Vector3) -> void:
	var center := arm_end + Vector3(0.0, -0.05, -0.30)
	b.box(center, Basis.IDENTITY, Vector3(0.30, 0.10, 0.74), LUMINAIRE_GREY, CELL_WHITE)
	b.box(center + Vector3(0.0, 0.06, 0.06), Basis.IDENTITY, Vector3(0.24, 0.04, 0.5), LUMINAIRE_GREY, CELL_WHITE)
	b.box(center + Vector3(0.0, -0.056, -0.04), Basis.IDENTITY, Vector3(0.24, 0.014, 0.52), LENS_GREY, CELL_WHITE)


## Slim grey lot-light pole with a small post-top lantern (the Building 1
## forecourt lot, Sep 2025 photos).
func _lamp_lot(b: Builder, height: float) -> void:
	b.tube(PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, height - 0.55, 0)]), PackedFloat32Array([0.07, 0.055]), 8, GALVANIZED, CELL_METAL, false, true)
	b.tube(PackedVector3Array([Vector3(0, -0.05, 0), Vector3(0, 0.45, 0)]), PackedFloat32Array([0.11, 0.09]), 8, GALVANIZED, CELL_METAL, false, true)
	# Lantern: a tapered housing over a lit lens, under a wider cap and finial.
	var top := height - 0.55
	b.tube(PackedVector3Array([Vector3(0, top, 0), Vector3(0, top + 0.06, 0)]), PackedFloat32Array([0.09, 0.09]), 8, LUMINAIRE_GREY, CELL_WHITE, false, false)
	b.tube(PackedVector3Array([Vector3(0, top + 0.06, 0), Vector3(0, top + 0.36, 0)]), PackedFloat32Array([0.12, 0.17]), 4, LENS_GREY, CELL_WHITE, true, false)
	b.tube(PackedVector3Array([Vector3(0, top + 0.36, 0), Vector3(0, top + 0.42, 0), Vector3(0, top + 0.5, 0)]), PackedFloat32Array([0.22, 0.2, 0.05]), 4, LUMINAIRE_GREY, CELL_WHITE, true, true)
	b.tube(PackedVector3Array([Vector3(0, top + 0.5, 0), Vector3(0, top + 0.6, 0)]), PackedFloat32Array([0.02, 0.01]), 4, LUMINAIRE_GREY, CELL_WHITE, false, true)


## Charcoal plaza pole with small spot heads on curved brackets, in pairs on
## either side along the road (Waterfront Plaza).
func _lamp_plaza(b: Builder, height: float, heads: int) -> void:
	b.tube(PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, height, 0)]), PackedFloat32Array([0.08, 0.062]), 8, CHARCOAL, CELL_METAL, false, true)
	b.box(Vector3(0, 0.06, 0), Basis.IDENTITY, Vector3(0.24, 0.12, 0.24), CHARCOAL, CELL_METAL)
	var layout := [[Vector3.RIGHT, height - 1.35, 22.0], [Vector3.RIGHT, height - 2.0, -22.0], [Vector3.LEFT, height - 2.75, 22.0], [Vector3.LEFT, height - 3.35, -22.0]]
	for index in mini(heads, layout.size()):
		var entry: Array = layout[index]
		var outward: Vector3 = (entry[0] as Vector3).rotated(Vector3.UP, deg_to_rad(float(entry[2])))
		var y := float(entry[1])
		var bracket := PackedVector3Array([
			outward * 0.05 + Vector3(0, y, 0),
			outward * 0.2 + Vector3(0, y + 0.08, 0),
			outward * 0.36 + Vector3(0, y + 0.3, 0),
			outward * 0.44 + Vector3(0, y + 0.56, 0),
		])
		b.tube(bracket, PackedFloat32Array([0.024, 0.022, 0.02, 0.02]), 6, CHARCOAL, CELL_METAL, false, false)
		# The bell hangs from the bracket tip, tilted down and out.
		var tip := bracket[bracket.size() - 1]
		var axis := (outward * 0.55 + Vector3.DOWN).normalized()
		var top := tip + Vector3(0, 0.04, 0)
		b.tube(PackedVector3Array([top, top + axis * 0.24]), PackedFloat32Array([0.075, 0.115]), 10, CHARCOAL, CELL_METAL, true, false)
		b.disc(top + axis * 0.24, axis, 0.105, 10, LENS_GREY)


## Galvanised signal pole on the far side of a crosswalk: an arched mast arm
## over the lanes of its own direction with a three-section head facing that
## traffic (-X); on the pole a near-side head for the opposite direction (+X), a
## pedestrian head facing across the crosswalk and a NO STOPPING ANY TIME sign
## facing the road; when `lamp`, a street lamp on top (ferry crossing photos).
func _signal_mast(b: Builder, arm: float, head_at: float, lamp: bool, sign_kind: String) -> void:
	var top := 8.4 if lamp else 6.6
	var path := PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, 0.0, 0), Vector3(0, 5.5, 0)])
	var radii := PackedFloat32Array([0.15, 0.15, 0.115])
	if lamp:
		path.append(Vector3(0, top - 1.2, 0))
		radii.append(0.09)
		_append_bend(path, radii, Vector3(0, top - 1.2, 0), 1.1, 75.0, 2.4, 0.08, 0.05)
	else:
		path.append(Vector3(0, top, 0))
		radii.append(0.1)
	b.tube(path, radii, 12, GALVANIZED, CELL_METAL, false, true)
	b.tube(PackedVector3Array([Vector3(0, -0.05, 0), Vector3(0, 0.1, 0)]), PackedFloat32Array([0.26, 0.22]), 12, GALVANIZED, CELL_METAL, false, true)
	if lamp:
		_cobra_head(b, path[path.size() - 1])
	# Arched mast arm: it leaves the pole level and rises toward its tip.
	var arm_path := PackedVector3Array()
	var arm_radii := PackedFloat32Array()
	for step in 7:
		var t := float(step) / 6.0
		arm_path.append(Vector3(0, _arm_y(t), -0.1 - (arm - 0.1) * t))
		arm_radii.append(lerpf(0.1, 0.055, t))
	b.tube(arm_path, arm_radii, 10, GALVANIZED, CELL_METAL, false, true)
	b.tube(PackedVector3Array([Vector3(0, 4.75, -0.12), Vector3(0, 5.1, -0.5), Vector3(0, 5.38, -1.1), Vector3(0, _arm_y(1.7 / arm), -1.7)]), PackedFloat32Array([0.035, 0.035, 0.035, 0.035]), 6, GALVANIZED, CELL_METAL, false, false)
	var hang_y := _arm_y(clampf(head_at / arm, 0.0, 1.0))
	b.box(Vector3(0, hang_y - 0.12, -head_at), Basis.IDENTITY, Vector3(0.06, 0.24, 0.06), SIGNAL_BLACK, CELL_WHITE)
	_signal_head(b, Vector3(0, hang_y - 0.24 - 0.5, -head_at), Vector3.LEFT)
	# Near-side head for the opposite direction, on the downstream side of the pole.
	b.box(Vector3(0.2, 3.4, 0), Basis.IDENTITY, Vector3(0.18, 0.08, 0.08), SIGNAL_BLACK, CELL_WHITE)
	_signal_head(b, Vector3(0.42, 3.4, 0), Vector3.RIGHT)
	# Pedestrian head on the crosswalk side, facing across the road.
	b.box(Vector3(-0.17, 2.75, -0.15), Basis.IDENTITY, Vector3(0.08, 0.08, 0.2), SIGNAL_BLACK, CELL_WHITE)
	_ped_head(b, Vector3(-0.17, 2.75, -0.34), Vector3.FORWARD)
	if sign_kind == "no_stopping":
		_pole_sign(b, Vector3(0, 1.95, -0.17), Vector3.FORWARD, Vector2(0.4, 0.6), CELL_NO_STOPPING)


## Height of the arched mast arm at fraction t of its length.
func _arm_y(t: float) -> float:
	return 5.55 + 1.0 * pow(t, 1.6)


## A 12 inch three-section vehicle head with backplate and visors; the green lens lit.
func _signal_head(b: Builder, center: Vector3, facing: Vector3) -> void:
	var basis := Basis.looking_at(facing, Vector3.UP)
	b.box(center + basis * Vector3(0, 0, 0.13), basis, Vector3(0.52, 1.18, 0.02), SIGNAL_BLACK, CELL_WHITE)
	b.box(center, basis, Vector3(0.32, 0.98, 0.24), SIGNAL_BLACK, CELL_WHITE)
	var lenses := [[0.31, LENS_RED_OFF, false], [0.0, LENS_AMBER_OFF, false], [-0.31, LENS_GREEN_LIT, true]]
	for lens: Array in lenses:
		var at := center + basis * Vector3(0, float(lens[0]), -0.125)
		b.disc(at, facing, 0.1, 12, lens[1] as Color, 1 if bool(lens[2]) else 0)
		b.box(at + basis * Vector3(0, 0.115, -0.09), basis, Vector3(0.26, 0.02, 0.18), SIGNAL_BLACK, CELL_WHITE)


## A pedestrian countdown head, its face lit (the orange hand).
func _ped_head(b: Builder, center: Vector3, facing: Vector3) -> void:
	var basis := Basis.looking_at(facing, Vector3.UP)
	b.box(center, basis, Vector3(0.42, 0.42, 0.22), SIGNAL_BLACK, CELL_WHITE)
	b.box(center + basis * Vector3(0, 0.215, -0.12), basis, Vector3(0.44, 0.02, 0.14), SIGNAL_BLACK, CELL_WHITE)
	b.plate(center + basis * Vector3(0, 0, -0.12), basis, _rectangle(0.38, 0.38), 0.004, CELL_PED, Color.WHITE, SIGNAL_BLACK, CELL_WHITE, false, 1)


## A sign plate held off a pole by two small brackets, its face toward `facing`.
func _pole_sign(b: Builder, center: Vector3, facing: Vector3, size: Vector2, cell: Rect2) -> void:
	var basis := Basis.looking_at(facing, Vector3.UP)
	for dy: float in [-size.y * 0.3, size.y * 0.3]:
		b.box(center + basis * Vector3(0, dy, 0.07), basis, Vector3(0.05, 0.04, 0.1), GALVANIZED, CELL_METAL)
	b.plate(center, basis, _rectangle(size.x, size.y), 0.012, cell, Color.WHITE, SIGN_BACK, CELL_METAL)


## An R1-1 stop sign (30 inch octagon) on a square galvanised post, with an ALL
## WAY plaque under it at an all-way stop.
func _stop_sign(b: Builder, all_way: bool) -> void:
	b.box(Vector3(0, 1.32, 0), Basis.IDENTITY, Vector3(0.05, 3.24, 0.05), GALVANIZED, CELL_METAL)
	var octagon := PackedVector2Array()
	var circumradius := 0.375 / cos(PI / 8.0)
	for corner in 8:
		var angle := PI / 8.0 + TAU * float(corner) / 8.0
		octagon.append(Vector2(cos(angle), sin(angle)) * circumradius)
	b.plate(Vector3(0, 2.55, -0.04), Basis.IDENTITY, octagon, 0.012, CELL_STOP, Color.WHITE, SIGN_BACK, CELL_METAL)
	if all_way:
		b.plate(Vector3(0, 2.05, -0.04), Basis.IDENTITY, _rectangle(0.46, 0.19), 0.012, CELL_ALL_WAY, Color.WHITE, SIGN_BACK, CELL_METAL)


## A corner post with green name blades (one per street), names as Label3D.
func _name_sign(result: Dictionary, params: Dictionary) -> void:
	_piece(result, "name_sign_post", _name_post)
	_capsule(result, 0.06, 3.0)
	var blades: Variant = params.get("blades", [])
	if not blades is Array:
		return
	var font := ThemeDB.fallback_font
	for index in mini((blades as Array).size(), 2):
		var blade: Variant = (blades as Array)[index]
		if not blade is Dictionary or str((blade as Dictionary).get("text", "")).is_empty():
			continue
		var text := str(blade.text)
		var text_m := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE).x * LABEL_PIXEL_M
		var length := snappedf(maxf(0.6, text_m + BLADE_MARGIN_M * 2.0), 0.05)
		var y := 3.18 + 0.27 * float(index)
		var placement := Transform3D(Basis(Vector3.UP, _number(blade, "yaw", 0.0)), Vector3(0, y, 0))
		_piece(result, "name_blade_l%.2f" % length, func(b: Builder) -> void: _blade(b, length), placement)
		# Text on both faces: Label3D faces +Z, so the front copy turns half round.
		result.labels.append({"text": text, "transform": placement * Transform3D(Basis(Vector3.UP, PI), Vector3(0, 0, -0.016))})
		result.labels.append({"text": text, "transform": placement * Transform3D(Basis.IDENTITY, Vector3(0, 0, 0.016))})


func _name_post(b: Builder) -> void:
	b.tube(PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, 3.62, 0)]), PackedFloat32Array([0.04, 0.036]), 8, GALVANIZED, CELL_METAL, false, true)
	b.box(Vector3(0, 3.5, 0), Basis.IDENTITY, Vector3(0.1, 0.06, 0.1), GALVANIZED, CELL_METAL)


## A blank green blade along X, printed on both faces; its white border keeps
## its width at the ends while the middle stretches with the name.
func _blade(b: Builder, length: float) -> void:
	b.blade(length, BLADE_HEIGHT_M, 0.02, minf(0.06, length * 0.2), 0.05, CELL_NAME_BLADE, BLADE_GREEN)


## A pillar hydrant: yellow barrel, white bonnet, a pumper nozzle toward the
## road (-Z) and two hose nozzles, rust-brown caps (Trade Winds Avenue photo).
func _hydrant(b: Builder) -> void:
	b.tube(PackedVector3Array([Vector3(0, -0.1, 0), Vector3(0, 0.06, 0)]), PackedFloat32Array([0.16, 0.16]), 12, HYDRANT_RUST, CELL_WHITE, false, true)
	b.tube(PackedVector3Array([Vector3(0, 0.06, 0), Vector3(0, 0.56, 0)]), PackedFloat32Array([0.125, 0.12]), 12, HYDRANT_YELLOW, CELL_WHITE, false, false)
	b.tube(PackedVector3Array([Vector3(0, 0.56, 0), Vector3(0, 0.6, 0)]), PackedFloat32Array([0.145, 0.145]), 12, HYDRANT_YELLOW, CELL_WHITE, false, true)
	b.tube(PackedVector3Array([Vector3(0, 0.6, 0), Vector3(0, 0.66, 0), Vector3(0, 0.71, 0)]), PackedFloat32Array([0.13, 0.11, 0.06]), 12, HYDRANT_BONNET, CELL_WHITE, false, true)
	b.tube(PackedVector3Array([Vector3(0, 0.71, 0), Vector3(0, 0.76, 0)]), PackedFloat32Array([0.028, 0.028]), 5, HYDRANT_BONNET, CELL_WHITE, false, true)
	for nozzle: Array in [[Vector3.FORWARD, 0.38, 0.07, 0.078], [Vector3.LEFT, 0.46, 0.045, 0.05], [Vector3.RIGHT, 0.46, 0.045, 0.05]]:
		var direction: Vector3 = nozzle[0]
		var y := float(nozzle[1])
		b.tube(PackedVector3Array([direction * 0.1 + Vector3(0, y, 0), direction * 0.19 + Vector3(0, y, 0)]), PackedFloat32Array([float(nozzle[2]), float(nozzle[2])]), 10, HYDRANT_YELLOW, CELL_WHITE, false, false)
		b.tube(PackedVector3Array([direction * 0.19 + Vector3(0, y, 0), direction * 0.235 + Vector3(0, y, 0)]), PackedFloat32Array([float(nozzle[3]), float(nozzle[3])]), 10, HYDRANT_RUST, CELL_WHITE, false, true)


## A dark green signal controller cabinet on a concrete pad, its door toward -Z.
func _signal_cabinet(b: Builder) -> void:
	b.box(Vector3(0, 0.05, 0), Basis.IDENTITY, Vector3(1.0, 0.16, 0.7), PAD_CONCRETE, CELL_WHITE)
	b.box(Vector3(0, 0.13 + 0.62, 0), Basis.IDENTITY, Vector3(0.76, 1.24, 0.48), CABINET_GREEN, CELL_WHITE, CELL_CABINET, CABINET_DOOR_TINT)
	b.box(Vector3(0, 0.13 + 1.24 + 0.025, 0), Basis.IDENTITY, Vector3(0.82, 0.05, 0.54), CABINET_GREEN, CELL_WHITE)


## A bus stop flag on a galvanised post, printed on both faces and set across
## the curb (its faces along the road) so approaching buses see it.
func _bus_stop_sign(b: Builder) -> void:
	# A small concrete pad under the post where it stands in a verge.
	b.box(Vector3(0, 0.0, 0), Basis.IDENTITY, Vector3(0.9, 0.08, 0.9), PAD_CONCRETE, CELL_WHITE)
	b.tube(PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, 3.0, 0)]), PackedFloat32Array([0.035, 0.032]), 8, GALVANIZED, CELL_METAL, false, true)
	# Faces along X; the flag stands out from the post toward the road (-Z).
	var basis := Basis.looking_at(Vector3.LEFT, Vector3.UP)
	for dy: float in [-0.22, 0.22]:
		b.box(Vector3(0, 2.55 + dy, -0.05), Basis.IDENTITY, Vector3(0.04, 0.04, 0.1), GALVANIZED, CELL_METAL)
	b.plate(Vector3(0, 2.55, -0.32), basis, _rectangle(0.44, 0.66), 0.012, CELL_BUS_STOP, Color.WHITE, Color.WHITE, CELL_BUS_STOP, true)


func _rectangle(width: float, height: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(-width * 0.5, -height * 0.5), Vector2(width * 0.5, -height * 0.5), Vector2(width * 0.5, height * 0.5), Vector2(-width * 0.5, height * 0.5)])


# ---------------------------------------------------------------- builder

## Two-surface mesh builder: surface 0 is the shaded atlas material, surface 1
## the unshaded lit lenses. Triangles are wound for Godot's clockwise front faces
## from the outward normal each primitive supplies.
class Builder:
	extends RefCounted
	var _surfaces: Array[Dictionary] = []
	var _white: Rect2

	func _init(white_cell: Rect2) -> void:
		_white = white_cell
		for _surface in 2:
			_surfaces.append({"vertices": PackedVector3Array(), "normals": PackedVector3Array(), "uvs": PackedVector2Array(), "colors": PackedColorArray(), "indices": PackedInt32Array()})

	func vertex(surface: int, position: Vector3, normal: Vector3, uv: Vector2, color: Color) -> int:
		var arrays: Dictionary = _surfaces[surface]
		arrays.vertices.append(position)
		arrays.normals.append(normal)
		arrays.uvs.append(uv)
		arrays.colors.append(color)
		return arrays.vertices.size() - 1

	## One triangle facing `outward`.
	func triangle(surface: int, a: int, b: int, c: int, outward: Vector3) -> void:
		var arrays: Dictionary = _surfaces[surface]
		var pa: Vector3 = arrays.vertices[a]
		var normal: Vector3 = (arrays.vertices[b] - pa).cross(arrays.vertices[c] - pa)
		if normal.dot(outward) > 0.0:
			arrays.indices.append_array(PackedInt32Array([a, c, b]))
		else:
			arrays.indices.append_array(PackedInt32Array([a, b, c]))

	## A tube swept along `path` (radius per point) with parallel-transported rings.
	func tube(path: PackedVector3Array, radii: PackedFloat32Array, sides: int, color: Color, cell: Rect2, cap_start: bool, cap_end: bool, surface := 0) -> void:
		var count := path.size()
		var lengths := PackedFloat32Array([0.0])
		for index in range(1, count):
			lengths.append(lengths[index - 1] + path[index].distance_to(path[index - 1]))
		var total := maxf(lengths[count - 1], 0.001)
		var tangent := (path[1] - path[0]).normalized()
		var side := Vector3.UP.cross(tangent) if absf(tangent.dot(Vector3.UP)) < 0.9 else Vector3.RIGHT.cross(tangent)
		side = side.normalized()
		var rings: Array[PackedInt32Array] = []
		var frames: Array[Vector3] = []
		for index in count:
			var forward := (path[mini(index + 1, count - 1)] - path[maxi(index - 1, 0)]).normalized()
			side = (side - forward * side.dot(forward)).normalized()
			var up := forward.cross(side)
			frames.append(forward)
			var ring := PackedInt32Array()
			for step in sides + 1:
				var angle := TAU * float(step) / float(sides)
				var direction := side * cos(angle) + up * sin(angle)
				var uv := Vector2(cell.position.x + cell.size.x * float(step) / float(sides), cell.position.y + cell.size.y * (1.0 - lengths[index] / total))
				ring.append(vertex(surface, path[index] + direction * radii[index], direction, uv, color))
			rings.append(ring)
		var arrays: Dictionary = _surfaces[surface]
		for index in range(1, count):
			for step in sides:
				var a := rings[index - 1][step]
				var b := rings[index - 1][step + 1]
				var c := rings[index][step + 1]
				var d := rings[index][step]
				var corners: Vector3 = arrays.vertices[a] + arrays.vertices[b] + arrays.vertices[c] + arrays.vertices[d]
				var outward := corners * 0.25 - (path[index - 1] + path[index]) * 0.5
				triangle(surface, a, b, c, outward)
				triangle(surface, a, c, d, outward)
		if cap_start:
			_cap(surface, path[0], -frames[0], radii[0], sides, color, cell)
		if cap_end:
			_cap(surface, path[count - 1], frames[count - 1], radii[count - 1], sides, color, cell)

	func _cap(surface: int, center: Vector3, normal: Vector3, radius: float, sides: int, color: Color, cell: Rect2) -> void:
		var side := Vector3.UP.cross(normal) if absf(normal.dot(Vector3.UP)) < 0.9 else Vector3.RIGHT.cross(normal)
		side = side.normalized()
		var up := normal.cross(side)
		var middle := cell.get_center()
		var hub := vertex(surface, center, normal, middle, color)
		var rim := PackedInt32Array()
		for step in sides:
			var angle := TAU * float(step) / float(sides)
			rim.append(vertex(surface, center + (side * cos(angle) + up * sin(angle)) * radius, normal, middle, color))
		for step in sides:
			triangle(surface, hub, rim[step], rim[(step + 1) % sides], normal)

	## A flat disc facing `normal`.
	func disc(center: Vector3, normal: Vector3, radius: float, sides: int, color: Color, surface := 0) -> void:
		_cap(surface, center, normal.normalized(), radius, sides, color, _white)

	## A box of `size` centred at `center` with axes `basis`; the -Z face may use
	## its own atlas cell and colour.
	func box(center: Vector3, basis: Basis, size: Vector3, color: Color, cell: Rect2, front_cell := Rect2(), front_color := Color.WHITE, surface := 0) -> void:
		var half := size * 0.5
		var faces := [
			[Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(0, 1, 0)],
			[Vector3(0, 0, 1), Vector3(-1, 0, 0), Vector3(0, 1, 0)],
			[Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 0)],
			[Vector3(-1, 0, 0), Vector3(0, 0, -1), Vector3(0, 1, 0)],
			[Vector3(0, 1, 0), Vector3(1, 0, 0), Vector3(0, 0, 1)],
			[Vector3(0, -1, 0), Vector3(1, 0, 0), Vector3(0, 0, -1)],
		]
		for face: Array in faces:
			var n: Vector3 = face[0]
			var u: Vector3 = face[1]
			var v: Vector3 = face[2]
			var front: bool = n.z < -0.5 and front_cell.has_area()
			var face_cell := front_cell if front else cell
			var face_color := front_color if front else color
			var normal := (basis * n).normalized()
			var corners := PackedInt32Array()
			for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
				# Seen from outside the -Z face, local +X runs to the viewer's left.
				var u_sign := -corner.x if front else corner.x
				var local := n * (half * n.abs()).length() + u * corner.x * (half * u.abs()).length() + v * corner.y * (half * v.abs()).length()
				var uv := Vector2(face_cell.position.x + face_cell.size.x * (u_sign * 0.5 + 0.5), face_cell.position.y + face_cell.size.y * (0.5 - corner.y * 0.5))
				corners.append(vertex(surface, center + basis * local, normal, uv, face_color))
			triangle(surface, corners[0], corners[1], corners[2], normal)
			triangle(surface, corners[0], corners[2], corners[3], normal)

	## A flat plate: `outline` (convex, local XY around the centre) extruded by
	## `thickness` along Z. The -Z face shows `front_cell`; the +Z face shows
	## `back_cell` in `back_color`, or the front art again when `printed_back`.
	func plate(center: Vector3, basis: Basis, outline: PackedVector2Array, thickness: float, front_cell: Rect2, front_color: Color, back_color: Color, back_cell: Rect2, printed_back := false, front_surface := 0) -> void:
		var bounds := Rect2(outline[0], Vector2.ZERO)
		for point in outline:
			bounds = bounds.expand(point)
		var count := outline.size()
		for side: int in [-1, 1]:
			var front := side < 0
			var surface := front_surface if front else 0
			var normal := (basis * Vector3(0, 0, float(side))).normalized()
			var cell := front_cell if front or printed_back else back_cell
			var color := front_color if front or printed_back else back_color
			var ring := PackedInt32Array()
			for point in outline:
				var fx := (point.x - bounds.position.x) / maxf(bounds.size.x, 0.0001)
				var fy := (point.y - bounds.position.y) / maxf(bounds.size.y, 0.0001)
				# Seen from the -Z side, local +X runs to the viewer's left.
				var u := 1.0 - fx if front else fx
				var uv := Vector2(cell.position.x + cell.size.x * u, cell.position.y + cell.size.y * (1.0 - fy))
				ring.append(vertex(surface, center + basis * Vector3(point.x, point.y, float(side) * thickness * 0.5), normal, uv, color))
			for index in range(1, count - 1):
				triangle(surface, ring[0], ring[index], ring[index + 1], normal)
		for index in count:
			var a := outline[index]
			var c := outline[(index + 1) % count]
			var edge := (c - a).normalized()
			var normal := (basis * Vector3(edge.y, -edge.x, 0.0)).normalized()
			if normal.dot(basis * Vector3(a.x + c.x, a.y + c.y, 0.0)) < 0.0:
				normal = -normal
			var middle := _white.get_center()
			var quad := PackedInt32Array()
			for corner: Array in [[a, -1.0], [c, -1.0], [c, 1.0], [a, 1.0]]:
				var point: Vector2 = corner[0]
				quad.append(vertex(0, center + basis * Vector3(point.x, point.y, float(corner[1]) * thickness * 0.5), normal, middle, back_color))
			triangle(0, quad[0], quad[1], quad[2], normal)
			triangle(0, quad[0], quad[2], quad[3], normal)

	## A double-faced blade along X centred on the origin: each face shows `cell`
	## with its outer `edge_u` of the texture kept on the outer `cap` metres.
	func blade(length: float, height: float, thickness: float, cap: float, edge_u: float, cell: Rect2, edge_color: Color) -> void:
		var xs := [-length * 0.5, -length * 0.5 + cap, length * 0.5 - cap, length * 0.5]
		var us := [0.0, edge_u, 1.0 - edge_u, 1.0]
		for side: int in [-1, 1]:
			var normal := Vector3(0, 0, float(side))
			var z := float(side) * thickness * 0.5
			var columns: Array[PackedInt32Array] = []
			for column in 4:
				# Seen from the -Z face, local +X runs to the viewer's left.
				var u := float(us[column])
				if side < 0:
					u = 1.0 - u
				var pair := PackedInt32Array()
				for row: float in [-0.5, 0.5]:
					var uv := Vector2(cell.position.x + cell.size.x * u, cell.position.y + cell.size.y * (0.5 - row))
					pair.append(vertex(0, Vector3(float(xs[column]), height * row, z), normal, uv, Color.WHITE))
				columns.append(pair)
			for column in 3:
				triangle(0, columns[column][0], columns[column + 1][0], columns[column + 1][1], normal)
				triangle(0, columns[column][0], columns[column + 1][1], columns[column][1], normal)
		var half := Vector3(length * 0.5, height * 0.5, thickness * 0.5)
		var middle := _white.get_center()
		for edge: Array in [[Vector3.UP, Vector3.RIGHT], [Vector3.DOWN, Vector3.RIGHT], [Vector3.RIGHT, Vector3.UP], [Vector3.LEFT, Vector3.UP]]:
			var n: Vector3 = edge[0]
			var t: Vector3 = edge[1]
			var center := n * (half * n.abs()).length()
			var along := (half * t.abs()).length()
			var quad := PackedInt32Array()
			for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
				quad.append(vertex(0, center + t * corner.x * along + Vector3(0, 0, corner.y * half.z), n, middle, edge_color))
			triangle(0, quad[0], quad[1], quad[2], n)
			triangle(0, quad[0], quad[2], quad[3], n)

	func commit(opaque: Material, lit: Material) -> ArrayMesh:
		var mesh := ArrayMesh.new()
		var materials := [opaque, lit]
		for index in _surfaces.size():
			var data: Dictionary = _surfaces[index]
			if data.indices.is_empty():
				continue
			var arrays := []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = data.vertices
			arrays[Mesh.ARRAY_NORMAL] = data.normals
			arrays[Mesh.ARRAY_TEX_UV] = data.uvs
			arrays[Mesh.ARRAY_COLOR] = data.colors
			arrays[Mesh.ARRAY_INDEX] = data.indices
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			mesh.surface_set_material(mesh.get_surface_count() - 1, materials[index])
		return mesh
