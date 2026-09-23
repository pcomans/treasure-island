class_name GameMain
extends Node3D

const MAC_EXPORT_SMOKE_ARG := "--mac-export-smoke"
const MAC_EXPORT_SMOKE_TIMEOUT_SECONDS := 60.0
const EXPECTED_MANIFEST_HASH := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const EXPECTED_CHUNKS := 38
const EXPECTED_PLAYABLE_ROWS := 735
const EXPECTED_CONTEXT_ROWS := 4
const EXPECTED_MESHES := 1260
const EXPECTED_SURFACES := 1275
const EXPECTED_TRIANGLES := 176165
const EXPECTED_STATIC_BODIES := 496
const EXPECTED_SHAPES := 646
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
	var d2_1439_attachment_valid := _mac_export_1439_attachment_valid()
	var d2_1444_attachment_valid := _mac_export_1444_attachment_valid()
	var d5_1308_attachment_valid := _mac_export_1308_attachment_valid()
	var d5_1394_attachment_valid := _mac_export_1394_attachment_valid()
	var d5_1317_attachment_valid := _mac_export_1317_attachment_valid()
	var fire_station48_attachment_valid := _mac_export_fire_station48_attachment_valid()
	var maceo_may_attachment_valid := _mac_export_maceo_may_attachment_valid()
	var northern_1201_attachment_valid := _mac_export_1201_attachment_valid()
	var northpoint_1238_attachment_valid := _mac_export_1238_attachment_valid()
	var mariner_1206_attachment_valid := _mac_export_1206_attachment_valid()
	var mariner_1219_attachment_valid := _mac_export_1219_attachment_valid()
	var family_1212_attachment_valid: bool = _mac_export_1212_attachment_valid()
	var family_1220_attachment_valid: bool = _mac_export_1220_attachment_valid()
	var family_1239_attachment_valid: bool = _mac_export_1239_attachment_valid()
	var projected_1222_attachment_valid: bool = _mac_export_projected_family_attachment_valid(preload("res://game/scripts/world/facades/bayside_1222_live_replacement.gd"), "1222")
	var projected_1227_attachment_valid: bool = _mac_export_projected_family_attachment_valid(preload("res://game/scripts/world/facades/northpoint_1227_live_replacement.gd"), "1227")
	var projected_1202_attachment_valid: bool = _mac_export_projected_family_attachment_valid(preload("res://game/scripts/world/facades/mariner_1202_live_replacement.gd"), "1202")
	var projected_1234_attachment_valid: bool = _mac_export_projected_family_attachment_valid(preload("res://game/scripts/world/facades/northpoint_1234_live_replacement.gd"), "1234")
	var projected_1215_attachment_valid: bool = _mac_export_projected_family_attachment_valid(preload("res://game/scripts/world/facades/bayside_1215_live_replacement.gd"), "1215")
	var projected_1232_attachment_valid: bool = _mac_export_projected_family_attachment_valid(preload("res://game/scripts/world/facades/northpoint_1232_live_replacement.gd"), "1232")
	var projected_1241_attachment_valid: bool = _mac_export_projected_family_attachment_valid(preload("res://game/scripts/world/facades/northpoint_1241_live_replacement.gd"), "1241")
	var projected_1221_attachment_valid: bool = _mac_export_projected_family_attachment_valid(preload("res://game/scripts/world/facades/mariner_1221_live_replacement.gd"), "1221")
	var projected_1240_attachment_valid: bool = _mac_export_projected_family_attachment_valid(preload("res://game/scripts/world/facades/northpoint_1240_live_replacement.gd"), "1240")
	var spawn := world_root.get_spawn_transform()
	var visual_defaults_valid := _visual_defaults_valid()
	var semantic_materials_valid := _semantic_materials_valid()
	var movement_defaults_valid := _movement_defaults_valid()
	var valid := world_root.is_world_validated() \
		and d2_1439_attachment_valid \
		and d2_1444_attachment_valid \
		and d5_1308_attachment_valid \
		and d5_1394_attachment_valid \
		and d5_1317_attachment_valid \
		and fire_station48_attachment_valid \
		and maceo_may_attachment_valid \
		and northern_1201_attachment_valid \
		and northpoint_1238_attachment_valid \
		and mariner_1206_attachment_valid \
		and mariner_1219_attachment_valid \
		and family_1212_attachment_valid \
		and family_1220_attachment_valid \
		and projected_1222_attachment_valid \
		and projected_1227_attachment_valid \
		and projected_1202_attachment_valid \
		and projected_1234_attachment_valid \
		and projected_1215_attachment_valid \
		and projected_1232_attachment_valid \
		and projected_1241_attachment_valid \
		and projected_1221_attachment_valid \
		and projected_1240_attachment_valid \
		and family_1239_attachment_valid \
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
		and evidence.shapes == EXPECTED_SHAPES \
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


func _mac_export_1439_attachment_valid() -> bool:
	var walls: Array[Node3D] = []
	var roofs: Array[Node3D] = []
	for node: Node in world_root.find_children("*", "Node3D", true, false):
		if not node.has_meta("feature_kind"):
			continue
		var key := str(node.get_meta("derived_object_key", ""))
		if key == "building:w95934144:wall":
			walls.append(node as Node3D)
		elif key == "building:w95934144:roof":
			roofs.append(node as Node3D)
	if walls.size() != 1 or roofs.size() != 1:
		print("MAC_EXPORT_D2_1439_ATTACHMENT: invalid pair count wall=%d roof=%d" % [walls.size(), roofs.size()])
		return false
	var wall := walls[0]
	var roof := roofs[0]
	var wall_measure := _mac_export_attachment_measure(wall)
	var roof_measure := _mac_export_attachment_measure(roof)
	var metadata := wall.get_meta("d2_1439_chinook_live_replacement", {}) as Dictionary
	var valid := wall.name == "D21439ChinookLiveWallReplacement" and roof.name == "D21439ChinookLiveRoofReplacement" \
		and wall_measure == {"meshes": 10, "surfaces": 10, "triangles": 512, "bodies": 1, "shapes": 2} \
		and roof_measure == {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1} \
		and metadata == (roof.get_meta("d2_1439_chinook_live_replacement", {}) as Dictionary) \
		and str(metadata.get("geometry_signature", "")) == "81a05d20b03e16253675a36692c9856cf4d53509e008aacbb69bbe4eea7683e5" \
		and str(metadata.get("live_ownership_signature", "")) == "82e1fdfae492aa1942bbbb5cfb65b51d4da4c980cf85a4231c2093aaf3edc27a" \
		and str(metadata.get("accepted_recognition_metric", "")) == "9/213" \
		and int(metadata.get("candidate_recognition_credit", -1)) == 0 \
		and not bool(metadata.get("recognition_accepted", true))
	print("MAC_EXPORT_D2_1439_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s geometry=%s ownership=%s recognition=9/213 credit=0" % [valid, wall.get_path(), roof.get_path(), wall_measure, roof_measure, metadata.get("geometry_signature", ""), metadata.get("live_ownership_signature", "")])
	return valid


func _mac_export_attachment_measure(attachment: Node3D) -> Dictionary:
	var result := {"meshes": 0, "surfaces": 0, "triangles": 0, "bodies": 0, "shapes": 0}
	for node: Node in attachment.find_children("*", "", true, false):
		if node is MeshInstance3D:
			var mesh := (node as MeshInstance3D).mesh
			result.meshes += 1
			result.surfaces += mesh.get_surface_count()
			result.triangles += int(mesh.get_faces().size() / 3)
		elif node is StaticBody3D:
			result.bodies += 1
		elif node is CollisionShape3D:
			result.shapes += 1
	return result


func _mac_export_1444_attachment_valid() -> bool:
	var walls: Array[Node3D] = []
	var roofs: Array[Node3D] = []
	for node: Node in world_root.find_children("*", "Node3D", true, false):
		if not node.has_meta("feature_kind"):
			continue
		var key := str(node.get_meta("derived_object_key", ""))
		if key == "building:w95934117:wall":
			walls.append(node as Node3D)
		elif key == "building:w95934117:roof":
			roofs.append(node as Node3D)
	if walls.size() != 1 or roofs.size() != 1:
		print("MAC_EXPORT_D2_1444_ATTACHMENT: invalid pair count wall=%d roof=%d" % [walls.size(), roofs.size()])
		return false
	var wall := walls[0]
	var roof := roofs[0]
	var wall_measure := _mac_export_attachment_measure(wall)
	var roof_measure := _mac_export_attachment_measure(roof)
	var metadata := wall.get_meta("d2_1444_croaker_live_replacement", {}) as Dictionary
	var valid := wall.name == "D21444CroakerLiveWallReplacement" and roof.name == "D21444CroakerLiveRoofReplacement" \
		and wall_measure == {"meshes": 10, "surfaces": 10, "triangles": 716, "bodies": 1, "shapes": 2} \
		and roof_measure == {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1} \
		and metadata == (roof.get_meta("d2_1444_croaker_live_replacement", {}) as Dictionary) \
		and str(metadata.get("geometry_signature", "")) == "1dba8f84003a0818c2ddb91504f41c3437a63fe0856ade70d1c194ca1be8d141" \
		and str(metadata.get("live_ownership_signature", "")) == "979910c4d53486b86db04cdf04528789f668a01c41dc27114e481c843b91b92d" \
		and str(metadata.get("accepted_recognition_metric", "")) == "9/213" \
		and int(metadata.get("candidate_recognition_credit", -1)) == 0 \
		and not bool(metadata.get("recognition_accepted", true))
	print("MAC_EXPORT_D2_1444_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s geometry=%s ownership=%s recognition=9/213 credit=0" % [valid, wall.get_path(), roof.get_path(), wall_measure, roof_measure, metadata.get("geometry_signature", ""), metadata.get("live_ownership_signature", "")])
	return valid


