extends RefCounted
## The Treasure Island ferry terminal beyond the covered pier (owner decisions
## 2026-11-07): the steel float with its railed ramps, the aluminium gangway down
## to it from the pier's gate end, its guide piles, the two mooring dolphins with
## their foam fenders, the breakwater in the water NW of it, and the Prop SF
## catamaran Sammy J docked at the float, gently rocking. Built under
## ContextWorld/FerryTerminal from the context's ferry_terminal section
## (tools/lib/ferry-terminal.mjs: frozen OSM float w1036802529, gangway
## w1036802528, dolphins w1222514696/97, stop n9335172179, breakwater w1011830371).
##
## Scenery, not part of the walk route: the float stays outside the playable
## outline and the canopy family's closed gate still ends the pier. Everything has
## simple solid collision on the world and spray layers (an opaque non-receiver,
## like the canopy family's "solid"), so a landing never falls through and a tag
## is refused. The boat's rocking is in its shader only; her collision stays still.
##
## Shapes, sizes, counts and colours are production inference from dated photos
## (research: ferry-research-20261107): the Flickr port views (orange27 docked at
## the float, 7 Jun 2025; Poskanzer underway, 7 Aug 2024), the SFCTA stern view at
## the float (10 Feb 2022), the Commons bow and port-quarter views (27 May 2025),
## the Commons float and gangway views (Aug 2021), the Trailview float pano (Sep
## 2026), the Commons Yerba Buena Island profile showing the breakwater (May 2025)
## and the Esri aerial (29 Aug 2025). Her berth along the float's stop side,
## starboard to the float and bow toward the gangway, follows the June 2025 view
## and the aerial. No photo shows her starboard side: it mirrors the photographed
## port side (owner-approved inference, to be corrected from the owner's photos).
## The float's bay-facing faces, its ramp layout, the piles' bay sides and the
## breakwater's bay face are inferred too. No unreadable sign text is invented.

const BUILDER := preload("res://game/scripts/world/street_furniture_kit.gd").Builder
const BOAT_SHADER := preload("res://game/resources/materials/world/ferry/ferry_boat.gdshader")
const LIVERY := preload("res://game/resources/textures/world/ferry/ferry_livery.png")
## The covered pier the gangway hangs from (pier_canopy_family.gd): its deck
## height is the canopy root's pier_deck_y, its deck end the config's inset.
const CANOPY_SOURCE_KEY := "w1222514695"
const CANOPY_CONFIG := "res://game/resources/pier_family/w1222514695.json"
const SOLID_LAYERS := 5

## Livery atlas cells (UV), as tools/draw_ferry_livery.sh draws them.
const CELL_WHITE := Rect2(0.0, 0.0, 0.25, 0.25)
const CELL_HULL_NAME := Rect2(0.25, 0.0, 0.5, 0.125)
const CELL_FENDER := Rect2(0.25, 0.125, 0.5, 0.125)
const CELL_BOW_PANEL := Rect2(0.0, 0.25, 1.0, 0.25)
const CELL_SIDE_PANEL := Rect2(0.0, 0.5, 1.0, 0.25)
## The transom cell's two sign panels: the name, port and PROP mark on the left,
## TREASURE ISLAND and the web address on the right.
const CELL_TRANSOM_PORT := Rect2(0.0, 0.75, 0.4, 0.1875)
const CELL_TRANSOM_STARBOARD := Rect2(0.58, 0.75, 0.42, 0.1875)
## How far inside its cell a label samples (UV; about 4 texels of the atlas).
const LABEL_INSET_UV := 0.004

## The float: deck height over the water and draft (its grey side photographs at
## a little over a pile's diameter above the water, Aug 2021).
const FLOAT_FREEBOARD_M := 0.95
const FLOAT_DRAFT_M := 1.7
## The berth side's black fender panels: how far their faces stand off the float.
const FENDER_STANDOFF_M := 0.42
## The deck layout (owner frames received 2026-11-07, the aerial looking SW from
## over the gangway): a central walkway the float's whole length (its half width),
## a long open deck at the gangway end (its share of the float's length), three
## railed ramp compartments each side, and a short landing at the outer end.
const AISLE_HALF_M := 1.2
const OPEN_DECK_SHARE := 0.47
const COMPARTMENTS := 3
const COMPARTMENT_GAP_M := 0.6
const OUTER_LANDING_M := 3.6
## The compartments' boarding platforms stand this high over the deck.
const PLATFORM_RISE_M := 0.9
## The berth side's black fender panels: their spacing along the float.
const FENDER_SPACING_M := 3.0
## Guide piles and dolphin piles: radius and the top of the steel below the cap.
const PILE_RADIUS_M := 0.38
const PILE_TOP_ABOVE_WATER_M := 8.0
const RAIL_HEIGHT_M := 1.07
## The breakwater: its cap beam's top over the water, the cap's depth and width,
## the panelled screen's width and depth below the water, and the panel joints.
const BREAKWATER_TOP_M := 3.0
const BREAKWATER_CAP_M := 1.15
const BREAKWATER_WIDTH_M := 1.3
const BREAKWATER_SCREEN_WIDTH_M := 1.0
const BREAKWATER_FOOT_M := 2.5
const BREAKWATER_PANEL_M := 2.6
## The Sammy J (AIS about 16 m by 6 m, draught 0.7 m; a 48-passenger Fyfe Class
## catamaran): half her beam, her length, her main deck and bulwark top aft over
## the waterline (the bulwark rises toward the bow, Aug 2024), and her cabin, the
## upper deck's forward block and the wheelhouse (Aug 2024, Jun 2025, Feb 2022).
const BOAT_HALF_BEAM_M := 3.0
const BOAT_LENGTH_M := 16.0
const BOAT_DECK_M := 1.55
const BOAT_SHEER_M := 2.15
const SHEER_RISE_M := 0.5
const CABIN_AFT_X := -4.6
const CABIN_FORE_X := 4.6
const CABIN_ROOF_M := 3.75
const UPPER_DECK_M := 3.85
const BLOCK_AFT_X := -0.9
const BLOCK_TOP_M := 5.05
const WHEELHOUSE_ROOF_M := 6.35
## Demi-hull layout: its middle off the centreline and its outer and inner half
## widths; the tunnel between the hulls ends at the bow at TUNNEL_BOW_X, its roof
## low over the water.
const HULL_MID_M := 2.05
const HULL_OUTER_M := 0.95
const HULL_INNER_M := 0.95
const TUNNEL_BOW_X := 6.2
const TUNNEL_ROOF_M := 0.55
## Forward of this the hull collision follows each bow's own shape.
const BOW_COLLISION_X := 4.0

## Colours (sRGB). The dock: blue-grey steel sides, darker blue-grey deck with
## a paler central walkway, a yellow edge line, white rails and gangway, black
## fender panels and foam (owner frames received 2026-11-07).
const STEEL := Color(0.58, 0.64, 0.69)
const STEEL_DARK := Color(0.29, 0.32, 0.35)
const GROWTH := Color(0.15, 0.17, 0.15)
const DECK_PLATE := Color(0.4, 0.45, 0.5)
const DECK_WALK := Color(0.55, 0.59, 0.62)
const SAFETY_YELLOW := Color(0.92, 0.76, 0.12)
const RAIL_WHITE := Color(0.9, 0.91, 0.9)
const FENDER_BLACK := Color(0.06, 0.06, 0.065)
const PILE_GREY := Color(0.66, 0.67, 0.68)
const CAP_WHITE := Color(0.93, 0.93, 0.92)
const GRATING := Color(0.55, 0.57, 0.58)
const LINE_DARK := Color(0.16, 0.15, 0.13)
const BUOY_ORANGE := Color(0.95, 0.38, 0.1)
const LANTERN := Color(0.2, 0.21, 0.22)
const LENS := Color(0.86, 0.85, 0.78)
## The breakwater's light concrete cap, its panelled screen and their joints.
const CONCRETE_CAP := Color(0.8, 0.79, 0.75)
const CONCRETE_PANEL := Color(0.72, 0.71, 0.67)
const CONCRETE_JOINT := Color(0.47, 0.47, 0.45)
## The boat: white hulls and cabin, a navy hull band and an orange flash aft, a
## dark bottom, forefoot and tunnel, an orange wheelhouse, stainless rails, blue
## fenders. Alpha marks the finish for ferry_boat.gdshader: 1 paint, 0.5 glass, 0 matte.
const HULL_WHITE := Color(0.93, 0.93, 0.91, 1.0)
const NAVY := Color(0.07, 0.11, 0.25, 1.0)
const FLASH_ORANGE := Color(0.92, 0.43, 0.13, 1.0)
const BOTTOM := Color(0.07, 0.07, 0.08, 0.0)
const TUNNEL := Color(0.08, 0.08, 0.09, 0.0)
const BOAT_DECK := Color(0.62, 0.63, 0.61, 0.0)
const RUB_GREY := Color(0.78, 0.79, 0.78, 1.0)
const GLASS := Color(0.09, 0.11, 0.13, 0.5)
const FRAME := Color(0.32, 0.33, 0.34, 1.0)
const WHEELHOUSE_ORANGE := Color(0.9, 0.41, 0.13, 1.0)
## The wheelhouse roof's crown inside its orange visor (owner aerial).
const ROOF_GREY := Color(0.79, 0.8, 0.81, 1.0)
const STAINLESS := Color(0.82, 0.83, 0.84, 1.0)
const FENDER_BLUE := Color(0.08, 0.28, 0.7, 1.0)
const VENT_GREY := Color(0.56, 0.57, 0.58, 1.0)
const NET_YELLOW := Color(0.95, 0.8, 0.12, 1.0)
const DOORWAY := Color(0.1, 0.1, 0.11, 0.0)


## The scenery for one validated ferry_terminal section: {ok, node, mesh_instances,
## surfaces, triangles, static_bodies, shapes} or {ok: false, message}. buildings
## holds the installed canopy family pier the gangway hangs from.
static func build(section: Dictionary, buildings: Node3D) -> Dictionary:
	var pier := _canopy_pier(buildings)
	if not pier.ok:
		return pier
	var dock := Dock.new(section)
	if not dock.problem.is_empty():
		return {"ok": false, "message": dock.problem}
	var root := Node3D.new()
	root.name = "FerryTerminal"
	root.set_meta("source_keys", [section["float"].source_key, section.gangway.source_key] + section.dolphins.map(func(d: Dictionary) -> String: return str(d.source_key)))
	root.set_meta("derived_object_key", "context:ferry-terminal")
	root.set_meta("dimensions", "production_inference_from_dated_references")
	var report := {"ok": true, "node": root, "mesh_instances": 0, "surfaces": 0, "triangles": 0, "static_bodies": 0, "shapes": 0}
	var dock_material := StandardMaterial3D.new()
	dock_material.resource_name = "ferry_dock"
	dock_material.albedo_texture = LIVERY
	dock_material.vertex_color_use_as_albedo = true
	dock_material.vertex_color_is_srgb = true
	dock_material.roughness = 0.74
	dock_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC

	var b: RefCounted = BUILDER.new(CELL_WHITE)
	var body := _solid_body("FerryDockCollision", [section["float"].source_key, section.gangway.source_key], "context:ferry-terminal:dock")
	_float(b, body, dock)
	_fenders(b, body, dock)
	_piles(b, body, dock, section.dolphins)
	_gangway(b, body, dock, section.gangway, float(pier.deck_y), float(pier.inset))
	_lantern_posts(b, dock)
	var dock_mesh: ArrayMesh = b.commit(dock_material, dock_material)
	dock_mesh.resource_name = "ferry_dock"
	_add_mesh(root, "FerryDock", dock_mesh, report)
	root.add_child(body)

	var breakwater := _breakwater(section.breakwater, dock.water_y, dock_material, report)
	root.add_child(breakwater)
	var boat := _boat(dock, str(section.stop.source_key), report)
	root.add_child(boat)
	for collision: StaticBody3D in [body, breakwater.get_node("BreakwaterCollision") as StaticBody3D, boat.get_node("SammyJCollision") as StaticBody3D]:
		report.static_bodies += 1
		report.shapes += collision.get_child_count()
	root.set_meta("ferry_triangles", report.triangles)
	return report


