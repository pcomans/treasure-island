extends SceneTree
## The housing family's opt-in unit details (game/scripts/world/facades/housing_unit_detail.gd),
## headless, on 1232 Northpoint's real wall record and config, and on the same config with
## every detail key taken out:
##   - without the keys the build has no visual-only or "solid" part and the siding keeps
##     its shader's default; with them the build is valid;
##   - blinds and the utilities' drawn parts are visual only: a second build of the same
##     config, its visual-only parts taken out, collides exactly alike; every blind lies
##     inside a front window, behind its wall plane;
##   - each utility has a box collider holding its drawn parts, outside the building and
##     off every front door's landing;
##   - the downspouts and roof vents collide as drawn; every vent stands inside the footprint;
##   - the siding takes siding_course_shadow;
##   - a gable run under gable_rakes carries no eave trim (the config without them draws one
##     there); story_band height 0 draws no board along the front; the frontage setback's
##     soffit takes its soffit_rgb;
##   - an end annex stands outside the frozen footprint only with its recorded exception,
##     and collides as drawn: chest-height probes into its three open faces and one down
##     through its roof meet its contact faces, which the config without it lacks.

const FAMILY := preload("res://game/scripts/world/facades/housing_site_family.gd")
const ATTACH := preload("res://game/scripts/world/facades/housing_family_live_attachment.gd")
const SIDING := preload("res://game/resources/housing_family/siding.gdshader")
const SOURCE := "w96215673"
const CONFIG := "res://game/resources/housing_family/w96215673.json"
const CHUNK := "res://generated/world/chunks/x_-2__z_-3.json"
const DETAIL_KEYS := ["window_blinds", "utility_kit", "roof_vents", "siding_course_shadow", "gable_rakes", "end_annexes"]

var failures: Array[String] = []


func _initialize() -> void:
	var chunk: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CHUNK))
	var wall: Dictionary = {}
	var roof: Dictionary = {}
	for record: Dictionary in chunk.records:
		if str(record.object_key) == "building:%s:wall" % SOURCE:
			wall = record
		elif str(record.object_key) == "building:%s:roof" % SOURCE:
			roof = record
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CONFIG))
	for key: String in DETAIL_KEYS:
		check(cfg.has(key), "1232's config carries %s (the pilot's options)" % key)
	var plain_cfg: Dictionary = cfg.duplicate(true)
	for key: String in DETAIL_KEYS:
		plain_cfg.erase(key)
	for frame: Dictionary in plain_cfg.target.frames:
		for entry: Dictionary in frame.get("entries", []):
			entry.erase("utilities")
		for pipe: Dictionary in frame.get("pipes", []):
			pipe.erase("style")
	var plain := FAMILY.build(wall, roof, plain_cfg)
	var model := FAMILY.build(wall, roof, cfg)
	_check_floor_line_and_gables(plain, model, cfg, wall)
	_check_plain(plain)
	_check_details(model, FAMILY.build(wall, roof, cfg), cfg, wall)
	if failures.is_empty():
		print("PASS: housing unit details: absent keys add no part and leave the siding's default; blinds and utility shells are visual only and every blind sits behind the glass of a front window; each utility's box collider holds it, outside the building and off every front door's landing; downspouts collide as drawn, vents stand inside the footprint and rakes over their gables; the siding takes its lap shadow; the rake replaces its gables' eave trim, story_band 0 draws no board and the setback's soffit takes soffit_rgb; the end annex stands outside the footprint by its recorded exception and collides as drawn")
		quit(0)
	else:
		for failure: String in failures:
			print("FAIL: " + failure)
		quit(1)


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func _check_plain(model: Node3D) -> void:
	check(bool(model.get_meta("build_valid", false)), "the config without detail keys builds")
	for child: Node in model.get_children():
		check(not child.get_meta("visual_only", false) and str(child.get_meta("family_role", "support")) != "solid", "without detail keys nothing visual-only or solid is built: " + str(child.name))
	var siding := _siding(model)
	check(siding != null and siding.get_shader_parameter("course_shadow") == null, "without siding_course_shadow the siding keeps the shader's default")
	model.free()