func _mac_export_1308_attachment_valid() -> bool:
	var walls: Array[Node3D] = []
	var roofs: Array[Node3D] = []
	for node: Node in world_root.find_children("*", "Node3D", true, false):
		if not node.has_meta("feature_kind"):
			continue
		var key := str(node.get_meta("derived_object_key", ""))
		if key == "building:w95934123:wall":
			walls.append(node as Node3D)
		elif key == "building:w95934123:roof":
			roofs.append(node as Node3D)
	if walls.size() != 1 or roofs.size() != 1:
		print("MAC_EXPORT_D5_1308_ATTACHMENT: invalid pair count wall=%d roof=%d" % [walls.size(), roofs.size()])
		return false
	var wall := walls[0]
	var roof := roofs[0]
	var wall_measure := _mac_export_attachment_measure(wall)
	var roof_measure := _mac_export_attachment_measure(roof)
	var metadata := wall.get_meta("d5_1308_gateview_live_replacement", {}) as Dictionary
	var valid := wall.name == "D51308GateviewLiveWallReplacement" and roof.name == "D51308GateviewLiveRoofReplacement" \
		and wall_measure == {"meshes": 14, "surfaces": 14, "triangles": 3469, "bodies": 1, "shapes": 4} \
		and roof_measure == {"meshes": 3, "surfaces": 3, "triangles": 1402, "bodies": 1, "shapes": 2} \
		and metadata == (roof.get_meta("d5_1308_gateview_live_replacement", {}) as Dictionary) \
		and str(metadata.get("adapter_id", "")) == "active-adapter:d5-1308-live:building:w95934123:wall" \
		and str(metadata.get("source_geometry_sha256", "")) == "6028c89be31ebfd095777b86f6d5d4a9094002b7b5fd73efb2fc940f9a9f3917" \
		and int(metadata.get("factory_calls", -1)) == 1 \
		and str(metadata.get("accepted_recognition_metric", "")) == "13/213" \
		and int(metadata.get("candidate_recognition_credit", -1)) == 0 \
		and not bool(metadata.get("recognition_accepted", true)) \
		and not bool(metadata.get("partial_pair_allowed", true)) \
		and not bool(metadata.get("fallback_allowed", true)) \
		and not bool(metadata.get("stack_allowed", true)) \
		and bool(wall.get_meta("runtime_attachment", false)) and bool(roof.get_meta("runtime_attachment", false)) \
		and not bool(wall.get_meta("prototype_only", true)) and not bool(roof.get_meta("prototype_only", true))
	print("MAC_EXPORT_D5_1308_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s source_geometry=%s captured_authority=13/213 credit=0" % [valid, wall.get_path(), roof.get_path(), wall_measure, roof_measure, metadata.get("source_geometry_sha256", "")])
	return valid


func _mac_export_1394_attachment_valid() -> bool:
	var walls: Array[Node3D] = []
	var roofs: Array[Node3D] = []
	for node: Node in world_root.find_children("*", "Node3D", true, false):
		if not node.has_meta("feature_kind"):
			continue
		var key := str(node.get_meta("derived_object_key", ""))
		if key == "building:w96215646:wall":
			walls.append(node as Node3D)
		elif key == "building:w96215646:roof":
			roofs.append(node as Node3D)
	if walls.size() != 1 or roofs.size() != 1:
		print("MAC_EXPORT_D5_1394_ATTACHMENT: invalid pair count wall=%d roof=%d" % [walls.size(), roofs.size()])
		return false
	var wall := walls[0]
	var roof := roofs[0]
	var wall_measure := _mac_export_attachment_measure(wall)
	var roof_measure := _mac_export_attachment_measure(roof)
	var metadata := wall.get_meta("d5_1394_gateview_live_replacement", {}) as Dictionary
	var valid := wall.name == "D51394GateviewLiveWallReplacement" and roof.name == "D51394GateviewLiveRoofReplacement" \
		and wall_measure == {"meshes": 15, "surfaces": 15, "triangles": 3352, "bodies": 1, "shapes": 3} \
		and roof_measure == {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1} \
		and metadata == (roof.get_meta("d5_1394_gateview_live_replacement", {}) as Dictionary) \
		and str(metadata.get("adapter_id", "")) == "active-adapter:d5-1394-live:building:w96215646:wall" \
		and str(metadata.get("source_geometry_sha256", "")) == "b0e6c7426ac41c995f96a647ff5102b4d85963d2b7a45f21ad1b81455e451220" \
		and int(metadata.get("factory_calls", -1)) == 1 \
		and str(metadata.get("accepted_recognition_metric", "")) == "13/213" \
		and int(metadata.get("candidate_recognition_credit", -1)) == 0 \
		and not bool(metadata.get("recognition_accepted", true)) \
		and not bool(metadata.get("partial_pair_allowed", true)) \
		and not bool(metadata.get("fallback_allowed", true)) \
		and not bool(metadata.get("stack_allowed", true)) \
		and bool(wall.get_meta("runtime_attachment", false)) and bool(roof.get_meta("runtime_attachment", false)) \
		and not bool(wall.get_meta("prototype_only", true)) and not bool(roof.get_meta("prototype_only", true))
	print("MAC_EXPORT_D5_1394_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s source_geometry=%s captured_authority=13/213 credit=0" % [valid, wall.get_path(), roof.get_path(), wall_measure, roof_measure, metadata.get("source_geometry_sha256", "")])
	return valid


func _mac_export_1317_attachment_valid() -> bool:
	var walls: Array[Node3D] = []
	var roofs: Array[Node3D] = []
	for node: Node in world_root.find_children("*", "Node3D", true, false):
		if not node.has_meta("feature_kind"):
			continue
		var key := str(node.get_meta("derived_object_key", ""))
		if key == "building:w95934125:wall":
			walls.append(node as Node3D)
		elif key == "building:w95934125:roof":
			roofs.append(node as Node3D)
	if walls.size() != 1 or roofs.size() != 1:
		print("MAC_EXPORT_D5_1317_ATTACHMENT: invalid pair count wall=%d roof=%d" % [walls.size(), roofs.size()])
		return false
	var wall := walls[0]
	var roof := roofs[0]
	var wall_measure := _mac_export_attachment_measure(wall)
	var roof_measure := _mac_export_attachment_measure(roof)
	var metadata := wall.get_meta("d5_1317_gateview_live_replacement", {}) as Dictionary
	var valid := wall.name == "D51317GateviewLiveWallReplacement" and roof.name == "D51317GateviewLiveRoofReplacement" \
		and wall_measure == {"meshes": 12, "surfaces": 12, "triangles": 1808, "bodies": 1, "shapes": 3} \
		and roof_measure == {"meshes": 2, "surfaces": 2, "triangles": 130, "bodies": 1, "shapes": 2} \
		and metadata == (roof.get_meta("d5_1317_gateview_live_replacement", {}) as Dictionary) \
		and str(metadata.get("adapter_id", "")) == "active-adapter:d5-1317-live:building:w95934125:wall" \
		and str(metadata.get("accepted_art002_geometry_sha256", "")) == "48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9" \
		and int(metadata.get("factory_calls", -1)) == 1 \
		and str(metadata.get("captured_authority_metric", "")) == "13/213" \
		and int(metadata.get("candidate_recognition_credit", -1)) == 0 \
		and not bool(metadata.get("recognition_accepted", true)) \
		and not bool(metadata.get("partial_pair_allowed", true)) \
		and not bool(metadata.get("fallback_allowed", true)) \
		and not bool(metadata.get("stack_allowed", true)) \
		and bool(wall.get_meta("runtime_attachment", false)) and bool(roof.get_meta("runtime_attachment", false)) \
		and not bool(wall.get_meta("prototype_only", true)) and not bool(roof.get_meta("prototype_only", true))
	print("MAC_EXPORT_D5_1317_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s source_geometry=%s captured_authority=13/213 credit=0" % [valid, wall.get_path(), roof.get_path(), wall_measure, roof_measure, metadata.get("accepted_art002_geometry_sha256", "")])
	return valid