## The installed canopy family pier: its deck height and the config's deck inset
## (how far inside the frozen outline its deck ends).
static func _canopy_pier(buildings: Node3D) -> Dictionary:
	for node: Node in buildings.find_children("SharedPier_" + CANOPY_SOURCE_KEY, "Node3D", true, false):
		if str(node.get_meta("source_key", "")) == CANOPY_SOURCE_KEY and bool(node.get_meta("build_valid", false)) and node.has_meta("pier_deck_y"):
			var config: Variant = JSON.parse_string(FileAccess.get_file_as_string(CANOPY_CONFIG))
			var inset := float(config.get("deck", {}).get("inset", NAN)) if config is Dictionary else NAN
			var deck_y := float(node.get_meta("pier_deck_y"))
			if not is_finite(inset) or not is_finite(deck_y):
				break
			return {"ok": true, "deck_y": deck_y, "inset": inset}
	return {"ok": false, "message": "The ferry gangway's pier (%s) is not installed" % CANOPY_SOURCE_KEY}


## The float's frame: s along it from the gangway's landing end, z across it
## (az = the along axis x up), heights in world y. berth is +1 or -1: the side
## (sign of z) that holds the ferry stop.
class Dock:
	var problem := ""
	var origin := Vector3.ZERO
	var ax := Vector3.ZERO
	var az := Vector3.ZERO
	var berth := 1.0
	var length := 0.0
	var half_width := 0.0
	var water_y := 0.0
	var deck_y := 0.0
	var stop_s := 0.0
	var gangway_z := 0.0

	func _init(section: Dictionary) -> void:
		var berth_side: Array = section["float"].berth_side_xz
		var far_side: Array = section["float"].far_side_xz
		var bl := Vector2(berth_side[0][0], berth_side[0][1])
		var bf := Vector2(berth_side[1][0], berth_side[1][1])
		var fl := Vector2(far_side[0][0], far_side[0][1])
		var ff := Vector2(far_side[1][0], far_side[1][1])
		var landing := (bl + fl) * 0.5
		var far := (bf + ff) * 0.5
		var along := (far - landing).normalized()
		origin = Vector3(landing.x, 0.0, landing.y)
		ax = Vector3(along.x, 0.0, along.y)
		az = ax.cross(Vector3.UP).normalized()
		length = landing.distance_to(far)
		half_width = (bl.distance_to(fl) + bf.distance_to(ff)) * 0.25
		var across := Vector3(bl.x - fl.x, 0.0, bl.y - fl.y)
		berth = 1.0 if across.dot(az) > 0.0 else -1.0
		water_y = float(section.water_y_m)
		deck_y = water_y + FLOAT_FREEBOARD_M
		var stop := Vector3(section.stop.xz[0], 0.0, section.stop.xz[1])
		stop_s = (stop - origin).dot(ax)
		var bottom := Vector3(section.gangway.bottom_xz[0], 0.0, section.gangway.bottom_xz[1])
		gangway_z = (bottom - origin).dot(az)
		# The boat lies with her stern at the stop: it must leave her on the float.
		if not is_finite(length) or length < 30.0 or half_width < 5.0 or stop_s < BOAT_LENGTH_M + 2.0 or stop_s > length or absf(gangway_z) > AISLE_HALF_M:
			problem = "The ferry float frame is not usable (length %.2f, half width %.2f, stop at %.2f, gangway at %.2f)" % [length, half_width, stop_s, gangway_z]

	func at(s: float, z: float, y: float) -> Vector3:
		return origin + ax * s + az * z + Vector3(0.0, y, 0.0)

	func basis() -> Basis:
		return Basis(ax, Vector3.UP, az)


# ------------------------------------------------------------------ helpers

static func _add_mesh(parent: Node3D, mesh_name: String, mesh: ArrayMesh, report: Dictionary) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = mesh_name
	instance.mesh = mesh
	parent.add_child(instance)
	report.mesh_instances += 1
	report.surfaces += mesh.get_surface_count()
	for surface in mesh.get_surface_count():
		report.triangles += int(mesh.surface_get_array_index_len(surface) / 3.0)
	return instance


