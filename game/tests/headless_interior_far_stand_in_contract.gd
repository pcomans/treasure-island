extends SceneTree
## InteriorFarStandIn (game/scripts/world/interiors/interior_far_stand_in.gd) on its own,
## headless, at 60 frames a second of game time (--fixed-fps 60), for a made-up interior:
## a root carrying a ring_sector plan (centre 0, 0; radii 10 to 20 m; angles -0.5 to 0.5;
## top 8 m) and a stand-in spec (one zone with an opening in its outer wall, a sill quad
## outside it, a glowing panel kept, the floor's own material kept), its detailed
## surfaces a closed room of known colours, a near source whose state the test turns, a
## near node, a near process that counts its frames, and a camera.
## - Specs it cannot use are refused (spec_problem).
## (The room's outer wall is open from the floor to OPENING's top, the top of its lower
## band, between OPENING's angles: a doorway.)
## - build(): the stand-in is hidden, on the layers given, casting no shadow; every face
##   faces into the room (Godot's front, clockwise seen from inside); each face carries
##   the detailed colour over it, the outer wall's lower band parted at its piers (the
##   faces on them darker, as the piers are, than the bays beside them); the floor keeps
##   the detailed floor's own material and its polar UVs, parted in floor_split steps
##   of each segment; the glowing panel keeps its material; every other face is drawn
##   with a material whose shader is a detailed surface's own (no new shader to
##   compile); the outer wall's opening stays open.
## - Before play starts nothing switches.
## - The source going far shows the stand-in in that same frame (the switch runs after
##   its source) and hides the near node; a frame later the near process is paused (its
##   frames stop), and it is given back its mode in the frame the source is near again.
## - Each turn of the source is exactly one switch.
## - A camera in the plan, or within INSIDE_MARGIN_M of it, keeps the interior near
##   whatever the source says, from the frame it gets there; farther out, far again.
## - force holds a state; leaving the tree while far puts everything back as built.
##
## Outside views, for each interior with a stand-in that the generated world builds
## (game/tests/support/interior_world.gd: the catalog units with walk-through passages,
## their chunks built as the world builds them, and the chunks under the interior): from
## anywhere outside, far and near look the same but through the spec's declared
## openings (its doorway). With the interior's own switch forced far, then near, all
## that is drawn is read (every visible mesh and multimesh instance, each surface's
## triangles by the shared collector, building_study_geometry.gd, showing the side its
## material shows): what is on the interior's layer (the stand-in's: what the switch
## changes) is looked at, and the rest hides it, but for surfaces that can be seen
## through (transparent or discarding materials, or ones the collector can't read).
## Points over every looked-at triangle (its middle, its corners drawn a little in, and
## every SAMPLE_M across a large one) are looked at from viewpoints all round the
## interior at eye height, over its roof and at jetpack heights, from overhead and from
## in front of each opening, but none shut in (under something facing up). A point
## whose side faces a viewpoint and that nothing hides from it must be seen through an
## opening (the sight line crosses its box). Not empty: in each state something is seen
## through an opening.

const PLAN := {"kind": "ring_sector", "centre": Vector2(0.0, 0.0), "radii": Vector2(10.0, 20.0), "angles": Vector2(-0.5, 0.5), "top_y": 8.0}
const LAYERS := 1 << 5
## The detailed room: its surfaces' albedo (sRGB), the floor's vertex colour.
const WALL_RGB := Color(0.8, 0.2, 0.2)
const START_RGB := Color(0.2, 0.7, 0.2)
const END_RGB := Color(0.2, 0.2, 0.8)
const CEILING_RGB := Color(0.9, 0.9, 0.3)
const SILL_RGB := Color(0.6, 0.6, 0.6)
const PIER_RGB := Color(0.15, 0.1, 0.05)
## The zone's stations between its ends, each a pier PIER_HALF_M either side in the
## outer wall's lower band (0 to 3 m); the floor parted in FLOOR_SPLIT steps a segment.
const PIERS: Array[float] = [-0.25, 0.25]
const PIER_HALF_M := 0.5
const FLOOR_SPLIT := 2
const FLOOR_TINT := 0.5
const OPENING := Vector3(-0.1, 0.1, 3.0)
const GLOW_SPAN := Vector2(0.2, 0.3)
const COLOUR_TOLERANCE := 0.02
const StudyGeometry := preload("res://game/tests/support/building_study_geometry.gd")
const InteriorWorld := preload("res://game/tests/support/interior_world.gd")
## The outside views: points this far apart across a large looked-at triangle, its
## corners drawn this share of the way to its middle, and of an instance's points one
## to a SAMPLE_M cube facing one way (its sides' main axis); viewpoints in VIEW_AZIMUTHS
## directions about the interior's bounds, VIEW_DISTANCES_M past their reach, at eye
## height (EYE_M over their floor) and VIEW_HEIGHTS_M over their top; overhead at
## OVERHEAD_M, and in front of each opening at OPENING_VIEWS_M (out, up).
const SAMPLE_M := 1.0
const CORNER_INSET := 0.02
const VIEW_AZIMUTHS := 16
const VIEW_DISTANCES_M: Array[float] = [10.0, 60.0]
const EYE_M := 1.6
const VIEW_HEIGHTS_M: Array[float] = [2.0, 25.0, 100.0]
const OVERHEAD_M: Array[float] = [30.0, 120.0]
const OPENING_VIEWS_M: Array[Vector2] = [Vector2(6.0, 0.0), Vector2(20.0, 0.0), Vector2(20.0, 8.0), Vector2(60.0, 20.0)]
## A sight line stops this short of the point, so a surface just over it still hides it,
## and passes a face it meets from behind by this much; past MAX_PASSES such faces it
## is taken as unhidden (and shown below if that matters). A point is seen only when
## the four sight lines SPREAD_M round its own, across it, are clear too: one line
## through the meeting edge of two hiding faces, or a crack narrower than that between
## them, is not a view.
const SIGHT_END_M := 0.01
const SPREAD_M := 0.02
const PASS_M := 0.001
const MAX_PASSES := 64
const EXAMPLES := 8
const SPEC := {
	"near_source": "Source",
	"near_nodes": ["Detail"],
	"near_processes": ["Busy"],
	"zones": [{"radii": Vector2(10.0, 20.0), "stations": [-0.5, -0.25, 0.0, 0.25, 0.5], "floor_split": FLOOR_SPLIT, "floor_y": 0.0, "ceiling_y": 6.0, "outer": [0.0, 3.0, 6.0], "outer_split": {"bands": 1, "half_m": PIER_HALF_M}, "start": [0.0, 6.0], "end": [0.0, 6.0], "opening": OPENING}],
	"kept": ["glow"],
	"materials": ["floor"],
	"uv_frames": {"floor": {"theta": Vector2(-0.5, 0.5), "radius": Vector2(10.0, 20.0)}},
	"matte": {"roughness": 0.9, "specular": 0.15},
}


