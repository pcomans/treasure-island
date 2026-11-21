extends SceneTree
## The shader warm-up (game/scripts/world/shader_warm_up.gd, main.gd
## _compile_by_group), headless: the island loaded as the web build loads it (the
## shaders a group at a time), and then:
##   - every shader anything under main can draw, as a mesh or as instances, inside
##     no reflection probe's box or one or two that reflect on its layers (the ways
##     Godot's Compatibility renderer compiles a program apart: a placed node by its
##     own box, a moving one as it may go), and every material registered by a
##     script that draws only in play, has a proxy drawing it that way: a
##     ShaderMaterial's Shader, a BaseMaterial3D's generated shader (both named by
##     the engine's shader inspector, as this test asks it itself), a Label3D's flag
##     set, the default material; and no drawable is of a kind it leaves out;
##   - no two Shader resources under main have the same code (each is a shader of its
##     own to the renderer, compiling its own programs);
##   - each script that makes materials, shaders or drawables is classified: it
##     registers what it draws only in play (a ShaderWarmUp.add call, not a comment),
##     or CLASSIFIED says why it need not, by folder, by file or by function (a new
##     kind of runtime effect fails here until it says), and no file classified by
##     folder or file makes one inside a callback Godot calls in play;
##   - after play starts, what the runtime effects draw (a fence bay broken, a street
##     prop felled, a car's splash, goal confetti, a live car) uses only shaders the
##     warm-up drew that way;
##   - nothing of it is left: no warm-up node, no proxy, the player's camera current.
## Whether that leaves no program compiled in play is the browser's to tell: the drive
## trace (?trace=drive) counts them, tools/web_shader_proof.sh checks it.
## The island here is the one generated as it loads; the web loads the one baked from it
## (generated/web/static_world.scn, tools/build-web.sh), which this test does not
## load: its census and duplicate-code check cover the baked island only as far as the
## bake keeps what it saves, and the browser proof is what covers the web's island.

