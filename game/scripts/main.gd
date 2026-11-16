class_name GameMain
extends Node3D

@onready var world_root: WorldLoader = $WorldRoot
@onready var player: PlayerController = $Player
@onready var hud: GameHUD = $Interface/HUD

const STARTUP_MARKS := preload("res://game/scripts/debug/startup_marks.gd")
const TOUCH_CONTROLS := preload("res://game/scripts/ui/touch_controls.gd")
const GROUND_DRESSING := preload("res://game/scripts/world/ground_dressing.gd")
const VEHICLE_MANAGER := preload("res://game/scripts/vehicles/vehicle_manager.gd")
## A touch screen's HUD is laid out for this many pixels or more each way
## (use_touch_controls); the view still fills the screen's shape.
const TOUCH_LAYOUT_PX := 720
## The gameplay actions a pause lets go of, so none is still held when play goes
## on: a key let go while the window was away, or a touch button's own press.
const GAMEPLAY_ACTIONS: Array[StringName] = [&"move_forward", &"move_back", &"move_left", &"move_right", &"run", &"jetpack", &"fast_drop", &"recover", &"vehicle_enter_exit", &"handbrake"]
## The line shown, and for how long (s), when the browser refuses the start
## prompt's capture of the mouse and play goes on with the pointer free.
const POINTER_FREE_LINE := "This browser won't let the mouse turn the view: Esc, then Resume, asks again."
const POINTER_FREE_LINE_S := 8.0
## The loading screen's lines, one for each step of startup, in the order they show
## (_show_loading_step), each naming the work that runs while it shows: the island
## loaded (the baked world: the web build and the desktop exports) or built (from
## the generated sources: development and tests); the island set up for play (the
## physics' first steps with the whole island, the player settling on the ground,
## the cars, the grass, on the web the sounds handed to the browser); the shaders
## compiled a group of the world at a time (COMPILE_GROUPS); then the reflections
## rendered. Each goes up, and gets a frame to be seen, before its step's work
## starts, and stays until the next; play takes the screen away. On the web the page
## shows the download and the engine's start before them, and these lines on its own
## loading screen (game/web/shell.html).
const LOADING_STEPS := {
	&"load": "Loading the island…",
	&"build": "Building the island…",
	&"setup": "Setting up the island…",
	&"reflections": "Rendering reflections…",
}
## The start of each loading-step line printed for the web page (game/web/shell.html).
const LOADING_STEP_PRINT := "LOADING_STEP "
## The shaders compiled a group of the world at a time (owner, 2026-11-15: the one
## graphics step was "too monolithic", and its line must say what runs). On the web
## the island's first frame compiles the shaders of everything in view, about 16 s
## (WebGL compiles each as it is first drawn). So every group starts hidden behind
## the loading screen and shows one frame after another, and the frame that first
## draws a group compiles its shaders under its own line. In order: each group's
## words on the line, the nodes (paths from main) it shows, and over how many frames
## ("batches", counted on the line) the children of its one node show, nearest the
## camera first. The first group shows nothing: its frame is the first with 3D on,
## the sky, the light, the player and the screen's effects. A missing node is
## skipped (the grass and the cars' near detail are desktop only). The groups and
## batches follow how long each line stayed on screen on the web (2026-11-15: from
## the sky's 1.9 s to the ferry's 0.6 s); groups that cost next to nothing are folded
## into a neighbour, and the buildings come in two batches (about 4.2 and 1.8 s), as
## the middle one of three stayed up only 0.4 s.
const COMPILE_GROUPS: Array[Dictionary] = [
	{"words": "sky and player", "paths": []},
	{"words": "water and shoreline rocks", "paths": ["WorldRoot/ContextWorld/Water", "WorldRoot/ContextWorld/Shoreline"]},
	{"words": "ground and roads", "paths": ["WorldRoot/PlayableWorld/GroundAndAreas", "WorldRoot/PlayableWorld/RoadsAndPaths"]},
	{"words": "buildings", "paths": ["WorldRoot/PlayableWorld/Buildings"], "batches": 2},
	{"words": "trees and plants", "paths": ["WorldRoot/PlayableWorld/StreetDetail/Vegetation", "GroundDressing"]},
	{"words": "street furniture and fences", "paths": ["WorldRoot/PlayableWorld/StreetDetail/Furniture", "WorldRoot/PlayableWorld/StreetDetail/Fences"]},
	{"words": "parked cars and street clutter", "paths": ["WorldRoot/PlayableWorld/StreetDetail/Clutter", "Vehicles"]},
	# The ferry terminal and what is seen across the water: Yerba Buena Island, the
	# roads and piers at the island's edge, the Bay Bridge and the distant shores.
	{"words": "the ferry and the view across the bay", "paths": ["WorldRoot/ContextWorld/FerryTerminal", "WorldRoot/ContextWorld/YerbaBuenaIsland", "WorldRoot/ContextWorld/BoundaryAttachedVisuals", "WorldRoot/ContextWorld/BayBridge", "WorldRoot/ContextWorld/BayAreaHorizon"]},
]
## The line for the shaders all at once (compile_by_group off).
const COMPILE_ALL_LINE := "Compiling shaders…"
## Joins words a loading line keeps together on a wrap (keep_last_words_together).
const NO_BREAK_SPACE := "\u00a0"
## A second line under a step that runs long on a desktop's first launch, smaller
## and dimmer (hud.gd's load_note); 2026-11-15, on the devcontainer: the island's
## load 7 to 8 s and the reflections 9 to 10 s, against 3 s and under 1 s on the next
## launch, which reuses the compiled shaders.
const FIRST_LAUNCH_NOTES := {
	&"load": "On a first launch this also compiles the island's shaders.",
	&"reflections": "On a first launch this also compiles the shaders for the reflections.",
}