class FakeMain extends Node:
	var play_ready := false

	func is_play_ready() -> bool:
		return play_ready


## The near source: near or not, as the test sets it or as it turns itself at a frame
## of its own (turn_at), counting its frames.
class FakeSource extends Node:
	var near := true
	var frames := 0
	var turn_at := -1

	func _process(_delta: float) -> void:
		frames += 1
		if frames == turn_at:
			near = not near

	func is_near() -> bool:
		return near


class Counter extends Node:
	var frames := 0

	func _process(_delta: float) -> void:
		frames += 1


## Takes the shader the engine's shader inspector names for each material asked.
class Inspector extends Node:
	var answers: Array[RID] = []

	func _inspect_shader(shader: RID) -> void:
		answers.append(shader)


var failures: Array[String] = []
var _main: FakeMain
var _root: Node3D
var _source: FakeSource
var _busy: Counter
var _detail: MeshInstance3D
var _far: MeshInstance3D
var _switch: InteriorFarStandIn
var _camera: Camera3D
var _materials := {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_specs()
	_main = FakeMain.new()
	_main.name = "Main"
	root.add_child(_main)
	_root = Node3D.new()
	_root.name = "Interior"
	_root.set_meta(InteriorPresence.PLAN_META, PLAN)
	var spec := SPEC.duplicate(true)
	spec["quads"] = [{"corners": [_at(9.5, -0.1, 0.0), _at(10.0, -0.1, 0.0), _at(10.0, 0.1, 0.0), _at(9.5, 0.1, 0.0)], "normal": Vector3.UP}]
	_root.set_meta(InteriorFarStandIn.FAR_META, spec)
	var surfaces := _room()
	_detail = MeshInstance3D.new()
	_detail.name = "Detail"
	var detail_mesh := ArrayMesh.new()
	for surface: Dictionary in surfaces:
		detail_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface.arrays)
		detail_mesh.surface_set_material(detail_mesh.get_surface_count() - 1, surface.material)
	_detail.mesh = detail_mesh
	_root.add_child(_detail)
	_far = InteriorFarStandIn.build(_root, surfaces, LAYERS)
	if _far == null:
		failures.append("build() made no stand-in for a spec it can use")
		_finish()
		return
	await _check_build()
	_source = FakeSource.new()
	_source.name = "Source"
	_source.near = false
	_root.add_child(_source)
	_busy = Counter.new()
	_busy.name = "Busy"
	_root.add_child(_busy)
	_root.add_child(_far)
	_switch = InteriorFarStandIn.new()
	_switch.name = "FarSwitch"
	_root.add_child(_switch)
	_camera = Camera3D.new()
	_camera.position = Vector3(-200.0, 1.6, 0.0)
	_root.add_child(_camera)
	root.add_child(_root)
	_camera.make_current()
	await _check_before_play()
	await _check_turns()
	await _check_camera_inside()
	await _check_force()
	await _check_leave()
	await _check_outside_views()
	_finish()


func _check_specs() -> void:
	var zone := (SPEC.zones as Array)[0] as Dictionary
	var wrong := [null, {}, {"near_source": 3, "near_nodes": []}, {"near_source": "Source"}, {"near_source": "Source", "near_nodes": ["Detail"]}, {"near_source": "Source", "near_nodes": ["Detail"], "zones": [], "quads": []}]
	for openings: Variant in [Transform3D.IDENTITY, [AABB()], [Transform3D(Basis.from_scale(Vector3(1.0, 0.0, 1.0)), Vector3.ZERO)]]:
		var spec := SPEC.duplicate(true)
		spec["openings"] = openings
		wrong.append(spec)
	for spec: Variant in wrong:
		if InteriorFarStandIn.spec_problem(spec) == "":
			failures.append("a stand-in spec it cannot use is taken: %s" % [spec])
	if InteriorFarStandIn.spec_problem(SPEC) != "":
		failures.append("the test's spec is refused: %s" % InteriorFarStandIn.spec_problem(SPEC))
	if zone.is_empty():
		failures.append("the test's spec has no zone")


