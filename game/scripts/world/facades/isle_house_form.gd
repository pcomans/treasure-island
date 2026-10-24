extends RefCounted

## Isle House form (2026-10-23 form-first rebuild from the Sep 2025 Street View, the
## May 2025 Commons crown and the DBA photos and Level 1/7 plans).
##
## Both wall records of w1249412094 are replaced by geometry whose receivers follow
## the visible form, so walls, spray and walk-up agree:
## - high w1282547786: a recessed double-height storefront under a soffit with
##   concrete columns; a brick podium at the footprint line with angled projecting
##   bay boxes; a recessed glazed level-7 band; then two tower volumes split by
##   full-height glazed slots (SE face, NW face), their faces folded into a sawtooth
##   (tips on the footprint line, valleys inside) and flared outward over the band
##   on a zigzag soffit; a crown with penthouse and guardrail.
## - low w1282547787: the WSW and ENE fronts with projecting bays over the base,
##   the WSW storefront recessed under a soffit; the NNW face flat with a recessed
##   entry, its west volume rising to the level-7 deck.
## Heights, depths, counts and cadence are production inference scaled from those
## photos, not surveyed. Added opaque solids collide on the spray layer with
## receiver_kind none; the receiver faces stay on the record's own body.

const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_2.json"
const LOW_WALL_KEY := "building-composite:w1249412094:w1282547787:wall"
const HIGH_WALL_KEY := "building-composite:w1249412094:w1282547786:wall"
const LOW_ROOF_KEY := "building-composite:w1249412094:w1282547787:roof"
const LOW_SOURCE_KEY := "w1282547787"
const HIGH_SOURCE_KEY := "w1282547786"
const LOW_TOP_Y := 19.103
const HIGH_TOP_Y := 71.103
# ROOT height override (2026-10-22): the tower rises to 75m on its frozen footprint,
# above the record's 71.103m top; its receiver walls deliberately run to this height.
const TOWER_TOP_Y := 79.1
const BASE_BOTTOM_Y := 3.8
const BASE_TOP_Y := 10.25
# Shared base bands (ih01, ih08, ih18, dba-64): the storefront mezzanine transom, the
# podium storefront transom bar and its upper glass, the louvre band under the soffit,
# the live-work louvred mezzanine band, the leasing canopy, the Garden Walk low wall
# and the garage door head. Production inference.
const TRANSOM_Y := 7.25
const STORE_TRANSOM_BOTTOM_Y := 7.15
const STORE_TRANSOM_TOP_Y := 7.35
const LOUVRE_BOTTOM_Y := 9.35
const MEZZANINE_BOTTOM_Y := 6.75
const MEZZANINE_TOP_Y := 7.45
const CANOPY_Y := 7.15
const GARDEN_WALL_TOP_Y := 5.0
const GARAGE_HEAD_Y := 7.1
const SILL_WALL_H := 0.45
const DOOR_H := 2.65
# Storey counts from the rectified 2025 photos (ih01/ih04 WSW, ih17/ih06 NNW, ih08 SE,
# ih14 ENE): four storeys over the double-height base to the level-7 deck (WSW, west
# podium, tall NNW volume) and two over it for the east volumes (NNW east, ENE, east
# podium), whose roof replaces the generated 15 m one. Production inference.
const STOREY_M := 2.97
const DECK_Y := BASE_TOP_Y + 4.0 * STOREY_M
const LOW_ROOF_Y := BASE_TOP_Y + 2.0 * STOREY_M
const TOWER_FLOOR_M := 2.95
const BAND_M := 3.3
const BASE_RECESS := 1.0
const BAND_INSET := 1.0
# Compact folded edge at the tower foot (ih09, ih14, ih18, dba-49/50): the folds
# kick out FLARE_OUT over the lowest FLARE_H, tapering to nothing at the slots and
# with the corner mitre capped, over a zigzag soffit back to the band.
const FLARE_OUT := 0.45
const FLARE_H := 1.2
const CORNER_MITER_MAX := 1.3
const SAW_PITCH := 4.0
const SAW_DEPTH := 0.6
const SAW_WIDE := 0.7
# Narrow glazed slots: dba-50/52 and ih21 read a thin dark joint, not a wide recess.
const SLOT_W := 2.0
const SLOT_D := 1.0
# ih08/ih09 shared corners and dba-50 put the slot centre about 24.5 m from c2.
const SE_SLOT_U := 23.5
# SE podium joint (ih08, ih09, dba-50): a broader recessed glazed bay between the two
# podium masses, from the ground to the podium tops, separate from the narrow tower
# slot above it; its recessed plane continues the storefront glazing (production
# inference from the shared corners: the masses end about 23.2 m and 27.6 m from c2).
const SE_JOINT_U0 := 23.2
const SE_JOINT_U1 := 27.6
const COLUMN_W := 0.7
const BAY_D := 0.9
const BAY_CHEEK := 0.8
# Low fronts: 6.4m module (the base column bay); WSW tall strip and NNW wing.
const MODULE_M := 6.4
const PIER_START := 0.6
const WING_DEPTH := 14.0
const NNW_TALL_M := 24.0
const NNW_WING_S := 12.0
const ENTRY_W := 4.0
# WSW stack starts and garage door (rectified ih01/ih02/ih04, u from the NW corner).
const WSW_STACKS := [11.5, 23.0, 34.5]
const WSW_GARAGE := [32.6, 36.4]
const WSW_FLAT_LIGHTS := [[4.9, 7.2], [8.6, 10.9], [16.4, 18.7], [20.2, 22.5], [27.9, 30.2], [31.7, 34.0],
	[39.6, 41.9], [44.0, 46.3], [48.4, 50.7]]
# NNW slim lights (rectified ih17, u from the NE corner): east volume and tall volume.
const NNW_EAST_LIGHTS := [[0.3, 1.5], [3.5, 4.1], [7.3, 8.5], [11.3, 12.5], [15.3, 16.5], [17.6, 19.0]]
const NNW_TALL_LIGHTS := [[22.3, 24.3], [27.0, 28.1], [32.9, 34.0], [38.3, 38.9], [41.5, 42.5]]
# Podium base panels per tower face: charcoal patterned brick [u0, u1, door u0, door u1]
# (ih18 SW pair flanking a door; ih08 SE panel with a service door), and the SE leasing
# storefront (ih08, ih14). Production inference from the rectified photos.
const PODIUM_PANELS := {1: [[3.3, 4.9], [6.5, 8.1]], 2: [[28.2, 31.0, 29.5, 30.4]]}
const PODIUM_DOORS := {1: [[5.15, 6.25]]}
const SE_LEASING := [31.4, 42.0]
const NNW_BASE_OPENINGS := [[9.7, 10.6], [11.6, 12.5], [15.4, 16.4], [19.2, 20.8], [38.2, 40.2], [41.2, 42.6]]
const ENTRY_D := 1.5
# Shared grid helpers (floor lines, stacked openings, cut lines).
const FACADE_GRID := preload("res://game/scripts/world/facades/facade_grid.gd")
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1
enum Body { RECEIVER, SOLID, VISUAL }

# Stage B base colours as a recognition aid (no textures): white panels, light
# speckled-grey brick, charcoal base, black frames, tinted glass, concrete.
# [albedo, roughness, metallic]
const COLOURS := {
	"wall": [Color(0.90, 0.90, 0.88), 0.8, 0.0],
	"brick": [Color(0.68, 0.69, 0.70), 0.97, 0.0],
	"tower_grey": [Color(0.76, 0.76, 0.74), 0.8, 0.0],
	"dark": [Color(0.30, 0.30, 0.31), 0.97, 0.0],
	"concrete": [Color(0.60, 0.60, 0.58), 0.95, 0.0],
	# Glass families. A metallic material tints its reflection by its albedo, so the
	# earlier dark metallic glass reflected a dark sky at street angles (c10 review).
	# Upper glass: light albedo, high metallic, smooth, so it mirrors the bright sky
	# (grey-green; blue on the Avenue of the Palms face, ih01-ih04). Lower storefront
	# glass: dark dielectric, so it reads dark with only a Fresnel sheen (ih08, ih18).
	"glass": [Color(0.55, 0.62, 0.63), 0.05, 0.8],
	"glass_blue": [Color(0.50, 0.60, 0.74), 0.05, 0.8],
	"glass_store": [Color(0.09, 0.11, 0.11), 0.05, 0.0],
	"frame": [Color(0.07, 0.07, 0.08), 0.6, 0.0],
	"spandrel": [Color(0.15, 0.16, 0.18), 0.5, 0.2],
	"panel": [Color(0.83, 0.84, 0.84), 0.85, 0.0],
	"band": [Color(0.96, 0.96, 0.95), 0.8, 0.0],
	"metal": [Color(0.70, 0.71, 0.72), 0.5, 0.5],
	"joint": [Color(0.66, 0.67, 0.68), 0.8, 0.0],
	"trim": [Color(0.88, 0.88, 0.86), 0.85, 0.0],
	"roof": [Color(0.60, 0.60, 0.58), 0.95, 0.0],
}
const WINDOW_DEPTH := 0.15
const FRAME_W := 0.07
# Stacked openings per storey (rectified 2025 photos; production inference): low block
# and podium lights from 0.35 to 2.6 m above each floor line, NNW slim lights 0.3-2.65,
# tower strips 1.9 m wide from 0.15 to 2.8 above each 2.95 m tower floor (ih14, ih19,
# ih21: near-continuous dark vertical stacks with thin spandrels).
const SILL := 0.35
const HEAD := 2.6
static var _materials := {}

var _walls := {}
var _roofs := {}
var _receiver := PackedVector3Array()
var _solid := PackedVector3Array()


static func matches_low_record(record: Dictionary) -> bool:
	return _matches(record, LOW_WALL_KEY, LOW_SOURCE_KEY, LOW_TOP_Y)


static func matches_high_record(record: Dictionary) -> bool:
	return _matches(record, HIGH_WALL_KEY, HIGH_SOURCE_KEY, HIGH_TOP_Y)


