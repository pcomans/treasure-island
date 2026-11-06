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

## Atlas cells as UV rectangles (1024 x 1024 atlas of 256 px cells; see the
## texture README). WHITE is an inset of the plain white lower half of cell
## (3, 1), for vertex-coloured parts; MAP, its upper half, is the ferry plaza
## board's island map. Rows 2 and 3 hold the island-wide props' cells.
const CELL_METAL := Rect2(0.0, 0.0, 0.25, 0.25)
const CELL_CABINET := Rect2(0.25, 0.0, 0.25, 0.25)
const CELL_STOP := Rect2(0.5, 0.0, 0.25, 0.25)
const CELL_PED := Rect2(0.75, 0.0, 0.25, 0.25)
const CELL_NO_STOPPING := Rect2(0.0, 0.25, 0.25, 0.25)
const CELL_BUS_STOP := Rect2(0.25, 0.25, 0.25, 0.25)
const CELL_ALL_WAY := Rect2(0.5, 0.25, 0.25, 0.125)
const CELL_NAME_BLADE := Rect2(0.5, 0.375, 0.25, 0.125)
const CELL_MAP := Rect2(0.75, 0.25, 0.25, 0.125)
const CELL_WHITE := Rect2(0.8, 0.42, 0.15, 0.06)
const CELL_POLE_WOOD := Rect2(0.0, 0.5, 0.25, 0.25)
const CELL_TOW_AWAY := Rect2(0.25, 0.5, 0.25, 0.25)
const CELL_MERSEA := Rect2(0.5, 0.5, 0.25, 0.25)

## Vertex colours (sRGB), multiplied with the atlas cell they sample.
## Galvanised steel: the metal cell darkened to the dated photos' mid grey
## (untinted it read near-white in the sun).
const GALVANIZED := Color(0.7, 0.71, 0.72)
const CHARCOAL := Color(0.42, 0.43, 0.45)
const SIGNAL_BLACK := Color(0.07, 0.07, 0.075)
## The green of the street-name signs on the signal mast arms.
const MAST_SIGN_GREEN := Color(0.02, 0.36, 0.2)
const LUMINAIRE_GREY := Color(0.36, 0.37, 0.39)
const LENS_GREY := Color(0.80, 0.82, 0.84)
const SIGN_BACK := Color(0.78, 0.79, 0.80)
const HYDRANT_YELLOW := Color(0.86, 0.65, 0.19)
const HYDRANT_BONNET := Color(0.90, 0.89, 0.85)
const HYDRANT_RUST := Color(0.40, 0.22, 0.14)
## The controller cabinets photograph as a very dark green-grey (about 30-37 /
## 36-45 / 35-45 of 255 in sunlit Sep and Mar 2025 photos). The door texture
## (the atlas cabinet cell, about 0.17 / 0.29 / 0.20) is tinted down to match.
const CABINET_GREEN := Color(0.12, 0.155, 0.115)
const CABINET_DOOR_TINT := Color(0.70, 0.53, 0.575)
const PAD_CONCRETE := Color(0.70, 0.69, 0.66)
const BLADE_GREEN := Color(0.0, 0.42, 0.21)
## San Francisco street-name blades: white with black lettering and a thin
## black border (Avenue B, Gateview Avenue, Mariner Drive, Cravath Street,
## Mar to Nov 2025 photos).
const BLADE_WHITE := Color(0.93, 0.93, 0.91)
const BLADE_BLACK := Color(0.05, 0.05, 0.055)
const NAME_TEXT := Color(0.04, 0.04, 0.045)
## The island's wooden utility poles (Avenue H, Avenue I, 11th and 13th Streets,
## Gateview Avenue, Mar and Sep 2025 photos): weathered grey-brown wood poles
## with timber crossarms, grey insulators and galvanised hardware.
const POLE_WOOD := Color(1.0, 1.0, 1.0)
const MONUMENT_POST := Color(0.86, 0.86, 0.84)
## The darker creosote shaft of a minority of poles (prop_params.wood "dark").
const POLE_WOOD_DARK := Color(0.52, 0.47, 0.42)
const CROSSARM_WOOD := Color(0.72, 0.68, 0.62)
const INSULATOR_GREY := Color(0.66, 0.68, 0.67)
const CONDUIT_GREY := Color(0.58, 0.59, 0.58)
## The classic cobra-head luminaires on the poles and davits: a pale grey
## housing over a bowl lens.
const COBRA_GREY := Color(0.70, 0.71, 0.70)
## A pad-mounted transformer's mid green (5th Street at Avenue H and 11th
## Street at Avenue D, Sep and Mar 2025 photos: about 60-80 / 110-120 / 70-80).
const TRANSFORMER_GREEN := Color(0.27, 0.43, 0.30)
const WARNING_RED := Color(0.72, 0.1, 0.08)
## White San Francisco hydrants in the new district and the housing (Bruton
## Street, 13th Street photos).
const HYDRANT_WHITE := Color(0.88, 0.88, 0.85)
const HYDRANT_CAP_GREY := Color(0.36, 0.38, 0.40)
## The Muni shelters (Avenue B and Bayside Drive at Gateview Avenue, 9th
## Street at Avenue H, Nov, Mar and Sep 2025 photos): charcoal steel frames,
## clear glass, a curved translucent roof and a dark map panel in one end.
const SHELTER_FRAME := Color(0.17, 0.18, 0.19)
const SHELTER_PANEL := Color(0.11, 0.12, 0.14)
const SHELTER_BENCH := Color(0.32, 0.33, 0.35)
## The lot's ChargePoint bay (Sep 2025 photos): pale grey pedestals with dark
## heads, one under a black hood, inside rust-orange steel bollards.
const CHARGER_GREY := Color(0.80, 0.81, 0.80)
const CHARGER_HEAD := Color(0.16, 0.17, 0.18)
const CHARGER_SCREEN := Color(0.25, 0.55, 0.62)
const BOLLARD_RUST := Color(0.78, 0.40, 0.17)
const BOLLARD_GRIME := Color(0.36, 0.24, 0.16)
## Ferry plaza furniture (Sep and Mar 2025 photos): pale cast concrete, dark
## stained timber, charcoal frames, bright blue plastic chairs, grey steel bins.
const CONCRETE := Color(0.8, 0.79, 0.76)
const TIMBER := Color(0.42, 0.3, 0.2)
const TIMBER_WEATHERED := Color(0.5, 0.41, 0.31)
const FRAME_CHARCOAL := Color(0.16, 0.17, 0.18)
## The Adirondack chairs are moulded plastic in a bright azure blue: about 30 /
## 95 / 160 of 255 on their shaded faces in the overcast Sep 2025 photos 24 and
## 25 (hue about 210 degrees), paler where their tops catch the sky.
const CHAIR_BLUE := Color(0.11, 0.43, 0.72)
## The chair's legs stand at x = +-CHAIR_LEG_X. Each placed chair settles on the
## visible ground under its feet: STREET_FURNITURE_FEET in
## tools/lib/street-furniture-generation.mjs is the one table of them (prop_feet
## in the generated street detail), and game/tests/validate_generated_world.gd
## checks that these legs stand on it (standing_vertices).
const CHAIR_LEG_X := 0.3
const BIN_STEEL := Color(0.42, 0.43, 0.44)
## Black powder-coated steel (the Mersea lot's slatted can).
const BIN_BLACK := Color(0.07, 0.075, 0.08)
## A bike rack's hoops (params.hoops): at most this many, this far apart along Z.
const BIKE_RACK_MAX_HOOPS := 10
const BIKE_RACK_HOOP_SPACING_M := 0.9
## Waste basket styles (prop_params.style).
const WASTE_BASKET_STYLES := ["steel", "timber", "black_slat"]
const RACK_DARK := Color(0.2, 0.17, 0.14)
const LENS_RED_OFF := Color(0.22, 0.03, 0.03)
const LENS_AMBER_OFF := Color(0.26, 0.16, 0.03)
const LENS_GREEN_LIT := Color(0.40, 1.0, 0.62)
## Cityside Park (Phase 1, opened Sep 2025): colours read from the dated photos
## ph02, ph05, ph08, ph09 and ph10 (Google Maps contributors, Sep 2025), CMG's
## photos and the aerial of 2026-05-26.
const ALUMINIUM := Color(0.74, 0.76, 0.78)
const STAINLESS := Color(0.88, 0.89, 0.9)
const PARK_POLE_GREY := Color(0.36, 0.38, 0.4)
const TABLE_TIMBER := Color(0.66, 0.46, 0.29)
const BENCH_TIMBER := Color(0.76, 0.63, 0.47)
const STEEL_BLACK := Color(0.09, 0.09, 0.095)
const DRIFTWOOD := Color(0.7, 0.64, 0.55)
const END_GRAIN := Color(0.79, 0.7, 0.56)
const PUMP_CONCRETE := Color(0.5, 0.5, 0.49)
const PUMP_FLOOR := Color(0.72, 0.72, 0.7)
## Canopy of Sky (Ned Kahn; TIDA art-selection report 2024-09-11, ph05 Sep 2025):
## a 20 ft stainless ring hung on cables from four curved aluminium poles that
## stand outside the walkway, holding a shallow dish of hanging polycarbonate
## discs above 13 ft. Heights and the dish's sag are inference from ph05.
const CANOPY_RING_RADIUS_M := 3.05
const CANOPY_RING_Y := 5.1
const CANOPY_SAG_M := 0.55
const CANOPY_POLE_RADIUS_M := 4.3
const CANOPY_POLE_TOP_M := 7.3
## The pump station's walled compound: outer size along local X and Z, wall
## height, wall thickness, and its inner wall's place along X and height. Sizes
## are inference from the aerial and CMG photo 4.
const PUMP_WALLS_M := Vector3(16.2, 3.6, 11.1)
const PUMP_WALL_THICKNESS_M := 0.3
const PUMP_INNER_WALL_X_M := -1.8
const PUMP_INNER_WALL_HEIGHT_M := 2.4

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
	"bench_wedge": {"range_m": 140.0, "shadow": true},
	"bench_park": {"range_m": 100.0, "shadow": true},
	"waste_basket": {"range_m": 90.0, "shadow": true},
	"map_board": {"range_m": 110.0, "shadow": true},
	"adirondack_chair": {"range_m": 100.0, "shadow": true},
	"bike_rack": {"range_m": 70.0, "shadow": false},
	"canopy_of_sky": {"range_m": 450.0, "shadow": true},
	"lamp_disc": {"range_m": 220.0, "shadow": true},
	"event_pole": {"range_m": 400.0, "shadow": true},
	"bench_long": {"range_m": 130.0, "shadow": true},
	"picnic_table_long": {"range_m": 150.0, "shadow": true},
	"bbq_grill": {"range_m": 100.0, "shadow": true},
	"log_seat": {"range_m": 110.0, "shadow": true},
	"pump_station": {"range_m": 700.0, "shadow": true},
	"utility_pole": {"range_m": 450.0, "shadow": true},
	"transformer_pad": {"range_m": 130.0, "shadow": true},
	"bus_shelter": {"range_m": 220.0, "shadow": true},
	"post_sign": {"range_m": 110.0, "shadow": false},
	"monument_sign": {"range_m": 120.0, "shadow": true},
	"ev_charger_bay": {"range_m": 120.0, "shadow": true},
}
## The power lines' wires: drawn to this range, never casting shadows, each span
## in straight pieces of at most WIRE_SEGMENT_M (at least 4), sagging WIRE_SAG of its
## length at mid span (the lower cable WIRE_LOWER_SAG); radii of the primaries
## and of the lower cable.
const WIRE_RANGE_M := 320.0
const WIRE_SEGMENT_M := 6.0
const WIRE_SAG := 0.012
const WIRE_LOWER_SAG := 0.022
const WIRE_RADIUS_M := 0.011
const WIRE_LOWER_RADIUS_M := 0.018
## Utility pole layout (m above the foot): the top crossarm, the second's drop
## below it, the insulators' pin offsets along each arm and their height, and
## the lower (secondary / communication) cable's bracket.
## How far a level pad's skirt reaches below its foot (PAD_SKIRT_M in
## tools/lib/street-furniture-generation.mjs, which settles the pads).
const PAD_SKIRT_M := 0.32
const POLE_HEIGHT_M := 11.5
const ARM_DROP_M := 0.45
const ARM2_DROP_M := 1.35
const INSULATOR_XS := [-1.02, 0.36, 1.02]
const INSULATOR_TOP_M := 0.2
const LOWER_CABLE_M := 6.6
## The tow-away sign's post, up to just above the sign's top (1.77 m).
const TOW_AWAY_POST_M := 1.8
const WIRE_SHADER := preload("res://game/resources/materials/world/street/street_wire.gdshader")
const LABEL_RANGE_M := 60.0
const LABEL_FONT_SIZE := 64
const LABEL_PIXEL_M := 0.0021
## The mast arm signs' letters, larger than the blades' (scale on LABEL_PIXEL_M).
const MAST_NAME_SCALE := 2.0
## The spacing of a signal mast's heads along its arm, inward from head_m, and
## the closest a head hangs to the pole.
const MAST_HEAD_STEP_M := 2.8
const MAST_HEAD_MIN_M := 1.8
const BLADE_HEIGHT_M := 0.24
## The lower name blade's centre height, the step to the upper blade, and the
## post top just under the lower blade's bracket.
const BLADE_LOWER_Y_M := 3.18
const BLADE_STEP_Y_M := 0.27
const BLADE_POST_TOP_M := 3.03
## How far a blade clamped beside a lamp pole starts from the pole's axis.
const LAMP_BLADE_REACH_M := 0.14
const BLADE_MARGIN_M := 0.09

