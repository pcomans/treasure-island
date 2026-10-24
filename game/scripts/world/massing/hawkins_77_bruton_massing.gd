class_name Hawkins77BrutonMassing
extends RefCounted

## Hawkins runtime massing (2026-10-22 ferry L1 pass, ROOT decision) from Sep
## 2025 Street View, the 27 May 2025 Commons aerial and the architect's plan
## and section: a perimeter block around a raised level-2 courtyard. The
## 4-storey wing runs the whole WSW (Garden Walk) side, the S corner and the
## west part of the NNW side, with its top storey set back under a long
## cantilevered roof canopy (a wedge at the S corner); the 6-storey block holds
## the ENE (Seven Seas) side and the east parts of SE and NNW. Raised stoops
## with planter walls stand on WSW and ENE. Wing depths, split stations,
## setback, overhangs and stoop sizes are production inference, not surveyed.
## The frozen footprint, source wall bottoms and record identities are kept.

const TARGET_SOURCE_KEY := "w1249412093"
const TARGET_LOGICAL_OBJECT_KEY := "building:w1249412093"
const TARGET_WALL_KEY := "building:w1249412093:wall"
const TARGET_ROOF_KEY := "building:w1249412093:roof"
const SOURCE_TOP_Y := 10.274
const BASE_Y := 4.274
const STOREY_M := 3.5
# 2026-10-24 form audit (cav-7 frontal, cav-0 section, hk15/hk18 rectified): ground
# storey about 4.2 m, upper storeys about 3.15 m; the bay boxes of the 4-storey wing
# run from about 4.2 to 10.9 m above grade. DECK_Y is the ground-storey top / box
# underside; the courtyard sits near grade over the garage (cav-0, cav-14).
const DECK_Y := 8.474
const COURT_Y := 4.774
const UPPER_STOREY_M := 3.15
const TERRACE_Y := 15.174
const LOW_TOP_Y := 18.274
const TALL_TOP_Y := 25.274
# The 6-storey block starts at the junction stair tower (cav-7, hk02 rectified).
const SE_SPLIT_U_M := 32.0
# West face of the thin cheek beside the junction slot (cav-7: about 0.6 m).
const SE_CHEEK_U0_M := 31.4
# The 6-storey block runs about 40-41 m of the NNW face (hk15 rectified 41.1, hk12 39.5).
const NNW_SPLIT_U_M := 40.5
# ENE wing double-loaded, about 20-21 m (cav-0 section, cav-14 plan).
const WING_DEPTH_M := {"wsw": 13.0, "se": 13.0, "ene": 20.0, "nnw": 13.0}
const SETBACK_M := 1.6
# The WSW setback starts past the NNW wing (its corner block stays full height).
const WSW_SETBACK_FROM_U_M := 13.0
# Setback stations along each side (u from the side start): WSW from past the
# NNW wing to the S corner, SE from the S corner to the 6-storey block.
const SETBACK_U_RANGES := {"wsw": Vector2(WSW_SETBACK_FROM_U_M, 200.0), "se": Vector2(-200.0, SE_SPLIT_U_M)}
# The wing roof slab stands just past the bay boxes below it (cav-7, cav-3); only
# the S corner wedge reaches far out (cav-2).
# The canopy reads well beyond the box faces from the walk (cav-3, cav-6, hk16).
const CANOPY_OVERHANG_M := 1.2
# Projecting fluted bay boxes over storeys 2-3 (hk02, cav-7 SE; cav-3, hk23 WSW):
# u ranges along each side, from DECK_Y to TERRACE_Y, BAY_BOX_DEPTH_M proud.
const BAY_BOX_DEPTH_M := 0.4
# The WSW box starts at the W corner and turns onto the NNW end of the 4-storey
# wing (cav-3, hk15).
const BAY_BOX_U_RANGES := {"wsw": Vector2(0.0, 200.0), "se": Vector2(0.0, SE_SPLIT_U_M - 0.8), "nnw": Vector2(NNW_SPLIT_U_M + 0.6, 200.0)}
# The ground storey under the bay boxes is recessed inside the frozen footprint
# (cav-3, hk23, hk02, cav-2): a deep shadow line and white soffit, with the WSW
# stoops tucked under and full-height glazing at the S corner.
const RECESS_M := 1.3
# A ground pier keeps the W corner (cav-3); the recess starts past it.
const RECESS_WSW_START_M := 1.2
const WEDGE_OVERHANG_M := 2.0
const WEDGE_RUN_M := 8.0
const CANOPY_TOP_Y := 18.30
const CANOPY_THICKNESS_M := 0.25
const ROOF_EDGE_OVERHANG_M := 1.0
# Full-height recesses in plan [side, u0, u1, depth] (production inference from the
# 2026-10-24 audit): the SE junction glazing slot (cav-7, hk02, hk13); on ENE (u from
# the E corner) a recessed bay after the E corner block, the middle section (re-filled
# on storeys 2-5 by ENE_BOX, leaving a recessed glazed ground floor and a top-floor
# loggia under the roof slab) and a glazing slot before the N corner block (cav-4 seen
# from the N corner, hk21 from the E corner, hk10);
# the NNW glazed strip between the two 6-storey blocks (hk15, hk12).
const NOTCHES := [
	["se", 32.0, 34.5, 1.0],
	["ene", 13.8, 18.8, 0.8], ["ene", 18.8, 42.7, 1.8], ["ene", 42.7, 44.5, 1.2],
	["nnw", 20.0, 23.3, 1.0],
]
# ENE middle: storeys 2-5 at the footprint line over the recessed ground floor, a
# low ledge in front of the recessed top floor, and the roof slab with a dark
# soffit over the middle only (u from the E corner).
const ENE_BOX_U := Vector2(18.82, 42.68)
const ENE_BOX_TOP_Y := DECK_Y + 4.0 * UPPER_STOREY_M
const ENE_LEDGE_TOP_Y := ENE_BOX_TOP_Y + 1.0
const ENE_ROOF_EDGE_U := Vector2(10.0, 46.0)
# Rooftop volumes approved by ROOT 2026-10-24 (production inference): [side, u0, u1,
# out0, out1, bottom, top, role]. SE junction stair/lift tower (pier and glazed slot
# part; cav-7, hk13, hk18, hk05), with the thin cheek on the 4-storey side of the slot
# rising with the pier while the slot cap stays lower between them (cav-7, hk05,
# hk18; Stage A rework 2026-10-24), roof-terrace pavilion and its overhanging roof east
# of it, behind the terrace so the street sees none of it (hk25, hk18, hk21, cav-0, cav-7), the mechanical screen along the ENE wing roof from
# near the E corner (hk21, hk18), the set-back NNW penthouse: a broad thin roof slab
# over a smaller glazed room at the strip, the slab's west end carried on posts over
# the roof terrace (hk15, hk21), and the short stair enclosure on the 4-storey roof
# at the NNW step (hk12, hk15).
const ROOF_VOLUMES := [
	["se", 34.5, 38.0, -6.5, 0.0, TALL_TOP_Y, 29.6, "tower"],
	["se", 32.0, 34.5, -6.5, -1.0, TALL_TOP_Y, 27.7, "tower"],
	["se", SE_CHEEK_U0_M, 32.0, -6.5, 0.0, TERRACE_Y, 29.6, "tower_cheek"],
	["se", 39.0, 47.0, -12.5, -8.0, TALL_TOP_Y, 28.6, "pavilion"],
	["se", 38.3, 48.0, -12.8, -7.0, 28.6, 28.9, "pavilion_roof"],
	["ene", 8.0, 48.0, -14.0, -6.0, TALL_TOP_Y, 28.0, "screen"],
	["nnw", 18.5, 27.0, -10.0, -3.0, TALL_TOP_Y, 27.45, "penthouse"],
	["nnw", 5.0, 27.8, -10.8, -1.5, 27.45, 27.8, "penthouse_roof"],
	["nnw", 5.2, 5.5, -2.2, -1.9, TALL_TOP_Y, 27.45, "penthouse_post"],
	["nnw", 5.2, 5.5, -10.5, -10.2, TALL_TOP_Y, 27.45, "penthouse_post"],
	["nnw", NNW_SPLIT_U_M - 0.2, 46.0, -8.0, -1.5, LOW_TOP_Y, 21.0, "stair"],
]
# Fin walls between the set-back top-floor terraces on WSW (cav-3, cav-6), on the
# unit module of the plan (cav-14, about 6.45 m).
const WSW_FIN_PITCH_M := 6.45
const WSW_FIN_WIDTH_M := 0.25
# Stoops: [side, u along side, local land y]; land y is sampled terrain from the
# frozen chunk (land_ground w26767313) at each stoop; platform 0.6m above it.
const STOOPS := [
	# WSW: one raised entry per 6.45 m plan module (Stage B rework; hk23, cav-3, cav-6),
	# land sampled from the frozen land_ground triangles (x_-1 z_1/z_2) at each stoop.
	["wsw", 15.0, 4.61], ["wsw", 21.45, 4.52], ["wsw", 27.9, 4.43], ["wsw", 34.35, 4.34], ["wsw", 40.8, 4.29],
	["wsw", 47.25, 4.30], ["wsw", 53.7, 4.28], ["wsw", 60.15, 4.25], ["wsw", 66.6, 4.25],
	["ene", 12.0, 4.28], ["ene", 24.0, 4.34], ["ene", 36.0, 4.44],
]
const STOOP_DEPTH_M := 1.8
const STOOP_WIDTH_M := 2.6
const STOOP_RISE_M := 0.6
const STEP_WIDTH_M := 1.6
const STEP_TREAD_M := 0.3
const PLANTER_TOP_ABOVE_LAND_M := 0.95
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const RENDER_WORLD_VISIBLE := 1 << 0
const RENDER_BUILDING_WALL := 1 << 1
const FACADE_SCENE := preload("res://game/scenes/world/facades/hawkins/hawkins_77_bruton_facade.tscn")
const CANOPY_MATERIAL := preload("res://game/resources/materials/world/hawkins/hawkins_pearl_plain.tres")
const SOFFIT_MATERIAL := preload("res://game/resources/materials/world/hawkins/hawkins_frame_charcoal.tres")
const STOOP_MATERIAL := preload("res://game/resources/materials/world/hawkins/hawkins_spandrel_pale.tres")

