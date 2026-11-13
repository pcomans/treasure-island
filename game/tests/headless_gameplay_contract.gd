extends SceneTree

const REQUIRED_ACTIONS := [
	"move_forward", "move_back", "move_left", "move_right", "run", "jetpack", "fast_drop",
	"recover", "pause", "quit_game", "toggle_debug", "vehicle_enter_exit", "handbrake",
]
const EXPECTED_WATER_Y := -0.12
const EXPECTED_WATER_SHADER := "res://game/resources/materials/world/water/bay_water.gdshader"
## Cameras stay within this of the origin: the island (about 950 m) and its overview poses.
## Every camera sees as far as gameplay's (player.tscn's far plane): the driving camera
## and game/tests/shared/building_shots.gd's capture cameras take it from the player's.
const WATER_CAMERA_REACH_M := 2000.0
## The street-detail zones: the soccer ball's check finds the full-size pitch's
## centre spot in their ground blocks (tools/lib/sports-pitch.mjs).
const STREET_DETAIL_ZONES_PATH := "res://tools/config/street-detail-zones.json"
## The vehicle contract's places: its ball case drives along the full-size pitch.
const VEHICLE_CASES_PATH := "res://game/tests/shared/vehicle_cases.json"
## Where this run keeps the shadow level its options check chooses.
const OPTIONS_SETTINGS_PATH := "user://test-gameplay-contract-%d.cfg"