var _opaque: StandardMaterial3D
var _lit: StandardMaterial3D
var _glass: StandardMaterial3D
var _roof_glass: StandardMaterial3D
var _wire: ShaderMaterial
var _wire_mesh: ArrayMesh
var _plastic: StandardMaterial3D
var _discs: StandardMaterial3D
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
	# Moulded plastic: vertex colour alone, a little glossier than paint.
	_plastic = StandardMaterial3D.new()
	_plastic.resource_name = "street_furniture_plastic"
	_plastic.vertex_color_use_as_albedo = true
	_plastic.vertex_color_is_srgb = true
	_plastic.roughness = 0.45
	# The Canopy of Sky's polycarbonate discs: pale and glossy, both sides drawn,
	# and lit through from behind, so the dish glows against the sky from below.
	_discs = StandardMaterial3D.new()
	_discs.resource_name = "street_furniture_canopy_discs"
	_discs.vertex_color_use_as_albedo = true
	_discs.vertex_color_is_srgb = true
	_discs.metallic = 0.35
	_discs.roughness = 0.22
	_discs.cull_mode = BaseMaterial3D.CULL_DISABLED
	_discs.backlight_enabled = true
	_discs.backlight = Color(0.62, 0.64, 0.66)
	# Shelter glass: clear, a faint grey-green, glossy, not metallic (a metallic
	# pane would tint its reflection by its colour).
	_glass = StandardMaterial3D.new()
	_glass.resource_name = "street_furniture_glass"
	_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_glass.albedo_color = Color(0.78, 0.84, 0.84, 0.2)
	_glass.roughness = 0.06
	_glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	_roof_glass = StandardMaterial3D.new()
	_roof_glass.resource_name = "street_furniture_roof_glass"
	_roof_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_roof_glass.albedo_color = Color(0.74, 0.77, 0.78, 0.55)
	_roof_glass.roughness = 0.2
	_roof_glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	_wire = ShaderMaterial.new()
	_wire.shader = WIRE_SHADER


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
			# head: "led" (the new district's flat LED heads) or "cobra" (the classic
			# cobra heads of the davit poles in the housing).
			var classic := str(params.get("head", "led")) == "cobra"
			# bend_m: the radius of the bend from the shaft into the arm; the
			# davits' smooth crook by default, a tight knee for a near-straight
			# upswept arm (the owner lot's island lamp).
			var bend := snappedf(clampf(_number(params, "bend_m", 1.2), 0.2, 1.2), 0.05)
			_piece(result, "lamp_cobra_h%.1f_a%.1f_c%d_b%.2f" % [height, arm, int(classic), bend], func(b: Builder) -> void: _lamp_cobra(b, height, arm, classic, bend))
			# blades: a junction's name blades clamped beside the pole at mid-height
			# (Avenue B at Gateview Avenue, Nov 2025), each reaching out along its street.
			var lamp_blades: Variant = params.get("blades", null)
			if lamp_blades is Array:
				_blades(result, lamp_blades, LAMP_BLADE_REACH_M)
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
			# heads: three-section heads spread along the arm from the outermost
			# (head_m) inward (_mast_heads).
			var heads := clampi(int(_number(params, "heads", 1)), 1, 3)
			var lamp := bool(params.get("lamp", true))
			var sign_kind := str(params.get("sign", ""))
			_piece(result, "signal_mast_a%.1f_h%.2f_n%d_l%d_%s" % [mast_arm, head_at, heads, int(lamp), sign_kind], func(b: Builder) -> void: _signal_mast(b, mast_arm, head_at, heads, lamp, sign_kind))
			_capsule(result, 0.18, 8.4 if lamp else 6.6)
			# name: the crossing street on a green sign hung from the arm, its
			# white letters toward the approaching traffic (-X, as the heads).
			var arm_name := str(params.get("name", ""))
			if not arm_name.is_empty():
				_mast_name_sign(result, arm_name, mast_arm, _mast_heads(head_at, heads))
		"stop_sign":
			# An ALL WAY plaque where the photos show one (plaque, by default at an
			# all-way stop; the island-wide rules set it false, unconfirmed there).
			var plaque := bool(params.get("plaque", bool(params.get("all_way", false))))
			# With name blades on top (blades), the post runs up to carry them.
			var bladed := params.get("blades", null) is Array and not (params.blades as Array).is_empty()
			_piece(result, "stop_sign_w%d_b%d" % [int(plaque), int(bladed)], func(b: Builder) -> void: _stop_sign(b, plaque, bladed))
			_capsule(result, 0.06, 3.0)
			if bladed:
				_blades(result, params.blades)
		"name_sign":
			_name_sign(result, params)
		"hydrant":
			var white := str(params.get("style", "yellow")) == "white"
			_piece(result, "hydrant_%s" % ("white" if white else "yellow"), func(b: Builder) -> void: _hydrant(b, white))
			_capsule(result, 0.17, 0.78)
		"utility_pole":
			_utility_pole(result, params)
		"transformer_pad":
			# Its pad rests level at the highest ground under it (lift), its skirt
			# hiding the low side (settlePad in tools/lib/street-furniture-generation.mjs).
			var cabinet_lift := Transform3D(Basis.IDENTITY, Vector3(0.0, _number(params, "lift", 0.0), 0.0))
			_piece(result, "transformer_pad", func(b: Builder) -> void: _transformer_pad(b), cabinet_lift)
			_box_shape(result, Vector3(1.32, 1.22, 1.17), Vector3(0.0, 0.61, 0.0), cabinet_lift)
		"bus_shelter":
			var shelter_lift := Transform3D(Basis.IDENTITY, Vector3(0.0, _number(params, "lift", 0.0), 0.0))
			_piece(result, "bus_shelter_frame", func(b: Builder) -> void: _bus_shelter_frame(b), shelter_lift)
			_piece(result, "bus_shelter_glass", func(b: Builder) -> void: _bus_shelter_glass(b), shelter_lift, _glass, false)
			_piece(result, "bus_shelter_roof", func(b: Builder) -> void: _bus_shelter_roof(b), shelter_lift, _roof_glass, false)
			_box_shape(result, Vector3(3.62, 2.3, 0.12), Vector3(0.0, 1.15, SHELTER_BACK_Z), shelter_lift)
			for side: float in [-1.0, 1.0]:
				_box_shape(result, Vector3(0.12, 2.3, SHELTER_BACK_Z - SHELTER_END_FRONT_Z), Vector3(side * SHELTER_HALF_X, 1.15, (SHELTER_BACK_Z + SHELTER_END_FRONT_Z) * 0.5), shelter_lift)
			_capsule(result, 0.05, 3.2, SHELTER_FLAG_POST + shelter_lift.origin)
		"post_sign":
			var post_kind := str(params.get("sign", "tow_away"))
			_piece(result, "post_sign_%s" % post_kind, func(b: Builder) -> void: _post_sign(b, post_kind))
			_capsule(result, 0.05, TOW_AWAY_POST_M if post_kind == "tow_away" else 2.5)
		"monument_sign":
			_piece(result, "monument_sign", func(b: Builder) -> void: _monument_sign(b))
			_box_shape(result, Vector3(1.24, 1.06, 0.12), Vector3(0.0, 0.53, 0.0))
		"ev_charger_bay":
			var bay_lift := Transform3D(Basis.IDENTITY, Vector3(0.0, _number(params, "lift", 0.0), 0.0))
			_piece(result, "ev_charger_bay", func(b: Builder) -> void: _ev_charger_bay(b), bay_lift)
			_box_shape(result, Vector3(3.1, 1.1, 1.15), Vector3(0.0, 0.55, 0.0), bay_lift)
			_capsule(result, 0.06, 1.7, Vector3(1.75, 0.0, 0.0) + bay_lift.origin)
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
		"bench_wedge":
			var timber_seat := bool(params.get("timber", false))
			_piece(result, "bench_wedge_t%d" % int(timber_seat), func(b: Builder) -> void: _bench_wedge(b, timber_seat))
			for x: float in [-1.0, 1.0]:
				_box_shape(result, Vector3(1.96, 0.46, 0.58), Vector3(x * 1.03, 0.23, 0.0))
		"bench_park":
			_piece(result, "bench_park", func(b: Builder) -> void: _bench_park(b))
			_box_shape(result, Vector3(1.86, 0.84, 0.62), Vector3(0.0, 0.42, 0.04))
		"waste_basket":
			var style := str(params.get("style", "steel"))
			if not style in WASTE_BASKET_STYLES:
				style = "steel"
			_piece(result, "waste_basket_%s" % style, func(b: Builder) -> void: _waste_basket(b, style))
			_capsule(result, 0.3, 0.98)
		"map_board":
			_piece(result, "map_board", func(b: Builder) -> void: _map_board(b))
			_box_shape(result, Vector3(1.32, 1.86, 0.16), Vector3(0.0, 0.93, 0.0))
		"adirondack_chair":
			# Its rest on the ground under its feet (settleOnFeet): the tilt and lift,
			# and single legs lengthened or shortened where the ground folds.
			var rest := _rest(params)
			var drops := _leg_drops(params)
			var chair_key := "adirondack_chair"
			for drop in drops:
				chair_key += "_%d" % roundi(drop * 1000.0)
			_piece(result, chair_key, func(b: Builder) -> void: _adirondack_chair(b, drops), rest, _plastic)
			_box_shape(result, Vector3(0.74, 0.6, 0.84), Vector3(0.0, 0.3, 0.0), rest)
		"bike_rack":
			# A row of hoops (params.hoops, OSM capacity / 2) along local Z, 0.9 m apart; one box for the row.
			var hoops := clampi(roundi(_number(params, "hoops", 1.0)), 1, BIKE_RACK_MAX_HOOPS)
			_piece(result, "bike_rack_h%d" % hoops, func(b: Builder) -> void: _bike_rack(b, hoops))
			_box_shape(result, Vector3(0.78, 0.86, 0.06 + BIKE_RACK_HOOP_SPACING_M * float(hoops - 1)), Vector3(0.0, 0.43, 0.0))
		"canopy_of_sky":
			_piece(result, "canopy_of_sky_frame", func(b: Builder) -> void: _canopy_frame(b))
			_piece(result, "canopy_of_sky_discs", func(b: Builder) -> void: _canopy_discs(b), Transform3D.IDENTITY, _discs)
			for index in 4:
				var angle := PI * 0.25 + PI * 0.5 * float(index)
				_capsule(result, 0.11, 4.0, Vector3(cos(angle), 0.0, sin(angle)) * CANOPY_POLE_RADIUS_M)
		"lamp_disc":
			_piece(result, "lamp_disc", func(b: Builder) -> void: _lamp_disc(b))
			_capsule(result, 0.07, 4.2)
		"event_pole":
			_piece(result, "event_pole", func(b: Builder) -> void: _event_pole(b))
			_capsule(result, 0.13, 9.0)
		"bench_long":
			var bench_length := snappedf(clampf(_number(params, "length_m", 2.4), 1.2, 6.0), 0.1)
			var back := bool(params.get("back", true))
			_piece(result, "bench_long_l%.1f_b%d" % [bench_length, int(back)], func(b: Builder) -> void: _bench_long(b, bench_length, back))
			if back:
				_box_shape(result, Vector3(bench_length, 0.84, 0.62), Vector3(0.0, 0.42, 0.04))
			else:
				_box_shape(result, Vector3(bench_length, 0.45, 0.6), Vector3(0.0, 0.225, 0.0))
		"picnic_table_long":
			var table_length := snappedf(clampf(_number(params, "length_m", 6.1), 2.0, 7.0), 0.1)
			_piece(result, "picnic_table_long_l%.1f" % table_length, func(b: Builder) -> void: _picnic_table_long(b, table_length))
			_box_shape(result, Vector3(table_length, 0.79, 0.95), Vector3(0.0, 0.395, 0.0))
			for side: float in [-1.0, 1.0]:
				_box_shape(result, Vector3(table_length - 0.4, 0.45, 0.32), Vector3(0.0, 0.225, side * 0.86))
		"bbq_grill":
			_piece(result, "bbq_grill", func(b: Builder) -> void: _bbq_grill(b))
			_box_shape(result, Vector3(0.78, 1.24, 0.54), Vector3(0.0, 0.62, 0.0))
		"log_seat":
			var form := str(params.get("form", "log"))
			if not form in ["log", "stump", "slab"]:
				form = "log"
			var size := snappedf(clampf(_number(params, "size_m", 3.2), 0.5, 5.0), 0.1)
			_piece(result, "log_seat_%s_%.1f" % [form, size], func(b: Builder) -> void: _log_seat(b, form, size))
			match form:
				"stump":
					_box_shape(result, Vector3(size * 0.86, 0.45, size * 0.86), Vector3(0.0, 0.225, 0.0))
				"slab":
					_box_shape(result, Vector3(size, 0.45, size * 0.55), Vector3(0.0, 0.225, 0.0))
				_:
					_box_shape(result, Vector3(size, 0.5, 0.56), Vector3(0.0, 0.25, 0.0))
		"pump_station":
			_piece(result, "pump_station", func(b: Builder) -> void: _pump_station(b))
			var walls := PUMP_WALLS_M
			var thick := PUMP_WALL_THICKNESS_M
			for side: float in [-1.0, 1.0]:
				_box_shape(result, Vector3(walls.x, walls.y, thick), Vector3(0.0, walls.y * 0.5, side * (walls.z - thick) * 0.5))
				_box_shape(result, Vector3(thick, walls.y, walls.z - thick * 2.0), Vector3(side * (walls.x - thick) * 0.5, walls.y * 0.5, 0.0))
			_box_shape(result, Vector3(thick, PUMP_INNER_WALL_HEIGHT_M, walls.z - thick * 2.0), Vector3(PUMP_INNER_WALL_X_M, PUMP_INNER_WALL_HEIGHT_M * 0.5, 0.0))
	return result