static func _matches(record: Dictionary, key: String, source: String, top: float) -> bool:
	return str(record.get("object_key", "")) == key \
		and record.get("source_keys", []) == [source] \
		and str(record.get("feature_kind", "")) == "building_part_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and is_equal_approx(float(record.get("top_elevation_m", 0.0)), top) \
		and (record.get("vertices", []) as Array).size() == 156 \
		and (record.get("normals", []) as Array).size() == 156


# The generated low roof (15 m) at the photographed two-storey height instead.
static func matches_low_roof_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == LOW_ROOF_KEY \
		and record.get("source_keys", []) == [LOW_SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_part_roof" \
		and str(record.get("receiver_kind", "")) == "none" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false)) \
		and is_equal_approx(float(record.get("top_elevation_m", 0.0)), LOW_TOP_Y) \
		and (record.get("vertices", []) as Array).size() == 18


# A fresh instance of this script (static entry points build through instance state).
static func _builder() -> RefCounted:
	return (load("res://game/scripts/world/facades/isle_house_form.gd") as GDScript).new()


static func build_low_roof_record(record: Dictionary) -> Dictionary:
	if not matches_low_roof_record(record):
		return {"ok": false, "code": "isle_house_low_roof_target", "message": "Isle House low roof refused a non-target record.", "source_keys": (record.get("source_keys", []) as Array).duplicate()}
	var builder := _builder()
	var raw: Array = record.vertices
	var outline: Array[Vector3] = []
	for i in range(0, raw.size(), 3):
		outline.append(Vector3(float(raw[i]), 0.0, float(raw[i + 2])))
	var error: String = builder._flat_roof(outline, LOW_ROOF_Y, "roof", Body.RECEIVER)
	if error != "":
		return {"ok": false, "code": "isle_house_low_roof", "message": error, "source_keys": [LOW_SOURCE_KEY]}
	return builder._emit(record, "IsleHouseLowRoof")


static func build_low_record(record: Dictionary) -> Dictionary:
	if not matches_low_record(record):
		return {"ok": false, "code": "isle_house_low_receiver_target", "message": "Isle House low receiver refused a non-target record.", "source_keys": (record.get("source_keys", []) as Array).duplicate()}
	var builder := _builder()
	builder._build_low(record)
	return builder._emit(record, "IsleHouseLowForm")


static func build_high_record(record: Dictionary) -> Dictionary:
	if not matches_high_record(record):
		return {"ok": false, "code": "isle_house_high_receiver_target", "message": "Isle House high receiver refused a non-target record.", "source_keys": (record.get("source_keys", []) as Array).duplicate()}
	var chunk: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNK_PATH))
	if not chunk is Dictionary:
		return {"ok": false, "code": "isle_house_high_chunk", "message": "Isle House form could not read its chunk.", "source_keys": [HIGH_SOURCE_KEY]}
	var low := _record(chunk.records, LOW_WALL_KEY)
	if not matches_low_record(low):
		return {"ok": false, "code": "isle_house_high_chunk", "message": "Isle House low record did not match.", "source_keys": [HIGH_SOURCE_KEY]}
	var builder := _builder()
	var error: String = builder._build_high(record, low)
	if error != "":
		return {"ok": false, "code": "isle_house_high_form", "message": error, "source_keys": [HIGH_SOURCE_KEY]}
	return builder._emit(record, "IsleHouseHighForm")


# ---------------------------------------------------------------- low block

func _build_low(low: Dictionary) -> void:
	var wsw := _side(low, 0, 4)
	var ene := _side(low, 5, 9)
	var nnw := _side(low, 10, 12)
	var floors2 := FACADE_GRID.floor_lines(BASE_TOP_Y, 2, STOREY_M)
	var floors4 := FACADE_GRID.floor_lines(BASE_TOP_Y, 4, STOREY_M)
	# WSW, Avenue of the Palms (rectified ih01/ih02/ih04): base recessed under a
	# soffit behind alternating concrete columns and charcoal piers about 3.85 m apart;
	# a brick NW corner bay; three projecting white stacks 11.5 m apart, each an angled
	# north cheek with a slim light and a front with one light per storey; between
	# them white panel planes with two 2.3 m lights per storey.
	var length: float = wsw.length
	var wsw_line := _side_plane(wsw, 0.0)
	var wsw_base := _side_plane(wsw, -BASE_RECESS)
	_wall(wsw, 0.0, PIER_START, BASE_BOTTOM_Y, BASE_TOP_Y, "brick", Body.RECEIVER)
	_wall(wsw, PIER_START, length, BASE_BOTTOM_Y, BASE_TOP_Y, "glass_store", Body.RECEIVER, -BASE_RECESS)
	# Live-work bays between the piers (ih01, ih02, dba-6): continuous mullions, a dark
	# louvred mezzanine band, a low concrete sill and a door in alternate bays; the
	# garage bay takes the roll-up door instead.
	_return(wsw, PIER_START, 0.0, -BASE_RECESS, BASE_BOTTOM_Y, BASE_TOP_Y, 1.0, "brick", Body.RECEIVER)
	_cap(wsw, PIER_START, length, 0.0, -BASE_RECESS, BASE_TOP_Y, false, "trim", Body.SOLID)
	# Silver roll-up garage door (ih01): a distinct opening in a dark frame, slatted,
	# with a dark header up to the soffit instead of storefront glazing.
	var g0: float = WSW_GARAGE[0]
	var g1: float = WSW_GARAGE[1]
	_strip(wsw_base, g0 - 0.25, g1 + 0.25, BASE_BOTTOM_Y, BASE_TOP_Y, "dark", 0.02)
	_strip(wsw_base, g0, g1, BASE_BOTTOM_Y, GARAGE_HEAD_Y, "metal", 0.04)
	for k in range(1, 16):
		var y := BASE_BOTTOM_Y + (GARAGE_HEAD_Y - BASE_BOTTOM_Y) * float(k) / 16.0
		_strip(wsw_base, g0, g1, y - 0.015, y + 0.015, "joint", 0.05)
	# Upper floors. Flat fields (ih01, ih04): grey-white panel field, two large
	# lights per bay with an asymmetric mullion and a low transom, and a narrow
	# white floor band at every floor line. Stacks: white projecting surrounds
	# around one continuous dark glazing/spandrel stack per front and cheek.
	var flat_style := {"split": 0.42, "transom": 0.55, "pane": "glass_blue"}
	var wsw_openings := FACADE_GRID.stacks(WSW_FLAT_LIGHTS, floors4, [], 0.2, 2.75, flat_style)
	var corner_openings := FACADE_GRID.stacks([[1.0, 3.3]], floors4, [], 0.2, 2.75, flat_style)
	_punched(wsw_line, 0.0, 4.2, BASE_TOP_Y, LOW_ROOF_Y, corner_openings, "brick", Body.RECEIVER)
	_punched(wsw_line, 0.0, 4.2, LOW_ROOF_Y, DECK_Y, corner_openings, "brick", Body.RECEIVER)
	_punched(wsw_line, 4.2, length, BASE_TOP_Y, LOW_ROOF_Y, wsw_openings, "panel", Body.RECEIVER)
	_punched(wsw_line, 4.2, length, LOW_ROOF_Y, DECK_Y, wsw_openings, "panel", Body.RECEIVER)
	for floor: float in floors4 + [DECK_Y]:
		_strip(wsw_line, 4.2, length, floor - 0.12, floor + 0.12, "band", 0.05)
	var stack_style := {"split": 0.0, "transom": 0.6, "pane": "glass_blue"}
	for s: float in WSW_STACKS:
		_bay(wsw, s + 1.2 + 1.55, 3.1, 1.2, 0.0, 0.8, BASE_TOP_Y, DECK_Y + 0.5, "wall",
			FACADE_GRID.stacks([[s + 1.55, s + 3.65]], floors4, [[0, 3]], 0.2, 2.75, stack_style), [[0.3, 0.95]], floors4, [[0, 3]], stack_style)
	var pier := false
	var u := 4.2
	var bay_index := 0
	var last := PIER_START
	while u < length - 0.8:
		var half := 0.55 if pier else COLUMN_W * 0.5
		if u > PIER_START + 0.8 and (u < g0 - 0.4 or u > g1 + 0.4):
			_column(wsw, u, BASE_BOTTOM_Y, BASE_TOP_Y, "dark" if pier else "concrete", half * 2.0)
		_live_work_bay(wsw_base, last, u - half, bay_index % 2 == 0, [[g0 - 0.25, g1 + 0.25]])
		last = u + half
		pier = not pier
		bay_index += 1
		u += 3.85
	_live_work_bay(wsw_base, last, length, false, [])
	# ENE, Garden Walk (dba-64, dba-4): live-work glazing at the line between charcoal
	# piers; projecting white boxes over the two upper storeys, one wide light per
	# storey in each box, a slim light between boxes.
	var ene_line := _side_plane(ene, 0.0)
	_wall(ene, 0.0, ene.length, BASE_BOTTOM_Y, BASE_TOP_Y, "glass_store", Body.RECEIVER)
	var ene_modules := _modules(ene.length, 0.0)
	var ene_slims := []
	# Live-work bays (dba-64, dba-4, dba-7): a charcoal patterned-brick pier, a bay with
	# a door, louvred mezzanine band and concrete sill, and a narrow glazed bay.
	var ene_runs := _runs_between(0.0, ene.length, ene_modules.map(func(m: float) -> Array: return [m + 4.1, m + 5.1]))
	for run: Array in ene_runs:
		_garden_walk_bay(ene_line, run[0], run[1], float(run[1]) - float(run[0]) > 3.0)
	for u0: float in ene_modules:
		ene_slims.append([u0 + 4.75, u0 + 5.65])
		_strip(ene_line, u0 + 4.1, u0 + 5.1, BASE_BOTTOM_Y, BASE_TOP_Y, "dark", 0.05)
	var ene_style := {"split": 0.5, "transom": 0.0, "surround": true}
	_punched(ene_line, 0.0, ene.length, BASE_TOP_Y, LOW_ROOF_Y, FACADE_GRID.stacks(ene_slims, floors2, [[0, 1]], 0.2, 2.75, ene_style), "wall", Body.RECEIVER)
	for u0: float in ene_modules:
		_bay(ene, u0 + 2.0, 3.1, 0.45, 0.45, 0.75, BASE_TOP_Y, LOW_ROOF_Y + 0.3, "wall", FACADE_GRID.stacks([[u0 + 0.75, u0 + 3.25]], floors2, [[0, 1]], 0.2, 2.75, ene_style))
	_coping(ene, 0.0, ene.length, LOW_ROOF_Y)
	# NNW (rectified ih17, ih06): light brick with slim dark-framed lights stacked
	# per storey over a charcoal base; the east volume two storeys, the west NNW_TALL_M
	# four storeys to the deck; a recessed double-height entry in the tall base.
	var nnw_line := _side_plane(nnw, 0.0)
	var step: float = float(nnw.length) - NNW_TALL_M
	var e0: float = float(nnw.length) - 14.0
	var e1 := e0 + ENTRY_W
	# Base (rectified ih17, ih06): a glazed storefront at the east end, light brick
	# fields with tall recessed openings under the window columns, charcoal panels
	# with doors around the entry, concrete pilasters at the changes.
	var nnw_base_openings := []
	for o: Array in NNW_BASE_OPENINGS:
		nnw_base_openings.append([o[0], o[1], BASE_BOTTOM_Y, 9.5, {"split": 0.0, "transom": 0.0, "sills": [BASE_BOTTOM_Y], "surround": true, "pane": "dark"}])
	_wall(nnw, 0.0, 9.0, BASE_BOTTOM_Y, BASE_TOP_Y, "glass_store", Body.RECEIVER)
	_mullions(nnw_line, 0.0, 9.0, BASE_BOTTOM_Y, BASE_TOP_Y, 1.5, TRANSOM_Y)
	_punched(nnw_line, 9.0, 24.0, BASE_BOTTOM_Y, BASE_TOP_Y, nnw_base_openings, "brick", Body.RECEIVER)
	_wall(nnw, 24.0, e0, BASE_BOTTOM_Y, BASE_TOP_Y, "dark", Body.RECEIVER)
	_wall(nnw, e1, 37.0, BASE_BOTTOM_Y, BASE_TOP_Y, "dark", Body.RECEIVER)
	_punched(nnw_line, 37.0, nnw.length, BASE_BOTTOM_Y, BASE_TOP_Y, nnw_base_openings, "brick", Body.RECEIVER)
	for door: Array in [[25.4, 26.5], [35.2, 36.3]]:
		_strip(nnw_line, door[0], door[1], BASE_BOTTOM_Y, 6.6, "frame", 0.03)
	for pilaster: float in [9.0, 24.0, 37.0]:
		_strip(nnw_line, pilaster - 0.35, pilaster + 0.35, BASE_BOTTOM_Y, BASE_TOP_Y, "concrete", 0.04)
	_wall(nnw, e0, e1, BASE_BOTTOM_Y, BASE_TOP_Y, "glass_store", Body.RECEIVER, -ENTRY_D)
	_mullions(_side_plane(nnw, -ENTRY_D), e0, e1, BASE_BOTTOM_Y, BASE_TOP_Y, 1.0, TRANSOM_Y)
	_return(nnw, e0, 0.0, -ENTRY_D, BASE_BOTTOM_Y, BASE_TOP_Y, 1.0, "dark", Body.RECEIVER)
	_return(nnw, e1, 0.0, -ENTRY_D, BASE_BOTTOM_Y, BASE_TOP_Y, -1.0, "dark", Body.RECEIVER)
	_cap(nnw, e0, e1, 0.0, -ENTRY_D, BASE_TOP_Y, false, "trim", Body.SOLID)
	# Tall dark-framed groups joining the middle floors (ih06, ih17), subdivided.
	var nnw_style := {"split": 0.4, "transom": 0.6, "surround": true}
	var nnw_openings := FACADE_GRID.stacks(NNW_EAST_LIGHTS, floors2, [], 0.3, 2.65, nnw_style)
	nnw_openings.append_array(FACADE_GRID.stacks(NNW_TALL_LIGHTS, floors4, [[0, 0], [1, 2], [3, 3]], 0.3, 2.65, nnw_style))
	_punched(nnw_line, 0.0, nnw.length, BASE_TOP_Y, LOW_ROOF_Y, nnw_openings, "brick", Body.RECEIVER)
	_punched(nnw_line, step - 0.03, nnw.length, LOW_ROOF_Y, DECK_Y, nnw_openings, "brick", Body.RECEIVER)
	_coping(nnw, 0.0, step, LOW_ROOF_Y)