func _initialize() -> void:
	# The options check chooses a shadow level, which the game keeps: in a file of
	# this run's own, never the shared user folder's.
	ShadowQuality.settings_path = OPTIONS_SETTINGS_PATH % OS.get_process_id()
	DirAccess.remove_absolute(ShadowQuality.settings_path)
	for action: String in REQUIRED_ACTIONS:
		if not InputMap.has_action(action):
			_fail("Missing input action: %s" % action)
			return
	if not _action_has_physical_key("jetpack", KEY_SPACE):
		_fail("Jetpack input must be bound to physical Space.")
		return
	if not _action_has_physical_key("fast_drop", KEY_C):
		_fail("Fast drop input must be bound to physical C.")
		return
	# Drivable cars (owner, 2026-11-08): F gets in and out; in a car Space is the
	# handbrake, its own action on the jetpack's key.
	if not _action_has_physical_key("vehicle_enter_exit", KEY_F):
		_fail("Getting in and out of a car must be bound to physical F.")
		return
	if not _action_has_physical_key("handbrake", KEY_SPACE):
		_fail("The handbrake must be bound to physical Space.")
		return
	# The owner removed the spray on 2026-11-11: its action is gone and the left
	# mouse button it was on does nothing (no action takes a click).
	if InputMap.has_action("spray"):
		_fail("The spray action must be gone.")
		return
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	for action: StringName in InputMap.get_actions():
		if InputMap.event_is_action(click, action):
			_fail("The left mouse button must do nothing, but it is bound to %s." % action)
			return
	# The arrow keys move as W, S, A and D do (owner, 2026-11-11), on foot and in a
	# car, which reads the same actions: a real key event presses the action and
	# its release lets it go.
	for binding: Array in [["move_forward", KEY_W, KEY_UP], ["move_back", KEY_S, KEY_DOWN], ["move_left", KEY_A, KEY_LEFT], ["move_right", KEY_D, KEY_RIGHT]]:
		if not _action_has_physical_key(binding[0], binding[1]) or not _action_has_physical_key(binding[0], binding[2]):
			_fail("%s must be bound to physical %s and to its arrow key." % [binding[0], OS.get_keycode_string(binding[1])])
			return
		_send_key(binding[2], true)
		var held := Input.is_action_pressed(binding[0])
		_send_key(binding[2], false)
		if not held or Input.is_action_pressed(binding[0]):
			_fail("The %s arrow key did not press and release %s." % [OS.get_keycode_string(binding[2]), binding[0]])
			return

	var boundary := {
		"components": [{
			"outer": [[0.0, 0.0], [10.0, 0.0], [10.0, 10.0], [0.0, 10.0]],
			"holes": [[[4.0, 4.0], [4.0, 6.0], [6.0, 6.0], [6.0, 4.0]]],
		}],
	}
	if not GeneratedWorldContract.validate_boundary(boundary).ok \
	or not GeneratedWorldContract.contains_xz(boundary, Vector2(2.0, 2.0)) \
	or not GeneratedWorldContract.contains_xz(boundary, Vector2(0.0, 5.0)) \
	or GeneratedWorldContract.contains_xz(boundary, Vector2(5.0, 5.0)) \
	or GeneratedWorldContract.contains_xz(boundary, Vector2(11.0, 5.0)):
		_fail("Playable-boundary outer/hole/edge cases failed.")
		return

	var player_scene := load("res://game/scenes/player/player.tscn") as PackedScene
	var player := player_scene.instantiate() as PlayerController
	# The player collides with the world (1) and the street props (1 << 3); the
	# camera arm below sees only the world, so a thin pole never pulls it in.
	if player == null or player.collision_layer != 2 or player.collision_mask != (1 | 1 << 3):
		_fail("Player physics-layer isolation is invalid.")
		return
	if not is_equal_approx(player.walk_speed_mps, 4.0) \
	or not is_equal_approx(player.run_speed_mps, 20.0) \
	or not is_equal_approx(player.acceleration_mps2, 30.0) \
	or not is_equal_approx(player.braking_mps2, 40.0):
		_fail("Walk, car-speed run, acceleration, or braking defaults drifted.")
		return
	if not is_equal_approx(player.jetpack_ascent_speed_mps, 5.0) \
	or not is_equal_approx(player.jetpack_descent_speed_mps, 1.5) \
	or not is_equal_approx(player.jetpack_vertical_response_mps2, 12.0):
		_fail("Jetpack rise, slow-descent, or response defaults drifted.")
		return
	if not is_equal_approx(player.fast_drop_speed_mps, 18.0) or not is_equal_approx(player.fast_drop_response_mps2, 30.0):
		_fail("Fast drop speed or response defaults drifted.")
		return
	var arm := player.get_node("CameraPivot/SpringArm3D") as SpringArm3D
	var camera := player.get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	var camera_pivot := player.get_node("CameraPivot") as PlayerCamera
	if arm == null or camera == null or camera.get_parent() != arm or arm.collision_mask != 1:
		_fail("CameraPivot -> SpringArm3D -> Camera3D contract is invalid.")
		return
	if camera_pivot == null \
	or not is_equal_approx(camera_pivot.position.y, 2.0) \
	or not is_equal_approx(arm.spring_length, 5.5) \
	or not is_equal_approx(arm.rotation.x, deg_to_rad(-8.0)):
		_fail("Initial third-person camera framing defaults drifted.")
		return
	var gameplay_far := camera.far
	var gameplay_arm_m := arm.spring_length
	player.free()

	var world_scene := load("res://game/scenes/world/world_root.tscn") as PackedScene
	var world := world_scene.instantiate() as Node3D
	for required_path: String in [
		"PlayableWorld/GroundAndAreas",
		"PlayableWorld/RoadsAndPaths",
		"PlayableWorld/Buildings",
		"PlayableWorld/StreetDetail/Vegetation",
		"PlayableWorld/StreetDetail/Furniture",
		"PlayableWorld/StreetDetail/Fences",
		"PlayableWorld/StreetDetail/Clutter",
		"ContextWorld/Water",
		"ContextWorld/YerbaBuenaIsland",
		"ContextWorld/BayBridge",
		"ContextWorld/BoundaryAttachedVisuals",
		"ContextWorld/FerryTerminal",
		"ContextWorld/BayAreaHorizon",
		"WorldBoundary",
		"RuntimeEvidence",
	]:
		if not world.has_node(required_path):
			_fail("Missing world hierarchy node: %s" % required_path)
			return
	var water_node := world.get_node_or_null("ContextWorld/Water")
	var water := water_node as MeshInstance3D
	var water_mesh := water.mesh as PlaneMesh if water != null else null
	var water_material := water_mesh.material as ShaderMaterial if water_mesh != null else null
	# The imported wave frames are a CompressedTexture2DArray, a TextureLayered but not a Texture2DArray.
	var water_waves := water_material.get_shader_parameter("waves") as TextureLayered if water_material != null else null
	if water == null or water_mesh == null or water_material == null \
	or water_material.shader == null or water_material.shader.resource_path != EXPECTED_WATER_SHADER \
	or water_waves == null or water_waves.get_layered_type() != TextureLayered.LAYERED_TYPE_2D_ARRAY \
	or not water_material.get_shader_parameter("shore_map") is Texture2D:
		_fail("Water must remain a MeshInstance3D with a PlaneMesh and the bay water shader, its waves and its shore map.")
		return
	if not is_equal_approx(_off_tree_world_transform(water, world).origin.y, EXPECTED_WATER_Y) \
	or not _off_tree_world_transform(water, world).basis.is_equal_approx(Basis.IDENTITY) \
	or water.layers != 1 \
	or water.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
		_fail("Water elevation, orientation, render layer, or shadow setting drifted.")
		return
	# The shader spreads the unit grid into rings round the camera, out to far_share of
	# the camera's far plane: an odd row count whose rings match the mesh, and bounds
	# centred on the island that hold the rings of the farthest-seeing camera from
	# anywhere it stands, and the outer ring's eye height up to where gameplay's camera
	# still sees the water.
	var far_share := float(water_material.get_shader_parameter("far_share"))
	var grid_rows := int(water_material.get_shader_parameter("grid_rows"))
	var bounds := water_mesh.custom_aabb
	var reach := far_share * gameplay_far + WATER_CAMERA_REACH_M
	if water_mesh.size != Vector2(2.0, 2.0) \
	or water_mesh.subdivide_width != water_mesh.subdivide_depth \
	or grid_rows % 2 != 1 or grid_rows != water_mesh.subdivide_width + 1 \
	or far_share <= 0.0 or far_share >= 1.0 \
	or absf(bounds.get_center().x) > 1.0 or absf(bounds.get_center().z) > 1.0 \
	or bounds.size.x < 2.0 * reach or bounds.size.z < 2.0 * reach \
	or bounds.position.y > 0.0 or bounds.end.y < far_share * gameplay_far:
		_fail("Water grid, far reach or bounds drifted apart.")
		return
	if not water.find_children("*", "CollisionObject3D", true, false).is_empty() \
	or not water.find_children("*", "CollisionShape3D", true, false).is_empty() \
	or not water.find_children("*", "CollisionPolygon3D", true, false).is_empty():
		_fail("Water must remain visual-only with no collision body, shape, or polygon descendants.")
		return
	# The distant Bay Area horizon (game/scripts/world/fresh_bay_horizon.gd) builds its
	# scenery on entering the tree; this contract builds it off-tree.
	var horizon := world.get_node("ContextWorld/BayAreaHorizon") as Node3D
	horizon.build_scenery()
	var horizon_problem := _horizon_problem(horizon, world as WorldLoader, gameplay_far, gameplay_arm_m)
	if horizon_problem != "":
		_fail(horizon_problem)
		return
	world.free()

	var main_scene := load("res://game/scenes/main.tscn") as PackedScene
	var main := main_scene.instantiate() as Node3D
	var world_environment := main.get_node("WorldEnvironment") as WorldEnvironment
	var environment := world_environment.environment if world_environment != null else null
	if environment == null \
	or environment.background_mode != Environment.BG_SKY \
	or environment.ambient_light_source != Environment.AMBIENT_SOURCE_SKY \
	or environment.reflected_light_source != Environment.REFLECTION_SOURCE_SKY \
	or environment.ambient_light_sky_contribution <= 0.0 \
	or environment.ambient_light_energy <= 0.0 \
	or environment.sky == null:
		_fail("Main scene must use the approved Sky for background, ambient fill, and reflections.")
		return
	if environment.fog_enabled and environment.fog_sky_affect >= 1.0:
		_fail("Fog must not hide the sky completely.")
		return
	# The sky is a shader (bay_sky.gdshader) that draws its clouds and sun from the
	# live sun; it must still light and reflect, with a lit sky and a lit ground
	# hemisphere, and it must take its sun from the scene's light, not from TIME.
	var daylight := environment.sky.sky_material as ShaderMaterial
	if daylight == null or daylight.shader == null \
	or daylight.shader.get_mode() != Shader.MODE_SKY \
	or float(daylight.get_shader_parameter("sky_energy")) <= 0.0 \
	or float(daylight.get_shader_parameter("ground_energy")) <= 0.0:
		_fail("Approved daylight needs an editable sky shader with lit sky and ground hemispheres.")
		return
	var sky_code := daylight.shader.code
	if not sky_code.contains("LIGHT0_DIRECTION") or not sky_code.contains("LIGHT0_ENERGY"):
		_fail("The sky's sun and clouds must be lit from the scene's own sun (LIGHT0), not from numbers of their own.")
		return
	if RegEx.create_from_string("\\bTIME\\b").search(_without_comments(sky_code)) != null:
		_fail("The sky shader must not read TIME: Godot would redraw the sky's radiance map every frame. Clouds move by sky_cloud_drift.")
		return
	if not ProjectSettings.has_setting("shader_globals/sky_cloud_drift") \
	or not main.get_node("WorldEnvironment").has_method("hold_at"):
		_fail("The clouds need their drift: the sky_cloud_drift shader global and sky_weather.gd on the WorldEnvironment.")
		return
	var sun := main.get_node("Sun") as DirectionalLight3D
	var solar := Vector3(-float(sun.get_meta("solar_elevation_deg")), 180.0 - float(sun.get_meta("solar_azimuth_deg")), 0.0)
	if not sun.rotation_degrees.is_equal_approx(solar):
		_fail("Sun rotation must follow its solar metadata: (-elevation, 180 - azimuth, 0).")
		return
	# North is world -Z and east +X (tools/lib/coordinates.mjs), so the direction to
	# the sun is (sin az * cos el, sin el, -cos az * cos el): the sky draws its disc
	# on the light's own direction, and this ties that direction to the compass.
	var azimuth := deg_to_rad(float(sun.get_meta("solar_azimuth_deg")))
	var elevation := deg_to_rad(float(sun.get_meta("solar_elevation_deg")))
	var to_sun := Vector3(sin(azimuth) * cos(elevation), sin(elevation), -cos(azimuth) * cos(elevation))
	if not sun.basis.z.is_equal_approx(to_sun):
		_fail("The Sun must shine from its solar azimuth, clockwise from north (world -Z) through east (+X).")
		return
	main.free()
	call_deferred("_check_ferry_solidity")


