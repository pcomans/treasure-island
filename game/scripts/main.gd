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

var _world_ready := false
var _startup_failed := false
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
var _web_view_revision := 0
var _web_debug_callback: JavaScriptObject
## A pause or resume asked for inside a physics tick, put off to the idle step
## (_set_paused): true pauses, false resumes.
var _pause_later := false
# Shared automation keeps the pointer visible while retaining normal startup.
# Ordinary gameplay uses the default and captures the mouse as before.
var capture_mouse_on_ready := true


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
	if OS.has_feature("web"):
		# The view fills the browser's shape (window/stretch/aspect "expand", as
		# everywhere).
		get_viewport().size_changed.connect(func() -> void: _web_view_revision += 1)
		# Keep the complete island while avoiding distant shadow passes in WebGL.
		$Sun.shadow_enabled = false
		get_viewport().scaling_3d_scale = 0.75
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
	hud.show_loading()
	hud.bind_evidence(world_root.get_runtime_evidence())
	world_root.load_progress.connect(hud.update_load_progress)
	world_root.world_ready.connect(_on_world_ready)
	world_root.world_failed.connect(_on_world_failed)
	hud.resume_requested.connect(_resume_game)
	hud.exit_requested.connect(_exit_game)
	world_root.call_deferred("load_world")
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
	if event.is_action_pressed("pause") and _world_ready:
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


func _on_world_ready(_report: Dictionary) -> void:
	STARTUP_MARKS.probe_building_materials(world_root.buildings)
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
	hud.show_loading("Preparing graphics…")
	STARTUP_MARKS.mark("world_ready")
	print("WORLD_READY")
	if STARTUP_MARKS.enabled():
		_mark_first_submitted_frame()
	var graphics_error := await _prepare_initial_graphics()
	if not graphics_error.is_empty():
		_on_world_failed("graphics_preparation", graphics_error, [])
		return
	if not is_inside_tree() or _startup_failed or not world_root.is_world_validated():
		return
	_world_ready = true
	STARTUP_MARKS.mark("play_handoff")
	print("PLAY_READY")
	player.set_gameplay_enabled(true)
	# A controls screen opened on the loading screen stays open, and play starts
	# paused behind it: nothing moves and the mouse stays free until the player
	# closes it (to the pause menu) and resumes.
	var controls_open := hud.controls_visible()
	if capture_mouse_on_ready and not OS.has_feature("web") and _touch_controls == null and not controls_open:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.show_world_ready()
	# Touch plays immediately; the desktop web walks with a visible pointer until
	# a deliberate click requests look capture. Never auto-request browser lock.
	if _touch_controls != null:
		_touch_controls.set_gameplay_active(true)
	elif OS.has_feature("web"):
		hud.set_pointer_capture_hint(true)
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
	var probes := world_root.buildings.find_children("Mersea*Reflection", "ReflectionProbe", true, false)
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
	if _touch_controls != null:
		_touch_controls.set_gameplay_active(false)
	player.hide()
	player.set_gameplay_enabled(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_load_error(code, message, source_keys)
	push_error("WORLD_FAILED: code=%s message=%s sources=%s" % [code, message, source_keys])


func _set_paused(paused: bool) -> void:
	# The tree pauses and resumes only in the idle step. Resumed inside a physics
	# tick (a deferred call, such as the web's pointer-lock grant, is flushed
	# there) after a pause from the idle step, the physics server re-adds every
	# awake body to a list it is still in ("p_elem->_root" errors) and runs that
	# tick's remainder at the paused clock's zero step.
	if Engine.is_in_physics_frame():
		_pause_later = paused
		if not get_tree().process_frame.is_connected(_set_paused_later):
			get_tree().process_frame.connect(_set_paused_later, CONNECT_ONE_SHOT)
		return
	if paused:
		for action: StringName in GAMEPLAY_ACTIONS:
			Input.action_release(action)
	get_tree().paused = paused
	if paused:
		_web_capture_pending = false
		_web_pointer_locked = false
	var mouse_mode := Input.MOUSE_MODE_VISIBLE if paused or _touch_controls != null else Input.MOUSE_MODE_CAPTURED
	if Input.mouse_mode != mouse_mode:
		Input.mouse_mode = mouse_mode
	if _touch_controls != null:
		_touch_controls.set_gameplay_active(not paused and _world_ready)
	hud.set_paused(paused)
	if OS.has_feature("web") and _touch_controls == null:
		hud.set_pointer_capture_hint(not paused and _world_ready and not _web_pointer_locked)


func _set_paused_later() -> void:
	_set_paused(_pause_later)


func _resume_game() -> void:
	if not _world_ready:
		return
	if OS.has_feature("web") and _touch_controls == null:
		if not _web_capture_pending:
			_web_capture_pending = true
			# Resume is a deliberate user gesture. Stay paused until the async grant.
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		_set_paused(false)


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
			_set_paused(false)
		elif get_tree().paused or not _web_pointer_locked:
			# Escape/cancel can precede an asynchronous grant. Release it, don't resume.
			JavaScriptBridge.get_interface("document").exitPointerLock()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		_web_pointer_locked = false
		_set_paused(true)


func _on_web_blur(_arguments: Array) -> void:
	if _world_ready:
		_set_paused.call_deferred(true)


func _on_web_visibility(_arguments: Array) -> void:
	if bool(JavaScriptBridge.get_interface("document").hidden):
		_on_web_blur([])


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
		"controls_button": [hud.controls_button.get_global_rect().get_center().x, hud.controls_button.get_global_rect().get_center().y],
		"back_button": [hud.back_button.get_global_rect().get_center().x, hud.back_button.get_global_rect().get_center().y],
		# The pitch's ball: where it is and how many goals it has gone into.
		"ball": _ball_state(),
	}
	JavaScriptBridge.get_interface("window").__tiState = JSON.stringify(state)


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
