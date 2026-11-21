class_name InteriorFarStandIn
extends Node
## A far stand-in for an enterable interior. While the interior's near content is
## released (its near source's is_near() is false), the detailed interior is not drawn
## and a mesh of a few hundred triangles stands in its place, so that from outside,
## through its open door, it still reads as a lit room of the right colours; near
## again, the detailed interior is drawn again. Only what is drawn and what runs
## changes: the interior's collision stays as built, so nothing arriving fast, on foot
## or by car, can find it missing.
##
## This node hangs under the interior's root beside the stand-in mesh (FAR_MESH, made
## by build() with the interior and baked with it) and takes what to do from the
## root's FAR_META meta:
##   near_source     a sibling whose is_near() says whether the near content is up;
##                   this node runs after it each frame (process_priority)
##   near_nodes      siblings (Node3D) drawn only while near
##   near_processes  siblings that run only while near: paused (PROCESS_MODE_DISABLED)
##                   one frame after the far state begins, so that each has run once
##                   since its near content went (the hall's reflections free their
##                   probes then), and given back their mode as soon as near returns
## Whatever the near source says, the interior is near while the camera stands in the
## root's PLAN_META plan or within INSIDE_MARGIN_M of it (InteriorPresence.plan_contains):
## nobody is ever inside it while it is far, however they got there.
## Nothing switches before the game hands over play (main.gd is_play_ready): the
## loading screen sees the interior as built (near), and the shader warm-up compiles
## the hidden stand-in with the rest. force ("near" or "far") holds one state, for
## captures and tests. Leaving the tree, it puts the interior back as built.
##
## build() makes the stand-in from the root's PLAN_META plan (its centre: the polar
## frame) and the FAR_META spec's shapes, every face facing in, toward where it is seen
## from, so a face seen only from inside the interior (where nobody is while it is far)
## is simply left out of the spec:
##   zones   ring sectors about the plan's centre: "radii" (inner, outer), "stations"
##           (the angles of its segments' edges, increasing), "rings" (the floor's
##           radial edges; default the radii), "floor_y" (a height, or the heights at
##           the inner and the outer radius: a ramp), "ceiling_y" (or none), and walls
##           by their band heights: "outer" (at the outer radius, facing the centre),
##           "start" and "end" (at the first and the last station, facing into the
##           sector). "opening" (first angle, last angle, top) leaves a gap in the outer
##           wall from its foot up to top; "outer_reach" (in front, behind: m) is how
##           far off the outer wall a detailed face still colours it (default
##           SAMPLE_REACH_M both ways): deep bays behind a wall's line, say.
##   quads   faces given whole: {"corners": four points, "normal"}, such as a door's
##           reveal.
##   kept    detailed surfaces kept in their own material: each piece of one inside a
##           zone becomes a quad over its extent (angles, heights) facing the way it
##           faces, on the outer wall's line (KEPT_LIFT_M off it) if it stands at or
##           behind it: a glowing panel should still glow.
##   materials  detailed surfaces whose own material a face takes where that surface
##           covers most of the face (its colour then the surface's vertex colours);
##           "uv_frames" gives such a surface's polar UV frame ({"theta", "radius"}: u
##           along the angles, v out along the radius), so its textures carry on.
##   matte   {"roughness", "specular"} of the stand-in's own material, for every other
##           face: vertex colour as albedo (sRGB) and nothing else, as an interior's
##           plain surfaces are drawn, so the same shader draws it.
## Each face's colour comes from the detailed triangles over it (close to its plane,
## in its bounds and heights, facing its way; for a ring sector's outer wall, anywhere
## between the reaches in front of it and behind it; a triangle over a given quad
## colours the quad), by area, in linear light: their material's colour times its
## albedo texture's mean times their vertex colours. A floor or a
## ceiling blends its faces' colours at their shared corners; a wall keeps each face
## flat, so bays read as bays.

const FAR_META := "interior_far"
const FAR_MESH := "FarStandIn"
## How closely a detailed face's normal and a stand-in face's must agree to colour it.
const FACING := 0.6
## How far (m) off a face's plane or past its edges a detailed face may lie and still
## colour it.
const SAMPLE_REACH_M := 0.6
## How far (m) a kept piece stands off the wall it is put on, toward the viewer.
const KEPT_LIFT_M := 0.03
## A texture's mean is read from its first mip level no longer than this (pixels).
const MEAN_MIP_PX := 16
## How far (m) outside the interior's plan the camera still keeps it near.
const INSIDE_MARGIN_M := 1.0
## A zone face's kinds, as numbers in its lookup key.
const KINDS: Array[String] = ["floor", "ceiling", "outer", "start", "end"]

## "near" or "far" holds that state; "" follows the near source.
@export var force := ""