func _number(params: Dictionary, key: String, fallback: float) -> float:
	var value: Variant = params.get(key, fallback)
	return float(value) if (value is float or value is int) and is_finite(float(value)) else fallback


## The prop's mesh for `key`, drawn once; `material` replaces the shared atlas
## material for the shaded surface; `shadow` false keeps the piece out of the
## sun's shadow when its prop casts one (glass).
func _piece(result: Dictionary, key: String, draw: Callable, transform := Transform3D.IDENTITY, material: Material = null, shadow := true) -> void:
	if not _meshes.has(key):
		var builder := Builder.new(CELL_WHITE)
		draw.call(builder)
		var mesh := builder.commit(material if material != null else _opaque, _lit)
		mesh.resource_name = key
		_meshes[key] = mesh
	result.pieces.append({"key": key, "mesh": _meshes[key], "transform": transform, "shadow": shadow})


## A box shape at an offset in the prop's frame (moved with the prop's `rest`),
## shared between rows of the same size.
func _box_shape(result: Dictionary, size: Vector3, offset: Vector3, rest := Transform3D.IDENTITY) -> void:
	var key := "box_%.3f_%.3f_%.3f" % [size.x, size.y, size.z]
	if not _shapes.has(key):
		var box := BoxShape3D.new()
		box.size = size
		_shapes[key] = box
	result.shapes.append({"shape": _shapes[key], "transform": rest * Transform3D(Basis.IDENTITY, offset)})


## The mesh vertices of a prop on legs as parts() draws it with no leg drops, in
## its own frame and without its rest, built without committing a mesh; empty
## for a prop without legs. For the contract that checks the legs against the
## generated street detail's prop_feet.
func standing_vertices(prop: String) -> PackedVector3Array:
	var builder := Builder.new(CELL_WHITE)
	match prop:
		"adirondack_chair":
			_adirondack_chair(builder, PackedFloat32Array())
		_:
			return PackedVector3Array()
	return builder.vertices(0)


## A prop's rest on the ground from its row's prop_params: pitch raises its
## front and roll its left side (radians), lift raises it (metres).
func _rest(params: Dictionary) -> Transform3D:
	var basis := Basis(Vector3.RIGHT, _number(params, "pitch", 0.0)) * Basis(Vector3.BACK, -_number(params, "roll", 0.0))
	return Transform3D(basis, Vector3(0.0, _number(params, "lift", 0.0), 0.0))


## The row's leg_drops_m: how much each leg (front-left, front-right,
## back-left, back-right) is lengthened (+) or shortened (-), in metres; empty
## when the row has none or they are malformed.
func _leg_drops(params: Dictionary) -> PackedFloat32Array:
	var drops := PackedFloat32Array()
	var value: Variant = params.get("leg_drops_m", null)
	if not value is Array or (value as Array).size() != 4:
		return drops
	for drop: Variant in value:
		if not (drop is float or drop is int) or not is_finite(float(drop)):
			return PackedFloat32Array()
		drops.append(float(drop))
	return drops


## An upright capsule from the foot (moved by `offset` in the prop's frame),
## shared between rows of the same size.
func _capsule(result: Dictionary, radius: float, height: float, offset := Vector3.ZERO) -> void:
	var key := "capsule_r%.3f_h%.3f" % [radius, height]
	if not _shapes.has(key):
		var capsule := CapsuleShape3D.new()
		capsule.radius = radius
		capsule.height = maxf(height, radius * 2.0)
		_shapes[key] = capsule
	var shape: CapsuleShape3D = _shapes[key]
	result.shapes.append({"shape": shape, "transform": Transform3D(Basis.IDENTITY, offset + Vector3(0.0, shape.height * 0.5, 0.0))})


# ---------------------------------------------------------------- props

## Galvanised bent-mast pole: a tapered shaft that bends into an arm over the
## road (-Z), ending in a flat LED cobra head (Treasure Island Road, Ave of the
## Palms) or, with `classic`, the davit's rounded cobra head (Avenue B, Gateview Avenue).
func _lamp_cobra(b: Builder, height: float, arm: float, classic := false, bend := 1.2) -> void:
	var bend_y := height - 0.1 - bend
	var path := PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, 0.0, 0), Vector3(0, bend_y * 0.5, 0), Vector3(0, bend_y, 0)])
	var radii := PackedFloat32Array([0.11, 0.11, 0.09, 0.072])
	_append_bend(path, radii, Vector3(0, bend_y, 0), bend, 75.0 if bend > 0.6 else 78.0, arm, 0.066, 0.05)
	b.tube(path, radii, 12, GALVANIZED, CELL_METAL, false, true)
	b.tube(PackedVector3Array([Vector3(0, -0.05, 0), Vector3(0, 0.07, 0)]), PackedFloat32Array([0.19, 0.17]), 12, GALVANIZED, CELL_METAL, false, true)
	if classic:
		_cobra_classic(b, path[path.size() - 1])
	else:
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


## A classic cobra head hung level from an arm end, reaching on toward -Z: a
## rounded pale housing, widest a third of the way along, over a bowl lens.
func _cobra_classic(b: Builder, arm_end: Vector3) -> void:
	var start := arm_end + Vector3(0.0, -0.06, 0.02)
	var path := PackedVector3Array([start, start + Vector3(0, 0.0, -0.1), start + Vector3(0, -0.01, -0.28), start + Vector3(0, -0.02, -0.52), start + Vector3(0, -0.03, -0.72)])
	b.tube(path, PackedFloat32Array([0.05, 0.12, 0.15, 0.13, 0.05]), 10, COBRA_GREY, CELL_WHITE, true, true)
	b.box(start + Vector3(0, -0.13, -0.36), Basis.IDENTITY, Vector3(0.2, 0.06, 0.46), LENS_GREY, CELL_WHITE)


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
func _signal_mast(b: Builder, arm: float, head_at: float, heads: int, lamp: bool, sign_kind: String) -> void:
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
	for at: float in _mast_heads(head_at, heads):
		var hang_y := _arm_y(clampf(at / arm, 0.0, 1.0))
		b.box(Vector3(0, hang_y - 0.12, -at), Basis.IDENTITY, Vector3(0.06, 0.24, 0.06), SIGNAL_BLACK, CELL_WHITE)
		_signal_head(b, Vector3(0, hang_y - 0.24 - 0.5, -at), Vector3.LEFT)
	# Near-side head for the opposite direction, on the downstream side of the pole.
	b.box(Vector3(0.2, 3.4, 0), Basis.IDENTITY, Vector3(0.18, 0.08, 0.08), SIGNAL_BLACK, CELL_WHITE)
	_signal_head(b, Vector3(0.42, 3.4, 0), Vector3.RIGHT)
	# Pedestrian head on the crosswalk side, facing across the road.
	b.box(Vector3(-0.17, 2.75, -0.15), Basis.IDENTITY, Vector3(0.08, 0.08, 0.2), SIGNAL_BLACK, CELL_WHITE)
	_ped_head(b, Vector3(-0.17, 2.75, -0.34), Vector3.FORWARD)
	if sign_kind == "no_stopping":
		_pole_sign(b, Vector3(0, 1.95, -0.17), Vector3.FORWARD, Vector2(0.4, 0.6), CELL_NO_STOPPING)


## Where a mast's heads hang along its arm (m from the pole): the outermost at
## head_at, the others inward, MAST_HEAD_STEP_M apart at most and no nearer the
## pole than MAST_HEAD_MIN_M.
func _mast_heads(head_at: float, heads: int) -> Array[float]:
	var spots: Array[float] = []
	var step := minf(MAST_HEAD_STEP_M, (head_at - MAST_HEAD_MIN_M) / float(heads - 1)) if heads > 1 else 0.0
	for index in heads:
		spots.append(head_at - step * float(index))
	return spots


## The green street-name sign hung from a mast arm (the dated photos' arm
## signs) in the longest stretch of arm clear of its heads: a white-bordered
## green panel sized to the name (its letters shrink to fit a short stretch),
## the name in white Label3D letters toward the approaching traffic (-X).
func _mast_name_sign(result: Dictionary, text: String, arm: float, heads: Array[float]) -> void:
	var edges: Array[float] = [0.45]
	var inward := heads.duplicate()
	inward.sort()
	for spot: float in inward:
		edges.append(spot - 0.32)
		edges.append(spot + 0.32)
	edges.append(arm - 0.1)
	var best_from := 0.0
	var best_to := 0.0
	for index in range(0, edges.size(), 2):
		if edges[index + 1] - edges[index] > best_to - best_from:
			best_from = edges[index]
			best_to = edges[index + 1]
	var room := best_to - best_from
	if room < 0.6:
		return
	var font := ThemeDB.fallback_font
	var text_m := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE).x * LABEL_PIXEL_M * MAST_NAME_SCALE
	var length := snappedf(minf(room, maxf(1.0, text_m + 0.3)), 0.05)
	var letters := MAST_NAME_SCALE * minf(1.0, (length - 0.3) / maxf(text_m, 0.01))
	var at := (best_from + best_to) * 0.5
	var y := _arm_y(clampf(at / arm, 0.0, 1.0)) - 0.33
	var placement := Transform3D(Basis.IDENTITY, Vector3(0, y, -at))
	_piece(result, "mast_name_sign_l%.2f" % length, func(b: Builder) -> void: _mast_sign_panel(b, length), placement)
	var facing := Basis(Vector3.UP, -PI * 0.5).scaled(Vector3.ONE * letters)
	result.labels.append({"text": text, "color": Color(0.96, 0.97, 0.95), "transform": placement * Transform3D(facing, Vector3(-0.022, 0, 0))})


## A green name panel in the arm's plane (along Z), facing -X with a white
## border, its back bare grey sheet, and a short hanger up to the arm.
func _mast_sign_panel(b: Builder, length: float) -> void:
	b.box(Vector3.ZERO, Basis.IDENTITY, Vector3(0.03, 0.44, length), BLADE_WHITE, CELL_WHITE)
	b.box(Vector3(-0.016, 0, 0), Basis.IDENTITY, Vector3(0.004, 0.38, length - 0.06), MAST_SIGN_GREEN, CELL_WHITE)
	b.box(Vector3(0.016, 0, 0), Basis.IDENTITY, Vector3(0.004, 0.44, length), GALVANIZED, CELL_METAL)
	for side: float in [-1.0, 1.0]:
		b.box(Vector3(0, 0.27, side * (length * 0.5 - 0.15)), Basis.IDENTITY, Vector3(0.03, 0.12, 0.03), GALVANIZED, CELL_METAL)


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
## WAY plaque under it with `plaque`; with `bladed` the post runs on up to the
## bracket that carries the junction's name blades (_blades).
func _stop_sign(b: Builder, plaque: bool, bladed := false) -> void:
	var top := BLADE_POST_TOP_M if bladed else 2.94
	b.box(Vector3(0, (top - 0.3) * 0.5, 0), Basis.IDENTITY, Vector3(0.05, top + 0.3, 0.05), GALVANIZED, CELL_METAL)
	if bladed:
		_blade_bracket(b)
	var octagon := PackedVector2Array()
	var circumradius := 0.375 / cos(PI / 8.0)
	for corner in 8:
		var angle := PI / 8.0 + TAU * float(corner) / 8.0
		octagon.append(Vector2(cos(angle), sin(angle)) * circumradius)
	b.plate(Vector3(0, 2.55, -0.04), Basis.IDENTITY, octagon, 0.012, CELL_STOP, Color.WHITE, SIGN_BACK, CELL_METAL)
	if plaque:
		b.plate(Vector3(0, 2.05, -0.04), Basis.IDENTITY, _rectangle(0.46, 0.19), 0.012, CELL_ALL_WAY, Color.WHITE, SIGN_BACK, CELL_METAL)


## A corner post with the junction's name blades (one per street).
func _name_sign(result: Dictionary, params: Dictionary) -> void:
	_piece(result, "name_sign_post", _name_post)
	_capsule(result, 0.06, 3.0)
	var blades: Variant = params.get("blades", [])
	if blades is Array:
		_blades(result, blades)