## Every script under SCRIPTS_ROOT matching SCAN makes materials, shaders or drawables.
const SCRIPTS_ROOT := "res://game/scripts"
const SCAN := "(Shader|Standard|ORM|CanvasItem|ParticleProcess)Material(3D)?\\.new\\(|\\bShader\\.new\\(|\\b(Mesh|MultiMesh)Instance3D\\.new\\(|Label3D\\.new\\(|Sprite3D\\.new\\(|CPUParticles3D|GPUParticles3D|RenderingServer\\.(instance_create|multimesh_create|mesh_create)|\\.instantiate\\(|duplicate\\(\\)\\s+as\\s+\\w*Material"
## A script registers what it draws only in play when it calls this: a call on a line
## of its own (a comment does not count).
const REGISTERS := "(?m)^\\s*ShaderWarmUp\\.add(_mesh)?\\("
## The callbacks Godot calls in play: a maker inside one in a script classified by folder
## or file (as making what it draws while the island loads) fails.
const RUNTIME_CALLBACKS := "^(_process|_physics_process|_input|_unhandled_input|_unhandled_key_input|_notification|_integrate_forces|_on_\\w+)$"
## Why the scripts that make materials, shaders or drawables and register none need
## none: by folder (ending "/"), by file, or by function ("FILE::FUNCTION": each maker
## in that file must then be in a function named here).
const CLASSIFIED := {
	"res://game/scripts/world/facades/": "builds buildings while the island loads (or bakes)",
	"res://game/scripts/world/massing/": "builds buildings while the island loads (or bakes)",
	"res://game/scripts/debug/startup_marks.gd": "a startup measurement, only with ?profile_startup=1",
	"res://game/scripts/player/chest_avatar.gd": "builds the player while the island loads",
	"res://game/scripts/player/chest_avatar_parts.gd": "the player's materials, made with it while the island loads (a driver's are made alike: car_driver.gd)",
	"res://game/scripts/player/landing_poof.gd": "made with the player while the island loads",
	"res://game/scripts/vehicles/car_driver.gd": "a car's driver at the hero level, desktop only, drawn with the player's shaders (chest_avatar_parts.gd)",
	"res://game/scripts/vehicles/drivable_car.gd::_instance": "a live car's instances, drawn with the clutter and yard kits' materials, which the kits register",
	"res://game/scripts/vehicles/drivable_car.gd::set_lamps_lit": "a lit lamp's copy of a kit's ShaderMaterial: the same Shader, so the same programs",
	"res://game/scripts/vehicles/vehicle_manager.gd::_new_barrier": "a yard's barrier instances, made while the island loads with the yard kit's materials (registered there)",
	"res://game/scripts/world/bay_bridge_builder.gd": "builds the Bay Bridge while the island loads (or bakes)",
	"res://game/scripts/world/breakwater_birds.gd": "builds the birds while the island loads (or bakes)",
	"res://game/scripts/world/ferry_terminal.gd": "builds the ferry terminal while the island loads (or bakes)",
	"res://game/scripts/world/fresh_bay_horizon.gd": "builds the horizon while the island loads (or bakes)",
	"res://game/scripts/world/ground_cover.gd": "builds the ground cover while the island loads (or bakes)",
	"res://game/scripts/world/ground_dressing.gd": "the grass round the camera, desktop only (Forward+): the web has none",
	"res://game/scripts/world/interiors/interior_far_stand_in.gd": "builds an interior's far stand-in with the interior while the island loads (or bakes): hidden until far, which the warm-up finds all the same, drawn with the interior's own shaders",
	"res://game/scripts/world/mulch_ground.gd": "builds the mulch while the island loads (or bakes)",
	"res://game/scripts/world/shader_warm_up.gd": "the warm-up's own proxies",
	"res://game/scripts/world/shoreline_builder.gd": "builds the shoreline while the island loads (or bakes)",
	"res://game/scripts/world/soccer_ball.gd": "made with the street furniture while the island loads (its confetti registers)",
	"res://game/scripts/world/street_clutter_builder.gd": "builds the street clutter while the island loads (or bakes)",
	"res://game/scripts/world/street_detail_batches.gd": "batches the street vegetation and clutter, and copies their materials with level bands, while the island loads (or bakes)",
	"res://game/scripts/world/street_fence_builder.gd": "builds the fences while the island loads (or bakes)",
	"res://game/scripts/world/street_fence_kit.gd": "its materials are made with the fences while the island loads; the fence breaker registers its debris's",
	"res://game/scripts/world/street_furniture_builder.gd": "builds the street furniture while the island loads (or bakes)",
	"res://game/scripts/world/street_furniture_kit.gd": "its materials are made with the furniture while the island loads; the furniture breaker registers what a felled prop draws",
	"res://game/scripts/world/street_vegetation_builder.gd": "builds the street trees while the island loads (or bakes)",
	"res://game/scripts/world/street_vegetation_kit.gd": "its materials are made with the trees while the island loads",
	"res://game/scripts/world/western_background_blockout.gd": "builds the western background while the island loads (or bakes)",
	"res://game/scripts/world/world_chunk_builder.gd": "builds the island's chunks while it loads (or bakes)",
	"res://game/scripts/world/world_loader.gd": "loads or builds the island",
	"res://game/scripts/world/ybi_detail_materials.gd": "Yerba Buena Island's materials, made while the island loads (or bakes)",
	"res://game/scripts/world/ybi_ground.gd": "builds Yerba Buena Island's ground while the island loads (or bakes)",
	"res://game/scripts/world/ybi_vegetation_builder.gd": "builds Yerba Buena Island's trees while the island loads (or bakes)",
}
const WARM_UP_LINE := "Compiling shaders: " + GameMain.WARM_UP_WORDS