func _mac_export_fire_station48_attachment_valid() -> bool:
	var walls: Array[Node3D] = []
	var roofs: Array[Node3D] = []
	for node: Node in world_root.find_children("*", "Node3D", true, false):
		if not node.has_meta("feature_kind"):
			continue
		var key := str(node.get_meta("derived_object_key", ""))
		if key == "building:w764313741:wall":
			walls.append(node as Node3D)
		elif key == "building:w764313741:roof":
			roofs.append(node as Node3D)
	if walls.size() != 1 or roofs.size() != 1:
		print("MAC_EXPORT_FIRE_STATION48_ATTACHMENT: invalid pair count wall=%d roof=%d" % [walls.size(), roofs.size()])
		return false
	var wall := walls[0]
	var roof := roofs[0]
	var wall_measure := _mac_export_attachment_measure(wall)
	var roof_measure := _mac_export_attachment_measure(roof)
	var metadata := wall.get_meta("fire_station48_live_replacement", {}) as Dictionary
	var valid := wall.name == "FireStation48LiveWallReplacement" and roof.name == "FireStation48LiveRoofReplacement" \
		and wall_measure == {"meshes": 6, "surfaces": 6, "triangles": 1080, "bodies": 1, "shapes": 1} \
		and roof_measure == {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1} \
		and metadata == (roof.get_meta("fire_station48_live_replacement", {}) as Dictionary) \
		and str(metadata.get("adapter_id", "")) == "active-adapter:fire-station48-live:building:w764313741:wall" \
		and str(metadata.get("accepted_study002_geometry_sha256", "")) == "e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597" \
		and int(metadata.get("factory_calls", -1)) == 1 \
		and bool(metadata.get("source_collision_only", false)) and bool(metadata.get("all_additions_render_only", false)) \
		and str(metadata.get("captured_authority_metric", "")) == "14/213" \
		and int(metadata.get("candidate_recognition_credit", -1)) == 0 \
		and not bool(metadata.get("recognition_accepted", true)) \
		and not bool(metadata.get("partial_pair_allowed", true)) \
		and not bool(metadata.get("fallback_allowed", true)) \
		and not bool(metadata.get("stack_allowed", true)) \
		and bool(wall.get_meta("runtime_attachment", false)) and bool(roof.get_meta("runtime_attachment", false)) \
		and not bool(wall.get_meta("prototype_only", true)) and not bool(roof.get_meta("prototype_only", true))
	print("MAC_EXPORT_FIRE_STATION48_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s source_geometry=%s captured_authority=14/213 credit=0" % [valid, wall.get_path(), roof.get_path(), wall_measure, roof_measure, metadata.get("accepted_study002_geometry_sha256", "")])
	return valid


func _mac_export_maceo_may_attachment_valid() -> bool:
	var walls: Array[Node3D] = []
	var roofs: Array[Node3D] = []
	for node: Node in world_root.find_children("*", "Node3D", true, false):
		if not node.has_meta("feature_kind"):
			continue
		var key := str(node.get_meta("derived_object_key", ""))
		if key == "building:r19685981:wall":
			walls.append(node as Node3D)
		elif key == "building:r19685981:roof":
			roofs.append(node as Node3D)
	if walls.size() != 1 or roofs.size() != 1:
		print("MAC_EXPORT_MACEO_MAY_ATTACHMENT: invalid pair count wall=%d roof=%d" % [walls.size(), roofs.size()])
		return false
	var wall := walls[0]
	var roof := roofs[0]
	var wall_measure := _mac_export_attachment_measure(wall)
	var roof_measure := _mac_export_attachment_measure(roof)
	var metadata := wall.get_meta("maceo_may_live_replacement", {}) as Dictionary
	var valid := wall.name == "MaceoMayLiveWallReplacement" and roof.name == "MaceoMayLiveRoofReplacement" \
		and wall_measure == {"meshes": 10, "surfaces": 10, "triangles": 16420, "bodies": 1, "shapes": 2} \
		and roof_measure == {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1} \
		and metadata == (roof.get_meta("maceo_may_live_replacement", {}) as Dictionary) \
		and str(metadata.get("adapter_id", "")) == "active-adapter:maceo-may-live:building:r19685981:wall" \
		and str(metadata.get("curtain_repaired_geometry_sha256", "")) == "4caf46d6c3ebb1ef497fbe8012e5f1fd938a055e11a4132c04ed8e6827da12b3" \
		and int(metadata.get("factory_calls", -1)) == 1 \
		and not bool(metadata.get("source_collision_only", true)) and not bool(metadata.get("all_additions_render_only", true)) \
		and str(metadata.get("added_collision_scope", "")) == "Five unchanged visible round columns, separate nonreceiver shape" \
		and str(metadata.get("captured_authority_metric", "")) == "14/213" \
		and int(metadata.get("candidate_recognition_credit", -1)) == 0 \
		and not bool(metadata.get("recognition_accepted", true)) \
		and not bool(metadata.get("partial_pair_allowed", true)) \
		and not bool(metadata.get("fallback_allowed", true)) \
		and not bool(metadata.get("stack_allowed", true)) \
		and bool(wall.get_meta("runtime_attachment", false)) and bool(roof.get_meta("runtime_attachment", false)) \
		and not bool(wall.get_meta("prototype_only", true)) and not bool(roof.get_meta("prototype_only", true))
	print("MAC_EXPORT_MACEO_MAY_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s source_geometry=%s captured_authority=14/213 credit=0" % [valid, wall.get_path(), roof.get_path(), wall_measure, roof_measure, metadata.get("curtain_repaired_geometry_sha256", "")])
	return valid


func _mac_export_1201_attachment_valid() -> bool:
	return _mac_export_northern_attachment_valid(NorthernCanopyFreeLiveReplacement, "1201", 10)


func _mac_export_1238_attachment_valid() -> bool:
	return _mac_export_northern_attachment_valid(Northpoint1238LiveReplacement, "1238", 16)


func _mac_export_northern_attachment_valid(adapter: Script, unit: String, roof_triangles: int) -> bool:
	var buildings := world_root.get_node_or_null("PlayableWorld/Buildings")
	if buildings == null:
		return false
	var roots: Dictionary = {}
	for key: String in [adapter.WALL_KEY, adapter.ROOF_KEY]:
		var matches: Array[Node3D] = []
		# Only category children own attachments; nested original collision roots share source keys.
		for proxy: Node in buildings.get_children():
			for child: Node in proxy.get_children():
				if child is Node3D and str(child.get_meta("derived_object_key", "")) == key:
					matches.append(child as Node3D)
		if matches.size() != 1:
			print("MAC_EXPORT_%s_ATTACHMENT: invalid pair count key=%s count=%d" % [unit, key, matches.size()])
			return false
		var outer := matches[0]
		var proxy := outer.get_parent()
		if str(proxy.name) != "%s__%s" % [adapter.TARGET_CHUNK_ID, key.validate_node_name()] or proxy.get_child_count() != 1 or proxy.has_meta("target_parent"):
			return false
		roots[key] = outer
	var valid := _mac_export_northern_pair_valid(roots[adapter.WALL_KEY], roots[adapter.ROOF_KEY], adapter, roof_triangles)
	print("MAC_EXPORT_%s_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s source=%s credit=0" % [unit, valid, roots[adapter.WALL_KEY].get_path(), roots[adapter.ROOF_KEY].get_path(), _mac_export_attachment_measure(roots[adapter.WALL_KEY]), _mac_export_attachment_measure(roots[adapter.ROOF_KEY]), adapter.SOURCE_KEY])
	return valid