var _world_ready := false
var _startup_failed := false
## Whether the shaders are compiled a group at a time (COMPILE_GROUPS), each under
## its own line: on the web, where WebGL compiles them as they are first drawn. A
## desktop compiles most of them as the island loads, and each group then draws in
## a frame (2026-11-15: 25 ms), so there they are compiled all at once under one line.
## The gameplay contract sets it, as a browser would.
var compile_by_group := OS.has_feature("web")
## This load's shader steps (compile_plan), each {"line": its words on the loading
## screen, "nodes": the Node3Ds its frame shows}, in order; set as they begin.
var compile_steps: Array[Dictionary] = []
## The nodes the loading screen keeps hidden until their step, each with its own
## visible flag, which _show_hidden puts back (and _end_loading_view, any left).
var _loading_hidden := {}
## The viewport whose 3D drawing the loading screen turns off until the shaders'
## step, and the flag it had (_end_loading_view puts it back).
var _loading_viewport: Viewport
var _loading_viewport_3d_off := false
var _touch_controls: TouchControls
## The grass round the camera (ground_dressing.gd), null where it isn't drawn.
var ground_dressing: GROUND_DRESSING
## The drivable cars (vehicle_manager.gd), once the world is loaded.
var vehicles: VEHICLE_MANAGER
var _web_blur_callback: JavaScriptObject
var _web_visibility_callback: JavaScriptObject
var _web_pointer_lock_callback: JavaScriptObject
var _web_capture_pending := false
var _web_pointer_locked := false
## The browser refused the start prompt's capture (_sync_web_pointer_lock), so
## play goes on with the pointer free until a later Resume gets the lock.
var _web_pointer_free := false
var _web_view_revision := 0
var _web_debug_callback: JavaScriptObject
## Whether the start prompt's tap also puts the page full screen: on a phone or
## tablet whose browser can (Android's), as the page decides (_show_start_notes).
var _full_screen_on_start := false
## A pause or resume asked for inside a physics tick, put off to the idle step
## (_set_paused): true pauses, false resumes; quiet without the pause's sound.
var _pause_later := false
var _pause_later_quiet := false
# Shared automation keeps the pointer visible while retaining normal startup.
# Ordinary gameplay uses the default and captures the mouse as before.
var capture_mouse_on_ready := true
## The sun's shadow quality (the pause menu's Options), put on as the game starts.
var shadows: ShadowQuality
## The frame rate limit, 3D resolution and frame rate display (the pause menu's
## Options), put on as the game starts.
var graphics: GraphicsSettings
## The Sun pointed at the time of day, with its light (DaySun, DayClock, DayLight):
## 12:30 on the island's date as the game starts (DayClock.start_instant), time
## running on from there; the recorded moment for a test or capture
## driver; with the time of day off (DayClock.enabled: its switch, and the web)
## main.tscn's Sun and look, untouched.
var day_sun: DaySun
## The flashlight and the driven car's headlights, on by themselves at night
## (NightLights), once the world is loaded where NightLights.wanted(): with the time
## of day on (DayClock.enabled: not with its switch off or on the web) and not in a
## test or capture run (DayClock.scripted), which keeps the recorded moment.
var night_lights: NightLights
## The game's sound (game/scripts/audio/sound.gd), made as the game starts.
var sound: Sound
## Startup puts on the shadow level, graphics and sound kept from the last run; the
## shared capture harness turns this off, so its captures always have the defaults
## (a player's choice is a global engine setting that would reach its neutral sun,
## its frame timing and its resolution too).
var use_saved_settings := true
## Whether play waits behind the start prompt (_on_world_ready): on the web, for
## a touch screen and a mouse alike. Tests of touch play set it as a browser
## would.
var start_prompt := OS.has_feature("web")


func _init() -> void:
	STARTUP_MARKS.mark("main_init")


func _enter_tree() -> void:
	STARTUP_MARKS.mark("main_enter_tree")


func _ready() -> void:
	STARTUP_MARKS.mark("main_ready_begin")
	# Main runs always, for its pause menu and Esc. Everything that moves stops
	# with the game: the world, the player and the sky (pausable in main.tscn),
	# the cars and the grass added later, and shader time (PauseClock).
	process_mode = Node.PROCESS_MODE_ALWAYS
	var clock := PauseClock.new()
	clock.name = "PauseClock"
	clock.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(clock)
	# The web's default level is Off: the complete island without distant shadow
	# passes in WebGL (ShadowQuality).
	shadows = ShadowQuality.new($Sun)
	var settings_problem := player_settings_problem(get_tree(), "loaded main.tscn with use_saved_settings on, reading") if use_saved_settings else ""
	if not settings_problem.is_empty():
		push_error(settings_problem)
	shadows.apply(ShadowQuality.saved_id() if use_saved_settings and settings_problem.is_empty() else ShadowQuality.default_id())
	hud.set_shadow_levels(ShadowQuality.offered(), shadows.current)
	hud.shadow_quality_chosen.connect(_on_shadow_quality_chosen)
	# The frame rate limit, 3D resolution and frame rate display: kept from the last
	# run, or for a test or capture driver the defaults, which leave the engine as it
	# started on desktop (the web's default resolution is two thirds).
	graphics = GraphicsSettings.new(get_viewport())
	graphics.apply(GraphicsSettings.saved() if use_saved_settings and settings_problem.is_empty() else GraphicsSettings.defaults())
	hud.set_graphics(GraphicsSettings.offered(GraphicsSettings.FRAME_RATE_KEY), GraphicsSettings.offered(GraphicsSettings.RESOLUTION_KEY), graphics.current)
	hud.graphics_chosen.connect(_on_graphics_chosen)
	day_sun = DaySun.new($Sun, ($WorldEnvironment as WorldEnvironment).environment)
	day_sun.shadow_quality = shadows
	add_child(day_sun)
	hud.set_time_controls(DayClock.enabled())
	# The sound: its takes loaded now, under the loading screen; the master volume
	# and mute kept from the last run (the defaults for a test or capture driver).
	sound = Sound.new()
	add_child(sound)
	var kept := Sound.saved_settings() if use_saved_settings and settings_problem.is_empty() else {"volume": Sound.DEFAULT_VOLUME, "muted": false}
	sound.apply_settings(float(kept.volume), bool(kept.muted))
	hud.set_sound_settings(sound.volume, sound.muted)
	hud.sound_settings_changed.connect(_on_sound_settings_changed)
	if OS.has_feature("web"):
		# The view fills the browser's shape (window/stretch/aspect "expand", as
		# everywhere). Its 3D scale is the graphics' resolution (above).
		get_viewport().size_changed.connect(func() -> void: _web_view_revision += 1)
		get_viewport().msaa_3d = Viewport.MSAA_2X
		print("WEB_RENDER msaa_3d=%d scale=%.2f" % [get_viewport().msaa_3d, get_viewport().scaling_3d_scale])
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	if OS.has_feature("web") and bool(JavaScriptBridge.eval("navigator.maxTouchPoints > 0")):
		use_touch_controls()
	if OS.has_feature("web"):
		_web_blur_callback = JavaScriptBridge.create_callback(_on_web_blur)
		_web_visibility_callback = JavaScriptBridge.create_callback(_on_web_visibility)
		JavaScriptBridge.get_interface("window").addEventListener("blur", _web_blur_callback)
		JavaScriptBridge.get_interface("document").addEventListener("visibilitychange", _web_visibility_callback)
		if _touch_controls == null:
			_web_pointer_lock_callback = JavaScriptBridge.create_callback(_on_web_pointer_lock)
			JavaScriptBridge.get_interface("document").addEventListener("pointerlockchange", _web_pointer_lock_callback)
			JavaScriptBridge.get_interface("document").addEventListener("pointerlockerror", _web_pointer_lock_callback)
	if OS.has_feature("web") and STARTUP_MARKS.enabled():
		_web_debug_callback = JavaScriptBridge.create_callback(_publish_web_state)
		JavaScriptBridge.get_interface("window").__tiReadback = _web_debug_callback
	# Until the shaders' step the view draws no 3D, only the loading screen: so the
	# frames that show each step's line never draw the island, whose first frame
	# compiles its shaders for seconds (_compile_by_group turns 3D back on).
	_loading_viewport = get_viewport()
	_loading_viewport_3d_off = _loading_viewport.disable_3d
	_loading_viewport.disable_3d = true
	_show_loading_step(&"load" if world_root.uses_prebuilt_world() else &"build")
	hud.bind_evidence(world_root.get_runtime_evidence())
	world_root.world_ready.connect(_on_world_ready)
	world_root.world_failed.connect(_on_world_failed)
	hud.resume_requested.connect(_resume_game)
	hud.exit_requested.connect(_exit_game)
	_load_world_after_paint.call_deferred()
	STARTUP_MARKS.mark("main_ready_end")