var _failure := ""
## The engine's shader inspector's answers, in the order asked (Asker).
var _asker: Asker


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var scan := _check_scan()
	if scan.is_empty():
		return
	_asker = Asker.new()
	root.add_child(_asker)
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	main.capture_mouse_on_ready = false
	main.use_saved_settings = false
	# The shaders a group at a time, as the web build compiles them; and, as on the web,
	# play starts paused behind the start prompt (the chest as it shows there is checked).
	main.compile_by_group = true
	main.start_prompt = true
	var world := main.get_node("WorldRoot") as WorldLoader
	var load_failures: Array[String] = []
	world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failures.append("%s: %s" % [code, message]))
	var seen := {"needs": [], "proxies": [], "unhandled": {}, "lines": 0}
	(main.get_node("Interface/HUD") as GameHUD).loading_shown.connect(func(text: String) -> void:
		if text.replace(GameMain.NO_BREAK_SPACE, " ").begins_with(WARM_UP_LINE):
			seen.lines += 1
			if (seen.proxies as Array).is_empty():
				_take_warm_up(main, seen))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while not main.is_play_ready() and load_failures.is_empty() and Time.get_ticks_msec() - started < 180000:
		await process_frame
	if not load_failures.is_empty() or not main.is_play_ready():
		_fail("The island did not reach play: %s" % [load_failures])
		return
	var chest := _check_chest_at_prompt(main)
	if chest.is_empty():
		return
	if int(seen.lines) == 0 or (seen.proxies as Array).is_empty():
		_fail("Loading must put up the warm-up's line(s) (\"%s\") and its proxies; lines %d, proxies %d." % [WARM_UP_LINE, seen.lines, (seen.proxies as Array).size()])
		return
	if not (seen.unhandled as Dictionary).is_empty():
		_fail("The warm-up could not proxy: %s (a drawable or material of a kind ShaderWarmUp._take does not draw, or a use with no place inside its probes' boxes)." % [seen.unhandled])
		return
	# The shader inspector names each BaseMaterial3D's shader a frame after it is asked.
	await process_frame
	var coverage := _check_coverage(seen)
	if coverage.is_empty():
		return
	var shared := _check_shared_code(main)
	if shared.is_empty():
		return
	var left := await _check_nothing_left(main)
	if left.is_empty():
		return
	# The start prompt's tap: play goes on, for the runtime effects.
	main._resume_game()
	await process_frame
	var effects := await _check_effects(main, seen)
	if effects.is_empty():
		return
	main.free()
	print("PASS: shader warm-up: %s; %s; %s; %s; %s; %s" % [scan, coverage, shared, chest, left, effects])
	quit(0)


## Every script that makes materials, shaders or drawables registers what it draws
## only in play or is CLASSIFIED; CLASSIFIED names no script that is gone or that
## registers. Returns a summary, or "" after failing.
func _check_scan() -> String:
	var pattern := RegEx.create_from_string(SCAN)
	var registers_call := RegEx.create_from_string(REGISTERS)
	var runtime := RegEx.create_from_string(RUNTIME_CALLBACKS)
	var makers := 0
	var registering: Array[String] = []
	var unclassified: Array[String] = []
	var in_play: Array[String] = []
	var both: Array[String] = []
	var found: Array[String] = []
	var named := {}
	for path: String in _scripts(SCRIPTS_ROOT):
		var source := FileAccess.get_file_as_string(path)
		var made := _makers(source, pattern)
		if made.is_empty():
			continue
		makers += made.size()
		found.append(path)
		if registers_call.search(source) != null:
			registering.append(path.get_file())
			if CLASSIFIED.has(path) or CLASSIFIED.keys().any(func(key: String) -> bool: return key.begins_with(path + "::")):
				both.append(path)
			continue
		var reason := _classified(path)
		for maker: Array in made:
			var function := str(maker[0])
			if CLASSIFIED.has(path + "::" + function):
				named[path + "::" + function] = true
			elif reason.is_empty():
				unclassified.append("%s (%s: %s)" % [path, function, maker[1]])
			elif runtime.search(function) != null:
				in_play.append("%s (%s: %s)" % [path, function, maker[1]])
	if not unclassified.is_empty():
		_fail("These makers of materials, shaders or drawables are in scripts that neither register what they draw only in play (a ShaderWarmUp.add call, as the island loads) nor say in CLASSIFIED (game/tests/headless_shader_warm_up_contract.gd) why they need not: %s" % [unclassified])
		return ""
	if not in_play.is_empty():
		_fail("These makers are inside callbacks Godot calls in play, in scripts CLASSIFIED as making what they draw while the island loads: register what they draw (ShaderWarmUp.add) or classify the function: %s" % [in_play])
		return ""
	if not both.is_empty():
		_fail("These scripts register with ShaderWarmUp and are also CLASSIFIED as needing no registration: %s" % [both])
		return ""
	var stale: Array[String] = []
	for key: String in CLASSIFIED:
		if key.contains("::"):
			if not named.has(key):
				stale.append(key)
		elif key.ends_with("/"):
			if not found.any(func(path: String) -> bool: return path.begins_with(key)):
				stale.append(key)
		elif not found.has(key):
			stale.append(key)
	if not stale.is_empty():
		_fail("CLASSIFIED names scripts or functions that make no materials, shaders or drawables (or are gone): %s" % [stale])
		return ""
	return "%d scripts make materials, shaders or drawables (%d makers), each classified (%d register: %s)" % [found.size(), makers, registering.size(), ", ".join(registering)]