## The white name blades of a junction on top of a post, one per street (at
## most two, the second above the first), each turned along its street by its
## yaw; the names are Label3D in black on both faces.
func _blades(result: Dictionary, blades: Array, beside := 0.0) -> void:
	var font := ThemeDB.fallback_font
	for index in mini(blades.size(), 2):
		var blade: Variant = blades[index]
		if not blade is Dictionary or str((blade as Dictionary).get("text", "")).is_empty():
			continue
		var text := str(blade.text)
		var text_m := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_FONT_SIZE).x * LABEL_PIXEL_M
		var length := snappedf(maxf(0.6, text_m + BLADE_MARGIN_M * 2.0), 0.05)
		var y := BLADE_LOWER_Y_M + BLADE_STEP_Y_M * float(index)
		var turn := Basis(Vector3.UP, _number(blade, "yaw", 0.0))
		# On a post the blades sit centred on its top; beside a pole (beside > 0)
		# each one is clamped by its end, clear of the pole.
		var placement := Transform3D(turn, turn * Vector3(length * 0.5 + beside if beside > 0.0 else 0.0, y, 0))
		_piece(result, "name_blade_white_l%.2f" % length, func(b: Builder) -> void: _blade(b, length), placement)
		if beside > 0.0:
			_piece(result, "name_blade_clamp", func(b: Builder) -> void: b.box(Vector3(0.5 * beside, 0, 0), Basis.IDENTITY, Vector3(beside + 0.02, 0.06, 0.05), GALVANIZED, CELL_METAL), Transform3D(turn, Vector3(0, y, 0)))
		# Text on both faces: Label3D faces +Z, so the front copy turns half round.
		result.labels.append({"text": text, "color": NAME_TEXT, "transform": placement * Transform3D(Basis(Vector3.UP, PI), Vector3(0, 0, -0.014))})
		result.labels.append({"text": text, "color": NAME_TEXT, "transform": placement * Transform3D(Basis.IDENTITY, Vector3(0, 0, 0.014))})


func _name_post(b: Builder) -> void:
	b.tube(PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, BLADE_POST_TOP_M, 0)]), PackedFloat32Array([0.04, 0.036]), 8, GALVANIZED, CELL_METAL, false, true)
	_blade_bracket(b)


## The cast bracket on a post top that holds the name blades: a cap under the
## lower blade's bottom edge and a short block between the two blades, so the
## post never runs through a blade's lettering.
func _blade_bracket(b: Builder) -> void:
	var lower_bottom := BLADE_LOWER_Y_M - BLADE_HEIGHT_M * 0.5
	b.box(Vector3(0, lower_bottom - 0.005, 0), Basis.IDENTITY, Vector3(0.09, 0.05, 0.07), GALVANIZED, CELL_METAL)
	var gap_mid := BLADE_LOWER_Y_M + BLADE_STEP_Y_M * 0.5
	b.box(Vector3(0, gap_mid, 0), Basis.IDENTITY, Vector3(0.06, BLADE_STEP_Y_M - BLADE_HEIGHT_M + 0.03, 0.06), GALVANIZED, CELL_METAL)


## A blank white name blade along X: a thin black blade with a white face on
## each side, inset so a black border shows round it.
func _blade(b: Builder, length: float) -> void:
	b.box(Vector3.ZERO, Basis.IDENTITY, Vector3(length, BLADE_HEIGHT_M, 0.016), BLADE_BLACK, CELL_WHITE)
	for side: float in [-1.0, 1.0]:
		b.box(Vector3(0, 0, side * 0.0085), Basis.IDENTITY, Vector3(length - 0.03, BLADE_HEIGHT_M - 0.03, 0.002), BLADE_WHITE, CELL_WHITE)


## A pillar hydrant: barrel, bonnet, a pumper nozzle toward the road (-Z) and
## two hose nozzles. Yellow barrel, white bonnet and rust-brown caps on the
## Navy-era streets (Trade Winds Avenue, Avenue I photos); with `white`, the
## white San Francisco hydrant of the housing and the new district, grey caps.
func _hydrant(b: Builder, white := false) -> void:
	var body := HYDRANT_WHITE if white else HYDRANT_YELLOW
	var bonnet := HYDRANT_WHITE if white else HYDRANT_BONNET
	var caps := HYDRANT_CAP_GREY if white else HYDRANT_RUST
	b.tube(PackedVector3Array([Vector3(0, -0.1, 0), Vector3(0, 0.06, 0)]), PackedFloat32Array([0.16, 0.16]), 12, caps, CELL_WHITE, false, true)
	b.tube(PackedVector3Array([Vector3(0, 0.06, 0), Vector3(0, 0.56, 0)]), PackedFloat32Array([0.125, 0.12]), 12, body, CELL_WHITE, false, false)
	b.tube(PackedVector3Array([Vector3(0, 0.56, 0), Vector3(0, 0.6, 0)]), PackedFloat32Array([0.145, 0.145]), 12, body, CELL_WHITE, false, true)
	b.tube(PackedVector3Array([Vector3(0, 0.6, 0), Vector3(0, 0.66, 0), Vector3(0, 0.71, 0)]), PackedFloat32Array([0.13, 0.11, 0.06]), 12, bonnet, CELL_WHITE, false, true)
	b.tube(PackedVector3Array([Vector3(0, 0.71, 0), Vector3(0, 0.76, 0)]), PackedFloat32Array([0.028, 0.028]), 5, bonnet, CELL_WHITE, false, true)
	for nozzle: Array in [[Vector3.FORWARD, 0.38, 0.07, 0.078], [Vector3.LEFT, 0.46, 0.045, 0.05], [Vector3.RIGHT, 0.46, 0.045, 0.05]]:
		var direction: Vector3 = nozzle[0]
		var y := float(nozzle[1])
		b.tube(PackedVector3Array([direction * 0.1 + Vector3(0, y, 0), direction * 0.19 + Vector3(0, y, 0)]), PackedFloat32Array([float(nozzle[2]), float(nozzle[2])]), 10, body, CELL_WHITE, false, false)
		b.tube(PackedVector3Array([direction * 0.19 + Vector3(0, y, 0), direction * 0.235 + Vector3(0, y, 0)]), PackedFloat32Array([float(nozzle[3]), float(nozzle[3])]), 10, caps, CELL_WHITE, false, true)


## A dark green signal controller cabinet on a concrete pad, its door toward -Z.
func _signal_cabinet(b: Builder) -> void:
	b.box(Vector3(0, 0.05, 0), Basis.IDENTITY, Vector3(1.0, 0.16, 0.7), PAD_CONCRETE, CELL_WHITE)
	b.box(Vector3(0, 0.13 + 0.62, 0), Basis.IDENTITY, Vector3(0.76, 1.24, 0.48), CABINET_GREEN, CELL_WHITE, CELL_CABINET, CABINET_DOOR_TINT)
	b.box(Vector3(0, 0.13 + 1.24 + 0.025, 0), Basis.IDENTITY, Vector3(0.82, 0.05, 0.54), CABINET_GREEN, CELL_WHITE)


## A Muni bus stop flag (the navy route 25 flag of Avenue B at Gateview Avenue,
## Nov 2025) on a square galvanised post, printed on both faces and set across
## the curb (its faces along the road) so approaching buses see it.
func _bus_stop_sign(b: Builder) -> void:
	# A small concrete pad under the post where it stands in a verge.
	b.box(Vector3(0, 0.0, 0), Basis.IDENTITY, Vector3(0.9, 0.08, 0.9), PAD_CONCRETE, CELL_WHITE)
	_muni_flag(b, Vector3.ZERO)


## The galvanised U-channel post of a Muni stop at `foot` (as at Avenue B and
## Gateview Avenue, Nov 2025), its navy flag standing out toward the road (-Z),
## faces along X: the channel's web toward the flag, its two flanges back.
func _muni_flag(b: Builder, foot: Vector3) -> void:
	b.box(foot + Vector3(0, 1.45, -0.022), Basis.IDENTITY, Vector3(0.056, 3.5, 0.006), GALVANIZED, CELL_METAL)
	for side: float in [-1.0, 1.0]:
		b.box(foot + Vector3(side * 0.025, 1.45, -0.004), Basis.IDENTITY, Vector3(0.006, 3.5, 0.036), GALVANIZED, CELL_METAL)
	var basis := Basis.looking_at(Vector3.LEFT, Vector3.UP)
	for dy: float in [-0.24, 0.24]:
		b.box(foot + Vector3(0, 2.6 + dy, -0.05), Basis.IDENTITY, Vector3(0.04, 0.04, 0.1), GALVANIZED, CELL_METAL)
	b.plate(foot + Vector3(0, 2.6, -0.33), basis, _rectangle(0.46, 0.64), 0.012, CELL_BUS_STOP, Color.WHITE, Color.WHITE, CELL_BUS_STOP, true)


## A pair of pale cast-concrete wedge benches end to end (Waterfront Plaza):
## each block's top falls from its outer end to where the two meet, in a
## shallow V; their long axis is X, the seat front -Z. With `timber`, a slatted
## timber bench with a backrest stands on the -X block, as at the pier.
func _bench_wedge(b: Builder, timber: bool) -> void:
	var length := 1.96
	var depth := 0.58
	for side: float in [-1.0, 1.0]:
		# Side profile in the block's XY plane: a trapezoid from the outer end
		# (0.46 m) down to the meeting end (0.3 m); the front face leans in a little.
		var outline := PackedVector2Array([Vector2(-length * 0.5, 0.0), Vector2(length * 0.5, 0.0), Vector2(length * 0.5, 0.3), Vector2(-length * 0.5, 0.46)])
		if side > 0.0:
			outline = PackedVector2Array([Vector2(-length * 0.5, 0.0), Vector2(length * 0.5, 0.0), Vector2(length * 0.5, 0.46), Vector2(-length * 0.5, 0.3)])
		var center := Vector3(side * (length * 0.5 + 0.05), 0.0, 0.0)
		b.plate(center, Basis.IDENTITY, outline, depth, CELL_WHITE, CONCRETE, CONCRETE, CELL_WHITE)
	if timber:
		var x0 := -(length * 0.5 + 0.05)
		# Legs down to the sloping top (0.46 m at the outer end, 0.3 m inside).
		for x: float in [x0 - 0.7, x0 + 0.7]:
			var top := lerpf(0.46, 0.3, (x - (x0 - length * 0.5)) / length)
			b.box(Vector3(x, (top + 0.52) * 0.5, 0.02), Basis.IDENTITY, Vector3(0.05, 0.52 - top, 0.42), FRAME_CHARCOAL, CELL_WHITE)
		for index in 4:
			b.box(Vector3(x0, 0.54, -0.17 + 0.11 * float(index)), Basis.IDENTITY, Vector3(1.6, 0.035, 0.09), TIMBER, CELL_WHITE)
		var back := Basis(Vector3.RIGHT, -0.22)
		for index in 3:
			b.box(Vector3(x0, 0.7 + 0.11 * float(index), 0.24 + 0.024 * float(index)), back, Vector3(1.6, 0.08, 0.03), TIMBER, CELL_WHITE)
		for x: float in [x0 - 0.76, x0 + 0.76]:
			b.box(Vector3(x, 0.78, 0.2), Basis(Vector3.RIGHT, -0.22), Vector3(0.05, 0.5, 0.05), FRAME_CHARCOAL, CELL_WHITE)


## A slatted timber bench with a backrest and armrests on two charcoal cast
## frames (Waterfront Plaza, Sep and Mar 2025); the seat faces -Z.
func _bench_park(b: Builder) -> void:
	for x: float in [-0.82, 0.82]:
		b.box(Vector3(x, 0.21, -0.02), Basis.IDENTITY, Vector3(0.06, 0.42, 0.5), FRAME_CHARCOAL, CELL_WHITE)
		b.box(Vector3(x, 0.62, 0.22), Basis(Vector3.RIGHT, -0.2), Vector3(0.06, 0.48, 0.05), FRAME_CHARCOAL, CELL_WHITE)
		b.box(Vector3(x, 0.64, -0.06), Basis.IDENTITY, Vector3(0.07, 0.04, 0.46), FRAME_CHARCOAL, CELL_WHITE)
	for index in 4:
		b.box(Vector3(0.0, 0.43, -0.2 + 0.125 * float(index)), Basis.IDENTITY, Vector3(1.8, 0.035, 0.1), TIMBER, CELL_WHITE)
	var back := Basis(Vector3.RIGHT, -0.2)
	for index in 3:
		b.box(Vector3(0.0, 0.58 + 0.12 * float(index), 0.25 + 0.025 * float(index)), back, Vector3(1.8, 0.09, 0.03), TIMBER, CELL_WHITE)