## How many times it has switched between near and far.
var switches := 0
var _source: Node
var _plan: Dictionary
var _near_nodes: Array[Node3D] = []
var _processes: Array[Node] = []
var _mesh: Node3D
## Each near_processes node's process_mode from before the far state paused it.
var _modes := {}
var _far := false
var _pause_due := false
var _ready_spec := false


func _ready() -> void:
	var root := get_parent()
	var spec: Variant = root.get_meta(FAR_META, null) if root != null else null
	var plan: Variant = root.get_meta(InteriorPresence.PLAN_META, null) if root != null else null
	var problem := spec_problem(spec)
	if problem == "":
		problem = InteriorPresence.plan_problem(plan)
	if problem == "":
		_plan = plan
		_source = root.get_node_or_null(NodePath(str(spec.near_source)))
		_mesh = root.get_node_or_null(FAR_MESH) as Node3D
		if _source == null or not _source.has_method("is_near") or _mesh == null:
			problem = "no near source %s with is_near(), or no %s mesh" % [spec.near_source, FAR_MESH]
	if problem != "":
		push_error("InteriorFarStandIn under %s: %s; the interior stays as built." % [root.name if root != null else "nothing", problem])
		set_process(false)
		return
	for name: Variant in spec.near_nodes:
		var node := root.get_node_or_null(NodePath(str(name))) as Node3D
		if node != null:
			_near_nodes.append(node)
	for name: Variant in spec.get("near_processes", []):
		var node := root.get_node_or_null(NodePath(str(name)))
		if node != null:
			_processes.append(node)
	# After the near source each frame, so a change of its state shows in the same frame.
	process_priority = _source.process_priority + 1
	_ready_spec = true


## Why a stand-in spec cannot be used, or "" if it can.
static func spec_problem(spec: Variant) -> String:
	if not spec is Dictionary:
		return "no %s meta on the interior's root" % FAR_META
	if not spec.get("near_source") is String or not spec.get("near_nodes") is Array:
		return "a stand-in spec needs near_source (a name) and near_nodes (a list)"
	if (spec.get("zones", []) as Array).is_empty() and (spec.get("quads", []) as Array).is_empty():
		return "a stand-in spec needs zones or quads to stand in"
	return ""


func _process(_delta: float) -> void:
	if not _ready_spec or (force == "" and not play_started(get_tree())):
		return
	var near := force == "near"
	if force == "":
		var camera := get_viewport().get_camera_3d()
		near = not is_instance_valid(_source) or bool(_source.call("is_near")) or (camera != null and InteriorPresence.plan_contains(_plan, camera.global_position, -INSIDE_MARGIN_M))
	if near == _far:
		_set_far(not near)
	elif _pause_due:
		_pause_due = false
		for node in _processes:
			if is_instance_valid(node) and not _modes.has(node):
				_modes[node] = node.process_mode
				node.process_mode = Node.PROCESS_MODE_DISABLED


## Whether the far state is shown now.
func is_far() -> bool:
	return _far


## Whether the near nodes' processing is paused now (a frame into the far state).
func is_paused() -> bool:
	return not _modes.is_empty()


func _exit_tree() -> void:
	if _far:
		_set_far(false)


func _set_far(far: bool) -> void:
	_far = far
	switches += 1
	for node in _near_nodes:
		if is_instance_valid(node):
			node.visible = not far
	if is_instance_valid(_mesh):
		_mesh.visible = far
	_pause_due = far
	if not far:
		for node: Node in _modes:
			if is_instance_valid(node):
				node.process_mode = _modes[node]
		_modes.clear()


## Whether the game has handed over play (main.gd is_play_ready).
static func play_started(tree: SceneTree) -> bool:
	var main := tree.root.get_node_or_null("Main")
	return main != null and main.has_method("is_play_ready") and bool(main.call("is_play_ready"))