## Each maker in a script's source (a SCAN match not in a comment): [the function it is
## in ("" at the script's top level), the text matched].
static func _makers(source: String, pattern: RegEx) -> Array:
	var functions := RegEx.create_from_string("(?m)^(?:static\\s+)?func\\s+(\\w+)")
	var starts: Array = []
	for found: RegExMatch in functions.search_all(source):
		starts.append([found.get_start(), found.get_string(1)])
	var made: Array = []
	for found: RegExMatch in pattern.search_all(source):
		var line_start := source.rfind("\n", found.get_start()) + 1
		if source.substr(line_start, found.get_start() - line_start).strip_edges().begins_with("#"):
			continue
		var function := ""
		for start: Array in starts:
			if int(start[0]) < found.get_start():
				function = str(start[1])
		made.append([function, found.get_string()])
	return made


func _classified(path: String) -> String:
	if CLASSIFIED.has(path):
		return CLASSIFIED[path]
	for key: String in CLASSIFIED:
		if key.ends_with("/") and path.begins_with(key):
			return CLASSIFIED[key]
	return ""


static func _scripts(folder: String) -> Array[String]:
	var paths: Array[String] = []
	for file: String in DirAccess.get_files_at(folder):
		if file.ends_with(".gd"):
			paths.append(folder.path_join(file))
	for sub: String in DirAccess.get_directories_at(folder):
		paths.append_array(_scripts(folder.path_join(sub)))
	return paths


## As the warm-up's first line goes up (its proxies built, the island loaded and every
## runtime effect's maker configured): what main draws, each way, by this test's own
## walk; and the warm-up's proxies, each with the way it draws (its kind, where it
## stands). BaseMaterial3Ds are asked of the shader inspector here, answered a frame on.
func _take_warm_up(main: GameMain, seen: Dictionary) -> void:
	var warm := main.get_node_or_null("ShaderWarmUp") as ShaderWarmUp
	if warm == null:
		return
	seen.unhandled = warm.unhandled.duplicate()
	var probes := _probes(main)
	seen["probes"] = probes
	for node: Node in main.find_children("*", "GeometryInstance3D", true, false):
		if warm.is_ancestor_of(node):
			continue
		var geometry := node as GeometryInstance3D
		var instanced := geometry is MultiMeshInstance3D or geometry is CPUParticles3D
		var classes := _classes(geometry, probes)
		var shadow_only := geometry.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		for material: Variant in _drawn_with(geometry):
			for probe_class: int in classes:
				(seen.needs as Array).append(_need(material, instanced, probe_class, shadow_only, str(main.get_path_to(geometry))))
	for item: Array in ShaderWarmUp.registered():
		for probe_class: int in _moving_classes(int(item[2]), probes):
			(seen.needs as Array).append(_need(item[0], bool(item[1]), probe_class, false, "registered %s" % (item[0] as Material).resource_name))
	for batch: Node3D in warm.batches:
		for proxy: Node in batch.get_children():
			(seen.proxies as Array).append(_proxy_way(proxy as GeometryInstance3D, probes))
	for stop: Dictionary in warm.stops:
		for proxy: Node in (stop.proxies as Node3D).get_children():
			(seen.proxies as Array).append(_proxy_way(proxy as GeometryInstance3D, probes))