## Touch play, as on a touch browser (navigator.maxTouchPoints > 0: _ready calls
## it there, and the touch tests do): the HUD laid out for a screen
## TOUCH_LAYOUT_PX or more each way, the touch controls over it (their II button
## pauses), the controls screen's touch list and the cars told there is no F key.
## Called before the world is ready, play hands the touch controls the cars and
## starts them (_on_world_ready); called after, that happens at once. Returns
## the touch controls.
func use_touch_controls() -> TouchControls:
	if _touch_controls != null:
		return _touch_controls
	get_window().content_scale_size = Vector2i(TOUCH_LAYOUT_PX, TOUCH_LAYOUT_PX)
	_touch_controls = TOUCH_CONTROLS.new()
	_touch_controls.name = "TouchControls"
	_touch_controls.camera_rig = player.camera_rig
	_touch_controls.player = player
	hud.add_child(_touch_controls)
	_touch_controls.set_gameplay_active(false)
	_touch_controls.pause_requested.connect(func() -> void: _set_paused(true))
	hud.set_touch_instructions()
	if vehicles != null:
		vehicles.set_touch(true)
		_touch_controls.vehicles = vehicles
	if _world_ready:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_touch_controls.set_gameplay_active(not get_tree().paused)
	return _touch_controls


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		hud.toggle_debug()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause") and hud.controls_visible():
		# Esc on the controls screen goes back: to the pause menu, or the loading screen.
		hud.hide_controls()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause") and hud.options_visible():
		# Esc on the options screen goes back to the pause menu.
		hud.hide_options()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause") and hud.credits_visible():
		# Esc on the credits screen goes back a step: from the Licences to the list,
		# from the list to the pause menu.
		hud.credits_back()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause") and _world_ready:
		# The start prompt waits for its tap or click, the gesture that lets the
		# browser start the sound: Esc there (an iPad's keyboard) does nothing.
		if not hud.start_prompt_text().is_empty():
			get_viewport().set_input_as_handled()
			return
		# Browser Escape may also arrive after its pointer-lock loss callback.
		# Never turn that same unlock gesture into a new capture request.
		_set_paused(true if OS.has_feature("web") and _touch_controls == null else not get_tree().paused)
		get_viewport().set_input_as_handled()
		return
	if get_tree().paused and event.is_action_pressed("quit_game"):
		_exit_game()
		get_viewport().set_input_as_handled()


## True once startup has handed play to the player: the world is loaded, the
## player grounded and the initial graphics prepared.
func is_play_ready() -> bool:
	return _world_ready


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT \
	and _world_ready \
	and not get_tree().paused:
		_set_paused(true)


## Loads the island (world_root.load_world, which holds the main thread for
## seconds) once its loading line has had a frame to be seen.
func _load_world_after_paint() -> void:
	await _paint_loading_step()
	if is_inside_tree() and not _startup_failed:
		world_root.load_world()


## Puts up a loading step's line (loading_line).
func _show_loading_step(step: StringName) -> void:
	_show_loading_line(loading_line(step))


## A loading step's line as it shows here (LOADING_STEPS): on a desktop, under a
## step that runs long on a first launch, with its note (FIRST_LAUNCH_NOTES).
static func loading_line(step: StringName) -> String:
	if not OS.has_feature("web") and FIRST_LAUNCH_NOTES.has(step):
		return keep_last_words_together("%s\n%s" % [LOADING_STEPS[step], FIRST_LAUNCH_NOTES[step]])
	return keep_last_words_together(LOADING_STEPS[step])


## A loading line with each of its lines' last two words joined by a no-break space,
## so a narrow screen never leaves a word alone on a line of its own (2026-11-15: at
## 375 px "roads…" was). A line whose last word is already joined to the one before
## (a count, as compile_plan writes it) is kept as it is.
static func keep_last_words_together(text: String) -> String:
	var lines := text.split("\n")
	for index in lines.size():
		var space := lines[index].rfind(" ")
		if space >= 0 and not lines[index].substr(space + 1).contains(NO_BREAK_SPACE):
			lines[index] = lines[index].left(space) + NO_BREAK_SPACE + lines[index].substr(space + 1)
	return "\n".join(lines)


## Puts up a line on the loading screen, and prints it for the web page, which shows
## it on its own loading screen over the game's.
func _show_loading_line(text: String) -> void:
	hud.show_loading(text)
	STARTUP_MARKS.mark("line " + text.get_slice("\n", 0))
	print(LOADING_STEP_PRINT + text)