## The stand-in mesh for an interior's root, from its PLAN_META plan and FAR_META spec,
## coloured from the detailed surfaces (each {"name", "arrays", "material"}: arrays in
## the root's frame, as the interior builds them), drawn on layers, hidden until the
## far state shows it. Null, said as an error, if the metas will not do.
static func build(root: Node, surfaces: Array, layers: int) -> MeshInstance3D:
	var plan: Variant = root.get_meta(InteriorPresence.PLAN_META, null)
	var spec: Variant = root.get_meta(FAR_META, null)
	var problem := InteriorPresence.plan_problem(plan)
	if problem == "":
		problem = spec_problem(spec)
	if problem != "":
		push_error("InteriorFarStandIn.build: %s" % problem)
		return null
	var centre: Vector2 = plan.centre
	var zones: Array = []
	var faces: Array[Dictionary] = []
	for zone: Dictionary in spec.get("zones", []):
		zones.append(_zone_frame(zone))
		for face in zone_faces(centre, zone):
			face["zone"] = zones.size() - 1
			faces.append(face)
	for quad: Dictionary in spec.get("quads", []):
		faces.append(_face(quad.corners as Array, quad.normal as Vector3, {"kind": "quad"}))
	var kept: Array = spec.get("kept", [])
	var by_name := {}
	for surface: Dictionary in surfaces:
		by_name[str(surface.name)] = surface
	_sample(faces, zones, surfaces, kept, centre)
	var groups := {}
	_colour(faces, spec.get("materials", []) as Array, by_name, material(spec.get("matte", {}) as Dictionary), groups)
	for name: Variant in kept:
		if by_name.has(str(name)):
			_add_kept(groups, by_name[str(name)], zones, centre)
	var frames: Dictionary = spec.get("uv_frames", {})
	var mesh := ArrayMesh.new()
	for key: String in groups:
		var group := groups[key] as Dictionary
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _arrays(group, centre, frames.get(key)))
		mesh.surface_set_name(mesh.get_surface_count() - 1, key)
		mesh.surface_set_material(mesh.get_surface_count() - 1, group.material)
	if mesh.get_surface_count() == 0:
		push_error("InteriorFarStandIn.build: the spec makes no face")
		return null
	var instance := MeshInstance3D.new()
	instance.name = FAR_MESH
	instance.mesh = mesh
	instance.layers = layers
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.visible = false
	return instance


## The stand-in's own material: vertex colour as albedo (sRGB) and nothing else, as an
## interior's plain surfaces are drawn, so the same shader draws it.
static func material(matte: Dictionary) -> StandardMaterial3D:
	var made := StandardMaterial3D.new()
	made.resource_name = "InteriorFarStandIn"
	made.vertex_color_use_as_albedo = true
	made.vertex_color_is_srgb = true
	made.roughness = float(matte.get("roughness", 0.9))
	made.metallic_specular = float(matte.get("specular", 0.15))
	return made


## A zone's faces (see the class notes), each with its place in the zone ("kind",
## "segment", "band" or "ring"); colours unset.
static func zone_faces(centre: Vector2, zone: Dictionary) -> Array[Dictionary]:
	var frame := _zone_frame(zone)
	var radii: Vector2 = frame.radii
	var stations: PackedFloat64Array = frame.stations
	var rings: PackedFloat64Array = frame.rings
	var faces: Array[Dictionary] = []
	for segment in stations.size() - 1:
		var a0 := stations[segment]
		var a1 := stations[segment + 1]
		for ring in rings.size() - 1:
			var r0 := rings[ring]
			var r1 := rings[ring + 1]
			faces.append(_face([_point(centre, r0, a0, _floor_at(frame, r0)), _point(centre, r1, a0, _floor_at(frame, r1)), _point(centre, r1, a1, _floor_at(frame, r1)), _point(centre, r0, a1, _floor_at(frame, r0))], Vector3.UP, {"kind": "floor", "segment": segment, "band": ring}))
		if frame.has("ceiling_y"):
			var top := float(frame.ceiling_y)
			faces.append(_face([_point(centre, radii.x, a0, top), _point(centre, radii.y, a0, top), _point(centre, radii.y, a1, top), _point(centre, radii.x, a1, top)], Vector3.DOWN, {"kind": "ceiling", "segment": segment, "band": 0}))
	var outer: PackedFloat64Array = frame.outer
	var outer_stations: PackedFloat64Array = frame.outer_stations
	for segment in outer_stations.size() - 1:
		var a0 := outer_stations[segment]
		var a1 := outer_stations[segment + 1]
		for band in outer.size() - 1:
			if _in_opening(frame, (a0 + a1) * 0.5, (outer[band] + outer[band + 1]) * 0.5):
				continue
			faces.append(_face([_point(centre, radii.y, a0, outer[band]), _point(centre, radii.y, a1, outer[band]), _point(centre, radii.y, a1, outer[band + 1]), _point(centre, radii.y, a0, outer[band + 1])], -_radial((a0 + a1) * 0.5), {"kind": "outer", "segment": segment, "band": band}))
	for end: String in ["start", "end"]:
		var bands: PackedFloat64Array = frame[end]
		var at := stations[0] if end == "start" else stations[stations.size() - 1]
		var into := _tangent(at) * (1.0 if end == "start" else -1.0)
		for band in bands.size() - 1:
			faces.append(_face([_point(centre, radii.x, at, bands[band]), _point(centre, radii.y, at, bands[band]), _point(centre, radii.y, at, bands[band + 1]), _point(centre, radii.x, at, bands[band + 1])], into, {"kind": end, "segment": 0, "band": band}))
	return faces