## A litter receptacle: a grey steel can with a domed lid, the plaza's
## timber-slatted can under a grey band, or a black steel-slat can under a black
## band and a domed lid with a dark opening on its front (-Z) (the Mersea lot,
## Sep 2025: its vertical bars stand proud of the body).
func _waste_basket(b: Builder, style: String) -> void:
	var timber := style == "timber"
	var slats := timber or style == "black_slat"
	var body := TIMBER_WEATHERED if timber else (BIN_BLACK if style == "black_slat" else BIN_STEEL)
	b.tube(PackedVector3Array([Vector3(0, 0.0, 0), Vector3(0, 0.78, 0)]), PackedFloat32Array([0.27, 0.28]), 14, body, CELL_WHITE if timber else CELL_METAL, false, false)
	if timber:
		# Vertical slats read as dark grooves.
		for index in 10:
			var angle := TAU * float(index) / 10.0
			b.box(Vector3(cos(angle) * 0.282, 0.4, sin(angle) * 0.282), Basis(Vector3.UP, -angle), Vector3(0.012, 0.7, 0.012), TIMBER * 0.55, CELL_WHITE)
	elif slats:
		# Black steel bars standing proud of the body, catching the light.
		for index in 16:
			var angle := TAU * float(index) / 16.0
			b.box(Vector3(cos(angle) * 0.295, 0.39, sin(angle) * 0.295), Basis(Vector3.UP, -angle), Vector3(0.03, 0.74, 0.03), BIN_BLACK * 2.2, CELL_METAL)
	var band := FRAME_CHARCOAL if timber else (BIN_BLACK if style == "black_slat" else BIN_STEEL * 0.8)
	b.tube(PackedVector3Array([Vector3(0, 0.78, 0), Vector3(0, 0.9, 0)]), PackedFloat32Array([0.29, 0.29]), 14, band, CELL_METAL, false, false)
	b.tube(PackedVector3Array([Vector3(0, 0.9, 0), Vector3(0, 0.94, 0), Vector3(0, 0.98, 0)]), PackedFloat32Array([0.29, 0.24, 0.1]), 14, band, CELL_METAL, false, true)
	if style == "black_slat":
		# The lid's opening: a dark mouth in the front of the dome.
		b.box(Vector3(0, 0.935, -0.255), Basis(Vector3.RIGHT, 0.6), Vector3(0.26, 0.07, 0.02), Color(0.012, 0.012, 0.014), CELL_METAL)
	b.disc(Vector3(0, 0.005, 0), Vector3.DOWN, 0.27, 14, body)


## The ferry plaza's information board: an island map in a charcoal frame on
## two posts, facing -Z (Sep 2025, beside the signal cabinet).
func _map_board(b: Builder) -> void:
	for x: float in [-0.63, 0.63]:
		b.box(Vector3(x, 0.92, 0.0), Basis.IDENTITY, Vector3(0.06, 1.84, 0.08), FRAME_CHARCOAL, CELL_WHITE)
	b.box(Vector3(0.0, 1.8, 0.0), Basis.IDENTITY, Vector3(1.32, 0.08, 0.1), FRAME_CHARCOAL, CELL_WHITE)
	b.box(Vector3(0.0, 1.02, 0.0), Basis.IDENTITY, Vector3(1.2, 0.06, 0.08), FRAME_CHARCOAL, CELL_WHITE)
	b.plate(Vector3(0.0, 1.41, 0.0), Basis.IDENTITY, _rectangle(1.2, 0.72), 0.03, CELL_MAP, Color.WHITE, FRAME_CHARCOAL, CELL_WHITE)


## A bright blue moulded-plastic Adirondack chair of the modern kind facing -Z
## (Waterfront Plaza lawn, Sep 2025 photos 24 and 25): a tall, flat-topped,
## rectangular back of broad side boards and closely spaced parallel slats under
## a band across its top; wide flat arms on upright front legs, their backs on a
## rail across the chair; a low seat of slats falling toward the back on two
## seat rails; and back legs angled from under the arms down to the ground
## behind. About 0.75 m wide, 0.87 m deep and 0.99 m tall, the seat front
## 0.375 m up: production inference from the photos and common Adirondack
## proportions, not measured. `drops` (none, or the front-left, front-right,
## back-left and back-right legs) lengthens single legs.
func _adirondack_chair(b: Builder, drops: PackedFloat32Array) -> void:
	var bevel := 0.006
	# Side frames, outlines in (z, y) and thick across X: the front leg with the
	# bracket under the arm's front, the back leg, the seat rail inside the legs
	# (its top the seat's underside) and the arm, widening to its rounded front.
	var side := _frame(Vector3.BACK, Vector3.UP)
	var plan := _frame(Vector3.RIGHT, Vector3.BACK)
	for index in 2:
		var mirror := -1.0 if index == 0 else 1.0
		var front_drop := drops[index] if drops.size() == 4 else 0.0
		var back_drop := drops[index + 2] if drops.size() == 4 else 0.0
		var leg := Vector3(mirror * CHAIR_LEG_X, 0.0, 0.0)
		b.slab(leg, side, Builder.rounded(PackedVector2Array([Vector2(-0.35, -front_drop), Vector2(-0.26, -front_drop), Vector2(-0.26, 0.553), Vector2(-0.35, 0.553)]), [0.008], 2), 0.035, bevel, CHAIR_BLUE)
		b.slab(leg, side, Builder.rounded(PackedVector2Array([Vector2(-0.35, 0.47), Vector2(-0.35, 0.553), Vector2(-0.397, 0.553)]), [0.006], 1), 0.03, 0.004, CHAIR_BLUE)
		b.slab(leg, side, Builder.rounded(PackedVector2Array([Vector2(0.333, -back_drop), Vector2(0.417, -back_drop), Vector2(0.262, 0.553), Vector2(0.178, 0.553)]), [0.008], 2), 0.035, bevel, CHAIR_BLUE)
		b.slab(Vector3(mirror * 0.265, 0.0, 0.0), side, Builder.rounded(PackedVector2Array([Vector2(-0.35, 0.2525), Vector2(-0.35, 0.3525), Vector2(0.32, 0.21), Vector2(0.32, 0.11)]), [0.008], 2), 0.035, bevel, CHAIR_BLUE)
		var arm := PackedVector2Array([Vector2(mirror * 0.26, 0.28), Vector2(mirror * 0.375, 0.28), Vector2(mirror * 0.375, -0.415), Vector2(mirror * 0.225, -0.415)])
		b.slab(Vector3(0.0, 0.564, 0.0), plan, Builder.rounded(arm, [0.012, 0.012, 0.05, 0.05], 3), 0.022, bevel, CHAIR_BLUE)
	# The arms' backs rest on a rail across the back of the chair.
	b.slab(Vector3(0.0, 0.513, 0.2625), _frame(Vector3.RIGHT, Vector3.UP), Builder.rounded(_rectangle(0.75, 0.08), [0.01], 2), 0.025, bevel, CHAIR_BLUE)
	# Seat: five slats on a plane falling 12 degrees toward the back from its
	# front edge, 0.375 m up.
	var fall := deg_to_rad(12.0)
	var down_seat := Vector3(0.0, -sin(fall), cos(fall))
	var seat_normal := Vector3(0.0, cos(fall), sin(fall))
	var seat := _frame(Vector3.RIGHT, down_seat)
	for index in 5:
		var center := Vector3(0.0, 0.375, -0.36) + down_seat * (0.092 * float(index) + 0.04) - seat_normal * 0.01
		b.slab(center, seat, Builder.rounded(_rectangle(0.56, 0.08), [0.012], 2), 0.02, bevel, CHAIR_BLUE)
	# Back, the modern poly kind of photos 24 and 25: a flat-topped rectangle
	# 0.49 m wide leaning back 23 degrees from behind the seat, broad side boards
	# with four closely spaced parallel slats between them, a band across its
	# top behind and a low rail between the seat rails. The outlines are in the
	# back's plane (across, up it); its Z points behind.
	var lean := deg_to_rad(23.0)
	var back := _frame(Vector3.RIGHT, Vector3(0.0, cos(lean), sin(lean)))
	var back_origin := Vector3(0.0, 0.26, 0.1)
	var top := 0.79
	for mirror: float in [-1.0, 1.0]:
		var side_board := PackedVector2Array([Vector2(mirror * 0.155, 0.0), Vector2(mirror * 0.245, 0.0), Vector2(mirror * 0.245, top), Vector2(mirror * 0.155, top)])
		b.slab(back_origin + back.z * 0.0125, back, Builder.rounded(side_board, [0.006, 0.006, 0.025, 0.008], 2), 0.025, bevel, CHAIR_BLUE)
	for index in 4:
		var middle := -0.113625 + 0.07575 * float(index)
		var slat := PackedVector2Array([Vector2(middle - 0.034375, 0.0), Vector2(middle + 0.034375, 0.0), Vector2(middle + 0.034375, top), Vector2(middle - 0.034375, top)])
		b.slab(back_origin + back.z * 0.01, back, Builder.rounded(slat, [0.006], 2), 0.02, 0.005, CHAIR_BLUE)
	b.slab(back_origin + back.y * (top - 0.0375) + back.z * 0.0375, back, Builder.rounded(_rectangle(0.49, 0.075), [0.012], 2), 0.025, bevel, CHAIR_BLUE)
	b.slab(back_origin + back.y * 0.035 + back.z * 0.04, back, Builder.rounded(_rectangle(0.495, 0.07), [0.01], 2), 0.03, bevel, CHAIR_BLUE)


## An orthonormal basis whose X and Y span an outline's plane and whose Z
## (X cross Y) is a slab's thickness.
static func _frame(x_axis: Vector3, y_axis: Vector3) -> Basis:
	var x := x_axis.normalized()
	var y := (y_axis - x * y_axis.dot(x)).normalized()
	return Basis(x, y, x.cross(y))


## An inverted-U bike rack ("staple") of dark powder-coated tube, its loop
## along X (Ave of the Palms at Johnson St, Nov 2025), each leg on a square base
## flange: `hoops` of them in a row along Z, BIKE_RACK_HOOP_SPACING_M apart and
## centred on the origin.
func _bike_rack(b: Builder, hoops: int) -> void:
	for hoop in hoops:
		var z := BIKE_RACK_HOOP_SPACING_M * (float(hoop) - float(hoops - 1) * 0.5)
		var path := PackedVector3Array([Vector3(-0.36, -0.1, z), Vector3(-0.36, 0.62, z)])
		var radii := PackedFloat32Array([0.026, 0.026])
		for step in range(1, 7):
			var angle := PI - PI * float(step) / 6.0
			path.append(Vector3(cos(angle) * 0.36, 0.62 + sin(angle) * 0.2, z))
			radii.append(0.026)
		path.append(Vector3(0.36, -0.1, z))
		radii.append(0.026)
		b.tube(path, radii, 8, RACK_DARK, CELL_METAL, false, false)
		for x: float in [-0.36, 0.36]:
			b.box(Vector3(x, 0.008, z), Basis.IDENTITY, Vector3(0.13, 0.016, 0.13), RACK_DARK * 1.15, CELL_METAL)


# ---------------------------------------------------------------- Cityside Park

## Canopy of Sky (Ned Kahn, 2025): the 20 ft stainless ring hung on cables from
## four curved aluminium poles, drawn here (the hanging discs are
## _canopy_discs). The poles stand on the diagonals, outside the walkway along
## local X; each pole's head leans in over the ring.
func _canopy_frame(b: Builder) -> void:
	for index in 4:
		var angle := PI * 0.25 + PI * 0.5 * float(index)
		var out := Vector3(cos(angle), 0.0, sin(angle))
		var path := PackedVector3Array()
		var radii := PackedFloat32Array()
		for step in 10:
			var t := float(step) / 9.0
			path.append(out * (CANOPY_POLE_RADIUS_M - 1.0 * t * t) + Vector3(0.0, -0.3 + (CANOPY_POLE_TOP_M + 0.3) * t, 0.0))
			radii.append(lerpf(0.095, 0.055, t))
		b.tube(path, radii, 10, ALUMINIUM, CELL_METAL, false, true)
		b.tube(PackedVector3Array([out * CANOPY_POLE_RADIUS_M + Vector3(0.0, -0.05, 0.0), out * CANOPY_POLE_RADIUS_M + Vector3(0.0, 0.09, 0.0)]), PackedFloat32Array([0.19, 0.16]), 12, PAD_CONCRETE, CELL_WHITE, false, true)
		# Three cables from the head to the ring, splayed either side.
		var head := path[path.size() - 1]
		for spread: float in [-0.35, 0.0, 0.35]:
			var to := Vector3(cos(angle + spread), 0.0, sin(angle + spread)) * CANOPY_RING_RADIUS_M + Vector3(0.0, CANOPY_RING_Y, 0.0)
			b.tube(PackedVector3Array([head, to]), PackedFloat32Array([0.012, 0.012]), 4, FRAME_CHARCOAL, CELL_WHITE, false, false)
	var ring := PackedVector3Array()
	var ring_radii := PackedFloat32Array()
	for step in 73:
		var angle := TAU * float(step) / 72.0
		ring.append(Vector3(cos(angle), 0.0, sin(angle)) * CANOPY_RING_RADIUS_M + Vector3(0.0, CANOPY_RING_Y, 0.0))
		ring_radii.append(0.045)
	b.tube(ring, ring_radii, 8, STAINLESS, CELL_METAL, false, false)