func _mac_export_northern_pair_valid(wall: Node3D, roof: Node3D, adapter: Script, roof_triangles: int) -> bool:
	if wall == null or roof == null or wall == roof:
		return false
	var is_1201: bool = adapter.SOURCE_KEY == "w96215672"
	var prefix := "NorthernCanopyFreeLive" if is_1201 else "Northpoint1238Live"
	if str(wall.name) != prefix + "Wall" or str(roof.name) != prefix + "Roof" \
	or _mac_export_attachment_measure(wall) != {"meshes": 10, "surfaces": 10, "triangles": 4940, "bodies": 2, "shapes": 8} \
	or _mac_export_attachment_measure(roof) != {"meshes": 1, "surfaces": 1, "triangles": roof_triangles, "bodies": 1, "shapes": 1}:
		return false
	var chunk: Dictionary = adapter.FACTORY._json(adapter.FACTORY.CHUNK_PATH)
	var prepared: Dictionary = adapter.prepare_chunk_records(chunk)
	if not bool(prepared.get("ok", false)) or not bool(prepared.get("contains_target", false)):
		return false
	for spec: Array in [[wall, adapter.WALL_KEY, true], [roof, adapter.ROOF_KEY, false]]:
		var outer: Node3D = spec[0]
		var key: String = spec[1]
		var is_wall: bool = spec[2]
		var receiver := "building_wall" if is_wall else "none"
		if outer.transform != Transform3D.IDENTITY or str(outer.get_meta("adapter_id", "")) != adapter.ADAPTER_ID \
		or str(outer.get_meta("derived_object_key", "")) != key or outer.get_meta("source_keys", []) != [adapter.SOURCE_KEY] \
		or str(outer.get_meta("feature_kind", "")) != ("building_wall" if is_wall else "building_roof") \
		or str(outer.get_meta("receiver_kind", "")) != receiver or not bool(outer.get_meta("runtime_attachment", false)) \
		or bool(outer.get_meta("prototype_only", true)) or bool(outer.get_meta("recognition_accepted", true)) \
		or not bool(outer.get_meta("runtime_supersedes_generated_placeholder", false)) \
		or outer.get_meta("superseded_object_keys", []) != [adapter.WALL_KEY, adapter.ROOF_KEY]:
			return false
		var original := outer.get_node_or_null("OriginalWallRecord" if is_wall else "OriginalRoofRecord") as Node3D
		var body := original.get_node_or_null("Collision") as StaticBody3D if original != null else null
		if original == null or original.transform != Transform3D.IDENTITY or original.get_child_count() != 1 \
		or body == null or body.transform != Transform3D.IDENTITY or body.get_child_count() != 1 \
		or body.collision_layer != 5 or body.collision_mask != 0 or body.is_in_group("spray_receiver_wall") != is_wall:
			return false
		var shape := body.get_child(0) as CollisionShape3D
		if shape == null or shape.transform != Transform3D.IDENTITY or shape.disabled or not shape.shape is ConcavePolygonShape3D:
			return false
		# The raw builder owns metadata on the body and shape resource, not the shape node.
		for object: Object in [body, shape.shape]:
			if str(object.get_meta("derived_object_key", "")) != key or object.get_meta("source_keys", []) != [adapter.SOURCE_KEY] \
			or str(object.get_meta("receiver_kind", "")) != receiver or not bool(object.get_meta("opaque", false)):
				return false
		var record: Dictionary = prepared.source_records[key]
		var expected := PackedVector3Array()
		for offset in range(0, record.indices.size(), 3):
			for index: int in [int(record.indices[offset]), int(record.indices[offset + 2]), int(record.indices[offset + 1])]:
				expected.append(Vector3(float(record.vertices[index * 3]), float(record.vertices[index * 3 + 1]), float(record.vertices[index * 3 + 2])))
		if var_to_bytes(shape.shape.get_faces()) != var_to_bytes(expected):
			return false
		for child: Node in outer.get_children():
			if child is MeshInstance3D:
				if child.transform != Transform3D.IDENTITY or str(child.get_meta("derived_object_key", "")) != key \
				or child.get_meta("source_keys", []) != [adapter.SOURCE_KEY] or not bool(child.get_meta("runtime_attachment", false)) \
				or bool(child.get_meta("prototype_only", true)) or child.layers != (2 if str(child.name) in ["ExactOriginalWallSurfaces", "NearHorizontalSiding"] else 1):
					return false
	if wall.get_node_or_null("ExactSourceNeutralRoof") != null or wall.get_node_or_null("OriginalRoofRecord") != null \
	or roof.get_child_count() != 2 or roof.get_node_or_null("ExactSourceNeutralRoof") == null \
	or wall.get_meta("mapped_public_run_indices", []) != adapter.MAPPED_RUNS or wall.get_meta("protected_run_indices", []) != adapter.PROTECTED_RUNS:
		return false
	var detail := wall.get_node_or_null("PhysicalDetails_NoSprayReceiver") as StaticBody3D
	if detail == null or detail.transform != Transform3D.IDENTITY or detail.get_child_count() != 7 \
	or detail.collision_layer != 5 or detail.collision_mask != 0 or detail.is_in_group("spray_receiver_wall") \
	or str(detail.get_meta("receiver_kind", "")) != "none" or str(detail.get_meta("derived_object_key", "")) != "prototype:" + adapter.WALL_KEY \
	or detail.get_meta("source_keys", []) != [adapter.SOURCE_KEY] or str(detail.get_meta("feature_kind", "")) != "bounded_facade_detail":
		return false
	for index in adapter.FACTORY.PHYSICAL_BUCKETS.size():
		var label: String = adapter.FACTORY.PHYSICAL_BUCKETS[index]
		var shape := detail.get_child(index) as CollisionShape3D
		var mesh := wall.get_node_or_null(NodePath(label)) as MeshInstance3D
		if shape == null or mesh == null or mesh.mesh == null or shape.transform != Transform3D.IDENTITY or shape.disabled \
		or str(shape.name) != label or not shape.shape is ConcavePolygonShape3D \
		or str(shape.shape.get_meta("receiver_kind", "")) != "none" or str(shape.shape.get_meta("structural_role", "")) != label:
			return false
		var arrays: Array = mesh.mesh.surface_get_arrays(0)
		var expected := PackedVector3Array()
		for vertex: int in arrays[Mesh.ARRAY_INDEX]:
			expected.append(arrays[Mesh.ARRAY_VERTEX][vertex])
		if var_to_bytes(shape.shape.get_faces()) != var_to_bytes(expected):
			return false
	return true


func _mac_export_1206_attachment_valid() -> bool:
	return _mac_export_mariner_attachment_valid(Mariner1206LiveReplacement, "1206")


func _mac_export_1219_attachment_valid() -> bool:
	return _mac_export_mariner_attachment_valid(Mariner1219LiveReplacement, "1219")


func _mac_export_mariner_attachment_valid(adapter: Script, unit: String) -> bool:
	var buildings := world_root.get_node_or_null("PlayableWorld/Buildings")
	if buildings == null:
		return false
	var roots: Dictionary = {}
	for key: String in [adapter.WALL_KEY, adapter.ROOF_KEY]:
		var matches: Array[Node3D] = []
		# Only category children own attachments; nested original collision roots share source keys.
		for proxy: Node in buildings.get_children():
			for child: Node in proxy.get_children():
				if child is Node3D and str(child.get_meta("derived_object_key", "")) == key:
					matches.append(child as Node3D)
		if matches.size() != 1:
			print("MAC_EXPORT_%s_ATTACHMENT: invalid pair count key=%s count=%d" % [unit, key, matches.size()])
			return false
		var outer := matches[0]
		var proxy := outer.get_parent()
		if str(proxy.name) != "%s__%s" % [adapter.TARGET_CHUNK_ID, key.validate_node_name()] or proxy.get_child_count() != 1 or proxy.has_meta("target_parent"):
			return false
		roots[key] = outer
	var valid := _mac_export_mariner_pair_valid(roots[adapter.WALL_KEY], roots[adapter.ROOF_KEY], adapter)
	print("MAC_EXPORT_%s_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s source=%s credit=0" % [unit, valid, roots[adapter.WALL_KEY].get_path(), roots[adapter.ROOF_KEY].get_path(), _mac_export_attachment_measure(roots[adapter.WALL_KEY]), _mac_export_attachment_measure(roots[adapter.ROOF_KEY]), adapter.SOURCE_KEY])
	return valid