## A zone's numbers in one place, with its outer wall's stations (the zone's and its
## opening's edges) and heights (its bands' and the opening's top).
static func _zone_frame(zone: Dictionary) -> Dictionary:
	var radii: Vector2 = zone.radii
	var stations := PackedFloat64Array(zone.stations as Array)
	var floor_value: Variant = zone.get("floor_y", 0.0)
	var floor_y: Vector2 = floor_value if floor_value is Vector2 else Vector2(float(floor_value), float(floor_value))
	var frame := {
		"radii": radii,
		"stations": stations,
		"rings": PackedFloat64Array(zone.get("rings", [radii.x, radii.y]) as Array),
		"floor_y": floor_y,
		"start": PackedFloat64Array(zone.get("start", []) as Array),
		"end": PackedFloat64Array(zone.get("end", []) as Array),
		"outer_reach": zone.get("outer_reach", Vector2(SAMPLE_REACH_M, SAMPLE_REACH_M)),
	}
	if zone.get("ceiling_y") != null:
		frame["ceiling_y"] = float(zone.ceiling_y)
	var outer_stations := stations.duplicate()
	var outer := PackedFloat64Array(zone.get("outer", []) as Array)
	if zone.get("opening") is Vector3:
		var opening: Vector3 = zone.opening
		frame["opening"] = opening
		for edge: float in [opening.x, opening.y]:
			if edge > stations[0] and edge < stations[stations.size() - 1] and not outer_stations.has(edge):
				outer_stations.append(edge)
		if outer.size() > 1 and opening.z > outer[0] and opening.z < outer[outer.size() - 1] and not outer.has(opening.z):
			outer.append(opening.z)
	outer_stations.sort()
	outer.sort()
	frame["outer_stations"] = outer_stations
	frame["outer"] = outer
	return frame


static func _in_opening(frame: Dictionary, angle: float, y: float) -> bool:
	if not frame.has("opening"):
		return false
	var opening: Vector3 = frame.opening
	return angle > opening.x and angle < opening.y and y < opening.z


static func _floor_at(frame: Dictionary, r: float) -> float:
	var radii: Vector2 = frame.radii
	var floor_y: Vector2 = frame.floor_y
	return lerpf(floor_y.x, floor_y.y, clampf((r - radii.x) / maxf(radii.y - radii.x, 0.001), 0.0, 1.0))


## Adds each detailed triangle's area and colours to the face it colours (see the class
## notes): per face, per detailed surface, [area, linear albedo times area, linear
## vertex colour times area].
static func _sample(faces: Array[Dictionary], zones: Array, surfaces: Array, kept: Array, centre: Vector2) -> void:
	var lookup := {}
	var quads: Array[int] = []
	var quad_box := AABB()
	for index in faces.size():
		var face := faces[index]
		if face.kind != "quad":
			lookup[_key(int(face.zone), KINDS.find(face.kind), int(face.segment), int(face.band))] = index
			continue
		for corner: Vector3 in face.corners:
			quad_box = quad_box.expand(corner) if not quads.is_empty() or corner != face.corners[0] else AABB(corner, Vector3.ZERO)
		quads.append(index)
	quad_box = quad_box.grow(SAMPLE_REACH_M)
	for surface: Dictionary in surfaces:
		if kept.has(surface.name):
			continue
		var arrays: Array = surface.arrays
		var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var tints: Variant = arrays[Mesh.ARRAY_COLOR]
		var indices: Variant = arrays[Mesh.ARRAY_INDEX]
		var indexed: bool = indices is PackedInt32Array and (indices as PackedInt32Array).size() > 0
		var count: int = (indices as PackedInt32Array).size() if indexed else points.size()
		var has_tints: bool = tints is PackedColorArray and (tints as PackedColorArray).size() == points.size()
		var has_normals := normals.size() == points.size()
		var albedo := _albedo(surface.material as Material)
		for t in range(0, count - 2, 3):
			var i0: int = indices[t] if indexed else t
			var i1: int = indices[t + 1] if indexed else t + 1
			var i2: int = indices[t + 2] if indexed else t + 2
			var p0 := points[i0]
			var p1 := points[i1]
			var p2 := points[i2]
			var cross := (p1 - p0).cross(p2 - p0)
			var area := cross.length() * 0.5
			if area <= 0.000001:
				continue
			# Godot draws a triangle's front where its corners run clockwise.
			var normal := (normals[i0] + normals[i1] + normals[i2]).normalized() if has_normals else -cross.normalized()
			var centroid := (p0 + p1 + p2) / 3.0
			# A given quad first: the zones' wider reach would take what lies on it.
			var target := -1
			if quad_box.has_point(centroid):
				for index in quads:
					if _over(faces[index], centroid, normal):
						target = index
						break
			if target < 0:
				target = _zone_face(lookup, zones, centroid, normal, centre)
			if target < 0:
				continue
			var tint := Vector3.ONE
			if has_tints:
				tint = (_linear(tints[i0]) + _linear(tints[i1]) + _linear(tints[i2])) / 3.0
			var sums := faces[target].sums as Dictionary
			if not sums.has(surface.name):
				sums[surface.name] = [0.0, Vector3.ZERO, Vector3.ZERO]
			var entry: Array = sums[surface.name]
			entry[0] += area
			entry[1] += albedo * tint * area
			entry[2] += tint * area