# Footprint corners (frozen OSM): A west, B south, C east, D north.
const A := Vector2(-118.795, 451.595)
const B := Vector2(-79.648, 526.358)
const C := Vector2(-41.556, 480.728)
const D := Vector2(-69.387, 427.417)
# Sides in footprint order. The ring has negative signed area in (x, z), so
# the outward normal of an edge with direction d is (-d.y, d.x).
const SIDES := {"wsw": [A, B], "se": [B, C], "ene": [C, D], "nnw": [D, A]}


static func matches_record(record: Dictionary) -> bool:
	var object_key := str(record.get("object_key", ""))
	if object_key not in [TARGET_WALL_KEY, TARGET_ROOF_KEY]:
		return false
	var source_keys: Array = record.get("source_keys", [])
	return source_keys.size() == 1 \
		and str(source_keys[0]) == TARGET_SOURCE_KEY \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build_record(record: Dictionary, material: Material) -> Dictionary:
	var validation := _validate_source_record(record)
	if not bool(validation.get("ok", false)):
		return validation
	var object_key := str(record.object_key)
	var is_wall := object_key == TARGET_WALL_KEY
	var geometry := wall_geometry(record) if is_wall else roof_geometry()
	if not bool(geometry.get("ok", false)):
		return geometry

	var canopy_material: Material = CANOPY_MATERIAL
	var soffit_material: Material = SOFFIT_MATERIAL
	var stoop_material: Material = STOOP_MATERIAL
	var root := Node3D.new()
	root.name = object_key.validate_node_name()
	root.set_meta("derived_object_key", object_key)
	root.set_meta("source_keys", record.source_keys.duplicate())
	root.set_meta("feature_kind", str(record.feature_kind))
	root.set_meta("hawkins_massing_override", true)
	root.set_meta("massing_contract", massing_contract())
	root.set_meta("massing_signature", str(geometry.signature))
	root.set_meta("source_geometry_preserved", true)
	if is_wall:
		root.set_meta("source_exterior_foundation_segments", int(record.exterior_foundation_segments))
		root.set_meta("runtime_wall_quads", (geometry.quads as Array).size())

	var mesh_instances := 0
	var faces := PackedVector3Array()
	if is_wall:
		# Stage B: the wall receiver carries the cladding zones and the punched
		# window openings (reveals and panes) as material-keyed surfaces; the
		# collision below uses all of them.
		var surfaces := wall_surfaces(geometry.quads)
		var keys := surfaces.keys()
		keys.sort()
		for key: String in keys:
			var surface := _flat_geometry(surfaces[key], "wall_" + key)
			root.add_child(_mesh_node("Wall_" + key, surface, surface_material(key), RENDER_BUILDING_WALL))
			faces.append_array(_faces(surface))
			mesh_instances += 1
	else:
		root.add_child(_mesh_node("Mesh", geometry, material, RENDER_WORLD_VISIBLE))
		faces = _faces(geometry)
		mesh_instances += 1
	if not is_wall:
		# Canopies and the ENE roof edge: pale tops/edges, dark soffits; solid.
		var canopy := canopy_geometry()
		root.add_child(_mesh_node("Canopies", canopy.top, canopy_material, RENDER_WORLD_VISIBLE))
		root.add_child(_mesh_node("CanopySoffits", canopy.soffit, soffit_material, RENDER_WORLD_VISIBLE))
		faces.append_array(_faces(canopy.top))
		faces.append_array(_faces(canopy.soffit))
		# The facade draws the terrace glass rail; it is solid here.
		faces.append_array(_faces(rail_collision()))
		# Bay boxes: white returns and undersides here, fluted fronts in the facade.
		var boxes := bay_box_geometry()
		root.add_child(_mesh_node("BayBoxes", boxes, canopy_material, RENDER_WORLD_VISIBLE))
		faces.append_array(_faces(boxes))
		var volumes := volume_geometry()
		var fronts := front_surfaces()
		var front_keys := fronts.keys()
		front_keys.sort()
		for key: String in front_keys:
			var surface := _flat_geometry(fronts[key], "front_" + key)
			root.add_child(_mesh_node("Front_" + key, surface, surface_material(key), RENDER_BUILDING_WALL))
			faces.append_array(_faces(surface))
			mesh_instances += 1
		root.add_child(_mesh_node("FormVolumes", volumes.solid, CANOPY_MATERIAL, RENDER_WORLD_VISIBLE))
		root.add_child(_mesh_node("FormVolumesDark", volumes.dark, soffit_material, RENDER_WORLD_VISIBLE))
		faces.append_array(_faces(volumes.solid))
		faces.append_array(_faces(volumes.dark))
		mesh_instances += 5

	var body := StaticBody3D.new()
	body.name = "Collision"
	body.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
	body.collision_mask = 0
	body.set_meta("receiver_kind", str(record.receiver_kind))
	body.set_meta("opaque", bool(record.opaque))
	body.set_meta("derived_object_key", object_key)
	body.set_meta("source_keys", record.source_keys.duplicate())
	body.set_meta("hawkins_massing_override", true)
	body.set_meta("massing_signature", str(geometry.signature))
	if is_wall:
		body.add_to_group("spray_receiver_wall")
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	shape.set_meta("receiver_kind", str(record.receiver_kind))
	shape.set_meta("opaque", bool(record.opaque))
	shape.set_meta("derived_object_key", object_key)
	shape.set_meta("source_keys", record.source_keys.duplicate())
	shape.set_meta("hawkins_massing_override", true)
	shape.set_meta("massing_signature", str(geometry.signature))
	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "Shape"
	collision_shape.shape = shape
	body.add_child(collision_shape)
	root.add_child(body)

	if is_wall:
		var stoops := stoop_geometry()
		root.add_child(_mesh_node("Stoops", stoops.solid, stoop_material, RENDER_WORLD_VISIBLE))
		root.add_child(_mesh_node("StoopSteps", stoops.decor, stoop_material, RENDER_WORLD_VISIBLE))
		root.add_child(_mesh_node("StoopRisers", stoops.risers, soffit_material, RENDER_WORLD_VISIBLE))
		mesh_instances += 2
		# Platforms, planters and the hidden flight ramps: solid, not spray walls.
		var stoop_faces := _faces(stoops.solid)
		stoop_faces.append_array(_faces(stoops.support))
		var stoop_shape := ConcavePolygonShape3D.new()
		stoop_shape.set_faces(stoop_faces)
		var stoop_shape_node := CollisionShape3D.new()
		stoop_shape_node.name = "Shape"
		stoop_shape_node.shape = stoop_shape
		var stoop_body := StaticBody3D.new()
		stoop_body.name = "StoopCollision_NoSprayOwnership"
		# On the spray layer too, so stoops occlude spray (receiver none refuses
		# the tag) instead of letting it reach the wall behind them.
		stoop_body.collision_layer = PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE
		stoop_body.collision_mask = 0
		stoop_body.set_meta("receiver_kind", "none")
		stoop_body.set_meta("opaque", true)
		stoop_body.set_meta("source_keys", record.source_keys.duplicate())
		stoop_body.add_child(stoop_shape_node)
		root.add_child(stoop_body)
	if is_wall:
		var facade := FACADE_SCENE.instantiate() as Hawkins77BrutonFacade
		var facade_result := facade.configure(record, geometry)
		if not bool(facade_result.get("ok", false)):
			facade.free()
			root.free()
			return {
				"ok": false,
				"code": "hawkins_facade_contract",
				"message": str(facade_result.get("message", "Could not build the Hawkins facade.")),
				"source_keys": record.source_keys,
			}
		root.add_child(facade)

	return {
		"ok": true,
		"node": root,
		"mesh_instances": mesh_instances,
		"surfaces": mesh_instances,
		"triangles": int(geometry.indices.size() / 3),
	}


static func massing_contract() -> Dictionary:
	return {
		"schema_version": "ti.hawkins-massing-runtime/2",
		"target_source_key": TARGET_SOURCE_KEY,
		"target_logical_object_key": TARGET_LOGICAL_OBJECT_KEY,
		"outer_ring_xz": [A, B, C, D],
		"base_y_m": BASE_Y,
		"deck_y_m": DECK_Y,
		"terrace_y_m": TERRACE_Y,
		"low_top_y_m": LOW_TOP_Y,
		"tall_top_y_m": TALL_TOP_Y,
		"storey_height_m": STOREY_M,
		"court_y_m": COURT_Y,
		"notches": NOTCHES,
		"roof_volumes": ROOF_VOLUMES,
		"se_split_u_m": SE_SPLIT_U_M,
		"nnw_split_u_m": NNW_SPLIT_U_M,
		"setback_m": SETBACK_M,
		"stoops": STOOPS,
		"source_top_y_m": SOURCE_TOP_Y,
		"runtime_override": true,
	}


# Side frame: start, unit tangent, outward normal and length, all in XZ.
static func side_frame(side: String) -> Dictionary:
	var ends: Array = SIDES[side]
	var start: Vector2 = ends[0]
	var finish: Vector2 = ends[1]
	var tangent := (finish - start).normalized()
	return {"start": start, "tangent": tangent, "normal": Vector2(-tangent.y, tangent.x), "length": start.distance_to(finish)}


static func side_point(side: String, u: float, out: float) -> Vector2:
	var f := side_frame(side)
	return (f.start as Vector2) + (f.tangent as Vector2) * u + (f.normal as Vector2) * out