## The ferry terminal's scenery (game/scripts/world/ferry_terminal.gd) lies off the
## walk route, but a jetpack landing on it must never fall through: in the loaded
## world, straight down onto the float's deck, the breakwater, the docked boat and
## the gangway, the first world-solid hit is the terminal's own body (receiver_kind
## none).
func _check_ferry_solidity() -> void:
	create_timer(240.0, true, false, true).timeout.connect(func() -> void: _fail("The ferry solidity check timed out."))
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	main.capture_mouse_on_ready = false
	var world := main.get_node("WorldRoot") as WorldLoader
	var load_failures: Array[String] = []
	world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failures.append("%s: %s" % [code, message]))
	root.add_child(main)
	# The loading screen's Controls button, pressed while the world loads.
	main.hud.load_controls_button.pressed.emit()
	var started := Time.get_ticks_msec()
	while not main.is_play_ready() and load_failures.is_empty() and Time.get_ticks_msec() - started < 180000:
		await process_frame
	if not load_failures.is_empty() or not main.is_play_ready():
		_fail("The world did not reach play for the ferry solidity check: %s" % [load_failures])
		return
	var opened := await _check_controls_from_loading(main)
	if opened.is_empty():
		return
	for _frame in 2:
		await physics_frame
	var context: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/context.json"))
	var ferry: Dictionary = context.get("ferry_terminal", {}) if context is Dictionary else {}
	var boat := world.ferry_context.find_child("SammyJ", true, false) as Node3D
	if ferry.is_empty() or boat == null:
		_fail("The ferry terminal's context section or its boat is missing.")
		return
	var corners: Array = ferry["float"].berth_side_xz + ferry["float"].far_side_xz
	var float_middle := Vector2.ZERO
	for corner: Array in corners:
		float_middle += Vector2(float(corner[0]), float(corner[1])) / float(corners.size())
	var line: Array = ferry.breakwater.line_xz
	var targets := {
		"float deck": float_middle,
		"breakwater": (Vector2(line[0][0], line[0][1]) + Vector2(line[1][0], line[1][1])) * 0.5,
		"boat": Vector2(boat.global_position.x, boat.global_position.z),
		"gangway": (Vector2(ferry.gangway.top_xz[0], ferry.gangway.top_xz[1]) + Vector2(ferry.gangway.bottom_xz[0], ferry.gangway.bottom_xz[1])) * 0.5,
	}
	var space := main.get_world_3d().direct_space_state
	var heights: Array[String] = []
	for target: String in targets:
		var xz: Vector2 = targets[target]
		# Layer 1, the world-solid layer the stock player stands on.
		var query := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 40.0, xz.y), Vector3(xz.x, -20.0, xz.y), 1)
		query.hit_back_faces = false
		var hit := space.intersect_ray(query)
		var body := hit.get("collider") as CollisionObject3D
		if body == null or (body.collision_layer & 1) == 0 \
		or str(body.get_meta("receiver_kind", "")) != "none" \
		or not str(body.get_meta("derived_object_key", "")).begins_with("context:ferry-terminal") \
		or (hit.position as Vector3).y <= EXPECTED_WATER_Y:
			_fail("Straight down onto the ferry %s at %s the first world-solid hit must be the terminal's own non-receiver body above the water, not %s." % [target, xz, hit])
			return
		heights.append("%s %.2f m" % [target, (hit.position as Vector3).y])
	var ball := await _check_soccer_ball(main, world)
	if ball.is_empty():
		return
	var pause := await _check_pause(main)
	if pause.is_empty():
		return
	var resume := await _check_resume_in_physics(main)
	if resume.is_empty():
		return
	# The menus as the player works them: from the idle step, where input arrives.
	await process_frame
	var controls := _check_controls_screen(main)
	if controls.is_empty():
		return
	var credits := await _check_credits_screen(main)
	if credits.is_empty():
		return
	var options := await _check_options_screen(main)
	if options.is_empty():
		return
	var prompt := await _check_prompt_beside_car(main, world)
	if prompt.is_empty():
		return
	main.queue_free()
	DirAccess.remove_absolute(ShadowQuality.settings_path)
	print("PASS: gameplay inputs (F drives, Space handbrake, arrow keys as WASD, no spray and nothing on the left mouse button), 4/20 m/s movement defaults, 30/40 m/s^2 response, jetpack and fast drop defaults, boundary cases, scene hierarchies, water visual-only contract, the distant horizon as scenery all round within the far plane, layer defaults, procedural daylight, the ferry terminal solid from above (%s), the pitch's ball (%s), the pause (%s; %s), the controls screen (%s; %s), the credits screen (%s), the options screen (%s), nothing in the middle of the screen in play and the car prompt (%s)" % [", ".join(heights), ball, pause, resume, opened, controls, credits, options, prompt])
	quit(0)


## The controls screen opened on the loading screen (pressed as the world loads)
## stays open when play starts, and play starts paused behind it, with the pause
## menu hidden: nothing moves until the player closes it. Back shows the pause
## menu, still paused; Resume plays. Then, in play, nothing of the HUD covers the
## middle of the screen (the spray's aiming cross went with the spray, 2026-11-11),
## and the prompt shows only with a car in reach: Resume brings back only a prompt
## that play set (it once showed the prompt label's scene text, "F  Drive",
## anywhere; _check_prompt_beside_car checks the other way).
## Returns a summary, or "" after failing.
func _check_controls_from_loading(main: GameMain) -> String:
	var hud := main.hud
	await process_frame
	if not hud.controls_visible() or not paused or hud.pause_panel.visible or hud.load_panel.visible:
		_fail("The controls screen opened while loading must stay open when play starts, with the game paused behind it (controls %s, paused %s, pause menu %s, loading screen %s)." % [hud.controls_visible(), paused, hud.pause_panel.visible, hud.load_panel.visible])
		return ""
	hud.back_button.pressed.emit()
	if hud.controls_visible() or not paused or not hud.pause_panel.visible:
		_fail("Back on the controls screen opened while loading must show the pause menu, still paused.")
		return ""
	hud.resume_button.pressed.emit()
	await process_frame
	if paused or hud.pause_panel.visible:
		_fail("Resume after the controls screen opened while loading did not start play.")
		return ""
	if hud.prompt_panel.visible != main.vehicles.can_enter():
		_fail("After Resume the prompt must show exactly when a car is in reach (shown %s \"%s\", a car in reach %s)." % [hud.prompt_panel.visible, hud.prompt_text.text, main.vehicles.can_enter()])
		return ""
	var centre := hud.get_viewport_rect().size * 0.5
	for node: Node in hud.find_children("*", "Control", true, false):
		var control := node as Control
		if control.is_visible_in_tree() and control.get_global_rect().has_point(centre):
			_fail("In play %s covers the middle of the screen." % control.get_path())
			return ""
	return "opened while loading, kept open and paused at the start of play"


## The controls screen (owner, 2026-11-11): the pause menu's Controls button shows it
## in place of the menu, listing the bindings as they are (the arrow keys beside
## WASD, the car's F, handbrake and R, and no spray); Esc or Back return to the menu,
## still paused. The loading screen opens it too, and on a touch screen it lists the
## touch controls instead. Returns a summary, or "" after failing.
func _check_controls_screen(main: GameMain) -> String:
	var hud := main.hud
	_push_key(KEY_ESCAPE)
	hud.controls_button.pressed.emit()
	if not paused or not hud.controls_visible() or hud.pause_panel.visible:
		_fail("The pause menu's Controls button must show the controls screen in its place.")
		return ""
	var keyboard := _controls_text(hud)
	for needed: String in ["W A S D or arrow keys", "up / down arrows", "left / right arrows", "Shift", "Space (hold)", "C (hold, in the air)", "F (beside a parked car)", "Handbrake", "Back on land", "Back to safe ground", "Esc", "F3"]:
		if not keyboard.contains(needed):
			_fail("The controls screen does not list %s:\n%s" % [needed, keyboard])
			return ""
	if keyboard.to_lower().contains("spray"):
		_fail("The controls screen still lists spray:\n%s" % keyboard)
		return ""
	_push_key(KEY_ESCAPE)
	if not paused or hud.controls_visible() or not hud.pause_panel.visible:
		_fail("Esc on the controls screen must go back to the pause menu, still paused.")
		return ""
	hud.controls_button.pressed.emit()
	hud.back_button.pressed.emit()
	if not paused or hud.controls_visible() or not hud.pause_panel.visible:
		_fail("Back on the controls screen must go back to the pause menu, still paused.")
		return ""
	hud.resume_button.pressed.emit()
	if paused or hud.controls_visible():
		_fail("Resume after the controls screen did not go back to play.")
		return ""
	# A touch screen's HUD (main.gd sets it up so), opened from its loading screen.
	var touch_hud := (load("res://game/scenes/ui/hud.tscn") as PackedScene).instantiate() as GameHUD
	root.add_child(touch_hud)
	touch_hud.set_touch_instructions()
	touch_hud.load_controls_button.pressed.emit()
	var touch := _controls_text(touch_hud)
	var shown := touch_hud.controls_visible()
	touch_hud.back_button.pressed.emit()
	var closed := not touch_hud.controls_visible()
	touch_hud.queue_free()
	if not shown or not closed:
		_fail("The loading screen's Controls button must open the controls screen, and Back close it.")
		return ""
	for needed: String in ["MOVE stick", "Drag on the right side", "RISE (hold)", "RUN (hold while moving)", "DROP (hold, in the air)", "DRIVE (beside a parked car)", "BRAKE (hold)", "GET OUT", "II (top right)"]:
		if not touch.contains(needed):
			_fail("The touch controls screen does not list %s:\n%s" % [needed, touch])
			return ""
	if touch.contains("Shift") or touch.to_lower().contains("spray"):
		_fail("The touch controls screen lists keys or spray:\n%s" % touch)
		return ""
	return "%d keyboard and %d touch lines" % [keyboard.count("\n") + 1, touch.count("\n") + 1]