func _mac_export_mariner_pair_valid(wall: Node3D, roof: Node3D, adapter: Script) -> bool:
	if wall == null or roof == null or wall == roof:
		return false
	var is_1206: bool = adapter.SOURCE_KEY == "w96215677"
	var prefix := "Mariner1206Live" if is_1206 else "Mariner1219Live"
	if str(wall.name) != prefix + "Wall" or str(roof.name) != prefix + "Roof" \
	or _mac_export_attachment_measure(wall) != {"meshes": 12, "surfaces": 12, "triangles": 5068, "bodies": 2, "shapes": 8} \
	or _mac_export_attachment_measure(roof) != {"meshes": 2, "surfaces": 2, "triangles": 64, "bodies": 2, "shapes": 2}:
		return false
	var chunk: Dictionary = adapter.FACTORY._json(adapter.FACTORY.CHUNK_PATH)
	var prepared: Dictionary = adapter.prepare_chunk_records(chunk)
	if not bool(prepared.get("ok", false)) or not bool(prepared.get("contains_target", false)):
		return false
	for spec: Array in [[wall, adapter.WALL_KEY, true], [roof, adapter.ROOF_KEY, false]]:
		var outer: Node3D = spec[0]
		var key: String = spec[1]
		var is_wall: bool = spec[2]
		var receiver := "building_wall" if is_wall else "none"
		if outer.transform != Transform3D.IDENTITY or str(outer.get_meta("adapter_id", "")) != adapter.ADAPTER_ID \
		or str(outer.get_meta("derived_object_key", "")) != key or outer.get_meta("source_keys", []) != [adapter.SOURCE_KEY] \
		or str(outer.get_meta("feature_kind", "")) != ("building_wall" if is_wall else "building_roof") \
		or str(outer.get_meta("receiver_kind", "")) != receiver or not bool(outer.get_meta("runtime_attachment", false)) \
		or bool(outer.get_meta("prototype_only", true)) or bool(outer.get_meta("recognition_accepted", true)) \
		or not bool(outer.get_meta("runtime_supersedes_generated_placeholder", false)) \
		or outer.get_meta("superseded_object_keys", []) != [adapter.WALL_KEY, adapter.ROOF_KEY]:
			return false
		var original := outer.get_node_or_null("OriginalWallRecord" if is_wall else "OriginalRoofRecord") as Node3D
		var body := original.get_node_or_null("Collision") as StaticBody3D if original != null else null
		if original == null or original.transform != Transform3D.IDENTITY or original.get_child_count() != 1 \
		or body == null or body.transform != Transform3D.IDENTITY or body.get_child_count() != 1 \
		or body.collision_layer != 5 or body.collision_mask != 0 or body.is_in_group("spray_receiver_wall") != is_wall:
			return false
		var shape := body.get_child(0) as CollisionShape3D
		if shape == null or shape.transform != Transform3D.IDENTITY or shape.disabled or not shape.shape is ConcavePolygonShape3D:
			return false
		# The raw builder owns metadata on the body and shape resource, not the shape node.
		for object: Object in [body, shape.shape]:
			if str(object.get_meta("derived_object_key", "")) != key or object.get_meta("source_keys", []) != [adapter.SOURCE_KEY] \
			or str(object.get_meta("receiver_kind", "")) != receiver or not bool(object.get_meta("opaque", false)):
				return false
		var record: Dictionary = prepared.source_records[key]
		var expected := PackedVector3Array()
		for offset in range(0, record.indices.size(), 3):
			for index: int in [int(record.indices[offset]), int(record.indices[offset + 2]), int(record.indices[offset + 1])]:
				expected.append(Vector3(float(record.vertices[index * 3]), float(record.vertices[index * 3 + 1]), float(record.vertices[index * 3 + 2])))
		if var_to_bytes(shape.shape.get_faces()) != var_to_bytes(expected):
			return false
		for child: Node in outer.get_children():
			if child is MeshInstance3D:
				if child.transform != Transform3D.IDENTITY or str(child.get_meta("derived_object_key", "")) != key \
				or child.get_meta("source_keys", []) != [adapter.SOURCE_KEY] or not bool(child.get_meta("runtime_attachment", false)) \
				or bool(child.get_meta("prototype_only", true)) or child.layers != (2 if str(child.name) in ["ExactOriginalWallSurfaces", "NearHorizontalSiding"] else 1):
					return false
	if wall.get_node_or_null("ExactSourceNeutralRoof") != null or wall.get_node_or_null("OriginalRoofRecord") != null \
	or roof.get_child_count() != 4 or roof.get_node_or_null("ExactSourceNeutralRoof") == null \
	or roof.get_node_or_null("ObservedPublicRoof") == null or roof.get_node_or_null("ObservedRoof_NoSprayReceiver") == null \
	or wall.get_meta("mapped_public_run_indices", []) != adapter.MAPPED_RUNS or wall.get_meta("protected_run_indices", []) != adapter.PROTECTED_RUNS:
		return false
	var detail := wall.get_node_or_null("PhysicalDetails_NoSprayReceiver") as StaticBody3D
	if detail == null or detail.transform != Transform3D.IDENTITY or detail.get_child_count() != 7 \
	or detail.collision_layer != 5 or detail.collision_mask != 0 or detail.is_in_group("spray_receiver_wall") \
	or str(detail.get_meta("receiver_kind", "")) != "none" or str(detail.get_meta("derived_object_key", "")) != "prototype:" + adapter.WALL_KEY \
	or detail.get_meta("source_keys", []) != [adapter.SOURCE_KEY] or str(detail.get_meta("feature_kind", "")) != "bounded_facade_detail":
		return false
	for index in adapter.FACTORY.PHYSICAL_BUCKETS.size():
		var label: String = adapter.FACTORY.PHYSICAL_BUCKETS[index]
		var shape := detail.get_child(index) as CollisionShape3D
		var mesh := wall.get_node_or_null(NodePath(label)) as MeshInstance3D
		if shape == null or mesh == null or mesh.mesh == null or shape.transform != Transform3D.IDENTITY or shape.disabled \
		or str(shape.name) != label or not shape.shape is ConcavePolygonShape3D \
		or str(shape.shape.get_meta("receiver_kind", "")) != "none" or str(shape.shape.get_meta("structural_role", "")) != label:
			return false
		var arrays: Array = mesh.mesh.surface_get_arrays(0)
		var expected := PackedVector3Array()
		for vertex: int in arrays[Mesh.ARRAY_INDEX]:
			expected.append(arrays[Mesh.ARRAY_VERTEX][vertex])
		if var_to_bytes(shape.shape.get_faces()) != var_to_bytes(expected):
			return false
	# The separate observed roof is a physical nonreceiver, never a replacement of the source roof.
	var roof_body := roof.get_node_or_null("ObservedRoof_NoSprayReceiver") as StaticBody3D
	var roof_mesh := roof.get_node_or_null("ObservedPublicRoof") as MeshInstance3D
	if roof_body == null or roof_mesh == null or roof_mesh.mesh == null or roof_body.transform != Transform3D.IDENTITY \
	or roof_body.get_child_count() != 1 or roof_body.collision_layer != 5 or roof_body.collision_mask != 0 \
	or roof_body.is_in_group("spray_receiver_wall") or str(roof_body.get_meta("receiver_kind", "")) != "none" \
	or str(roof_body.get_meta("derived_object_key", "")) != "prototype:" + adapter.ROOF_KEY \
	or roof_body.get_meta("source_keys", []) != [adapter.SOURCE_KEY] \
	or str(roof_body.get_meta("feature_kind", "")) != "bounded_public_roof_addition":
		return false
	var roof_shape := roof_body.get_child(0) as CollisionShape3D
	if roof_shape == null or roof_shape.transform != Transform3D.IDENTITY or roof_shape.disabled \
	or str(roof_shape.name) != "ObservedPublicRoof" or not roof_shape.shape is ConcavePolygonShape3D \
	or str(roof_shape.shape.get_meta("receiver_kind", "")) != "none" \
	or str(roof_shape.shape.get_meta("structural_role", "")) != "ObservedPublicRoof":
		return false
	var roof_arrays: Array = roof_mesh.mesh.surface_get_arrays(0)
	var roof_faces := PackedVector3Array()
	for vertex: int in roof_arrays[Mesh.ARRAY_INDEX]: roof_faces.append(roof_arrays[Mesh.ARRAY_VERTEX][vertex])
	if roof_faces.size() != 48 * 3 or var_to_bytes(roof_shape.shape.get_faces()) != var_to_bytes(roof_faces):
		return false
	return true


# Candidate-only smoke predicates; authority and frozen study geometry remain unchanged.
func _mac_export_1212_attachment_valid() -> bool:
	return _mac_export_family_attachment_valid(Mariner1212LiveReplacement, "1212")


func _mac_export_1220_attachment_valid() -> bool:
	return _mac_export_family_attachment_valid(Bayside1220LiveReplacement, "1220")


func _mac_export_1239_attachment_valid() -> bool:
	return _mac_export_family_attachment_valid(Northpoint1239LiveReplacement, "1239")


func _mac_export_family_spec(adapter: Script) -> Dictionary:
	match str(adapter.SOURCE_KEY):
		"w96215649": return {"prefix": "Mariner1212Live", "wall": {"meshes": 12, "surfaces": 12, "triangles": 5076, "bodies": 2, "shapes": 8}, "roof": {"meshes": 2, "surfaces": 2, "triangles": 64, "bodies": 2, "shapes": 2}, "detail_shapes": 7, "added_roof_triangles": 48, "meshes": 14, "channels": 182, "shapes": 10, "detail_tangents": 12}
		"w96215652": return {"prefix": "Bayside1220Live", "wall": {"meshes": 12, "surfaces": 12, "triangles": 7040, "bodies": 2, "shapes": 8}, "roof": {"meshes": 2, "surfaces": 2, "triangles": 78, "bodies": 2, "shapes": 2}, "detail_shapes": 7, "added_roof_triangles": 64, "meshes": 14, "channels": 182, "shapes": 10, "detail_tangents": 12}
		"w96215658": return {"prefix": "Northpoint1239Live", "wall": {"meshes": 13, "surfaces": 13, "triangles": 6892, "bodies": 2, "shapes": 9}, "roof": {"meshes": 2, "surfaces": 2, "triangles": 86, "bodies": 2, "shapes": 2}, "detail_shapes": 8, "added_roof_triangles": 64, "meshes": 15, "channels": 195, "shapes": 11, "detail_tangents": 13}
	return {}


