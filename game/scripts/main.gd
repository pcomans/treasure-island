class_name GameMain
extends Node3D

@onready var world_root: WorldLoader = $WorldRoot
@onready var player: PlayerController = $Player
@onready var hud: GameHUD = $Interface/HUD

var _world_ready := false
# Shared automation keeps the pointer visible while retaining normal startup.
# Ordinary gameplay uses the default and captures the mouse as before.
var capture_mouse_on_ready := true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.hide()
	player.set_gameplay_enabled(false)
	hud.show_loading()
	hud.bind_evidence(world_root.get_runtime_evidence())
	world_root.load_progress.connect(hud.update_load_progress)
	world_root.world_ready.connect(_on_world_ready)
	world_root.world_failed.connect(_on_world_failed)
	hud.resume_requested.connect(_resume_game)
	hud.exit_requested.connect(_exit_game)
	world_root.call_deferred("load_world")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		hud.toggle_debug()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause") and _world_ready:
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()
		return
	if get_tree().paused and event.is_action_pressed("quit_game"):
		_exit_game()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT \
	and _world_ready \
	and not get_tree().paused:
		_set_paused(true)


func _on_world_ready(_report: Dictionary) -> void:
	player.configure_world(world_root.get_spawn_transform(), world_root.get_boundary())
	await player.startup_grounded
	if not world_root.is_world_validated() or not player.reveal_grounded():
		_on_world_failed("player_grounding", "Player could not settle on generated land before its first visible frame.", [])
		return
	_world_ready = true
	if not player.feedback_requested.is_connected(hud.show_feedback):
		player.feedback_requested.connect(hud.show_feedback)
	if not player.spray_result.is_connected(world_root.get_runtime_evidence().record_spray):
		player.spray_result.connect(world_root.get_runtime_evidence().record_spray)
	if not player.recovered.is_connected(world_root.get_runtime_evidence().record_recovery):
		player.recovered.connect(world_root.get_runtime_evidence().record_recovery)
	if not player.get_spray_controller().spray_identity.is_connected(world_root.get_runtime_evidence().record_spray_identity):
		player.get_spray_controller().spray_identity.connect(world_root.get_runtime_evidence().record_spray_identity)
	if not player.get_spray_controller().tag_instances.active_count_changed.is_connected(world_root.get_runtime_evidence().set_active_decals):
		player.get_spray_controller().tag_instances.active_count_changed.connect(world_root.get_runtime_evidence().set_active_decals)
	if not player.get_spray_controller().tag_instances.oldest_tag_removed.is_connected(world_root.get_runtime_evidence().record_tag_eviction):
		player.get_spray_controller().tag_instances.oldest_tag_removed.connect(world_root.get_runtime_evidence().record_tag_eviction)
	world_root.get_runtime_evidence().bind_runtime(player, world_root.get_boundary())
	player.set_gameplay_enabled(true)
	if capture_mouse_on_ready:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.show_world_ready()
	print("WORLD_READY")
	# Launch check for exported builds: load the island, then exit cleanly.
	if OS.get_cmdline_user_args().has("--quit-on-ready"):
		get_tree().quit(0)


func _on_world_failed(code: String, message: String, source_keys: Array) -> void:
	_world_ready = false
	player.hide()
	player.set_gameplay_enabled(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_load_error(code, message, source_keys)
	push_error("WORLD_FAILED: code=%s message=%s sources=%s" % [code, message, source_keys])


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
	hud.set_paused(paused)


func _resume_game() -> void:
	if _world_ready:
		_set_paused(false)


func _exit_game() -> void:
	get_tree().quit()