# Module starts over [from_u, length], centred.
static func _modules(length: float, from_u: float) -> Array[float]:
	var count := int(floor((length - from_u) / MODULE_M))
	var first := from_u + (length - from_u - MODULE_M * float(count)) * 0.5
	var starts: Array[float] = []
	for index in count:
		starts.append(first + MODULE_M * float(index))
	return starts


# ---------------------------------------------------------------- high part

var _corners: Array[Vector3] = []
var _miters: Array[Vector3] = []
var _faces: Array[Dictionary] = []


func _build_high(high: Dictionary, low: Dictionary) -> String:
	# Tower corners c0..c6 (starts of runs 0, 3, 5, 8, 10, 11, 12) and faces
	# f0 WSW, f1 SW, f2 SE, f3 ENE, f4 NNE, f5 NW, f6 short NNW return.
	var starts := [0, 3, 5, 8, 10, 11, 12]
	var normals := [1, 3, 5, 9, 10, 11, 12]
	for i in 7:
		_corners.append(_flat(_run_point(high, starts[i], false)))
	for i in 7:
		var p := _corners[i]
		var q := _corners[(i + 1) % 7]
		var n := _run_normal(high, normals[i])
		_faces.append({"origin": p, "t": (q - p).normalized(), "n": n, "length": p.distance_to(q)})
	for i in 7:
		var na: Vector3 = _faces[(i + 6) % 7].n
		var nb: Vector3 = _faces[i].n
		_miters.append((na + nb) / (1.0 + na.dot(nb)))
	# Where the level-7 deck (WING_DEPTH from the WSW line) meets the NW face.
	var a := _flat(_run_point(low, 0, false))
	var wsw_n := _run_normal(low, 0)
	var ra := (_corners[6] - a).dot(-wsw_n)
	var rb := (_corners[5] - a).dot(-wsw_n)
	var meet := _corners[6].lerp(_corners[5], (WING_DEPTH - ra) / (rb - ra))
	var meet_u := meet.distance_to(_corners[5])
	var f2_length: float = _faces[2].length
	var f5_length: float = _faces[5].length
	var west_tb := DECK_Y + BAND_M
	var east_tb := LOW_ROOF_Y + BAND_M
	# West volume on the six-storey podium, east volume on the three-storey podium.
	var segments: Array[Dictionary] = [
		_segment(0, 0.0, _faces[0].length, true, DECK_Y, west_tb, true, "corner", "corner", [[8.5, 6.0]], [],
			{"flat": [[1.0, 4.0], [13.6, 14.6], [15.6, 16.4]], "fronts": [[6.0, 7.0], [9.6, 11.2]]}),
		_segment(1, 0.0, _faces[1].length, true, DECK_Y, west_tb, true, "corner", "corner", [[5.68, 5.0]], [],
			{"flat": [[0.4, 1.4], [9.6, 10.6]], "fronts": [[4.0, 5.0], [6.4, 7.9]]}),
		_segment(2, 0.0, SE_SLOT_U, true, DECK_Y, west_tb, true, "corner", "slot", [[6.5, 4.5], [16.0, 4.5]], [0.0, SE_JOINT_U0],
			{"flat": [[0.8, 1.8], [10.9, 12.0], [19.7, 21.5], [21.9, 22.8]], "fronts": [[5.0, 6.8], [7.4, 8.4], [14.1, 15.9], [16.6, 17.6]]}),
		_segment(2, SE_SLOT_U + SLOT_W, f2_length, true, LOW_ROOF_Y, east_tb, true, "slot", "corner", [[32.4, 6.0]], [SE_JOINT_U1, f2_length],
			{"flat": [[36.6, 38.4], [39.4, 40.4]], "fronts": [[30.2, 32.0], [32.8, 33.8]]}),
		_segment(3, 0.0, _faces[3].length, true, LOW_ROOF_Y, east_tb, false, "corner", "corner", [], [],
			{"flat": [[3.2, 5.0], [6.5, 7.7], [10.2, 11.3]], "slots": [[3.0, 3.8], [7.8, 8.6], [11.4, 12.2]]}),
		_segment(4, 0.0, _faces[4].length, false, LOW_ROOF_Y, east_tb, true, "corner", "corner", []),
		_segment(5, 0.0, meet_u - SLOT_W, false, LOW_ROOF_Y, east_tb, true, "corner", "slot", []),
		_segment(5, meet_u, f5_length, false, DECK_Y, west_tb, true, "slot", "corner", []),
		_segment(6, 0.0, _faces[6].length, false, DECK_Y, west_tb, false, "corner", "corner", [], [], {"slots": [[1.3, 2.1]]}),
	]
	_tower_base()
	for segment in segments:
		_tower_segment(segment)
	# Glazed slots: SE from the base soffit, NW from the low roof.
	_slot(2, SE_SLOT_U, BASE_TOP_Y, false)
	_slot(5, meet_u - SLOT_W, LOW_ROOF_Y, true)
	_se_joint()
	var outline := _roof_outline(segments, meet_u)
	var error := _flat_roof(outline, TOWER_TOP_Y, "roof")
	if error != "":
		return error
	error = _crown(outline, segments)
	if error != "":
		return error
	return _deck(low, meet)


# `podium` trims the podium mass (wall and ledge) to [u0, u1] where a recess
# cuts it back from the tower segment's own ends.
# `windows`: podium lights "flat" (on the wall) and "fronts" (on bay fronts) as [u0, u1]
# in the face's u (rectified ih08/ih14/ih18), and "slots" for a flat tower face.
func _segment(face: int, u0: float, u1: float, ground: bool, podium_top: float, tower_bottom: float, saw: bool, start: String, finish: String, bays: Array, podium: Array = [], windows: Dictionary = {}) -> Dictionary:
	var podium_range := podium if not podium.is_empty() else [u0, u1]
	return {"face": face, "u0": u0, "u1": u1, "ground": ground, "p": podium_top, "tb": tower_bottom, "saw": saw, "start": start, "end": finish, "bays": bays,
		"pod_u0": float(podium_range[0]), "pod_u1": float(podium_range[1]), "windows": windows}