func _mac_export_family_attachment_valid(adapter: Script, unit: String) -> bool:
	var buildings := world_root.get_node_or_null("PlayableWorld/Buildings")
	if buildings == null:
		return false
	var roots: Dictionary = {}
	for key: String in [adapter.WALL_KEY, adapter.ROOF_KEY]:
		var matches: Array[Node3D] = []
		# Only category children own attachments; nested original collision roots share source keys.
		for proxy: Node in buildings.get_children():
			for child: Node in proxy.get_children():
				if child is Node3D and str(child.get_meta("derived_object_key", "")) == key:
					matches.append(child as Node3D)
		if matches.size() != 1:
			print("MAC_EXPORT_%s_ATTACHMENT: invalid pair count key=%s count=%d" % [unit, key, matches.size()])
			return false
		var outer := matches[0]
		var proxy := outer.get_parent()
		if str(proxy.name) != "%s__%s" % [adapter.TARGET_CHUNK_ID, key.validate_node_name()] or proxy.get_child_count() != 1 or proxy.has_meta("target_parent"):
			return false
		roots[key] = outer
	var valid := _mac_export_family_pair_valid(roots[adapter.WALL_KEY], roots[adapter.ROOF_KEY], adapter)
	print("MAC_EXPORT_%s_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s source=%s credit=0" % [unit, valid, roots[adapter.WALL_KEY].get_path(), roots[adapter.ROOF_KEY].get_path(), _mac_export_attachment_measure(roots[adapter.WALL_KEY]), _mac_export_attachment_measure(roots[adapter.ROOF_KEY]), adapter.SOURCE_KEY])
	return valid


func _mac_export_family_pair_valid(wall: Node3D, roof: Node3D, adapter: Script) -> bool:
	if wall == null or roof == null or wall == roof:
		return false
	var spec: Dictionary = _mac_export_family_spec(adapter)
	if spec.is_empty(): return false
	var prefix: String = str(spec.prefix)
	if str(wall.name) != prefix + "Wall" or str(roof.name) != prefix + "Roof" \
	or _mac_export_attachment_measure(wall) != spec.wall \
	or _mac_export_attachment_measure(roof) != spec.roof:
		return false
	var chunk: Dictionary = adapter.FACTORY._json(adapter.FACTORY.CHUNK_PATH)
	var prepared: Dictionary = adapter.prepare_chunk_records(chunk)
	if not bool(prepared.get("ok", false)) or not bool(prepared.get("contains_target", false)):
		return false
	for pair_spec: Array in [[wall, adapter.WALL_KEY, true], [roof, adapter.ROOF_KEY, false]]:
		var outer: Node3D = pair_spec[0]
		var key: String = pair_spec[1]
		var is_wall: bool = pair_spec[2]
		var receiver := "building_wall" if is_wall else "none"
		if outer.transform != Transform3D.IDENTITY or str(outer.get_meta("adapter_id", "")) != adapter.ADAPTER_ID \
		or str(outer.get_meta("derived_object_key", "")) != key or outer.get_meta("source_keys", []) != [adapter.SOURCE_KEY] \
		or str(outer.get_meta("feature_kind", "")) != ("building_wall" if is_wall else "building_roof") \
		or str(outer.get_meta("receiver_kind", "")) != receiver or not bool(outer.get_meta("runtime_attachment", false)) \
		or bool(outer.get_meta("prototype_only", true)) or bool(outer.get_meta("recognition_accepted", true)) \
		or not bool(outer.get_meta("runtime_supersedes_generated_placeholder", false)) \
		or outer.get_meta("superseded_object_keys", []) != [adapter.WALL_KEY, adapter.ROOF_KEY]:
			return false
		var original := outer.get_node_or_null("OriginalWallRecord" if is_wall else "OriginalRoofRecord") as Node3D
		var body := original.get_node_or_null("Collision") as StaticBody3D if original != null else null
		if original == null or original.transform != Transform3D.IDENTITY or original.get_child_count() != 1 \
		or body == null or body.transform != Transform3D.IDENTITY or body.get_child_count() != 1 \
		or body.collision_layer != 5 or body.collision_mask != 0 or body.is_in_group("spray_receiver_wall") != is_wall:
			return false
		var shape := body.get_child(0) as CollisionShape3D
		if shape == null or shape.transform != Transform3D.IDENTITY or shape.disabled or not shape.shape is ConcavePolygonShape3D:
			return false
		# The raw builder owns metadata on the body and shape resource, not the shape node.
		for object: Object in [body, shape.shape]:
			if str(object.get_meta("derived_object_key", "")) != key or object.get_meta("source_keys", []) != [adapter.SOURCE_KEY] \
			or str(object.get_meta("receiver_kind", "")) != receiver or not bool(object.get_meta("opaque", false)):
				return false
		var record: Dictionary = prepared.source_records[key]
		var expected := PackedVector3Array()
		for offset in range(0, record.indices.size(), 3):
			for index: int in [int(record.indices[offset]), int(record.indices[offset + 2]), int(record.indices[offset + 1])]:
				expected.append(Vector3(float(record.vertices[index * 3]), float(record.vertices[index * 3 + 1]), float(record.vertices[index * 3 + 2])))
		if var_to_bytes(shape.shape.get_faces()) != var_to_bytes(expected):
			return false
		for child: Node in outer.get_children():
			if child is MeshInstance3D:
				if child.transform != Transform3D.IDENTITY or str(child.get_meta("derived_object_key", "")) != key \
				or child.get_meta("source_keys", []) != [adapter.SOURCE_KEY] or not bool(child.get_meta("runtime_attachment", false)) \
				or bool(child.get_meta("prototype_only", true)) or child.layers != (2 if str(child.name) in ["ExactOriginalWallSurfaces", "NearHorizontalSiding"] else 1):
					return false
	if wall.get_node_or_null("ExactSourceNeutralRoof") != null or wall.get_node_or_null("OriginalRoofRecord") != null \
	or roof.get_child_count() != 4 or roof.get_node_or_null("ExactSourceNeutralRoof") == null \
	or roof.get_node_or_null("ObservedPublicRoof") == null or roof.get_node_or_null("ObservedRoof_NoSprayReceiver") == null \
	or wall.get_meta("mapped_public_run_indices", []) != adapter.MAPPED_RUNS or wall.get_meta("protected_run_indices", []) != adapter.PROTECTED_RUNS:
		return false
	var detail := wall.get_node_or_null("PhysicalDetails_NoSprayReceiver") as StaticBody3D
	if detail == null or detail.transform != Transform3D.IDENTITY or detail.get_child_count() != int(spec.detail_shapes) \
	or detail.collision_layer != 5 or detail.collision_mask != 0 or detail.is_in_group("spray_receiver_wall") \
	or str(detail.get_meta("receiver_kind", "")) != "none" or str(detail.get_meta("derived_object_key", "")) != "prototype:" + adapter.WALL_KEY \
	or detail.get_meta("source_keys", []) != [adapter.SOURCE_KEY] or str(detail.get_meta("feature_kind", "")) != "bounded_facade_detail":
		return false
	for index in adapter.FACTORY.PHYSICAL_BUCKETS.size():
		var label: String = adapter.FACTORY.PHYSICAL_BUCKETS[index]
		var shape := detail.get_child(index) as CollisionShape3D
		var mesh := wall.get_node_or_null(NodePath(label)) as MeshInstance3D
		if shape == null or mesh == null or mesh.mesh == null or shape.transform != Transform3D.IDENTITY or shape.disabled \
		or str(shape.name) != label or not shape.shape is ConcavePolygonShape3D \
		or str(shape.shape.get_meta("receiver_kind", "")) != "none" or str(shape.shape.get_meta("structural_role", "")) != label:
			return false
		var arrays: Array = mesh.mesh.surface_get_arrays(0)
		var expected := PackedVector3Array()
		for vertex: int in arrays[Mesh.ARRAY_INDEX]:
			expected.append(arrays[Mesh.ARRAY_VERTEX][vertex])
		if var_to_bytes(shape.shape.get_faces()) != var_to_bytes(expected):
			return false
	# The separate observed roof is a physical nonreceiver, never a replacement of the source roof.
	var roof_body := roof.get_node_or_null("ObservedRoof_NoSprayReceiver") as StaticBody3D
	var roof_mesh := roof.get_node_or_null("ObservedPublicRoof") as MeshInstance3D
	if roof_body == null or roof_mesh == null or roof_mesh.mesh == null or roof_body.transform != Transform3D.IDENTITY \
	or roof_body.get_child_count() != 1 or roof_body.collision_layer != 5 or roof_body.collision_mask != 0 \
	or roof_body.is_in_group("spray_receiver_wall") or str(roof_body.get_meta("receiver_kind", "")) != "none" \
	or str(roof_body.get_meta("derived_object_key", "")) != "prototype:" + adapter.ROOF_KEY \
	or roof_body.get_meta("source_keys", []) != [adapter.SOURCE_KEY] \
	or str(roof_body.get_meta("feature_kind", "")) != "bounded_public_roof_addition":
		return false
	var roof_shape := roof_body.get_child(0) as CollisionShape3D
	if roof_shape == null or roof_shape.transform != Transform3D.IDENTITY or roof_shape.disabled \
	or str(roof_shape.name) != "ObservedPublicRoof" or not roof_shape.shape is ConcavePolygonShape3D \
	or str(roof_shape.shape.get_meta("receiver_kind", "")) != "none" \
	or str(roof_shape.shape.get_meta("structural_role", "")) != "ObservedPublicRoof":
		return false
	var roof_arrays: Array = roof_mesh.mesh.surface_get_arrays(0)
	var roof_faces := PackedVector3Array()
	for vertex: int in roof_arrays[Mesh.ARRAY_INDEX]: roof_faces.append(roof_arrays[Mesh.ARRAY_VERTEX][vertex])
	if roof_faces.size() != int(spec.added_roof_triangles) * 3 or var_to_bytes(roof_shape.shape.get_faces()) != var_to_bytes(roof_faces):
		return false
	return true