## The detailed room as {"name", "arrays", "material"} surfaces: floor, outer wall (open
## where the spec's opening is), the two end walls, the ceiling, a glowing panel on the
## outer wall, and the sill outside.
func _room() -> Array[Dictionary]:
	var steps := 16
	var quads := {"floor": [], "wall": [], "start": [], "end": [], "ceiling": [], "glow": [], "sill": [], "pier": []}
	for step in steps:
		var a0 := lerpf(-0.5, 0.5, float(step) / steps)
		var a1 := lerpf(-0.5, 0.5, float(step + 1) / steps)
		var mid := (a0 + a1) * 0.5
		var radial := Vector3(cos(mid), 0.0, sin(mid))
		quads.floor.append([[_at(10.0, a0, 0.0), _at(20.0, a0, 0.0), _at(20.0, a1, 0.0), _at(10.0, a1, 0.0)], Vector3.UP])
		quads.ceiling.append([[_at(10.0, a0, 6.0), _at(20.0, a0, 6.0), _at(20.0, a1, 6.0), _at(10.0, a1, 6.0)], Vector3.DOWN])
		quads.wall.append([[_at(20.0, a0, 3.0), _at(20.0, a1, 3.0), _at(20.0, a1, 6.0), _at(20.0, a0, 6.0)], -radial])
	# The wall's lower band in finer steps, open where the piers stand (a step's width
	# clear of them) and below the opening's top.
	var fine := 64
	var clear := PIER_HALF_M / 20.0 + 1.0 / fine
	for step in fine:
		var a0 := lerpf(-0.5, 0.5, float(step) / fine)
		var a1 := lerpf(-0.5, 0.5, float(step + 1) / fine)
		var mid := (a0 + a1) * 0.5
		if PIERS.any(func(pier: float) -> bool: return absf(mid - pier) < clear):
			continue
		if mid > OPENING.x and mid < OPENING.y:
			continue
		quads.wall.append([[_at(20.0, a0, 0.0), _at(20.0, a1, 0.0), _at(20.0, a1, 3.0), _at(20.0, a0, 3.0)], -Vector3(cos(mid), 0.0, sin(mid))])
	for end: int in [0, 1]:
		var a := -0.5 if end == 0 else 0.5
		var into := Vector3(-sin(a), 0.0, cos(a)) * (1.0 if end == 0 else -1.0)
		quads["start" if end == 0 else "end"].append([[_at(10.0, a, 0.0), _at(20.0, a, 0.0), _at(20.0, a, 6.0), _at(10.0, a, 6.0)], into])
	var glow_mid := (GLOW_SPAN.x + GLOW_SPAN.y) * 0.5
	quads.glow.append([[_at(19.9, GLOW_SPAN.x, 2.0), _at(19.9, GLOW_SPAN.y, 2.0), _at(19.9, GLOW_SPAN.y, 4.0), _at(19.9, GLOW_SPAN.x, 4.0)], -Vector3(cos(glow_mid), 0.0, sin(glow_mid))])
	quads.sill.append([[_at(9.5, -0.1, 0.0), _at(10.0, -0.1, 0.0), _at(10.0, 0.1, 0.0), _at(9.5, 0.1, 0.0)], Vector3.UP])
	var half := PIER_HALF_M / 20.0
	for pier in PIERS:
		quads.pier.append([[_at(20.0, pier - half, 0.0), _at(20.0, pier + half, 0.0), _at(20.0, pier + half, 3.0), _at(20.0, pier - half, 3.0)], -Vector3(cos(pier), 0.0, sin(pier))])
	var colours := {"pier": PIER_RGB, "wall": WALL_RGB, "start": START_RGB, "end": END_RGB, "ceiling": CEILING_RGB, "sill": SILL_RGB, "floor": Color(0.9, 0.85, 0.8)}
	var surfaces: Array[Dictionary] = []
	for name: String in quads:
		var made := StandardMaterial3D.new()
		if name == "glow":
			made.emission_enabled = true
			made.emission = Color(1.0, 0.9, 0.6)
		else:
			made.albedo_color = colours[name]
			made.vertex_color_use_as_albedo = true
			made.vertex_color_is_srgb = true
		_materials[name] = made
		surfaces.append({"name": name, "arrays": _arrays(quads[name], name), "material": made})
	return surfaces


func _arrays(quads: Array, name: String) -> Array:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var colours := PackedColorArray()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for quad: Array in quads:
		var corners: Array = quad[0]
		var normal: Vector3 = quad[1]
		var order: Array[int] = [0, 1, 2, 3]
		# Godot's front: clockwise seen from the side the normal points to.
		if ((corners[1] as Vector3) - (corners[0] as Vector3)).cross((corners[2] as Vector3) - (corners[0] as Vector3)).dot(normal) > 0.0:
			order = [0, 3, 2, 1]
		var first := vertices.size()
		for index in order:
			var corner: Vector3 = corners[index]
			vertices.append(corner)
			normals.append(normal)
			colours.append(Color(FLOOR_TINT, FLOOR_TINT, FLOOR_TINT) if name == "floor" else Color.WHITE)
			uvs.append(_polar_uv(corner))
		indices.append_array([first, first + 1, first + 2, first, first + 2, first + 3])
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	if name != "glow":
		arrays[Mesh.ARRAY_COLOR] = colours
	arrays[Mesh.ARRAY_INDEX] = indices
	return arrays


