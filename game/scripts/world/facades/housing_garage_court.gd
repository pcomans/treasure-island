extends RefCounted
## Opt-in garage-court motifs for the shared housing kit (housing_site_family):
## single-car garage doors, garage-bank piers, window shutters, recessed
## loggias, exterior open stairs, gable vents and coloured gablets. The kit
## calls these only for config keys that are present, so configs without them
## build exactly as before. Dimensions are instance-config production
## inference, not survey.

const PARTS = preload("res://game/scripts/world/facades/northpoint_1232_quality_model.gd")
const BRICK = preload("res://game/resources/housing_family/brick.gdshader")
const SIDING = preload("res://game/resources/housing_family/siding.gdshader")
const NOSE := 0.025
const STEEL := 0.05


static func _vec(a: Array) -> Vector3:
	return Vector3(a[0], a[1], a[2])


static func _number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))


# Three numbers in [0, 1].
static func _rgb(value: Variant) -> bool:
	if not value is Array or (value as Array).size() != 3:
		return false
	for channel: Variant in value:
		if not _number(channel) or float(channel) < 0.0 or float(channel) > 1.0:
			return false
	return true


# Invalid opt-in data fails the whole build closed, like the kit's other guards.
static func _invalid(root: Node3D, message: String) -> void:
	root.set_meta("build_valid", false)
	push_error("%s: %s" % [message, root.get_meta("source_key", "")])


static func _color(cfg: Dictionary, key: String, fallback: Color) -> Color:
	var a: Array = cfg.get(key, [])
	return Color(a[0], a[1], a[2]) if a.size() == 3 else fallback


# ---------- one mesh per material: flat-shaded triangle buckets ----------

static func _bucket() -> Dictionary:
	return {"vertices": [], "normals": []}


# Godot renders the clockwise side: the front normal of (a, b, c) is
# -(b-a)x(c-a). Each triangle is wound to face along outward.
static func _tri(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, outward: Vector3) -> void:
	var cross := (b - a).cross(c - a)
	if cross.length_squared() < 1e-12:
		return
	if cross.dot(outward) > 0.0:
		var swap := b
		b = c
		c = swap
		cross = -cross
	var normal := -cross.normalized()
	(bucket.vertices as Array).append_array([a, b, c])
	(bucket.normals as Array).append_array([normal, normal, normal])


static func _quad(bucket: Dictionary, a: Vector3, b: Vector3, c: Vector3, d: Vector3, outward: Vector3) -> void:
	_tri(bucket, a, b, c, outward)
	_tri(bucket, a, c, d, outward)


# Box with orthonormal axes: size.x along ax, size.y along ay, size.z along az.
static func _obox(bucket: Dictionary, center: Vector3, ax: Vector3, ay: Vector3, az: Vector3, size: Vector3) -> void:
	var x := ax.normalized() * size.x * 0.5
	var y := ay.normalized() * size.y * 0.5
	var z := az.normalized() * size.z * 0.5
	var c := [center - x - y - z, center + x - y - z, center + x + y - z, center - x + y - z,
		center - x - y + z, center + x - y + z, center + x + y + z, center - x + y + z]
	_quad(bucket, c[1], c[2], c[6], c[5], x)
	_quad(bucket, c[0], c[4], c[7], c[3], -x)
	_quad(bucket, c[3], c[7], c[6], c[2], y)
	_quad(bucket, c[0], c[1], c[5], c[4], -y)
	_quad(bucket, c[4], c[5], c[6], c[7], z)
	_quad(bucket, c[0], c[3], c[2], c[1], -z)


# Wall-aligned box: size.x along the wall tangent, size.y up, size.z along the wall normal.
static func _box(bucket: Dictionary, center: Vector3, t: Vector3, n: Vector3, size: Vector3) -> void:
	_obox(bucket, center, t, Vector3.UP, n, size)


static func _commit(root: Node3D, bucket: Dictionary, material: Material, label: String) -> MeshInstance3D:
	if (bucket.vertices as Array).is_empty():
		return null
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(bucket.vertices)
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(bucket.normals)
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var node := MeshInstance3D.new()
	node.name = label
	node.mesh = mesh
	node.material_override = material
	root.add_child(node)
	return node