# Podium end point: the segment end unless the podium is trimmed there.
func _podium_end(segment: Dictionary, at_start: bool, out: float) -> Vector3:
	var u: float = segment.pod_u0 if at_start else segment.pod_u1
	if is_equal_approx(u, float(segment.u0 if at_start else segment.u1)):
		return _end(segment, at_start, out)
	return _at_side(_faces[segment.face], u, out)


func _podium_trimmed(segment: Dictionary, at_start: bool) -> bool:
	return not is_equal_approx(float(segment.pod_u0 if at_start else segment.pod_u1), float(segment.u0 if at_start else segment.u1))


# (u, depth) points of a segment's plan: an asymmetric sawtooth (a wide facet
# folding SAW_DEPTH in, a narrow one back out) or a straight line.
func _saw(segment: Dictionary) -> Array[Vector2]:
	var u0: float = segment.u0
	var u1: float = segment.u1
	var points: Array[Vector2] = [Vector2(u0, 0.0)]
	if bool(segment.saw):
		var count := maxi(roundi((u1 - u0) / SAW_PITCH), 1)
		var pitch := (u1 - u0) / float(count)
		for index in count:
			if index > 0:
				points.append(Vector2(u0 + pitch * float(index), 0.0))
			points.append(Vector2(u0 + pitch * (float(index) + SAW_WIDE), SAW_DEPTH))
	points.append(Vector2(u1, 0.0))
	return points


# A segment end pushed `out` along the outward normal: mitred at a tower corner,
# straight at a slot edge.
func _end(segment: Dictionary, at_start: bool, out: float) -> Vector3:
	var face: int = segment.face
	if str(segment.start if at_start else segment.end) == "corner":
		var index := face if at_start else (face + 1) % 7
		var offset := _miters[index] * out
		if out > 0.0 and offset.length() > out * CORNER_MITER_MAX:
			offset = offset.normalized() * out * CORNER_MITER_MAX
		return _corners[index] + offset
	return _at_side(_faces[face], float(segment.u0 if at_start else segment.u1), minf(out, 0.0))


# The segment's sawtooth line pushed `out` (valleys SAW_DEPTH further in).
func _saw_line(segment: Dictionary, out: float, flat: bool = false) -> Array[Vector3]:
	var plan := _saw(segment)
	var line: Array[Vector3] = []
	for j in plan.size():
		if j == 0:
			line.append(_end(segment, true, out))
		elif j == plan.size() - 1:
			line.append(_end(segment, false, out))
		else:
			line.append(_at_side(_faces[segment.face], plan[j].x, out - (0.0 if flat else plan[j].y)))
	return line


func _tower_segment(segment: Dictionary) -> void:
	var side: Dictionary = _faces[segment.face]
	var n: Vector3 = side.n
	var p: float = segment.p
	var tb: float = segment.tb
	# Podium storeys at the line, with angled projecting bay boxes (ih18, ih09).
	var windows: Dictionary = segment.windows
	if bool(segment.ground):
		# Podium window assemblies (ih08, ih09, ih10, ih18): strong black surrounds,
		# asymmetric subdivisions, and the middle floors joined into tall groups.
		var floors := FACADE_GRID.floor_lines(BASE_TOP_Y, roundi((p - BASE_TOP_Y) / STOREY_M), STOREY_M)
		var groups := [[0, 0], [1, 2], [3, 3]] if floors.size() == 4 else []
		var style := {"split": 0.36, "transom": 0.6, "surround": true}
		_punched(_side_plane(side, 0.0), segment.pod_u0, segment.pod_u1, BASE_TOP_Y, p, FACADE_GRID.stacks(windows.get("flat", []), floors, groups, SILL, HEAD, style), "brick", Body.RECEIVER)
		for bay: Array in segment.bays:
			_bay(side, float(bay[0]), float(bay[1]), BAY_CHEEK, BAY_CHEEK, BAY_D, BASE_TOP_Y, p + 0.3, "brick",
				FACADE_GRID.stacks(windows.get("fronts", []), floors, groups, SILL, HEAD, style), [[0.3, 0.8]], floors, groups, style)
	# Ledge on the podium top, then the recessed glazed band.
	var outer := [_podium_end(segment, true, 0.0), _podium_end(segment, false, 0.0)]
	var ledge := [_podium_end(segment, true, -BAND_INSET), _podium_end(segment, false, -BAND_INSET)]
	_poly("roof", [_at(outer[0], p), _at(outer[1], p), _at(ledge[1], p), _at(ledge[0], p)], Vector3.UP, Body.SOLID, true)
	var band := [_end(segment, true, -BAND_INSET), _end(segment, false, -BAND_INSET)]
	_extrude(band, p, band, tb, n, "glass", Body.RECEIVER)
	# Band mullions on the face's absolute grid, so on the SE they continue the
	# joint's curtain-wall verticals (pitch 1.0) above the east podium.
	var band_plane := _side_plane(side, -BAND_INSET)
	# Corner ends are mitred behind the band plane; keep members off them.
	var bu0 := float(segment.u0) + (BAND_INSET * 1.5 if str(segment.start) == "corner" else 0.0)
	var bu1 := float(segment.u1) - (BAND_INSET * 1.5 if str(segment.end) == "corner" else 0.0)
	_mullions_abs(band_plane, bu0, bu1, p, tb, 1.0 if int(segment.face) == 2 else 1.5)
	_strip(band_plane, bu0, bu1, p, p + 0.12, "frame", 0.03)
	# Flare: the lowest tower storey leans FLARE_OUT out at its foot, over a zigzag
	# soffit back to the band (ih09, ih14); then the sawtooth shaft to the crown.
	var flared := _saw_line(segment, FLARE_OUT)
	var shaft := _saw_line(segment, 0.0)
	var inner := _saw_line(segment, -BAND_INSET, true)
	for j in flared.size() - 1:
		_poly("trim", [_at(flared[j], tb), _at(flared[j + 1], tb), _at(inner[j + 1], tb), _at(inner[j], tb)], Vector3.DOWN, Body.SOLID)
	_extrude(flared, tb, shaft, tb + FLARE_H, n, "wall", Body.RECEIVER)
	# Shaft facets: a stacked glazing strip per floor on each wide facet, the narrow
	# return facets solid grey panel (ih19, ih21); slots on the flat faces (ih14).
	var plan := _saw(segment)
	var tower_floors := FACADE_GRID.floor_lines(tb, ceili((TOWER_TOP_Y - tb) / TOWER_FLOOR_M), TOWER_FLOOR_M)
	for j in shaft.size() - 1:
		var a := shaft[j]
		var b := shaft[j + 1]
		var along := b - a
		var facet_n := Vector3(along.z, 0.0, -along.x).normalized()
		if facet_n.dot(n) < 0.0:
			facet_n = -facet_n
		var wide := not bool(segment.saw) or plan[j + 1].y > plan[j].y
		var columns: Array = windows.get("slots", []) if not bool(segment.saw) else ([[along.length() * 0.5 - 0.95, along.length() * 0.5 + 0.95]] if wide else [])
		# One continuous dark glazing/spandrel stack per strip from above the flare to
		# below the parapet (ih14, ih19, ih21), floor joints across the panels.
		var k_last := floori((TOWER_TOP_Y - 0.5 - tb - 2.8) / TOWER_FLOOR_M)
		var openings := []
		for o: Array in FACADE_GRID.stacks(columns, tower_floors, [[0, k_last]], 0.15, 2.8, {"split": 0.0, "transom": 0.0}):
			o[2] = maxf(float(o[2]), tb + FLARE_H + 0.15)
			openings.append(o)
		var facet := _plane(a, along, facet_n)
		var length := along.length()
		_punched(facet, 0.0, length, tb + FLARE_H, TOWER_TOP_Y, openings, "wall" if wide else "tower_grey", Body.RECEIVER)
		var gaps := [0.0]
		for column: Array in columns:
			gaps.append_array([float(column[0]), float(column[1])])
			if not bool(segment.saw):
				# Grey vertical panel beside each flat-face slot (ih14).
				_strip(facet, float(column[1]), minf(float(column[1]) + 0.9, length), tb + FLARE_H, TOWER_TOP_Y - 0.4, "tower_grey", 0.01)
		gaps.append(length)
		for floor: float in tower_floors:
			if floor > tb + FLARE_H and floor < TOWER_TOP_Y - 0.4:
				for g in range(0, gaps.size(), 2):
					_strip(facet, gaps[g], gaps[g + 1], floor - 0.03, floor + 0.03, "joint", 0.015)
	# Slot returns: the faces of the segment's end seen from inside the slot.
	for at_start: bool in [true, false]:
		if str(segment.start if at_start else segment.end) != "slot":
			continue
		var u: float = segment.u0 if at_start else segment.u1
		var facing := -1.0 if at_start else 1.0
		var bottom := BASE_TOP_Y if bool(segment.ground) else LOW_ROOF_Y
		if p > bottom + 0.01 and not _podium_trimmed(segment, at_start):
			_return(side, u, 0.0, -SLOT_D, bottom, p, facing, "brick", Body.RECEIVER)
		_return(side, u, -BAND_INSET, -SLOT_D, p, tb, facing, "glass", Body.RECEIVER)
		_return(side, u, 0.0, -SLOT_D, tb, TOWER_TOP_Y, facing, "wall", Body.RECEIVER)