## The canopy's hanging polycarbonate discs (about 7000 on the real piece; fewer
## and larger here, overlapping so the dish reads near solid from afar): rings of
## small discs filling the ring in a shallow dish that
## sags CANOPY_SAG_M at the middle, each turned and swung a little by the wind,
## pale silver with a faint sky tint. The disc material lets the sun through, so
## the dish glows when seen from below.
func _canopy_discs(b: Builder) -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 7000
	var step := 0.16
	for ring in int(CANOPY_RING_RADIUS_M / step):
		var radius := step * (float(ring) + 0.55)
		var count := maxi(6, roundi(TAU * radius / step))
		for index in count:
			var angle := TAU * (float(index) + random.randf_range(-0.2, 0.2)) / float(count) + float(ring) * 0.41
			var r := minf(radius + random.randf_range(-0.035, 0.035), CANOPY_RING_RADIUS_M - 0.06)
			var y := CANOPY_RING_Y - CANOPY_SAG_M * (1.0 - pow(r / CANOPY_RING_RADIUS_M, 2.0)) - random.randf_range(0.0, 0.07)
			var normal := Vector3(random.randf_range(-0.6, 0.6), -1.0, random.randf_range(-0.6, 0.6)).normalized()
			var shade := random.randf_range(0.8, 0.98)
			b.disc(Vector3(cos(angle) * r, y, sin(angle) * r), normal, 0.1, 8, Color(shade * 0.97, shade * 0.99, minf(1.0, shade * 1.04)))


## Cityside Park's 14 ft path lights (2024 art-location plan label "Light Pole
## 14 ft"; ph08 and ph10, Sep 2025): a slender dark grey pole under a broad flat
## disc head.
func _lamp_disc(b: Builder) -> void:
	var top := 4.27
	b.tube(PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, top - 0.12, 0)]), PackedFloat32Array([0.055, 0.045]), 10, PARK_POLE_GREY, CELL_METAL, false, true)
	b.tube(PackedVector3Array([Vector3(0, -0.05, 0), Vector3(0, 0.3, 0)]), PackedFloat32Array([0.085, 0.075]), 10, PARK_POLE_GREY, CELL_METAL, false, true)
	b.tube(PackedVector3Array([Vector3(0, top - 0.12, 0), Vector3(0, top - 0.05, 0)]), PackedFloat32Array([0.42, 0.45]), 24, PARK_POLE_GREY, CELL_METAL, false, false)
	b.tube(PackedVector3Array([Vector3(0, top - 0.05, 0), Vector3(0, top - 0.01, 0), Vector3(0, top + 0.03, 0)]), PackedFloat32Array([0.45, 0.38, 0.06]), 24, PARK_POLE_GREY, CELL_METAL, false, true)
	b.disc(Vector3(0, top - 0.12, 0), Vector3.DOWN, 0.42, 24, LENS_GREY)


## The 30 ft event light poles round the lawn (2024 art-location plan label
## "Light Pole 30 ft (event use only)"; ph08): a tall tapered grey pole with a
## short cross arm near its top holding two small floodlights aimed down over the
## lawn (-Z).
func _event_pole(b: Builder) -> void:
	var top := 9.1
	b.tube(PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, top, 0)]), PackedFloat32Array([0.12, 0.07]), 10, PARK_POLE_GREY, CELL_METAL, false, true)
	b.tube(PackedVector3Array([Vector3(0, -0.05, 0), Vector3(0, 0.45, 0)]), PackedFloat32Array([0.17, 0.15]), 10, PARK_POLE_GREY, CELL_METAL, false, true)
	b.box(Vector3(0, top - 0.45, -0.05), Basis.IDENTITY, Vector3(0.95, 0.07, 0.07), PARK_POLE_GREY, CELL_METAL)
	for x: float in [-0.4, 0.4]:
		var mount := Vector3(x, top - 0.42, -0.08)
		var axis := Vector3(0.0, -0.6, -1.0).normalized()
		b.tube(PackedVector3Array([mount, mount + axis * 0.3]), PackedFloat32Array([0.1, 0.13]), 10, PARK_POLE_GREY, CELL_METAL, true, false)
		b.disc(mount + axis * 0.3, axis, 0.12, 10, LENS_GREY)
	b.box(Vector3(0, top - 1.4, 0.1), Basis.IDENTITY, Vector3(0.22, 0.32, 0.16), PARK_POLE_GREY, CELL_METAL)


## The park's long timber benches (2024 art-location plan label "Park Bench -
## Rough&Ready 6 by Streetlife"; ph10, Sep 2025): thick pale timber slats on dark
## steel frames with a slatted backrest, or, without a back, on a pale concrete
## plinth as by the lawn. Length along X; the seat faces -Z.
func _bench_long(b: Builder, length: float, back: bool) -> void:
	if back:
		var frames := maxi(2, ceili(length / 1.9) + 1)
		for index in frames:
			var x := lerpf(-length * 0.5 + 0.18, length * 0.5 - 0.18, float(index) / float(frames - 1))
			b.box(Vector3(x, 0.2, 0.0), Basis.IDENTITY, Vector3(0.07, 0.4, 0.5), STEEL_BLACK, CELL_WHITE)
			b.box(Vector3(x, 0.68, 0.24), Basis(Vector3.RIGHT, -0.18), Vector3(0.07, 0.52, 0.07), STEEL_BLACK, CELL_WHITE)
		for index in 5:
			b.box(Vector3(0.0, 0.435, -0.22 + 0.105 * float(index)), Basis.IDENTITY, Vector3(length, 0.07, 0.092), BENCH_TIMBER, CELL_WHITE)
		var tilt := Basis(Vector3.RIGHT, -0.18)
		for index in 3:
			b.box(Vector3(0.0, 0.62 + 0.13 * float(index), 0.26 + 0.024 * float(index)), tilt, Vector3(length, 0.1, 0.06), BENCH_TIMBER, CELL_WHITE)
	else:
		b.box(Vector3(0.0, 0.19, 0.0), Basis.IDENTITY, Vector3(length - 0.1, 0.38, 0.5), CONCRETE, CELL_WHITE)
		for index in 5:
			b.box(Vector3(0.0, 0.415, -0.24 + 0.12 * float(index)), Basis.IDENTITY, Vector3(length, 0.07, 0.1), BENCH_TIMBER, CELL_WHITE)


## The north BBQ plaza's 20 ft picnic tables (CMG news, Sep 2025; ph09, Sep 2025):
## a top of three thick fresh timber beams and a long timber bench beam either
## side, on black steel flat-bar frames. Length along X.
func _picnic_table_long(b: Builder, length: float) -> void:
	for index in 3:
		b.box(Vector3(0.0, 0.74, -0.31 + 0.31 * float(index)), Basis.IDENTITY, Vector3(length, 0.1, 0.29), TABLE_TIMBER, CELL_WHITE)
	for side: float in [-1.0, 1.0]:
		b.box(Vector3(0.0, 0.33, side * 0.86), Basis.IDENTITY, Vector3(length - 0.4, 0.24, 0.3), TABLE_TIMBER, CELL_WHITE)
	var frames := maxi(2, roundi(length / 2.0) + 1)
	for index in frames:
		var x := lerpf(-length * 0.5 + 0.45, length * 0.5 - 0.45, float(index) / float(frames - 1))
		for dz: float in [-0.13, 0.13]:
			b.box(Vector3(x, 0.345, dz), Basis.IDENTITY, Vector3(0.05, 0.69, 0.025), STEEL_BLACK, CELL_WHITE)
		b.box(Vector3(x, 0.12, 0.0), Basis.IDENTITY, Vector3(0.05, 0.05, 1.95), STEEL_BLACK, CELL_WHITE)
		for side: float in [-1.0, 1.0]:
			b.box(Vector3(x, 0.115, side * 0.86), Basis.IDENTITY, Vector3(0.05, 0.23, 0.05), STEEL_BLACK, CELL_WHITE)


## A park BBQ grill (ph09, Sep 2025): a black steel firebox under a heavy grate on
## a single post, a heat shield rising at its back (+Z), on a small pad.
func _bbq_grill(b: Builder) -> void:
	b.box(Vector3(0, 0.03, 0), Basis.IDENTITY, Vector3(0.6, 0.06, 0.6), PAD_CONCRETE, CELL_WHITE)
	b.tube(PackedVector3Array([Vector3(0, 0.0, 0), Vector3(0, 0.72, 0)]), PackedFloat32Array([0.06, 0.06]), 10, STEEL_BLACK, CELL_METAL, false, false)
	b.box(Vector3(0, 0.84, 0), Basis.IDENTITY, Vector3(0.76, 0.24, 0.5), STEEL_BLACK, CELL_METAL)
	b.box(Vector3(0, 1.1, 0.235), Basis.IDENTITY, Vector3(0.76, 0.28, 0.03), STEEL_BLACK, CELL_METAL)
	for side: float in [-1.0, 1.0]:
		b.box(Vector3(side * 0.365, 1.04, 0.1), Basis.IDENTITY, Vector3(0.03, 0.16, 0.3), STEEL_BLACK, CELL_METAL)
	for index in 7:
		b.box(Vector3(0, 0.97, -0.21 + 0.07 * float(index)), Basis.IDENTITY, Vector3(0.7, 0.02, 0.018), BIN_STEEL * 0.6, CELL_METAL)


## Salvaged eucalyptus from Yerba Buena Island as seats in the strand garden (CMG;
## ph02 and ph03, Sep 2025), the wood weathered pale and barkless: a long log
## lying along X, a stump stool, or a broad bean-shaped stump slab. size is the
## log's length or the stump's or slab's width (m).
func _log_seat(b: Builder, form: String, size: float) -> void:
	match form:
		"stump":
			var radius := size * 0.5
			b.tube(PackedVector3Array([Vector3(0, -0.05, 0), Vector3(0, 0.45, 0)]), PackedFloat32Array([radius + 0.03, radius]), 16, DRIFTWOOD, CELL_WHITE, false, false)
			b.disc(Vector3(0, 0.45, 0), Vector3.UP, radius, 16, END_GRAIN)
		"slab":
			# Two overlapping rounds of one broad stump.
			for lobe: Array in [[Vector3(-size * 0.2, 0.0, 0.03), size * 0.32], [Vector3(size * 0.2, 0.0, -0.03), size * 0.28]]:
				var center: Vector3 = lobe[0]
				var radius := float(lobe[1])
				b.tube(PackedVector3Array([center + Vector3(0, -0.05, 0), center + Vector3(0, 0.45, 0)]), PackedFloat32Array([radius + 0.02, radius]), 16, DRIFTWOOD, CELL_WHITE, false, false)
				b.disc(center + Vector3(0, 0.45, 0), Vector3.UP, radius, 16, END_GRAIN)
		_:
			b.tube(PackedVector3Array([Vector3(-size * 0.5, 0.27, 0), Vector3(0.0, 0.26, 0.02), Vector3(size * 0.5, 0.245, 0)]), PackedFloat32Array([0.31, 0.29, 0.27]), 14, DRIFTWOOD, CELL_WHITE, false, false)
			b.disc(Vector3(-size * 0.5, 0.27, 0), Vector3.LEFT, 0.31, 14, END_GRAIN)
			b.disc(Vector3(size * 0.5, 0.245, 0), Vector3.RIGHT, 0.27, 14, END_GRAIN)


## Cityside Park's stormwater pump station (not in the frozen OSM building
## inventory, so a site structure): an open-topped compound of tall grey cast
## concrete walls round a pale concrete floor, divided by a lower inner wall
## (CMG photo 4, 2025-2026; the aerial of 2026-05-26). Simple massing only, with
## no doors, openings or other detail that no dated photo shows.
func _pump_station(b: Builder) -> void:
	var walls := PUMP_WALLS_M
	var thick := PUMP_WALL_THICKNESS_M
	for side: float in [-1.0, 1.0]:
		b.box(Vector3(0.0, walls.y * 0.5 - 0.15, side * (walls.z - thick) * 0.5), Basis.IDENTITY, Vector3(walls.x, walls.y + 0.3, thick), PUMP_CONCRETE, CELL_WHITE)
		b.box(Vector3(side * (walls.x - thick) * 0.5, walls.y * 0.5 - 0.15, 0.0), Basis.IDENTITY, Vector3(thick, walls.y + 0.3, walls.z - thick * 2.0), PUMP_CONCRETE, CELL_WHITE)
	b.box(Vector3(0.0, 0.05, 0.0), Basis.IDENTITY, Vector3(walls.x - thick * 2.0, 0.1, walls.z - thick * 2.0), PUMP_FLOOR, CELL_WHITE)
	b.box(Vector3(PUMP_INNER_WALL_X_M, PUMP_INNER_WALL_HEIGHT_M * 0.5 - 0.1, 0.0), Basis.IDENTITY, Vector3(thick, PUMP_INNER_WALL_HEIGHT_M + 0.2, walls.z - thick * 2.0), PUMP_CONCRETE, CELL_WHITE)


# ---------------------------------------------------------------- island-wide props