## The desktop prompt beside a car: standing at the ferry fixture car's driver
## door (vehicle_cases.json enter), "F  Drive" shows; Esc pauses and hides it;
## Resume brings it back. Returns a summary, or "" after failing.
func _check_prompt_beside_car(main: GameMain, world: WorldLoader) -> String:
	var hud := main.hud
	var cases: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://game/tests/shared/vehicle_cases.json"))
	var entry := main.vehicles.row(str((cases as Dictionary).enter.car)) if cases is Dictionary else {}
	if entry.is_empty():
		_fail("The prompt check's fixture car is not a swappable row.")
		return ""
	var parked: Transform3D = entry.transform
	if not await _place_player(main.player, world, parked.origin - parked.basis.x * 1.6):
		return ""
	for _tick in 5:
		await physics_frame
	await process_frame
	var beside := [main.vehicles.can_enter(), hud.prompt_panel.visible, hud.prompt_text.text]
	_push_key(KEY_ESCAPE)
	var while_paused := [paused, hud.prompt_panel.visible]
	hud.resume_button.pressed.emit()
	await process_frame
	var resumed := [paused, hud.prompt_panel.visible, hud.prompt_text.text]
	if beside != [true, true, "F  Drive"] or while_paused != [true, false] or resumed != [false, true, "F  Drive"]:
		_fail("Beside a car the prompt must show \"F  Drive\", hide while paused and come back on Resume (beside: in reach, shown, text %s; paused: paused, shown %s; resumed: paused, shown, text %s)." % [beside, while_paused, resumed])
		return ""
	return "\"F  Drive\" beside a car, hidden while paused, back on Resume"


## The credits screen (owner, 2026-11-12) in the loaded game. With the ball rolling,
## Esc pauses and the pause menu's Credits opens the credits in its place: the game
## stays frozen (the clock at 0, the world, player, sky and cars stopped, the ball
## still) through the list and the Licences. Esc goes back a step at a time (the
## Licences, the list, the pause menu, still paused), as does Back;
## Resume plays on with the clock back, the ball rolling on, and no prompt away from
## a car. Returns a summary, or "" after failing.
func _check_credits_screen(main: GameMain) -> String:
	var hud := main.hud
	var ball: SoccerBall = get_nodes_in_group(SoccerBall.GROUP)[0]
	var scale := Engine.time_scale
	# The reset the check before ended with takes in the ball's next physics step,
	# and would stop a roll started before it.
	for _tick in 10:
		await physics_frame
	ball.sleeping = false
	ball.linear_velocity = Vector3(4.0, 0.0, 0.0)
	for _tick in 5:
		await physics_frame
	if ball.linear_velocity.length() < 1.0:
		_fail("Before the credits check the ball must be rolling (%.2f m/s)." % ball.linear_velocity.length())
		return ""
	await process_frame
	_push_key(KEY_ESCAPE)
	hud.credits_button.pressed.emit()
	var rolled_to := ball.global_position
	var moving := [main.get_node("WorldRoot"), main.get_node("Player"), main.get_node("WorldEnvironment"), main.vehicles]
	if not paused or Engine.time_scale != 0.0 or not hud.credits_visible() or hud.pause_panel.visible or not hud.credits_screen.can_process() \
	or moving.any(func(node: Node) -> bool: return node.can_process()):
		_fail("The pause menu's Credits must show the credits in the menu's place with the game frozen (paused %s, time scale %s, credits %s, pause menu %s)." % [paused, Engine.time_scale, hud.credits_visible(), hud.pause_panel.visible])
		return ""
	hud.credits_licences_button.pressed.emit()
	for _tick in 60:
		await physics_frame
	if ball.global_position != rolled_to or not paused or Engine.time_scale != 0.0:
		_fail("With the credits open the ball moved from %s to %s (paused %s, time scale %s)." % [rolled_to, ball.global_position, paused, Engine.time_scale])
		return ""
	await process_frame
	var steps := PackedStringArray()
	for expected: String in ["list", "pause menu"]:
		_push_key(KEY_ESCAPE)
		var at := "pause menu" if not hud.credits_visible() and hud.pause_panel.visible else ("list" if hud.credits_list.visible and not hud.credits_licences.visible else "Licences")
		if at != expected or not paused:
			_fail("Esc on the credits must go back a step, to the %s, still paused (it went to the %s, paused %s)." % [expected, at, paused])
			return ""
		steps.append(at)
	hud.credits_button.pressed.emit()
	hud.credits_back_button.pressed.emit()
	if hud.credits_visible() or not hud.pause_panel.visible or not paused:
		_fail("Back on the credits list must go back to the pause menu, still paused.")
		return ""
	hud.resume_button.pressed.emit()
	await process_frame
	if paused or Engine.time_scale != scale or hud.credits_visible() or hud.pause_panel.visible:
		_fail("Resume after the credits did not go back to play with the clock at %s (paused %s, time scale %s)." % [scale, paused, Engine.time_scale])
		return ""
	for _tick in 10:
		await physics_frame
	if ball.global_position.distance_to(rolled_to) < 0.05:
		_fail("After Resume the ball did not roll on from %s." % rolled_to)
		return ""
	if hud.prompt_panel.visible and not main.vehicles.can_enter():
		_fail("After Resume from the credits, away from any car, the prompt \"%s\" shows." % hud.prompt_text.text)
		return ""
	return "frozen through the list and the Licences, Esc back to the %s, Back and Resume" % " then ".join(steps)


