class_name ShaderWarmUp
extends Node3D
## The shaders play may draw, compiled behind the loading screen before play starts
## (owner, 2026-11-17: "find a mechanical way to find all shaders before the game
## starts and compile them"). The web build's renderer, Godot 4.7.2's Compatibility
## on WebGL, compiles a shader's programs the first time something is drawn with it:
## at the shader's first draw the default program of each of its four variants
## (ShaderGLES3::_initialize_version), then the one the draw needs, which depends on
## how the thing is drawn (RasterizerSceneGLES3::_render_list_template): as one mesh
## or as instances (a MultiMesh, CPU particles), in the depth pre-pass or the colour
## pass, and inside the box of one reflection probe that reflects on its render
## layers, two, or none. Whatever loading had not drawn that way was compiled in
## play, a hitch at a time: the drive trace (game/scripts/debug/drive_trace.gd,
## 2026-11-17) counted 163 programs of 18 shaders on one drive round the island,
## every hitch of the drive in WebKit and Chrome alike.
##
## find() walks every GeometryInstance3D under main, shown or hidden, near or far,
## and takes every material a script registered that it makes while the island loads
## but draws only in play (add): a mesh's surface materials (its override, a surface
## override or the mesh's own; none is Godot's default material), its overlay and
## each one's next pass; a MultiMesh's and CPU particles' drawn as instances; a
## Label3D's by the flags its own material is made from (no property exposes it).
## One entry a shader: a ShaderMaterial's Shader, a BaseMaterial3D's generated
## shader (which the engine's shader inspector names a frame later: resolve), a
## Label3D flag set or the default material; with each way it is drawn (a use: in
## how many probes' boxes, as instances or not, in the shadow pass only or not).
## A node that moves (under a moving body) and a registered material may be drawn
## inside any probe that reflects on its layers, so it gets those uses too.
##
## build() makes a tiny proxy for each entry's use: those drawn outside the probes
## in batches that main's loading screen shows one frame each in front of the spawn
## camera (main.gd compile_plan), the others at stops inside the probes' boxes that
## probe_pass() shows a camera of its own, once the probes have their images. Main
## frees it all before play, so nothing of it is left in the tree.

const INSPECTOR_GROUP := &"_native_shader_source_visualizer"
## Shader entries in one batch: one frame of the loading screen draws a batch.
const PER_BATCH := 48
## A proxy's size, the grid's spacing and columns, and how far in front of the
## camera it stands (m): small, all in view, past the near plane.
const PROXY_M := 0.02
const SPACING_M := 0.03
const COLUMNS := 24
const DISTANCE_M := 1.2
## The world's visible render layer (as the builders' RENDER_WORLD_VISIBLE).
const RENDER_WORLD_VISIBLE := 1
## How far the probe pass's camera sees (m): its proxies, not the island.
const PROBE_CAMERA_FAR_M := 30.0

## Materials registered by scripts that make them while the island loads and draw
## them only in play (add): [WeakRef, instanced, render layers], oldest first.
static var _registered: Array = []
## One Shader for each distinct code (shared_shader).
static var _shared_shaders: Dictionary = {}

## One entry a shader: {"key": String, "kind": "shader", "generated", "label" or
## "default", "material": a material drawn with it (null for a Label3D's and the
## default), "label": a Label3D's flags ({} otherwise), "uses": {use key: render
## layers}, "users": how many nodes and registrations draw it}. A use key is
## "PROBES INSTANCED SHADOW_ONLY", as 0 or 1 each (probes up to 2).
var entries: Array[Dictionary] = []
## Drawables of a kind this does not proxy, by class: {class name: count}.
var unhandled: Dictionary = {}
## How many materials came from the registry.
var registered_count := 0
## The batches compile_plan shows a frame each, in front of the spawn camera.
var batches: Array[Node3D] = []
## The probe pass's stops: {"point": Vector3 (inside the boxes), "proxies": Node3D}.
var stops: Array[Dictionary] = []
var _by_key: Dictionary = {}
## The reflection probes' boxes and masks: [{"box": AABB, "mask": int}].
var _probes: Array[Dictionary] = []
## BaseMaterial3Ds in the order asked of the inspector, each one's uses, and its
## answers (shader RIDs), in that same order.
var _asked: Array[BaseMaterial3D] = []
var _asked_uses: Dictionary = {}
var _answers: Array[RID] = []
var _camera: Camera3D