## model and twin are two builds of the same config: the twin loses its visual-only parts
## before its contacts are made, and must collide exactly as the model does.
func _check_details(model: Node3D, twin: Node3D, cfg: Dictionary, wall: Dictionary) -> void:
	check(bool(model.get_meta("build_valid", false)), "1232 builds with its detail options")
	var siding := _siding(model)
	check(siding != null and is_equal_approx(float(siding.get_shader_parameter("course_shadow")), float(cfg.siding_course_shadow)), "the siding takes siding_course_shadow")
	var blinds: Array[MeshInstance3D] = []
	var shells: Array[MeshInstance3D] = []
	var boxes: Array[MeshInstance3D] = []
	for child: Node in model.get_children():
		var mesh := child as MeshInstance3D
		if mesh == null:
			continue
		if child.get_meta("visual_only", false):
			check(str(child.get_meta("family_role", "")) == "solid" and mesh.visible, "visual-only parts are visible and in the solid role")
			(blinds if mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF else shells).append(mesh)
		elif child.get_meta("collision_only", false) and str(child.get_meta("family_role", "")) == "solid":
			boxes.append(mesh)
	check(not blinds.is_empty() and not shells.is_empty() and boxes.size() == 1, "blinds, utility shells and the utilities' collision boxes are built apart")
	var contacts: Dictionary = ATTACH._contacts(model, [] as Array[MeshInstance3D], SOURCE)
	check(bool(contacts.get("ok", false)), "the attachment builds contacts for the detailed model")
	for child: Node in twin.get_children():
		if child.get_meta("visual_only", false):
			twin.remove_child(child)
			child.free()
	ATTACH._contacts(twin, [] as Array[MeshInstance3D], SOURCE)
	var bodies := _bodies(model)
	var twin_bodies := _bodies(twin)
	check(bodies.keys() == twin_bodies.keys(), "the same contact bodies with and without the visual-only parts")
	for role: String in bodies:
		check(twin_bodies.has(role) and bodies[role] == twin_bodies[role], "visual-only parts add no collision: the %s contact is the same without them" % role)
	var support_faces: PackedVector3Array = bodies.get("support", PackedVector3Array())
	_check_blinds(blinds, cfg)
	_check_utilities(shells, boxes, cfg, wall)
	_check_downspouts_and_vents(model, support_faces, cfg, wall)
	_check_annexes(bodies, cfg, wall)
	model.free()
	twin.free()


## Every blind vertex inside a front window's opening, 0.15-0.2 m behind its wall plane
## (a lower window's plane stands back with the lower storey under a frontage setback).
func _check_blinds(blinds: Array[MeshInstance3D], cfg: Dictionary) -> void:
	var windows: Array[Dictionary] = []
	var back := float(cfg.get("lower_frontage_recess", {}).get("depth_m", 0.0))
	for frame: Dictionary in cfg.target.frames:
		for group: String in ["upper_windows", "lower_windows"]:
			for motif: Dictionary in frame.get(group, []):
				var basis: Dictionary = motif.get("basis", frame)
				var t := _vec(basis.tangent)
				var n := _vec(basis.normal)
				var point := _vec(basis.start) + t * float(motif.get("local_station_m", motif.station_m))
				if group == "lower_windows":
					point -= n * back
				windows.append({"point": Vector3(point.x, float(motif.center_y), point.z), "t": t, "n": n, "w": float(motif.width_m), "h": float(motif.height_m)})
	var outside := 0
	var total := 0
	for mesh: MeshInstance3D in blinds:
		for vertex: Vector3 in _triangles(mesh):
			total += 1
			var held := false
			for window: Dictionary in windows:
				var d: Vector3 = vertex - window.point
				var across := d.dot(window.t)
				var behind := -d.dot(window.n)
				held = held or (absf(across) <= float(window.w) * 0.5 and absf(d.y) <= float(window.h) * 0.5 and behind >= 0.15 and behind <= 0.2)
			outside += int(not held)
	check(total > 0 and outside == 0, "every blind lies inside a front window behind its wall plane (%d of %d vertices outside)" % [outside, total])