# Double-height storefront on the podium's ground faces f0-f3, recessed under a
# soffit behind concrete columns; continuous with the low WSW recess at c0 and
# closed by a pier where the low ENE base returns to the line at c4.
func _tower_base() -> void:
	for face in 4:
		var side: Dictionary = _faces[face]
		var start := _corners[face] + _miters[face] * -BASE_RECESS if face > 0 else _at_side(side, 0.0, -BASE_RECESS)
		var length: float = side.length
		var end_u := length - 0.6 if face == 3 else length
		var finish := _corners[face + 1] + _miters[face + 1] * -BASE_RECESS if face < 3 else _at_side(side, end_u, -BASE_RECESS)
		var front_start := _corners[face] if face > 0 else _at_side(side, 0.0, 0.0)
		var front_end := _corners[face + 1] if face < 3 else _at_side(side, end_u, 0.0)
		_extrude([start, finish], BASE_BOTTOM_Y, [start, finish], BASE_TOP_Y, side.n, "glass_store", Body.RECEIVER)
		_podium_frontage(face, side, end_u)
		if face == 2:
			# No soffit across the SE joint: its glazing rises past the base.
			for piece: Array in [[front_start, _at_side(side, SE_JOINT_U0, 0.0), _at_side(side, SE_JOINT_U0, -BASE_RECESS), start],
					[_at_side(side, SE_JOINT_U1, 0.0), front_end, finish, _at_side(side, SE_JOINT_U1, -BASE_RECESS)]]:
				_poly("trim", [_at(piece[0], BASE_TOP_Y), _at(piece[1], BASE_TOP_Y), _at(piece[2], BASE_TOP_Y), _at(piece[3], BASE_TOP_Y)], Vector3.DOWN, Body.SOLID)
		else:
			_poly("trim", [_at(front_start, BASE_TOP_Y), _at(front_end, BASE_TOP_Y), _at(finish, BASE_TOP_Y), _at(start, BASE_TOP_Y)], Vector3.DOWN, Body.SOLID)
		if face == 3:
			_wall(side, end_u, length, BASE_BOTTOM_Y, BASE_TOP_Y, "brick", Body.RECEIVER)
			_return(side, end_u, 0.0, -BASE_RECESS, BASE_BOTTOM_Y, BASE_TOP_Y, -1.0, "brick", Body.RECEIVER)
		var count := maxi(roundi(length / 6.0), 1)
		for index in count + 1:
			var u := clampf(length * float(index) / float(count), COLUMN_W * 0.5 + 0.05, length - COLUMN_W * 0.5 - 0.05)
			if (face == 3 and u > end_u - 0.5) or (face == 2 and u > SE_JOINT_U0 - 1.0 and u < SE_JOINT_U1 + 1.0):
				continue
			_column(side, u, BASE_BOTTOM_Y, BASE_TOP_Y)


# Podium ground frontage on the recessed glass plane (ih08, ih09, ih14, ih18):
# storefront bays with continuous mullions, a mezzanine transom and a dark louvre band
# under the soffit, interrupted by opaque charcoal patterned-brick panels with doors,
# and on the SE the leasing storefront with its canopy and sign band. The "39" entry is
# part of the SE joint.
func _podium_frontage(face: int, side: Dictionary, end_u: float) -> void:
	var plane := _side_plane(side, -BASE_RECESS)
	var panels: Array = PODIUM_PANELS.get(face, [])
	var skips: Array = panels.duplicate()
	if face == 2:
		skips.append([SE_JOINT_U0, SE_JOINT_U1])
		skips.append(SE_LEASING)
	var runs := _runs_between(0.0, end_u, skips)
	for run: Array in runs:
		_storefront_bay(plane, run[0], run[1], true)
	for door: Array in PODIUM_DOORS.get(face, []):
		_door(plane, door[0], door[1])
	for panel: Array in panels:
		_strip(plane, panel[0], panel[1], BASE_BOTTOM_Y, BASE_TOP_Y, "dark", 0.03)
		if panel.size() > 2:
			_door(plane, panel[2], panel[3])
	if face == 2:
		var l0: float = SE_LEASING[0]
		var l1: float = SE_LEASING[1]
		_storefront_bay(plane, l0, l1, false)
		_door(plane, 34.6, 35.8)
		# Dark leasing canopy and the navy sign band above it (ih08, ih14).
		_box("frame", _at(_at_side(side, (l0 + l1) * 0.5, -BASE_RECESS * 0.5 + 0.1), CANOPY_Y), side.t, side.n, l1 - l0, 0.25, BASE_RECESS + 0.2, Body.SOLID)
		_strip(plane, l0 + 0.3, l1 - 0.3, 7.6, 9.4, "spandrel", 0.04)
		_strip(plane, 38.6, 40.6, 7.9, 9.1, "glass_blue", 0.05)
	if face == 3:
		# The leasing canopy turns the ENE corner (ih14).
		_box("frame", _at(_at_side(side, 2.0, -BASE_RECESS * 0.5 + 0.1), CANOPY_Y), side.t, side.n, 4.0, 0.25, BASE_RECESS + 0.2, Body.SOLID)


# [u0, u1] pieces of [a, b] outside the given ranges.
static func _runs_between(a: float, b: float, skips: Array) -> Array:
	var cuts := skips.duplicate()
	cuts.sort_custom(func(x: Array, y: Array) -> bool: return float(x[0]) < float(y[0]))
	var runs := []
	var u := a
	for cut: Array in cuts:
		if float(cut[0]) > u + 0.05:
			runs.append([u, minf(float(cut[0]), b)])
		u = maxf(u, float(cut[1]))
	if b > u + 0.05:
		runs.append([u, b])
	return runs


# Storefront glazing frame over [u0, u1]: continuous mullions on a shared absolute
# u grid, a mezzanine transom, and optionally a dark louvre band under the soffit.
func _storefront_bay(plane: Dictionary, u0: float, u1: float, louvre: bool) -> void:
	var top := LOUVRE_BOTTOM_Y if louvre else BASE_TOP_Y
	_strip(plane, u0, u1, STORE_TRANSOM_TOP_Y, top, "glass", 0.015)
	_mullions_abs(plane, u0, u1, BASE_BOTTOM_Y, top, 1.25)
	_strip(plane, u0, u1, STORE_TRANSOM_BOTTOM_Y, STORE_TRANSOM_TOP_Y, "frame", 0.035)
	if louvre:
		_strip(plane, u0, u1, LOUVRE_BOTTOM_Y, BASE_TOP_Y, "spandrel", 0.03)
		for k in range(1, 7):
			var y := LOUVRE_BOTTOM_Y + (BASE_TOP_Y - LOUVRE_BOTTOM_Y) * float(k) / 7.0
			_strip(plane, u0, u1, y - 0.015, y + 0.015, "joint", 0.04)


func _mullions_abs(plane: Dictionary, u0: float, u1: float, y0: float, y1: float, pitch: float) -> void:
	var us := [u0 + 0.05, u1 - 0.05]
	var k := ceili((u0 + 0.3) / pitch)
	while float(k) * pitch < u1 - 0.3:
		us.append(float(k) * pitch)
		k += 1
	for u: float in us:
		_strip(plane, u - 0.05, u + 0.05, y0, y1, "frame", 0.03)


# Live-work bay on a base glass plane over [u0, u1] (ih01, ih18, dba-64): mullions,
# a dark louvred mezzanine band, a low concrete sill and optionally a door; parts
# inside `skips` (garage) are left out.
func _live_work_bay(plane: Dictionary, u0: float, u1: float, door: bool, skips: Array) -> void:
	for run: Array in _runs_between(u0, u1, skips):
		var a: float = run[0]
		var b: float = run[1]
		if b - a < 0.3:
			continue
		_mezzanine(plane, a, b, BASE_BOTTOM_Y)
		var d0 := a + 0.4
		if door and b - a > 2.2:
			_door(plane, d0, d0 + 1.1)
			_strip(plane, d0 + 1.25, b, BASE_BOTTOM_Y, BASE_BOTTOM_Y + SILL_WALL_H, "concrete", 0.035)
			_strip(plane, a, d0 - 0.1, BASE_BOTTOM_Y, BASE_BOTTOM_Y + SILL_WALL_H, "concrete", 0.035)
		else:
			_strip(plane, a, b, BASE_BOTTOM_Y, BASE_BOTTOM_Y + SILL_WALL_H, "concrete", 0.035)


# Live-work bay upper parts over [a, b]: light upper glass above the louvred mezzanine
# band and mullions on the shared absolute grid from `mullion_bottom` to the soffit.
func _mezzanine(plane: Dictionary, a: float, b: float, mullion_bottom: float) -> void:
	_strip(plane, a, b, MEZZANINE_TOP_Y, BASE_TOP_Y, "glass", 0.015)
	_mullions_abs(plane, a, b, mullion_bottom, BASE_TOP_Y, 1.25)
	_strip(plane, a, b, MEZZANINE_BOTTOM_Y, MEZZANINE_TOP_Y, "spandrel", 0.03)
	for k in range(1, 5):
		var y := MEZZANINE_BOTTOM_Y + (MEZZANINE_TOP_Y - MEZZANINE_BOTTOM_Y) * float(k) / 5.0
		_strip(plane, a, b, y - 0.015, y + 0.015, "joint", 0.04)


# Garden Walk live-work bay (dba-64): lower windows over an opaque concrete low wall
# about 0.9 m above the walk, the door recessed in a broad opaque charcoal surround,
# a louvred mezzanine band, and light upper glazing above it.
func _garden_walk_bay(plane: Dictionary, a: float, b: float, door: bool) -> void:
	if b - a < 0.3:
		return
	var wall_top := GARDEN_WALL_TOP_Y
	_mezzanine(plane, a, b, wall_top)
	var s0 := a
	if door and b - a > 3.0:
		var d0 := a + 0.5
		# Opaque surround, then the dark recessed door leaf inside it.
		_strip(plane, a, d0 + 1.5, BASE_BOTTOM_Y, MEZZANINE_BOTTOM_Y, "dark", 0.045)
		_strip(plane, d0, d0 + 1.0, BASE_BOTTOM_Y, 6.55, "frame", 0.05)
		_strip(plane, d0 + 0.08, d0 + 0.92, BASE_BOTTOM_Y, 6.47, "spandrel", 0.055)
		s0 = d0 + 1.5
	_strip(plane, s0, b, BASE_BOTTOM_Y, wall_top, "concrete", 0.04)
	_strip(plane, s0, b, wall_top, wall_top + 0.08, "frame", 0.045)