func _check_build() -> void:
	if _far.visible or _far.layers != LAYERS or _far.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF or _far.name != InteriorFarStandIn.FAR_MESH:
		failures.append("the stand-in is not hidden, on the layers given and shadowless, named %s: visible %s, layers %d, shadow %d, name %s" % [InteriorFarStandIn.FAR_MESH, _far.visible, _far.layers, _far.cast_shadow, _far.name])
	var mesh := _far.mesh as ArrayMesh
	var seen := {}
	var middle := _at(15.0, 0.0, 3.0)
	var plain_shaders: Array[Material] = []
	# The lightest face on a pier and the darkest bay face of the lower band.
	var pier_light := -1.0
	var bay_light := 2.0
	for surface in mesh.get_surface_count():
		var name: String = mesh.surface_get_name(surface)
		var material := mesh.surface_get_material(surface)
		var arrays := mesh.surface_get_arrays(surface)
		var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var colours: Variant = arrays[Mesh.ARRAY_COLOR]
		var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		if name == "floor" and material != _materials.floor:
			failures.append("the stand-in's floor is not drawn with the detailed floor's own material")
		elif name == "glow" and material != _materials.glow:
			failures.append("the stand-in's glowing panel is not drawn with its own material")
		elif name == "matte":
			plain_shaders.append(material)
		elif not name in ["floor", "glow", "matte"]:
			failures.append("the stand-in has a surface %s it should not" % name)
		for t in range(0, indices.size(), 3):
			var p0 := points[indices[t]]
			var p1 := points[indices[t + 1]]
			var p2 := points[indices[t + 2]]
			var front := -(p1 - p0).cross(p2 - p0).normalized()
			var centroid := (p0 + p1 + p2) / 3.0
			if front.dot(middle - centroid) <= 0.0:
				failures.append("a %s triangle at %s faces away from the room (front %s)" % [name, centroid, front])
				break
			var polar := _polar(centroid)
			if absf(polar.y - 20.0) < 0.5 and polar.x > OPENING.x and polar.x < OPENING.y and centroid.y < OPENING.z:
				failures.append("a %s triangle at %s stands in the outer wall's opening" % [name, centroid])
			var kind := _kind(front, polar, centroid)
			seen[name + " " + kind] = true
			if name == "floor" and absf(_polar(p0).x - _polar(p1).x) + absf(_polar(p1).x - _polar(p2).x) > 2.0 * (0.25 / FLOOR_SPLIT) + 0.0001:
				failures.append("a floor triangle at %s spans more than a %d-step part of its segment" % [centroid, FLOOR_SPLIT])
			if kind == "outer" and name == "matte" and centroid.y < 3.0 and colours is PackedColorArray:
				var luminance := (colours as PackedColorArray)[indices[t]].get_luminance()
				var on_pier := PIERS.any(func(pier: float) -> bool: return absf(polar.x - pier) < PIER_HALF_M / 20.0)
				if on_pier:
					pier_light = maxf(pier_light, luminance)
				elif not (polar.x > OPENING.x and polar.x < OPENING.y):
					bay_light = minf(bay_light, luminance)
				continue
			if colours is PackedColorArray:
				var colour: Color = (colours as PackedColorArray)[indices[t]]
				var wanted := _wanted(name, kind)
				if wanted.a > 0.0 and (absf(colour.r - wanted.r) > COLOUR_TOLERANCE or absf(colour.g - wanted.g) > COLOUR_TOLERANCE or absf(colour.b - wanted.b) > COLOUR_TOLERANCE):
					failures.append("the stand-in's %s %s at %s is %s, not the detailed %s" % [name, kind, centroid, colour, wanted])
			if name == "floor":
				for index in [indices[t], indices[t + 1], indices[t + 2]]:
					if uvs[index].distance_to(_polar_uv(points[index])) > 0.001:
						failures.append("the stand-in's floor UV %s at %s is not the floor's polar frame %s" % [uvs[index], points[index], _polar_uv(points[index])])
						break
	if pier_light < 0.0 or bay_light > 1.0 or pier_light >= bay_light - 0.1:
		failures.append("the outer wall's lower band is not parted at its piers, darker on them (lightest pier face %.2f, darkest bay face %.2f)" % [pier_light, bay_light])
	for wanted: String in ["floor floor", "matte ceiling", "matte outer", "matte start", "matte end", "matte sill", "glow outer"]:
		if not seen.has(wanted):
			failures.append("the stand-in has no %s face (it has %s)" % [wanted, seen.keys()])
	# No new shader: the stand-in's own material generates a detailed plain surface's
	# (the engine's shader inspector names each; the glow's, another shader, must differ).
	var asked: Array[Material] = []
	asked.append_array(plain_shaders)
	asked.append_array([_materials.wall, _materials.glow])
	var answers := await shaders_of(asked)
	if answers.size() != asked.size() or answers.any(func(shader: RID) -> bool: return not shader.is_valid()):
		failures.append("the shader inspector named %d valid shaders of %d materials" % [answers.filter(func(shader: RID) -> bool: return shader.is_valid()).size(), asked.size()])
	elif plain_shaders.is_empty() or answers[asked.size() - 1] == answers[asked.size() - 2]:
		failures.append("no stand-in material to compare, or the inspector names one shader for the plain wall and the glow")
	else:
		for index in plain_shaders.size():
			if answers[index] != answers[asked.size() - 2]:
				failures.append("the stand-in's own material generates a shader the detailed room does not use")
	print("FAR_STAND_IN built: %d surfaces, faces seen %s" % [mesh.get_surface_count(), seen.keys()])