# ---------- garage-door bank ----------

## One single-car panel garage door in a width x height opening centred at
## point on the host wall face (the kit has already moved point onto a
## recessed lower wall). Jambs and head line the opening back to the leaf;
## the leaf carries section and stile lines; a flat frame trims the wall.
static func garage_door(root: Node3D, point: Vector3, t: Vector3, n: Vector3, width: float, height: float, motif: Dictionary, palette: Dictionary, trim: Material) -> void:
	var leaf_color := _color(motif, "door_rgb", _color(palette, "garage_door_rgb", Color(0.78, 0.74, 0.66)))
	var setback := float(motif.get("door_setback_m", 0.12))
	var leaf := _bucket()
	var lines := _bucket()
	var reveal := _bucket()
	var frame := _bucket()
	for side: float in [-1.0, 1.0]:
		_box(reveal, point + t * side * (width * 0.5 - 0.025) - n * setback * 0.5, t, n, Vector3(0.05, height, setback))
	_box(reveal, point + Vector3.UP * (height * 0.5 - 0.025) - n * setback * 0.5, t, n, Vector3(width - 0.1, 0.05, setback))
	# The leaf closes the opening down to its sill, under the head jamb.
	_box(leaf, point - n * (setback + 0.02) - Vector3.UP * 0.0225, t, n, Vector3(width - 0.1, height - 0.055, 0.04))
	var face := point - n * (setback - 0.004)
	# Opt-in panel style from the photo: "grid" (default) adds two stiles to
	# the horizontal section joints, "joints" keeps the joints only;
	# joint_count defaults to three (four sections).
	var joints := int(motif.get("joint_count", 3))
	for k in range(1, joints + 1):
		_box(lines, face + Vector3.UP * (-height * 0.5 + height * float(k) / float(joints + 1)), t, n, Vector3(width - 0.14, 0.022, 0.012))
	if motif.has("stiles"):
		# Opt-in explicit stile count, evenly spaced (one stile: a two-leaf door).
		if not _number(motif.stiles):
			_invalid(root, "Invalid garage door stiles %s" % [motif.stiles])
			return
		var stiles := int(motif.stiles)
		for k in range(1, stiles + 1):
			_box(lines, face + t * (width - 0.1) * (float(k) / float(stiles + 1) - 0.5), t, n, Vector3(0.02, height - 0.09, 0.012))
	elif str(motif.get("panel_style", "grid")) == "grid":
		for k: float in [-1.0, 1.0]:
			_box(lines, face + t * k * (width - 0.1) / 6.0, t, n, Vector3(0.02, height - 0.09, 0.012))
	for side: float in [-1.0, 1.0]:
		_box(frame, point + t * side * (width * 0.5 + 0.05) + n * 0.015, t, n, Vector3(0.10, height + 0.10, 0.03))
	_box(frame, point + Vector3.UP * (height * 0.5 + 0.05) + n * 0.015, t, n, Vector3(width + 0.2, 0.10, 0.03))
	_commit(root, leaf, PARTS._material(leaf_color, 0.8), "GarageDoorLeaf")
	_commit(root, lines, PARTS._material(leaf_color.darkened(0.3), 0.85), "GarageDoorLines")
	_commit(root, reveal, PARTS._material(_color(palette, "garage_reveal_rgb", leaf_color.darkened(0.4)), 0.9), "GarageDoorReveal")
	_commit(root, frame, trim, "GarageDoorFrame")


