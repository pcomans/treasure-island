class_name GameMain
extends Node3D

const MAC_EXPORT_SMOKE_ARG := "--mac-export-smoke"
const MAC_EXPORT_SMOKE_TIMEOUT_SECONDS := 60.0
const EXPECTED_MANIFEST_HASH := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_CHUNKS := 38
const EXPECTED_PLAYABLE_ROWS := 735
const EXPECTED_CONTEXT_ROWS := 4
const EXPECTED_MESHES := 952
const EXPECTED_SURFACES := 967
const EXPECTED_TRIANGLES := 67716
const EXPECTED_STATIC_BODIES := 466
const EXPECTED_VEGETATION_SEED := 1414092337
const EXPECTED_VEGETATION_INSTANCES := 124
const EXPECTED_VEGETATION_ASSETS := 15
const EXPECTED_VEGETATION_BATCHES := 19
const EXPECTED_FERRY_SPAWN_ORIGIN := Vector3(-104.364, 3.457, 786.024)
const EXPECTED_FERRY_SPAWN_YAW := -0.119
const EXPECTED_WALK_SPEED_MPS := 4.0
const EXPECTED_RUN_SPEED_MPS := 20.0
const EXPECTED_ACCELERATION_MPS2 := 30.0
const EXPECTED_BRAKING_MPS2 := 40.0
const POLYHAVEN_TEXTURE_ROOT := "res://game/resources/textures/world/polyhaven"
const MAC_EXPORT_EXPECTED_MATERIALS := {
	"road_path": {"asset": "clean_asphalt", "repeat_dimension_m": 2.1, "normal_strength": 0.2},
	"road_path_pedestrian": {"asset": "concrete_pavement", "repeat_dimension_m": 1.8, "normal_strength": 0.2},
	"major_area_paved": {"asset": "concrete_floor_03", "repeat_dimension_m": 2.5, "normal_strength": 0.2},
	"land_ground": {"asset": "sparse_grass", "repeat_dimension_m": 5.0, "normal_strength": 0.2},
	"major_area_landuse": {"asset": "sparse_grass", "repeat_dimension_m": 5.0, "normal_strength": 0.2},
	"major_area_leisure": {"asset": "sparse_grass", "repeat_dimension_m": 5.0, "normal_strength": 0.2},
	"context_ybi": {"asset": "sparse_grass", "repeat_dimension_m": 5.0, "normal_strength": 0.2},
	"building_wall": {"asset": "plaster_grey_04", "repeat_dimension_m": 0.75, "normal_strength": 0.1},
	"building_part_wall": {"asset": "plaster_grey_04", "repeat_dimension_m": 0.75, "normal_strength": 0.1},
	"building_roof": {"asset": "bitumen", "repeat_dimension_m": 10.0, "normal_strength": 0.2},
	"building_part_roof": {"asset": "bitumen", "repeat_dimension_m": 10.0, "normal_strength": 0.2},
}

@onready var world_root: WorldLoader = $WorldRoot
@onready var player: PlayerController = $Player
@onready var hud: GameHUD = $Interface/HUD
@onready var world_environment: WorldEnvironment = $WorldEnvironment

var _world_ready := false
var _mac_export_smoke := false
var _mac_export_smoke_finished := false
var _mac_export_smoke_deadline_msec := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_mac_export_smoke = OS.get_cmdline_user_args().has(MAC_EXPORT_SMOKE_ARG)
	if _mac_export_smoke:
		_mac_export_smoke_deadline_msec = Time.get_ticks_msec() + int(MAC_EXPORT_SMOKE_TIMEOUT_SECONDS * 1000.0)
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


func _process(_delta: float) -> void:
	if _mac_export_smoke \
	and not _mac_export_smoke_finished \
	and _mac_export_smoke_deadline_msec >= 0 \
	and Time.get_ticks_msec() >= _mac_export_smoke_deadline_msec:
		_on_mac_export_smoke_timeout()


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
	and not _mac_export_smoke \
	and not get_tree().paused:
		_set_paused(true)