## The options screen (owner, 2026-11-12) in the loaded game. With the ball rolling,
## Esc pauses and the pause menu's Options opens the shadow levels in its place,
## the game frozen (the clock at 0, the world, player, sky and cars stopped, the
## ball still). A level chosen there goes on at once, still paused, and is kept;
## Esc goes back to the pause menu, still paused, and Resume plays on with the
## clock back, the ball rolling on and the level still on. Medium is put back after.
## Returns a summary, or "" after failing.
func _check_options_screen(main: GameMain) -> String:
	var hud := main.hud
	var sun := main.get_node("Sun") as DirectionalLight3D
	var ball: SoccerBall = get_nodes_in_group(SoccerBall.GROUP)[0]
	var scale := Engine.time_scale
	if main.shadows.current != ShadowQuality.default_id():
		_fail("Before the options check the game must have the default shadows, not %s." % main.shadows.current)
		return ""
	for _tick in 10:
		await physics_frame
	ball.sleeping = false
	ball.linear_velocity = Vector3(-4.0, 0.0, 0.0)
	for _tick in 5:
		await physics_frame
	await process_frame
	_push_key(KEY_ESCAPE)
	hud.options_button.pressed.emit()
	var rolled_to := ball.global_position
	var moving := [main.get_node("WorldRoot"), main.get_node("Player"), main.get_node("WorldEnvironment"), main.vehicles]
	if not paused or Engine.time_scale != 0.0 or not hud.options_visible() or hud.pause_panel.visible or not hud.options_screen.can_process() \
	or moving.any(func(node: Node) -> bool: return node.can_process()):
		_fail("The pause menu's Options must show the shadow levels in the menu's place with the game frozen (paused %s, time scale %s, options %s, pause menu %s)." % [paused, Engine.time_scale, hud.options_visible(), hud.pause_panel.visible])
		return ""
	(hud.shadow_levels.get_node("high") as Button).button_pressed = true
	var file := ConfigFile.new()
	file.load(ShadowQuality.settings_path)
	if main.shadows.current != "high" or str(file.get_value(ShadowQuality.SECTION, ShadowQuality.KEY, "")) != "high" or not paused:
		_fail("Choosing High on the options screen must put it on at once, still paused, and keep it (on: %s, kept: %s, paused %s)." % [main.shadows.current, file.get_value(ShadowQuality.SECTION, ShadowQuality.KEY, ""), paused])
		return ""
	for _tick in 60:
		await physics_frame
	if ball.global_position != rolled_to or not paused or Engine.time_scale != 0.0:
		_fail("With the options open the ball moved from %s to %s (paused %s, time scale %s)." % [rolled_to, ball.global_position, paused, Engine.time_scale])
		return ""
	await process_frame
	_push_key(KEY_ESCAPE)
	if hud.options_visible() or not hud.pause_panel.visible or not paused:
		_fail("Esc on the options screen must go back to the pause menu, still paused.")
		return ""
	hud.resume_button.pressed.emit()
	await process_frame
	if paused or Engine.time_scale != scale or hud.options_visible() or hud.pause_panel.visible or main.shadows.current != "high" or not sun.shadow_enabled:
		_fail("Resume after the options did not play on with the clock at %s and High still on (paused %s, time scale %s, on: %s)." % [scale, paused, Engine.time_scale, main.shadows.current])
		return ""
	for _tick in 10:
		await physics_frame
	if ball.global_position.distance_to(rolled_to) < 0.05:
		_fail("After Resume the ball did not roll on from %s." % rolled_to)
		return ""
	main._on_shadow_quality_chosen("medium")
	return "frozen while open, High on at once and kept, Esc back to the pause menu, Resume with High still on"


## Every line the controls screen shows, headings and rows.
func _controls_text(hud: GameHUD) -> String:
	var lines := PackedStringArray()
	for label: Node in hud.controls_sections.find_children("*", "Label", true, false):
		lines.append((label as Label).text)
	return "\n".join(lines)


## The pause (owner, 2026-11-11) freezes everything that moves. With a car driving
## along the pitch, the player riding in it and the ball rolling across, Esc pauses:
## the menu shows and keeps running, the world, the player, the sky and the cars stop
## processing, shader time stops (Engine.time_scale 0), every gameplay action is let
## go, and nothing moves however long the pause lasts; Resume goes on from there with
## the clock back as it was. Then the same on foot, rising on the jetpack. Returns a
## summary, or "" after failing.
func _check_pause(main: GameMain) -> String:
	var player := main.get_node("Player") as PlayerController
	var vehicles := main.vehicles
	var ball: SoccerBall = get_nodes_in_group(SoccerBall.GROUP)[0]
	var car_id := ""
	for id: String in vehicles.swappable_ids():
		if str(vehicles.row(id).prop) == "parked_car":
			car_id = id
			break
	# Beside the pitch's centre line, driving along it (the vehicle contract's
	# heading for its ball case runs along the full-size pitch).
	var cases: Variant = JSON.parse_string(FileAccess.get_file_as_string(VEHICLE_CASES_PATH))
	var heading: Array = (cases as Dictionary).ball.heading_xz if cases is Dictionary else [1.0, 0.0]
	var along := Vector2(float(heading[0]), float(heading[1])).normalized()
	var across := Vector2(-along.y, along.x)
	var centre := Vector2(ball.spot.origin.x, ball.spot.origin.z)
	var problem := "no parked car" if car_id.is_empty() else vehicles.drive_from(car_id, centre - along * 20.0 + across * 10.0, along)
	if not problem.is_empty():
		_fail("The pause check could not start a drive: %s." % problem)
		return ""
	var car := vehicles.active_car()
	Input.action_press("move_forward")
	for _tick in 60:
		await physics_frame
	ball.sleeping = false
	ball.linear_velocity = Vector3(across.x, 0.0, across.y) * 5.0
	for _tick in 5:
		await physics_frame
	if car.linear_velocity.length() < 1.0 or ball.linear_velocity.length() < 1.0:
		_fail("Before the pause the car (%.2f m/s) and the ball (%.2f m/s) must be moving." % [car.linear_velocity.length(), ball.linear_velocity.length()])
		return ""
	var driving := await _paused_still(main, {"car": car, "player": player, "ball": ball})
	if driving.is_empty():
		return ""
	var moved := {"car": car.global_position, "ball": ball.global_position}
	for _tick in 30:
		await physics_frame
	if car.global_position.distance_to(moved.car) < 0.2 or ball.global_position.distance_to(moved.ball) < 0.2:
		_fail("After Resume the car moved %.2f m and the ball %.2f m: play did not go on." % [car.global_position.distance_to(moved.car), ball.global_position.distance_to(moved.ball)])
		return ""
	vehicles.force_exit()
	for _tick in 30:
		await physics_frame
	# On foot, rising on the jetpack: paused it hangs where it is, and Resume lets it
	# go on (the pause let go of Space, so it comes down).
	Input.action_press("jetpack")
	for _tick in 30:
		await physics_frame
	if player.velocity.y < 1.0:
		_fail("The player did not rise on the jetpack before the pause: %.2f m/s." % player.velocity.y)
		return ""
	var rising := await _paused_still(main, {"player": player})
	if rising.is_empty():
		return ""
	var hung := player.global_position
	for _tick in 30:
		await physics_frame
	if player.global_position.distance_to(hung) < 0.05:
		_fail("After Resume the player did not move on from %s." % hung)
		return ""
	for _tick in 600:
		await physics_frame
		if player.is_on_floor():
			break
	player.set_gameplay_enabled(false)
	return "driving: %s; rising on foot: %s" % [driving, rising]


## The tree pauses and resumes in the idle step, however that is asked for. The web
## resumes from a deferred call (its pointer-lock grant), which Godot flushes inside
## a physics tick: resumed there after a pause from the idle step, the physics
## server printed an error for every awake body (an engine error fails the suite)
## and ran the rest of that tick at the paused clock's zero step. With the ball
## rolling, a pause from the idle step takes at once; a resume asked for inside a
## physics tick, directly or by a deferred call, waits for the idle step, and the
## ball rolls on from where it stopped. Returns a summary, or "" after failing.
func _check_resume_in_physics(main: GameMain) -> String:
	var ball: SoccerBall = get_nodes_in_group(SoccerBall.GROUP)[0]
	var scale := Engine.time_scale
	var rolled := PackedStringArray()
	for deferred: bool in [false, true]:
		ball.reset_to_spot()
		for _tick in 30:
			await physics_frame
		ball.sleeping = false
		ball.linear_velocity = Vector3(3.0, 0.0, 0.5)
		for _tick in 6:
			await physics_frame
		await process_frame
		main._set_paused(true)
		if not paused or Engine.time_scale != 0.0:
			_fail("A pause asked for in the idle step must take at once (paused %s, time scale %s)." % [paused, Engine.time_scale])
			return ""
		var stopped := ball.global_position
		for _tick in 10:
			await physics_frame
			if ball.global_position != stopped:
				_fail("Paused, the rolling ball moved.")
				return ""
		await physics_frame
		if deferred:
			main._set_paused.call_deferred(false)
		else:
			main._set_paused(false)
			if not paused:
				_fail("A resume asked for inside a physics tick must wait for the idle step.")
				return ""
		# The next physics tick: the idle step between has resumed.
		await physics_frame
		if paused or Engine.time_scale != scale:
			_fail("A resume asked for inside a physics tick (%s) must take in the next idle step with the clock back at %s (paused %s, time scale %s)." % ["deferred" if deferred else "direct", scale, paused, Engine.time_scale])
			return ""
		for _tick in 4:
			await physics_frame
		var moved := ball.global_position.distance_to(stopped)
		if not ball.global_position.is_finite() or not ball.linear_velocity.is_finite() or moved < 0.05:
			_fail("After the resume the rolling ball must roll on: moved %.3f m, velocity %s." % [moved, ball.linear_velocity])
			return ""
		rolled.append("%s %.2f m" % ["deferred" if deferred else "direct", moved])
	ball.reset_to_spot()
	return "resumed from inside a physics tick in the idle step after, the ball rolling on (%s)" % ", ".join(rolled)