# Massing pieces with a top height: ring trapezoids between the footprint and
# the inset courtyard, split by the tall/low line (SE station to NNW station);
# the low WSW and SE strips under the canopy drop to the terrace; the
# courtyard is the raised level-2 deck. Polygons have negative signed area.
static func pieces() -> Array[Dictionary]:
	var inner := _inner_quad()
	var outer: Array[Vector2] = [A, B, C, D]
	var q := side_point("se", SE_SPLIT_U_M, 0.0)
	var r := side_point("nnw", NNW_SPLIT_U_M, 0.0)
	var tall := PackedVector2Array([q, C, D, r])
	var low := PackedVector2Array([A, B, q, r])
	# Setback bands per side as convex regions (no polygon subtraction, which
	# can leave slit polygons): the band within SETBACK_M of the footprint line
	# over the setback stations, the inner region behind the setback line, and
	# the outer region before the band starts.
	var far := 200.0
	var bands := {
		0: [SETBACK_U_RANGES.wsw, "wsw"],
		1: [SETBACK_U_RANGES.se, "se"],
	}
	var result: Array[Dictionary] = []
	var names := ["wsw", "se", "ene", "nnw"]
	for i in 4:
		var trapezoid := PackedVector2Array([outer[i], outer[(i + 1) % 4], inner[(i + 1) % 4], inner[i]])
		for part: PackedVector2Array in Geometry2D.intersect_polygons(trapezoid, tall):
			result.append({"poly": _ordered(part), "top": TALL_TOP_Y, "role": "tall"})
		for part: PackedVector2Array in Geometry2D.intersect_polygons(trapezoid, low):
			if not bands.has(i):
				result.append({"poly": _ordered(part), "top": LOW_TOP_Y, "role": "low"})
				continue
			var side: String = names[i]
			var u_range: Vector2 = bands[i][0]
			var band := PackedVector2Array([side_point(side, u_range.x, far), side_point(side, u_range.y, far), side_point(side, u_range.y, -SETBACK_M), side_point(side, u_range.x, -SETBACK_M)])
			var behind := PackedVector2Array([side_point(side, -far, -SETBACK_M), side_point(side, far, -SETBACK_M), side_point(side, far, -far), side_point(side, -far, -far)])
			var before := PackedVector2Array([side_point(side, -far, far), side_point(side, u_range.x, far), side_point(side, u_range.x, -SETBACK_M), side_point(side, -far, -SETBACK_M)])
			var after := PackedVector2Array([side_point(side, u_range.y, far), side_point(side, far, far), side_point(side, far, -SETBACK_M), side_point(side, u_range.y, -SETBACK_M)])
			for terrace: PackedVector2Array in Geometry2D.intersect_polygons(part, band):
				result.append({"poly": _ordered(terrace), "top": TERRACE_Y, "role": "terrace"})
			for region: PackedVector2Array in [behind, before, after]:
				for rest: PackedVector2Array in Geometry2D.intersect_polygons(part, region):
					result.append({"poly": _ordered(rest), "top": LOW_TOP_Y, "role": "low"})
	result.append({"poly": _ordered(PackedVector2Array(inner)), "top": COURT_Y, "role": "court"})
	# Drop slivers that polygon clipping can leave along collinear edges
	# (mean width = area / half the perimeter under 5 cm).
	var cleaned: Array[Dictionary] = []
	for piece: Dictionary in result:
		var poly: PackedVector2Array = piece.poly
		var perimeter := 0.0
		for i in poly.size():
			perimeter += poly[i].distance_to(poly[(i + 1) % poly.size()])
		if absf(_signed_area(poly)) / maxf(perimeter * 0.5, 0.001) > 0.05:
			cleaned.append(piece)
	return _notched(cleaned)


# Cut the full-height NOTCHES out of the pieces (each notch rectangle reaches 1 m
# outside the footprint, so the clip never leaves a hole).
static func _notched(all_pieces: Array[Dictionary]) -> Array[Dictionary]:
	var result := all_pieces
	for notch: Array in NOTCHES:
		var side := str(notch[0])
		var rect := PackedVector2Array([
			side_point(side, notch[1], 1.0), side_point(side, notch[2], 1.0),
			side_point(side, notch[2], -float(notch[3])), side_point(side, notch[1], -float(notch[3])),
		])
		var next: Array[Dictionary] = []
		for piece: Dictionary in result:
			if Geometry2D.intersect_polygons(piece.poly, rect).is_empty():
				next.append(piece)
				continue
			for part: PackedVector2Array in Geometry2D.clip_polygons(piece.poly, rect):
				var perimeter := 0.0
				for i in part.size():
					perimeter += part[i].distance_to(part[(i + 1) % part.size()])
				if absf(_signed_area(part)) / maxf(perimeter * 0.5, 0.001) > 0.05:
					next.append({"poly": _ordered(part), "top": piece.top, "role": piece.role})
		result = next
	return result


static func _inner_quad() -> Array[Vector2]:
	var names := ["wsw", "se", "ene", "nnw"]
	var lines: Array = []
	for side_name: String in names:
		var f := side_frame(side_name)
		var depth: float = WING_DEPTH_M[side_name]
		lines.append([(f.start as Vector2) - (f.normal as Vector2) * depth, f.tangent])
	var corners: Array[Vector2] = []
	# Inner corner i lies where side i-1 meets side i (A: nnw x wsw, B: wsw x se ...).
	for i in 4:
		var l1: Array = lines[(i + 3) % 4]
		var l2: Array = lines[i]
		corners.append(Geometry2D.line_intersects_line(l1[0], l1[1], l2[0], l2[1]) as Vector2)
	return corners


# Vertical walls on every piece edge facing the outside (from the source wall
# bottom), the courtyard or a lower neighbour; edges are split at every vertex
# lying on them so each part sees one neighbour.
static func wall_geometry(record: Dictionary) -> Dictionary:
	if str(record.get("object_key", "")) != TARGET_WALL_KEY:
		return {"ok": false, "code": "hawkins_massing_target", "message": "Wall geometry requested for a non-Hawkins wall."}
	var source_quads := _source_wall_quads(record)
	if source_quads.size() != 20:
		return {"ok": false, "code": "hawkins_massing_source", "message": "Hawkins source wall is not the exact 20-quad receiver."}
	var all_pieces := pieces()
	var points: Array[Vector2] = []
	for piece: Dictionary in all_pieces:
		for p: Vector2 in piece.poly:
			points.append(p)
	for quad: Dictionary in source_quads:
		points.append(Vector2((quad.start_bottom as Vector3).x, (quad.start_bottom as Vector3).z))
	var quads: Array[Dictionary] = []
	for piece: Dictionary in all_pieces:
		var poly: PackedVector2Array = piece.poly
		var top: float = piece.top
		for i in poly.size():
			var p0 := poly[i]
			var p1 := poly[(i + 1) % poly.size()]
			var length := p0.distance_to(p1)
			if length < 0.01:
				continue
			var stations: Array[float] = [0.0, 1.0]
			for p: Vector2 in points:
				var t := (p - p0).dot(p1 - p0) / (length * length)
				if t > 0.0005 and t < 0.9995 and Geometry2D.get_closest_point_to_segment(p, p0, p1).distance_to(p) < 0.002:
					stations.append(t)
			stations.sort()
			var direction := (p1 - p0) / length
			var outward := Vector2(-direction.y, direction.x)
			var normal := Vector3(outward.x, 0.0, outward.y)
			for k in stations.size() - 1:
				var a := p0.lerp(p1, stations[k])
				var b := p0.lerp(p1, stations[k + 1])
				if a.distance_to(b) < 0.005:
					continue
				var neighbour := _height_at(all_pieces, (a + b) * 0.5 + outward * 0.05)
				if is_nan(neighbour):
					var bottom_a := _ground_bottom(source_quads, a)
					var bottom_b := _ground_bottom(source_quads, b)
					if is_nan(bottom_a) or is_nan(bottom_b):
						return {"ok": false, "code": "hawkins_massing_source", "message": "Hawkins outer wall left the frozen footprint."}
					_append_wall_quad(quads, Vector3(a.x, bottom_a, a.y), Vector3(b.x, bottom_b, b.y), top, normal, "outer", str(piece.role))
				elif neighbour < top - 0.001:
					var role := "setback" if is_equal_approx(neighbour, TERRACE_Y) else ("court" if is_equal_approx(neighbour, COURT_Y) else "step")
					_append_wall_quad(quads, Vector3(a.x, neighbour, a.y), Vector3(b.x, neighbour, b.y), top, normal, role, str(piece.role))
	return _geometry_from_wall_quads(_recess_ground(quads, source_quads))