## Each collision box holds drawn utility parts; every drawn part is held; the boxes stand
## outside the footprint and off the front doors' landings.
func _check_utilities(shells: Array[MeshInstance3D], boxes: Array[MeshInstance3D], cfg: Dictionary, wall: Dictionary) -> void:
	if boxes.is_empty():
		return
	# The lower walls: the footprint, moved in by a frontage setback.
	var ring := _ring(wall)
	var back := float(cfg.get("lower_frontage_recess", {}).get("depth_m", 0.0))
	if back > 0.0:
		ring = Geometry2D.offset_polygon(ring, -back)[0]
	var corners := _triangles(boxes[0])
	var hulls: Array[PackedVector2Array] = []
	var heights: Array[Vector2] = []
	# KIT._box emits each box as 12 triangles (36 corners) in turn.
	for start in range(0, corners.size(), 36):
		var points := PackedVector2Array()
		var low := INF
		var high := -INF
		for i in range(start, start + 36):
			points.append(Vector2(corners[i].x, corners[i].z))
			low = minf(low, corners[i].y)
			high = maxf(high, corners[i].y)
		hulls.append(Geometry2D.convex_hull(points))
		heights.append(Vector2(low, high))
	var items := 0
	for frame: Dictionary in cfg.target.frames:
		for entry: Dictionary in frame.get("entries", []):
			items += (entry.get("utilities", {}).get("items", []) as Array).size()
	check(hulls.size() == items, "one collision box per utility named in the config (%d boxes, %d items)" % [hulls.size(), items])
	var loose := 0
	for mesh: MeshInstance3D in shells:
		for vertex: Vector3 in _triangles(mesh):
			var held := false
			# A unit's pad runs on under the box's foot, into the ground; above it, the box holds all.
			for i in hulls.size():
				var grown: Array = Geometry2D.offset_polygon(hulls[i], 0.08)
				held = held or (not grown.is_empty() and Geometry2D.is_point_in_polygon(Vector2(vertex.x, vertex.z), grown[0]) and vertex.y <= heights[i].y + 0.08)
			loose += int(not held)
	check(loose == 0, "every drawn utility part lies in its collision box (%d vertices outside)" % loose)
	for hull: PackedVector2Array in hulls:
		for corner: Vector2 in hull:
			check(not Geometry2D.is_point_in_polygon(corner, ring), "a utility stands outside the building")
		for frame: Dictionary in cfg.target.frames:
			for entry: Dictionary in frame.get("entries", []):
				var basis: Dictionary = entry.get("basis", frame)
				var t := _vec(basis.tangent)
				var n := _vec(basis.normal)
				var door := _vec(basis.start) + t * float(entry.get("local_station_m", entry.station_m)) - n * back
				var p := Vector2(door.x, door.z)
				var tt := Vector2(t.x, t.z) * 0.8225
				var nn := Vector2(n.x, n.z) * 1.3
				var landing := PackedVector2Array([p - tt, p + tt, p + tt + nn, p - tt + nn])
				check(Geometry2D.intersect_polygons(hull, landing).is_empty(), "no utility stands on a front door's landing (frame %s)" % frame.id)


## Collision faces at every downspout's foot-to-top run; the roof vents (their own metal)
## inside the footprint; and every support face above the eaves outside the footprint
## within a gable rake's overhang of its gable.
func _check_downspouts_and_vents(model: Node3D, support: PackedVector3Array, cfg: Dictionary, wall: Dictionary) -> void:
	for frame: Dictionary in cfg.target.frames:
		for pipe: Dictionary in frame.get("pipes", []):
			if str(pipe.get("style", "")) != "downspout":
				continue
			var basis: Dictionary = pipe.get("basis", frame)
			var p := _vec(basis.start) + _vec(basis.tangent) * float(pipe.get("local_station_m", pipe.station_m))
			var mid := (float(pipe.bottom_y) + float(pipe.top_y)) * 0.5
			var near := false
			for vertex: Vector3 in support:
				near = near or (Vector2(vertex.x - p.x, vertex.z - p.z).length() < 0.45 and absf(vertex.y - mid) < 1.0)
			check(near, "the downspout in frame %s collides as drawn" % frame.id)
	var ring := _ring(wall)
	var metal: Array = cfg.roof_vents.get("rgb", [0.56, 0.57, 0.58])
	var vents := 0
	var inside := 0
	for child: Node in model.get_children():
		var mesh := child as MeshInstance3D
		if mesh == null or mesh.mesh == null or str(child.get_meta("family_role", "support")) != "support":
			continue
		for s in mesh.mesh.get_surface_count():
			var material := mesh.mesh.surface_get_material(s) as StandardMaterial3D
			if material == null or not material.albedo_color.is_equal_approx(Color(float(metal[0]), float(metal[1]), float(metal[2]))):
				continue
			for vertex: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
				vents += 1
				inside += int(Geometry2D.is_point_in_polygon(Vector2(vertex.x, vertex.z), ring))
	check(vents > 0 and inside == vents, "the roof vents stand inside the footprint (%d of %d vertices inside)" % [inside, vents])
	var over := float(cfg.get("gable_rakes", {}).get("overhang_m", 0.0)) + 0.05
	var vertices: Array = wall.vertices
	var stray := 0
	var eave := float(cfg.get("wall_top_y", 8.05)) + 0.3
	for vertex: Vector3 in support:
		var xz := Vector2(vertex.x, vertex.z)
		if vertex.y <= eave or Geometry2D.is_point_in_polygon(xz, ring):
			continue
		var held := false
		for run: Variant in cfg.get("gable_rakes", {}).get("runs", []):
			var i := int(run) * 12
			var a := Vector2(float(vertices[i]), float(vertices[i + 2]))
			var b := Vector2(float(vertices[i + 3]), float(vertices[i + 5]))
			held = held or Geometry2D.get_closest_point_to_segment(xz, a, b).distance_to(xz) <= over
		stray += int(not held)
	check(stray == 0, "the roof's support parts outside the footprint lie over a gable rake's overhang (%d vertices elsewhere)" % stray)