## What a node draws with: its materials and their next passes ({} for a Label3D's own
## flags, null for the default material).
static func _drawn_with(geometry: GeometryInstance3D) -> Array:
	var firsts: Array = []
	if geometry is Label3D:
		firsts.append(geometry.material_override if geometry.material_override != null else _label_flags(geometry as Label3D))
	else:
		var mesh: Mesh = null
		if geometry is MeshInstance3D:
			mesh = (geometry as MeshInstance3D).mesh
		elif geometry is MultiMeshInstance3D and (geometry as MultiMeshInstance3D).multimesh != null:
			mesh = (geometry as MultiMeshInstance3D).multimesh.mesh
		elif geometry is CPUParticles3D:
			mesh = (geometry as CPUParticles3D).mesh
		if mesh == null:
			return []
		for surface in mesh.get_surface_count():
			if geometry.material_override != null:
				firsts.append(geometry.material_override)
				break
			firsts.append((geometry as MeshInstance3D).get_active_material(surface) if geometry is MeshInstance3D else mesh.surface_get_material(surface))
	if geometry.material_overlay != null and not firsts.is_empty():
		firsts.append(geometry.material_overlay)
	var all: Array = []
	for first: Variant in firsts:
		all.append(first)
		if not first is Material:
			continue
		var material := first as Material
		while material.next_pass != null:
			material = material.next_pass
			all.append(material)
	return all


static func _label_flags(label: Label3D) -> Dictionary:
	return {"shaded": label.shaded, "double_sided": label.double_sided, "no_depth_test": label.no_depth_test, "fixed_size": label.fixed_size,
		"billboard": label.billboard, "alpha_cut": label.alpha_cut, "aa": label.alpha_antialiasing_mode, "filter": label.texture_filter,
		"font": label.font.get_instance_id() if label.font != null else 0}


## A need: a shader drawn one way, its shader named once the inspector has answered.
func _need(material: Variant, instanced: bool, probe_class: int, shadow_only: bool, by: String) -> Dictionary:
	var need := {"instanced": instanced, "class": probe_class, "shadow_only": shadow_only, "by": by, "shader": ""}
	if material is Dictionary:
		need.shader = "label %s" % str((material as Dictionary).values())
	elif material == null:
		need.shader = "default"
	elif material is ShaderMaterial:
		# Without a shader it draws with the default material.
		need.shader = "shader %d" % (material as ShaderMaterial).shader.get_instance_id() if (material as ShaderMaterial).shader != null else "default"
	elif material is BaseMaterial3D:
		need["ask"] = _asker.ask(material as BaseMaterial3D)
	else:
		need.shader = "kind %s" % (material as Object).get_class()
	return need


func _proxy_way(proxy: GeometryInstance3D, probes: Array) -> Dictionary:
	var material: Variant = proxy.material_override
	if proxy is Label3D:
		material = _label_flags(proxy as Label3D)
	var way := _need(material, proxy is MultiMeshInstance3D, _classes(proxy, probes, false)[0], proxy.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY, str(proxy.name))
	way["kind"] = proxy.get_class()
	return way


## The reflection probes' boxes and masks.
static func _probes(main: Node) -> Array:
	var probes: Array = []
	for node: Node in main.find_children("*", "ReflectionProbe", true, false):
		var probe := node as ReflectionProbe
		probes.append({"box": probe.global_transform * probe.get_aabb(), "mask": probe.reflection_mask})
	return probes