static func _solid_body(body_name: String, source_keys: Array, object_key: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = body_name
	body.collision_layer = SOLID_LAYERS
	body.collision_mask = 0
	body.set_meta("receiver_kind", "none")
	body.set_meta("opaque", true)
	body.set_meta("source_keys", source_keys)
	body.set_meta("derived_object_key", object_key)
	return body


static func _box_shape(body: StaticBody3D, center: Vector3, basis: Basis, size: Vector3) -> void:
	var shape := BoxShape3D.new()
	shape.size = size
	var holder := CollisionShape3D.new()
	holder.name = "Box%d" % body.get_child_count()
	holder.shape = shape
	holder.transform = Transform3D(basis.orthonormalized(), center)
	body.add_child(holder)


static func _convex_shape(body: StaticBody3D, points: PackedVector3Array) -> void:
	var shape := ConvexPolygonShape3D.new()
	shape.points = points
	var holder := CollisionShape3D.new()
	holder.name = "Convex%d" % body.get_child_count()
	holder.shape = shape
	body.add_child(holder)


static func _cylinder_shape(body: StaticBody3D, center: Vector3, radius: float, height: float) -> void:
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	var holder := CollisionShape3D.new()
	holder.name = "Cylinder%d" % body.get_child_count()
	holder.shape = shape
	holder.position = center
	body.add_child(holder)


## A quad a, b, c, d (round its edge, a-b along the bottom as seen from outside)
## showing the atlas cell, facing outward.
static func _label(b: RefCounted, corners: Array[Vector3], cell: Rect2, color: Color, outward: Vector3) -> void:
	# Sample a little inside the cell, so filtering never reaches a neighbouring cell.
	var inset := Vector2(minf(LABEL_INSET_UV, cell.size.x * 0.25), minf(LABEL_INSET_UV, cell.size.y * 0.25))
	var low := cell.position + inset
	var high := cell.end - inset
	var uvs := [Vector2(low.x, high.y), Vector2(high.x, high.y), Vector2(high.x, low.y), Vector2(low.x, low.y)]
	var normal := outward.normalized()
	var ids: Array[int] = []
	for index in 4:
		ids.append(b.vertex(0, corners[index], normal, uvs[index], color))
	b.triangle(0, ids[0], ids[1], ids[2], normal)
	b.triangle(0, ids[0], ids[2], ids[3], normal)


## A white pipe rail from p to q (deck points): posts every `spacing`, a top
## rail and two mid rails, height `height`, with a thin solid along it.
static func _pipe_rail(b: RefCounted, body: StaticBody3D, p: Vector3, q: Vector3, height: float, spacing: float, color: Color) -> void:
	var run := q - p
	var length := run.length()
	if length < 0.2:
		return
	var posts := maxi(1, int(ceil(length / spacing)))
	for index in posts + 1:
		var foot := p + run * (float(index) / float(posts))
		b.tube(PackedVector3Array([foot, foot + Vector3.UP * height]), PackedFloat32Array([0.026, 0.026]), 6, color, CELL_WHITE, false, true)
	for rise: float in [height, height * 0.62, height * 0.3]:
		var r := 0.03 if rise == height else 0.018
		b.tube(PackedVector3Array([p + Vector3.UP * rise, q + Vector3.UP * rise]), PackedFloat32Array([r, r]), 6, color, CELL_WHITE, true, true)
	var along := run / length
	var flat := Vector3(along.x, 0.0, along.z).normalized()
	_box_shape(body, (p + q) * 0.5 + Vector3.UP * height * 0.5, Basis(along, Vector3.UP, flat.cross(Vector3.UP)), Vector3(length, height, 0.06))


# ------------------------------------------------------------------ the dock

## The steel float: blue-grey sides with a growth line at the water, a darker
## deck under a paler central walkway its whole length, a yellow edge line, white
## edge rails; a long open deck at the gangway end with bollards, cleats and
## boxes, three railed switchback ramp compartments each side, and a short landing
## at the outer end (owner aerials and low view received 2026-11-07; Sep 2026
## pano). Its bay faces and the compartments' exact ramps are inferred.
static func _float(b: RefCounted, body: StaticBody3D, d: Dock) -> void:
	var hw := d.half_width
	var top := d.deck_y
	var bottom := d.water_y - FLOAT_DRAFT_M
	var corners := [Vector2(0.0, -hw), Vector2(d.length, -hw), Vector2(d.length, hw), Vector2(0.0, hw)]
	var middle := d.at(d.length * 0.5, 0.0, 0.0)
	for index in 4:
		var p: Vector2 = corners[index]
		var q: Vector2 = corners[(index + 1) % 4]
		var outward := d.at((p.x + q.x) * 0.5, (p.y + q.y) * 0.5, 0.0) - middle
		outward.y = 0.0
		outward = outward.normalized()
		b.quad_face(d.at(p.x, p.y, bottom), d.at(q.x, q.y, bottom), d.at(q.x, q.y, top), d.at(p.x, p.y, top), STEEL, outward)
		# Growth at the waterline and the rubbing strip under the deck edge.
		var off := outward * 0.02
		b.quad_face(d.at(p.x, p.y, d.water_y - 0.25) + off, d.at(q.x, q.y, d.water_y - 0.25) + off, d.at(q.x, q.y, d.water_y + 0.15) + off, d.at(p.x, p.y, d.water_y + 0.15) + off, GROWTH, outward)
		b.quad_face(d.at(p.x, p.y, top - 0.14) + off * 2.0, d.at(q.x, q.y, top - 0.14) + off * 2.0, d.at(q.x, q.y, top - 0.02) + off * 2.0, d.at(p.x, p.y, top - 0.02) + off * 2.0, STEEL_DARK, outward)
	b.quad_face(d.at(0.0, -hw, top), d.at(d.length, -hw, top), d.at(d.length, hw, top), d.at(0.0, hw, top), DECK_PLATE, Vector3.UP)
	var lift := 0.004
	b.quad_face(d.at(0.3, -AISLE_HALF_M, top + lift), d.at(d.length - 0.3, -AISLE_HALF_M, top + lift), d.at(d.length - 0.3, AISLE_HALF_M, top + lift), d.at(0.3, AISLE_HALF_M, top + lift), DECK_WALK, Vector3.UP)
	# The yellow edge line round the deck.
	var e := 0.16
	var w := 0.1
	for strip: Array in [[e, -hw + e, d.length - e, -hw + e + w], [e, hw - e - w, d.length - e, hw - e], [e, -hw + e, e + w, hw - e], [d.length - e - w, -hw + e, d.length - e, hw - e]]:
		var s0: float = strip[0]
		var z0: float = strip[1]
		var s1: float = strip[2]
		var z1: float = strip[3]
		b.quad_face(d.at(s0, z0, top + lift * 2.0), d.at(s1, z0, top + lift * 2.0), d.at(s1, z1, top + lift * 2.0), d.at(s0, z1, top + lift * 2.0), SAFETY_YELLOW, Vector3.UP)
	_box_shape(body, d.at(d.length * 0.5, 0.0, (top + bottom) * 0.5), d.basis(), Vector3(d.length, top - bottom, hw * 2.0))
	# Three compartments each side between the open deck and the outer landing.
	var open_s := d.length * OPEN_DECK_SHARE
	var landing_s := d.length - OUTER_LANDING_M
	var span := (landing_s - open_s - COMPARTMENT_GAP_M * float(COMPARTMENTS)) / float(COMPARTMENTS)
	for index in COMPARTMENTS:
		var s0 := open_s + float(index) * (span + COMPARTMENT_GAP_M)
		for side: float in [d.berth, -d.berth]:
			_compartment(b, body, d, s0, s0 + span, side, side == d.berth)
	# Edge rails: along the open deck and the outer landing on both sides, across
	# the outer end, and across the gangway end either side of the gangway.
	var berth_z := d.berth * (hw - 0.62)
	var far_z := -d.berth * (hw - 0.3)
	for side_z: float in [berth_z, far_z]:
		_pipe_rail(b, body, d.at(0.35, side_z, top), d.at(open_s - 0.1, side_z, top), RAIL_HEIGHT_M, 1.6, RAIL_WHITE)
		_pipe_rail(b, body, d.at(landing_s, side_z, top), d.at(d.length - 0.35, side_z, top), RAIL_HEIGHT_M, 1.6, RAIL_WHITE)
	_pipe_rail(b, body, d.at(d.length - 0.3, far_z, top), d.at(d.length - 0.3, berth_z, top), RAIL_HEIGHT_M, 1.6, RAIL_WHITE)
	for edge: Array in [[far_z, d.gangway_z - 1.25 * d.berth], [d.gangway_z + 1.25 * d.berth, berth_z]]:
		_pipe_rail(b, body, d.at(0.3, float(edge[0]), top), d.at(0.3, float(edge[1]), top), RAIL_HEIGHT_M, 1.6, RAIL_WHITE)
	# Small white bollards over the open deck and on the outer landing, cleats at
	# their berth edges, and the open deck's two white utility boxes (owner aerial).
	for spot: Vector2 in [Vector2(open_s - 2.0, 3.6), Vector2(open_s - 6.5, 3.6), Vector2(open_s - 11.0, 3.6), Vector2(d.length - 1.8, 3.6), Vector2(open_s - 2.0, -3.6), Vector2(open_s - 6.5, -3.6), Vector2(open_s - 11.0, -3.6), Vector2(d.length - 1.8, -3.6), Vector2(1.6, 4.6), Vector2(1.6, -4.6)]:
		var foot := d.at(spot.x, spot.y, top)
		b.tube(PackedVector3Array([foot, foot + Vector3.UP * 0.42]), PackedFloat32Array([0.12, 0.12]), 10, CAP_WHITE, CELL_WHITE, false, true)
	for cleat_s: float in [2.5, open_s - 9.0, open_s - 4.5, open_s - 1.0, d.length - 1.0]:
		b.box(d.at(cleat_s, d.berth * (hw - 0.3), top + 0.08), d.basis(), Vector3(0.36, 0.16, 0.12), STEEL_DARK, CELL_WHITE)
	for box_spot: Vector2 in [Vector2(open_s - 3.6, -d.berth * 4.9), Vector2(5.5, -d.berth * 2.6)]:
		var box_center := d.at(box_spot.x, box_spot.y, top + 0.45)
		b.box(box_center, d.basis(), Vector3(0.9, 0.9, 0.6), CAP_WHITE, CELL_WHITE)
		_box_shape(body, box_center, d.basis(), Vector3(0.9, 0.9, 0.6))
	for buoy: Vector2 in [Vector2(open_s - 3.0, far_z), Vector2(1.8, far_z), Vector2(d.length - 2.0, berth_z)]:
		var hub := d.at(buoy.x, buoy.y - signf(buoy.y) * 0.06, top + 0.68)
		var ring := PackedVector3Array()
		var radii := PackedFloat32Array()
		for step in 17:
			var angle := TAU * float(step) / 16.0
			ring.append(hub + d.ax * cos(angle) * 0.3 + Vector3.UP * sin(angle) * 0.3)
			radii.append(0.055)
		b.tube(ring, radii, 6, BUOY_ORANGE, CELL_WHITE, false, false)



## One railed ramp compartment on side `side` (+1/-1 in z) between s0 and s1: a
## boarding platform PLATFORM_RISE_M up along the deck edge, reached from the
## walkway by a switchback, two runs rising along the inner lanes and turning on
## a landing at the compartment's outer-landing end. White pipe rails line every
## run, the landing and the platform; on the berth side the platform's edge opens
## in its middle for boarding. Production inference from the owner aerials and
## low view (2026-11-07) and the Sep 2026 float pano.
static func _compartment(b: RefCounted, body: StaticBody3D, d: Dock, s0: float, s1: float, side: float, berth_side: bool) -> void:
	var top := d.deck_y
	var high := top + PLATFORM_RISE_M
	var mid := top + PLATFORM_RISE_M * 0.5
	var basis := d.basis()
	var hw := d.half_width
	var lane_a := [AISLE_HALF_M + 0.35, AISLE_HALF_M + 1.6]
	var lane_b := [AISLE_HALF_M + 1.8, AISLE_HALF_M + 3.05]
	var edge := hw - 0.1
	var landing := 1.4
	var run_end := s1 - landing
	var z := func(v: float) -> float: return side * v
	# Platform along the deck edge, contiguous with lane B.
	var platform_center := d.at((s0 + s1) * 0.5, z.call((lane_b[1] + edge) * 0.5), (top + high) * 0.5)
	var platform_size := Vector3(s1 - s0, PLATFORM_RISE_M, edge - float(lane_b[1]))
	b.box(platform_center, basis, platform_size, GRATING, CELL_WHITE)
	_box_shape(body, platform_center, basis, platform_size)
	# Run A from the walkway end at s0 up to the landing; run B from the landing
	# back up to the platform's s0 end.
	for ramp: Array in [[d.at(s0, 0.0, top), d.at(run_end, 0.0, mid), lane_a], [d.at(run_end, 0.0, mid), d.at(s0 + 0.2, 0.0, high), lane_b]]:
		var p: Vector3 = ramp[0]
		var q: Vector3 = ramp[1]
		var lane: Array = ramp[2]
		var slope := (q - p).normalized()
		var normal := d.az.cross(slope).normalized()
		if normal.y < 0.0:
			normal = -normal
		var ramp_basis := Basis(slope, normal, slope.cross(normal).normalized())
		var center: Vector3 = (p + q) * 0.5 + d.az * float(z.call((float(lane[0]) + float(lane[1])) * 0.5)) - normal * 0.05
		var size := Vector3(p.distance_to(q), 0.1, float(lane[1]) - float(lane[0]))
		b.box(center, ramp_basis, size, GRATING, CELL_WHITE)
		_box_shape(body, center, ramp_basis, size)
		_pipe_rail(b, body, p + d.az * float(z.call(float(lane[0]))), q + d.az * float(z.call(float(lane[0]))), RAIL_HEIGHT_M, 1.4, RAIL_WHITE)
	# Lane A's outer rail; lane B's outer edge is the platform's.
	_pipe_rail(b, body, d.at(s0, z.call(lane_a[1]), top), d.at(run_end, z.call(lane_a[1]), mid), RAIL_HEIGHT_M, 1.4, RAIL_WHITE)
	# The turn landing at mid height, railed round its outer end.
	var landing_center := d.at(run_end + landing * 0.5, z.call((lane_a[0] + lane_b[1]) * 0.5), (top + mid) * 0.5)
	var landing_size := Vector3(landing, PLATFORM_RISE_M * 0.5, lane_b[1] - lane_a[0])
	b.box(landing_center, basis, landing_size, GRATING, CELL_WHITE)
	_box_shape(body, landing_center, basis, landing_size)
	_pipe_rail(b, body, d.at(s1, z.call(lane_a[0]), mid), d.at(s1, z.call(lane_b[1]), mid), RAIL_HEIGHT_M, 1.4, RAIL_WHITE)
	_pipe_rail(b, body, d.at(run_end, z.call(lane_a[0]), mid), d.at(s1, z.call(lane_a[0]), mid), RAIL_HEIGHT_M, 1.4, RAIL_WHITE)
	# Platform rails: its inner side beside lane B (open where run B arrives), its
	# two ends, and the deck edge (on the berth side, open in the middle).
	_pipe_rail(b, body, d.at(s0 + 1.6, z.call(lane_b[1]), high), d.at(s1, z.call(lane_b[1]), high), RAIL_HEIGHT_M, 1.4, RAIL_WHITE)
	for end_s: float in [s0, s1]:
		_pipe_rail(b, body, d.at(end_s, z.call(lane_b[1]), high), d.at(end_s, z.call(edge - 0.05), high), RAIL_HEIGHT_M, 1.4, RAIL_WHITE)
	var middle_s := (s0 + s1) * 0.5
	if berth_side:
		_pipe_rail(b, body, d.at(s0, z.call(edge - 0.05), high), d.at(middle_s - 0.8, z.call(edge - 0.05), high), RAIL_HEIGHT_M, 1.4, RAIL_WHITE)
		_pipe_rail(b, body, d.at(middle_s + 0.8, z.call(edge - 0.05), high), d.at(s1, z.call(edge - 0.05), high), RAIL_HEIGHT_M, 1.4, RAIL_WHITE)
	else:
		_pipe_rail(b, body, d.at(s0, z.call(edge - 0.05), high), d.at(s1, z.call(edge - 0.05), high), RAIL_HEIGHT_M, 1.4, RAIL_WHITE)



## Tall black vertical fender panels along both long faces at about 3 m centres,
## on brackets over a dark whaler beam (owner aerial and low view received
## 2026-11-07; Aug 2021, Jun 2025 and Sep 2026 views).
static func _fenders(b: RefCounted, body: StaticBody3D, d: Dock) -> void:
	var basis := d.basis()
	var top := d.deck_y + 1.35
	var foot := d.water_y - 0.6
	var count := int(floor((d.length - 1.6) / FENDER_SPACING_M))
	var first := (d.length - FENDER_SPACING_M * float(count)) * 0.5
	for side: float in [d.berth, -d.berth]:
		var face := side * (d.half_width + FENDER_STANDOFF_M)
		for index in count + 1:
			var s := first + FENDER_SPACING_M * float(index)
			b.box(d.at(s, face - side * 0.09, (foot + top) * 0.5), basis, Vector3(0.6, top - foot, 0.18), FENDER_BLACK, CELL_WHITE)
			for y: float in [d.deck_y - 0.3, d.water_y + 0.1]:
				b.box(d.at(s, side * (d.half_width + FENDER_STANDOFF_M * 0.4), y), basis, Vector3(0.18, 0.18, FENDER_STANDOFF_M * 0.8), STEEL_DARK, CELL_WHITE)
		var whaler := d.at(d.length * 0.5, side * (d.half_width + 0.1), d.deck_y - 0.22)
		b.box(whaler, basis, Vector3(d.length - 0.6, 0.24, 0.2), STEEL_DARK, CELL_WHITE)
		_box_shape(body, d.at(d.length * 0.5, side * (d.half_width + FENDER_STANDOFF_M * 0.5), (foot + top) * 0.5), basis, Vector3(d.length - 0.6, top - foot, FENDER_STANDOFF_M))


## One pile: grey steel from below the water to its top, darker in the tide zone,
## under a white cone cap.
static func _pile(b: RefCounted, body: StaticBody3D, d: Dock, center: Vector3, radius: float) -> void:
	var low := d.water_y - 3.0
	var tide := d.water_y + 0.7
	var top := d.water_y + PILE_TOP_ABOVE_WATER_M
	b.tube(PackedVector3Array([Vector3(center.x, low, center.z), Vector3(center.x, tide, center.z)]), PackedFloat32Array([radius, radius]), 14, GROWTH, CELL_WHITE, false, false)
	b.tube(PackedVector3Array([Vector3(center.x, tide, center.z), Vector3(center.x, top, center.z)]), PackedFloat32Array([radius, radius]), 14, PILE_GREY, CELL_WHITE, false, false)
	b.tube(PackedVector3Array([Vector3(center.x, top, center.z), Vector3(center.x, top + 0.14, center.z), Vector3(center.x, top + 0.95, center.z)]), PackedFloat32Array([radius + 0.03, radius + 0.03, 0.02]), 14, CAP_WHITE, CELL_WHITE, true, false)
	_cylinder_shape(body, Vector3(center.x, (low + top + 0.95) * 0.5, center.z), radius + 0.02, top + 0.95 - low)


## Four guide piles hooped to the float (production inference from the Aug 2021
## views and the aerial's shadows), and the two frozen mooring dolphins: piles in
## black OCEAN DONUT foam drums (Jun 2025, Sep 2026).
static func _piles(b: RefCounted, body: StaticBody3D, d: Dock, dolphins: Array) -> void:
	var berth := d.berth
	var hw := d.half_width
	var out := PILE_RADIUS_M + 0.28
	# Outside the fender panels on both faces.
	var guides := [
		Vector2(2.2, berth * (hw + FENDER_STANDOFF_M + out)),
		Vector2(2.2, -berth * (hw + FENDER_STANDOFF_M + out)),
		Vector2(d.length - 2.6, -berth * (hw + FENDER_STANDOFF_M + out)),
		Vector2(d.length - 0.6, berth * (hw + FENDER_STANDOFF_M + out)),
	]
	for guide: Vector2 in guides:
		var center := d.at(guide.x, guide.y, 0.0)
		_pile(b, body, d, center, PILE_RADIUS_M)
		# The hoop bracket from the float's edge round the pile.
		var edge_z := signf(guide.y) * hw
		var bracket := d.at(guide.x, (edge_z + guide.y) * 0.5, d.deck_y - 0.3)
		b.box(bracket, d.basis(), Vector3(PILE_RADIUS_M * 2.4, 0.5, absf(guide.y - edge_z) + PILE_RADIUS_M), STEEL_DARK, CELL_WHITE)
	for dolphin: Dictionary in dolphins:
		var center := Vector3(float(dolphin.center_xz[0]), 0.0, float(dolphin.center_xz[1]))
		var radius := float(dolphin.radius_m)
		_pile(b, body, d, center, PILE_RADIUS_M)
		var drum_low := d.water_y - 0.6
		var drum_top := d.water_y + 2.55
		b.tube(PackedVector3Array([Vector3(center.x, drum_low, center.z), Vector3(center.x, drum_top - 0.08, center.z), Vector3(center.x, drum_top, center.z)]), PackedFloat32Array([radius, radius, radius - 0.08]), 24, FENDER_BLACK, CELL_WHITE, false, true)
		_cylinder_shape(body, Vector3(center.x, (drum_low + drum_top) * 0.5, center.z), radius, drum_top - drum_low)
		# The stencil, on the side toward the float and on the opposite side.
		var toward := (d.at(d.length * 0.5, 0.0, 0.0) - center)
		toward.y = 0.0
		var heading := atan2(toward.z, toward.x)
		for side: float in [0.0, PI]:
			_drum_label(b, center, radius + 0.012, drum_top - 1.05, drum_top - 0.35, heading + side, 1.15)


## A label wrapped round a vertical drum: the cell across `span` radians centred
## on `angle` (radians from +X toward +Z), between heights y0 and y1.
static func _drum_label(b: RefCounted, center: Vector3, radius: float, y0: float, y1: float, angle: float, span: float) -> void:
	var steps := 8
	# The black middle of the stencil cell, clear of its white neighbours.
	var stencil := CELL_FENDER.grow_individual(-CELL_FENDER.size.x * 0.05, -CELL_FENDER.size.y * 0.12, -CELL_FENDER.size.x * 0.05, -CELL_FENDER.size.y * 0.12)
	for step in steps:
		# Seen from outside, the text runs clockwise seen from above (toward -angle).
		var a0 := angle + span * (0.5 - float(step) / float(steps))
		var a1 := angle + span * (0.5 - float(step + 1) / float(steps))
		var p0 := center + Vector3(cos(a0), 0.0, sin(a0)) * radius
		var p1 := center + Vector3(cos(a1), 0.0, sin(a1)) * radius
		var u0 := stencil.position.x + stencil.size.x * float(step) / float(steps)
		var u1 := stencil.position.x + stencil.size.x * float(step + 1) / float(steps)
		var cell := Rect2(u0, stencil.position.y, u1 - u0, stencil.size.y)
		var mid := (a0 + a1) * 0.5
		var corners: Array[Vector3] = [Vector3(p0.x, y0, p0.z), Vector3(p1.x, y0, p1.z), Vector3(p1.x, y1, p1.z), Vector3(p0.x, y1, p0.z)]
		_label(b, corners, cell, Color.WHITE, Vector3(cos(mid), 0.0, sin(mid)))


## The aluminium gangway from the pier's deck end down to the float's landing
## end: a grated walkway between white Warren-truss sides with a top rail and a
## mid rod, on a hinge plate at the pier and a transition plate on the float
## (Aug 2021 views; OSM w1036802528, about 24 m).
static func _gangway(b: RefCounted, body: StaticBody3D, d: Dock, gangway: Dictionary, pier_deck_y: float, pier_inset: float) -> void:
	var top_xz := Vector3(gangway.top_xz[0], 0.0, gangway.top_xz[1])
	var bottom_xz := Vector3(gangway.bottom_xz[0], 0.0, gangway.bottom_xz[1])
	var level := (bottom_xz - top_xz).normalized()
	var top := top_xz - level * pier_inset + Vector3.UP * pier_deck_y
	var bottom := bottom_xz + level * 0.9 + Vector3.UP * (d.deck_y + 0.1)
	var run := bottom - top
	var length := run.length()
	var g := run / length
	var w := level.cross(Vector3.UP).normalized()
	var n := w.cross(g).normalized()
	if n.y < 0.0:
		n = -n
	var basis := Basis(g, n, g.cross(n).normalized())
	var half := 0.92
	var walk_center := (top + bottom) * 0.5 - n * 0.04
	b.box(walk_center, basis, Vector3(length, 0.08, half * 2.0 - 0.1), RAIL_WHITE.darkened(0.12), CELL_WHITE)
	_box_shape(body, walk_center, basis, Vector3(length, 0.1, half * 2.0))
	var panels := maxi(4, int(round(length / 1.55)))
	for side: float in [-1.0, 1.0]:
		var edge := w * side * half
		var low_chord := top + edge + n * 0.08
		b.box((low_chord + bottom + edge + n * 0.08) * 0.5, basis, Vector3(length, 0.16, 0.08), RAIL_WHITE, CELL_WHITE)
		var rail_top := n * 1.12
		b.tube(PackedVector3Array([top + edge + rail_top, bottom + edge + rail_top]), PackedFloat32Array([0.045, 0.045]), 8, RAIL_WHITE, CELL_WHITE, true, true)
		b.tube(PackedVector3Array([top + edge + n * 0.62, bottom + edge + n * 0.62]), PackedFloat32Array([0.016, 0.016]), 6, RAIL_WHITE, CELL_WHITE, true, true)
		for index in panels + 1:
			var at := top + g * (length * float(index) / float(panels)) + edge
			b.tube(PackedVector3Array([at + n * 0.14, at + rail_top]), PackedFloat32Array([0.03, 0.03]), 6, RAIL_WHITE, CELL_WHITE, false, false)
			if index < panels:
				var next := top + g * (length * float(index + 1) / float(panels)) + edge
				var from := at + n * 0.16 if index % 2 == 0 else at + rail_top
				var to := next + rail_top if index % 2 == 0 else next + n * 0.16
				b.tube(PackedVector3Array([from, to]), PackedFloat32Array([0.026, 0.026]), 6, RAIL_WHITE, CELL_WHITE, false, false)
		_box_shape(body, (top + bottom) * 0.5 + edge + n * 0.6, basis, Vector3(length, 1.2, 0.08))
	# Hinge plate at the pier and transition plate onto the float.
	b.box(top + g * 0.25 + n * 0.02, basis, Vector3(0.6, 0.04, half * 2.0), STEEL_DARK, CELL_WHITE)
	var plate_basis := Basis(level, Vector3.UP, level.cross(Vector3.UP).normalized())
	var plate := bottom_xz + level * 1.6 + Vector3.UP * (d.deck_y + 0.03)
	b.box(plate, plate_basis, Vector3(1.4, 0.06, half * 2.0), GRATING, CELL_WHITE)


## Slim white light posts on the float, each with a small dark cylindrical lantern
## under a flat cap (Feb 2022 view, Sep 2026 pano, owner aerial), along the
## walkway's edges: near the gangway, where the open deck meets the compartments,
## and on the outer landing.
static func _lantern_posts(b: RefCounted, d: Dock) -> void:
	var open_s := d.length * OPEN_DECK_SHARE
	for spot: Vector2 in [Vector2(3.0, 1.45), Vector2(3.0, -1.45), Vector2(open_s - 0.6, 1.45), Vector2(open_s - 0.6, -1.45), Vector2(d.length - 1.4, 1.45), Vector2(d.length - 1.4, -1.45)]:
		var foot := d.at(spot.x, spot.y, d.deck_y)
		b.tube(PackedVector3Array([foot, foot + Vector3.UP * 3.9]), PackedFloat32Array([0.05, 0.04]), 8, RAIL_WHITE, CELL_WHITE, false, false)
		b.tube(PackedVector3Array([foot + Vector3.UP * 3.9, foot + Vector3.UP * 4.0, foot + Vector3.UP * 4.32]), PackedFloat32Array([0.06, 0.11, 0.11]), 10, LANTERN, CELL_WHITE, false, false)
		b.tube(PackedVector3Array([foot + Vector3.UP * 4.04, foot + Vector3.UP * 4.24]), PackedFloat32Array([0.113, 0.113]), 10, LENS, CELL_WHITE, false, false)
		b.tube(PackedVector3Array([foot + Vector3.UP * 4.32, foot + Vector3.UP * 4.37]), PackedFloat32Array([0.16, 0.16]), 10, LANTERN, CELL_WHITE, true, true)


# ------------------------------------------------------------------ the breakwater

## The breakwater (frozen OSM w1011830371): a long straight wall in the water NW
## of the float, a light concrete cap beam over a recessed screen of precast
## panels with dark joints, growth at the waterline, both faces alike (the May
## 2025 Yerba Buena Island profile shows its terminal face; its bay face is
## inferred). Its own node and collision, solid like the float.
static func _breakwater(line: Dictionary, water_y: float, material: Material, report: Dictionary) -> Node3D:
	var node := Node3D.new()
	node.name = "Breakwater"
	node.set_meta("source_keys", [str(line.source_key)])
	node.set_meta("derived_object_key", "context:ferry-terminal:breakwater")
	var a := Vector3(float(line.line_xz[0][0]), 0.0, float(line.line_xz[0][1]))
	var c := Vector3(float(line.line_xz[1][0]), 0.0, float(line.line_xz[1][1]))
	var along := (c - a).normalized()
	var length := a.distance_to(c)
	var across := along.cross(Vector3.UP).normalized()
	var basis := Basis(along, Vector3.UP, across)
	var mid := (a + c) * 0.5
	var b: RefCounted = BUILDER.new(CELL_WHITE)
	var cap_top := water_y + BREAKWATER_TOP_M
	var cap_bottom := cap_top - BREAKWATER_CAP_M
	var foot := water_y - BREAKWATER_FOOT_M
	b.box(mid + Vector3.UP * (cap_top + cap_bottom) * 0.5, basis, Vector3(length, BREAKWATER_CAP_M, BREAKWATER_WIDTH_M), CONCRETE_CAP, CELL_WHITE)
	b.box(mid + Vector3.UP * (cap_bottom + foot) * 0.5, basis, Vector3(length - 0.2, cap_bottom - foot, BREAKWATER_SCREEN_WIDTH_M), CONCRETE_PANEL, CELL_WHITE)
	# The screen's panel joints and the waterline growth on both faces.
	var panels := maxi(1, int(round(length / BREAKWATER_PANEL_M)))
	for side: float in [-1.0, 1.0]:
		var face := across * side * (BREAKWATER_SCREEN_WIDTH_M * 0.5 + 0.008)
		for index in range(1, panels):
			var at := a + along * (length * float(index) / float(panels)) + face
			b.quad_face(at - along * 0.03 + Vector3.UP * (water_y - 0.4), at + along * 0.03 + Vector3.UP * (water_y - 0.4), at + along * 0.03 + Vector3.UP * (cap_bottom - 0.02), at - along * 0.03 + Vector3.UP * (cap_bottom - 0.02), CONCRETE_JOINT, across * side)
		var low := a + along * 0.1 + face * 1.002
		var high := c - along * 0.1 + face * 1.002
		b.quad_face(low + Vector3.UP * (water_y - 0.3), high + Vector3.UP * (water_y - 0.3), high + Vector3.UP * (water_y + 0.3), low + Vector3.UP * (water_y + 0.3), GROWTH, across * side)
		# The drip edge along the cap's underside.
		var lip := across * side * (BREAKWATER_WIDTH_M * 0.5 + 0.004)
		b.quad_face(a + lip + Vector3.UP * cap_bottom, c + lip + Vector3.UP * cap_bottom, c + lip + Vector3.UP * (cap_bottom + 0.08), a + lip + Vector3.UP * (cap_bottom + 0.08), CONCRETE_JOINT, across * side)
	var mesh: ArrayMesh = b.commit(material, material)
	mesh.resource_name = "ferry_breakwater"
	_add_mesh(node, "BreakwaterMesh", mesh, report)
	var body := _solid_body("BreakwaterCollision", [str(line.source_key)], "context:ferry-terminal:breakwater")
	_box_shape(body, mid + Vector3.UP * (cap_top + foot) * 0.5, basis, Vector3(length, cap_top - foot, BREAKWATER_WIDTH_M))
	node.add_child(body)
	return node


# ------------------------------------------------------------------ the boat

## The Sammy J at her berth: alongside the float's stop side, starboard to its
## fenders, bow toward the gangway, her stern at the stop (owner aerials received
## 2026-11-07: on the float's NW face, her stern by the outermost compartment and
## her bow beside the open deck). Her local frame: +X
## forward, +Y up, +Z starboard, origin at the waterline amidships (the rocking's
## pivot).
static func _boat(d: Dock, stop_key: String, report: Dictionary) -> Node3D:
	var heading := -d.ax * d.berth
	var z := d.berth * (d.half_width + FENDER_STANDOFF_M + 0.06 + BOAT_HALF_BEAM_M)
	var origin := d.at(d.stop_s - BOAT_LENGTH_M * 0.5, z, d.water_y)
	var node := Node3D.new()
	node.name = "SammyJ"
	node.transform = Transform3D(Basis(heading, Vector3.UP, heading.cross(Vector3.UP)), origin)
	node.set_meta("source_keys", [stop_key])
	node.set_meta("derived_object_key", "context:ferry-terminal:sammy-j")
	node.set_meta("vessel", "Sammy J (Prop SF), as docked at the Treasure Island float")
	node.set_meta("starboard", "mirrored_inference_of_the_photographed_port_side")
	var b: RefCounted = BUILDER.new(CELL_WHITE)
	var body := _solid_body("SammyJCollision", [stop_key], "context:ferry-terminal:sammy-j")
	_hulls(b, body)
	_transom(b, body)
	_main_deck(b, body)
	_cabin(b, body)
	_upper_block(b, body)
	_wheelhouse(b, body)
	_upper_deck_aft(b, body)
	var material := ShaderMaterial.new()
	material.resource_name = "ferry_boat"
	material.shader = BOAT_SHADER
	material.set_shader_parameter("livery", LIVERY)
	var mesh: ArrayMesh = b.commit(material, material)
	mesh.resource_name = "sammy_j"
	var instance := _add_mesh(node, "SammyJHull", mesh, report)
	# The rocking moves her a few centimetres beyond her still bounds.
	instance.extra_cull_margin = 0.5
	node.add_child(body)
	return node


## How far her sheer (bulwark top) and hull band rise toward the bow above their
## heights aft (Aug 2024 profile; part of that view's rise is her trim underway).
static func _sheer_rise(x: float) -> float:
	var t := clampf((x + 2.0) / (BOAT_LENGTH_M * 0.5 + 2.0), 0.0, 1.0)
	return SHEER_RISE_M * t * t


static func _sheer(x: float) -> float:
	return BOAT_SHEER_M + _sheer_rise(x)


## A demi-hull's shape at x: the outer side's share of its half width (1
## amidships, 0 at the stem), the keel height, and the inner side's share. Broad,
## straight-sided slabs to the waterline (May 2025 bow view); the outer side curves
## in from x = 3 to a raked stem whose forefoot leaves the water about 5.8 m
## forward of amidships (Aug 2024, Jun 2025); the inner side stays straight along
## the tunnel and closes in only forward of its bow face.
static func _hull_plan(x: float) -> Vector3:
	var half := BOAT_LENGTH_M * 0.5
	var t := clampf((x - 3.0) / (half - 3.0), 0.0, 1.0)
	var outer := pow(maxf(0.0, 1.0 - pow(t, 2.2)), 0.6)
	var rise := clampf((x - 3.6) / (half - 3.6), 0.0, 1.0)
	var keel := -0.7 + (_sheer(half) + 0.75) * rise * rise
	var u := clampf((x - TUNNEL_BOW_X) / (half - TUNNEL_BOW_X), 0.0, 1.0)
	var inner := pow(maxf(0.0, 1.0 - u * u), 0.6)
	return Vector3(outer, keel, inner)


## Where the main deck meets the bulwark's inner face at x, on the given side.
static func _deck_edge(x: float, side: float) -> float:
	return side * (HULL_MID_M + (HULL_OUTER_M - 0.08) * _hull_plan(x).x)


## The two demi-hulls lofted through stations: the outer side in the livery's bands
## (dark bottom, white, navy, white bulwark), swept up toward the bow with the
## sheer, the forefoot dark; the dark tunnel sides; the bow tips' tops; the orange
## flash aft as a trapezoid above and below the unbroken navy band (Aug 2024).
static func _hulls(b: RefCounted, body: StaticBody3D) -> void:
	var stations := [-8.0, -6.0, -4.0, -2.0, 0.0, 2.0, 3.0, 3.8, 4.6, 5.2, 5.8, TUNNEL_BOW_X, TUNNEL_BOW_X + 0.01, 6.7, 7.1, 7.45, 7.75, 7.92, 8.0]
	var band_colors := [HULL_WHITE, NAVY, HULL_WHITE, BOTTOM]
	for side: float in [-1.0, 1.0]:
		var rings: Array = []
		for x: float in stations:
			var plan := _hull_plan(x)
			var rise := _sheer_rise(x)
			var cap := _sheer(x)
			var outer_z := side * (HULL_MID_M + HULL_OUTER_M * plan.x)
			var ring: Array[Vector3] = []
			# Outer side top down: bulwark top, navy top, navy bottom, bottom paint, chine.
			for y: float in [cap, 1.5 + 1.3 * rise, 1.02 + 1.3 * rise, 0.38, 0.1]:
				ring.append(Vector3(x, minf(maxf(y, plan.y), cap), outer_z))
			ring.append(Vector3(x, minf(plan.y, cap), side * HULL_MID_M))
			var inner_z := side * (HULL_MID_M - HULL_INNER_M * plan.z)
			ring.append(Vector3(x, minf(maxf(0.1, plan.y), cap), side * (HULL_MID_M - (HULL_INNER_M - 0.05) * plan.z)))
			ring.append(Vector3(x, minf(maxf(0.35, plan.y), cap), inner_z))
			# Forward of the tunnel's bow face the inner side rises to the bulwark top
			# through the navy band, which wraps round each bow (owner bow view).
			if x <= TUNNEL_BOW_X:
				var tunnel_top := minf(maxf(TUNNEL_ROOF_M, plan.y), cap)
				ring.append(Vector3(x, tunnel_top, inner_z))
				ring.append(Vector3(x, tunnel_top, inner_z))
				ring.append(Vector3(x, tunnel_top, inner_z))
			else:
				ring.append(Vector3(x, minf(maxf(1.02 + 1.3 * rise, plan.y), cap), inner_z))
				ring.append(Vector3(x, minf(maxf(1.5 + 1.3 * rise, plan.y), cap), inner_z))
				ring.append(Vector3(x, cap, inner_z))
			rings.append(ring)
		# Collision for the bow forward of the hull box: this demi-hull's own points.
		var bow_points := PackedVector3Array()
		for index in stations.size():
			if float(stations[index]) >= BOW_COLLISION_X:
				var bow_ring: Array[Vector3] = rings[index]
				for point: Vector3 in bow_ring:
					bow_points.append(point)
				var x_bow := float(stations[index])
				bow_points.append(Vector3(x_bow, _sheer(x_bow), side * (HULL_MID_M - HULL_INNER_M * _hull_plan(x_bow).z)))
		_convex_shape(body, bow_points)
		for index in stations.size() - 1:
			var a: Array[Vector3] = rings[index]
			var c: Array[Vector3] = rings[index + 1]
			var x_mid := (float(stations[index]) + float(stations[index + 1])) * 0.5
			for segment in a.size() - 1:
				# The inner side's step from the tunnel roof up to the bow tip happens
				# within the tunnel's bow face, which covers it: no sliver face there.
				if segment >= 6 and float(stations[index + 1]) - float(stations[index]) < 0.05:
					continue
				# Outer bands, then the keel and inner chine in the dark bottom, then the
				# inner side: dark tunnel under the deck, the bands again on the bow tips.
				var color: Color = band_colors[mini(segment, 3)] if segment < 4 else BOTTOM
				if segment >= 7:
					color = TUNNEL if x_mid <= TUNNEL_BOW_X else [BOTTOM, NAVY, HULL_WHITE][segment - 7]
				# The bottom paint sweeps up over the forefoot (the dark bows).
				if segment == 2 and x_mid > 5.0:
					color = BOTTOM
				var p0 := a[segment]
				var p1 := c[segment]
				var p2 := c[segment + 1]
				var p3 := a[segment + 1]
				var normal := (p1 - p0).cross(p3 - p0)
				if normal.length_squared() < 1e-10:
					normal = (p2 - p3).cross(p0 - p3)
				if normal.length_squared() < 1e-10:
					continue
				var center := (p0 + p1 + p2 + p3) * 0.25
				if normal.dot(center - Vector3(x_mid, 0.6, side * HULL_MID_M)) < 0.0:
					normal = -normal
				b.quad_face(p0, p1, p2, p3, color, normal)
		# The bow tips' tops at the sheer, forward of the tunnel's bow face.
		for index in range(stations.find(TUNNEL_BOW_X + 0.01), stations.size() - 1):
			var xa: float = stations[index]
			var xc: float = stations[index + 1]
			var pa := _hull_plan(xa)
			var pc := _hull_plan(xc)
			b.quad_face(Vector3(xa, _sheer(xa), side * (HULL_MID_M + HULL_OUTER_M * pa.x)), Vector3(xc, _sheer(xc), side * (HULL_MID_M + HULL_OUTER_M * pc.x)),
				Vector3(xc, _sheer(xc), side * (HULL_MID_M - HULL_INNER_M * pc.z)), Vector3(xa, _sheer(xa), side * (HULL_MID_M - HULL_INNER_M * pa.z)), HULL_WHITE, Vector3.UP)
		# Rub rail at the navy band's top and the cap rail on the bulwark.
		for spec: Array in [[1.5, 1.3, 0.035], [0.0, 1.0, -0.04]]:
			var path := PackedVector3Array()
			var radii := PackedFloat32Array()
			for x: float in stations:
				var plan := _hull_plan(x)
				var y := float(spec[0]) + float(spec[1]) * _sheer_rise(x) if float(spec[0]) > 0.0 else _sheer(x) - 0.02
				if y < plan.y + 0.05 or plan.x < 0.05:
					break
				path.append(Vector3(x, y, side * (HULL_MID_M + (HULL_OUTER_M + float(spec[2])) * plan.x)))
				radii.append(0.045 if float(spec[0]) > 0.0 else 0.06)
			if path.size() >= 2:
				b.tube(path, radii, 6, RUB_GREY, CELL_WHITE, true, true)
		# The orange flash aft: a trapezoid above the navy band and one below it.
		var flash_z := side * (HULL_MID_M + HULL_OUTER_M + 0.012)
		var outward := Vector3(0.0, 0.0, side)
		var navy_top := 1.5 + 1.3 * _sheer_rise(-2.6)
		var navy_bottom := 1.02 + 1.3 * _sheer_rise(-2.6)
		var parts := [[_sheer(-2.6) - 0.03, -3.4, -1.9, navy_top + 0.02, -3.32, -1.98], [navy_bottom - 0.02, -3.25, -2.05, 0.4, -3.12, -2.18]]
		for part: Array in parts:
			var y0: float = part[3]
			var y1: float = part[0]
			var bl := Vector3(float(part[4]), y0, flash_z)
			var br := Vector3(float(part[5]), y0, flash_z)
			var tr := Vector3(float(part[2]), y1, flash_z)
			var tl := Vector3(float(part[1]), y1, flash_z)
			b.quad_face(bl, br, tr, tl, FLASH_ORANGE, outward)
		# SAMMY J near the bow on the white bulwark band, following the hull's curve.
		var name_x := [5.6, 5.4, 5.2, 5.0, 4.8]
		for step in name_x.size() - 1:
			var xa: float = name_x[step]
			var xb: float = name_x[step + 1]
			var za := side * (HULL_MID_M + HULL_OUTER_M * _hull_plan(xa).x + 0.015)
			var zb := side * (HULL_MID_M + HULL_OUTER_M * _hull_plan(xb).x + 0.015)
			var ya := 1.5 + 1.3 * _sheer_rise(xa) + 0.12
			var yb := 1.5 + 1.3 * _sheer_rise(xb) + 0.12
			var u0 := float(step) / float(name_x.size() - 1)
			var u1 := float(step + 1) / float(name_x.size() - 1)
			var corners: Array[Vector3] = [Vector3(xa, ya, za), Vector3(xb, yb, zb), Vector3(xb, yb + 0.2, zb), Vector3(xa, ya + 0.2, za)]
			# Port reads bow to stern, starboard stern to bow.
			if side > 0.0:
				u0 = 1.0 - u0
				u1 = 1.0 - u1
				corners = [Vector3(xb, yb, zb), Vector3(xa, ya, za), Vector3(xa, ya + 0.2, za), Vector3(xb, yb + 0.2, zb)]
			var cell := Rect2(CELL_HULL_NAME.position.x + CELL_HULL_NAME.size.x * minf(u0, u1), CELL_HULL_NAME.position.y, CELL_HULL_NAME.size.x * absf(u1 - u0), CELL_HULL_NAME.size.y)
			_label(b, corners, cell, HULL_WHITE, outward)
		# Blue fender buoys over the navy band on their lines (port side, outboard;
		# her starboard side lies against the float's fender panels).
		if side < 0.0:
			for x: float in [-0.6, 2.6]:
				var hang := Vector3(x, 1.26 + 1.3 * _sheer_rise(x), side * (HULL_MID_M + HULL_OUTER_M + 0.17))
				b.tube(PackedVector3Array([hang - Vector3(0.36, 0.0, 0.0), hang + Vector3(0.36, 0.0, 0.0)]), PackedFloat32Array([0.15, 0.15]), 10, FENDER_BLUE, CELL_WHITE, true, true)
				b.tube(PackedVector3Array([hang + Vector3(0.0, 0.14, 0.0), Vector3(x, _sheer(x) + 0.02, side * (HULL_MID_M + HULL_OUTER_M - 0.02))]), PackedFloat32Array([0.012, 0.012]), 4, LINE_DARK, CELL_WHITE, false, false)
	# The low dark tunnel roof between the hulls and its bow face (dark under the
	# deck, white bulwark above it).
	var tunnel := HULL_MID_M - HULL_INNER_M
	b.quad_face(Vector3(-8.0, TUNNEL_ROOF_M, -tunnel), Vector3(TUNNEL_BOW_X, TUNNEL_ROOF_M, -tunnel), Vector3(TUNNEL_BOW_X, TUNNEL_ROOF_M, tunnel), Vector3(-8.0, TUNNEL_ROOF_M, tunnel), TUNNEL, Vector3.DOWN)
	b.quad_face(Vector3(TUNNEL_BOW_X, TUNNEL_ROOF_M, -tunnel), Vector3(TUNNEL_BOW_X, BOAT_DECK_M, -tunnel), Vector3(TUNNEL_BOW_X, BOAT_DECK_M, tunnel), Vector3(TUNNEL_BOW_X, TUNNEL_ROOF_M, tunnel), TUNNEL, Vector3.RIGHT)
	var bow_cap := _sheer(TUNNEL_BOW_X)
	b.quad_face(Vector3(TUNNEL_BOW_X, BOAT_DECK_M, -tunnel), Vector3(TUNNEL_BOW_X, bow_cap, -tunnel), Vector3(TUNNEL_BOW_X, bow_cap, tunnel), Vector3(TUNNEL_BOW_X, BOAT_DECK_M, tunnel), HULL_WHITE, Vector3.RIGHT)
	var aft_x := -BOAT_LENGTH_M * 0.5
	_box_shape(body, Vector3((aft_x + BOW_COLLISION_X) * 0.5, (BOAT_DECK_M - 0.75) * 0.5, 0.0), Basis.IDENTITY, Vector3(BOW_COLLISION_X - aft_x, BOAT_DECK_M + 0.75, 6.0))
	for side: float in [-1.0, 1.0]:
		_box_shape(body, Vector3((aft_x + BOW_COLLISION_X) * 0.5, (BOAT_DECK_M + BOAT_SHEER_M) * 0.5, side * 2.96), Basis.IDENTITY, Vector3(BOW_COLLISION_X - aft_x, BOAT_SHEER_M - BOAT_DECK_M, 0.08))


## The stern (Feb 2022): the hulls' aft faces and the cross structure's white
## transom low over the water; above the aft deck an open stainless rail with the
## two lettered sign panels hung on it, a yellow-meshed gate between them, and
## grey grated vent boxes in the corners behind.
static func _transom(b: RefCounted, body: StaticBody3D) -> void:
	var x := -BOAT_LENGTH_M * 0.5
	var deck := BOAT_DECK_M
	b.quad_face(Vector3(x, TUNNEL_ROOF_M, -3.0), Vector3(x, TUNNEL_ROOF_M, 3.0), Vector3(x, deck + 0.05, 3.0), Vector3(x, deck + 0.05, -3.0), HULL_WHITE, Vector3.LEFT)
	for side: float in [-1.0, 1.0]:
		var outer := side * (HULL_MID_M + HULL_OUTER_M)
		var inner := side * (HULL_MID_M - HULL_INNER_M)
		# The hull's aft face under the transom: white above the bottom paint.
		b.quad_face(Vector3(x, 0.38, inner), Vector3(x, 0.38, outer), Vector3(x, TUNNEL_ROOF_M, outer), Vector3(x, TUNNEL_ROOF_M, inner), HULL_WHITE, Vector3.LEFT)
		b.quad_face(Vector3(x, 0.1, inner), Vector3(x, 0.1, outer), Vector3(x, 0.38, outer), Vector3(x, 0.38, inner), BOTTOM, Vector3.LEFT)
		b.triangle_face(Vector3(x, 0.1, inner), Vector3(x, -0.7, side * HULL_MID_M), Vector3(x, 0.1, outer), BOTTOM, Vector3.LEFT)
		# The bulwark's aft end above the deck.
		b.quad_face(Vector3(x, deck, side * 2.92), Vector3(x, deck, outer), Vector3(x, BOAT_SHEER_M, outer), Vector3(x, BOAT_SHEER_M, side * 2.92), HULL_WHITE, Vector3.LEFT)
	# The rail across the stern, posts and two rails, and the meshed gate.
	var rail_x := x + 0.04
	for z: float in [-2.95, -2.0, -0.75, 0.75, 2.0, 2.95]:
		b.tube(PackedVector3Array([Vector3(rail_x, deck, z), Vector3(rail_x, deck + 1.0, z)]), PackedFloat32Array([0.028, 0.028]), 6, STAINLESS, CELL_WHITE, false, true)
	for y: float in [deck + 1.0, deck + 0.55]:
		b.tube(PackedVector3Array([Vector3(rail_x, y, -2.95), Vector3(rail_x, y, 2.95)]), PackedFloat32Array([0.03, 0.03]), 6, STAINLESS, CELL_WHITE, true, true)
	for z: float in [-0.5, -0.25, 0.0, 0.25, 0.5]:
		b.tube(PackedVector3Array([Vector3(rail_x - 0.01, deck + 0.08, z), Vector3(rail_x - 0.01, deck + 0.9, z)]), PackedFloat32Array([0.012, 0.012]), 4, NET_YELLOW, CELL_WHITE, false, false)
	for y: float in [deck + 0.25, deck + 0.45, deck + 0.65, deck + 0.85]:
		b.tube(PackedVector3Array([Vector3(rail_x - 0.01, y, -0.72), Vector3(rail_x - 0.01, y, 0.72)]), PackedFloat32Array([0.012, 0.012]), 4, NET_YELLOW, CELL_WHITE, false, false)
	# The sign panels hung on the rail's aft face.
	for sign: Array in [[-2.9, -0.82, CELL_TRANSOM_PORT], [0.82, 2.9, CELL_TRANSOM_STARBOARD]]:
		var z0: float = sign[0]
		var z1: float = sign[1]
		var cell: Rect2 = sign[2]
		var sign_x := x - 0.02
		b.box(Vector3(sign_x + 0.02, deck + 0.42, (z0 + z1) * 0.5), Basis.IDENTITY, Vector3(0.03, 0.88, z1 - z0), HULL_WHITE, CELL_WHITE)
		var corners: Array[Vector3] = [Vector3(sign_x, deck + 0.0, z0), Vector3(sign_x, deck + 0.0, z1), Vector3(sign_x, deck + 0.84, z1), Vector3(sign_x, deck + 0.84, z0)]
		_label(b, corners, cell, HULL_WHITE, Vector3.LEFT)
	# Grey grated vent boxes in the aft deck's corners.
	for span: Array in [[-2.07, -0.85], [0.85, 2.07]]:
		var z0: float = span[0]
		var z1: float = span[1]
		var center := Vector3(x + 0.75, deck + 0.5, (z0 + z1) * 0.5)
		b.box(center, Basis.IDENTITY, Vector3(0.7, 1.0, z1 - z0), VENT_GREY, CELL_WHITE)
		_box_shape(body, center, Basis.IDENTITY, Vector3(0.7, 1.0, z1 - z0))
		for step in 7:
			var y := deck + 0.18 + 0.11 * float(step)
			b.quad_face(Vector3(x + 0.394, y, z0 + 0.06), Vector3(x + 0.394, y, z1 - 0.06), Vector3(x + 0.394, y + 0.035, z1 - 0.06), Vector3(x + 0.394, y + 0.035, z0 + 0.06), FRAME, Vector3.LEFT)
	_box_shape(body, Vector3(x + 0.04, deck + 0.5, 0.0), Basis.IDENTITY, Vector3(0.08, 1.0, 5.9))


## The main deck inside the bulwarks, the bulwarks' inner faces and the
## stainless rail on their cap, following the hull's plan and sheer.
static func _main_deck(b: RefCounted, body: StaticBody3D) -> void:
	var deck := BOAT_DECK_M
	var edge_x := [-7.95, -4.0, 0.0, 3.0, 3.8, 4.6, 5.2, 5.8, TUNNEL_BOW_X - 0.05]
	for index in edge_x.size() - 1:
		var xa: float = edge_x[index]
		var xb: float = edge_x[index + 1]
		b.quad_face(Vector3(xa, deck, _deck_edge(xa, -1.0)), Vector3(xb, deck, _deck_edge(xb, -1.0)), Vector3(xb, deck, _deck_edge(xb, 1.0)), Vector3(xa, deck, _deck_edge(xa, 1.0)), BOAT_DECK, Vector3.UP)
		for side: float in [-1.0, 1.0]:
			var za := _deck_edge(xa, side)
			var zb := _deck_edge(xb, side)
			b.quad_face(Vector3(xa, deck, za), Vector3(xb, deck, zb), Vector3(xb, _sheer(xb), zb), Vector3(xa, _sheer(xa), za), HULL_WHITE, Vector3(0.0, 0.0, -side))
	var bow_x := TUNNEL_BOW_X - 0.05
	b.quad_face(Vector3(bow_x, deck, _deck_edge(bow_x, -1.0)), Vector3(bow_x, deck, _deck_edge(bow_x, 1.0)), Vector3(bow_x, _sheer(bow_x), _deck_edge(bow_x, 1.0)), Vector3(bow_x, _sheer(bow_x), _deck_edge(bow_x, -1.0)), HULL_WHITE, Vector3.LEFT)
	# The open aft deck's grating, set apart from the cabin (owner astern view).
	var grate_x0 := -BOAT_LENGTH_M * 0.5 + 0.1
	var grate_x1 := CABIN_AFT_X - 0.1
	b.quad_face(Vector3(grate_x0, deck + 0.004, -2.75), Vector3(grate_x1, deck + 0.004, -2.75), Vector3(grate_x1, deck + 0.004, 2.75), Vector3(grate_x0, deck + 0.004, 2.75), VENT_GREY, Vector3.UP)
	var bars := int((grate_x1 - grate_x0) / 0.25)
	for bar in bars:
		var bx := grate_x0 + 0.25 * (float(bar) + 0.5)
		b.quad_face(Vector3(bx - 0.03, deck + 0.006, -2.75), Vector3(bx + 0.03, deck + 0.006, -2.75), Vector3(bx + 0.03, deck + 0.006, 2.75), Vector3(bx - 0.03, deck + 0.006, 2.75), FRAME, Vector3.UP)
	for side: float in [-1.0, 1.0]:
		# Stanchions and a top rail along the bulwark cap, stern to bow.
		var path := PackedVector3Array()
		var radii := PackedFloat32Array()
		var x := -7.8
		while x <= 7.4:
			var z := side * (HULL_MID_M + (HULL_OUTER_M - 0.05) * _hull_plan(x).x)
			var foot := _sheer(x) + 0.02
			b.tube(PackedVector3Array([Vector3(x, foot, z), Vector3(x, foot + 0.36, z)]), PackedFloat32Array([0.02, 0.02]), 5, STAINLESS, CELL_WHITE, false, false)
			path.append(Vector3(x, foot + 0.36, z))
			radii.append(0.024)
			x += 1.0
		b.tube(path, radii, 6, STAINLESS, CELL_WHITE, true, true)


## The main cabin, shorter than the hull (about 57 %, with a long aft deck): white,
## three dark forward windows under the lettered block (May 2025, Jun 2025), two
## small windows and a long band of dark tinted panes down each side, a door aft; the aft face's life
## ring, door and open doorway (Aug 2024, Jun 2025, May 2025, Feb 2022). Starboard
## mirrors port.
static func _cabin(b: RefCounted, body: StaticBody3D) -> void:
	var x0 := CABIN_AFT_X
	var x1 := CABIN_FORE_X
	var hz := 2.85
	var y0 := BOAT_DECK_M
	var y1 := CABIN_ROOF_M
	for side: float in [-1.0, 1.0]:
		var outward := Vector3(0.0, 0.0, side)
		b.quad_face(Vector3(x0, y0, side * hz), Vector3(x1, y0, side * hz), Vector3(x1, y1, side * hz), Vector3(x0, y1, side * hz), HULL_WHITE, outward)
		var panes := [[3.75, 4.2], [2.55, 3.3]]
		for pane in 6:
			panes.append([-3.7 + pane * 0.975, -3.7 + pane * 0.975 + 0.92])
		for pane: Array in panes:
			_window(b, outward, Vector3(float(pane[0]), 2.6, side * hz), Vector3(float(pane[1]), 3.6, side * hz))
		b.quad_face(Vector3(-4.45, y0 + 0.05, side * (hz + 0.01)), Vector3(-3.85, y0 + 0.05, side * (hz + 0.01)), Vector3(-3.85, 3.5, side * (hz + 0.01)), Vector3(-4.45, 3.5, side * (hz + 0.01)), RUB_GREY, outward)
	b.quad_face(Vector3(x1, y0, -hz), Vector3(x1, y0, hz), Vector3(x1, y1, hz), Vector3(x1, y1, -hz), HULL_WHITE, Vector3.RIGHT)
	for pane: Array in [[-2.5, -1.25], [-0.62, 0.62], [1.25, 2.5]]:
		_window(b, Vector3.RIGHT, Vector3(x1, 2.45, float(pane[0])), Vector3(x1, 3.45, float(pane[1])))
	b.quad_face(Vector3(x0, y0, -hz), Vector3(x0, y0, hz), Vector3(x0, y1, hz), Vector3(x0, y1, -hz), HULL_WHITE, Vector3.LEFT)
	# Aft face, port to starboard: life ring, door with its window, open doorway.
	var ring := PackedVector3Array()
	var radii := PackedFloat32Array()
	for step in 17:
		var angle := TAU * float(step) / 16.0
		ring.append(Vector3(x0 - 0.07, 2.95 + sin(angle) * 0.3, -2.3 + cos(angle) * 0.3))
		radii.append(0.065)
	b.tube(ring, radii, 6, BUOY_ORANGE, CELL_WHITE, false, false)
	b.quad_face(Vector3(x0 - 0.012, y0, -1.75), Vector3(x0 - 0.012, y0, -0.95), Vector3(x0 - 0.012, 3.5, -0.95), Vector3(x0 - 0.012, 3.5, -1.75), RUB_GREY, Vector3.LEFT)
	_window(b, Vector3.LEFT, Vector3(x0 - 0.012, 2.8, -1.6), Vector3(x0 - 0.012, 3.3, -1.1))
	b.quad_face(Vector3(x0 - 0.01, y0, -0.45), Vector3(x0 - 0.01, y0, 0.75), Vector3(x0 - 0.01, 3.45, 0.75), Vector3(x0 - 0.01, 3.45, -0.45), DOORWAY, Vector3.LEFT)
	# Roof (the upper deck) with a slim white fascia.
	b.box(Vector3((x0 + x1) * 0.5, y1 + 0.05, 0.0), Basis.IDENTITY, Vector3(x1 - x0 + 0.2, 0.1, 5.8), HULL_WHITE, CELL_WHITE)
	b.quad_face(Vector3(x0 - 0.05, UPPER_DECK_M + 0.001, -2.85), Vector3(x1 + 0.05, UPPER_DECK_M + 0.001, -2.85), Vector3(x1 + 0.05, UPPER_DECK_M + 0.001, 2.85), Vector3(x0 - 0.05, UPPER_DECK_M + 0.001, 2.85), BOAT_DECK, Vector3.UP)
	_box_shape(body, Vector3((x0 + x1) * 0.5, (y0 + UPPER_DECK_M) * 0.5, 0.0), Basis.IDENTITY, Vector3(x1 - x0 + 0.2, UPPER_DECK_M - y0, 5.8))


## A dark glass pane in a frame on a wall facing `outward`, between two opposite
## corners in the wall's plane.
static func _window(b: RefCounted, outward: Vector3, low: Vector3, high: Vector3, frame_color := FRAME, frame := 0.05) -> void:
	var o := outward.normalized()
	var corners := func(a: Vector3, c: Vector3, lift: float) -> Array[Vector3]:
		var bb := Vector3(c.x, a.y, c.z) if absf(o.x) < 0.5 else Vector3(a.x, a.y, c.z)
		var dd := Vector3(a.x, c.y, a.z) if absf(o.x) < 0.5 else Vector3(a.x, c.y, a.z)
		var quad: Array[Vector3] = [a + o * lift, bb + o * lift, c + o * lift, dd + o * lift]
		return quad
	var along := (Vector3(high.x, 0.0, high.z) - Vector3(low.x, 0.0, low.z)).normalized()
	var f: Array[Vector3] = corners.call(low - along * frame - Vector3.UP * frame, high + along * frame + Vector3.UP * frame, 0.008)
	b.quad_face(f[0], f[1], f[2], f[3], frame_color, o)
	var g: Array[Vector3] = corners.call(low, high, 0.016)
	b.quad_face(g[0], g[1], g[2], g[3], GLASS, o)


## The upper deck's forward block on the cabin roof: white, its lettered face
## raked back (TREASURE ISLAND ahead, YERBA BUENA ISLAND each side; Aug 2024,
## Jun 2025), its top the wheelhouse's deck.
static func _upper_block(b: RefCounted, body: StaticBody3D) -> void:
	var y0 := UPPER_DECK_M
	var y1 := BLOCK_TOP_M
	var hz := 2.85
	var fore_low := CABIN_FORE_X - 0.05
	var fore_high := fore_low - 0.3
	var aft := BLOCK_AFT_X
	# Front, raked back; sides; aft face; top.
	var rake := Vector3(y1 - y0, fore_low - fore_high, 0.0).normalized()
	b.quad_face(Vector3(fore_low, y0, hz), Vector3(fore_low, y0, -hz), Vector3(fore_high, y1, -hz), Vector3(fore_high, y1, hz), HULL_WHITE, rake)
	for side: float in [-1.0, 1.0]:
		b.quad_face(Vector3(aft, y0, side * hz), Vector3(fore_low, y0, side * hz), Vector3(fore_high, y1, side * hz), Vector3(aft, y1, side * hz), HULL_WHITE, Vector3(0.0, 0.0, side))
		var x0 := 0.35
		var x1 := 3.95
		var lettered: Array[Vector3] = [Vector3(x1, y0 + 0.12, side * (hz + 0.012)), Vector3(x0, y0 + 0.12, side * (hz + 0.012)), Vector3(x0, y1 - 0.1, side * (hz + 0.012)), Vector3(x1, y1 - 0.1, side * (hz + 0.012))]
		if side > 0.0:
			lettered = [Vector3(x0, y0 + 0.12, side * (hz + 0.012)), Vector3(x1, y0 + 0.12, side * (hz + 0.012)), Vector3(x1, y1 - 0.1, side * (hz + 0.012)), Vector3(x0, y1 - 0.1, side * (hz + 0.012))]
		_label(b, lettered, CELL_SIDE_PANEL, HULL_WHITE, Vector3(0.0, 0.0, side))
	b.quad_face(Vector3(aft, y0, -hz), Vector3(aft, y0, hz), Vector3(aft, y1, hz), Vector3(aft, y1, -hz), HULL_WHITE, Vector3.LEFT)
	b.quad_face(Vector3(aft, y1, -hz), Vector3(fore_high, y1, -hz), Vector3(fore_high, y1, hz), Vector3(aft, y1, hz), BOAT_DECK, Vector3.UP)
	var lift := rake * 0.012
	var front: Array[Vector3] = [Vector3(fore_low, y0 + 0.08, 2.75) + lift, Vector3(fore_low, y0 + 0.08, -2.75) + lift, Vector3(fore_high, y1 - 0.06, -2.75) + lift, Vector3(fore_high, y1 - 0.06, 2.75) + lift]
	front[0] = front[0].lerp(front[3], 0.06)
	front[1] = front[1].lerp(front[2], 0.06)
	_label(b, front, CELL_BOW_PANEL, HULL_WHITE, rake)
	_box_shape(body, Vector3((aft + fore_low) * 0.5, (y0 + y1) * 0.5, 0.0), Basis.IDENTITY, Vector3(fore_low - aft, y1 - y0, hz * 2.0))


## The orange wheelhouse on the forward block: its white-framed windscreen raked
## forward under the roof's orange visor (a light grey crown), wide white-framed side
## windows and a small side door, two aft windows; the mast with its light bar,
## the Garmin radar dome and two whips (owner frames received 2026-11-07; Aug
## 2024, Jun 2025, Feb 2022).
static func _wheelhouse(b: RefCounted, body: StaticBody3D) -> void:
	var y0 := BLOCK_TOP_M
	var y1 := WHEELHOUSE_ROOF_M
	var aft := 0.1
	var fore_low := 3.6
	var fore_high := 3.9
	var wz := 1.3
	var screen := Vector3(y1 - y0, fore_low - fore_high, 0.0).normalized() * -1.0
	if screen.x < 0.0:
		screen = -screen
	b.quad_face(Vector3(fore_low, y0, wz), Vector3(fore_low, y0, -wz), Vector3(fore_high, y1, -wz), Vector3(fore_high, y1, wz), WHEELHOUSE_ORANGE, screen)
	for side: float in [-1.0, 1.0]:
		b.quad_face(Vector3(aft, y0, side * wz), Vector3(fore_low, y0, side * wz), Vector3(fore_high, y1, side * wz), Vector3(aft, y1, side * wz), WHEELHOUSE_ORANGE, Vector3(0.0, 0.0, side))
		for pane: Array in [[2.55, 3.4], [1.55, 2.4], [0.55, 1.4]]:
			_window(b, Vector3(0.0, 0.0, side), Vector3(float(pane[0]), 5.35, side * wz), Vector3(float(pane[1]), 6.15, side * wz), HULL_WHITE, 0.07)
	b.quad_face(Vector3(aft, y0, -wz), Vector3(aft, y0, wz), Vector3(aft, y1, wz), Vector3(aft, y1, -wz), WHEELHOUSE_ORANGE, Vector3.LEFT)
	for pane: Array in [[-0.95, -0.2], [0.2, 0.95]]:
		_window(b, Vector3.LEFT, Vector3(aft, 5.45, float(pane[0])), Vector3(aft, 6.15, float(pane[1])))
	# The windscreen: two panes on the forward-raked front.
	for pane: Array in [[-1.15, -0.08], [0.08, 1.15]]:
		var za: float = pane[0]
		var zb: float = pane[1]
		for spec: Array in [[HULL_WHITE, 0.008, 0.06], [GLASS, 0.016, 0.0]]:
			var color: Color = spec[0]
			var lift: Vector3 = screen * float(spec[1])
			var grow: float = spec[2]
			var ya := 5.3 - grow
			var yb := 6.2 + grow
			var xa := lerpf(fore_low, fore_high, (ya - y0) / (y1 - y0))
			var xb := lerpf(fore_low, fore_high, (yb - y0) / (y1 - y0))
			b.quad_face(Vector3(xa, ya, zb + grow) + lift, Vector3(xa, ya, za - grow) + lift, Vector3(xb, yb, za - grow) + lift, Vector3(xb, yb, zb + grow) + lift, color, screen)
	# The roof: a light grey crown in an orange visor that rolls down round its edge.
	var crown_y := _wheelhouse_roof(b, body, aft, fore_high, wz, y1)
	# A small side door aft of the side windows (owner close-up); starboard mirrored.
	for side: float in [-1.0, 1.0]:
		b.quad_face(Vector3(0.18, y0 + 0.05, side * (wz + 0.012)), Vector3(0.48, y0 + 0.05, side * (wz + 0.012)), Vector3(0.48, y1 - 0.25, side * (wz + 0.012)), Vector3(0.18, y1 - 0.25, side * (wz + 0.012)), HULL_WHITE, Vector3(0.0, 0.0, side))
	_box_shape(body, Vector3((aft + fore_high) * 0.5, (y0 + y1) * 0.5, 0.0), Basis.IDENTITY, Vector3(fore_high - aft, y1 - y0, wz * 2.0))
	# Mast with its light bar, the radar dome and two whip antennas.
	var mast := Vector3(1.4, crown_y, 0.0)
	b.tube(PackedVector3Array([mast, mast + Vector3.UP * 0.75]), PackedFloat32Array([0.055, 0.045]), 8, HULL_WHITE, CELL_WHITE, false, false)
	b.box(mast + Vector3.UP * 0.55, Basis.IDENTITY, Vector3(0.08, 0.06, 1.3), STAINLESS, CELL_WHITE)
	for z: float in [-0.6, -0.2, 0.2, 0.6]:
		b.box(mast + Vector3(0.0, 0.62, z), Basis.IDENTITY, Vector3(0.1, 0.1, 0.1), FRAME, CELL_WHITE)
	var dome := mast + Vector3.UP * 0.75
	b.tube(PackedVector3Array([dome, dome + Vector3.UP * 0.2, dome + Vector3.UP * 0.27]), PackedFloat32Array([0.3, 0.3, 0.12]), 16, HULL_WHITE, CELL_WHITE, true, true)
	for side: float in [-1.0, 1.0]:
		var foot := Vector3(0.5, crown_y, side * 1.05)
		b.tube(PackedVector3Array([foot, foot + Vector3(-0.15, 2.3, side * 0.18)]), PackedFloat32Array([0.022, 0.01]), 4, HULL_WHITE, CELL_WHITE, false, false)


## The wheelhouse roof (owner aerial and low view received 2026-11-07; Jun 2025):
## a light grey crown inside an orange visor whose edge rolls down all round,
## deepest over the windscreen and swept round the front corners, with a short
## lip and an orange soffit under the overhang. aft, fore and wz are the walls'
## aft end, top front edge and half width, wall_top their top. Adds the roof's
## convex collision and returns the crown's height.
static func _wheelhouse_roof(b: RefCounted, body: StaticBody3D, aft: float, fore: float, wz: float, wall_top: float) -> float:
	var drop := 0.24
	var lip := 0.05
	var soffit_y := wall_top - 0.01
	var crown_y := soffit_y + lip + drop
	# The outer edge in plan (x forward, z starboard, counter-clockwise): it
	# overhangs the windscreen most and is rounded widely at the front corners.
	var corners := PackedVector2Array([Vector2(aft - 0.08, -wz - 0.12), Vector2(fore + 0.3, -wz - 0.12), Vector2(fore + 0.3, wz + 0.12), Vector2(aft - 0.08, wz + 0.12)])
	var outline: PackedVector2Array = BUILDER.rounded(corners, [0.35, 0.7, 0.7, 0.35], 6)
	var count := outline.size()
	var steps := 5
	var uv := CELL_WHITE.get_center()
	# Vertex rings: the visor's curve from the crown's edge (0) to its outer edge
	# (steps), then the lip's foot (steps + 1); the crown and the soffit apart.
	var rings: Array[Array] = []
	for step in steps + 2:
		rings.append([])
	var crown := PackedInt32Array()
	var soffit := PackedInt32Array()
	var normals: Array[Vector3] = []
	var hull := PackedVector3Array()
	var crown_middle := Vector3.ZERO
	var soffit_middle := Vector3.ZERO
	for index in count:
		var here := outline[index]
		var before := here - outline[(index + count - 1) % count]
		var after := outline[(index + 1) % count] - here
		var flat := (Vector2(before.y, -before.x).normalized() + Vector2(after.y, -after.x).normalized()).normalized()
		var n := Vector3(flat.x, 0.0, flat.y)
		# How far the curve reaches in from the edge: most at the front, least aft.
		var reach := lerpf(0.3, 0.45, flat.x) if flat.x > 0.0 else lerpf(0.3, 0.15, -flat.x)
		var edge := Vector3(here.x, crown_y, here.y) - n * reach
		for step in steps + 1:
			var angle := PI * 0.5 * float(step) / float(steps)
			var point := edge + n * reach * sin(angle) - Vector3.UP * drop * (1.0 - cos(angle))
			var normal := (n * sin(angle) / reach + Vector3.UP * cos(angle) / drop).normalized()
			rings[step].append(b.vertex(0, point, normal, uv, WHEELHOUSE_ORANGE))
		var rim := Vector3(here.x, soffit_y, here.y)
		rings[steps + 1].append(b.vertex(0, rim, n, uv, WHEELHOUSE_ORANGE))
		crown.append(b.vertex(0, edge, Vector3.UP, uv, ROOF_GREY))
		soffit.append(b.vertex(0, rim, Vector3.DOWN, uv, WHEELHOUSE_ORANGE))
		normals.append(n)
		hull.append(rim)
		hull.append(edge)
		crown_middle += edge / float(count)
		soffit_middle += rim / float(count)
	for step in steps + 1:
		var near: Array = rings[step]
		var far: Array = rings[step + 1]
		var tilt := PI * 0.5 * (float(step) + 0.5) / float(steps) if step < steps else PI * 0.5
		for index in count:
			var next := (index + 1) % count
			var outward := (normals[index] + normals[next]) * sin(tilt) + Vector3.UP * 2.0 * cos(tilt)
			b.triangle(0, near[index], near[next], far[next], outward)
			b.triangle(0, near[index], far[next], far[index], outward)
	var crown_centre: int = b.vertex(0, crown_middle, Vector3.UP, uv, ROOF_GREY)
	var soffit_centre: int = b.vertex(0, soffit_middle, Vector3.DOWN, uv, WHEELHOUSE_ORANGE)
	for index in count:
		var next := (index + 1) % count
		b.triangle(0, crown_centre, crown[index], crown[next], Vector3.UP)
		b.triangle(0, soffit_centre, soffit[index], soffit[next], Vector3.DOWN)
	_convex_shape(body, hull)
	return crown_y


## The open upper deck aft of the forward block: dense stainless rails of nine
## bars round its sides and curved aft corners, open at the ladder; two pairs of
## white liferaft canisters in cradles; and the ladder up from the aft deck
## (Aug 2024, Jun 2025, Feb 2022).
static func _upper_deck_aft(b: RefCounted, body: StaticBody3D) -> void:
	var deck := UPPER_DECK_M
	var aft := CABIN_AFT_X + 0.05
	var side_z := 2.8
	var corner := 0.8
	for side: float in [-1.0, 1.0]:
		var path := PackedVector3Array([Vector3(BLOCK_AFT_X - 0.02, deck, side * side_z)])
		for step in 7:
			var angle := PI * 0.5 * float(step) / 6.0
			path.append(Vector3(aft + corner - sin(angle) * corner, deck, side * (side_z - corner + cos(angle) * corner)))
		path.append(Vector3(aft, deck, side * 1.98 if side > 0.0 else side * 0.0))
		if side < 0.0:
			path.append(Vector3(aft, deck, 1.12))
		_curved_rail(b, body, path, 1.2, 9)
	# Red life rings hung on the upper deck's aft rail (owner astern view).
	for z: float in [-1.6, 0.4]:
		var hub := Vector3(aft - 0.06, deck + 0.75, z)
		var ring := PackedVector3Array()
		var radii := PackedFloat32Array()
		for step in 17:
			var angle := TAU * float(step) / 16.0
			ring.append(hub + Vector3(0.0, sin(angle) * 0.3, cos(angle) * 0.3))
			radii.append(0.06)
		b.tube(ring, radii, 6, BUOY_ORANGE, CELL_WHITE, false, false)
	# Liferaft canisters in pairs behind the block.
	for side: float in [-1.0, 1.0]:
		for x: float in [-1.55, -2.75]:
			var canister := Vector3(x, deck + 0.42, side * 2.2)
			b.tube(PackedVector3Array([canister - Vector3(0.52, 0.0, 0.0), canister + Vector3(0.52, 0.0, 0.0)]), PackedFloat32Array([0.3, 0.3]), 14, HULL_WHITE, CELL_WHITE, true, true)
			for band: float in [-0.3, 0.3]:
				b.tube(PackedVector3Array([canister + Vector3(band - 0.02, 0.0, 0.0), canister + Vector3(band + 0.02, 0.0, 0.0)]), PackedFloat32Array([0.305, 0.305]), 14, STAINLESS, CELL_WHITE, false, false)
			b.box(canister + Vector3(0.0, -0.3, 0.0), Basis.IDENTITY, Vector3(0.9, 0.12, 0.5), FRAME, CELL_WHITE)
			_box_shape(body, canister, Basis.IDENTITY, Vector3(1.04, 0.6, 0.6))
	# The ladder from the aft deck up to the deck's starboard opening.
	var steps := 9
	var foot := Vector3(-6.3, BOAT_DECK_M, 1.55)
	var head := Vector3(CABIN_AFT_X, deck, 1.55)
	for step in steps:
		var t := (float(step) + 0.5) / float(steps)
		b.box(foot.lerp(head, t), Basis.IDENTITY, Vector3(0.22, 0.04, 0.72), STAINLESS, CELL_WHITE)
	for side: float in [-1.0, 1.0]:
		var offset := Vector3(0.0, 0.0, side * 0.4)
		b.tube(PackedVector3Array([foot + offset, head + offset]), PackedFloat32Array([0.035, 0.035]), 6, STAINLESS, CELL_WHITE, true, true)
		b.tube(PackedVector3Array([foot + offset + Vector3.UP * 0.9, head + offset + Vector3.UP * 0.9]), PackedFloat32Array([0.022, 0.022]), 6, STAINLESS, CELL_WHITE, true, true)


## A stainless rail along a deck-level polyline: posts at its points and about
## every 0.85 m between, and `bars` horizontal bars up to `height`, the top one
## heavier; with thin solids along its straight runs.
static func _curved_rail(b: RefCounted, body: StaticBody3D, path: PackedVector3Array, height: float, bars: int) -> void:
	for index in path.size():
		var p := path[index]
		b.tube(PackedVector3Array([p, p + Vector3.UP * height]), PackedFloat32Array([0.025, 0.025]), 5, STAINLESS, CELL_WHITE, false, true)
		if index + 1 < path.size():
			var q := path[index + 1]
			var count := int(floor(p.distance_to(q) / 0.85))
			for step in range(1, count + 1):
				var foot := p.lerp(q, float(step) / float(count + 1))
				b.tube(PackedVector3Array([foot, foot + Vector3.UP * height]), PackedFloat32Array([0.02, 0.02]), 5, STAINLESS, CELL_WHITE, false, false)
			var run := q - p
			if run.length() > 0.3:
				var along := run.normalized()
				_box_shape(body, (p + q) * 0.5 + Vector3.UP * height * 0.5, Basis(along, Vector3.UP, along.cross(Vector3.UP)), Vector3(run.length(), height, 0.06))
	for bar in bars:
		var rise := height * float(bar + 1) / float(bars)
		var line := PackedVector3Array()
		var radii := PackedFloat32Array()
		for p: Vector3 in path:
			line.append(p + Vector3.UP * rise)
			radii.append(0.026 if bar == bars - 1 else 0.015)
		b.tube(line, radii, 5, STAINLESS, CELL_WHITE, true, true)