## Piers of a front frame's garage bank. Each stands on the recessed lower
## wall (setback from the source plane) and projects toward the street;
## style "brick" uses the procedural running-bond material.
static func piers(root: Node3D, frame: Dictionary, palette: Dictionary) -> void:
	for pier: Dictionary in frame.get("garage_piers", []):
		var basis: Dictionary = pier.get("basis", frame)
		var t := _vec(basis.tangent)
		var n := _vec(basis.normal)
		var p := _vec(basis.start) + t * float(pier.get("local_station_m", pier.get("station_m", 0.0)))
		var bottom := float(pier.bottom_y)
		var top := float(pier.top_y)
		var back := -float(pier.get("setback_m", 0.0)) - 0.01
		var projection := float(pier.get("projection_m", 0.08)) + 0.01
		p.y = (bottom + top) * 0.5
		var bucket := _bucket()
		_box(bucket, p + n * (back + projection * 0.5), t, n, Vector3(float(pier.width_m), top - bottom, projection))
		var material: Material
		if str(pier.get("style", "plain")) == "brick":
			var brick := ShaderMaterial.new()
			brick.shader = BRICK
			brick.set_shader_parameter("brick_color", _color(pier, "brick_rgb", _color(palette, "brick_rgb", Color(0.55, 0.26, 0.2))))
			brick.set_shader_parameter("mortar_color", _color(pier, "mortar_rgb", Color(0.72, 0.7, 0.66)))
			material = brick
		else:
			material = PARTS._material(_color(pier, "material_rgb", _color(palette, "siding_rgb", Color.GRAY)), 0.9)
		var node := _commit(root, bucket, material, "GaragePier")
		node.set_meta("family_role", "wall")
	# Opt-in window shutters on the front frame's wall face, in palette shutter_rgb.
	var shutters := _bucket()
	for shutter: Dictionary in frame.get("shutters", []):
		var complete := true
		for key: String in ["local_station_m", "bottom_y", "top_y", "width_m"]:
			complete = complete and shutter.has(key) and _number(shutter[key])
		if not complete:
			_invalid(root, "Invalid shutter in frame %s" % [frame.get("id", "")])
			continue
		var basis: Dictionary = shutter.get("basis", frame)
		var t := _vec(basis.tangent)
		var n := _vec(basis.normal)
		var p := _vec(basis.start) + t * float(shutter.local_station_m)
		var bottom := float(shutter.bottom_y)
		var top := float(shutter.top_y)
		p.y = (bottom + top) * 0.5
		_box(shutters, p + n * 0.025, t, n, Vector3(float(shutter.width_m), top - bottom, 0.05))
	var shutter_node := _commit(root, shutters, PARTS._material(_color(palette, "shutter_rgb", Color(0.45, 0.4, 0.35)), 0.85), "WindowShutters")
	if shutter_node != null:
		shutter_node.set_meta("family_role", "wall")


## Opt-in wall colours on the siding of the wall pieces built since begin for
## one source run: cfg.run_siding_rgb {"<run>": [r, g, b]} repaints the whole
## run; cfg.lower_siding_rgb repaints the lower storey (pieces at or below the
## recess band) of front-frame runs, for a two-tone upper/garage zone. Both
## keep the siding shader; runs without them keep the instance siding.
static func run_siding(root: Node3D, begin: int, run: int, cfg: Dictionary, siding: ShaderMaterial) -> void:
	var colors: Dictionary = cfg.get("run_siding_rgb", {})
	var run_material := siding
	if colors.has(str(run)):
		run_material = siding.duplicate() as ShaderMaterial
		run_material.set_shader_parameter("wall_color", _color(colors, str(run), Color.GRAY))
		for i in range(begin, root.get_child_count()):
			var child := root.get_child(i) as MeshInstance3D
			if child != null and child.material_override == siding:
				child.material_override = run_material
	# extras() reports an invalid lower_siding_rgb once; here it is simply not applied.
	var lower: Variant = cfg.get("lower_siding_rgb", [])
	if not _rgb(lower) or cfg.get("lower_frontage_recess", {}).is_empty():
		return
	var front_run := false
	for frame: Dictionary in cfg.target.frames:
		for frame_run in frame.runs:
			if int(frame_run) == run:
				front_run = true
	if not front_run:
		return
	var band := float(cfg.lower_frontage_recess.band_y)
	var lower_material := siding.duplicate() as ShaderMaterial
	lower_material.set_shader_parameter("wall_color", Color(lower[0], lower[1], lower[2]))
	for i in range(begin, root.get_child_count()):
		var child := root.get_child(i) as MeshInstance3D
		if child != null and child.material_override == run_material and child.mesh.get_aabb().end.y <= band + 0.001:
			child.material_override = lower_material


# ---------- recessed loggia (balcony with railing, or porch without) ----------