## Probes in the open air where a removed part would stand: at the middle of each rake run,
## just outside the wall at its top, where the eave trim runs (the plain build must draw it,
## the detailed one not); along the front at the storey band, just in front of the wall,
## away from the downspouts. And the setback's soffit, in its own colour, at the band.
func _check_floor_line_and_gables(plain: Node3D, model: Node3D, cfg: Dictionary, wall: Dictionary) -> void:
	var vertices: Array = wall.vertices
	var top := float(cfg.get("wall_top_y", 8.05))
	var plain_faces := _faces(plain)
	var faces := _faces(model)
	for run: Variant in cfg.gable_rakes.runs:
		var i := int(run) * 12
		var a := Vector3(float(vertices[i]), top, float(vertices[i + 2]))
		var b := Vector3(float(vertices[i + 3]), top, float(vertices[i + 5]))
		var t := (b - a).normalized()
		var n := Vector3(-t.z, 0.0, t.x)
		var mid := (a + b) * 0.5
		check(_crosses(plain_faces, mid + n * 0.03, mid + n * 0.3), "without gable_rakes, gable run %d carries the eave trim" % int(run))
		check(not _crosses(faces, mid + n * 0.03, mid + n * 0.3), "under its rake, gable run %d carries no eave trim" % int(run))
	if float(cfg.get("story_band", {}).get("height_m", 0.09)) <= 0.0:
		var band_y := float(cfg.get("facade", {}).get("story_band_y", 5.38))
		var pipes: Array[Vector3] = []
		for frame: Dictionary in cfg.target.frames:
			for pipe: Dictionary in frame.get("pipes", []):
				var basis: Dictionary = pipe.get("basis", frame)
				pipes.append(_vec(basis.start) + _vec(basis.tangent) * float(pipe.get("local_station_m", pipe.station_m)))
		var probes := 0
		var blocked: Array[String] = []
		# Along each front run's own wall line (a frame's runs can step).
		for frame: Dictionary in cfg.target.frames:
			for run: Variant in frame.runs:
				var i := int(run) * 12
				var a := Vector3(float(vertices[i]), band_y, float(vertices[i + 2]))
				var b := Vector3(float(vertices[i + 3]), band_y, float(vertices[i + 5]))
				var t := (b - a).normalized()
				var n := Vector3(-t.z, 0.0, t.x)
				for k in range(1, 5):
					var p := a.lerp(b, k / 5.0)
					var near := false
					for q: Vector3 in pipes:
						near = near or Vector2(q.x - p.x, q.z - p.z).length() < 0.6
					if near:
						continue
					probes += 1
					if _crosses(faces, p + n * 0.01, p + n * 0.12):
						blocked.append("run %d at %s" % [int(run), str(p)])
		check(probes > 0 and blocked.is_empty(), "story_band height 0 draws no board along the front (%d probes, blocked: %s)" % [probes, ", ".join(blocked)])
	var recess: Dictionary = cfg.get("lower_frontage_recess", {})
	if recess.has("soffit_rgb"):
		var rgb: Array = recess.soffit_rgb
		var want := Color(float(rgb[0]), float(rgb[1]), float(rgb[2]))
		var at_band := 0
		var elsewhere := 0
		for child: Node in model.get_children():
			var mesh := child as MeshInstance3D
			if mesh == null or mesh.mesh == null:
				continue
			for s in mesh.mesh.get_surface_count():
				var material := mesh.mesh.surface_get_material(s) as StandardMaterial3D
				if material == null or not material.albedo_color.is_equal_approx(want):
					continue
				for vertex: Vector3 in mesh.mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
					if absf((mesh.transform * vertex).y - float(recess.band_y)) < 0.005:
						at_band += 1
					else:
						elsewhere += 1
		check(at_band > 0 and elsewhere == 0, "the setback's soffit takes soffit_rgb, at the band and nowhere else (%d vertices at the band, %d elsewhere)" % [at_band, elsewhere])