## Pauses as Esc does, checks that nothing in `bodies` (name -> Node3D) moves over
## three seconds of frames (180 at 60 a second; this runs at --fixed-fps, so wall
## time says nothing) while the pause menu stays live, and resumes as the Resume
## button does. Returns a summary, or "" after failing.
func _paused_still(main: GameMain, bodies: Dictionary) -> String:
	var scale := Engine.time_scale
	# Keys arrive in the idle step.
	await process_frame
	_push_key(KEY_ESCAPE)
	var at := {}
	for name: String in bodies:
		at[name] = (bodies[name] as Node3D).global_position
	var hud := main.hud
	var moving := [main.get_node("WorldRoot"), main.get_node("Player"), main.get_node("WorldEnvironment"), main.vehicles]
	if not paused or Engine.time_scale != 0.0 or not hud.pause_panel.visible or not hud.can_process() \
	or moving.any(func(node: Node) -> bool: return node.can_process()):
		_fail("Esc must pause the tree with the menu showing and running, the clock at 0 (time scale %s) and the world, player, sky and cars stopped." % Engine.time_scale)
		return ""
	var held := GameMain.GAMEPLAY_ACTIONS.filter(func(action: StringName) -> bool: return Input.is_action_pressed(action))
	if not held.is_empty():
		_fail("The pause left %s held." % [held])
		return ""
	var frames := 0
	while frames < 180:
		await physics_frame
		frames += 1
		for name: String in bodies:
			if (bodies[name] as Node3D).global_position != at[name]:
				_fail("Paused, the %s moved from %s to %s." % [name, at[name], (bodies[name] as Node3D).global_position])
				return ""
	await process_frame
	hud.resume_button.pressed.emit()
	if paused or Engine.time_scale != scale or hud.pause_panel.visible:
		_fail("Resume did not unpause with the clock back at %s (paused %s, time scale %s)." % [scale, paused, Engine.time_scale])
		return ""
	return "%s still over %d frames" % [", ".join(PackedStringArray(bodies.keys())), frames]


## The pitch's football (game/scripts/world/soccer_ball.gd): the ball on a full-size
## pitch's centre spot, on the loose-prop layer the player's mask leaves out, colliding
## with the world and the street props. The stock player walking into it moves it on
## ahead of them, and it comes to rest on the turf; running into it sends it rolling;
## dropped in the bay off the island, or through the land, it goes back to its centre
## spot. Returns a summary, or "" after failing.
func _check_soccer_ball(main: GameMain, world: WorldLoader) -> String:
	var player := main.get_node("Player") as PlayerController
	var spots := _full_pitch_spots()
	var ball: SoccerBall = null
	for node: Node in get_nodes_in_group(SoccerBall.GROUP):
		var candidate := node as SoccerBall
		if candidate != null and spots.any(func(spot: Vector2) -> bool: return spot.distance_to(Vector2(candidate.spot.origin.x, candidate.spot.origin.z)) < 0.05):
			ball = candidate
			break
	if ball == null:
		_fail("No soccer ball rests on a full-size pitch's centre spot %s." % [spots])
		return ""
	if ball.collision_layer != SoccerBall.LOOSE_PROP_LAYER or (player.collision_mask & ball.collision_layer) != 0 or ball.collision_mask != (1 | 1 << 3):
		_fail("The soccer ball must sit on the loose-prop layer, outside the player's mask, and meet the world and the street props: layer %d, mask %d, player mask %d." % [ball.collision_layer, ball.collision_mask, player.collision_mask])
		return ""
	if not await _ball_rests(ball) or ball.global_position.distance_to(ball.spot.origin) > 0.1:
		_fail("The soccer ball did not rest on its spot %s: at %s." % [ball.spot.origin, ball.global_position])
		return ""
	# Walk into it from 2.5 m west, heading east across the open pitch.
	var east := Vector3.RIGHT
	var start := ball.global_position
	if not await _place_player(player, world, start - east * 2.5):
		return ""
	(player.get_node("CameraPivot") as Node3D).rotation = Vector3(0.0, atan2(-east.x, -east.z), 0.0)
	Input.action_press("move_forward")
	for _tick in 90:
		await physics_frame
	Input.action_release("move_forward")
	var pushed := (ball.global_position - start).dot(east)
	if pushed < 2.0:
		_fail("Walking into the soccer ball moved it %.2f m east, not at least 2 m." % pushed)
		return ""
	if not await _ball_rests(ball):
		_fail("The walked soccer ball did not come to rest: moving at %.2f m/s." % ball.linear_velocity.length())
		return ""
	var rolled := (ball.global_position - start).dot(east)
	# Run into it: it goes off much faster than a walk sends it.
	var from := ball.global_position
	if not await _place_player(player, world, from - east * 4.0):
		return ""
	(player.get_node("CameraPivot") as Node3D).rotation = Vector3(0.0, atan2(-east.x, -east.z), 0.0)
	Input.action_press("move_forward")
	Input.action_press("run")
	var fastest := 0.0
	for _tick in 45:
		await physics_frame
		fastest = maxf(fastest, ball.linear_velocity.length())
	Input.action_release("run")
	Input.action_release("move_forward")
	player.set_gameplay_enabled(false)
	if fastest < 12.0:
		_fail("Running into the soccer ball sent it off at %.2f m/s, not at least 12." % fastest)
		return ""
	# A glancing walk: the capsule's axis passes 0.4 m to the side of the ball's
	# centre, a thin touch. The ball goes off aside, away from the player, and well
	# under the walk's speed along it: only a ball the capsule has run through goes
	# on along the run (as it did here, at about 4.3 m/s, at c1cdac7f).
	if not await _place_ball(ball, ball.spot.origin):
		return ""
	var side := Vector3.BACK
	if not await _place_player(player, world, ball.global_position - east * 4.0 + side * 0.4):
		return ""
	(player.get_node("CameraPivot") as Node3D).rotation = Vector3(0.0, atan2(-east.x, -east.z), 0.0)
	var glance := Vector3.ZERO
	Input.action_press("move_forward")
	for _tick in 90:
		await physics_frame
		if ball.linear_velocity.length() > glance.length():
			glance = ball.linear_velocity
	Input.action_release("move_forward")
	player.set_gameplay_enabled(false)
	if -glance.dot(side) < 0.5 or glance.dot(east) > 3.0:
		_fail("Walked past glancing (0.4 m to the side of its centre), the ball must go off aside, at least 0.5 m/s away from the player and under 3 m/s along the walk: %.2f m/s aside, %.2f along." % [-glance.dot(side), glance.dot(east)])
		return ""
	# Over the bay, off the island: back on its spot. Then the same from below the land.
	var resets := ball.resets
	var over_bay := ball.spot.origin
	while world.get_boundary().contains_position(over_bay):
		over_bay += east * 10.0
	over_bay += east * 30.0
	for case: Vector3 in [over_bay, ball.spot.origin - Vector3.UP * 10.0]:
		ball.global_position = case
		ball.linear_velocity = Vector3.ZERO
		# A ball at rest sleeps and skips the check, as it can't have moved.
		ball.sleeping = false
		for _tick in 10:
			await physics_frame
		if ball.global_position.distance_to(ball.spot.origin) > 0.05:
			_fail("The soccer ball dropped at %s did not go back to its spot %s: at %s." % [case, ball.spot.origin, ball.global_position])
			return ""
	if ball.resets != resets + 2:
		_fail("The soccer ball went back to its spot %d times for its 2 drops." % (ball.resets - resets))
		return ""
	var goals := await _check_goals(player, world, ball)
	if goals.is_empty():
		return ""
	return "walked %.1f m on, at rest %.1f m on, run off at %.1f m/s, a glancing walk sent aside at %.1f m/s (%.1f along), back from the bay and from below the land; %s" % [pushed, rolled, fastest, -glance.dot(side), glance.dot(east), goals]