## The probe counts a node is drawn under: its own box's, or, if it rides on a moving
## body, every count it may come to.
static func _classes(geometry: GeometryInstance3D, probes: Array, may_move := true) -> Array[int]:
	if may_move:
		var at := geometry.get_parent()
		while at != null:
			if at is AnimatableBody3D or (at is PhysicsBody3D and not at is StaticBody3D):
				return _moving_classes(geometry.layers, probes)
			at = at.get_parent()
	var box := geometry.global_transform * geometry.get_aabb()
	var inside := 0
	for probe: Dictionary in probes:
		if (int(probe.mask) & geometry.layers) != 0 and (probe.box as AABB).intersects(box):
			inside += 1
	var classes: Array[int] = [mini(inside, 2)]
	return classes


static func _moving_classes(layers: int, probes: Array) -> Array[int]:
	var classes: Array[int] = [0]
	var boxes: Array[AABB] = []
	for probe: Dictionary in probes:
		if (int(probe.mask) & layers) != 0:
			boxes.append(probe.box)
	if not boxes.is_empty():
		classes.append(1)
	for a in boxes.size():
		for b in range(a + 1, boxes.size()):
			if boxes[a].intersects(boxes[b]) and not classes.has(2):
				classes.append(2)
	return classes


## Fills in each need's and proxy's shader from the inspector's answers.
func _name_shaders(items: Array) -> void:
	for item: Dictionary in items:
		if item.has("ask"):
			item.shader = _asker.shader_of(int(item.ask))


## Every need has a proxy drawing its shader the same way. Returns a summary, or "".
func _check_coverage(seen: Dictionary) -> String:
	_name_shaders(seen.needs)
	_name_shaders(seen.proxies)
	var drawn := {}
	for way: Dictionary in seen.proxies:
		drawn[_way_key(way)] = true
	var missing: Array[String] = []
	var shaders := {}
	for need: Dictionary in seen.needs:
		shaders[need.shader] = true
		if str(need.shader).is_empty() or str(need.shader).begins_with("kind "):
			missing.append("%s (shader not named: %s)" % [need.by, need.shader])
		elif not drawn.has(_way_key(need)):
			missing.append("%s: %s" % [need.by, _way_key(need)])
		if missing.size() >= 12:
			break
	if not missing.is_empty():
		_fail("These are drawn a way no warm-up proxy draws (shader, instances, probes, shadow only): %s" % [missing])
		return ""
	return "%d ways %d shaders are drawn (nodes and registered materials), each drawn by one of %d proxies" % [(seen.needs as Array).size(), shaders.size(), (seen.proxies as Array).size()]


static func _way_key(way: Dictionary) -> String:
	return "%s %d %d %d" % [way.shader, int(way.instanced), int(way.class), int(way.shadow_only)]


## No two Shader resources under main (or registered) have the same code.
func _check_shared_code(main: GameMain) -> String:
	var by_code := {}
	var shaders := {}
	for node: Node in main.find_children("*", "GeometryInstance3D", true, false):
		for material: Variant in _drawn_with(node as GeometryInstance3D):
			if material is ShaderMaterial and (material as ShaderMaterial).shader != null:
				shaders[(material as ShaderMaterial).shader] = str(main.get_path_to(node))
	for item: Array in ShaderWarmUp.registered():
		if item[0] is ShaderMaterial and (item[0] as ShaderMaterial).shader != null:
			shaders[(item[0] as ShaderMaterial).shader] = "registered"
	for shader: Shader in shaders:
		var list: Array = by_code.get(shader.code, [])
		list.append("%s (%s)" % [shader.resource_path if not shader.resource_path.is_empty() else "built in", shaders[shader]])
		by_code[shader.code] = list
	var copies: Array = []
	for code: String in by_code:
		if (by_code[code] as Array).size() > 1:
			copies.append("%d Shaders with one code, e.g. %s" % [(by_code[code] as Array).size(), (by_code[code] as Array).slice(0, 2)])
	if not copies.is_empty():
		_fail("Shaders with the same code are separate shaders to the renderer, each compiling its own programs: share one (ShaderWarmUp.shared_shader). %s" % [copies.slice(0, 8)])
		return ""
	return "%d Shaders, no two with the same code" % shaders.size()