# A dark-framed glazed door (2.6 m) at the base.
func _door(plane: Dictionary, u0: float, u1: float) -> void:
	_strip(plane, u0 - 0.08, u1 + 0.08, BASE_BOTTOM_Y, BASE_BOTTOM_Y + DOOR_H + 0.1, "frame", 0.045)
	_strip(plane, u0, u1, BASE_BOTTOM_Y, BASE_BOTTOM_Y + DOOR_H, "glass", 0.05)
	_strip(plane, (u0 + u1) * 0.5 - 0.03, (u0 + u1) * 0.5 + 0.03, BASE_BOTTOM_Y, BASE_BOTTOM_Y + DOOR_H, "frame", 0.055)


# Full-height recessed glazed slot: back wall, and its floor where it stands on a
# roof (the SE slot's glazing continues down into the podium joint instead).
func _slot(face: int, u0: float, bottom: float, floor_cap: bool) -> void:
	var side: Dictionary = _faces[face]
	var u1 := u0 + SLOT_W
	_wall(side, u0, u1, bottom, TOWER_TOP_Y, "glass", Body.RECEIVER, -SLOT_D)
	var floors := FACADE_GRID.floor_lines(BASE_TOP_Y, roundi((DECK_Y - BASE_TOP_Y) / STOREY_M) + 1, STOREY_M)
	floors.append_array(FACADE_GRID.floor_lines(DECK_Y + BAND_M, ceili((TOWER_TOP_Y - DECK_Y - BAND_M) / TOWER_FLOOR_M), TOWER_FLOOR_M))
	_curtain(_side_plane(side, -SLOT_D), u0, u1, bottom, TOWER_TOP_Y, floors, 1.0)
	if floor_cap:
		_cap(side, u0, u1, 0.0, -SLOT_D, bottom, true, "roof", Body.SOLID)


# SE podium joint: the recessed glazed plane between the podium masses' ends
# (beside the tower slot), the masses' end returns, and columns under their corners.
func _se_joint() -> void:
	var side: Dictionary = _faces[2]
	var u0 := SE_JOINT_U0
	var u1 := SE_JOINT_U1
	var s0 := SE_SLOT_U
	var s1 := SE_SLOT_U + SLOT_W
	_wall(side, u0, s0, BASE_TOP_Y, DECK_Y, "glass", Body.RECEIVER, -BASE_RECESS)
	_wall(side, s1, u1, BASE_TOP_Y, LOW_ROOF_Y, "glass", Body.RECEIVER, -BASE_RECESS)
	_return(side, u0, 0.0, -BASE_RECESS, BASE_TOP_Y, DECK_Y, 1.0, "brick", Body.RECEIVER)
	_return(side, u1, 0.0, -BASE_RECESS, BASE_TOP_Y, LOW_ROOF_Y, -1.0, "brick", Body.RECEIVER)
	# One curtain wall from the ground (ih08, ih09, dba-50): the base, joint and slot
	# share one absolute mullion grid, the mezzanine transom and the floor lines, with
	# the "39" entry doors and its address plate at the foot.
	var floors := [TRANSOM_Y]
	floors.append_array(FACADE_GRID.floor_lines(BASE_TOP_Y, 5, STOREY_M))
	var joint := _side_plane(side, -BASE_RECESS)
	_curtain(joint, u0, u1, BASE_BOTTOM_Y, BASE_TOP_Y, floors, 1.0)
	_curtain(joint, u0, s0, BASE_TOP_Y, DECK_Y, floors, 1.0)
	_curtain(joint, s1, u1, BASE_TOP_Y, LOW_ROOF_Y, floors, 1.0)
	_door(joint, 25.1, 26.5)
	_strip(joint, 24.05, 24.85, 7.55, 8.15, "frame", 0.06)
	_column(side, u0 - COLUMN_W * 0.5, BASE_BOTTOM_Y, BASE_TOP_Y)
	_column(side, u1 + COLUMN_W * 0.5, BASE_BOTTOM_Y, BASE_TOP_Y)


func _roof_outline(segments: Array[Dictionary], meet_u: float) -> Array[Vector3]:
	var outline: Array[Vector3] = []
	for segment in segments:
		var line := _saw_line(segment, 0.0)
		var side: Dictionary = _faces[segment.face]
		if str(segment.start) == "slot":
			var u: float = segment.u0
			outline.append(_at_side(side, u - SLOT_W, -SLOT_D))
			outline.append(_at_side(side, u, -SLOT_D))
		for j in line.size() - (1 if str(segment.end) == "corner" else 0):
			outline.append(line[j])
	return outline


func _flat_roof(outline: Array[Vector3], y: float, key: String, body: Body = Body.SOLID) -> String:
	var flat: PackedVector2Array = []
	for p in outline:
		flat.append(Vector2(p.x, p.z))
	var triangles := Geometry2D.triangulate_polygon(flat)
	if triangles.is_empty():
		return "Isle House roof outline did not triangulate."
	for i in range(0, triangles.size(), 3):
		_poly(key, [_at(outline[triangles[i]], y), _at(outline[triangles[i + 1]], y), _at(outline[triangles[i + 2]], y)], Vector3.UP, body, true)
	return ""


# Crown (ih21, dba-50/52): an offset penthouse left of centre on the SE half, plant
# boxes, and a guardrail set in from the parapet.
func _crown(outline: Array[Vector3], segments: Array[Dictionary]) -> String:
	var flat: PackedVector2Array = []
	for p in outline:
		flat.append(Vector2(p.x, p.z))
	var se: Dictionary = _faces[2]
	var along: Vector3 = se.t
	var inward: Vector3 = -se.n
	var middle := _at_side(se, 18.6, -7.5)
	if not _on_roof(flat, middle, along, inward, 20.0, 9.0):
		return "Isle House penthouse footprint left the tower roof."
	_box("tower_grey", _at(middle, TOWER_TOP_Y + 2.0), along, inward, 20.0, 4.0, 9.0, Body.SOLID, true)
	for plant: Array in [[middle - along * 12.5, 4.0, 2.2, 4.0], [middle + along * 13.0 - inward * 1.5, 3.0, 1.8, 2.5]]:
		if _on_roof(flat, plant[0], along, inward, plant[1], plant[3]):
			_box("roof", _at(plant[0], TOWER_TOP_Y + float(plant[2]) * 0.5), along, inward, plant[1], plant[2], plant[3], Body.SOLID, true)
	for segment in segments:
		var side: Dictionary = _faces[segment.face]
		var a := _at_side(side, float(segment.u0) + 1.0, -1.0)
		var b := _at_side(side, float(segment.u1) - 1.0, -1.0)
		var length := a.distance_to(b)
		if length < 1.0:
			continue
		var t: Vector3 = side.t
		_box("dark", _at((a + b) * 0.5, TOWER_TOP_Y + 1.05), t, side.n, length, 0.06, 0.06, Body.SOLID)
		var posts := maxi(int(length / 2.5), 1)
		for k in posts + 1:
			_box("dark", _at(a.lerp(b, float(k) / float(posts)), TOWER_TOP_Y + 0.53), t, side.n, 0.06, 1.05, 0.06, Body.SOLID)
	return ""


func _on_roof(flat: PackedVector2Array, middle: Vector3, along: Vector3, inward: Vector3, width: float, depth: float) -> bool:
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var p := middle + along * corner.x * width * 0.5 + inward * corner.y * depth * 0.5
		if not Geometry2D.is_point_in_polygon(Vector2(p.x, p.z), flat):
			return false
	return true


# Level-7 deck over the WSW strip and the NNW wing (ih04, ih17, dba-43/55, L7
# plan): courtyard walls from the low roof, the deck, parapet, rail and stair box.
func _deck(low: Dictionary, meet: Vector3) -> String:
	var a := _flat(_run_point(low, 0, false))
	var b := _flat(_run_point(low, 4, true))
	var s_axis := (b - a).normalized()
	var r_axis := -_run_normal(low, 0)
	var nnw_dir := (_flat(_run_point(low, 10, false)) - a).normalized()
	var polygon: Array[Vector3] = [
		a, b, _corners[6], meet,
		a + s_axis * NNW_WING_S + r_axis * WING_DEPTH,
		a + nnw_dir * NNW_TALL_M + s_axis * NNW_WING_S,
		a + nnw_dir * NNW_TALL_M,
	]
	var signed := 0.0
	for i in polygon.size():
		var p := polygon[i]
		var q := polygon[(i + 1) % polygon.size()]
		signed += p.x * q.z - q.x * p.z
	for i in polygon.size():
		var p := polygon[i]
		var q := polygon[(i + 1) % polygon.size()]
		var tangent := (q - p).normalized()
		var out := Vector3(tangent.z, 0.0, -tangent.x) if signed > 0.0 else Vector3(-tangent.z, 0.0, tangent.x)
		# Faces 0 (WSW) and 6 (NNW) are the low fronts; 1 and 2 lie on the tower.
		# Courtyard faces of the added storeys stand inside the frozen footprint over
		# the low roof, not on an exterior run, so they occlude and refuse spray.
		if i in [3, 4, 5]:
			_poly("wall", [_at(p, LOW_ROOF_Y), _at(q, LOW_ROOF_Y), _at(q, DECK_Y), _at(p, DECK_Y)], out, Body.SOLID)
		if i in [1, 2]:
			continue
		var length := p.distance_to(q)
		var mid := (p + q) * 0.5
		_box("trim", _at(mid, DECK_Y + 0.25) - out * 0.12, tangent, out, length + 0.24, 0.5, 0.36, Body.SOLID)
		_box("glass", _at(mid, DECK_Y + 0.85) - out * 0.25, tangent, out, length - 0.1, 0.7, 0.05, Body.SOLID)
	var error := _flat_roof(polygon, DECK_Y, "roof")
	if error != "":
		return error
	var flat: PackedVector2Array = []
	for p in polygon:
		flat.append(Vector2(p.x, p.z))
	var stair := a + nnw_dir * 7.0 + s_axis * 6.0
	if _on_roof(flat, stair, s_axis, nnw_dir, 4.2, 3.4):
		_box("dark", _at(stair, DECK_Y + 2.3), s_axis, nnw_dir, 4.2, 4.6, 3.4, Body.SOLID, true)
	return ""


# ---------------------------------------------------------------- primitives

static func _side(record: Dictionary, first: int, last: int) -> Dictionary:
	var start := _flat(_run_point(record, first, false))
	var finish := _flat(_run_point(record, last, true))
	return {"origin": start, "t": (finish - start).normalized(), "n": _run_normal(record, first), "length": start.distance_to(finish)}