# Outer walls over the recess start at DECK_Y; the recessed ground walls and their
# end returns run from the source wall bottom (taken on the footprint line) to it.
static func _recess_ground(quads: Array[Dictionary], source_quads: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for quad: Dictionary in quads:
		var side := _outer_side(quad)
		var r := ground_cut_range(side) if side != "" else Vector2(INF, -INF)
		var f := side_frame(side) if side != "" else {}
		var sb := quad.start_bottom as Vector3
		var eb := quad.end_bottom as Vector3
		var ua := (Vector2(sb.x, sb.z) - (f.get("start", Vector2.ZERO) as Vector2)).dot(f.get("tangent", Vector2.ZERO) as Vector2) if side != "" else 0.0
		var ub := (Vector2(eb.x, eb.z) - (f.get("start", Vector2.ZERO) as Vector2)).dot(f.get("tangent", Vector2.ZERO) as Vector2) if side != "" else 0.0
		if side == "" or maxf(ua, ub) <= r.x + 0.001 or minf(ua, ub) >= r.y - 0.001:
			result.append(quad)
			continue
		# Split at the range ends; the inside part loses its ground storey.
		var cuts: Array[float] = [0.0, 1.0]
		for u_cut: float in [r.x, r.y]:
			var t := (u_cut - ua) / (ub - ua)
			if t > 0.001 and t < 0.999:
				cuts.append(t)
		cuts.sort()
		var top := (quad.start_top as Vector3).y
		for k in cuts.size() - 1:
			var p := sb.lerp(eb, cuts[k])
			var q := sb.lerp(eb, cuts[k + 1])
			var mid_u := lerpf(ua, ub, (cuts[k] + cuts[k + 1]) * 0.5)
			if mid_u > r.x and mid_u < r.y:
				p.y = DECK_Y
				q.y = DECK_Y
			_append_wall_quad(result, p, q, top, quad.normal, "outer", str(quad.volume))
	var strip := recess_strip()
	var walls := [
		[strip[5], strip[4], "wsw"], [strip[4], strip[3], "se"],
		[strip[0], strip[5], "wsw_return"], [strip[3], strip[2], "se_return"],
	]
	for wall: Array in walls:
		var p: Vector2 = wall[0]
		var q: Vector2 = wall[1]
		var kind := str(wall[2])
		var normal2: Vector2
		match kind:
			"wsw": normal2 = side_frame("wsw").normal
			"se": normal2 = side_frame("se").normal
			"wsw_return": normal2 = side_frame("wsw").tangent
			_: normal2 = -(side_frame("se").tangent as Vector2)
		# Start -> end must have outward normal (-d.y, d.x).
		var d := (q - p).normalized()
		if Vector2(-d.y, d.x).dot(normal2) < 0.0:
			var swap := p
			p = q
			q = swap
		var foot := kind.trim_suffix("_return")
		var bottom_p := _source_bottom(source_quads, p + (side_frame(foot).normal as Vector2) * _depth_in(foot, p))
		var bottom_q := _source_bottom(source_quads, q + (side_frame(foot).normal as Vector2) * _depth_in(foot, q))
		_append_wall_quad(result, Vector3(p.x, bottom_p, p.y), Vector3(q.x, bottom_q, q.y), DECK_Y, Vector3(normal2.x, 0.0, normal2.y), "recess", foot)
	return result


# How far inside a side's footprint line a point lies.
static func _depth_in(side: String, p: Vector2) -> float:
	return -(p - (side_frame(side).start as Vector2)).dot(side_frame(side).normal)


# The footprint side an outer wall quad lies on ("" for any other wall).
static func _outer_side(quad: Dictionary) -> String:
	if str(quad.role) != "outer":
		return ""
	var normal := quad.normal as Vector3
	var p := quad.start_bottom as Vector3
	for side: String in SIDES:
		var f := side_frame(side)
		if Vector2(normal.x, normal.z).dot(f.normal) > 0.999 and absf((Vector2(p.x, p.z) - (f.start as Vector2)).dot(f.normal)) < 0.05:
			return side
	return ""


static func roof_geometry() -> Dictionary:
	var bucket := _bucket()
	for piece: Dictionary in pieces():
		var poly: PackedVector2Array = piece.poly
		var triangles := Geometry2D.triangulate_polygon(poly)
		if triangles.is_empty():
			return {"ok": false, "code": "hawkins_massing_roof", "message": "A Hawkins roof piece did not triangulate."}
		var y: float = piece.top
		for i in range(0, triangles.size(), 3):
			_append_oriented(bucket, _at(poly[triangles[i]], y), _at(poly[triangles[i + 1]], y), _at(poly[triangles[i + 2]], y), Vector3.UP)
	return _flat_geometry(bucket, "roof")


# Canopy slab along the WSW and SE low edges, widening to a wedge at the S
# corner (pale all round), and the 6-storey ENE roof edge (dark soffit).
static func canopy_geometry() -> Dictionary:
	var top := _bucket()
	var soffit := _bucket()
	var wsw_length: float = side_frame("wsw").length
	var apex := Geometry2D.line_intersects_line(side_point("wsw", 0.0, WEDGE_OVERHANG_M), side_frame("wsw").tangent, side_point("se", 0.0, WEDGE_OVERHANG_M), side_frame("se").tangent) as Vector2
	var inner_corner := Geometry2D.line_intersects_line(side_point("wsw", 0.0, -SETBACK_M), side_frame("wsw").tangent, side_point("se", 0.0, -SETBACK_M), side_frame("se").tangent) as Vector2
	var canopy := PackedVector2Array([
		side_point("wsw", 0.0, -SETBACK_M),
		side_point("wsw", 0.0, CANOPY_OVERHANG_M),
		side_point("wsw", wsw_length - WEDGE_RUN_M, CANOPY_OVERHANG_M),
		apex,
		side_point("se", WEDGE_RUN_M, CANOPY_OVERHANG_M),
		side_point("se", SE_CHEEK_U0_M, CANOPY_OVERHANG_M),
		side_point("se", SE_CHEEK_U0_M, -SETBACK_M),
		inner_corner,
	])
	# The wing canopy is white underneath too (cav-2, cav-3); only the ENE roof
	# edge has a dark soffit (hk07/hk10).
	_append_slab(top, top, _ordered(canopy), CANOPY_TOP_Y - CANOPY_THICKNESS_M, CANOPY_TOP_Y)
	# Roof slab over the ENE middle and its top-floor loggia (cav-4, hk21, hk10).
	var edge := PackedVector2Array([
		side_point("ene", ENE_ROOF_EDGE_U.x, -2.0), side_point("ene", ENE_ROOF_EDGE_U.x, ROOF_EDGE_OVERHANG_M),
		side_point("ene", ENE_ROOF_EDGE_U.y, ROOF_EDGE_OVERHANG_M), side_point("ene", ENE_ROOF_EDGE_U.y, -2.0),
	])
	_append_slab(top, soffit, _ordered(edge), TALL_TOP_Y - 0.35, TALL_TOP_Y + 0.03)
	return {"top": _flat_geometry(top, "canopy"), "soffit": _flat_geometry(soffit, "soffit")}


# Solid projecting bay boxes (top, underside and returns; receiver none in the
# roof body, so they occlude spray instead of hiding a tag behind them).
# Punched exterior fronts of the projecting boxes and the ENE middle box (wall receiver).
static func front_surfaces() -> Dictionary:
	var fronts := {}
	for side: String in BAY_BOX_U_RANGES:
		var u_range := bay_box_range(side)
		_punch_rect(fronts, "clad", side, BAY_BOX_DEPTH_M, u_range.x, u_range.y, DECK_Y, TERRACE_Y, openings_on(side, BAY_BOX_DEPTH_M))
	_punch_rect(fronts, "clad", "ene", 0.0, ENE_BOX_U.x, ENE_BOX_U.y, DECK_Y, ENE_BOX_TOP_Y, openings_on("ene", 0.0, ENE_BOX_U))
	return fronts


static func bay_box_geometry() -> Dictionary:
	var bucket := _bucket()
	for side: String in BAY_BOX_U_RANGES:
		var u_range := bay_box_range(side)
		# Top, underside, back and ends here; the front carries the window groups.
		_append_box_open_front(bucket, side, u_range.x, u_range.y, 0.0, BAY_BOX_DEPTH_M, DECK_Y, TERRACE_Y)
	# White soffit over the recessed ground storey.
	_append_slab(bucket, bucket, _ordered(recess_strip()), DECK_Y, DECK_Y + 0.3)
	return _flat_geometry(bucket, "bay_box")


# Solid form pieces added to the roof body (receiver none, spray layer): the ENE
# middle storeys 2-5 and ledge, the WSW terrace fins and the rooftop volumes.
# Returns {"solid": pale volumes, "dark": tower slot and pavilion glazing}.
static func volume_geometry() -> Dictionary:
	var solid := _bucket()
	var dark := _bucket()
	_append_box_open_front(solid, "ene", ENE_BOX_U.x, ENE_BOX_U.y, -1.8, 0.0, DECK_Y, ENE_BOX_TOP_Y)
	_append_slab(solid, solid, _side_rect("ene", ENE_BOX_U.x, ENE_BOX_U.y, -0.35, 0.0), ENE_BOX_TOP_Y, ENE_LEDGE_TOP_Y)
	var wsw_range := Vector2(maxf((SETBACK_U_RANGES.wsw as Vector2).x, 0.0), float(side_frame("wsw").length) - WEDGE_RUN_M)
	var u := wsw_range.x
	while u <= wsw_range.y:
		_append_slab(solid, solid, _side_rect("wsw", u - WSW_FIN_WIDTH_M * 0.5, u + WSW_FIN_WIDTH_M * 0.5, -SETBACK_M, BAY_BOX_DEPTH_M), TERRACE_Y, CANOPY_TOP_Y - CANOPY_THICKNESS_M)
		u += WSW_FIN_PITCH_M
	for volume: Array in ROOF_VOLUMES:
		var target := dark if str(volume[7]) in ["pavilion", "penthouse"] else solid
		_append_slab(target, target, _side_rect(str(volume[0]), volume[1], volume[2], volume[3], volume[4]), volume[5], volume[6])
	return {"solid": _flat_geometry(solid, "volumes"), "dark": _flat_geometry(dark, "volumes_dark")}


# ---------------------------------------------------------------------------
# Stage B (2026-10-24): structural window grid from rectified Sep 2025 Street View
# and the architect's photos (production inference; grid tables in the task note).
# Floors L2-L6 at DECK_Y + k * UPPER_STOREY_M; one sill (F + 0.35) and one head
# (F + 2.95) per floor; columns are shared by every floor of a face.
const FLOORS := [8.474, 11.624, 14.774, 17.924, 21.074]
const WIN_SILL_M := 0.35
const WIN_HEAD_M := 2.95
const REVEAL_M := 0.2
# Window columns [u0, u1] per face on the cladding at the footprint line (SE tall block
# hk02/hk13/cav-7; ENE E and N blocks and middle box cav-4/hk13/hk07; NNW 6-storey
# hk15). Corner columns wrap the E and N corners (hk13, hk09, cav-4).
const WINDOW_COLUMNS := {
	"se": [[38.1, 39.3], [40.0, 42.3], [44.7, 45.7], [47.1, 49.4], [50.6, 51.7], [53.9, 56.2], [57.6, 59.45]],
	"ene": [[0.15, 4.8], [7.25, 9.6], [11.0, 12.5], [19.6, 20.8], [23.25, 24.5], [25.6, 27.9], [30.0, 32.0], [33.25, 34.5],
		[36.6, 38.5], [39.9, 40.9], [47.0, 49.0], [51.0, 52.0], [53.1, 55.0], [57.0, 59.95]],
	"nnw": [[0.15, 1.4], [3.75, 6.0], [7.5, 9.75], [12.1, 14.25], [16.75, 19.0], [25.0, 26.1], [27.25, 29.6], [31.9, 33.0],
		[35.4, 37.6], [38.6, 40.2]],
}
# Floor groups per face (indices into FLOORS): NNW windows join two floors over a dark
# spandrel with a white sill under each pair (hk15); SE and ENE are single floors.
const FLOOR_GROUPS := {"se": [[0, 0], [1, 1], [2, 2], [3, 3], [4, 4]], "ene": [[0, 0], [1, 1], [2, 2], [3, 3], [4, 4]], "nnw": [[0, 1], [2, 3], [4, 4]]}
# ENE recessed bay (0.8 m notch, cav-4): one column on its inset plane.
const ENE_BAY_COLUMN := [14.9, 16.6]
# Two-storey window groups on the projecting boxes (L2-L3): SE six groups (cav-2
# count, cav-7/hk01 positions, regular 5.15 m pitch), WSW one per 6.45 m plan module
# from the terrace fins plus two in the corner block (cav-3, cav-6; inference), NNW
# narrow and wide group (hk15).
const BOX_GROUP_W_M := 2.7
const BOX_GROUPS := {
	"se": [0.35, 5.5, 10.65, 15.8, 20.95, 26.1],
	"nnw": [[43.4, 44.8], [50.3, 52.7]],
}
# Ground openings at the footprint line [u0, u1, kind] (hk02, hk13, hk07, hk15, cav-4).
const GROUND_OPENINGS := {
	"se": [[38.7, 44.1, "garage"], [44.85, 45.55, "door"], [47.1, 49.4, "win"], [53.9, 56.2, "win"], [57.6, 59.45, "store"]],
	"ene": [[0.15, 4.8, "store"], [7.25, 9.6, "win"], [11.45, 12.55, "door"], [14.9, 16.6, "win_bay"], [47.0, 49.0, "win"],
		[51.0, 52.0, "win"], [53.1, 55.0, "win"], [57.0, 59.95, "store"]],
	"nnw": [[0.15, 1.4, "store"], [3.75, 6.0, "win"], [7.5, 9.75, "win"], [12.1, 14.25, "door"], [16.75, 19.0, "win"],
		[25.0, 26.1, "door"], [27.25, 29.6, "win"], [31.9, 33.0, "door"], [35.4, 37.6, "win"], [38.6, 40.2, "win"],
		[43.4, 44.8, "door"], [50.3, 52.7, "win"]],
}
# Fourth storey at the line on the 4-storey wing (NNW west part and the WSW corner
# block): window columns (hk15; cav-3 inference).
const L4_COLUMNS := {"nnw": [[43.4, 44.8], [50.3, 52.7]], "wsw": [[2.0, 4.7], [7.5, 10.2]]}
# Recessed planes by notch (glazed slot, stair and strip curtain walls; ENE middle
# ground and loggia): their back walls are glass, the ENE bay is clad.
const GLASS_NOTCH_OUTS := {"se": [-1.0], "ene": [-1.8, -1.2], "nnw": [-1.0]}
# Recessed ground storeys that are opaque pale walls with punched windows and doors
# (hk07, cav-4 ENE middle; cav-3, cav-6 WSW live-work units), not storefront glazing.
const BASE_GROUND_OUTS := {"ene": [-1.8], "wsw": [-RECESS_M]}
# WSW and ENE-middle ground openings on those recessed planes [u0, u1, kind]; the WSW
# list is built per plan module in recessed_ground_openings().
const ENE_MIDDLE_GROUND := [[19.6, 20.8, "win"], [23.45, 24.55, "door"], [25.6, 27.9, "win"], [30.0, 32.0, "win"],
	[33.25, 34.5, "win"], [35.45, 36.55, "door"], [39.9, 40.9, "win"]]
const WSW_GROUP_W_M := 4.4


static func wsw_group_starts() -> Array:
	var starts := [1.6, 7.2]
	var m := (SETBACK_U_RANGES.wsw as Vector2).x
	while m + 1.5 + WSW_GROUP_W_M < float(side_frame("wsw").length) - 2.0:
		starts.append(m + 1.0)
		m += WSW_FIN_PITCH_M
	return starts


static func is_base_ground(side: String, out: float) -> bool:
	for o: float in BASE_GROUND_OUTS.get(side, []):
		if absf(out - o) < 0.05:
			return true
	return false


# Openings on the opaque recessed ground storeys: ENE middle (doors at the stoops) and
# the WSW live-work units, one per 6.45 m module: the stoop door plus a window, or a
# window, and the S corner storefront under the wedge.
static func recessed_ground_openings() -> Array:
	var result := []
	for g: Array in ENE_MIDDLE_GROUND:
		result.append(["ene", -1.8, g[0], g[1], g[2]])
	var w := -RECESS_M
	result.append(["wsw", w, 3.0, 5.5, "win"])
	result.append(["wsw", w, 8.0, 10.5, "win"])
	var length := float(side_frame("wsw").length)
	var corner_store := length - 8.0
	var m := (SETBACK_U_RANGES.wsw as Vector2).x
	while m + WSW_FIN_PITCH_M <= corner_store + 0.01:
		var door := -1.0
		for stoop: Array in STOOPS:
			if str(stoop[0]) == "wsw" and float(stoop[1]) > m and float(stoop[1]) < m + WSW_FIN_PITCH_M:
				door = float(stoop[1])
		if door > 0.0:
			result.append(["wsw", w, door - 0.55, door + 1.15, "door_side"])
			# The window takes the wider side of the module beside the door.
			if m + WSW_FIN_PITCH_M - door > door - m:
				result.append(["wsw", w, door + 1.6, m + WSW_FIN_PITCH_M - 0.9, "win"])
			else:
				result.append(["wsw", w, m + 0.9, door - 1.2, "win"])
		else:
			result.append(["wsw", w, m + 1.5, m + 1.5 + WSW_GROUP_W_M, "win"])
		m += WSW_FIN_PITCH_M
	result.append(["wsw", w, corner_store + 0.4, length - 0.3, "store"])
	return result


# Every punched opening as {side, out, u0, u1, y0, y1, kind, pane, spandrels}.
static func openings() -> Array:
	var result := []
	for side: String in WINDOW_COLUMNS:
		for column: Array in WINDOW_COLUMNS[side]:
			for group: Array in FLOOR_GROUPS[side]:
				if side == "ene" and float(column[0]) > ENE_BOX_U.x and float(column[1]) < ENE_BOX_U.y and int(group[1]) >= 4:
					continue
				var f0: float = FLOORS[group[0]]
				var f1: float = FLOORS[group[1]]
				var spandrels := []
				for k in range(int(group[0]) + 1, int(group[1]) + 1):
					spandrels.append([float(FLOORS[k - 1]) + WIN_HEAD_M, float(FLOORS[k]) + WIN_SILL_M])
				result.append({"side": side, "out": 0.0, "u0": column[0], "u1": column[1], "y0": f0 + WIN_SILL_M, "y1": f1 + WIN_HEAD_M,
					"kind": "corner" if float(column[1]) - float(column[0]) > 2.6 else "win", "pane": "glass", "spandrels": spandrels})
	for f: float in FLOORS:
		result.append({"side": "ene", "out": -0.8, "u0": ENE_BAY_COLUMN[0], "u1": ENE_BAY_COLUMN[1], "y0": f + WIN_SILL_M, "y1": f + WIN_HEAD_M, "kind": "win", "pane": "glass", "spandrels": []})
	var groups := {"se": [], "wsw": [], "nnw": BOX_GROUPS.nnw}
	for start: float in BOX_GROUPS.se:
		groups.se.append([start, start + BOX_GROUP_W_M])
	for start: float in wsw_group_starts():
		groups.wsw.append([start, start + WSW_GROUP_W_M])
	for side: String in groups:
		for g: Array in groups[side]:
			result.append({"side": side, "out": BAY_BOX_DEPTH_M, "u0": g[0], "u1": g[1], "y0": DECK_Y + 0.45, "y1": TERRACE_Y - 0.5, "kind": "group", "pane": "glass",
				"spandrels": [[FLOORS[1] - 0.2, FLOORS[1] + 0.2]]})
	for side: String in L4_COLUMNS:
		for column: Array in L4_COLUMNS[side]:
			result.append({"side": side, "out": 0.0, "u0": column[0], "u1": column[1], "y0": TERRACE_Y + 0.35, "y1": LOW_TOP_Y - 0.55, "kind": "win", "pane": "glass", "spandrels": []})
	var ground := []
	for side: String in GROUND_OPENINGS:
		for g: Array in GROUND_OPENINGS[side]:
			ground.append([side, -0.8 if str(g[2]) == "win_bay" else 0.0, g[0], g[1], g[2]])
	ground.append_array(recessed_ground_openings())
	for entry: Array in ground:
		var side := str(entry[0])
		var g := [entry[2], entry[3], entry[4]]
		var kind := str(g[2])
		var out := float(entry[1])
		var y0 := 4.75
		var y1 := 7.35
		var pane := "store"
		match kind:
			"store":
				pane = "lobby"
				y0 = 4.35
				y1 = 7.6
			"door", "door_side":
				y0 = maxf(4.3, _stoop_top(side, float(g[0]) + 0.55))
				y1 = y0 + 2.6
			"garage":
				y0 = 4.3
				y1 = 7.0
				pane = "garage"
		result.append({"side": side, "out": out, "u0": g[0], "u1": g[1], "y0": y0, "y1": y1, "kind": "win" if kind == "win_bay" else kind, "pane": pane, "spandrels": []})
	return result


# Stoop platform top at u on a side, or -INF.
static func _stoop_top(side: String, u: float) -> float:
	for stoop: Array in STOOPS:
		if str(stoop[0]) == side and absf(float(stoop[1]) - u) < 1.5:
			return float(stoop[2]) + STOOP_RISE_M
	return -INF


static func openings_on(side: String, out: float, u_range := Vector2(-INF, INF)) -> Array:
	var result := []
	for o: Dictionary in openings():
		if str(o.side) == side and absf(float(o.out) - out) < 0.05 and float(o.u1) > u_range.x and float(o.u0) < u_range.y:
			result.append(o)
	return result


# Wall receiver surfaces by material key: each wall quad split into its ground band
# (base) and upper band (cladding), recessed planes glazed, with openings punched.
static func wall_surfaces(quads: Array) -> Dictionary:
	var buckets := {}
	for quad: Dictionary in quads:
		var sb := quad.start_bottom as Vector3
		var eb := quad.end_bottom as Vector3
		var top := (quad.start_top as Vector3).y
		var normal := quad.normal as Vector3
		var n2 := Vector2(normal.x, normal.z)
		var origin := Vector2(sb.x, sb.z)
		var t2 := (Vector2(eb.x, eb.z) - origin).normalized()
		var length := origin.distance_to(Vector2(eb.x, eb.z))
		var side := ""
		var out := 0.0
		var u_start := 0.0
		for name: String in SIDES:
			var f := side_frame(name)
			if n2.dot(f.normal) > 0.999:
				side = name
				out = (origin - (f.start as Vector2)).dot(f.normal)
				u_start = (origin - (f.start as Vector2)).dot(f.tangent)
		var role := str(quad.role)
		var glass_plane := false
		if side != "":
			for o: float in GLASS_NOTCH_OUTS.get(side, []):
				if absf(out - o) < 0.05:
					glass_plane = true
		var upper_key := "clad"
		var ground_key := "base"
		if role == "setback" or glass_plane:
			upper_key = "glass"
			ground_key = "lobby"
		elif role == "recess":
			ground_key = "lobby" if side != "" else "base"
		if is_base_ground(side, out):
			ground_key = "base"
		var skirt := maxf(sb.y, eb.y)
		var frame := {"origin": origin, "t": t2, "n": n2, "u_start": u_start}
		# Sloped source bottom: a solid skirt up to the higher end.
		if absf(sb.y - eb.y) > 0.001:
			var b := _key_bucket(buckets, ground_key if skirt <= DECK_Y else upper_key)
			var n3 := Vector3(n2.x, 0.0, n2.y)
			if sb.y < eb.y:
				_append_oriented(b, sb, eb, Vector3(sb.x, skirt, sb.z), n3)
			else:
				_append_oriented(b, sb, eb, Vector3(eb.x, skirt, eb.z), n3)
		var holes := []
		if side != "" and role in ["outer", "recess"]:
			holes = openings_on(side, out)
		var bands := [[skirt, minf(DECK_Y, top), ground_key], [maxf(skirt, DECK_Y), top, upper_key]]
		for band: Array in bands:
			if float(band[1]) - float(band[0]) > 0.005:
				if str(band[2]) == "lobby" and holes.is_empty():
					var n3 := Vector3(n2.x, 0.0, n2.y)
					_lobby_panes(buckets, frame, u_start, u_start + length, band[0], band[1], 0.0, n3)
				else:
					_punch_frame(buckets, str(band[2]), frame, u_start, u_start + length, band[0], band[1], holes)
	return buckets


static func _key_bucket(buckets: Dictionary, key: String) -> Dictionary:
	if not buckets.has(key):
		buckets[key] = _bucket()
	return buckets[key]


# Punch a rectangle on a side plane `out` metres from the footprint line.
static func _punch_rect(buckets: Dictionary, key: String, side: String, out: float, u0: float, u1: float, y0: float, y1: float, holes: Array) -> void:
	var f := side_frame(side)
	var frame := {"origin": (f.start as Vector2) + (f.normal as Vector2) * out, "t": f.tangent, "n": f.normal, "u_start": 0.0}
	_punch_frame(buckets, key, frame, u0, u1, y0, y1, holes)


# Wall rectangle [u0,u1] x [y0,y1] (u along the side) cut around openings: solid cells
# in `key`, each opening lined with REVEAL_M deep reveals (true edges only, so an
# opening split across wall quads stays continuous) and a pane at the back.
static func _punch_frame(buckets: Dictionary, key: String, frame: Dictionary, u0: float, u1: float, y0: float, y1: float, holes: Array) -> void:
	var cut := []
	for o: Dictionary in holes:
		var a := maxf(float(o.u0), u0)
		var b := minf(float(o.u1), u1)
		var c := maxf(float(o.y0), y0)
		var e := minf(float(o.y1), y1)
		if b - a > 0.05 and e - c > 0.05:
			# Horizontal edges always get a reveal (bands never share an opening).
			cut.append([a, b, c, e, o, absf(a - float(o.u0)) < 0.001, absf(b - float(o.u1)) < 0.001, true, true])
	var us := [u0, u1]
	var ys := [y0, y1]
	for c: Array in cut:
		us.append_array([c[0], c[1]])
		ys.append_array([c[2], c[3]])
	us = _unique(us)
	ys = _unique(ys)
	var n3 := Vector3((frame.n as Vector2).x, 0.0, (frame.n as Vector2).y)
	var t3 := Vector3((frame.t as Vector2).x, 0.0, (frame.t as Vector2).y)
	var solid := _key_bucket(buckets, key)
	for j in ys.size() - 1:
		var y_mid := (float(ys[j]) + float(ys[j + 1])) * 0.5
		var run := -1
		for i in us.size():
			var open := false
			if i < us.size() - 1:
				var u_mid := (float(us[i]) + float(us[i + 1])) * 0.5
				for c: Array in cut:
					if u_mid > float(c[0]) and u_mid < float(c[1]) and y_mid > float(c[2]) and y_mid < float(c[3]):
						open = true
			var solid_cell := i < us.size() - 1 and not open
			if solid_cell and run < 0:
				run = i
			elif not solid_cell and run >= 0:
				_quad_on(solid, frame, us[run], us[i], ys[j], ys[j + 1], 0.0, n3)
				run = -1
	for c: Array in cut:
		var a: float = c[0]
		var b: float = c[1]
		var lo: float = c[2]
		var hi: float = c[3]
		var d := -REVEAL_M
		var reveal := _key_bucket(buckets, "reveal")
		if c[5]:
			_append_oriented_quad(reveal, _fp(frame, a, lo, 0.0), _fp(frame, a, lo, d), _fp(frame, a, hi, d), _fp(frame, a, hi, 0.0), t3)
		if c[6]:
			_append_oriented_quad(reveal, _fp(frame, b, lo, 0.0), _fp(frame, b, lo, d), _fp(frame, b, hi, d), _fp(frame, b, hi, 0.0), -t3)
		if c[7]:
			_append_oriented_quad(reveal, _fp(frame, a, lo, 0.0), _fp(frame, b, lo, 0.0), _fp(frame, b, lo, d), _fp(frame, a, lo, d), Vector3.UP)
		if c[8]:
			_append_oriented_quad(reveal, _fp(frame, a, hi, 0.0), _fp(frame, b, hi, 0.0), _fp(frame, b, hi, d), _fp(frame, a, hi, d), Vector3.DOWN)
		var pane := str((c[4] as Dictionary).pane)
		if pane == "lobby":
			_lobby_panes(buckets, frame, a, b, lo, hi, d, n3)
		else:
			_quad_on(_key_bucket(buckets, pane), frame, a, b, lo, hi, d, n3)


# Storefront/lobby glazing as dark glass with a restrained interior value structure
# behind it (hk02, cav-7, cav-2, hk22): a darker low band, a dim lit ceiling band under
# the head, and the field between split on an absolute 1.6 m u grid into darker glass
# with an occasional dimly lit interior bay.
static func _lobby_panes(buckets: Dictionary, frame: Dictionary, u0: float, u1: float, y0: float, y1: float, d: float, n3: Vector3) -> void:
	var low := minf(y0 + 0.9, y1 - 0.8)
	var top := maxf(y1 - 0.55, low + 0.3)
	_quad_on(_key_bucket(buckets, "lobby_low"), frame, u0, u1, y0, low, d, n3)
	_quad_on(_key_bucket(buckets, "lobby_top"), frame, u0, u1, top, y1, d, n3)
	var cuts := [u0, u1]
	var k := ceili(u0 / 1.6)
	while float(k) * 1.6 < u1 - 0.05:
		if float(k) * 1.6 > u0 + 0.05:
			cuts.append(float(k) * 1.6)
		k += 1
	cuts = _unique(cuts)
	for i in cuts.size() - 1:
		var cell := int(floor((float(cuts[i]) + float(cuts[i + 1])) * 0.5 / 1.6))
		var key := "lobby_alt" if posmod(cell * 7 + 3, 5) < 2 else "lobby"
		_quad_on(_key_bucket(buckets, key), frame, cuts[i], cuts[i + 1], low, top, d, n3)


static func _fp(frame: Dictionary, u: float, y: float, d: float) -> Vector3:
	var p := (frame.origin as Vector2) + (frame.t as Vector2) * (u - float(frame.u_start)) + (frame.n as Vector2) * d
	return Vector3(p.x, y, p.y)


static func _quad_on(bucket: Dictionary, frame: Dictionary, u0: float, u1: float, y0: float, y1: float, d: float, outward: Vector3) -> void:
	_append_oriented_quad(bucket, _fp(frame, u0, y0, d), _fp(frame, u1, y0, d), _fp(frame, u1, y1, d), _fp(frame, u0, y1, d), outward)


static func _append_oriented_quad(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, d: Vector3, outward: Vector3) -> void:
	_append_oriented(bucket, a, b, c, outward)
	_append_oriented(bucket, a, c, d, outward)


static func _unique(values: Array) -> Array:
	values.sort()
	var out := []
	for v: float in values:
		if out.is_empty() or v - float(out[-1]) > 0.001:
			out.append(v)
	return out


# Box on a side between out0 (back) and out1 (front) without its front face.
static func _append_box_open_front(bucket: Dictionary, side: String, u0: float, u1: float, out0: float, out1: float, y0: float, y1: float) -> void:
	var f := side_frame(side)
	var t3 := Vector3((f.tangent as Vector2).x, 0.0, (f.tangent as Vector2).y)
	var n3 := Vector3((f.normal as Vector2).x, 0.0, (f.normal as Vector2).y)
	var p := func(u: float, o: float, y: float) -> Vector3: return _at(side_point(side, u, o), y)
	_append_oriented_quad(bucket, p.call(u0, out0, y1), p.call(u1, out0, y1), p.call(u1, out1, y1), p.call(u0, out1, y1), Vector3.UP)
	_append_oriented_quad(bucket, p.call(u0, out0, y0), p.call(u1, out0, y0), p.call(u1, out1, y0), p.call(u0, out1, y0), Vector3.DOWN)
	_append_oriented_quad(bucket, p.call(u0, out0, y0), p.call(u1, out0, y0), p.call(u1, out0, y1), p.call(u0, out0, y1), -n3)
	_append_oriented_quad(bucket, p.call(u0, out0, y0), p.call(u0, out1, y0), p.call(u0, out1, y1), p.call(u0, out0, y1), -t3)
	_append_oriented_quad(bucket, p.call(u1, out0, y0), p.call(u1, out1, y0), p.call(u1, out1, y1), p.call(u1, out0, y1), t3)


# Coarse Stage B materials (no textures): the existing Hawkins cladding resources plus
# two glass families after the Isle House c10 lesson: upper glass light and mirror-like
# (metallic 0.8, smooth) so it picks up sky at street angles; storefront glass a dark
# dielectric; reveals grey frame metal.
static var _surface_materials := {}


static func surface_material(key: String) -> Material:
	if _surface_materials.has(key):
		return _surface_materials[key]
	var material: Material
	match key:
		"clad":
			material = preload("res://game/resources/materials/world/hawkins/hawkins_pearl_fluted.tres")
		"base":
			material = preload("res://game/resources/materials/world/hawkins/hawkins_base_smooth.tres")
		"reveal":
			material = preload("res://game/resources/materials/world/hawkins/hawkins_frame_grey.tres")
		"garage":
			material = preload("res://game/resources/materials/world/hawkins/hawkins_garage_dark.tres")
		"glass":
			material = _plain(Color(0.5, 0.53, 0.55), 0.12, 0.55)
		"store":
			material = _plain(Color(0.08, 0.10, 0.11), 0.05, 0.0)
		"lobby":
			material = _plain(Color(0.15, 0.16, 0.16), 0.06, 0.45)
		"lobby_low":
			material = _plain(Color(0.08, 0.085, 0.085), 0.06, 0.45)
		"lobby_alt":
			var dim := _plain(Color(0.26, 0.24, 0.21), 0.08, 0.3)
			dim.emission_enabled = true
			dim.emission = Color(0.45, 0.39, 0.30)
			dim.emission_energy_multiplier = 0.12
			material = dim
		"lobby_top":
			var band := _plain(Color(0.42, 0.38, 0.31), 0.1, 0.2)
			band.emission_enabled = true
			band.emission = Color(0.6, 0.5, 0.38)
			band.emission_energy_multiplier = 0.3
			material = band
		_:
			material = preload("res://game/resources/materials/world/hawkins/hawkins_pearl_plain.tres")
	_surface_materials[key] = material
	return material


static func _plain(albedo: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = roughness
	m.metallic = metallic
	return m


static func _side_rect(side: String, u0: float, u1: float, out0: float, out1: float) -> PackedVector2Array:
	return _ordered(PackedVector2Array([side_point(side, u0, out0), side_point(side, u1, out0), side_point(side, u1, out1), side_point(side, u0, out1)]))


# Plan of the recessed ground strip: the WSW box range to the S corner and the SE
# box range from it, RECESS_M deep, joined where the recessed lines meet.
static func recess_strip() -> PackedVector2Array:
	var w := recess_range("wsw")
	var e := recess_range("se")
	return PackedVector2Array([
		side_point("wsw", w.x, 0.0), B, side_point("se", e.y, 0.0),
		side_point("se", e.y, -RECESS_M), recess_corner(), side_point("wsw", w.x, -RECESS_M),
	])


static func recess_corner() -> Vector2:
	return Geometry2D.line_intersects_line(side_point("wsw", 0.0, -RECESS_M), side_frame("wsw").tangent, side_point("se", 0.0, -RECESS_M), side_frame("se").tangent) as Vector2


# u range along a side where the ground storey is recessed (box range, less the
# corner join).
static func recess_range(side: String) -> Vector2:
	if side not in ["wsw", "se"]:
		return Vector2(INF, -INF)
	var r := bay_box_range(side)
	var corner_u := (recess_corner() - (side_frame(side).start as Vector2)).dot(side_frame(side).tangent)
	return Vector2(maxf(r.x, RECESS_WSW_START_M), corner_u) if side == "wsw" else Vector2(corner_u, r.y)


# Footprint-line u range whose outer wall loses its ground storey to the recess.
static func ground_cut_range(side: String) -> Vector2:
	if side == "wsw":
		return Vector2(recess_range("wsw").x, float(side_frame("wsw").length))
	if side == "se":
		return Vector2(0.0, recess_range("se").y)
	return Vector2(INF, -INF)


static func bay_box_range(side: String) -> Vector2:
	var u_range: Vector2 = BAY_BOX_U_RANGES[side]
	return Vector2(maxf(u_range.x, 0.0), minf(u_range.y, float(side_frame(side).length)))


# Collision for the terrace glass rail drawn by the facade (0.15-0.17 m inside
# the footprint line, terrace to 0.94 m above it) along the WSW and SE setbacks.
static func rail_collision() -> Dictionary:
	var bucket := _bucket()
	for side: String in SETBACK_U_RANGES:
		var f := side_frame(side)
		var u_range: Vector2 = SETBACK_U_RANGES[side]
		var u0 := maxf(u_range.x, 0.0)
		var u1 := minf(u_range.y, float(f.length))
		var t := Vector3((f.tangent as Vector2).x, 0.0, (f.tangent as Vector2).y)
		var n := Vector3((f.normal as Vector2).x, 0.0, (f.normal as Vector2).y)
		var center := _at(side_point(side, (u0 + u1) * 0.5, -0.16), 0.0)
		_box(bucket, center, t, n, u1 - u0 - 0.1, TERRACE_Y, TERRACE_Y + 0.94, 0.04)
	return _flat_geometry(bucket, "rail")


# Raised stoops: a solid platform and two planter blocks flanking a three-riser
# flight. Treads are decor; a hidden walkable ramp through the nosings carries
# the player (the accepted Chapel/Mersea stair grammar).
static func stoop_geometry() -> Dictionary:
	var solid := _bucket()
	var decor := _bucket()
	var support := _bucket()
	var risers := _bucket()
	for stoop: Array in STOOPS:
		var side := str(stoop[0])
		var u: float = stoop[1]
		var land: float = stoop[2]
		var f := side_frame(side)
		var t := Vector3((f.tangent as Vector2).x, 0.0, (f.tangent as Vector2).y)
		var n := Vector3((f.normal as Vector2).x, 0.0, (f.normal as Vector2).y)
		var base := _at(side_point(side, u, -_stoop_recess(side, u)), 0.0)
		var floor_y := land - 0.15
		var top_y := land + STOOP_RISE_M
		var riser := STOOP_RISE_M / 3.0
		_box(solid, base + n * (STOOP_DEPTH_M * 0.5), t, n, STOOP_WIDTH_M, floor_y, top_y, STOOP_DEPTH_M)
		var planter_depth := STEP_TREAD_M * 3.0 + 0.2
		var planter_width := (STOOP_WIDTH_M - STEP_WIDTH_M) * 0.5 + 0.3
		# WSW: one planter only, so the stair run stays open on its north side and
		# reads between the cheek walls (hk23; Stage B rework).
		for s: float in ([1.0] if side == "wsw" else [-1.0, 1.0]):
			var center := base + n * (STOOP_DEPTH_M + planter_depth * 0.5) + t * s * (STEP_WIDTH_M * 0.5 + planter_width * 0.5)
			_box(solid, center, t, n, planter_width, floor_y, land + PLANTER_TOP_ABOVE_LAND_M, planter_depth)
		if side == "wsw":
			# Cheek walls flanking the raised entry under the projecting wing, from the
			# recessed wall to the footprint line (hk23, cav-3, cav-6; ROOT approved).
			for s: float in [-1.0, 1.0]:
				_box(solid, base + n * (RECESS_M * 0.5) + t * s * (STOOP_WIDTH_M * 0.5 + 0.11), t, n, 0.22, floor_y, top_y + 0.45, RECESS_M)
		for step in 2:
			var tread_top := top_y - float(step + 1) * riser
			_box(decor, base + n * (STOOP_DEPTH_M + STEP_TREAD_M * (float(step) + 0.5)), t, n, STEP_WIDTH_M, floor_y, tread_top, STEP_TREAD_M)
		# Render-only dark riser faces so the run reads as steps (hk23).
		for k in 3:
			var front := STOOP_DEPTH_M + float(k) * STEP_TREAD_M + 0.012
			var r_top := top_y - float(k) * riser
			var c := base + n * front
			_append_oriented_quad(risers, c - t * STEP_WIDTH_M * 0.5 + Vector3.UP * (r_top - riser), c + t * STEP_WIDTH_M * 0.5 + Vector3.UP * (r_top - riser), c + t * STEP_WIDTH_M * 0.5 + Vector3.UP * (r_top - 0.02), c - t * STEP_WIDTH_M * 0.5 + Vector3.UP * (r_top - 0.02), n)
		var stations: Array = [[STOOP_DEPTH_M + 3.0 * STEP_TREAD_M, land - 0.01]]
		for k in range(2, -1, -1):
			stations.append([STOOP_DEPTH_M + float(k) * STEP_TREAD_M, top_y - float(k) * riser])
		var half := STEP_WIDTH_M * 0.5
		for i in stations.size() - 1:
			var outer: Array = stations[i]
			var inner: Array = stations[i + 1]
			var p0 := base + n * float(outer[0]) - t * half + Vector3.UP * float(outer[1])
			var p1 := base + n * float(outer[0]) + t * half + Vector3.UP * float(outer[1])
			var p2 := base + n * float(inner[0]) + t * half + Vector3.UP * float(inner[1])
			var p3 := base + n * float(inner[0]) - t * half + Vector3.UP * float(inner[1])
			_append_oriented(support, p0, p1, p2, Vector3.UP)
			_append_oriented(support, p0, p2, p3, Vector3.UP)
	return {"solid": _flat_geometry(solid, "stoops"), "decor": _flat_geometry(decor, "stoop_steps"), "support": _flat_geometry(support, "stoop_support"), "risers": _flat_geometry(risers, "stoop_risers")}


# How far the ground-floor wall behind a stoop sits inside the footprint line.
static func _stoop_recess(side: String, u: float) -> float:
	if side == "wsw":
		return RECESS_M
	if side == "ene" and u > ENE_BOX_U.x and u < ENE_BOX_U.y:
		return 1.8
	return 0.0


static func _height_at(all_pieces: Array[Dictionary], point: Vector2) -> float:
	for piece: Dictionary in all_pieces:
		if Geometry2D.is_point_in_polygon(point, piece.poly):
			return float(piece.top)
	return NAN


static func _source_bottom(source_quads: Array[Dictionary], point: Vector2) -> float:
	for quad: Dictionary in source_quads:
		var s := quad.start_bottom as Vector3
		var e := quad.end_bottom as Vector3
		var a := Vector2(s.x, s.z)
		var b := Vector2(e.x, e.z)
		if Geometry2D.get_closest_point_to_segment(point, a, b).distance_to(point) < 0.01:
			var t := clampf((point - a).dot(b - a) / a.distance_squared_to(b), 0.0, 1.0)
			return lerpf(s.y, e.y, t)
	return NAN


# Source wall bottom at a point on the footprint line, or, for walls set back in a
# notch, at its projection on the nearest footprint edge within 2.5 m (as the
# recessed ground walls do).
static func _ground_bottom(source_quads: Array[Dictionary], point: Vector2) -> float:
	var exact := _source_bottom(source_quads, point)
	if not is_nan(exact):
		return exact
	var best := NAN
	var best_distance := 2.5
	for quad: Dictionary in source_quads:
		var s := quad.start_bottom as Vector3
		var e := quad.end_bottom as Vector3
		var a := Vector2(s.x, s.z)
		var b := Vector2(e.x, e.z)
		var distance := Geometry2D.get_closest_point_to_segment(point, a, b).distance_to(point)
		if distance < best_distance:
			best_distance = distance
			best = lerpf(s.y, e.y, clampf((point - a).dot(b - a) / a.distance_squared_to(b), 0.0, 1.0))
	return best


static func _signed_area(poly: PackedVector2Array) -> float:
	var area := 0.0
	for i in poly.size():
		var p := poly[i]
		var q := poly[(i + 1) % poly.size()]
		area += p.x * q.y - q.x * p.y
	return area * 0.5


static func _ordered(poly: PackedVector2Array) -> PackedVector2Array:
	if _signed_area(poly) > 0.0:
		var reversed := poly.duplicate()
		reversed.reverse()
		return reversed
	return poly


static func _at(p: Vector2, y: float) -> Vector3:
	return Vector3(p.x, y, p.y)


static func _bucket() -> Dictionary:
	return {"vertices": PackedVector3Array(), "indices": PackedInt32Array()}


static func _append_slab(top: Dictionary, soffit: Dictionary, poly: PackedVector2Array, bottom_y: float, top_y: float) -> void:
	var triangles := Geometry2D.triangulate_polygon(poly)
	for i in range(0, triangles.size(), 3):
		var a := poly[triangles[i]]
		var b := poly[triangles[i + 1]]
		var c := poly[triangles[i + 2]]
		_append_oriented(top, _at(a, top_y), _at(b, top_y), _at(c, top_y), Vector3.UP)
		_append_oriented(soffit, _at(a, bottom_y), _at(b, bottom_y), _at(c, bottom_y), Vector3.DOWN)
	for i in poly.size():
		var p := poly[i]
		var q := poly[(i + 1) % poly.size()]
		var d := (q - p).normalized()
		var out := Vector3(-d.y, 0.0, d.x)
		_append_oriented(top, _at(p, bottom_y), _at(q, bottom_y), _at(q, top_y), out)
		_append_oriented(top, _at(p, bottom_y), _at(q, top_y), _at(p, top_y), out)


static func _box(bucket: Dictionary, center: Vector3, t: Vector3, n: Vector3, width: float, bottom_y: float, top_y: float, depth: float) -> void:
	var hx := t * width * 0.5
	var hz := n * depth * 0.5
	var c := Vector3(center.x, 0.0, center.z)
	var corners := [c - hx - hz, c + hx - hz, c + hx + hz, c - hx + hz]
	for face: Array in [[0, 1, -n], [1, 2, t], [2, 3, n], [3, 0, -t]]:
		var p: Vector3 = corners[face[0]]
		var q: Vector3 = corners[face[1]]
		var out: Vector3 = face[2]
		_append_oriented(bucket, p + Vector3.UP * bottom_y, q + Vector3.UP * bottom_y, q + Vector3.UP * top_y, out)
		_append_oriented(bucket, p + Vector3.UP * bottom_y, q + Vector3.UP * top_y, p + Vector3.UP * top_y, out)
	var up: Array[Vector3] = []
	for corner: Vector3 in corners:
		up.append(corner + Vector3.UP * top_y)
	_append_oriented(bucket, up[0], up[1], up[2], Vector3.UP)
	_append_oriented(bucket, up[0], up[2], up[3], Vector3.UP)


# Godot front faces are clockwise seen from the front (outward) side; native
# queries without back faces (the fit harness) see only those.
static func _append_oriented(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, outward: Vector3) -> void:
	var vertices: PackedVector3Array = bucket.vertices
	var indices: PackedInt32Array = bucket.indices
	var base := vertices.size()
	vertices.append_array([a, b, c])
	if (b - a).cross(c - a).dot(outward) > 0.0:
		indices.append_array([base, base + 2, base + 1])
	else:
		indices.append_array([base, base + 1, base + 2])
	bucket.vertices = vertices
	bucket.indices = indices


static func _flat_geometry(bucket: Dictionary, role: String) -> Dictionary:
	var vertices: PackedVector3Array = bucket.vertices
	var indices: PackedInt32Array = bucket.indices
	var normals := PackedVector3Array()
	normals.resize(vertices.size())
	for i in range(0, indices.size(), 3):
		var a := vertices[indices[i]]
		var b := vertices[indices[i + 1]]
		var c := vertices[indices[i + 2]]
		# Clockwise front faces: the outward normal is (c - a) x (b - a).
		var normal := (c - a).cross(b - a).normalized()
		for k in 3:
			normals[indices[i + k]] = normal
	var uvs := PackedVector2Array()
	var tangents := PackedFloat32Array()
	for vertex: Vector3 in vertices:
		uvs.append(Vector2(vertex.x + vertex.z, vertex.y) * 0.1)
		tangents.append_array(PackedFloat32Array([1.0, 0.0, 0.0, 1.0]))
	return {"ok": true, "vertices": vertices, "normals": normals, "uvs": uvs, "tangents": tangents, "indices": indices, "signature": _geometry_signature(vertices, indices, role)}


static func _source_wall_quads(record: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var raw_vertices: Array = record.get("vertices", [])
	var raw_normals: Array = record.get("normals", [])
	if raw_vertices.size() != 240 or raw_normals.size() != 240:
		return result
	for vertex_index in range(0, 80, 4):
		var offset := vertex_index * 3
		result.append({
			"start_bottom": Vector3(float(raw_vertices[offset]), float(raw_vertices[offset + 1]), float(raw_vertices[offset + 2])),
			"end_bottom": Vector3(float(raw_vertices[offset + 3]), float(raw_vertices[offset + 4]), float(raw_vertices[offset + 5])),
			"normal": Vector3(float(raw_normals[offset]), float(raw_normals[offset + 1]), float(raw_normals[offset + 2])).normalized(),
		})
	return result


static func _append_wall_quad(target: Array[Dictionary], start_bottom: Vector3, end_bottom: Vector3, top_y: float, normal: Vector3, role: String, volume: String) -> void:
	target.append({
		"start_bottom": start_bottom,
		"end_bottom": end_bottom,
		"end_top": Vector3(end_bottom.x, top_y, end_bottom.z),
		"start_top": Vector3(start_bottom.x, top_y, start_bottom.z),
		"normal": normal.normalized(),
		"role": role,
		"volume": volume,
	})


static func _geometry_from_wall_quads(quads: Array[Dictionary]) -> Dictionary:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var tangents := PackedFloat32Array()
	var indices := PackedInt32Array()
	for quad: Dictionary in quads:
		var base := vertices.size()
		var normal := quad.normal as Vector3
		var tangent := Vector3(normal.z, 0.0, -normal.x).normalized()
		var start_bottom := quad.start_bottom as Vector3
		var end_bottom := quad.end_bottom as Vector3
		var end_top := quad.end_top as Vector3
		var start_top := quad.start_top as Vector3
		var length := Vector2(end_bottom.x - start_bottom.x, end_bottom.z - start_bottom.z).length()
		for vertex: Vector3 in [start_bottom, end_bottom, end_top, start_top]:
			vertices.append(vertex)
			normals.append(normal)
			tangents.append_array(PackedFloat32Array([tangent.x, tangent.y, tangent.z, 1.0]))
		uvs.append_array(PackedVector2Array([Vector2(0.0, start_bottom.y * 0.1), Vector2(length * 0.1, end_bottom.y * 0.1), Vector2(length * 0.1, end_top.y * 0.1), Vector2(0.0, start_top.y * 0.1)]))
		# Start -> end runs along the ring with outward normal (-d.z, d.x), the
		# source receiver's convention, so front faces stay outward.
		indices.append_array(PackedInt32Array([base, base + 2, base + 1, base, base + 3, base + 2]))
	return {"ok": true, "vertices": vertices, "normals": normals, "uvs": uvs, "tangents": tangents, "indices": indices, "quads": quads, "signature": _geometry_signature(vertices, indices, "wall")}


static func _mesh_node(node_name: String, geometry: Dictionary, material: Material, layers: int) -> MeshInstance3D:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = geometry.vertices
	arrays[Mesh.ARRAY_NORMAL] = geometry.normals
	arrays[Mesh.ARRAY_TEX_UV] = geometry.uvs
	arrays[Mesh.ARRAY_TANGENT] = geometry.tangents
	arrays[Mesh.ARRAY_INDEX] = geometry.indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, material)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.layers = layers
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return instance


static func _faces(geometry: Dictionary) -> PackedVector3Array:
	var faces := PackedVector3Array()
	for index_value: int in geometry.indices:
		faces.append(geometry.vertices[index_value])
	return faces


static func _geometry_signature(vertices: PackedVector3Array, indices: PackedInt32Array, role: String) -> String:
	var parts := PackedStringArray([role, TARGET_SOURCE_KEY])
	for vertex: Vector3 in vertices:
		parts.append("%.9f,%.9f,%.9f" % [vertex.x, vertex.y, vertex.z])
	for index: int in indices:
		parts.append(str(index))
	return "|".join(parts).sha256_text()


static func _validate_source_record(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return {"ok": false, "code": "hawkins_massing_target", "message": "Hawkins massing refused a non-target record.", "source_keys": record.get("source_keys", [])}
	var object_key := str(record.object_key)
	var expected_feature := "building_wall" if object_key == TARGET_WALL_KEY else "building_roof"
	var expected_material := expected_feature
	var expected_receiver := "building_wall" if object_key == TARGET_WALL_KEY else "none"
	var expected_vertex_values := 240 if object_key == TARGET_WALL_KEY else 12
	var expected_index_values := 120 if object_key == TARGET_WALL_KEY else 6
	if str(record.get("feature_kind", "")) != expected_feature \
		or str(record.get("material_key", "")) != expected_material \
		or str(record.get("receiver_kind", "")) != expected_receiver \
		or (record.get("vertices", []) as Array).size() != expected_vertex_values \
		or (record.get("indices", []) as Array).size() != expected_index_values:
		return {"ok": false, "code": "hawkins_massing_source", "message": "Hawkins generated receiver contract drifted.", "source_keys": record.source_keys}
	var top_y := -INF
	for offset in range(1, (record.vertices as Array).size(), 3):
		top_y = maxf(top_y, float(record.vertices[offset]))
	if not is_equal_approx(top_y, SOURCE_TOP_Y):
		return {"ok": false, "code": "hawkins_massing_source", "message": "Hawkins source top is no longer the approved reversible 6 m assumption.", "source_keys": record.source_keys}
	if object_key == TARGET_WALL_KEY and (int(record.get("exterior_foundation_segments", -1)) != 20 or int(record.get("shared_wall_segments", -1)) != 0):
		return {"ok": false, "code": "hawkins_massing_source", "message": "Hawkins source foundation segmentation drifted.", "source_keys": record.source_keys}
	return {"ok": true}