## Once play has started: no warm-up node or proxy, the warm-up steps without nodes,
## the player's camera current. Returns a summary, or "".
func _check_nothing_left(main: GameMain) -> String:
	await process_frame
	var left := main.find_children("ShaderWarmUp", "", true, false)
	left.append_array(main.find_children("ProbeCamera", "", true, false))
	var steps_with_nodes := main.compile_steps.filter(func(step: Dictionary) -> bool: return step.get("warm_up", false) and not (step.nodes as Array).is_empty())
	var camera := main.get_viewport().get_camera_3d()
	if not left.is_empty() or not steps_with_nodes.is_empty() or camera != main.player.get_camera():
		_fail("Once play has started nothing of the warm-up may be left: nodes %s, steps with nodes %d, current camera %s." % [left.map(func(node: Node) -> String: return str(node.get_path())), steps_with_nodes.size(), camera.get_path() if camera != null else "none"])
		return ""
	return "nothing of it left in play (the player's camera current)"


## The chest as the start prompt shows it, play paused as loading ends (as on the
## web): at rest with its lid shut, however many frames the warm-up added to loading
## (it holds its rest pose until play starts; a breath lifts the lid up to 2 deg,
## which showed the gold at the web's prompt). Returns a summary, or "".
func _check_chest_at_prompt(main: GameMain) -> String:
	var avatars := main.player.find_children("*", "ChestAvatar", true, false)
	var pose: Dictionary = (avatars[0] as ChestAvatar).describe() if not avatars.is_empty() else {}
	if not paused or main.hud.start_prompt_text().is_empty():
		_fail("Play must start paused behind the start prompt (main.start_prompt), as on the web: paused %s, prompt \"%s\"." % [paused, main.hud.start_prompt_text()])
		return ""
	if pose.is_empty() or absf(float(pose.squash)) > 0.002 or absf(float(pose.lid_deg) - rad_to_deg(ChestAvatar.LID_REST)) > 0.5 or bool(pose.airborne):
		_fail("At the start prompt the chest must stand at rest with its lid shut (squash 0, lid %.2f deg, on the ground), whatever loading's length: %s." % [rad_to_deg(ChestAvatar.LID_REST), pose])
		return ""
	return "the chest at rest at the start prompt (lid %.2f deg)" % float(pose.lid_deg)