## The shader the engine generates for each material (Material.inspect_native_shader_code:
## the engine's shader inspector answers a frame later), in order.
func shaders_of(materials: Array[Material]) -> Array[RID]:
	var inspector := Inspector.new()
	root.add_child(inspector)
	inspector.add_to_group(&"_native_shader_source_visualizer")
	for material in materials:
		material.inspect_native_shader_code()
	await process_frame
	await process_frame
	var answers := inspector.answers.duplicate()
	inspector.queue_free()
	return answers


## What a stand-in triangle is, by its front and place: floor, ceiling, outer, start,
## end, sill.
func _kind(front: Vector3, polar: Vector2, at: Vector3) -> String:
	if front.y > 0.6:
		return "sill" if polar.y < 10.0 else "floor"
	if front.y < -0.6:
		return "ceiling"
	var radial := Vector3(cos(polar.x), 0.0, sin(polar.x))
	if front.dot(-radial) > 0.6:
		return "outer"
	return "start" if front.dot(Vector3(-sin(polar.x), 0.0, cos(polar.x))) > 0.0 else "end"


func _wanted(name: String, kind: String) -> Color:
	if name == "floor":
		return Color(FLOOR_TINT, FLOOR_TINT, FLOOR_TINT)
	match kind:
		"outer":
			return WALL_RGB
		"start":
			return START_RGB
		"end":
			return END_RGB
		"ceiling":
			return CEILING_RGB
		"sill":
			return SILL_RGB
	return Color(0, 0, 0, 0)


func _check_before_play() -> void:
	await _frames(5)
	if _switch.switches != 0 or _switch.is_far() or not _detail.visible or _far.visible:
		failures.append("before play started it switched (switches %d, far %s, detail shown %s)" % [_switch.switches, _switch.is_far(), _detail.visible])
	_main.play_ready = true


## Far, near and far again by the source's own turns, each in the frame it turns; the
## near process paused a frame into far and back with near.
func _check_turns() -> void:
	# The source is far: the first frame of play goes far.
	await _frames(2)
	if not _switch.is_far() or _detail.visible or not _far.visible or _switch.switches != 1:
		failures.append("play started with the source far, but it is not far (switches %d, detail shown %s, stand-in shown %s)" % [_switch.switches, _detail.visible, _far.visible])
	await _frames(2)
	if not _switch.is_paused() or _busy.process_mode != Node.PROCESS_MODE_DISABLED:
		failures.append("a frame into far the near process is not paused")
	var counted := _busy.frames
	await _frames(5)
	if _busy.frames != counted:
		failures.append("the paused near process still ran %d frames" % (_busy.frames - counted))
	# The source turns near in its own frame: near in that frame.
	_source.turn_at = _source.frames + 2
	# Back here before the next frame runs: the source turned in the frame just run.
	while _source.frames < _source.turn_at:
		await process_frame
	if _switch.is_far() or not _detail.visible or _far.visible or _switch.is_paused() or _busy.process_mode == Node.PROCESS_MODE_DISABLED:
		failures.append("the source turned near, but in that frame the interior is not near with its process given back (far %s, paused %s)" % [_switch.is_far(), _switch.is_paused()])
	counted = _busy.frames
	await _frames(3)
	if _busy.frames <= counted:
		failures.append("near again, the near process does not run")
	# Turned every frame: one switch a turn.
	var before := _switch.switches
	var turns := 0
	for _i in 12:
		_source.near = not _source.near
		turns += 1
		await _frames(1)
	await _frames(1)
	if _switch.switches - before != turns:
		failures.append("the source turned %d times, the interior switched %d times" % [turns, _switch.switches - before])
	_source.near = true
	await _frames(2)


## The source far: a camera in the plan, or within INSIDE_MARGIN_M of it, keeps the
## interior near from the frame it gets there; beyond, it goes far again.
func _check_camera_inside() -> void:
	_source.near = false
	_camera.position = Vector3(-200.0, 1.6, 0.0)
	await _frames(3)
	if not _switch.is_far():
		failures.append("with the source far and the camera far away, the interior is not far")
	for case: Array in [[15.0, true], [10.0 - InteriorFarStandIn.INSIDE_MARGIN_M * 0.5, true], [10.0 - InteriorFarStandIn.INSIDE_MARGIN_M * 2.0, false], [21.0 + InteriorFarStandIn.INSIDE_MARGIN_M, false], [19.5, true]]:
		_camera.position = _at(float(case[0]), 0.0, 1.6)
		await _frames(1)
		await process_frame
		if _switch.is_far() == bool(case[1]):
			failures.append("with the camera %.2f m from the centre (the plan's radii 10 to 20), the interior is %s" % [float(case[0]), "far" if _switch.is_far() else "near"])
	_camera.position = Vector3(-200.0, 1.6, 0.0)
	await _frames(2)


func _check_force() -> void:
	_source.near = false
	_switch.force = "near"
	await _frames(2)
	if _switch.is_far() or not _detail.visible:
		failures.append("force near, the source far: the interior is not near")
	_source.near = true
	_switch.force = "far"
	await _frames(2)
	if not _switch.is_far() or _detail.visible:
		failures.append("force far, the source near: the interior is not far")
	_switch.force = ""
	await _frames(2)
	if _switch.is_far():
		failures.append("force cleared, the source near: the interior is not near")