static func _at_side(side: Dictionary, u: float, out: float) -> Vector3:
	return (side.origin as Vector3) + (side.t as Vector3) * u + (side.n as Vector3) * out


# Flat wall on a side between u0 and u1 at `out` from the line.
func _wall(side: Dictionary, u0: float, u1: float, y0: float, y1: float, key: String, body: Body, out: float = 0.0) -> void:
	var line := [_at_side(side, u0, out), _at_side(side, u1, out)]
	_extrude(line, y0, line, y1, side.n, key, body)


# Return face across the side at u, from depth `out0` to `out1`, facing along
# +t (facing 1) or -t (facing -1).
func _return(side: Dictionary, u: float, out0: float, out1: float, y0: float, y1: float, facing: float, key: String, body: Body) -> void:
	var p := _at_side(side, u, out0)
	var q := _at_side(side, u, out1)
	_poly(key, [_at(p, y0), _at(q, y0), _at(q, y1), _at(p, y1)], (side.t as Vector3) * facing, body)


# Horizontal cap over [u0, u1] between depths out0 and out1, up or down facing.
func _cap(side: Dictionary, u0: float, u1: float, out0: float, out1: float, y: float, up: bool, key: String, body: Body) -> void:
	var points := [_at(_at_side(side, u0, out0), y), _at(_at_side(side, u1, out0), y), _at(_at_side(side, u1, out1), y), _at(_at_side(side, u0, out1), y)]
	_poly(key, points, Vector3.UP if up else Vector3.DOWN, body, up)


func _coping(side: Dictionary, u0: float, u1: float, top: float) -> void:
	_box("trim", _at(_at_side(side, (u0 + u1) * 0.5, 0.0), top + 0.15), side.t, side.n, u1 - u0, 0.3, 0.3, Body.SOLID)


# Wall strips between two polylines (bottom at y0, top at y1), facing outward.
func _extrude(bottom: Array, y0: float, top: Array, y1: float, outward: Vector3, key: String, body: Body) -> void:
	for j in bottom.size() - 1:
		_poly(key, [_at(bottom[j], y0), _at(bottom[j + 1], y0), _at(top[j + 1], y1), _at(top[j], y1)], outward, body)


# A plane for openings: u along t from origin, y up, d along n (outward).
static func _plane(origin: Vector3, t: Vector3, n: Vector3) -> Dictionary:
	return {"origin": _flat(origin), "t": t.normalized(), "n": n.normalized()}


static func _side_plane(side: Dictionary, out: float) -> Dictionary:
	return _plane(_at_side(side, 0.0, out), side.t, side.n)


static func _pp(plane: Dictionary, u: float, y: float, d: float) -> Vector3:
	return (plane.origin as Vector3) + (plane.t as Vector3) * u + (plane.n as Vector3) * d + Vector3.UP * y


# Wall rectangle [u0,u1]x[y0,y1] on a plane, cut around recessed window openings
# ([u0, u1, y0, y1] each; rows of merged cells), each opening lined with dark reveals
# WINDOW_DEPTH deep to a glass pane, a thin frame and a mullion on wide lights.
func _punched(plane: Dictionary, u0: float, u1: float, y0: float, y1: float, openings: Array, key: String, body: Body) -> void:
	var inside := []
	for o: Array in openings:
		var a := maxf(float(o[0]), u0)
		var b := minf(float(o[1]), u1)
		var c := maxf(float(o[2]), y0)
		var d := minf(float(o[3]), y1)
		if b - a > 0.05 and d - c > 0.05:
			inside.append([a, b, c, d, o[4] if o.size() > 4 else {}])
	var us := [u0, u1]
	var ys := [y0, y1]
	for o: Array in inside:
		us.append_array([o[0], o[1]])
		ys.append_array([o[2], o[3]])
	us = FACADE_GRID.unique_sorted(us)
	ys = FACADE_GRID.unique_sorted(ys)
	var n: Vector3 = plane.n
	for j in ys.size() - 1:
		var y_mid := (float(ys[j]) + float(ys[j + 1])) * 0.5
		var run_start := -1
		for i in us.size():
			var solid_cell := i < us.size() - 1 and not FACADE_GRID.in_opening(inside, (float(us[i]) + float(us[i + 1])) * 0.5, y_mid)
			if solid_cell and run_start < 0:
				run_start = i
			elif not solid_cell and run_start >= 0:
				_poly(key, [_pp(plane, us[run_start], ys[j], 0.0), _pp(plane, us[i], ys[j], 0.0), _pp(plane, us[i], ys[j + 1], 0.0), _pp(plane, us[run_start], ys[j + 1], 0.0)], n, body)
				run_start = -1
	for o: Array in inside:
		_opening(plane, o, body)


func _opening(plane: Dictionary, o: Array, body: Body) -> void:
	var t: Vector3 = plane.t
	var n: Vector3 = plane.n
	var a: float = o[0]
	var b: float = o[1]
	var c: float = o[2]
	var e: float = o[3]
	var d := -WINDOW_DEPTH
	_poly("frame", [_pp(plane, a, c, 0.0), _pp(plane, a, c, d), _pp(plane, a, e, d), _pp(plane, a, e, 0.0)], t, body)
	_poly("frame", [_pp(plane, b, c, 0.0), _pp(plane, b, c, d), _pp(plane, b, e, d), _pp(plane, b, e, 0.0)], -t, body)
	_poly("frame", [_pp(plane, a, e, 0.0), _pp(plane, b, e, 0.0), _pp(plane, b, e, d), _pp(plane, a, e, d)], Vector3.DOWN, body)
	_poly("frame", [_pp(plane, a, c, 0.0), _pp(plane, b, c, 0.0), _pp(plane, b, c, d), _pp(plane, a, c, d)], Vector3.UP, body)
	var extras: Dictionary = o[4] if o.size() > 4 else {}
	_poly(str(extras.get("pane", "glass")), [_pp(plane, a, c, d), _pp(plane, b, c, d), _pp(plane, b, e, d), _pp(plane, a, e, d)], n, body)
	# Frame ring, spandrels, mullion and transoms just in front of the glass (visual only).
	var f := d + 0.02
	var w := FRAME_W
	var bars := [[a, a + w, c, e], [b - w, b, c, e], [a, b, c, c + w], [a, b, e - w, e]]
	var split := float(extras.get("split", 0.5)) if b - a > 1.4 else 0.0
	if split > 0.0:
		var mu := lerpf(a, b, split)
		bars.append([mu - w * 0.6, mu + w * 0.6, c, e])
	var transom := float(extras.get("transom", 0.0))
	for sill_y: float in extras.get("sills", []):
		if transom > 0.0:
			bars.append([a, b, sill_y + transom - w * 0.5, sill_y + transom + w * 0.5])
	for r: Array in bars:
		_poly("frame", [_pp(plane, r[0], r[2], f), _pp(plane, r[1], r[2], f), _pp(plane, r[1], r[3], f), _pp(plane, r[0], r[3], f)], n, Body.VISUAL)
	for band: Array in extras.get("spandrels", []):
		_poly("spandrel", [_pp(plane, a, band[0], f - 0.005), _pp(plane, b, band[0], f - 0.005), _pp(plane, b, band[1], f - 0.005), _pp(plane, a, band[1], f - 0.005)], n, Body.VISUAL)
	if bool(extras.get("surround", false)):
		var sw := 0.12
		for r: Array in [[a - sw, a, c - sw, e + sw], [b, b + sw, c - sw, e + sw], [a, b, c - sw, c], [a, b, e, e + sw]]:
			_poly("frame", [_pp(plane, r[0], r[2], 0.03), _pp(plane, r[1], r[2], 0.03), _pp(plane, r[1], r[3], 0.03), _pp(plane, r[0], r[3], 0.03)], n, Body.VISUAL)


# Curtain wall over a glazing plane (ih08, ih09, dba-50): mullions on a shared
# absolute u grid (multiples of `pitch`) and floor-aligned spandrel bands, so every
# division runs the full height of its plane and meets the floor lines.
func _curtain(plane: Dictionary, u0: float, u1: float, y0: float, y1: float, floors: Array, pitch: float = 1.25) -> void:
	var f := 0.03
	var us := [u0, u1]
	var k := ceili(u0 / pitch)
	while float(k) * pitch < u1 - 0.05:
		if float(k) * pitch > u0 + 0.05:
			us.append(float(k) * pitch)
		k += 1
	for u: float in us:
		_strip(plane, u - 0.05, u + 0.05, y0, y1, "frame", f)
	# Head and sill members close the field so no vertical ends free.
	for y: float in [y0, y1]:
		_strip(plane, u0, u1, y - 0.06, y + 0.06, "frame", f)
	for floor: float in floors:
		if floor > y0 + 0.2 and floor < y1 - 0.2:
			_strip(plane, u0, u1, floor - 0.35, floor + 0.15, "spandrel", f - 0.005)
			_strip(plane, u0, u1, floor - 0.4, floor - 0.33, "frame", f)
			_strip(plane, u0, u1, floor + 0.13, floor + 0.2, "frame", f)


# A flat visual strip on a plane (bands, joints, panels) `out` in front of it.
func _strip(plane: Dictionary, u0: float, u1: float, y0: float, y1: float, key: String, out: float = 0.02) -> void:
	if u1 - u0 > 0.01 and y1 - y0 > 0.005:
		_poly(key, [_pp(plane, u0, y0, out), _pp(plane, u1, y0, out), _pp(plane, u1, y1, out), _pp(plane, u0, y1, out)], plane.n, Body.VISUAL)


# Thin dark mullions (and an optional transom) just in front of a glazing plane.
func _mullions(plane: Dictionary, u0: float, u1: float, y0: float, y1: float, pitch: float, transom: float = -1.0) -> void:
	var count := maxi(roundi((u1 - u0) / pitch), 1)
	for k in count + 1:
		var u := lerpf(u0, u1, float(k) / float(count))
		_strip(plane, u - 0.05, u + 0.05, y0, y1, "frame", 0.03)
	if transom > 0.0:
		_strip(plane, u0, u1, transom - 0.06, transom + 0.06, "frame", 0.03)