## Registers a material a script makes while the island loads but draws only in play
## (a felled lamp's debris, a splash's spray): drawn as instances (a MultiMesh, CPU
## particles) or not, on these render layers. Call it as the material is made.
static func add(material: Material, instanced: bool, layers := RENDER_WORLD_VISIBLE) -> void:
	if material == null:
		return
	for item: Array in _registered:
		if (item[0] as WeakRef).get_ref() == material and item[1] == instanced and item[2] == layers:
			return
	_registered.append([weakref(material), instanced, layers])


## Registers each surface material of a mesh drawn only in play (add).
static func add_mesh(mesh: Mesh, instanced: bool, layers := RENDER_WORLD_VISIBLE) -> void:
	if mesh == null:
		return
	for surface in mesh.get_surface_count():
		add(mesh.surface_get_material(surface), instanced, layers)


## The registered materials still in use: [[material, instanced, layers], ...].
static func registered() -> Array:
	var live: Array = []
	var materials: Array = []
	for item: Array in _registered:
		var material: Variant = (item[0] as WeakRef).get_ref()
		if material != null:
			live.append(item)
			materials.append([material, item[1], item[2]])
	_registered = live
	return materials


## One Shader for each distinct code, shared: two Shader resources with the same code
## are two shaders to the renderer, each compiling its own programs (Mersea's glazing
## made one a window bay, nine in all).
static func shared_shader(code: String) -> Shader:
	var shader: Shader = _shared_shaders.get(code)
	if shader == null:
		shader = Shader.new()
		shader.code = code
		_shared_shaders[code] = shader
	return shader


## Takes what root draws and what scripts registered, with the reflection probes'
## boxes. A BaseMaterial3D's shader is known only once the inspector has answered,
## a frame later: then call resolve().
func find(root: Node, probes: Array) -> void:
	_probes.clear()
	for node: Variant in probes:
		var probe := node as ReflectionProbe
		if probe != null and is_instance_valid(probe):
			_probes.append({"box": probe.global_transform * probe.get_aabb(), "mask": probe.reflection_mask})
	add_to_group(INSPECTOR_GROUP)
	for node: Node in root.find_children("*", "GeometryInstance3D", true, false):
		if not is_ancestor_of(node):
			_take(node as GeometryInstance3D)
	for item: Array in registered():
		registered_count += 1
		_add_uses(item[0], _moving_uses(bool(item[1]), int(item[2]), false))
	for material: BaseMaterial3D in _asked:
		material.inspect_native_shader_code()


## The engine's shader inspector's answer (Material.inspect_native_shader_code): a
## BaseMaterial3D's shader, in the order asked.
func _inspect_shader(shader: RID) -> void:
	_answers.append(shader)


## Files each BaseMaterial3D under its generated shader, once the inspector has
## answered (a frame after find). Should an answer be missing, each material asked
## is its own entry: more proxies, none missed.
func resolve() -> void:
	remove_from_group(INSPECTOR_GROUP)
	var matched := _answers.size() == _asked.size()
	if not matched:
		push_warning("ShaderWarmUp: the shader inspector answered %d of %d materials; each is warmed on its own." % [_answers.size(), _asked.size()])
	for index in _asked.size():
		var material := _asked[index]
		var key := "generated %d" % _answers[index].get_id() if matched else "material %d" % material.get_instance_id()
		_note(key, "generated", material, {}, _asked_uses[material])
	_asked.clear()
	_asked_uses.clear()
	_answers.clear()