func _check_leave() -> void:
	_source.near = false
	await _frames(4)
	if not _switch.is_far() or not _switch.is_paused():
		failures.append("the source far: the interior is not far and paused before leaving the tree")
	root.remove_child(_root)
	if _switch.is_far() or not _detail.visible or _far.visible or _busy.process_mode != Node.PROCESS_MODE_INHERIT:
		failures.append("left the tree while far, the interior is not back as built (far %s, detail shown %s, stand-in shown %s, process mode %d)" % [_switch.is_far(), _detail.visible, _far.visible, _busy.process_mode])
	_root.free()
	_root = null


## The outside views (see the notes above) of every interior with a stand-in in the
## generated world.
func _check_outside_views() -> void:
	var world := InteriorWorld.new(root)
	var looked := 0
	var checked: Array[String] = []
	for unit: Dictionary in InteriorWorld.units_with_passages():
		var source := str(unit.get("anchor_source_key", ""))
		if not world.build_holding(source):
			failures.append("%s lists passages, but no chunk holds its records" % source)
			continue
		for interior: Node3D in world.interiors(source):
			if interior.has_meta(InteriorFarStandIn.FAR_META):
				looked += 1
				var report: String = await _check_outside(world, interior, "%s's interior %s" % [source, interior.name])
				if report != "":
					checked.append(report)
	failures.append_array(world.errors)
	world.free_parents()
	if looked == 0:
		failures.append("outside views: no interior with a far stand-in was looked at in the generated world")
	elif not checked.is_empty():
		print("OUTSIDE_VIEWS %s" % "; ".join(checked))


## One interior's outside views, far and then near: a summary, or "" when it fails.
func _check_outside(world: InteriorWorld, interior: Node3D, label: String) -> String:
	var before := failures.size()
	var spec: Dictionary = interior.get_meta(InteriorFarStandIn.FAR_META)
	var switch: InteriorFarStandIn = null
	for child: Node in interior.get_children():
		if child is InteriorFarStandIn:
			switch = child
	var stand_in := interior.get_node_or_null(InteriorFarStandIn.FAR_MESH) as GeometryInstance3D
	var openings: Array[Transform3D] = []
	for box: Variant in spec.get("openings", []):
		openings.append(interior.global_transform * (box as Transform3D))
	if switch == null or stand_in == null or openings.is_empty():
		failures.append("%s: outside views need its FarSwitch, its %s mesh and its spec's openings (has %s, %s, %d)" % [label, InteriorFarStandIn.FAR_MESH, switch != null, stand_in != null, openings.size()])
		return ""
	var bounds := AABB()
	for node: Node in interior.find_children("*", "GeometryInstance3D", true, false):
		var instance := node as GeometryInstance3D
		if instance.layers & stand_in.layers != 0:
			var box := instance.global_transform * instance.get_aabb()
			bounds = box if bounds.size == Vector3.ZERO else bounds.merge(box)
	world.build_under(Vector2(bounds.position.x, bounds.position.z) - Vector2.ONE * VIEW_DISTANCES_M[0], Vector2(bounds.end.x, bounds.end.z) + Vector2.ONE * VIEW_DISTANCES_M[0])
	var summary: Array[String] = []
	for state: String in ["far", "near"]:
		switch.force = state
		await _frames(2)
		if switch.is_far() != (state == "far"):
			failures.append("%s: forced %s, its switch is not" % [label, state])
			continue
		var drawn := _drawn(stand_in.layers, label)
		if int(drawn.hiding) == 0 or (drawn.points as PackedVector3Array).is_empty():
			failures.append("%s, %s: nothing to look at (%d points) or nothing to hide it (%d triangles)" % [label, state, (drawn.points as PackedVector3Array).size(), drawn.hiding])
			continue
		var viewpoints := _viewpoints(bounds, openings, drawn.hide as TriangleMesh, drawn.sides as PackedVector3Array)
		summary.append("%s %s" % [state, _look(drawn, viewpoints, openings, "%s, %s" % [label, state])])
	switch.force = ""
	if failures.size() > before:
		return ""
	return "%s: %s" % [label, ", ".join(summary)]