## The wooden utility pole of an OSM power pole (local -Z along its line, the
## crossarms along X): the pole with its top crossarm, a second crossarm where
## another line turns off or two circuits run (arm2_yaw, turned about the
## pole), a riser conduit where the line goes underground (riser) and a street
## lamp on an arm toward its street (lamp: {yaw, arm_m, height_m, head}). Most
## shafts are weathered grey; wood "dark" draws a darker creosote one.
func _utility_pole(result: Dictionary, params: Dictionary) -> void:
	var height := POLE_HEIGHT_M
	var riser := bool(params.get("riser", false))
	var dark := str(params.get("wood", "")) == "dark"
	_piece(result, "utility_pole_r%d_w%d" % [int(riser), int(dark)], func(b: Builder) -> void: _pole_body(b, height, riser, POLE_WOOD_DARK if dark else POLE_WOOD))
	var arm2: Variant = params.get("arm2_yaw", null)
	if arm2 is float or arm2 is int:
		_piece(result, "utility_pole_arm2", func(b: Builder) -> void: _crossarm(b, height - ARM2_DROP_M), Transform3D(Basis(Vector3.UP, float(arm2)), Vector3.ZERO))
	var lamp: Variant = params.get("lamp", null)
	if lamp is Dictionary:
		var arm := snappedf(clampf(_number(lamp, "arm_m", 2.1), 1.0, 3.0), 0.1)
		var at := snappedf(clampf(_number(lamp, "height_m", 7.9), 5.0, 9.5), 0.1)
		_piece(result, "utility_pole_lamp_a%.1f_h%.1f" % [arm, at], func(b: Builder) -> void: _pole_lamp(b, at, arm), Transform3D(Basis(Vector3.UP, _number(lamp, "yaw", 0.0)), Vector3.ZERO))
	_capsule(result, 0.16, height)


## The pole: a wood shaft (tinted `wood`) tapering to its cap, the top crossarm
## with its braces and pin insulators, the lower cable's bracket and, with
## `riser`, a grey conduit up its back to a terminator bracket.
func _pole_body(b: Builder, height: float, riser: bool, wood: Color) -> void:
	b.tube(PackedVector3Array([Vector3(0, -0.3, 0), Vector3(0, height * 0.5, 0), Vector3(0, height, 0)]), PackedFloat32Array([0.155, 0.135, 0.11]), 10, wood, CELL_POLE_WOOD, false, true)
	_crossarm(b, height - ARM_DROP_M)
	b.box(Vector3(0, LOWER_CABLE_M, -0.13), Basis.IDENTITY, Vector3(0.06, 0.14, 0.06), GALVANIZED, CELL_METAL)
	if riser:
		b.tube(PackedVector3Array([Vector3(0, -0.1, 0.19), Vector3(0, height - 2.0, 0.19)]), PackedFloat32Array([0.05, 0.05]), 8, CONDUIT_GREY, CELL_WHITE, false, true)
		for y: float in [0.8, 3.0, 5.2, height - 2.3]:
			b.box(Vector3(0, y, 0.15), Basis.IDENTITY, Vector3(0.12, 0.04, 0.1), GALVANIZED, CELL_METAL)
		b.box(Vector3(0, height - 1.95, 0.22), Basis.IDENTITY, Vector3(0.8, 0.07, 0.07), CROSSARM_WOOD, CELL_POLE_WOOD)
		for x: float in [-0.3, 0.0, 0.3]:
			b.tube(PackedVector3Array([Vector3(x, height - 1.92, 0.22), Vector3(x, height - 1.62, 0.22)]), PackedFloat32Array([0.04, 0.03]), 6, INSULATOR_GREY, CELL_WHITE, false, true)


## A timber crossarm across the pole (along X) at height y, with two braces
## under it and a pin insulator at each INSULATOR_XS.
func _crossarm(b: Builder, y: float) -> void:
	b.box(Vector3(0, y, -0.17), Basis.IDENTITY, Vector3(2.44, 0.09, 0.1), CROSSARM_WOOD, CELL_POLE_WOOD)
	for side: float in [-1.0, 1.0]:
		var top := Vector3(side * 0.62, y - 0.05, -0.16)
		var foot := Vector3(0, y - 0.62, -0.14)
		var along := top - foot
		var basis := Basis(along.cross(Vector3.BACK).normalized(), along.normalized(), Vector3.BACK)
		b.box((top + foot) * 0.5, basis, Vector3(0.04, along.length(), 0.01), GALVANIZED, CELL_METAL)
	for x: float in INSULATOR_XS:
		b.tube(PackedVector3Array([Vector3(x, y + 0.045, -0.17), Vector3(x, y + 0.1, -0.17), Vector3(x, y + 0.15, -0.17), Vector3(x, y + INSULATOR_TOP_M, -0.17)]), PackedFloat32Array([0.035, 0.055, 0.045, 0.03]), 8, INSULATOR_GREY, CELL_WHITE, false, true)


## A street lamp on a pole: a galvanised arm from the pole at height `at`,
## rising a little toward -Z for `arm` metres, with a classic cobra head.
func _pole_lamp(b: Builder, at: float, arm: float) -> void:
	b.box(Vector3(0, at, -0.16), Basis.IDENTITY, Vector3(0.12, 0.22, 0.05), GALVANIZED, CELL_METAL)
	var path := PackedVector3Array([Vector3(0, at, -0.17), Vector3(0, at + 0.12, -0.17 - arm * 0.35), Vector3(0, at + 0.3, -0.17 - arm * 0.75), Vector3(0, at + 0.36, -0.17 - arm)])
	b.tube(path, PackedFloat32Array([0.04, 0.035, 0.032, 0.03]), 8, GALVANIZED, CELL_METAL, false, true)
	b.tube(PackedVector3Array([Vector3(0, at - 0.2, -0.17), Vector3(0, at + 0.1, -0.17 - arm * 0.3)]), PackedFloat32Array([0.018, 0.018]), 6, GALVANIZED, CELL_METAL, false, false)
	_cobra_classic(b, path[path.size() - 1] + Vector3(0, 0.06, 0))


## Where a utility pole's wires attach, in its frame: one entry per crossarm,
## {yaw (radians about the pole, 0 for the top arm), points (insulator tops)},
## and the lower cable's bracket as "lower".
func wire_levels(params: Dictionary) -> Dictionary:
	var height := POLE_HEIGHT_M
	var levels: Array = []
	var arms := [[0.0, height - ARM_DROP_M]]
	var arm2: Variant = params.get("arm2_yaw", null)
	if arm2 is float or arm2 is int:
		arms.append([float(arm2), height - ARM2_DROP_M])
	for arm: Array in arms:
		var turn := Basis(Vector3.UP, float(arm[0]))
		var points: Array[Vector3] = []
		for x: float in INSULATOR_XS:
			points.append(turn * Vector3(x, float(arm[1]) + INSULATOR_TOP_M, -0.17))
		levels.append({"yaw": float(arm[0]), "points": points})
	return {"levels": levels, "lower": Vector3(0, LOWER_CABLE_M, -0.17)}


## One straight piece of wire: a four-sided unit tube along +Z (0 to 1) with a
## unit radius, which each instance scales to its piece's length and the wire's
## radius; the wire shader keeps it at least a pixel wide at any distance.
func wire_mesh() -> ArrayMesh:
	if _wire_mesh == null:
		var vertices := PackedVector3Array()
		var normals := PackedVector3Array()
		var indices := PackedInt32Array()
		for side in 4:
			var angle := TAU * (float(side) + 0.5) / 4.0
			var normal := Vector3(cos(angle), sin(angle), 0.0)
			for z: float in [0.0, 1.0]:
				vertices.append(Vector3(normal.x, normal.y, z))
				normals.append(normal)
		for side in 4:
			var a := side * 2
			var c := ((side + 1) % 4) * 2
			# Clockwise seen from outside, as Godot's front faces.
			indices.append_array(PackedInt32Array([a, a + 1, c, c, a + 1, c + 1]))
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_INDEX] = indices
		_wire_mesh = ArrayMesh.new()
		_wire_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		_wire_mesh.surface_set_material(0, _wire)
		_wire_mesh.resource_name = "power_wire"
	return _wire_mesh


## A pad-mounted transformer: a mid-green steel cabinet with two louvred doors
## toward -Z, a lid lip and small warning labels, on a concrete pad.
func _transformer_pad(b: Builder) -> void:
	_pad(b, Vector3(0, 0, 0), Vector2(1.55, 1.4), 0.1)
	b.box(Vector3(0, 0.1 + 0.55, 0), Basis.IDENTITY, Vector3(1.3, 1.1, 1.15), TRANSFORMER_GREEN, CELL_WHITE)
	b.box(Vector3(0, 1.22, 0), Basis.IDENTITY, Vector3(1.34, 0.04, 1.19), TRANSFORMER_GREEN, CELL_WHITE)
	b.box(Vector3(0, 0.62, -0.576), Basis.IDENTITY, Vector3(0.012, 1.0, 0.012), TRANSFORMER_GREEN * 0.7, CELL_WHITE)
	# Louvre bands low and high on each door.
	for x: float in [-0.33, 0.33]:
		for y: float in [0.3, 1.02]:
			for index in 3:
				b.box(Vector3(x, y + 0.035 * float(index), -0.578), Basis.IDENTITY, Vector3(0.44, 0.012, 0.008), TRANSFORMER_GREEN * 0.62, CELL_WHITE)
	for x: float in [-0.36, 0.36]:
		b.box(Vector3(x, 0.78, -0.578), Basis.IDENTITY, Vector3(0.2, 0.12, 0.006), WARNING_RED, CELL_WHITE)
		b.box(Vector3(x, 0.78, -0.581), Basis.IDENTITY, Vector3(0.16, 0.05, 0.004), BLADE_WHITE, CELL_WHITE)


## A Muni shelter's opaque parts (its open front toward -Z, along X): charcoal
## posts, rails and roof beams, a bench along the back, a dark map panel in the
## -X end and the stop's flag on its own post at the front of that end.
const SHELTER_HALF_X := 1.8
const SHELTER_BACK_Z := 0.72
const SHELTER_END_FRONT_Z := -0.55
const SHELTER_ROOF_Y := 2.3
const SHELTER_FLAG_POST := Vector3(-1.95, 0.0, -0.8)


func _bus_shelter_frame(b: Builder) -> void:
	_pad(b, Vector3(0, 0, 0.05), Vector2(3.85, 1.75), 0.06)
	for x: float in [-SHELTER_HALF_X, 0.0, SHELTER_HALF_X]:
		b.box(Vector3(x, SHELTER_ROOF_Y * 0.5, SHELTER_BACK_Z), Basis.IDENTITY, Vector3(0.08, SHELTER_ROOF_Y, 0.08), SHELTER_FRAME, CELL_WHITE)
	for x: float in [-SHELTER_HALF_X, SHELTER_HALF_X]:
		b.box(Vector3(x, SHELTER_ROOF_Y * 0.5, SHELTER_END_FRONT_Z), Basis.IDENTITY, Vector3(0.08, SHELTER_ROOF_Y, 0.08), SHELTER_FRAME, CELL_WHITE)
		for y: float in [0.12, SHELTER_ROOF_Y - 0.06]:
			b.box(Vector3(x, y, (SHELTER_BACK_Z + SHELTER_END_FRONT_Z) * 0.5), Basis.IDENTITY, Vector3(0.06, 0.06, SHELTER_BACK_Z - SHELTER_END_FRONT_Z), SHELTER_FRAME, CELL_WHITE)
	for y: float in [0.12, SHELTER_ROOF_Y - 0.06]:
		b.box(Vector3(0, y, SHELTER_BACK_Z), Basis.IDENTITY, Vector3(SHELTER_HALF_X * 2.0, 0.06, 0.06), SHELTER_FRAME, CELL_WHITE)
	# Roof beams along the front and back edges of the arched roof.
	for z: float in [-0.85, 0.85]:
		b.box(Vector3(0, SHELTER_ROOF_Y + 0.02, z), Basis.IDENTITY, Vector3(SHELTER_HALF_X * 2.0 + 0.2, 0.1, 0.07), SHELTER_FRAME, CELL_WHITE)
	for x: float in [-SHELTER_HALF_X - 0.05, SHELTER_HALF_X + 0.05]:
		_roof_arc(b, x, 0.07, SHELTER_FRAME, 0.07)
	# Bench along the back, on two legs.
	b.box(Vector3(0, 0.46, SHELTER_BACK_Z - 0.26), Basis.IDENTITY, Vector3(2.2, 0.05, 0.36), SHELTER_BENCH, CELL_WHITE)
	for x: float in [-0.9, 0.9]:
		b.box(Vector3(x, 0.22, SHELTER_BACK_Z - 0.26), Basis.IDENTITY, Vector3(0.05, 0.44, 0.3), SHELTER_FRAME, CELL_WHITE)
	# The map panel in the -X end.
	b.box(Vector3(-SHELTER_HALF_X, 1.2, 0.08), Basis.IDENTITY, Vector3(0.05, 1.2, 0.85), SHELTER_PANEL, CELL_WHITE)
	_muni_flag(b, SHELTER_FLAG_POST)