static func _key(zone: int, kind: int, segment: int, band: int) -> int:
	return ((zone * 8 + kind) * 4096 + segment) * 4096 + band


## The zone face a detailed triangle colours (its centroid, its normal), or -1.
static func _zone_face(lookup: Dictionary, zones: Array, at: Vector3, normal: Vector3, centre: Vector2) -> int:
	var offset := Vector2(at.x - centre.x, at.z - centre.y)
	var r := offset.length()
	var angle := atan2(offset.y, offset.x)
	for z in zones.size():
		var frame: Dictionary = zones[z]
		var stations: PackedFloat64Array = frame.stations
		var a := stations[0] + wrapf(angle - stations[0], -PI, PI)
		var radii: Vector2 = frame.radii
		var reach: Vector2 = frame.outer_reach
		var rings: PackedFloat64Array = frame.rings
		# Past the sector's ends only for its end walls, which stand on them.
		var slack := SAMPLE_REACH_M / maxf(r, 1.0)
		if a < stations[0] - slack or a > stations[stations.size() - 1] + slack or r < minf(radii.x, rings[0]) - SAMPLE_REACH_M or r > radii.y + reach.y:
			continue
		var within := a >= stations[0] and a <= stations[stations.size() - 1]
		var floor_y := _floor_at(frame, r)
		if normal.y > FACING:
			if within and absf(at.y - floor_y) < SAMPLE_REACH_M * 0.5 and r >= rings[0] - SAMPLE_REACH_M * 0.5 and r <= rings[rings.size() - 1] + SAMPLE_REACH_M * 0.5:
				return lookup.get(_key(z, 0, _step(stations, a), _step(rings, r)), -1)
			continue
		if normal.y < -FACING:
			if within and frame.has("ceiling_y") and at.y > (floor_y + float(frame.ceiling_y)) * 0.5 and at.y < float(frame.ceiling_y) + SAMPLE_REACH_M:
				return lookup.get(_key(z, 1, _step(stations, a), 0), -1)
			continue
		if normal.dot(-_radial(a)) > FACING:
			if within and r >= radii.y - reach.x and _in_bands(frame.outer, at.y) and not _in_opening(frame, a, at.y):
				return lookup.get(_key(z, 2, _step(frame.outer_stations, a), _step(frame.outer, at.y)), -1)
			continue
		var along := normal.dot(_tangent(a))
		var start_m := (a - stations[0]) * r
		var end_m := (stations[stations.size() - 1] - a) * r
		if along > FACING and start_m > -SAMPLE_REACH_M * 0.5 and start_m < SAMPLE_REACH_M and _in_bands(frame.start, at.y):
			return lookup.get(_key(z, 3, 0, _step(frame.start, at.y)), -1)
		if along < -FACING and end_m > -SAMPLE_REACH_M * 0.5 and end_m < SAMPLE_REACH_M and _in_bands(frame.end, at.y):
			return lookup.get(_key(z, 4, 0, _step(frame.end, at.y)), -1)
	return -1


## Whether a height lies within a wall's bands (or just past their ends).
static func _in_bands(bands: PackedFloat64Array, y: float) -> bool:
	return bands.size() > 1 and y > bands[0] - SAMPLE_REACH_M * 0.5 and y < bands[bands.size() - 1] + SAMPLE_REACH_M * 0.5


## The index of the step of a sorted list of edges a value falls in, clamped to the
## first and the last step.
static func _step(edges: PackedFloat64Array, value: float) -> int:
	return clampi(edges.bsearch(value) - 1, 0, maxi(edges.size() - 2, 0))