## The shaders' steps for the world as loaded, in order, as {"line": the words on the
## loading screen, "nodes": the Node3Ds its frame shows}: a group at a time
## (COMPILE_GROUPS), or with by_group off one step showing every group's nodes.
func compile_plan(by_group: bool) -> Array[Dictionary]:
	var plan: Array[Dictionary] = []
	if not by_group:
		var every: Array[Node3D] = []
		for group: Dictionary in COMPILE_GROUPS:
			for path: String in group.paths:
				var node := get_node_or_null(path) as Node3D
				if node != null:
					every.append(node)
		plan.append({"line": keep_last_words_together(COMPILE_ALL_LINE), "nodes": every})
		return plan
	var eye := player.get_camera().global_position
	for group: Dictionary in COMPILE_GROUPS:
		var nodes: Array[Node3D] = []
		for path: String in group.paths:
			var node := get_node_or_null(path) as Node3D
			if node != null:
				nodes.append(node)
		if nodes.is_empty() and not (group.paths as Array).is_empty():
			continue
		var batches := int(group.get("batches", 1))
		var parent: Node3D = nodes[0] if nodes.size() == 1 else null
		# Spread over the children where the one node holds a single wrapper.
		while parent != null and parent.get_child_count() == 1 and parent.get_child(0) is Node3D:
			parent = parent.get_child(0) as Node3D
		var children: Array[Node3D] = []
		if parent != null and batches > 1:
			for child: Node in parent.get_children():
				if child is Node3D:
					children.append(child as Node3D)
		var count := mini(batches, children.size())
		if count <= 1:
			plan.append({"line": keep_last_words_together("Compiling shaders: %s…" % group.words), "nodes": nodes})
			continue
		var away := {}
		for child: Node3D in children:
			away[child] = _centre_of(child).distance_squared_to(eye)
		children.sort_custom(func(a: Node3D, b: Node3D) -> bool: return away[a] < away[b])
		for index in count:
			var part: Array[Node3D] = []
			part.assign(children.slice(index * children.size() / count, (index + 1) * children.size() / count))
			# The count kept whole and with the word before it, as one on a wrap.
			plan.append({"line": "Compiling shaders: %s\u00a0(%d\u00a0of\u00a0%d)…" % [group.words, index + 1, count], "nodes": part})
	return plan


## Where a node's drawing is: the middle of its first mesh (or of itself), else its origin.
static func _centre_of(node: Node3D) -> Vector3:
	var geometry := node as GeometryInstance3D
	if geometry == null:
		var found := node.find_children("*", "GeometryInstance3D", true, false)
		if found.is_empty():
			return node.global_position
		geometry = found[0] as GeometryInstance3D
	return geometry.global_transform * geometry.get_aabb().get_center()


## The reflection probes startup renders before play: Mersea's two.
func _reflection_probes() -> Array[Node]:
	return world_root.buildings.find_children("Mersea*Reflection", "ReflectionProbe", true, false)


## The shaders compiled a group of the world at a time (COMPILE_GROUPS), behind the
## loading screen, which covers the view until play; then the reflection probes
## shown for their rendering. Hides every group's nodes and the probes, puts up the
## first group's line and, a frame later, turns 3D on; then each frame shows one
## group and puts up the next line. So the frame that first draws a group, and
## compiles its shaders, does so under that group's line, put up a frame before.
## Returns false if startup stopped meanwhile.
func _compile_by_group() -> bool:
	compile_steps = compile_plan(compile_by_group)
	for step: Dictionary in compile_steps:
		for node: Variant in step.nodes:
			_hide_until_shown(node)
	for probe: Node in _reflection_probes():
		_hide_until_shown(probe)
	_show_loading_line(compile_steps[0].line)
	await _paint_loading_step()
	if not _loading_goes_on():
		return false
	_loading_viewport.disable_3d = _loading_viewport_3d_off
	STARTUP_MARKS.mark("world_ready")
	print("WORLD_READY")
	if STARTUP_MARKS.enabled():
		_mark_first_submitted_frame()
	for index in compile_steps.size():
		# A group's node may be freed meanwhile; the helpers pass over it.
		for node: Variant in compile_steps[index].nodes:
			_show_hidden(node)
		_show_loading_line(compile_steps[index + 1].line if index + 1 < compile_steps.size() else loading_line(&"reflections"))
		# Called in an idle step: this frame draws the group shown, then the next comes.
		await get_tree().process_frame
		if not _loading_goes_on():
			return false
	for probe: Node in _reflection_probes():
		_show_hidden(probe)
	return true


## Whether startup is still on its way to play.
func _loading_goes_on() -> bool:
	return is_inside_tree() and not _startup_failed and world_root.is_world_validated()


## Hides a node until its step shows it (_show_hidden), keeping its own visible
## flag; a node already freed is passed over.
func _hide_until_shown(node: Variant) -> void:
	if is_instance_valid(node) and node is Node3D and not _loading_hidden.has(node):
		_loading_hidden[node] = (node as Node3D).visible
		(node as Node3D).visible = false


## Shows a node the loading screen hid, as it was; a node freed meanwhile is just forgotten.
func _show_hidden(node: Variant) -> void:
	if _loading_hidden.has(node):
		if is_instance_valid(node):
			(node as Node3D).visible = _loading_hidden[node]
		_loading_hidden.erase(node)


## Puts back all the loading screen changed in the view, as startup ends whichever
## way (play, a failure, main leaving the tree): every node it hid, and 3D drawing.
func _end_loading_view() -> void:
	for node: Variant in _loading_hidden.keys():
		if is_instance_valid(node):
			(node as Node3D).visible = _loading_hidden[node]
	_loading_hidden.clear()
	if is_instance_valid(_loading_viewport):
		_loading_viewport.disable_3d = _loading_viewport_3d_off
		_loading_viewport = null


## Returns once the loading line just put up has had a frame to be seen, before
## work that holds the main thread starts: a drawn frame of the loading screen on
## desktop (no 3D yet), and on the web, where each frame is a separate turn of the
## browser's, a turn in which the browser paints the page. Called in a physics step,
## that is the next frame's idle step; in an idle step, the next one. It waits for
## frames to be processed, not drawn, so a window that can't draw (minimized or
## covered) never holds up loading.
func _paint_loading_step() -> void:
	if Engine.is_in_physics_frame():
		await get_tree().process_frame
	await get_tree().process_frame