func _take(geometry: GeometryInstance3D) -> void:
	var moves := _moves(geometry)
	var shadow_only := geometry.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	var uses: Dictionary = _moving_uses(false, geometry.layers, shadow_only) if moves else _placed_uses(geometry, false, shadow_only)
	var mesh: Mesh = null
	if geometry is Label3D:
		if geometry.material_override == null:
			var label := geometry as Label3D
			var flags := label_flags(label)
			_note("label %s" % str(flags.values()), "label", null, flags, uses)
		mesh = null
	elif geometry is MeshInstance3D:
		mesh = (geometry as MeshInstance3D).mesh
	elif geometry is MultiMeshInstance3D:
		var multimesh := (geometry as MultiMeshInstance3D).multimesh
		mesh = multimesh.mesh if multimesh != null else null
		uses = _moving_uses(true, geometry.layers, shadow_only) if moves else _placed_uses(geometry, true, shadow_only)
	elif geometry is CPUParticles3D:
		mesh = (geometry as CPUParticles3D).mesh
		uses = _moving_uses(true, geometry.layers, shadow_only) if moves else _placed_uses(geometry, true, shadow_only)
	else:
		unhandled[geometry.get_class()] = int(unhandled.get(geometry.get_class(), 0)) + 1
		return
	var used: Array = []
	if geometry is Label3D:
		if geometry.material_override != null:
			used.append(geometry.material_override)
	elif mesh != null and mesh.get_surface_count() > 0:
		if geometry.material_override != null:
			used.append(geometry.material_override)
		else:
			for surface in mesh.get_surface_count():
				var material: Material = (geometry as MeshInstance3D).get_surface_override_material(surface) if geometry is MeshInstance3D else null
				used.append(material if material != null else mesh.surface_get_material(surface))
	if geometry.material_overlay != null and (geometry is Label3D or (mesh != null and mesh.get_surface_count() > 0)):
		used.append(geometry.material_overlay)
	for first: Variant in used:
		_add_uses(first, uses)


## A material and its next passes, each with these uses (none: the default material).
func _add_uses(first: Variant, uses: Dictionary) -> void:
	if first == null:
		_note("default", "default", null, {}, uses)
		return
	var material := first as Material
	var depth := 0
	while material != null and depth < 8:
		if material is BaseMaterial3D:
			var base := material as BaseMaterial3D
			if not _asked_uses.has(base):
				_asked.append(base)
				_asked_uses[base] = {}
			_merge(_asked_uses[base], uses)
		elif material is ShaderMaterial:
			var shader := (material as ShaderMaterial).shader
			if shader != null:
				_note("shader %d" % shader.get_instance_id(), "shader", material, {}, uses)
			else:
				# Without a shader it draws with the default material.
				_note("default", "default", null, {}, uses)
		else:
			unhandled[material.get_class()] = int(unhandled.get(material.get_class(), 0)) + 1
		material = material.next_pass
		depth += 1


func _note(key: String, kind: String, material: Material, label: Dictionary, uses: Dictionary) -> void:
	var entry: Dictionary = _by_key.get(key, {})
	if entry.is_empty():
		entry = {"key": key, "kind": kind, "material": material, "label": label, "uses": {}, "users": 0}
		_by_key[key] = entry
		entries.append(entry)
	entry.users += 1
	_merge(entry.uses, uses)


static func _merge(into: Dictionary, uses: Dictionary) -> void:
	for use: String in uses:
		if not into.has(use):
			into[use] = uses[use]


static func _use_key(probes: int, instanced: bool, shadow_only: bool) -> String:
	return "%d %d %d" % [probes, int(instanced), int(shadow_only)]


## A node that stays where it is: drawn inside as many probes as reflect on its
## layers and whose boxes its own box meets (at most two count).
func _placed_uses(geometry: GeometryInstance3D, instanced: bool, shadow_only: bool) -> Dictionary:
	var box := geometry.global_transform * geometry.get_aabb()
	var inside := 0
	for probe: Dictionary in _probes:
		if (int(probe.mask) & geometry.layers) != 0 and (probe.box as AABB).intersects(box):
			inside += 1
	return {_use_key(mini(inside, 2), instanced, shadow_only): geometry.layers}


## A node that moves, or a registered material: drawn outside the probes and inside
## any probe, or two that meet, that reflects on its layers.
func _moving_uses(instanced: bool, layers: int, shadow_only: bool) -> Dictionary:
	var uses := {_use_key(0, instanced, shadow_only): layers}
	var matching: Array[AABB] = []
	for probe: Dictionary in _probes:
		if (int(probe.mask) & layers) != 0:
			matching.append(probe.box)
	if not matching.is_empty():
		uses[_use_key(1, instanced, shadow_only)] = layers
	for a in matching.size():
		for b in range(a + 1, matching.size()):
			if matching[a].intersects(matching[b]):
				uses[_use_key(2, instanced, shadow_only)] = layers
	return uses


