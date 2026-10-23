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
const DECK_Y := 7.774
const TERRACE_Y := 14.774
const LOW_TOP_Y := 18.274
const TALL_TOP_Y := 25.274
const SE_SPLIT_U_M := 33.0
const NNW_SPLIT_U_M := 25.0
const WING_DEPTH_M := {"wsw": 13.0, "se": 13.0, "ene": 16.0, "nnw": 13.0}
const SETBACK_M := 1.6
# The WSW setback starts past the NNW wing (its corner block stays full height).
const WSW_SETBACK_FROM_U_M := 13.0
# Setback stations along each side (u from the side start): WSW from past the
# NNW wing to the S corner, SE from the S corner to the 6-storey block.
const SETBACK_U_RANGES := {"wsw": Vector2(WSW_SETBACK_FROM_U_M, 200.0), "se": Vector2(-200.0, SE_SPLIT_U_M)}
const CANOPY_OVERHANG_M := 1.2
const WEDGE_OVERHANG_M := 2.0
const WEDGE_RUN_M := 8.0
const CANOPY_TOP_Y := 18.30
const CANOPY_THICKNESS_M := 0.25
const ROOF_EDGE_OVERHANG_M := 0.9
# Stoops: [side, u along side, local land y]; land y is sampled terrain from the
# frozen chunk (land_ground w26767313) at each stoop; platform 0.6m above it.
const STOOPS := [
	["wsw", 16.0, 4.60], ["wsw", 28.0, 4.43], ["wsw", 40.0, 4.29], ["wsw", 52.0, 4.30], ["wsw", 64.0, 4.26],
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

	root.add_child(_mesh_node("Mesh", geometry, material, RENDER_BUILDING_WALL if is_wall else RENDER_WORLD_VISIBLE))
	var faces := _faces(geometry)
	var mesh_instances := 1
	if not is_wall:
		# Canopies and the ENE roof edge: pale tops/edges, dark soffits; solid.
		var canopy := canopy_geometry()
		root.add_child(_mesh_node("Canopies", canopy.top, CANOPY_MATERIAL, RENDER_WORLD_VISIBLE))
		root.add_child(_mesh_node("CanopySoffits", canopy.soffit, SOFFIT_MATERIAL, RENDER_WORLD_VISIBLE))
		faces.append_array(_faces(canopy.top))
		faces.append_array(_faces(canopy.soffit))
		# The facade draws the terrace glass rail; it is solid here.
		faces.append_array(_faces(rail_collision()))
		mesh_instances += 2

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
		root.add_child(_mesh_node("Stoops", stoops.solid, STOOP_MATERIAL, RENDER_WORLD_VISIBLE))
		root.add_child(_mesh_node("StoopSteps", stoops.decor, STOOP_MATERIAL, RENDER_WORLD_VISIBLE))
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
	result.append({"poly": _ordered(PackedVector2Array(inner)), "top": DECK_Y, "role": "court"})
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
	return cleaned


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
					var bottom_a := _source_bottom(source_quads, a)
					var bottom_b := _source_bottom(source_quads, b)
					if is_nan(bottom_a) or is_nan(bottom_b):
						return {"ok": false, "code": "hawkins_massing_source", "message": "Hawkins outer wall left the frozen footprint."}
					_append_wall_quad(quads, Vector3(a.x, bottom_a, a.y), Vector3(b.x, bottom_b, b.y), top, normal, "outer", str(piece.role))
				elif neighbour < top - 0.001:
					var role := "setback" if is_equal_approx(neighbour, TERRACE_Y) else ("court" if is_equal_approx(neighbour, DECK_Y) else "step")
					_append_wall_quad(quads, Vector3(a.x, neighbour, a.y), Vector3(b.x, neighbour, b.y), top, normal, role, str(piece.role))
	return _geometry_from_wall_quads(quads)


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
		side_point("se", SE_SPLIT_U_M - 0.05, CANOPY_OVERHANG_M),
		side_point("se", SE_SPLIT_U_M - 0.05, -SETBACK_M),
		inner_corner,
	])
	# The wing canopy is white underneath too (cav-2, cav-3); only the ENE roof
	# edge has a dark soffit (hk07/hk10).
	_append_slab(top, top, _ordered(canopy), CANOPY_TOP_Y - CANOPY_THICKNESS_M, CANOPY_TOP_Y)
	var ene_length: float = side_frame("ene").length
	var edge := PackedVector2Array([
		side_point("ene", 0.0, -0.3), side_point("ene", 0.0, ROOF_EDGE_OVERHANG_M),
		side_point("ene", ene_length, ROOF_EDGE_OVERHANG_M), side_point("ene", ene_length, -0.3),
	])
	_append_slab(top, soffit, _ordered(edge), TALL_TOP_Y - 0.3, TALL_TOP_Y + 0.03)
	return {"top": _flat_geometry(top, "canopy"), "soffit": _flat_geometry(soffit, "soffit")}


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
	for stoop: Array in STOOPS:
		var side := str(stoop[0])
		var u: float = stoop[1]
		var land: float = stoop[2]
		var f := side_frame(side)
		var t := Vector3((f.tangent as Vector2).x, 0.0, (f.tangent as Vector2).y)
		var n := Vector3((f.normal as Vector2).x, 0.0, (f.normal as Vector2).y)
		var base := _at(side_point(side, u, 0.0), 0.0)
		var floor_y := land - 0.15
		var top_y := land + STOOP_RISE_M
		var riser := STOOP_RISE_M / 3.0
		_box(solid, base + n * (STOOP_DEPTH_M * 0.5), t, n, STOOP_WIDTH_M, floor_y, top_y, STOOP_DEPTH_M)
		var planter_depth := STEP_TREAD_M * 3.0 + 0.2
		var planter_width := (STOOP_WIDTH_M - STEP_WIDTH_M) * 0.5 + 0.3
		for s: float in [-1.0, 1.0]:
			var center := base + n * (STOOP_DEPTH_M + planter_depth * 0.5) + t * s * (STEP_WIDTH_M * 0.5 + planter_width * 0.5)
			_box(solid, center, t, n, planter_width, floor_y, land + PLANTER_TOP_ABOVE_LAND_M, planter_depth)
		for step in 2:
			var tread_top := top_y - float(step + 1) * riser
			_box(decor, base + n * (STOOP_DEPTH_M + STEP_TREAD_M * (float(step) + 0.5)), t, n, STEP_WIDTH_M, floor_y, tread_top, STEP_TREAD_M)
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
	return {"solid": _flat_geometry(solid, "stoops"), "decor": _flat_geometry(decor, "stoop_steps"), "support": _flat_geometry(support, "stoop_support")}


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