func _on_world_ready(_report: Dictionary) -> void:
	STARTUP_MARKS.probe_building_materials(world_root.buildings)
	# Loaded in an idle step: the player settles in the next frame's physics, after
	# a frame has shown this line.
	_show_loading_step(&"setup")
	STARTUP_MARKS.mark("grounding_begin")
	player.configure_world(world_root.get_spawn_transform(), world_root.get_boundary())
	await player.startup_grounded
	if not world_root.is_world_validated() or not player.reveal_grounded():
		_on_world_failed("player_grounding", "Player could not settle on generated land before its first visible frame.", [])
		return
	STARTUP_MARKS.mark("grounding_end")
	if OS.has_feature("web"):
		STARTUP_MARKS.mark("detail_distances_begin")
		_apply_web_detail_distances()
		STARTUP_MARKS.mark("detail_distances_end")
	if not player.feedback_requested.is_connected(hud.show_feedback):
		player.feedback_requested.connect(hud.show_feedback)
	if not player.recovered.is_connected(world_root.get_runtime_evidence().record_recovery):
		player.recovered.connect(world_root.get_runtime_evidence().record_recovery)
	world_root.get_runtime_evidence().bind_runtime(player, world_root.get_boundary())
	var dressing_level := GROUND_DRESSING.run_level()
	if dressing_level != GROUND_DRESSING.OFF:
		ground_dressing = GROUND_DRESSING.new()
		ground_dressing.name = "GroundDressing"
		ground_dressing.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(ground_dressing)
		ground_dressing.configure(world_root, player, dressing_level)
	if vehicles == null:
		vehicles = VEHICLE_MANAGER.new()
		vehicles.name = "Vehicles"
		add_child(vehicles)
		vehicles.configure(world_root, player, hud, _touch_controls != null)
		if _touch_controls != null:
			_touch_controls.vehicles = vehicles
	# The buildings' daylight fills, found once now the world is loaded, go out at
	# night with the look (DaySun; nothing with the time of day off).
	day_sun.collect_fills(world_root.buildings)
	if night_lights == null and NightLights.wanted():
		night_lights = NightLights.new(day_sun, player, vehicles, shadows)
		add_child(night_lights)
	# On the web the browser takes the sounds now, not at their first play; the
	# ditch's drawn water is read back now, not at the first footstep near it.
	sound.prepare_for_play()
	StandingWater.prepare()
	# The island's first frame would compile the shaders of everything in view for
	# seconds (on the web, a quarter of a minute): a group at a time instead, each
	# under its own line, with 3D back on; then the reflections.
	if not await _compile_by_group():
		return
	var graphics_error := await _prepare_initial_graphics()
	if not graphics_error.is_empty():
		_on_world_failed("graphics_preparation", graphics_error, [])
		return
	if not _loading_goes_on():
		return
	_end_loading_view()
	_world_ready = true
	STARTUP_MARKS.mark("play_handoff")
	print("PLAY_READY")
	player.set_gameplay_enabled(true)
	# The wind and the bay fade in: play has started (no "ready" sting, which would
	# be music; owner, 2026-11-14). The bay is heard by the player at its edge.
	sound.start_beds(world_root.get_boundary(), player)
	# A controls screen opened on the loading screen stays open, and play starts
	# paused behind it: nothing moves and the mouse stays free until the player
	# closes it (to the pause menu) and resumes.
	var controls_open := hud.controls_visible()
	if capture_mouse_on_ready and not OS.has_feature("web") and _touch_controls == null and not controls_open:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.show_world_ready()
	# On the web, touch or mouse, play waits behind one start prompt (owner,
	# 2026-11-15): the game starts paused, its pause menu showing only Play,
	# worded for the screen. That tap or click is the gesture that lets the
	# browser start the sound (game/web/shell.html) and, with a mouse, take the
	# mouse for the look, through the menu's own Resume (_resume_game): a refused
	# capture leaves it waiting there, as the pause menu does. The loading screen
	# hands over to it as play is ready. Never auto-request browser lock.
	if start_prompt:
		hud.set_start_prompt("Tap to play" if _touch_controls != null else "Click to play")
		if OS.has_feature("web") and _touch_controls != null:
			_show_start_notes()
		_set_paused(true, true)
	else:
		if _touch_controls != null:
			_touch_controls.set_gameplay_active(true)
		if controls_open:
			_set_paused(true)
	# Launch check for exported builds: load the island, then exit cleanly.
	if OS.get_cmdline_user_args().has("--quit-on-ready"):
		get_tree().quit(0)


func _prepare_initial_graphics() -> String:
	# Headless contracts have no rendered readiness claim or draw signals.
	if DisplayServer.get_name() == "headless":
		STARTUP_MARKS.mark("graphics_skipped_headless")
		return ""
	STARTUP_MARKS.mark("graphics_prepare_begin")
	if STARTUP_MARKS.enabled():
		print("GRAPHICS_PREPARE visible=%s grounded=%s input=%s camera=%s renderer=%s" % [player.visible, player.is_on_floor(), player.is_processing_unhandled_input(), player.get_camera().global_position, RenderingServer.get_current_rendering_method()])
	# Mersea's two probes are the only startup reflection producers, and shared startup
	# must not depend on one building: without them there is nothing to settle, and a
	# probe whose images failed keeps updating every frame (Mersea's own fallback).
	var probes := _reflection_probes()
	if probes.is_empty():
		STARTUP_MARKS.mark("graphics_no_reflection_probe")
	for probe: ReflectionProbe in probes:
		while is_instance_valid(probe) and probe.is_inside_tree():
			if _startup_failed:
				return "Startup was cancelled."
			var state := str(probe.get_meta("startup_reflection", ""))
			if state == "final_mode_set" or state == "images_failed":
				break
			if state != "waiting_images":
				return "Initial reflection images could not be prepared."
			await get_tree().process_frame
		if not is_instance_valid(probe) or not probe.is_inside_tree():
			return "Initial reflection producer was removed."
	STARTUP_MARKS.mark("graphics_final_probe_mode")
	# If rotation changes the initial view mid-preparation, submit the same
	# bounded work for the new view before handing over controls.
	var prepared_revision := -1
	while prepared_revision != _web_view_revision:
		prepared_revision = _web_view_revision
		# Pinned Godot 4.7.2 scheduling contract, NOT a public probe-ready query.
		# Preserve Mersea's existing ALWAYS atlas setup and image-settling callback.
		# Their final ONCE mode dirties each probe: viewport culling discovers it AFTER
		# render_probes, so start with a discovery draw at the grounded player camera.
		await RenderingServer.frame_post_draw
		STARTUP_MARKS.mark("graphics_probe_discovery_submitted")
		# render_probes services one ONCE probe per draw. RD's existing ALWAYS atlas
		# has 7 roughness mips: capture + 6 filtering steps. GLES3 caps its atlas at
		# 8 mips: capture + at most 8 filtering steps. Both Mersea probes end up ONCE
		# and take turns, so cover each actual producer in sequence.
		# This bound is scoped to the current Mersea setup, not a generic scheduler.
		var capture_filter_draws := 9 if RenderingServer.get_current_rendering_method() == "gl_compatibility" else 7
		for probe: ReflectionProbe in probes:
			for task in range(capture_filter_draws):
				await RenderingServer.frame_post_draw
				if _startup_failed or not is_instance_valid(probe) or not probe.is_inside_tree():
					return "Initial reflection preparation was cancelled."
		STARTUP_MARKS.mark("graphics_capture_filter_submitted")
		# Draw the player-visible initial scene with those reflections, input still off.
		await RenderingServer.frame_post_draw
		STARTUP_MARKS.mark("graphics_initial_view_submitted")
	# From now on the probes are captured again as the time of day changes the light
	# while time runs (DaySun; never with the clock held, as a test's, a capture's or
	# the web's is).
	var settled: Array[ReflectionProbe] = []
	for probe: ReflectionProbe in probes:
		settled.append(probe)
	day_sun.watch_reflections(settled)
	# Submission coverage of this tested initial view only: no physical-display,
	# all-future-variant, driver-idle or general cubemap-completion guarantee.
	return ""