## What is drawn now under the root: every visible mesh and multimesh instance's
## triangles in world space, by the shared collector (indexed arrays, or the vertices in
## order for a surface without indices, as Mesh.get_faces() reads them), with the side
## each shows (Godot's front by its clockwise winding, turned by a mirroring pose; the
## back for cull_front; both, as a zero vector, for cull_disabled). On the layers given:
## "points" over each triangle to look at, with the side it shows and its instance's
## path ("owners"). Elsewhere: "hide", what hides them, with each triangle's side
## ("sides"), but for surfaces that can be seen through, which hide nothing.
func _drawn(layers: int, label: String) -> Dictionary:
	var hide_faces := PackedVector3Array()
	var sides := PackedVector3Array()
	var points := PackedVector3Array()
	var point_sides := PackedVector3Array()
	var point_owners := PackedInt32Array()
	var owners: Array[String] = []
	var taken := {}
	for node: Node in root.find_children("*", "GeometryInstance3D", true, false):
		var instance := node as GeometryInstance3D
		if not instance.is_visible_in_tree():
			continue
		var mesh: Mesh = null
		var poses: Array[Transform3D] = []
		if instance is MeshInstance3D:
			mesh = (instance as MeshInstance3D).mesh
			poses.append(instance.global_transform)
		elif instance is MultiMeshInstance3D and (instance as MultiMeshInstance3D).multimesh != null:
			var multimesh := (instance as MultiMeshInstance3D).multimesh
			mesh = multimesh.mesh
			var count := multimesh.instance_count if multimesh.visible_instance_count < 0 else multimesh.visible_instance_count
			for index in count:
				poses.append(instance.global_transform * multimesh.get_instance_transform(index))
		if mesh == null or poses.is_empty():
			continue
		var looked_at := instance.layers & layers != 0
		var owner := owners.size()
		if looked_at:
			owners.append(str(instance.get_path()))
		for surface in mesh.get_surface_count():
			var material := instance.material_override
			if material == null:
				material = (instance as MeshInstance3D).get_active_material(surface) if instance is MeshInstance3D else mesh.surface_get_material(surface)
			var cull := StudyGeometry.roof_cull_mode(material)
			if not bool(cull.ok) and not looked_at:
				continue
			var mode := int(cull.get("mode", BaseMaterial3D.CULL_DISABLED))
			var primitive := (mesh as ArrayMesh).surface_get_primitive_type(surface) if mesh is ArrayMesh else Mesh.PRIMITIVE_TRIANGLES
			var arrays := mesh.surface_get_arrays(surface)
			var vertices: Variant = arrays[Mesh.ARRAY_VERTEX]
			if primitive != Mesh.PRIMITIVE_TRIANGLES or not vertices is PackedVector3Array or (vertices as PackedVector3Array).is_empty():
				if looked_at and primitive != Mesh.PRIMITIVE_TRIANGLES:
					failures.append("%s: %s's surface %d is not drawn as triangles, so it can't be looked at" % [label, instance.get_path(), surface])
				continue
			var single := ArrayMesh.new()
			single.add_surface_from_arrays(primitive, arrays)
			var producer := StudyGeometry.INDEXED_ARRAYS if arrays[Mesh.ARRAY_INDEX] is PackedInt32Array and not (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).is_empty() else StudyGeometry.MESH_GET_FACES
			var collected := StudyGeometry.collect(single, poses, producer)
			if not bool(collected.ok):
				if not (collected.errors as Array).is_empty():
					failures.append("%s: %s's surface %d can't be read: %s" % [label, instance.get_path(), surface, str(collected.errors)])
				continue
			var faces: PackedVector3Array = collected.faces
			var per_pose := (collected.local_faces as PackedVector3Array).size() / 3
			for t in faces.size() / 3:
				var a := faces[t * 3]
				var b := faces[t * 3 + 1]
				var c := faces[t * 3 + 2]
				var side := (c - a).cross(b - a).normalized()
				if poses[t / per_pose].basis.determinant() < 0.0:
					side = -side
				if mode == BaseMaterial3D.CULL_FRONT:
					side = -side
				elif mode == BaseMaterial3D.CULL_DISABLED:
					side = Vector3.ZERO
				if not looked_at:
					hide_faces.append_array(PackedVector3Array([a, b, c]))
					sides.append(side)
					continue
				var middle := (a + b + c) / 3.0
				var across := ceili(maxf(a.distance_to(b), maxf(b.distance_to(c), c.distance_to(a))) / SAMPLE_M)
				var spots: Array[Vector3] = [middle, a.lerp(middle, CORNER_INSET), b.lerp(middle, CORNER_INSET), c.lerp(middle, CORNER_INSET)]
				if across > 1:
					for i in across + 1:
						for j in across + 1 - i:
							spots.append(a + (b - a) * (float(i) / across) + (c - a) * (float(j) / across))
				var axis := side.abs().max_axis_index()
				var facing := 6 if side == Vector3.ZERO else axis * 2 + (1 if side[axis] < 0.0 else 0)
				for spot in spots:
					var cell := Vector4i(floori(spot.x / SAMPLE_M), floori(spot.y / SAMPLE_M), floori(spot.z / SAMPLE_M), owner * 8 + facing)
					if taken.has(cell):
						continue
					taken[cell] = true
					points.append(spot)
					point_sides.append(side)
					point_owners.append(owner)
	var hide := TriangleMesh.new()
	if not hide_faces.is_empty():
		hide.create_from_faces(hide_faces)
	return {"hide": hide, "sides": sides, "points": points, "point_sides": point_sides, "point_owners": point_owners, "owners": owners, "hiding": hide_faces.size() / 3}


## Viewpoints round the bounds (see the constants), less those shut in: under something
## of the hiding surfaces facing up.
func _viewpoints(bounds: AABB, openings: Array[Transform3D], hide: TriangleMesh, sides: PackedVector3Array) -> Array[Vector3]:
	var centre := bounds.get_center()
	var reach := Vector2(bounds.size.x, bounds.size.z).length() * 0.5
	var all: Array[Vector3] = []
	for k in VIEW_AZIMUTHS:
		var way := Vector3(cos(TAU * k / VIEW_AZIMUTHS), 0.0, sin(TAU * k / VIEW_AZIMUTHS))
		for distance in VIEW_DISTANCES_M:
			var at := centre + way * (reach + distance)
			all.append(Vector3(at.x, bounds.position.y + EYE_M, at.z))
			for height in VIEW_HEIGHTS_M:
				all.append(Vector3(at.x, bounds.end.y + height, at.z))
	for height in OVERHEAD_M:
		for offset: Vector2 in [Vector2.ZERO, Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)]:
			all.append(Vector3(centre.x + offset.x * reach * 0.5, bounds.end.y + height, centre.z + offset.y * reach * 0.5))
	for box in openings:
		var out := Vector3(box.origin.x - centre.x, 0.0, box.origin.z - centre.z).normalized()
		for view in OPENING_VIEWS_M:
			all.append(box.origin + out * view.x + Vector3.UP * view.y)
	var open: Array[Vector3] = []
	for at in all:
		var above := hide.intersect_ray(at, Vector3.UP)
		if above.is_empty() or sides[int(above.face_index)].y <= 0.0:
			open.append(at)
	return open