## Goals (owner, 2026-11-11). The stock player running into the ball in front of the
## full-size goal nearest its spot sends it in through the mouth: one goal, there, a
## burst of confetti at that goal, and GOAL_RESET_S later the ball back on its spot at
## rest, the confetti gone soon after. Rolled at a post from outside, or past the
## goal's side, it scores nothing. Rolled into a GAA goal and through a rugby H it
## scores too: every kind of goal on the island. Returns a summary, or "" after failing.
func _check_goals(player: PlayerController, world: WorldLoader, ball: SoccerBall) -> String:
	var kinds := {}
	for goal: Dictionary in ball.goals:
		kinds[str(goal.prop)] = int(kinds.get(str(goal.prop), 0)) + 1
	if kinds.keys().size() != 3 or not kinds.has("goal_soccer") or not kinds.has("goal_gaa") or not kinds.has("goal_rugby"):
		_fail("The ball must know every goal on the island, soccer, GAA and rugby: it knows %s." % kinds)
		return ""
	var scored: Array[String] = []
	ball.scored.connect(func(id: String) -> void: scored.append(id))
	# The kick: the player runs into the ball from 12 m back, at the full run's
	# 20 m/s, the ball 3 m out in front of the middle of the mouth, along the compass
	# direction nearest the goal's axis. (The stock controller speeds each axis up
	# apart, so a slanting run-up curves aside; from 3 m out the ball still comes in
	# well inside the posts.)
	var soccer := _goal_of(ball, "goal_soccer")
	var frame: Transform3D = soccer.transform
	var into := Vector3(frame.basis.z.x, 0.0, frame.basis.z.z).normalized()
	var run := Vector3(signf(into.x), 0.0, 0.0) if absf(into.x) >= absf(into.z) else Vector3(0.0, 0.0, signf(into.z))
	if not await _place_ball(ball, frame * Vector3(0.0, 0.0, -3.0)):
		return ""
	if not await _place_player(player, world, ball.global_position - run * 12.0):
		return ""
	(player.get_node("CameraPivot") as Node3D).rotation = Vector3(0.0, atan2(-run.x, -run.z), 0.0)
	var before := ball.goals_scored
	var kick_speed := 0.0
	Input.action_press("move_forward")
	Input.action_press("run")
	for _tick in 120:
		await physics_frame
		if ball.linear_velocity.length() < 1.0:
			kick_speed = Vector2(player.velocity.x, player.velocity.z).length()
		if ball.goals_scored > before:
			break
	Input.action_release("run")
	Input.action_release("move_forward")
	player.set_gameplay_enabled(false)
	if ball.goals_scored != before + 1 or scored != [str(soccer.id)] or kick_speed < 19.0:
		_fail("Kicked in through the mouth of %s at the full run (%.1f m/s) the ball must score one goal there: %d goals, at %s, ball at %s." % [soccer.id, kick_speed, ball.goals_scored - before, scored, ball.global_position])
		return ""
	var confetti := _confetti_at(ball, soccer)
	if confetti == null:
		_fail("The goal at %s set off no confetti there." % soccer.id)
		return ""
	var resets := ball.resets
	for _tick in roundi((SoccerBall.GOAL_RESET_S + 0.5) * Engine.physics_ticks_per_second):
		await physics_frame
		if ball.resets > resets:
			break
	if ball.resets != resets + 1 or not await _ball_rests(ball) or ball.global_position.distance_to(ball.spot.origin) > 0.1:
		_fail("After the goal the ball must go back to its spot %s at rest: at %s after %d resets." % [ball.spot.origin, ball.global_position, ball.resets - resets])
		return ""
	for _tick in roundi(4.0 * Engine.physics_ticks_per_second):
		await physics_frame
		if not is_instance_valid(confetti):
			break
	if is_instance_valid(confetti):
		_fail("The goal's confetti was still there 4 s after the ball went back.")
		return ""
	# Near misses: at the post from outside, and past the side of the goal.
	var half := float(soccer.half_m)
	for offset: float in [half + SoccerBall.RADIUS_M + 0.05, half + 0.6]:
		if not await _place_ball(ball, frame * Vector3(offset, 0.0, -2.0)):
			return ""
		ball.linear_velocity = into * 6.0
		for _tick in 90:
			await physics_frame
		if ball.goals_scored != before + 1:
			_fail("A ball rolled %.2f m out from the middle of %s, outside its post, scored." % [offset, soccer.id])
			return ""
	# Every kind of goal: rolled into a GAA goal and through a rugby H from 2 m out.
	for prop: String in ["goal_gaa", "goal_rugby"]:
		var goal := _goal_of(ball, prop)
		var at: Transform3D = goal.transform
		if not await _place_ball(ball, at * Vector3(0.0, 0.0, -2.0)):
			return ""
		ball.linear_velocity = Vector3(at.basis.z.x, 0.0, at.basis.z.z).normalized() * 6.0
		var count := ball.goals_scored
		for _tick in 60:
			await physics_frame
			if ball.goals_scored > count:
				break
		if ball.goals_scored != count + 1 or scored.back() != str(goal.id) or _confetti_at(ball, goal) == null:
			_fail("Rolled in through the mouth of %s the ball scored %d goals (last at %s), with confetti %s." % [goal.id, ball.goals_scored - count, scored.back(), _confetti_at(ball, goal) != null])
			return ""
	ball.reset_to_spot()
	if not await _ball_rests(ball):
		_fail("The ball did not come to rest on its spot after the goals.")
		return ""
	return "goals %s kicked in by the player at %.1f m/s, %s and %s rolled in, with confetti at each and the ball back on its spot; none from outside the post or past the goal (%d goals on the island: %s)" % [soccer.id.get_slice(":", 3), kick_speed, scored[1].get_slice(":", 3), scored[2].get_slice(":", 3), ball.goals.size(), kinds]


## The goal of this kind nearest the ball's spot, the largest first.
func _goal_of(ball: SoccerBall, prop: String) -> Dictionary:
	var best := {}
	for goal: Dictionary in ball.goals:
		if str(goal.prop) != prop:
			continue
		var distance := (goal.transform as Transform3D).origin.distance_to(ball.spot.origin)
		if best.is_empty() or float(goal.half_m) > float(best.half_m) + 0.01 \
		or (is_equal_approx(float(goal.half_m), float(best.half_m)) and distance < (best.transform as Transform3D).origin.distance_to(ball.spot.origin)):
			best = goal
	return best