## A width x height opening centred at point recessed depth_m into the wall:
## back wall with a glazed sliding door, side walls, soffit and floor, all
## inside the host wall, plus an optional railing across the opening.
static func loggia(root: Node3D, point: Vector3, t: Vector3, n: Vector3, width: float, height: float, motif: Dictionary, palette: Dictionary, siding: Material, trim: Material, dark: Material, concrete: Material) -> void:
	var depth := float(motif.get("depth_m", 1.3))
	var half := width * 0.5
	var bottom := point.y - height * 0.5
	var top := point.y + height * 0.5
	var base := Vector3(point.x, 0.0, point.z)
	var inner := _bucket()
	var soffit := _bucket()
	var floor_slab := _bucket()
	var glazing := _bucket()
	var frame := _bucket()
	var rail := _bucket()
	var l0 := base - t * half
	var r0 := base + t * half
	var l1 := l0 - n * depth
	var r1 := r0 - n * depth
	var up_b := Vector3.UP * bottom
	var up_t := Vector3.UP * top
	_quad(inner, l1 + up_b, r1 + up_b, r1 + up_t, l1 + up_t, n)
	_quad(inner, l0 + up_b, l1 + up_b, l1 + up_t, l0 + up_t, t)
	_quad(inner, r1 + up_b, r0 + up_b, r0 + up_t, r1 + up_t, -t)
	_quad(soffit, l0 + up_t, r0 + up_t, r1 + up_t, l1 + up_t, Vector3.DOWN)
	_box(floor_slab, base - n * depth * 0.5 + Vector3.UP * (bottom - 0.06), t, n, Vector3(width, 0.12, depth))
	var door_width := minf(1.8, width - 0.6)
	var door_height := minf(2.05, height - 0.12)
	var door_center := base - n * (depth - 0.03) + Vector3.UP * (bottom + door_height * 0.5)
	_box(glazing, door_center, t, n, Vector3(door_width, door_height, 0.02))
	for side: float in [-1.0, 1.0]:
		_box(frame, door_center + t * side * (door_width * 0.5 + 0.03), t, n, Vector3(0.06, door_height + 0.06, 0.05))
	_box(frame, door_center + Vector3.UP * (door_height * 0.5 + 0.03), t, n, Vector3(door_width + 0.12, 0.06, 0.05))
	_box(frame, door_center, t, n, Vector3(0.05, door_height, 0.05))
	if bool(motif.get("railing", false)):
		var rail_face := base - n * 0.06
		var rail_top := bottom + 1.0
		_box(rail, rail_face + Vector3.UP * rail_top, t, n, Vector3(width - 0.04, 0.05, 0.05))
		_box(rail, rail_face + Vector3.UP * (bottom + 0.1), t, n, Vector3(width - 0.04, 0.04, 0.04))
		var count := maxi(2, int(floor((width - 0.1) / 0.12)))
		for i in count + 1:
			var along := lerpf(-half + 0.05, half - 0.05, float(i) / float(count))
			_box(rail, rail_face + t * along + Vector3.UP * (bottom + 0.55), t, n, Vector3(0.022, 0.9, 0.022))
	_commit(root, inner, siding, "LoggiaWalls")
	_commit(root, soffit, PARTS._material(_color(palette, "soffit_rgb", Color(0.86, 0.85, 0.82)), 0.92), "LoggiaSoffit")
	_commit(root, floor_slab, concrete, "LoggiaFloor")
	_commit(root, glazing, dark, "LoggiaGlazing")
	_commit(root, frame, trim, "LoggiaDoorFrame")
	_commit(root, rail, PARTS._material(_color(motif, "rail_rgb", _color(palette, "rail_rgb", Color(0.3, 0.3, 0.3))), 0.6), "LoggiaRailing")


# ---------- exterior open stairs and gable vents ----------