## Looks at every point from every viewpoint: a point whose side faces the viewpoint and
## that nothing hides from it must be seen through an opening. A summary for the PASS
## line; failures with their operands.
func _look(drawn: Dictionary, viewpoints: Array[Vector3], openings: Array[Transform3D], label: String) -> String:
	var hide := drawn.hide as TriangleMesh
	var sides: PackedVector3Array = drawn.sides
	var points: PackedVector3Array = drawn.points
	var point_sides: PackedVector3Array = drawn.point_sides
	var point_owners: PackedInt32Array = drawn.point_owners
	var owners: Array[String] = drawn.owners
	var inverses: Array[Transform3D] = []
	for box in openings:
		inverses.append(box.affine_inverse())
	var through := 0
	var leaks := 0
	var leaking := {}
	var examples: Array[String] = []
	for at in viewpoints:
		for index in points.size():
			var point := points[index]
			var side := point_sides[index]
			if side != Vector3.ZERO and side.dot(at - point) <= 0.0:
				continue
			var way := (point - at).normalized()
			var end := point - way * SIGHT_END_M
			if _hidden(hide, sides, at, end, way):
				continue
			if inverses.any(func(inverse: Transform3D) -> bool: return _crosses_box(inverse * at, inverse * point)):
				through += 1
				continue
			var across := way.cross(Vector3.UP if absf(way.y) < 0.9 else Vector3.RIGHT).normalized()
			var spread: Array[Vector3] = [across, -across, way.cross(across), -way.cross(across)]
			if spread.any(func(offset: Vector3) -> bool: return _hidden(hide, sides, at, end + offset * SPREAD_M, way)):
				continue
			leaks += 1
			leaking[index] = true
			if examples.size() < EXAMPLES:
				examples.append("%s at %s (side %s) from %s" % [owners[point_owners[index]], point, side, at])
	if leaks > 0:
		failures.append("%s: drawn on the interior's layer and seen from outside other than through its openings at %d of %d points (%d sight lines), as %s" % [label, leaking.size(), points.size(), leaks, "; ".join(examples)])
	elif through == 0:
		failures.append("%s: from %d viewpoints nothing of it is seen through its openings, so the views prove nothing" % [label, viewpoints.size()])
	return "%d points from %d viewpoints, %d sight lines through its openings and none elsewhere" % [points.size(), viewpoints.size(), through]


## Whether a hiding face lies on the segment, met on the side it shows (or two-sided).
func _hidden(hide: TriangleMesh, sides: PackedVector3Array, from: Vector3, to: Vector3, way: Vector3) -> bool:
	var at := from
	for _pass in MAX_PASSES:
		var hit := hide.intersect_segment(at, to)
		if hit.is_empty():
			return false
		var side := sides[int(hit.face_index)]
		if side == Vector3.ZERO or side.dot(way) < 0.0:
			return true
		at = (hit.position as Vector3) + way * PASS_M
		if (to - at).dot(way) <= 0.0:
			return false
	return false


## Whether the segment from a to b (in a box's frame) crosses the cube from -1 to 1.
static func _crosses_box(a: Vector3, b: Vector3) -> bool:
	var enter := 0.0
	var leave := 1.0
	var d := b - a
	for axis in 3:
		if absf(d[axis]) < 1e-12:
			if absf(a[axis]) > 1.0:
				return false
			continue
		var t0 := (-1.0 - a[axis]) / d[axis]
		var t1 := (1.0 - a[axis]) / d[axis]
		enter = maxf(enter, minf(t0, t1))
		leave = minf(leave, maxf(t0, t1))
		if enter > leave:
			return false
	return true


func _frames(count: int) -> void:
	for _i in count:
		await process_frame


func _at(r: float, angle: float, y: float) -> Vector3:
	return Vector3(r * cos(angle), y, r * sin(angle))


## (angle, radius) about the plan's centre.
func _polar(at: Vector3) -> Vector2:
	return Vector2(atan2(at.z, at.x), Vector2(at.x, at.z).length())


func _polar_uv(at: Vector3) -> Vector2:
	var polar := _polar(at)
	return Vector2((polar.x + 0.5) / 1.0, (polar.y - 10.0) / 10.0)


func _finish() -> void:
	if is_instance_valid(_root):
		_root.queue_free()
	if is_instance_valid(_main):
		_main.queue_free()
	if failures.is_empty():
		print("PASS: InteriorFarStandIn: specs it cannot use refused; the stand-in hidden, shadowless, every face facing in with the detailed colour over it, the floor in its own material and polar UVs, the glow kept, its own faces in a detailed surface's shader, the opening open; nothing switched before play; far and near in the frame the source turns, one switch a turn, the near process paused a frame into far and given back with near; near with the camera in or by the plan; force held; back as built leaving the tree; from outside, far and near alike seen only through the openings")
		quit(0)
		return
	for message in failures:
		print("FAIL: " + message)
	quit(1)