# Angled projecting bay (ih18, ih04, dba-64): front `front_w` wide centred on uc,
# `depth` proud of the line, its cheeks running cheek_l/cheek_r along the face
# (0 for a square return).
# Front openings are in the side's u; cheek openings [c0, c1] run along each cheek
# from its back edge, repeated on `floors`.
func _bay(side: Dictionary, uc: float, front_w: float, cheek_l: float, cheek_r: float, depth: float, y0: float, y1: float, key: String,
		front_openings: Array = [], cheek_columns: Array = [], floors: Array = [], cheek_groups: Array = [], cheek_style: Dictionary = {}) -> void:
	var back_l := _at_side(side, uc - front_w * 0.5 - cheek_l, 0.0)
	var front_l := _at_side(side, uc - front_w * 0.5, depth)
	var front_r := _at_side(side, uc + front_w * 0.5, depth)
	var back_r := _at_side(side, uc + front_w * 0.5 + cheek_r, 0.0)
	var n: Vector3 = side.n
	_punched(_side_plane(side, depth), uc - front_w * 0.5, uc + front_w * 0.5, y0, y1, front_openings, key, Body.SOLID)
	var t: Vector3 = side.t
	for cheek: Array in [[back_l, front_l, cheek_l, -t], [front_r, back_r, cheek_r, t]]:
		if float(cheek[2]) < 0.001:
			# Square return: faces along the side, not out of it.
			_extrude([cheek[0], cheek[1]], y0, [cheek[0], cheek[1]], y1, cheek[3], key, Body.SOLID)
			continue
		var a: Vector3 = cheek[0]
		var b: Vector3 = cheek[1]
		var along := b - a
		var normal := Vector3(along.z, 0.0, -along.x).normalized()
		if normal.dot(n) < 0.0:
			normal = -normal
		# Cheek columns measured from the cheek's back (wall) edge.
		var plane := _plane(a, along, normal) if a == back_l else _plane(b, -along, normal)
		_punched(plane, 0.0, along.length(), y0, y1, FACADE_GRID.stacks(cheek_columns, floors, cheek_groups, SILL, HEAD, cheek_style), key, Body.SOLID)
	_poly("trim", [_at(back_l, y0), _at(front_l, y0), _at(front_r, y0), _at(back_r, y0)], Vector3.DOWN, Body.SOLID)
	_poly("roof", [_at(back_l, y1), _at(front_l, y1), _at(front_r, y1), _at(back_r, y1)], Vector3.UP, Body.SOLID, true)


# Board-formed concrete column standing at the line in front of a recessed base.
func _column(side: Dictionary, u: float, y0: float, y1: float, key: String = "concrete", width: float = COLUMN_W) -> void:
	_box(key, _at(_at_side(side, u, -COLUMN_W * 0.5), (y0 + y1) * 0.5), side.t, side.n, width, y1 - y0, COLUMN_W, Body.SOLID)


func _box(key: String, center: Vector3, tangent_value: Vector3, normal_value: Vector3, width: float, height: float, depth: float, body: Body, roof_top: bool = false) -> void:
	var t := tangent_value.normalized()
	var n := (normal_value - t * normal_value.dot(t)).normalized()
	var tx := t * width * 0.5
	var nz := n * depth * 0.5
	var uy := Vector3.UP * height * 0.5
	var c := center
	_poly(key, [c - tx - uy + nz, c + tx - uy + nz, c + tx + uy + nz, c - tx + uy + nz], n, body)
	_poly(key, [c + tx - uy - nz, c - tx - uy - nz, c - tx + uy - nz, c + tx + uy - nz], -n, body)
	_poly(key, [c - tx - uy - nz, c - tx - uy + nz, c - tx + uy + nz, c - tx + uy - nz], -t, body)
	_poly(key, [c + tx - uy + nz, c + tx - uy - nz, c + tx + uy - nz, c + tx + uy + nz], t, body)
	_poly(key, [c - tx - uy - nz, c + tx - uy - nz, c + tx - uy + nz, c - tx - uy + nz], Vector3.DOWN, body)
	_poly("roof" if roof_top else key, [c - tx + uy + nz, c + tx + uy + nz, c + tx + uy - nz, c - tx + uy - nz], Vector3.UP, body, roof_top)


# Convex polygon as a triangle fan. Each triangle faces the side of `hint`: Godot
# fronts wind clockwise seen from the front, so the geometric (b-a)x(c-a) normal
# must oppose the outward one; the collision shares that winding.
func _poly(key: String, points: Array, hint: Vector3, body: Body, roof: bool = false) -> void:
	for i in range(1, points.size() - 1):
		var a: Vector3 = points[0]
		var b: Vector3 = points[i]
		var c: Vector3 = points[i + 1]
		var cross := (b - a).cross(c - a)
		if cross.length() < 0.000001:
			continue
		var normal := cross.normalized()
		if normal.dot(hint) < 0.0:
			normal = -normal
		var ordered := [a, c, b] if cross.dot(normal) > 0.0 else [a, b, c]
		var bucket := _bucket(_roofs if roof else _walls, key)
		var vertices: PackedVector3Array = bucket.vertices
		var normals: PackedVector3Array = bucket.normals
		for p: Vector3 in ordered:
			vertices.append(p)
			normals.append(normal)
		bucket.vertices = vertices
		bucket.normals = normals
		if body == Body.RECEIVER:
			_receiver.append_array(PackedVector3Array(ordered))
		elif body == Body.SOLID:
			_solid.append_array(PackedVector3Array(ordered))


static func _bucket(target: Dictionary, key: String) -> Dictionary:
	if not target.has(key):
		target[key] = {"vertices": PackedVector3Array(), "normals": PackedVector3Array()}
	return target[key]


static func _material(key: String) -> Material:
	if not _materials.has(key):
		var material := StandardMaterial3D.new()
		var spec: Array = COLOURS[key]
		material.albedo_color = spec[0]
		material.roughness = float(spec[1])
		material.metallic = float(spec[2])
		_materials[key] = material
	return _materials[key]


# The record root: visuals, the record's own receiver body, and a solid body
# (receiver_kind none) for everything that only occludes.
func _emit(record: Dictionary, form_name: String) -> Dictionary:
	var root := Node3D.new()
	root.name = str(record.object_key).validate_node_name()
	root.set_meta("derived_object_key", str(record.object_key))
	root.set_meta("source_keys", (record.source_keys as Array).duplicate())
	root.set_meta("feature_kind", str(record.feature_kind))
	root.set_meta("isle_house_form_override", true)
	root.set_meta("truth_class", "production_inference_scaled_from_2025_photos")
	var form := Node3D.new()
	form.name = form_name
	root.add_child(form)
	var triangles := 0
	var meshes := 0
	for pair: Array in [[_walls, RENDER_BUILDING_WALL, ""], [_roofs, RENDER_WORLD_VISIBLE, "roof"]]:
		var target: Dictionary = pair[0]
		for key: String in target:
			var bucket: Dictionary = target[key]
			var arrays: Array = []
			arrays.resize(Mesh.ARRAY_MAX)
			arrays[Mesh.ARRAY_VERTEX] = bucket.vertices
			arrays[Mesh.ARRAY_NORMAL] = bucket.normals
			var mesh := ArrayMesh.new()
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			mesh.surface_set_material(0, _material(key))
			var instance := MeshInstance3D.new()
			instance.name = ("Roof_" if str(pair[2]) != "" else "Form_") + key
			instance.mesh = mesh
			instance.layers = int(pair[1])
			if str(pair[2]) != "":
				instance.set_meta("physical_role", str(pair[2]))
			form.add_child(instance)
			triangles += (bucket.vertices as PackedVector3Array).size() / 3
			meshes += 1
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(_receiver)
	var body := StaticBody3D.new()
	body.name = "Collision"
	body.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
	body.collision_mask = 0
	for target: Object in [body, shape]:
		target.set_meta("receiver_kind", str(record.receiver_kind))
		target.set_meta("opaque", bool(record.opaque))
		target.set_meta("derived_object_key", str(record.object_key))
		target.set_meta("source_keys", (record.source_keys as Array).duplicate())
	if str(record.receiver_kind) == "building_wall":
		body.add_to_group("spray_receiver_wall")
	var shape_node := CollisionShape3D.new()
	shape_node.name = "Shape"
	shape_node.shape = shape
	body.add_child(shape_node)
	root.add_child(body)
	if not _solid.is_empty():
		var solid_shape := ConcavePolygonShape3D.new()
		solid_shape.set_faces(_solid)
		var solid := StaticBody3D.new()
		solid.name = "IsleHouseFormSolid_NoSprayOwnership"
		# Spray rays stop on these solids (receiver_kind none refuses the tag).
		solid.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
		solid.collision_mask = 0
		solid.set_meta("receiver_kind", "none")
		solid.set_meta("opaque", true)
		solid.set_meta("spray_ownership", "none")
		solid.set_meta("derived_object_key", str(record.object_key))
		solid.set_meta("source_keys", (record.source_keys as Array).duplicate())
		var solid_node := CollisionShape3D.new()
		solid_node.name = "SolidShape"
		solid_node.shape = solid_shape
		solid.add_child(solid_node)
		root.add_child(solid)
	return {"ok": true, "node": root, "mesh_instances": meshes, "surfaces": meshes, "triangles": triangles}


static func _at(p: Vector3, y: float) -> Vector3:
	return Vector3(p.x, y, p.z)


static func _flat(p: Vector3) -> Vector3:
	return Vector3(p.x, 0.0, p.z)


static func _run_point(record: Dictionary, run: int, end: bool) -> Vector3:
	var v: Array = record.vertices
	var o := run * 12 + (3 if end else 0)
	return Vector3(float(v[o]), float(v[o + 1]), float(v[o + 2]))


static func _run_normal(record: Dictionary, run: int) -> Vector3:
	var n: Array = record.normals
	return Vector3(float(n[run * 12]), 0.0, float(n[run * 12 + 2])).normalized()


static func _record(records: Array, key: String) -> Dictionary:
	for value: Variant in records:
		if str((value as Dictionary).get("object_key", "")) == key:
			return value
	return {}