## Whether a detailed triangle (its centroid, its normal) colours a quad face: facing
## the same way, close to the face's plane, and over the face or just past its edges.
static func _over(face: Dictionary, centroid: Vector3, normal: Vector3) -> bool:
	var face_normal: Vector3 = face.normal
	if normal.dot(face_normal) < FACING:
		return false
	var corners: Array = face.corners
	if absf((centroid - (corners[0] as Vector3)).dot(face_normal)) > SAMPLE_REACH_M * 0.5:
		return false
	var middle := ((corners[0] as Vector3) + (corners[1] as Vector3) + (corners[2] as Vector3) + (corners[3] as Vector3)) * 0.25
	for index in 4:
		var a: Vector3 = corners[index]
		var edge := ((corners[(index + 1) % 4] as Vector3) - a).normalized()
		var inward := (middle - a) - edge * (middle - a).dot(edge)
		if (centroid - a).dot(inward.normalized()) < -SAMPLE_REACH_M * 0.2:
			return false
	return true


## Picks each face's material and colour (see the class notes) and files the faces
## into groups by material: "matte" (the stand-in's own) or a detailed surface's name.
static func _colour(faces: Array[Dictionary], materials: Array, by_name: Dictionary, matte: Material, groups: Dictionary) -> void:
	var whole_area := 0.0
	var whole := Vector3.ZERO
	for face in faces:
		var area := 0.0
		var albedo := Vector3.ZERO
		var best := ""
		var best_area := 0.0
		for name: String in face.sums:
			var entry: Array = face.sums[name]
			area += float(entry[0])
			albedo += entry[1]
			if float(entry[0]) > best_area:
				best_area = float(entry[0])
				best = name
		face["area"] = area
		if area <= 0.0:
			continue
		whole_area += area
		whole += albedo
		if materials.has(best) and by_name.has(best):
			var entry: Array = face.sums[best]
			face["group"] = best
			face["colour"] = entry[2] / float(entry[0])
		else:
			face["group"] = "matte"
			face["colour"] = albedo / area
	# A face nothing coloured takes its zone's mean for its kind, or the whole mean.
	var kinds := {}
	for face in faces:
		if float(face.area) > 0.0 and face.group == "matte":
			var key := "%s|%s" % [face.get("zone", -1), face.kind]
			if not kinds.has(key):
				kinds[key] = [0.0, Vector3.ZERO]
			kinds[key][0] += float(face.area)
			kinds[key][1] += (face.colour as Vector3) * float(face.area)
	for face in faces:
		if float(face.area) <= 0.0:
			var key := "%s|%s" % [face.get("zone", -1), face.kind]
			face["group"] = "matte"
			face["colour"] = kinds[key][1] / float(kinds[key][0]) if kinds.has(key) else (whole / whole_area if whole_area > 0.0 else Vector3(0.5, 0.5, 0.5))
	# Floors and ceilings: each corner the mean of the faces of the same material round it.
	var grid := {}
	for index in faces.size():
		var face := faces[index]
		if face.kind == "floor" or face.kind == "ceiling":
			grid[_key(int(face.zone), KINDS.find(face.kind), int(face.segment), int(face.band))] = index
	for face in faces:
		var colours: Array[Vector3] = []
		if face.kind == "floor" or face.kind == "ceiling":
			# Corners in order: (segment, band), (segment, band + 1), (segment + 1, band + 1), (segment + 1, band).
			for corner: Vector2i in [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0)]:
				var sum := Vector3.ZERO
				var weight := 0.0
				for ds: int in [-1, 0]:
					for db: int in [-1, 0]:
						var key := _key(int(face.zone), KINDS.find(face.kind), int(face.segment) + corner.x + ds, int(face.band) + corner.y + db)
						if grid.has(key) and faces[grid[key]].group == face.group:
							sum += faces[grid[key]].colour
							weight += 1.0
				colours.append(sum / weight if weight > 0.0 else face.colour as Vector3)
		else:
			colours = [face.colour, face.colour, face.colour, face.colour]
		face["colours"] = colours
		var group_key: String = face.group
		if not groups.has(group_key):
			groups[group_key] = {"material": matte if group_key == "matte" else by_name[group_key].material, "faces": [], "tinted": true}
		(groups[group_key].faces as Array).append(face)