## Stairs, vents and gablets named by the instance config, tagged with their roles.
static func extras(root: Node3D, cfg: Dictionary, palette: Dictionary, trim: Material) -> void:
	for spec: Dictionary in cfg.get("exterior_stairs", []):
		_stair(root, spec, palette)
	if cfg.has("lower_siding_rgb") and not _rgb(cfg.lower_siding_rgb):
		_invalid(root, "Invalid lower_siding_rgb %s" % [cfg.lower_siding_rgb])
	# Opt-in gablets in their own siding colour (roof role, wound as authored).
	var gablets: Dictionary = cfg.get("gablets", {})
	if not gablets.is_empty() and not _rgb(gablets.get("rgb")):
		_invalid(root, "Invalid gablets rgb %s" % [gablets.get("rgb")])
	elif not gablets.is_empty():
		var gablet_siding := ShaderMaterial.new()
		gablet_siding.shader = SIDING
		gablet_siding.set_shader_parameter("wall_color", _color(gablets, "rgb", Color.GRAY))
		for triangle: Array in gablets.get("triangles", []):
			PARTS._mesh(root, [_vec(triangle[0]), _vec(triangle[1]), _vec(triangle[2])], PackedInt32Array([0, 1, 2]), gablet_siding)
			root.get_child(-1).set_meta("family_role", "roof")
	var louver_frame := _bucket()
	var louver_back := _bucket()
	for vent: Dictionary in cfg.get("gable_vents", []):
		var c := _vec(vent.center)
		var n := _vec(vent.normal).normalized()
		var t := Vector3(n.z, 0.0, -n.x)
		var w := float(vent.width_m)
		var h := float(vent.height_m)
		_box(louver_back, c + n * 0.01, t, n, Vector3(w, h, 0.02))
		for side: float in [-1.0, 1.0]:
			_box(louver_frame, c + n * 0.03 + t * side * (w * 0.5 + 0.02), t, n, Vector3(0.05, h + 0.09, 0.05))
			_box(louver_frame, c + n * 0.03 + Vector3.UP * side * (h * 0.5 + 0.02), t, n, Vector3(w + 0.09, 0.05, 0.05))
		var slats := maxi(2, int(floor(h / 0.08)))
		for i in range(1, slats):
			_box(louver_frame, c + n * 0.03 + Vector3.UP * (-h * 0.5 + h * float(i) / float(slats)), t, n, Vector3(w, 0.025, 0.04))
	for node: MeshInstance3D in [
		_commit(root, louver_back, PARTS._material(_color(palette, "vent_rgb", Color(0.16, 0.15, 0.14)), 0.9), "GableVentBack"),
		_commit(root, louver_frame, trim, "GableVentLouvers")]:
		if node != null:
			node.set_meta("family_role", "roof")


static func _stair_point(foot: Vector3, a: Vector3, right: Vector3, s: float, w: float, y: float) -> Vector3:
	return Vector3(foot.x, y, foot.z) + a * s + right * w