func _mac_export_projected_family_spec(adapter: Script) -> Dictionary:
	match str(adapter.SOURCE_KEY):
		"w96215685": return {"prefix": "Bayside1226Live", "wall": {"meshes": 15, "surfaces": 15, "triangles": 3468, "bodies": 3, "shapes": 12}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 14, "bodies": 1, "shapes": 1}, "detail_shapes": 10, "meshes": 16, "channels": 208, "shapes": 13, "detail_tangents": 14, "projected_runs": [5, 6, 7, 8, 9, 11, 12, 14], "projected_triangles": 8, "public_roof": true}
		"w96215670": return {"prefix": "Gateview1397Live", "wall": {"meshes": 14, "surfaces": 14, "triangles": 4256, "bodies": 3, "shapes": 11}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 22, "bodies": 1, "shapes": 1}, "detail_shapes": 9, "meshes": 15, "channels": 195, "shapes": 12, "detail_tangents": 13, "projected_runs": [17, 18, 19, 20, 23, 24, 25, 26, 27, 28, 30, 31, 32, 33, 34, 35, 36, 37], "projected_triangles": 8, "public_roof": true}
		"w96215688": return {"prefix": "Northpoint1240Live", "wall": {"meshes": 17, "surfaces": 17, "triangles": 3040, "bodies": 3, "shapes": 14}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}, "detail_shapes": 12, "meshes": 18, "channels": 234, "shapes": 15, "detail_tangents": 16, "projected_runs": [15, 16, 18, 19, 20, 21, 23, 24, 25], "projected_triangles": 6, "public_roof": true}
		"w96215666": return {"prefix": "Bayside1215Live", "wall": {"meshes": 17, "surfaces": 17, "triangles": 4736, "bodies": 3, "shapes": 13}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1}, "detail_shapes": 11, "meshes": 18, "channels": 234, "shapes": 14, "detail_tangents": 16, "projected_runs": [1, 3, 4, 5, 19], "projected_triangles": 6, "public_roof": true}
		"w96215659": return {"prefix": "Northpoint1234Live", "wall": {"meshes": 18, "surfaces": 18, "triangles": 5484, "bodies": 3, "shapes": 14}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}, "detail_shapes": 12, "meshes": 19, "channels": 247, "shapes": 15, "detail_tangents": 17, "projected_runs": [1, 2, 3, 4, 17, 18, 19, 20, 22, 23, 24, 25], "projected_triangles": 6, "public_roof": true}
		"w96215673": return {"prefix": "Northpoint1232Live", "wall": {"meshes": 18, "surfaces": 18, "triangles": 2560, "bodies": 3, "shapes": 14}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}, "detail_shapes": 12, "meshes": 19, "channels": 247, "shapes": 15, "detail_tangents": 17, "projected_runs": [10, 11, 12, 13, 15, 16, 17, 18], "projected_triangles": 6, "public_roof": true}
		"w96215674": return {"prefix": "Northpoint1241Live", "wall": {"meshes": 18, "surfaces": 18, "triangles": 3416, "bodies": 3, "shapes": 14}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}, "detail_shapes": 12, "meshes": 19, "channels": 247, "shapes": 15, "detail_tangents": 17, "projected_runs": [0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12], "projected_triangles": 6, "public_roof": true}
		"w96215682": return {"prefix": "Mariner1221Live", "wall": {"meshes": 19, "surfaces": 19, "triangles": 3356, "bodies": 3, "shapes": 14}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}, "detail_shapes": 12, "meshes": 20, "channels": 260, "shapes": 15, "detail_tangents": 18, "projected_runs": [0, 1, 2, 4, 5, 6, 9, 10, 11, 12], "projected_triangles": 6, "public_roof": true}
		"w96215661": return {"prefix": "Bayside1222Live", "wall": {"meshes": 15, "surfaces": 15, "triangles": 5336, "bodies": 3, "shapes": 11}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1}, "detail_shapes": 9, "meshes": 16, "channels": 208, "shapes": 12, "detail_tangents": 14, "projected_runs": [10, 11, 12, 15, 16, 19], "projected_triangles": 6, "public_roof": false}
		"w96215653": return {"prefix": "Northpoint1227Live", "wall": {"meshes": 19, "surfaces": 19, "triangles": 5528, "bodies": 3, "shapes": 15}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}, "detail_shapes": 13, "meshes": 20, "channels": 260, "shapes": 16, "detail_tangents": 18, "projected_runs": [4, 5, 6, 7, 9, 10, 11, 13, 14, 15, 16], "projected_triangles": 6, "public_roof": true}
		"w96215651": return {"prefix": "Mariner1202Live", "wall": {"meshes": 17, "surfaces": 17, "triangles": 5088, "bodies": 3, "shapes": 13}, "roof": {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}, "detail_shapes": 11, "meshes": 18, "channels": 234, "shapes": 14, "detail_tangents": 16, "projected_runs": [10, 11, 12, 13, 14, 16, 17, 18, 19, 21], "projected_triangles": 6, "public_roof": true}
	return {}


func _mac_export_projected_family_attachment_valid(adapter: Script, unit: String) -> bool:
	var buildings := world_root.get_node_or_null("PlayableWorld/Buildings")
	if buildings == null:
		return false
	var roots: Dictionary = {}
	for key: String in [adapter.WALL_KEY, adapter.ROOF_KEY]:
		var matches: Array[Node3D] = []
		# Only category children own attachments; nested original collision roots share source keys.
		for proxy: Node in buildings.get_children():
			for child: Node in proxy.get_children():
				if child is Node3D and str(child.get_meta("derived_object_key", "")) == key:
					matches.append(child as Node3D)
		if matches.size() != 1:
			print("MAC_EXPORT_%s_ATTACHMENT: invalid pair count key=%s count=%d" % [unit, key, matches.size()])
			return false
		var outer := matches[0]
		var proxy := outer.get_parent()
		if str(proxy.name) != "%s__%s" % [adapter.TARGET_CHUNK_ID, key.validate_node_name()] or proxy.get_child_count() != 1 or proxy.has_meta("target_parent"):
			return false
		roots[key] = outer
	var valid := _mac_export_projected_family_pair_valid(roots[adapter.WALL_KEY], roots[adapter.ROOF_KEY], adapter)
	print("MAC_EXPORT_%s_ATTACHMENT: valid=%s wall=%s roof=%s wall_counts=%s roof_counts=%s source=%s credit=0" % [unit, valid, roots[adapter.WALL_KEY].get_path(), roots[adapter.ROOF_KEY].get_path(), _mac_export_attachment_measure(roots[adapter.WALL_KEY]), _mac_export_attachment_measure(roots[adapter.ROOF_KEY]), adapter.SOURCE_KEY])
	return valid