## Adds the pieces of a kept detailed surface (see the class notes) to its own group.
static func _add_kept(groups: Dictionary, surface: Dictionary, zones: Array, centre: Vector2) -> void:
	var arrays: Array = surface.arrays
	var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var tints: Variant = arrays[Mesh.ARRAY_COLOR]
	var tinted: bool = tints is PackedColorArray and (tints as PackedColorArray).size() == points.size()
	var indices := PackedInt32Array()
	if arrays[Mesh.ARRAY_INDEX] is PackedInt32Array and (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size() > 0:
		indices = arrays[Mesh.ARRAY_INDEX]
	else:
		for index in points.size():
			indices.append(index)
	for piece: Array in _pieces(points, indices):
		var middle := Vector3.ZERO
		for index: int in piece:
			middle += points[index]
		middle /= float(piece.size())
		var offset := Vector2(middle.x - centre.x, middle.z - centre.y)
		var frame := {}
		for candidate: Dictionary in zones:
			var stations: PackedFloat64Array = candidate.stations
			var a := stations[0] + wrapf(atan2(offset.y, offset.x) - stations[0], -PI, PI)
			var radii: Vector2 = candidate.radii
			if a >= stations[0] and a <= stations[stations.size() - 1] and offset.length() >= radii.x and offset.length() <= radii.y + (candidate.outer_reach as Vector2).y and middle.y >= (candidate.floor_y as Vector2).x - SAMPLE_REACH_M and middle.y <= float(candidate.get("ceiling_y", INF)):
				frame = candidate
				break
		if frame.is_empty():
			continue
		var stations: PackedFloat64Array = frame.stations
		var a0 := INF
		var a1 := -INF
		var low := INF
		var high := -INF
		var r_sum := 0.0
		var normal := Vector3.ZERO
		var tint := Vector3.ZERO
		for index: int in piece:
			var at := Vector2(points[index].x - centre.x, points[index].z - centre.y)
			var a := stations[0] + wrapf(atan2(at.y, at.x) - stations[0], -PI, PI)
			a0 = minf(a0, a)
			a1 = maxf(a1, a)
			low = minf(low, points[index].y)
			high = maxf(high, points[index].y)
			r_sum += at.length()
			if normals.size() == points.size():
				normal += normals[index]
			tint += _linear(tints[index]) if tinted else Vector3.ONE
		var r := r_sum / float(piece.size())
		var radial := _radial((a0 + a1) * 0.5)
		var facing := normal.dot(radial) / float(piece.size())
		if absf(facing) < FACING or a1 <= a0 or high <= low:
			continue
		var outer_r := (frame.radii as Vector2).y
		var on_wall := facing < 0.0 and r >= outer_r - (frame.outer_reach as Vector2).x
		# On the wall: edges at its stations between the piece's ends, so it follows the chords.
		var edges := PackedFloat64Array([a0, a1])
		if on_wall:
			for station: float in frame.outer_stations:
				if station > a0 and station < a1:
					edges.append(station)
		edges.sort()
		var colour := tint / float(piece.size())
		var group_key := str(surface.name)
		if not groups.has(group_key):
			groups[group_key] = {"material": surface.material, "faces": [], "tinted": tinted}
		for step in edges.size() - 1:
			var corners: Array = []
			for corner: Vector2 in [Vector2(edges[step], low), Vector2(edges[step + 1], low), Vector2(edges[step + 1], high), Vector2(edges[step], high)]:
				if on_wall:
					corners.append(_on_chord(centre, frame.outer_stations, outer_r, corner.x, corner.y) - _radial(corner.x) * KEPT_LIFT_M)
				else:
					corners.append(_point(centre, r, corner.x, corner.y))
			var face := _face(corners, radial * signf(facing), {"kind": "kept"})
			face["colours"] = [colour, colour, colour, colour]
			(groups[group_key].faces as Array).append(face)


## A surface's vertices in connected pieces (triangles sharing a corner, to the
## millimetre): each piece a list of vertex indices.
static func _pieces(points: PackedVector3Array, indices: PackedInt32Array) -> Array:
	var parent := {}
	var keys := PackedStringArray()
	keys.resize(points.size())
	for index in points.size():
		var p := points[index]
		keys[index] = "%d,%d,%d" % [roundi(p.x * 1000.0), roundi(p.y * 1000.0), roundi(p.z * 1000.0)]
		parent[keys[index]] = keys[index]
	for t in range(0, indices.size() - 2, 3):
		var a := _root(parent, keys[indices[t]])
		for j: int in [1, 2]:
			var b := _root(parent, keys[indices[t + j]])
			if a != b:
				parent[b] = a
	var pieces := {}
	for index in points.size():
		var root := _root(parent, keys[index])
		if not pieces.has(root):
			pieces[root] = []
		(pieces[root] as Array).append(index)
	return pieces.values()


static func _root(parent: Dictionary, key: String) -> String:
	while parent[key] != key:
		parent[key] = parent[parent[key]]
		key = parent[key]
	return key


## A group's mesh arrays: each face two triangles, wound so they face the face's way.
static func _arrays(group: Dictionary, centre: Vector2, uv_frame: Variant) -> Array:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var colours := PackedColorArray()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for face: Dictionary in group.faces:
		var corners: Array = face.corners
		var face_colours: Array = face.colours
		var order: Array[int] = [0, 1, 2, 3]
		# Godot draws a triangle's front where its corners run clockwise.
		if ((corners[1] as Vector3) - (corners[0] as Vector3)).cross((corners[2] as Vector3) - (corners[0] as Vector3)).dot(face.normal) > 0.0:
			order = [0, 3, 2, 1]
		var first := vertices.size()
		for index in order:
			var corner: Vector3 = corners[index]
			vertices.append(corner)
			normals.append(_corner_normal(face, corner, centre))
			colours.append(_srgb(face_colours[index]))
			uvs.append(_frame_uv(uv_frame, centre, corner))
		indices.append_array([first, first + 1, first + 2, first, first + 2, first + 3])
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	if group.tinted:
		arrays[Mesh.ARRAY_COLOR] = colours
	arrays[Mesh.ARRAY_INDEX] = indices
	return arrays


## A corner's shading normal: on a curved wall the radial at the corner's own angle,
## so the wall shades smoothly round its chords; else the face's.
static func _corner_normal(face: Dictionary, corner: Vector3, centre: Vector2) -> Vector3:
	var normal: Vector3 = face.normal
	if face.kind == "outer" or face.kind == "kept":
		var radial := Vector3(corner.x - centre.x, 0.0, corner.z - centre.y).normalized()
		return radial * signf(normal.dot(radial))
	return normal


static func _frame_uv(uv_frame: Variant, centre: Vector2, corner: Vector3) -> Vector2:
	if not uv_frame is Dictionary:
		return Vector2.ZERO
	var theta: Vector2 = uv_frame.theta
	var radius: Vector2 = uv_frame.radius
	var offset := Vector2(corner.x - centre.x, corner.z - centre.y)
	return Vector2(wrapf(atan2(offset.y, offset.x) - theta.x, -PI, PI) / (theta.y - theta.x), (offset.length() - radius.x) / (radius.y - radius.x))


## A material's albedo in linear light: its colour, times its albedo texture's mean when
## it has one (and its detail texture's, multiplied in). White for none.
static func _albedo(surface_material: Material) -> Vector3:
	var base := surface_material as BaseMaterial3D
	if base == null:
		return Vector3.ONE
	var albedo := _linear(base.albedo_color)
	var textures: Array[Texture2D] = [base.albedo_texture]
	if base.detail_enabled:
		textures.append(base.detail_albedo)
	for texture in textures:
		if texture != null:
			albedo *= _texture_mean(texture)
	return albedo


## A texture's mean colour (linear), from its first mip level no longer than MEAN_MIP_PX.
static func _texture_mean(texture: Texture2D) -> Vector3:
	var image := texture.get_image()
	if image == null or image.is_empty():
		return Vector3.ONE
	var size := Vector2i(image.get_width(), image.get_height())
	if image.has_mipmaps():
		var level := 0
		while level < image.get_mipmap_count() and maxi(size.x, size.y) > MEAN_MIP_PX:
			level += 1
			size = Vector2i(maxi(1, size.x >> 1), maxi(1, size.y >> 1))
		var data := image.get_data()
		var to := image.get_mipmap_offset(level + 1) if level < image.get_mipmap_count() else data.size()
		image = Image.create_from_data(size.x, size.y, false, image.get_format(), data.slice(image.get_mipmap_offset(level), to))
	else:
		image = image.duplicate()
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	var sum := Vector3.ZERO
	for y in image.get_height():
		for x in image.get_width():
			sum += _linear(image.get_pixel(x, y))
	return sum / float(image.get_width() * image.get_height())


static func _face(corners: Array, normal: Vector3, place: Dictionary) -> Dictionary:
	var face := {"corners": corners, "normal": normal, "sums": {}, "area": 0.0}
	face.merge(place)
	return face


static func _point(centre: Vector2, r: float, angle: float, y: float) -> Vector3:
	return Vector3(centre.x + r * cos(angle), y, centre.y + r * sin(angle))


## The point at an angle on the chords between a wall's stations at radius r, at height y.
static func _on_chord(centre: Vector2, stations: PackedFloat64Array, r: float, angle: float, y: float) -> Vector3:
	var segment := _step(stations, angle)
	var a0 := stations[segment]
	var a1 := stations[segment + 1]
	return _point(centre, r * cos((a1 - a0) * 0.5) / cos(angle - (a0 + a1) * 0.5), angle, y)


static func _radial(angle: float) -> Vector3:
	return Vector3(cos(angle), 0.0, sin(angle))


static func _tangent(angle: float) -> Vector3:
	return Vector3(-sin(angle), 0.0, cos(angle))


static func _linear(colour: Color) -> Vector3:
	var linear := colour.srgb_to_linear()
	return Vector3(linear.r, linear.g, linear.b)


static func _srgb(linear: Vector3) -> Color:
	return Color(clampf(linear.x, 0.0, 1.0), clampf(linear.y, 0.0, 1.0), clampf(linear.z, 0.0, 1.0)).linear_to_srgb()