## Whether a node rides on something that moves: a rigid, character or animatable
## body (a car, the player, the ball, debris).
func _moves(node: Node) -> bool:
	var at := node.get_parent()
	while at != null:
		if at is AnimatableBody3D or (at is PhysicsBody3D and not at is StaticBody3D):
			return true
		at = at.get_parent()
	return false


## The flags a Label3D's own material is made from (Label3D._generate_glyph_surfaces:
## StandardMaterial3D.get_material_for_2d), and its font (whose kind can change it).
static func label_flags(label: Label3D) -> Dictionary:
	return {
		"shaded": label.shaded, "double_sided": label.double_sided, "no_depth_test": label.no_depth_test,
		"fixed_size": label.fixed_size, "billboard": label.billboard, "alpha_cut": label.alpha_cut,
		"alpha_antialiasing_mode": label.alpha_antialiasing_mode, "texture_filter": label.texture_filter,
		"font": label.font.get_instance_id() if label.font != null else 0,
	}


## Makes the proxies: the uses outside the probes in batches of PER_BATCH entries in
## front of camera (main's loading screen hides them and shows them a batch a
## frame); those inside at a stop for each place the probe pass visits, hidden.
func build(camera: Camera3D) -> void:
	var outside: Array = []
	var inside := {}
	for entry: Dictionary in entries:
		var here: Array = []
		for use: String in entry.uses:
			var parts := use.split(" ")
			var probes := int(parts[0])
			var item := [entry, parts[1] == "1", parts[2] == "1", int(entry.uses[use])]
			if probes == 0:
				here.append(item)
				continue
			var point: Variant = _point_inside(probes, int(entry.uses[use]))
			if point == null:
				continue
			var at := str(point)
			if not inside.has(at):
				inside[at] = {"point": point, "items": []}
			(inside[at].items as Array).append(item)
		if not here.is_empty():
			outside.append(here)
	var front := camera.global_transform * Transform3D(Basis.IDENTITY, Vector3(0.0, -0.1, -DISTANCE_M))
	for start in range(0, outside.size(), PER_BATCH):
		var items: Array = []
		for here: Array in outside.slice(start, start + PER_BATCH):
			items.append_array(here)
		# Shown: the loading screen hides each step's nodes until its frame.
		var batch := _grid("Batch%d" % batches.size(), items, true)
		batch.global_transform = front
		batches.append(batch)
	for at: String in inside:
		var stop: Dictionary = inside[at]
		var proxies := _grid("Probe%d" % stops.size(), stop.items, false)
		proxies.global_transform = Transform3D(Basis.IDENTITY, stop.point)
		stops.append({"point": stop.point, "proxies": proxies})


## A grid of proxies facing +Z (toward the camera behind it), as a child.
func _grid(node_name: String, items: Array, shown: bool) -> Node3D:
	var grid := Node3D.new()
	grid.name = node_name
	grid.visible = shown
	add_child(grid)
	var rows := ceili(float(items.size()) / COLUMNS)
	for index in items.size():
		var item: Array = items[index]
		var proxy := _proxy(item[0], item[1], item[2], item[3])
		proxy.position = Vector3((index % COLUMNS - (COLUMNS - 1) * 0.5) * SPACING_M, ((rows - 1) * 0.5 - index / COLUMNS) * SPACING_M, 0.0)
		grid.add_child(proxy)
	return grid


## A proxy drawing an entry one way: a tiny quad with its material (or a "." with a
## Label3D's flags), as a mesh or a one-instance MultiMesh, on the user's layers.
func _proxy(entry: Dictionary, instanced: bool, shadow_only: bool, layers: int) -> GeometryInstance3D:
	var node: GeometryInstance3D
	if entry.kind == "label":
		var label := Label3D.new()
		var flags: Dictionary = entry.label
		label.text = "."
		label.font_size = 16
		label.pixel_size = 0.001
		label.outline_size = 0
		label.shaded = flags.shaded
		label.double_sided = flags.double_sided
		label.no_depth_test = flags.no_depth_test
		label.fixed_size = flags.fixed_size
		label.billboard = flags.billboard
		label.alpha_cut = flags.alpha_cut
		label.alpha_antialiasing_mode = flags.alpha_antialiasing_mode
		label.texture_filter = flags.texture_filter
		if int(flags.font) != 0:
			label.font = instance_from_id(int(flags.font)) as Font
		node = label
	else:
		var quad := QuadMesh.new()
		quad.size = Vector2(PROXY_M, PROXY_M)
		if instanced:
			var multimesh := MultiMesh.new()
			multimesh.transform_format = MultiMesh.TRANSFORM_3D
			multimesh.use_colors = true
			multimesh.use_custom_data = true
			multimesh.mesh = quad
			multimesh.instance_count = 1
			multimesh.set_instance_transform(0, Transform3D.IDENTITY)
			var instances := MultiMeshInstance3D.new()
			instances.multimesh = multimesh
			node = instances
		else:
			var mesh := MeshInstance3D.new()
			mesh.mesh = quad
			node = mesh
		node.material_override = entry.material
	node.layers = layers
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY if shadow_only else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node