## Each annex: its outline outside the footprint (an exception only for listed sources,
## which annex_valid enforces), probes into its open faces at chest height meet wall
## faces, and one down through its roof meets support faces.
func _check_annexes(bodies: Dictionary, cfg: Dictionary, wall: Dictionary) -> void:
	var ring := _ring(wall)
	var walls: PackedVector3Array = bodies.get("wall", PackedVector3Array())
	var support: PackedVector3Array = bodies.get("support", PackedVector3Array())
	var vertices: Array = wall.vertices
	for annex: Dictionary in cfg.get("end_annexes", []):
		check(annex.has("osm_exception"), "an end annex carries its recorded exception")
		var i := int(annex.run) * 12
		var a := Vector3(float(vertices[i]), 0.0, float(vertices[i + 2]))
		var b := Vector3(float(vertices[i + 3]), 0.0, float(vertices[i + 5]))
		var t := (b - a).normalized()
		var n := Vector3(-t.z, 0.0, t.x)
		var depth := float(annex.depth_m)
		var mid_along := (float(annex.from_m) + float(annex.to_m)) * 0.5
		var centre := a + t * mid_along + n * depth * 0.5
		check(not Geometry2D.is_point_in_polygon(Vector2(centre.x, centre.z), ring), "the annex stands outside the frozen footprint")
		var chest := float(annex.door.bottom_y) + 1.3
		var door_face := a + t * float(annex.to_m) + n * (depth - 0.03)
		var probes := [
			[a + t * mid_along + n * (depth + 0.6), a + t * mid_along + n * (depth - 0.3), "its far face"],
			[door_face + t * 0.6, door_face - t * 0.3, "its end face by the door"],
			[a + t * float(annex.from_m) + n * depth * 0.5 - t * 0.6, a + t * float(annex.from_m) + n * depth * 0.5 + t * 0.3, "its other end face"],
		]
		for probe: Array in probes:
			var from: Vector3 = probe[0]
			var to: Vector3 = probe[1]
			from.y = chest
			to.y = chest
			check(_crosses(walls, from, to), "the annex's wall collides as drawn: %s" % probe[2])
		var over := centre + Vector3.UP * (float(annex.top_y) + 1.0)
		var into := centre + Vector3.UP * (float(annex.top_y) - 0.5)
		check(_crosses(support, over, into), "the annex's roof collides as drawn")


## Every drawn triangle of a model, in its frame.
func _faces(model: Node3D) -> PackedVector3Array:
	var out := PackedVector3Array()
	for child: Node in model.get_children():
		var mesh := child as MeshInstance3D
		if mesh != null and mesh.mesh != null and mesh.visible:
			out.append_array(_triangles(mesh))
	return out


func _crosses(faces: PackedVector3Array, from: Vector3, to: Vector3) -> bool:
	for i in range(0, faces.size(), 3):
		if Geometry3D.segment_intersects_triangle(from, to, faces[i], faces[i + 1], faces[i + 2]) != null:
			return true
	return false


## Each contact body's world faces, by role.
func _bodies(model: Node3D) -> Dictionary:
	var out := {}
	for child: Node in model.get_children():
		var body := child as StaticBody3D
		if body == null:
			continue
		var faces := PackedVector3Array()
		for vertex: Vector3 in ((body.get_child(0) as CollisionShape3D).shape as ConcavePolygonShape3D).get_faces():
			faces.append(vertex + body.position)
		out[str(body.get_meta("family_role", ""))] = faces
	return out


func _siding(model: Node3D) -> ShaderMaterial:
	for child: Node in model.get_children():
		var mesh := child as MeshInstance3D
		if mesh == null or mesh.mesh == null:
			continue
		for s in mesh.mesh.get_surface_count():
			var material := mesh.mesh.surface_get_material(s) as ShaderMaterial
			if material != null and material.shader == SIDING:
				return material
	return null


func _triangles(mesh: MeshInstance3D) -> PackedVector3Array:
	var out := PackedVector3Array()
	for vertex: Vector3 in mesh.mesh.get_faces():
		out.append(mesh.transform * vertex)
	return out


func _ring(wall: Dictionary) -> PackedVector2Array:
	var ring := PackedVector2Array()
	var vertices: Array = wall.vertices
	for i in range(0, vertices.size(), 12):
		ring.append(Vector2(float(vertices[i]), float(vertices[i + 2])))
	return ring


func _vec(a: Array) -> Vector3:
	return Vector3(float(a[0]), float(a[1]), float(a[2]))