## What the runtime effects draw after play has started uses only shaders the warm-up
## drew that way: a fence bay broken, a street prop felled, a car's splash, goal
## confetti, a live car. Returns a summary, or "".
func _check_effects(main: GameMain, seen: Dictionary) -> String:
	var before := {}
	for node: Node in main.find_children("*", "GeometryInstance3D", true, false):
		before[node] = true
	var vehicles := main.vehicles
	var done: Array[String] = []
	var near := main.player.global_position
	# A fence bay, the nearest breakable one.
	var fences := main.world_root.street_detail_layer("fences") if "fences" in main.world_root.get_street_detail_layers() else null
	if fences != null:
		for body: Node in fences.find_children("Collision", "StaticBody3D", true, false):
			var group := body.get_parent() as Node3D
			var shape: CollisionShape3D = null
			for child: Node in body.get_children():
				if child is CollisionShape3D and child.has_meta("fence_bay"):
					shape = child as CollisionShape3D
					break
			if group != null and group.has_meta("fence_bays") and shape != null and bool(body.get_meta("breakable", true)):
				vehicles.fence_breaker().break_bay(group, shape, Vector3(4.0, 0.0, 0.0))
				done.append("fence bay")
				break
	# A street prop, felled.
	var breaker := vehicles.furniture_breaker()
	var ids := breaker.fellable_ids()
	if not ids.is_empty():
		breaker.fell(str(ids[0]))
		done.append("felled %s" % breaker.prop_of(str(ids[0])))
	# A car's splash and goal confetti, as the vehicle manager and the ball make them.
	var splash = (load("res://game/scripts/vehicles/car_splash.gd") as GDScript).new()
	main.add_child(splash)
	splash.start(near + Vector3(4.0, 0.0, 0.0), 8.0, 4.5)
	var confetti = (load("res://game/scripts/world/goal_confetti.gd") as GDScript).new()
	main.add_child(confetti)
	confetti.start(Transform3D(Basis.IDENTITY, near + Vector3(0.0, 0.0, 4.0)), 3.0, 2.4)
	done.append_array(["splash", "confetti"])
	# A live car: the first parked car taken up and driven from where it stands.
	var rows: Array = vehicles.swappable_ids()
	if not rows.is_empty():
		var started := vehicles.drive_from(str(rows[0]), Vector2(near.x + 6.0, near.z), Vector2(0.0, -1.0))
		if started == "":
			done.append("live car")
	for _frame in 3:
		await process_frame
	var needs: Array = []
	var probes: Array = seen.probes
	for node: Node in main.find_children("*", "GeometryInstance3D", true, false):
		if before.has(node):
			continue
		var geometry := node as GeometryInstance3D
		var instanced := geometry is MultiMeshInstance3D or geometry is CPUParticles3D
		var shadow_only := geometry.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		for material: Variant in _drawn_with(geometry):
			# Made in play, it may be drawn anywhere: outside the probes, at least.
			needs.append(_need(material, instanced, 0, shadow_only, str(main.get_path_to(geometry))))
	await process_frame
	_name_shaders(needs)
	var drawn := {}
	for way: Dictionary in seen.proxies:
		drawn[_way_key(way)] = true
	var missing: Array[String] = []
	for need: Dictionary in needs:
		if not drawn.has(_way_key(need)):
			missing.append("%s: %s" % [need.by, _way_key(need)])
	if vehicles.is_driving():
		vehicles.force_exit()
	if not missing.is_empty():
		_fail("Runtime effects drew shaders, or ways, the warm-up did not (%s): %s" % [", ".join(done), missing.slice(0, 12)])
		return ""
	if not (done.has("fence bay") and done.has("splash") and done.has("confetti") and done.any(func(item: String) -> bool: return item.begins_with("felled "))):
		_fail("Each runtime effect must run here (a fence bay, a felled prop, a splash, confetti; a live car where one can start): only %s did." % [done])
		return ""
	return "%d drawables of the runtime effects (%s) use only shaders the warm-up drew those ways" % [needs.size(), ", ".join(done)]


func _fail(message: String) -> void:
	if _failure == "":
		_failure = message
		push_error("FAIL: " + message)
		print("FAIL: " + message)
		quit(1)


## Asks the engine's shader inspector for BaseMaterial3Ds' shaders (answers come a
## frame later, in the order asked) and keeps the answers.
## It joins the inspector's group only while it asks (the warm-up asks the same group).
class Asker extends Node:
	var _asked: Array[BaseMaterial3D] = []
	var _index := {}
	var _answers: Array[RID] = []

	func ask(material: BaseMaterial3D) -> int:
		if _index.has(material):
			return _index[material]
		if not is_in_group(&"_native_shader_source_visualizer"):
			add_to_group(&"_native_shader_source_visualizer")
		_index[material] = _asked.size()
		_asked.append(material)
		material.inspect_native_shader_code()
		return _asked.size() - 1

	func _inspect_shader(shader: RID) -> void:
		_answers.append(shader)

	func shader_of(index: int) -> String:
		if is_in_group(&"_native_shader_source_visualizer") and _answers.size() >= _asked.size():
			remove_from_group(&"_native_shader_source_visualizer")
		return "generated %d" % _answers[index].get_id() if index < _answers.size() else ""