## A point inside exactly this many of the probes that reflect on these layers (one,
## or two whose boxes meet), far enough in that the grid stays inside; null if none.
func _point_inside(count: int, layers: int) -> Variant:
	var boxes: Array[AABB] = []
	for probe: Dictionary in _probes:
		if (int(probe.mask) & layers) != 0:
			boxes.append(probe.box)
	var candidates: Array[AABB] = []
	if count == 1:
		candidates.assign(boxes)
	else:
		for a in boxes.size():
			for b in range(a + 1, boxes.size()):
				if boxes[a].intersects(boxes[b]):
					candidates.append(boxes[a].intersection(boxes[b]))
	var reach := Vector3.ONE * (COLUMNS * SPACING_M)
	for candidate: AABB in candidates:
		# Its middle, then toward each face, for a box another one overlaps there.
		var points: Array[Vector3] = [candidate.get_center()]
		for axis in 3:
			for side: float in [-0.35, 0.35]:
				var offset := Vector3.ZERO
				offset[axis] = candidate.size[axis] * side
				points.append(candidate.get_center() + offset)
		for point: Vector3 in points:
			var grid := AABB(point - reach * 0.5, reach)
			var touching := 0
			var holding := 0
			for box: AABB in boxes:
				touching += int(box.intersects(grid))
				holding += int(box.encloses(grid))
			if touching == count and holding == count:
				return point
	return null


## Shows each stop's proxies to a camera of the warm-up's own, a frame a stop, and
## gives the view back to restore. Call once the probes have their images (an
## instance counts a probe only then: RasterizerSceneGLES3::_fill_render_list).
func probe_pass(restore: Camera3D) -> void:
	if stops.is_empty():
		return
	_camera = Camera3D.new()
	_camera.name = "ProbeCamera"
	_camera.far = PROBE_CAMERA_FAR_M
	add_child(_camera)
	for stop: Dictionary in stops:
		if not is_inside_tree():
			return
		_camera.global_transform = Transform3D(Basis.IDENTITY, (stop.point as Vector3) + Vector3(0.0, 0.0, DISTANCE_M))
		_camera.make_current()
		(stop.proxies as Node3D).visible = true
		await get_tree().process_frame
		if not is_inside_tree():
			return
		(stop.proxies as Node3D).visible = false
	if is_instance_valid(restore):
		restore.make_current()


## What was found, for the loading log and the tests: entries by kind, uses by kind,
## the registry, proxies, batches and stops, and any kind left out.
func summary() -> Dictionary:
	var kinds := {}
	var uses := {"plain": 0, "instanced": 0, "probe": 0, "shadow_only": 0}
	var proxies := 0
	for entry: Dictionary in entries:
		kinds[entry.kind] = int(kinds.get(entry.kind, 0)) + 1
		for use: String in entry.uses:
			var parts := use.split(" ")
			uses["instanced" if parts[1] == "1" else "plain"] += 1
			uses.probe += int(parts[0] != "0")
			uses.shadow_only += int(parts[2] == "1")
	for batch: Node3D in batches:
		proxies += batch.get_child_count()
	for stop: Dictionary in stops:
		proxies += (stop.proxies as Node3D).get_child_count()
	return {"shaders": entries.size(), "kinds": kinds, "uses": uses, "registered": registered_count, "proxies": proxies, "batches": batches.size(), "stops": stops.size(), "unhandled": unhandled}