func _mac_export_projected_family_pair_valid(wall: Node3D, roof: Node3D, adapter: Script) -> bool:
	if wall == null or roof == null or wall == roof:
		return false
	var spec: Dictionary = _mac_export_projected_family_spec(adapter)
	if spec.is_empty(): return false
	var prefix: String = str(spec.prefix)
	if str(wall.name) != prefix + "Wall" or str(roof.name) != prefix + "Roof" \
	or _mac_export_attachment_measure(wall) != spec.wall \
	or _mac_export_attachment_measure(roof) != spec.roof:
		return false
	var chunk: Dictionary = adapter.FACTORY._json(adapter.FACTORY.CHUNK_PATH)
	var prepared: Dictionary = adapter.prepare_chunk_records(chunk)
	if not bool(prepared.get("ok", false)) or not bool(prepared.get("contains_target", false)):
		return false
	for pair_spec: Array in [[wall, adapter.WALL_KEY, true], [roof, adapter.ROOF_KEY, false]]:
		var outer: Node3D = pair_spec[0]
		var key: String = pair_spec[1]
		var is_wall: bool = pair_spec[2]
		var receiver := "building_wall" if is_wall else "none"
		if outer.transform != Transform3D.IDENTITY or str(outer.get_meta("adapter_id", "")) != adapter.ADAPTER_ID \
		or str(outer.get_meta("derived_object_key", "")) != key or outer.get_meta("source_keys", []) != [adapter.SOURCE_KEY] \
		or str(outer.get_meta("feature_kind", "")) != ("building_wall" if is_wall else "building_roof") \
		or str(outer.get_meta("receiver_kind", "")) != receiver or not bool(outer.get_meta("runtime_attachment", false)) \
		or bool(outer.get_meta("prototype_only", true)) or bool(outer.get_meta("recognition_accepted", true)) \
		or not bool(outer.get_meta("runtime_supersedes_generated_placeholder", false)) \
		or outer.get_meta("superseded_object_keys", []) != [adapter.WALL_KEY, adapter.ROOF_KEY]:
			return false
		var original := outer.get_node_or_null("OriginalWallRecord" if is_wall else "OriginalRoofRecord") as Node3D
		var body := original.get_node_or_null("Collision") as StaticBody3D if original != null else null
		if original == null or original.transform != Transform3D.IDENTITY or original.get_child_count() != 1 \
		or body == null or body.transform != Transform3D.IDENTITY or body.get_child_count() != 1 \
		or body.collision_layer != 5 or body.collision_mask != 0 or body.is_in_group("spray_receiver_wall") != is_wall:
			return false
		var shape := body.get_child(0) as CollisionShape3D
		if shape == null or shape.transform != Transform3D.IDENTITY or shape.disabled or not shape.shape is ConcavePolygonShape3D:
			return false
		# The raw builder owns metadata on the body and shape resource, not the shape node.
		for object: Object in [body, shape.shape]:
			if str(object.get_meta("derived_object_key", "")) != key or object.get_meta("source_keys", []) != [adapter.SOURCE_KEY] \
			or str(object.get_meta("receiver_kind", "")) != receiver or not bool(object.get_meta("opaque", false)):
				return false
		var record: Dictionary = prepared.source_records[key]
		var expected := PackedVector3Array()
		for offset in range(0, record.indices.size(), 3):
			for index: int in [int(record.indices[offset]), int(record.indices[offset + 2]), int(record.indices[offset + 1])]:
				expected.append(Vector3(float(record.vertices[index * 3]), float(record.vertices[index * 3 + 1]), float(record.vertices[index * 3 + 2])))
		if var_to_bytes(shape.shape.get_faces()) != var_to_bytes(expected):
			return false
		for child: Node in outer.get_children():
			if child is MeshInstance3D:
				if child.transform != Transform3D.IDENTITY or str(child.get_meta("derived_object_key", "")) != key \
				or child.get_meta("source_keys", []) != [adapter.SOURCE_KEY] or not bool(child.get_meta("runtime_attachment", false)) \
				or bool(child.get_meta("prototype_only", true)) or child.layers != (2 if str(child.name) in ["ExactOriginalWallSurfaces", "NearHorizontalSiding", "ProjectedUpperSiding"] else 1):
					return false
	if wall.get_node_or_null("ExactSourceNeutralRoof") != null or wall.get_node_or_null("OriginalRoofRecord") != null \
	or roof.get_child_count() != 2 or roof.get_node_or_null("ExactSourceNeutralRoof") == null \
	or roof.get_node_or_null("ObservedPublicRoof") != null or roof.get_node_or_null("ObservedRoof_NoSprayReceiver") != null \
	or wall.has_node("ObservedPublicRoof") != bool(spec.public_roof) \
	or wall.get_meta("mapped_public_run_indices", []) != adapter.MAPPED_RUNS or wall.get_meta("protected_run_indices", []) != adapter.PROTECTED_RUNS:
		return false
	var detail := wall.get_node_or_null("PhysicalDetails_NoSprayReceiver") as StaticBody3D
	if detail == null or detail.transform != Transform3D.IDENTITY or detail.get_child_count() != int(spec.detail_shapes) \
	or detail.collision_layer != 5 or detail.collision_mask != 0 or detail.is_in_group("spray_receiver_wall") \
	or str(detail.get_meta("receiver_kind", "")) != "none" or str(detail.get_meta("derived_object_key", "")) != "prototype:" + adapter.WALL_KEY \
	or detail.get_meta("source_keys", []) != [adapter.SOURCE_KEY] or str(detail.get_meta("feature_kind", "")) != "bounded_facade_detail":
		return false
	for index in adapter.FACTORY.PHYSICAL_BUCKETS.size():
		var label: String = adapter.FACTORY.PHYSICAL_BUCKETS[index]
		var shape := detail.get_child(index) as CollisionShape3D
		var mesh := wall.get_node_or_null(NodePath(label)) as MeshInstance3D
		if shape == null or shape.transform != Transform3D.IDENTITY or shape.disabled \
		or str(shape.name) != label or not shape.shape is ConcavePolygonShape3D \
		or str(shape.shape.get_meta("receiver_kind", "")) != "none" or str(shape.shape.get_meta("structural_role", "")) != label:
			return false
		#1240 deliberately retains this named zero-face physical slot without a visual mesh.
		if str(adapter.SOURCE_KEY) == "w96215688" and label == "DarkOpaqueGlazing":
			if mesh != null or not shape.shape.get_faces().is_empty():
				return false
			continue
		if mesh == null or mesh.mesh == null:
			return false
		var arrays: Array = mesh.mesh.surface_get_arrays(0)
		var expected := PackedVector3Array()
		for vertex: int in arrays[Mesh.ARRAY_INDEX]:
			expected.append(arrays[Mesh.ARRAY_VERTEX][vertex])
		if var_to_bytes(shape.shape.get_faces()) != var_to_bytes(expected):
			return false
	# The added front is an eligible surface at the visible projected plane; closures stay in the nonreceiver detail body.
	var projected := wall.get_node_or_null("ProjectedUpperWallReceiver") as StaticBody3D
	var projected_mesh := wall.get_node_or_null("ProjectedUpperSiding") as MeshInstance3D
	if projected == null or projected_mesh == null or projected_mesh.mesh == null \
	or projected.transform != Transform3D.IDENTITY or projected.get_child_count() != 1 \
	or projected.collision_layer != 5 or projected.collision_mask != 0 or not projected.is_in_group("spray_receiver_wall") \
	or projected_mesh.layers != 2:
		return false
	var runs: Array[int] = []
	for value: Variant in spec.projected_runs: runs.append(int(value))
	if projected.get_meta("source_run_indices", []) != runs: return false
	var projected_shape := projected.get_child(0) as CollisionShape3D
	if projected_shape == null or projected_shape.transform != Transform3D.IDENTITY or projected_shape.disabled \
	or str(projected_shape.name) != "ProjectedUpperSiding" or not projected_shape.shape is ConcavePolygonShape3D:
		return false
	var source_wall: Dictionary = prepared.source_records[adapter.WALL_KEY]
	for owner: Object in [projected, projected_shape.shape]:
		if owner.get_meta("receiver_kind", "") != source_wall.receiver_kind or owner.get_meta("opaque", false) != source_wall.opaque \
		or owner.get_meta("derived_object_key", "") != source_wall.object_key or owner.get_meta("source_keys", []) != source_wall.source_keys:
			return false
	var projected_arrays: Array = projected_mesh.mesh.surface_get_arrays(0)
	var projected_faces := PackedVector3Array()
	for vertex: int in projected_arrays[Mesh.ARRAY_INDEX]: projected_faces.append(projected_arrays[Mesh.ARRAY_VERTEX][vertex])
	if projected_faces.size() != int(spec.projected_triangles) * 3 or var_to_bytes(projected_shape.shape.get_faces()) != var_to_bytes(projected_faces):
		return false
	return true