## The arched roof's cross section at x: a band of segments over the shelter's
## depth, rising 0.18 m at its middle, `depth` thick along X.
func _roof_arc(b: Builder, x: float, depth: float, color: Color, thickness: float) -> void:
	var steps := 8
	for step in steps:
		var z0 := lerpf(-0.88, 0.88, float(step) / float(steps))
		var z1 := lerpf(-0.88, 0.88, float(step + 1) / float(steps))
		var y0 := SHELTER_ROOF_Y + 0.08 + 0.18 * (1.0 - pow(z0 / 0.88, 2.0))
		var y1 := SHELTER_ROOF_Y + 0.08 + 0.18 * (1.0 - pow(z1 / 0.88, 2.0))
		var along := Vector3(0, y1 - y0, z1 - z0)
		var basis := Basis(Vector3.RIGHT, along.cross(Vector3.RIGHT).normalized(), along.normalized())
		b.box(Vector3(x, (y0 + y1) * 0.5, (z0 + z1) * 0.5), basis, Vector3(depth, thickness, along.length() + 0.01), color, CELL_WHITE)


## The shelter's glass: the back wall and both ends (drawn with the glass material).
func _bus_shelter_glass(b: Builder) -> void:
	b.box(Vector3(0, 1.2, SHELTER_BACK_Z + 0.005), Basis.IDENTITY, Vector3(SHELTER_HALF_X * 2.0 - 0.08, 1.9, 0.012), Color.WHITE, CELL_WHITE)
	for x: float in [-SHELTER_HALF_X, SHELTER_HALF_X]:
		b.box(Vector3(x, 1.2, (SHELTER_BACK_Z + SHELTER_END_FRONT_Z) * 0.5), Basis.IDENTITY, Vector3(0.012, 1.9, SHELTER_BACK_Z - SHELTER_END_FRONT_Z - 0.08), Color.WHITE, CELL_WHITE)


## The shelter's curved translucent roof (drawn with the roof glass material).
func _bus_shelter_roof(b: Builder) -> void:
	_roof_arc(b, 0.0, SHELTER_HALF_X * 2.0 + 0.1, Color.WHITE, 0.02)


## A sign on its own square galvanised post, facing -Z: "tow_away", the banded
## tow-away sign at the owner's lot fence (0.6 x 0.92 m, its top level with the
## fence's top rail, as the Sep 2025 photos show), else a no-stopping plate.
func _post_sign(b: Builder, kind: String) -> void:
	if kind == "tow_away":
		b.box(Vector3(0, TOW_AWAY_POST_M * 0.5 - 0.15, 0), Basis.IDENTITY, Vector3(0.05, TOW_AWAY_POST_M + 0.3, 0.05), GALVANIZED, CELL_METAL)
		_pole_sign(b, Vector3(0, 1.31, -0.04), Vector3.FORWARD, Vector2(0.6, 0.92), CELL_TOW_AWAY)
		return
	b.box(Vector3(0, 0.95, 0), Basis.IDENTITY, Vector3(0.05, 2.5, 0.05), GALVANIZED, CELL_METAL)
	_pole_sign(b, Vector3(0, 1.75, -0.04), Vector3.FORWARD, Vector2(0.46, 0.6), CELL_NO_STOPPING)


## A low monument sign at a lot entrance, facing -Z: a 1.05 x 0.72 m painted
## panel (CELL_MERSEA: an original generic face for the owner lot's Mersea
## sign) between two square white posts, its foot 0.3 m up (Sep 2025 photo).
func _monument_sign(b: Builder) -> void:
	for side: float in [-1.0, 1.0]:
		b.box(Vector3(side * 0.56, 0.38, 0), Basis.IDENTITY, Vector3(0.07, 1.36, 0.07), MONUMENT_POST, CELL_WHITE)
	_pole_sign(b, Vector3(0, 0.66, -0.01), Vector3.FORWARD, Vector2(1.05, 0.72), CELL_MERSEA)


## The lot's ChargePoint bay (local X along the pad): a narrow concrete pad, two
## pale charger pedestals with dark heads (the -X one hooded in black) and
## coiled cables, rust-orange bollards with dark and white bands round the pad,
## and a grey meter box on a post at its +X end.
func _ev_charger_bay(b: Builder) -> void:
	_pad(b, Vector3.ZERO, Vector2(3.0, 0.95), 0.13)
	for entry: Array in [[-0.5, true], [0.45, false]]:
		var x := float(entry[0])
		b.box(Vector3(x, 0.15, 0), Basis.IDENTITY, Vector3(0.34, 0.04, 0.26), CHARGER_GREY * 0.8, CELL_WHITE)
		b.box(Vector3(x, 0.75, 0), Basis.IDENTITY, Vector3(0.24, 1.2, 0.2), CHARGER_GREY, CELL_WHITE)
		if bool(entry[1]):
			# A black bag over the head, sagging below it.
			b.tube(PackedVector3Array([Vector3(x, 1.0, 0), Vector3(x, 1.35, 0), Vector3(x, 1.72, 0), Vector3(x, 1.86, 0)]), PackedFloat32Array([0.22, 0.25, 0.22, 0.08]), 8, CHARGER_HEAD * 0.45, CELL_WHITE, true, true)
		else:
			b.box(Vector3(x, 1.55, 0), Basis.IDENTITY, Vector3(0.3, 0.46, 0.24), CHARGER_HEAD, CELL_WHITE)
			b.box(Vector3(x, 1.6, -0.122), Basis.IDENTITY, Vector3(0.2, 0.14, 0.006), CHARGER_SCREEN, CELL_WHITE, Rect2(), Color.WHITE, 1)
		# The holstered cable's loop down to the pad.
		b.tube(PackedVector3Array([Vector3(x + 0.12, 1.25, -0.08), Vector3(x + 0.3, 0.7, -0.25), Vector3(x + 0.2, 0.2, -0.35), Vector3(x - 0.05, 0.16, -0.3)]), PackedFloat32Array([0.02, 0.02, 0.02, 0.02]), 5, CHARGER_HEAD * 0.4, CELL_WHITE, false, false)
	# Weathered paint: each bollard faded a little differently, with road grime
	# splashed dark round its foot.
	var fades := [1.0, 0.86, 0.94, 0.8, 1.0, 0.9, 0.84, 0.96]
	var spots := [Vector2(-1.35, -0.42), Vector2(-0.95, -0.47), Vector2(-0.05, -0.47), Vector2(0.85, -0.47), Vector2(1.3, -0.42), Vector2(-1.25, 0.43), Vector2(-0.05, 0.47), Vector2(1.2, 0.43)]
	for index in spots.size():
		var spot: Vector2 = spots[index]
		var foot := Vector3(spot.x, 0.1, spot.y)
		var paint := BOLLARD_RUST * float(fades[index])
		paint.a = 1.0
		b.tube(PackedVector3Array([foot, foot + Vector3(0, 0.16, 0)]), PackedFloat32Array([0.071, 0.071]), 8, BOLLARD_GRIME, CELL_WHITE, false, false)
		b.tube(PackedVector3Array([foot + Vector3(0, 0.16, 0), foot + Vector3(0, 0.82, 0)]), PackedFloat32Array([0.07, 0.07]), 8, paint, CELL_WHITE, false, false)
		b.tube(PackedVector3Array([foot + Vector3(0, 0.82, 0), foot + Vector3(0, 0.9, 0)]), PackedFloat32Array([0.072, 0.072]), 8, BLADE_BLACK, CELL_WHITE, false, false)
		b.tube(PackedVector3Array([foot + Vector3(0, 0.9, 0), foot + Vector3(0, 0.98, 0)]), PackedFloat32Array([0.072, 0.07]), 8, BLADE_WHITE, CELL_WHITE, false, true)
	b.box(Vector3(1.75, 0.8, 0), Basis.IDENTITY, Vector3(0.06, 1.7, 0.06), GALVANIZED, CELL_METAL)
	b.box(Vector3(1.75, 1.25, -0.1), Basis.IDENTITY, Vector3(0.3, 0.42, 0.16), CONDUIT_GREY, CELL_WHITE)
	b.disc(Vector3(1.75, 1.3, -0.182), Vector3.FORWARD, 0.07, 10, LENS_GREY)


## A level concrete pad of plan size (x, z) at `at`, its top `top` above the
## prop's foot and its skirt reaching PAD_SKIRT_M below the foot (the pad of a
## settled prop rises to its highest ground; the skirt hides the low side).
func _pad(b: Builder, at: Vector3, size: Vector2, top: float) -> void:
	b.box(at + Vector3(0, (top - PAD_SKIRT_M) * 0.5, 0), Basis.IDENTITY, Vector3(size.x, top + PAD_SKIRT_M, size.y), PAD_CONCRETE, CELL_WHITE)


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

	## A slab: the convex `outline` (local XY around `center`, either winding)
	## extruded by `thickness` along local Z, the edges of both faces bevelled by
	## `bevel` with normals smoothed across the bevels and round the outline, so
	## it reads as moulded with softened edges. Round the outline's corners
	## (Builder.rounded) so its sides shade smoothly too. One flat colour.
	func slab(center: Vector3, basis: Basis, outline: PackedVector2Array, thickness: float, bevel: float, color: Color, surface := 0) -> void:
		var points := PackedVector2Array()
		for point in outline:
			if points.is_empty() or point.distance_to(points[points.size() - 1]) > 1e-5:
				points.append(point)
		if points.size() > 3 and points[0].distance_to(points[points.size() - 1]) <= 1e-5:
			points.remove_at(points.size() - 1)
		var count := points.size()
		var area := 0.0
		for index in count:
			area += points[index].cross(points[(index + 1) % count])
		if area < 0.0:
			points.reverse()
		var half := thickness * 0.5
		var depth := minf(bevel, half * 0.9)
		# Outward normal of the outline at each point, and the point moved in by
		# the bevel (the edge of a face).
		var normals := PackedVector2Array()
		var insets := PackedVector2Array()
		for index in count:
			var before := _edge_normal(points[(index + count - 1) % count], points[index])
			var after := _edge_normal(points[index], points[(index + 1) % count])
			var normal := (before + after).normalized()
			normals.append(normal)
			insets.append(points[index] - normal * depth / maxf(normal.dot(after), 0.3))
		var middle := _white.get_center()
		# Rings round the slab: the front face's edge, the side's two edges, the back face's edge.
		var rings: Array[PackedInt32Array] = []
		for spec: Array in [[insets, half, 1.0], [points, half - depth, 0.0], [points, depth - half, 0.0], [insets, -half, -1.0]]:
			var ring_points: PackedVector2Array = spec[0]
			var z := float(spec[1])
			var face := float(spec[2])
			var ring := PackedInt32Array()
			for index in count:
				var local_normal := Vector3(0.0, 0.0, face) if face != 0.0 else Vector3(normals[index].x, normals[index].y, 0.0)
				var point := ring_points[index]
				ring.append(vertex(surface, center + basis * Vector3(point.x, point.y, z), (basis * local_normal).normalized(), middle, color))
			rings.append(ring)
		var arrays: Dictionary = _surfaces[surface]
		for ring_index in 3:
			var near_ring := rings[ring_index]
			var far_ring := rings[ring_index + 1]
			for index in count:
				var next := (index + 1) % count
				var outward: Vector3 = arrays.normals[near_ring[index]] + arrays.normals[near_ring[next]] + arrays.normals[far_ring[index]] + arrays.normals[far_ring[next]]
				triangle(surface, near_ring[index], near_ring[next], far_ring[next], outward)
				triangle(surface, near_ring[index], far_ring[next], far_ring[index], outward)
		for cap: Array in [[rings[0], basis.z], [rings[3], -basis.z]]:
			var ring: PackedInt32Array = cap[0]
			for index in range(1, count - 1):
				triangle(surface, ring[0], ring[index], ring[index + 1], cap[1])

	## The convex polygon `points` with each corner rounded by an arc of
	## radii[i] (or radii[0] at every corner) in `segments` steps, smaller where
	## an edge is too short for it; nearly straight corners stay as they are.
	static func rounded(points: PackedVector2Array, radii: Array, segments: int) -> PackedVector2Array:
		var count := points.size()
		var result := PackedVector2Array()
		for index in count:
			var here := points[index]
			var to_before := points[(index + count - 1) % count] - here
			var to_after := points[(index + 1) % count] - here
			var radius := float(radii[index] if radii.size() == count else radii[0])
			var angle := acos(clampf(to_before.normalized().dot(to_after.normalized()), -1.0, 1.0))
			if radius <= 0.0 or angle > deg_to_rad(170.0):
				result.append(here)
				continue
			var tangent := radius / tan(angle * 0.5)
			var limit := 0.45 * minf(to_before.length(), to_after.length())
			if tangent > limit:
				radius *= limit / tangent
				tangent = limit
			var centre := here + (to_before.normalized() + to_after.normalized()).normalized() * radius / sin(angle * 0.5)
			var start := (here + to_before.normalized() * tangent - centre).angle()
			var sweep := wrapf((here + to_after.normalized() * tangent - centre).angle() - start, -PI, PI)
			for step in segments + 1:
				result.append(centre + Vector2.from_angle(start + sweep * float(step) / float(segments)) * radius)
		return result

	## The outward normal of an edge of a counter-clockwise outline.
	static func _edge_normal(from: Vector2, to: Vector2) -> Vector2:
		var direction := (to - from).normalized()
		return Vector2(direction.y, -direction.x)

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

	## A copy of one surface's vertex positions so far.
	func vertices(surface: int) -> PackedVector3Array:
		return (_surfaces[surface].vertices as PackedVector3Array).duplicate()

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