## Puts the ball at rest on the ground under at.
func _place_ball(ball: SoccerBall, at: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 5.0, at + Vector3.DOWN * 5.0, ball.collision_mask, [ball.get_rid()])
	var hit := ball.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		_fail("No ground for the ball at %s." % at)
		return false
	ball.place((hit.position as Vector3) + Vector3.UP * SoccerBall.RADIUS_M)
	for _tick in 3:
		await physics_frame
	return true


## The confetti burst at a goal's crossbar, or null.
func _confetti_at(ball: SoccerBall, goal: Dictionary) -> CPUParticles3D:
	var crossbar: Vector3 = (goal.transform as Transform3D) * Vector3(0.0, float(goal.crossbar_m), 0.0)
	for node: Node in ball.get_parent().get_children():
		if node is CPUParticles3D and str(node.name).begins_with("GoalConfetti") and (node as CPUParticles3D).global_position.distance_to(crossbar) < 1.0:
			return node as CPUParticles3D
	return null


## The centre spots (world x, z) of the full-size pitches in the street-detail zones.
func _full_pitch_spots() -> Array[Vector2]:
	var spots: Array[Vector2] = []
	var config: Variant = JSON.parse_string(FileAccess.get_file_as_string(STREET_DETAIL_ZONES_PATH))
	var zones: Array = (config as Dictionary).get("zones", []) if config is Dictionary else []
	for zone: Variant in zones:
		var ground: Variant = (zone as Dictionary).get("ground", {}) if zone is Dictionary else {}
		var pitches: Array = (ground as Dictionary).get("pitches", []) if ground is Dictionary else []
		for pitch: Variant in pitches:
			if pitch is Dictionary and str((pitch as Dictionary).get("layout", "")) == "full_size":
				var centre: Array = (pitch as Dictionary).get("centre_xz", [])
				spots.append(Vector2(float(centre[0]), float(centre[1])))
	return spots


## Puts the stock player on the ground at the column through at, with gameplay on.
func _place_player(player: PlayerController, world: WorldLoader, at: Vector3) -> bool:
	player.set_gameplay_enabled(false)
	var query := PhysicsRayQueryParameters3D.create(Vector3(at.x, at.y + 20.0, at.z), Vector3(at.x, at.y - 20.0, at.z), player.collision_mask, [player.get_rid()])
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty() or not world.get_boundary().contains_position(at):
		_fail("No ground for the player at %s." % at)
		return false
	player.global_transform = Transform3D(Basis.IDENTITY, (hit.position as Vector3) + Vector3.UP * 0.05)
	player.velocity = Vector3.ZERO
	player.set_gameplay_enabled(true)
	for _tick in 20:
		await physics_frame
	if not player.is_on_floor():
		_fail("The player did not settle at %s: at %s." % [at, player.global_position])
		return false
	return true


## Waits until the ball rests (asleep, or still for half a second), at most 30 s.
func _ball_rests(ball: SoccerBall) -> bool:
	var still := 0
	for _tick in 1800:
		await physics_frame
		still = still + 1 if ball.linear_velocity.length() < 0.05 else 0
		if ball.sleeping or still >= 30:
			return true
	return false


## Why the distant horizon would not work as scenery, or "". It collides with
## nothing; its meshes draw on the world's render layer and cast no shadow; some of
## it stands at every degree of bearing round the island; and the gameplay
## camera's far plane holds its farthest band and ridge tops (the mapped
## backgrounds' profile points; the land carried on behind them is meant to pass
## the far plane) from the playable boundary's farthest point, plus the camera arm.
func _horizon_problem(horizon: Node3D, world: WorldLoader, far: float, arm_m: float) -> String:
	for kind: String in ["CollisionObject3D", "CollisionShape3D", "CollisionPolygon3D"]:
		if not horizon.find_children("*", kind, true, false).is_empty():
			return "The distant horizon must collide with nothing (it has a %s)." % kind
	var items := horizon.find_children("*", "GeometryInstance3D", true, false)
	if items.is_empty():
		return "The distant horizon has no meshes."
	var covered := PackedByteArray()
	covered.resize(360)
	for item: GeometryInstance3D in items:
		var mesh: Mesh = (item as MeshInstance3D).mesh if item is MeshInstance3D else null
		if mesh == null or item.layers != 1 or item.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			return "Horizon item %s must be a mesh on render layer 1 alone that casts no shadow." % item.name
		var to_world := _off_tree_world_transform(item, world)
		var faces := mesh.get_faces()
		for i in range(0, faces.size(), 3):
			var bearings: Array[float] = []
			for corner in 3:
				var at := to_world * faces[i + corner]
				bearings.append(fposmod(rad_to_deg(atan2(at.x, -at.z)), 360.0))
			_cover_bearings(covered, bearings)
	for degree in 360:
		if covered[degree] == 0:
			return "The distant horizon leaves a gap at a bearing of %d degrees." % degree
	var farthest := 0.0
	for sector: Node in horizon.get_node("Continuous360Horizon").get_children():
		for vertex: Vector3 in (sector as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array:
			farthest = maxf(farthest, Vector2(vertex.x, vertex.z).length())
	for background: String in ["MappedWesternBackground", "MappedEasternBackground"]:
		for profile: Dictionary in horizon.get_node(background).registration.profiles:
			for point: Array in profile.points:
				farthest = maxf(farthest, Vector2(float(point[0]), float(point[2])).length())
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(world.default_manifest_path))
	var edge := 0.0
	for component: Dictionary in manifest.playable_boundary.components:
		for point: Array in component.outer:
			edge = maxf(edge, Vector2(float(point[0]), float(point[1])).length())
	if edge <= 0.0 or far < farthest + edge + arm_m:
		return "The gameplay camera's far plane (%.0f m) must hold the horizon's farthest band and ridge tops (%.0f m out) from the island's farthest edge (%.0f m out) and the camera arm (%.1f m)." % [far, farthest, edge, arm_m]
	return ""


## Marks the whole degrees a triangle spans, given its corners' bearings (degrees
## round the compass): the arc holding all three starts after the widest gap
## between them.
func _cover_bearings(covered: PackedByteArray, bearings: Array[float]) -> void:
	bearings.sort()
	var gaps := [bearings[1] - bearings[0], bearings[2] - bearings[1], bearings[0] + 360.0 - bearings[2]]
	var widest := gaps.find(gaps.max())
	var start: float = bearings[(widest + 1) % 3]
	for degree in range(floori(start), floori(start + 360.0 - float(gaps[widest])) + 1):
		covered[posmod(degree, 360)] = 1


func _off_tree_world_transform(node: Node3D, scene_root: Node3D) -> Transform3D:
	var composed := node.transform
	var parent := node.get_parent()
	while parent != null:
		if parent is Node3D:
			composed = (parent as Node3D).transform * composed
		if parent == scene_root:
			return composed
		parent = parent.get_parent()
	return Transform3D()


func _action_has_physical_key(action: StringName, physical_keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey and (event as InputEventKey).physical_keycode == physical_keycode:
			return true
	return false


## A key going down or up, as the platform sends it, applied at once.
func _send_key(physical_keycode: Key, pressed: bool) -> void:
	var key := InputEventKey.new()
	key.physical_keycode = physical_keycode
	key.pressed = pressed
	Input.parse_input_event(key)
	Input.flush_buffered_events()


## A tap of a key, delivered to the game's nodes as the window delivers it.
func _push_key(keycode: Key) -> void:
	for pressed: bool in [true, false]:
		var key := InputEventKey.new()
		key.keycode = keycode
		key.physical_keycode = keycode
		key.pressed = pressed
		root.push_input(key)


## Shader code without its // comments.
func _without_comments(code: String) -> String:
	var lines := PackedStringArray()
	for line in code.split("\n"):
		lines.append(line.get_slice("//", 0))
	return "\n".join(lines)


func _fail(message: String) -> void:
	push_error(message)
	DirAccess.remove_absolute(ShadowQuality.settings_path)
	quit(1)