func _mark_first_submitted_frame() -> void:
	await RenderingServer.frame_post_draw
	# Submission opportunity only: not physical display or shader completion.
	STARTUP_MARKS.mark("first_frame_submitted")


func _on_world_failed(code: String, message: String, source_keys: Array) -> void:
	_startup_failed = true
	_web_capture_pending = false
	_world_ready = false
	_end_loading_view()
	if _touch_controls != null:
		_touch_controls.set_gameplay_active(false)
	player.hide()
	player.set_gameplay_enabled(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_load_error(code, message, source_keys)
	push_error("WORLD_FAILED: code=%s message=%s sources=%s" % [code, message, source_keys])


## Pauses or resumes the game, with the pause's sound unless quiet (the page
## hidden: nobody hears it).
func _set_paused(paused: bool, quiet := false) -> void:
	# The tree pauses and resumes only in the idle step. Resumed inside a physics
	# tick (a deferred call, such as the web's pointer-lock grant, is flushed
	# there) after a pause from the idle step, the physics server re-adds every
	# awake body to a list it is still in ("p_elem->_root" errors) and runs that
	# tick's remainder at the paused clock's zero step.
	if Engine.is_in_physics_frame():
		_pause_later = paused
		_pause_later_quiet = quiet
		if not get_tree().process_frame.is_connected(_set_paused_later):
			get_tree().process_frame.connect(_set_paused_later, CONNECT_ONE_SHOT)
		return
	if paused:
		for action: StringName in GAMEPLAY_ACTIONS:
			Input.action_release(action)
	if get_tree().paused != paused and not quiet:
		# The pause menu opening, a little lower closing.
		Sound.play(&"ui_pause", Vector3.INF, 1.0, 1.0 if paused else 0.9)
	get_tree().paused = paused
	if paused:
		_web_capture_pending = false
		_web_pointer_locked = false
	var mouse_mode := Input.MOUSE_MODE_VISIBLE if paused or _touch_controls != null or _web_pointer_free else Input.MOUSE_MODE_CAPTURED
	if Input.mouse_mode != mouse_mode:
		Input.mouse_mode = mouse_mode
	if _touch_controls != null:
		_touch_controls.set_gameplay_active(not paused and _world_ready)
	hud.set_paused(paused)


## Why this run must not use the player's settings file, or "". A test or capture
## driver (a --script run, its SceneTree scripted) that read it would take whatever
## level was last chosen on this machine, so its renders and timings would change
## with the machine, and one that wrote it would change the player's own game. A
## driver that only needs the default sets main.use_saved_settings = false; one that
## chooses levels points ShadowQuality.settings_path at a file of its own. main
## reports the error, which fails the run, and neither reads nor writes the file.
static func player_settings_problem(tree: SceneTree, use: String) -> String:
	if tree.get_script() != null and ShadowQuality.settings_path == ShadowQuality.DEFAULT_SETTINGS_PATH:
		return "A test or capture driver %s the player's settings file (%s): set main.use_saved_settings = false before adding main if it only needs the default, and point ShadowQuality.settings_path at a file of its own if it chooses levels." % [use, ShadowQuality.DEFAULT_SETTINGS_PATH]
	return ""


## A shadow level chosen on the options screen: on at once, and kept for next time
## (but never by a driver in the player's own settings file).
func _on_shadow_quality_chosen(id: String) -> void:
	shadows.apply(id)
	var settings_problem := player_settings_problem(get_tree(), "chose a shadow level, writing")
	if settings_problem.is_empty():
		ShadowQuality.save_id(shadows.current)
	else:
		push_error(settings_problem)
	hud.show_shadow_level(shadows.current)


## A frame rate limit or resolution chosen on the options screen, or the frame rate
## display switched: on at once, and kept for next time (but never by a driver in
## the player's own settings file).
func _on_graphics_chosen(key: String, value: Variant) -> void:
	var choices := graphics.current.duplicate()
	choices[key] = value
	graphics.apply(choices)
	var settings_problem := player_settings_problem(get_tree(), "chose a graphics setting, writing")
	if settings_problem.is_empty():
		GraphicsSettings.save(graphics.current)
	else:
		push_error(settings_problem)
	hud.show_graphics(graphics.current)


## The master volume or mute changed on the options screen: on at once, and kept
## for next time when keep (once a drag ends; never by a driver in the player's
## own settings file).
func _on_sound_settings_changed(volume: float, muted: bool, keep: bool) -> void:
	sound.apply_settings(volume, muted)
	if not keep:
		return
	var settings_problem := player_settings_problem(get_tree(), "changed the sound settings, writing")
	if settings_problem.is_empty():
		Sound.save_settings(sound.volume, sound.muted)
	else:
		push_error(settings_problem)


func _set_paused_later() -> void:
	_set_paused(_pause_later, _pause_later_quiet)


func _resume_game() -> void:
	if not _world_ready:
		return
	if OS.has_feature("web") and _touch_controls == null:
		if not _web_capture_pending:
			_web_capture_pending = true
			# Resume is a deliberate user gesture. Stay paused until the async grant.
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		if _full_screen_on_start and not hud.start_prompt_text().is_empty():
			# The start prompt's tap on an Android phone or tablet: full screen too, asked
			# for in the tap itself (the web build handles a touch inside its event), as
			# the browser requires; a refusal leaves the page as it was.
			_full_screen_on_start = false
			JavaScriptBridge.eval("window.__tiStartNotes && window.__tiStartNotes.enterFullScreen()")
		_set_paused(false)


## The start prompt's notes on a touch screen (owner, 2026-11-16), as the web page
## decides them (game/web/shell.html's __tiStartNotes): on an iPhone or iPad, in
## Safari outside a home screen app, how to play full screen from the home screen;
## on any iPhone or iPad, that the sound needs the silent mode off, unless the
## game's own sound is off (Options' mute or no volume); on an Android phone or
## tablet nothing to read, the prompt's tap going full screen (_resume_game). A
## page without the notes shows none.
func _show_start_notes() -> void:
	var notes: Variant = JSON.parse_string(str(JavaScriptBridge.eval("window.__tiStartNotes ? window.__tiStartNotes.read() : '{}'")))
	if not notes is Dictionary:
		return
	_full_screen_on_start = bool(notes.get("full_screen", false))
	var sound_on := not sound.muted and sound.volume > 0.0
	hud.set_start_notes(bool(notes.get("home_screen", false)), bool(notes.get("silent_mode", false)) and sound_on)


func _exit_game() -> void:
	get_tree().quit()


func _apply_web_detail_distances() -> void:
	# Distance culling by building mesh size. Keep the complete loaded world,
	# collision inventory, terrain and roads; distant small meshes can disappear.
	for node in world_root.get_node("PlayableWorld/Buildings").find_children("*", "GeometryInstance3D", true, false):
		var geometry := node as GeometryInstance3D
		# The bake's merged meshes hold a building's walls and roofs, not small parts.
		if geometry.has_meta("baked_merge"):
			continue
		var bounds := geometry.get_aabb()
		var world_size := (geometry.global_transform * bounds).size
		var longest := maxf(world_size.x, maxf(world_size.y, world_size.z))
		if longest <= 12.0:
			geometry.visibility_range_end = 200.0
			geometry.visibility_range_end_margin = 20.0
		elif longest <= 50.0:
			geometry.visibility_range_end = 500.0
			geometry.visibility_range_end_margin = 40.0


func _on_web_pointer_lock(_arguments: Array) -> void:
	_sync_web_pointer_lock.call_deferred()


func _sync_web_pointer_lock() -> void:
	if _touch_controls != null:
		return
	var captured := bool(JavaScriptBridge.eval("document.pointerLockElement === document.getElementById('canvas')"))
	if not _world_ready:
		_web_capture_pending = false
		if captured:
			JavaScriptBridge.get_interface("document").exitPointerLock()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if captured:
		if _web_capture_pending:
			_web_capture_pending = false
			_web_pointer_locked = true
			_web_pointer_free = false
			_set_paused(false)
		elif get_tree().paused or not _web_pointer_locked:
			# Escape/cancel can precede an asynchronous grant. Release it, don't resume.
			JavaScriptBridge.get_interface("document").exitPointerLock()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif _web_capture_pending and not hud.start_prompt_text().is_empty():
		# The browser refused the start prompt's capture (an embedding frame without
		# the permission, a kiosk, some Linux setups): play goes on with the pointer
		# free, as before the prompt; Esc and the pause menu's Resume ask again.
		_web_capture_pending = false
		_web_pointer_locked = false
		_web_pointer_free = true
		_set_paused(false)
		hud.show_feedback(POINTER_FREE_LINE, false, POINTER_FREE_LINE_S)
	else:
		_web_pointer_locked = false
		_set_paused(true)


func _on_web_blur(_arguments: Array) -> void:
	if _world_ready:
		_set_paused.call_deferred(true)


## The page hidden (another tab in front, the window minimized, another app on a
## phone): it draws no frames then, so a deferred pause (the blur's) would wait
## until it is shown again while the browser went on playing the loops (Godot's
## web sample playback starts a looping take again in JavaScript), and the
## frames it then catches up would sound. It pauses now, which stops every
## world sound at once, and quietly.
func _on_web_visibility(_arguments: Array) -> void:
	if _world_ready and bool(JavaScriptBridge.get_interface("document").hidden):
		_set_paused(true, true)


func _publish_web_state(_args: Array) -> void:
	var state := {
		"ready": _world_ready, "paused": get_tree().paused,
		"visible": player.visible, "grounded": player.is_on_floor(),
		"input": player.is_processing_unhandled_input(),
		"position": [player.position.x, player.position.y, player.position.z],
		"velocity": [player.velocity.x, player.velocity.y, player.velocity.z],
		"jetpack": Input.is_action_pressed("jetpack"), "run": Input.is_action_pressed("run"),
		"touch_vector": [player.touch_input_vector.x, player.touch_input_vector.y],
		"viewport": [get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y],
		"window": [get_window().size.x, get_window().size.y],
		"camera_aspect": player.get_camera().get_camera_projection().get_aspect(),
		"touch_visible": _touch_controls != null and _touch_controls.visible,
		"capture_pending": _web_capture_pending, "pointer_locked": _web_pointer_locked,
		"view_revision": _web_view_revision,
		"driving": vehicles != null and vehicles.is_driving(),
		"car": vehicles.active_car().describe() if vehicles != null and vehicles.is_driving() else {},
		# What the touch controls show and press, and the car's own inputs.
		"touch": _touch_controls.describe() if _touch_controls != null else {},
		"fast_drop": Input.is_action_pressed("fast_drop"),
		"enter_exit": Input.is_action_pressed("vehicle_enter_exit"),
		"handbrake": Input.is_action_pressed("handbrake"),
		"car_input": [vehicles.active_car().drive_input, vehicles.active_car().steer_input, vehicles.active_car().handbrake] if vehicles != null and vehicles.is_driving() else [],
		"resume_button": [hud.resume_button.get_global_rect().get_center().x, hud.resume_button.get_global_rect().get_center().y],
		# The controls screen (open or not) and the buttons that open and close it.
		"controls": hud.controls_visible(),
		# The start prompt (play waiting for its first tap or click) and its words;
		# whether play goes on with the pointer free (its capture refused), and the
		# feedback line showing.
		"start_prompt": hud.start_prompt_text(),
		# Its notes (which show), its panel, and whether its tap also goes full screen.
		"start_notes": hud.start_notes_state(),
		"start_panel": _rect(hud.pause_box),
		"full_screen_on_start": _full_screen_on_start,
		"pointer_free": _web_pointer_free,
		"feedback": hud.feedback_text.text if hud.feedback_panel.visible else "",
		"controls_button": [hud.controls_button.get_global_rect().get_center().x, hud.controls_button.get_global_rect().get_center().y],
		"back_button": [hud.back_button.get_global_rect().get_center().x, hud.back_button.get_global_rect().get_center().y],
		# The credits screen (open or not), its view and how far it is scrolled, and
		# the buttons that open, switch and close it.
		"credits": hud.credits_visible(),
		"credits_view": "licences" if hud.credits_licences.visible else "list",
		"credits_scroll": hud.credits_scroll().scroll_vertical,
		"credits_button": [hud.credits_button.get_global_rect().get_center().x, hud.credits_button.get_global_rect().get_center().y],
		"credits_licences_button": [hud.credits_licences_button.get_global_rect().get_center().x, hud.credits_licences_button.get_global_rect().get_center().y],
		"credits_back_button": [hud.credits_back_button.get_global_rect().get_center().x, hud.credits_back_button.get_global_rect().get_center().y],
		# The options screen (open or not) and where its panel and Back button are,
		# the shadow level on, and the buttons that open it and choose each level.
		"options": hud.options_visible(),
		"options_panel": _rect(hud.options_panel),
		"options_back_button": [hud.options_back_button.get_global_rect().get_center().x, hud.options_back_button.get_global_rect().get_center().y],
		"shadow_quality": shadows.current,
		"sun_shadows": ($Sun as DirectionalLight3D).shadow_enabled,
		"options_button": [hud.options_button.get_global_rect().get_center().x, hud.options_button.get_global_rect().get_center().y],
		"shadow_level_buttons": _shadow_level_buttons(),
		# The graphics: the choices on, what the engine has (the frame limit, the
		# window's 3D scale and mode, frames drawn a second), the frame rate shown or
		# not, and the buttons and switch that choose them.
		"graphics": _graphics_state(),
		# The pitch's ball: where it is and how many goals it has gone into.
		"ball": _ball_state(),
		# The sound: the audio driver, the master volume and mute, the slider on the
		# options screen, and how many times each sound has played.
		"sound": _sound_state(),
		# The time of day: whether it is on (DayClock.enabled), the clock's instant,
		# whether it runs, the Sun's rotation and sky mode, whether the options screen
		# offers the date and time, and whether there are night lights (none on the
		# web).
		"time": {"enabled": DayClock.enabled(), "unix": DayClock.now(), "running": DayClock.is_running(), "sun": [($Sun as Node3D).rotation_degrees.x, ($Sun as Node3D).rotation_degrees.y], "sky_mode": ($Sun as DirectionalLight3D).sky_mode, "controls": hud.time_controls_shown(), "night_lights": night_lights != null},
	}
	JavaScriptBridge.get_interface("window").__tiState = JSON.stringify(state)


func _shadow_level_buttons() -> Dictionary:
	return _button_centres(hud.shadow_levels)


func _button_centres(row: Control) -> Dictionary:
	var at := {}
	for button: Node in row.get_children():
		var middle := (button as Control).get_global_rect().get_center()
		at[str(button.name)] = [middle.x, middle.y]
	return at


func _graphics_state() -> Dictionary:
	var shown := hud.show_frame_rate.get_global_rect().get_center()
	return {
		"choices": graphics.current, "max_fps": Engine.max_fps,
		"scale": get_viewport().scaling_3d_scale, "mode": get_viewport().scaling_3d_mode,
		"fps": Engine.get_frames_per_second(), "frames_drawn": Engine.get_frames_drawn(),
		"frame_rate_shown": hud.frame_rate_label.visible, "frame_rate_text": hud.frame_rate_label.text,
		"frame_rate_rect": _rect(hud.frame_rate_label),
		"frame_rates_offered": hud.frame_rates.visible, "frame_rate_buttons": _button_centres(hud.frame_rates),
		"resolution_buttons": _button_centres(hud.resolutions), "show_switch": [shown.x, shown.y],
	}


## A control's rect in the viewport, as [x, y, width, height].
func _rect(control: Control) -> Array:
	var at := control.get_global_rect()
	return [at.position.x, at.position.y, at.size.x, at.size.y]


func _sound_state() -> Dictionary:
	var slider := hud.sound_volume.get_global_rect().get_center()
	return {"driver": AudioServer.get_driver_name(), "volume": sound.volume, "muted": sound.muted, "played": sound.played_counts, "volume_slider": [slider.x, slider.y]}


func _ball_state() -> Dictionary:
	var ball := get_tree().get_first_node_in_group(SoccerBall.GROUP) as SoccerBall
	if ball == null:
		return {}
	return {"position": [ball.global_position.x, ball.global_position.y, ball.global_position.z], "goals": ball.goals_scored, "resets": ball.resets}


## Stops the clock the scene tree's pause does not: shader time (the water's
## waves, the trees' and the grass's sway, the docked ferry's rocking, the jet
## flame), particles' steps and every process step follow Engine.time_scale,
## which this sets to 0 while the tree is paused and back after, however the
## pause comes (the pause menu, a lost focus, a test). Pausable, so it hears the
## tree pause and unpause; leaving the tree it puts the scale back.
class PauseClock extends Node:
	var _saved_scale := 1.0
	var _frozen := false

	func _notification(what: int) -> void:
		if what == NOTIFICATION_PAUSED and not _frozen:
			_saved_scale = Engine.time_scale
			Engine.time_scale = 0.0
			_frozen = true
		elif (what == NOTIFICATION_UNPAUSED or what == NOTIFICATION_EXIT_TREE) and _frozen:
			Engine.time_scale = _saved_scale
			_frozen = false


func _exit_tree() -> void:
	# A main freed mid-load gives the shared viewport its 3D back, and its nodes their looks.
	_end_loading_view()
	if _web_debug_callback != null:
		JavaScriptBridge.eval("delete window.__tiReadback; delete window.__tiState")
	_web_capture_pending = false
	if _web_pointer_lock_callback != null:
		if bool(JavaScriptBridge.eval("document.pointerLockElement === document.getElementById('canvas')")):
			JavaScriptBridge.get_interface("document").exitPointerLock()
		JavaScriptBridge.get_interface("document").removeEventListener("pointerlockchange", _web_pointer_lock_callback)
		JavaScriptBridge.get_interface("document").removeEventListener("pointerlockerror", _web_pointer_lock_callback)
	if _web_blur_callback != null:
		JavaScriptBridge.get_interface("window").removeEventListener("blur", _web_blur_callback)
		JavaScriptBridge.get_interface("document").removeEventListener("visibilitychange", _web_visibility_callback)