## One straight open steel flight: two stringers, open treads, railings and a
## top landing on posts, all rendering and colliding in the support role.
## The stock controller has no step-up, so the walking surface is a
## collision-only ramp through the tread nosings (the Mersea and
## Bulgarian-wall stair grammar): every tread lies on or below it, it spans
## only the clear width between the stringers, and it meets the landing deck
## flush at the top nosing.
static func _stair(root: Node3D, spec: Dictionary, palette: Dictionary) -> void:
	var foot := _vec(spec.foot)
	var a := _vec(spec.axis)
	a.y = 0.0
	a = a.normalized()
	var right := Vector3(-a.z, 0.0, a.x)
	var risers := int(spec.risers)
	var rise := float(spec.rise_m) / float(risers)
	var going := float(spec.going_m)
	var clear := float(spec.clear_width_m)
	var landing_depth := float(spec.landing_depth_m)
	var y0 := foot.y
	var landing_y := y0 + rise * float(risers)
	var line := clear * 0.5 + STEEL * 0.5
	var s_foot := -going - NOSE
	var s_top := float(risers - 1) * going - NOSE
	var slope := rise / going
	var cos_slope := going / sqrt(going * going + rise * rise)
	var d := (a * going + Vector3.UP * rise).normalized()
	var p := (Vector3.UP * going - a * rise).normalized()
	var steel := _bucket()
	var treads := _bucket()
	var ramp := _bucket()
	# Open treads: tread k (1..risers-1) tops out at y0 + k*rise, nosing at (k-1)*going - NOSE.
	for k in range(1, risers):
		var s_front := float(k - 1) * going - NOSE
		var s_back := float(k) * going
		_obox(treads, _stair_point(foot, a, right, (s_front + s_back) * 0.5, 0.0, y0 + rise * float(k) - 0.0225), a, Vector3.UP, right, Vector3(s_back - s_front, 0.045, clear))
	# Landing deck, flush with the top nosing.
	_obox(treads, _stair_point(foot, a, right, s_top + landing_depth * 0.5, 0.0, landing_y - 0.08), a, Vector3.UP, right, Vector3(landing_depth, 0.16, clear + STEEL * 2.0))
	# Channel stringers: top edge 0.06 above the nosing line, 0.26 deep.
	var length := (s_top - s_foot) / cos_slope
	for side: float in [-1.0, 1.0]:
		var mid := (s_foot + s_top) * 0.5
		var center := _stair_point(foot, a, right, mid, side * line, y0 + (mid - s_foot) * slope) + p * (0.06 * cos_slope - 0.13)
		_obox(steel, center, d, p, right, Vector3(length, 0.26, STEEL))
	# Flight railings on the requested sides: handrail 0.9 above the nosings, pickets.
	for label: String in spec.get("rail_sides", ["left", "right"]):
		var w := line * (1.0 if label == "right" else -1.0)
		var s0 := -NOSE
		var rail_mid := (s0 + s_top) * 0.5
		var rail_center := _stair_point(foot, a, right, rail_mid, w, y0 + (rail_mid - s_foot) * slope + 0.9)
		_obox(steel, rail_center, d, p, right, Vector3((s_top - s0) / cos_slope, 0.045, 0.045))
		var count := maxi(2, int(ceil((s_top - s0) / 0.13)))
		for i in count + 1:
			var s := lerpf(s0, s_top, float(i) / float(count))
			var nosing_y := y0 + (s - s_foot) * slope
			_obox(steel, _stair_point(foot, a, right, s, w, nosing_y + 0.48), a, Vector3.UP, right, Vector3(0.022, 0.84, 0.022))
		_obox(steel, _stair_point(foot, a, right, s0, w, (y0 + y0 + rise + 0.95) * 0.5), a, Vector3.UP, right, Vector3(0.05, rise + 0.95, 0.05))
	# Landing railings along the requested lateral sides, stopping clear of the door trim.
	for label: String in spec.get("landing_rail_sides", []):
		var w := line * (1.0 if label == "right" else -1.0)
		var s_end := s_top + landing_depth - 0.15
		_obox(steel, _stair_point(foot, a, right, (s_top + s_end) * 0.5, w, landing_y + 0.95), a, Vector3.UP, right, Vector3(s_end - s_top, 0.045, 0.045))
		var count := maxi(2, int(ceil((s_end - s_top) / 0.12)))
		for i in count + 1:
			var s := lerpf(s_top, s_end, float(i) / float(count))
			_obox(steel, _stair_point(foot, a, right, s, w, landing_y + 0.49), a, Vector3.UP, right, Vector3(0.022, 0.92, 0.022))
	# Landing posts down to the sampled ground.
	for post: Dictionary in spec.get("posts", []):
		var xz: Array = post.xz
		var bottom := float(post.bottom_y)
		var top := landing_y - 0.16
		_obox(steel, Vector3(xz[0], (bottom + top) * 0.5, xz[1]), a, Vector3.UP, right, Vector3(0.08, top - bottom, 0.08))
	# Collision-only walking surface through the nosings, from the ground one going ahead of the first nosing.
	_quad(ramp, _stair_point(foot, a, right, s_foot, -clear * 0.5, y0), _stair_point(foot, a, right, s_foot, clear * 0.5, y0), _stair_point(foot, a, right, s_top, clear * 0.5, landing_y), _stair_point(foot, a, right, s_top, -clear * 0.5, landing_y), p)
	for node: MeshInstance3D in [
		_commit(root, steel, PARTS._material(_color(spec, "steel_rgb", _color(palette, "stair_rgb", Color(0.32, 0.33, 0.32))), 0.55), "StairSteel"),
		_commit(root, treads, PARTS._material(_color(spec, "tread_rgb", _color(palette, "tread_rgb", Color(0.56, 0.56, 0.54))), 0.9), "StairTreads")]:
		if node != null:
			node.set_meta("family_role", "support")
	var walk := _commit(root, ramp, null, "StairWalkSurface")
	walk.visible = false
	walk.set_meta("family_role", "support")
	walk.set_meta("collision_only", true)