func _on_world_ready(report: Dictionary) -> void:
	player.configure_world(world_root.get_spawn_transform(), world_root.get_boundary())
	await player.startup_grounded
	if not world_root.is_world_validated() or not player.reveal_grounded():
		_on_world_failed("player_grounding", "Player could not settle on generated land before its first visible frame.", [])
		return
	_world_ready = true
	player.feedback_requested.connect(hud.show_feedback)
	player.spray_result.connect(world_root.get_runtime_evidence().record_spray)
	player.recovered.connect(world_root.get_runtime_evidence().record_recovery)
	player.get_spray_controller().spray_identity.connect(world_root.get_runtime_evidence().record_spray_identity)
	player.get_spray_controller().tag_instances.active_count_changed.connect(world_root.get_runtime_evidence().set_active_decals)
	player.get_spray_controller().tag_instances.oldest_tag_removed.connect(world_root.get_runtime_evidence().record_tag_eviction)
	world_root.get_runtime_evidence().bind_runtime(player, world_root.get_boundary())
	player.set_gameplay_enabled(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hud.show_world_ready()
	if _mac_export_smoke:
		_finish_mac_export_smoke(report)


func _on_world_failed(code: String, message: String, source_keys: Array) -> void:
	_world_ready = false
	player.hide()
	player.set_gameplay_enabled(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.show_load_error(code, message, source_keys)
	if _mac_export_smoke:
		_release_mac_export_smoke_input()
		push_error("MAC_EXPORT_WORLD_FAILED: code=%s message=%s sources=%s" % [code, message, source_keys])
		_mac_export_smoke_finished = true
		get_tree().quit(1)


func _finish_mac_export_smoke(report: Dictionary) -> void:
	var evidence := world_root.get_runtime_evidence()
	var spawn := world_root.get_spawn_transform()
	var visual_defaults_valid := _visual_defaults_valid()
	var semantic_materials_valid := _semantic_materials_valid()
	var movement_defaults_valid := _movement_defaults_valid()
	var valid := world_root.is_world_validated() \
		and str(report.get("content_sha256", "")) == EXPECTED_MANIFEST_HASH \
		and spawn.origin.is_equal_approx(EXPECTED_FERRY_SPAWN_ORIGIN) \
		and spawn.basis.is_equal_approx(Basis(Vector3.UP, EXPECTED_FERRY_SPAWN_YAW)) \
		and evidence.chunks_loaded == EXPECTED_CHUNKS \
		and evidence.chunks_expected == EXPECTED_CHUNKS \
		and evidence.playable_rows == EXPECTED_PLAYABLE_ROWS \
		and evidence.context_rows == EXPECTED_CONTEXT_ROWS \
		and evidence.mesh_instances == EXPECTED_MESHES \
		and evidence.surfaces == EXPECTED_SURFACES \
		and evidence.triangles == EXPECTED_TRIANGLES \
		and evidence.static_bodies == EXPECTED_STATIC_BODIES \
		and evidence.shapes == EXPECTED_STATIC_BODIES \
		and evidence.vegetation_seed == EXPECTED_VEGETATION_SEED \
		and evidence.vegetation_instances == EXPECTED_VEGETATION_INSTANCES \
		and evidence.vegetation_assets == EXPECTED_VEGETATION_ASSETS \
		and evidence.vegetation_multimesh_batches == EXPECTED_VEGETATION_BATCHES \
		and player.visible \
		and player.is_physics_processing() \
		and visual_defaults_valid \
		and semantic_materials_valid \
		and movement_defaults_valid
	print("MAC_EXPORT_WORLD_READY: hash=%s spawn=(%.3f,%.3f,%.3f) yaw=%.3f chunks=%d/%d coverage=%d+%d meshes=%d surfaces=%d triangles=%d bodies=%d shapes=%d vegetation=%d seed=%d batches=%d load_ms=%d" % [
		str(report.get("content_sha256", "")),
		spawn.origin.x,
		spawn.origin.y,
		spawn.origin.z,
		spawn.basis.get_euler().y,
		evidence.chunks_loaded,
		evidence.chunks_expected,
		evidence.playable_rows,
		evidence.context_rows,
		evidence.mesh_instances,
		evidence.surfaces,
		evidence.triangles,
		evidence.static_bodies,
		evidence.shapes,
		evidence.vegetation_instances,
		evidence.vegetation_seed,
		evidence.vegetation_multimesh_batches,
		evidence.load_duration_msec,
	])
	var environment := world_environment.environment
	var camera_pivot := player.get_node("CameraPivot") as PlayerCamera
	var spring_arm := camera_pivot.get_node("SpringArm3D") as SpringArm3D
	print("MAC_EXPORT_VISUAL: ambient_source=%d ambient_color=(%.2f,%.2f,%.2f,%.2f) ambient_energy=%.2f sky_contribution=%.2f camera_pivot_y=%.2f spring_length=%.2f pitch=%.1fdeg semantic_palette=%s" % [
		environment.ambient_light_source if environment != null else -1,
		environment.ambient_light_color.r if environment != null else -1.0,
		environment.ambient_light_color.g if environment != null else -1.0,
		environment.ambient_light_color.b if environment != null else -1.0,
		environment.ambient_light_color.a if environment != null else -1.0,
		environment.ambient_light_energy if environment != null else -1.0,
		environment.ambient_light_sky_contribution if environment != null else -1.0,
		camera_pivot.position.y,
		spring_arm.spring_length,
		rad_to_deg(spring_arm.rotation.x),
		"pass" if semantic_materials_valid else "fail",
	])
	print("MAC_EXPORT_MOVEMENT: walk=%.1fmps run=%.1fmps acceleration=%.1fmps2 braking=%.1fmps2 defaults=%s" % [
		player.walk_speed_mps,
		player.run_speed_mps,
		player.acceleration_mps2,
		player.braking_mps2,
		"pass" if movement_defaults_valid else "fail",
	])
	if not valid:
		_release_mac_export_smoke_input()
		push_error("MAC_EXPORT_SMOKE_FAIL: packaged ferry spawn, world counts, player gate, movement defaults, or visual defaults did not match the approved contract")
		_mac_export_smoke_finished = true
		get_tree().quit(1)
		return

	print("MAC_EXPORT_JETPACK_PHASE: grounding_start")
	var grounded := false
	for _frame in 120:
		await get_tree().physics_frame
		if player.is_on_floor():
			grounded = true
			break
	print("MAC_EXPORT_JETPACK_PHASE: grounding_complete grounded=%s" % grounded)
	if not grounded or not _action_has_physical_key("jetpack", KEY_SPACE):
		_release_mac_export_smoke_input()
		push_error("MAC_EXPORT_SMOKE_FAIL: packaged player did not ground or jetpack is not bound to physical Space")
		_mac_export_smoke_finished = true
		get_tree().quit(1)
		return

	var start_y := player.global_position.y
	print("MAC_EXPORT_JETPACK_PHASE: ascent_start y=%.3f" % start_y)
	Input.action_press("jetpack")
	for _frame in 45:
		await get_tree().physics_frame
	Input.action_release("jetpack")
	var rise := player.global_position.y - start_y
	var ascent_velocity := player.velocity.y
	print("MAC_EXPORT_JETPACK_PHASE: ascent_complete rise=%.3f velocity=%.3f" % [rise, ascent_velocity])
	var reached_slow_descent := false
	for _frame in 90:
		await get_tree().physics_frame
		if player.velocity.y <= -player.jetpack_descent_speed_mps + 0.05:
			reached_slow_descent = true
			break
	print("MAC_EXPORT_JETPACK_PHASE: descent_threshold reached=%s velocity=%.3f" % [reached_slow_descent, player.velocity.y])
	var descent_start_y := player.global_position.y
	var minimum_velocity_y := player.velocity.y
	if reached_slow_descent:
		for _frame in 12:
			await get_tree().physics_frame
			minimum_velocity_y = minf(minimum_velocity_y, player.velocity.y)
	var descent := descent_start_y - player.global_position.y
	_release_mac_export_smoke_input()
	var jetpack_valid := rise > 1.5 \
		and ascent_velocity > 0.0 \
		and ascent_velocity <= player.jetpack_ascent_speed_mps + 0.01 \
		and reached_slow_descent \
		and descent > 0.1 \
		and descent < 0.5 \
		and minimum_velocity_y >= -player.jetpack_descent_speed_mps - 0.01
	print("MAC_EXPORT_JETPACK: rise=%.3fm ascent_velocity=%.3fmps slow_descent=%.3fm minimum_velocity=%.3fmps" % [
		rise,
		ascent_velocity,
		descent,
		minimum_velocity_y,
	])
	if not jetpack_valid:
		push_error("MAC_EXPORT_SMOKE_FAIL: packaged jetpack ascent or slow-descent contract failed")
		_mac_export_smoke_finished = true
		get_tree().quit(1)
		return
	print("PASS: packaged main scene reached full world_ready, verified movement defaults, enabled the player, and exercised jetpack rise/slow descent")
	_mac_export_smoke_finished = true
	get_tree().quit(0)


func _on_mac_export_smoke_timeout() -> void:
	if _mac_export_smoke and not _mac_export_smoke_finished:
		_release_mac_export_smoke_input()
		push_error("MAC_EXPORT_SMOKE_TIMEOUT: packaged main scene did not finish world/jetpack checks within %.0f seconds of monotonic wall time" % MAC_EXPORT_SMOKE_TIMEOUT_SECONDS)
		_mac_export_smoke_finished = true
		get_tree().quit(1)


func _release_mac_export_smoke_input() -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		if InputMap.has_action(action):
			Input.action_release(action)


func _action_has_physical_key(action: StringName, physical_keycode: Key) -> bool:
	if not InputMap.has_action(action):
		return false
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == physical_keycode:
			return true
	return false


func _visual_defaults_valid() -> bool:
	var environment := world_environment.environment
	var camera_pivot := player.get_node("CameraPivot") as PlayerCamera
	var spring_arm := camera_pivot.get_node("SpringArm3D") as SpringArm3D
	return environment != null \
		and environment.ambient_light_source == Environment.AMBIENT_SOURCE_COLOR \
		and environment.ambient_light_color.is_equal_approx(Color(0.71, 0.77, 0.82, 1.0)) \
		and is_equal_approx(environment.ambient_light_energy, 0.65) \
		and is_zero_approx(environment.ambient_light_sky_contribution) \
		and is_equal_approx(camera_pivot.position.y, 2.0) \
		and is_equal_approx(spring_arm.spring_length, 5.5) \
		and is_equal_approx(spring_arm.rotation.x, deg_to_rad(-8.0))


func _movement_defaults_valid() -> bool:
	return is_equal_approx(player.walk_speed_mps, EXPECTED_WALK_SPEED_MPS) \
		and is_equal_approx(player.run_speed_mps, EXPECTED_RUN_SPEED_MPS) \
		and is_equal_approx(player.acceleration_mps2, EXPECTED_ACCELERATION_MPS2) \
		and is_equal_approx(player.braking_mps2, EXPECTED_BRAKING_MPS2)


func _semantic_materials_valid() -> bool:
	var found := {}
	for node: Node in world_root.find_children("*", "Node3D", true, false):
		if not node.has_meta("feature_kind"):
			continue
		var mesh_instance := node.get_node_or_null("Mesh") as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		for surface_index in mesh_instance.mesh.get_surface_count():
			var material := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
			if material == null or not MAC_EXPORT_EXPECTED_MATERIALS.has(material.resource_name):
				continue
			var expected: Dictionary = MAC_EXPORT_EXPECTED_MATERIALS[material.resource_name]
			var asset := str(expected.asset)
			var prefix := "%s/%s/%s" % [POLYHAVEN_TEXTURE_ROOT, asset, asset]
			var uv_scale := 10.0 / float(expected.repeat_dimension_m)
			if material.albedo_texture == null or material.albedo_texture.resource_path != "%s_diff_1k.jpg" % prefix \
			or material.normal_texture == null or material.normal_texture.resource_path != "%s_nor_gl_1k.jpg" % prefix \
			or material.roughness_texture == null or material.roughness_texture.resource_path != "%s_rough_1k.jpg" % prefix \
			or not material.normal_enabled or not is_equal_approx(material.normal_scale, float(expected.normal_strength)) \
			or not is_equal_approx(material.uv1_scale.x, uv_scale) or not is_equal_approx(material.uv1_scale.y, uv_scale) \
			or not is_equal_approx(material.uv1_scale.z, 1.0) \
			or not material.get_flag(BaseMaterial3D.FLAG_USE_TEXTURE_REPEAT) \
			or material.texture_filter != BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC \
			or material.heightmap_enabled:
				return false
			found[material.resource_name] = true
	return found.size() == MAC_EXPORT_EXPECTED_MATERIALS.size()


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
	hud.set_paused(paused)


func _resume_game() -> void:
	if _world_ready:
		_set_paused(false)


func _exit_game() -> void:
	get_tree().quit()
