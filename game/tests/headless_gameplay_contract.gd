extends SceneTree

const REQUIRED_ACTIONS := [
	"move_forward", "move_back", "move_left", "move_right", "run", "jetpack", "fast_drop",
	"spray", "recover", "pause", "quit_game", "toggle_debug",
]
const EXPECTED_BILLBOARD_TEXTURE := "res://game/resources/textures/context/sf_skyline_owner_silhouette_final.png"
const EXPECTED_BILLBOARD_TEXTURE_SIZE := Vector2i(2212, 340)
const EXPECTED_BILLBOARD_SIZE := Vector2(3900.0, 600.0)
const EXPECTED_BILLBOARD_TRANSFORM := Transform3D(Basis.IDENTITY, Vector3(-1875.0, 264.85, 4306.4))
const EXPECTED_WATER_Y := -0.12
const EXPECTED_WATER_SHADER := "res://game/resources/materials/world/water/bay_water.gdshader"
## The largest camera far plane in use: the island overviews' in
## game/tests/shared/building_shots.gd, read from it; gameplay's camera uses player.tscn's.
const BUILDING_SHOTS := preload("res://game/tests/shared/building_shots.gd")
const WATER_LARGEST_CAMERA_FAR_M: float = BUILDING_SHOTS.ISLAND_CAMERA_FAR_M
## Cameras stay within this of the origin: the island (about 950 m) and its overview poses.
const WATER_CAMERA_REACH_M := 2000.0
## The street-detail zones: the soccer ball's check finds the full-size pitch's
## centre spot in their ground blocks (tools/lib/sports-pitch.mjs).
const STREET_DETAIL_ZONES_PATH := "res://tools/config/street-detail-zones.json"


func _initialize() -> void:
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
	for action_value: Variant in InputMap.get_actions():
		var action := str(action_value).to_lower()
		if "vehicle" in action or "car_" in action:
			_fail("Deferred vehicle action leaked into the first playable: %s" % action)
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
	var pool := player.get_node("SprayController/TagInstances") as TagInstancePool
	if arm == null or camera == null or camera.get_parent() != arm or arm.collision_mask != 1:
		_fail("CameraPivot -> SpringArm3D -> Camera3D contract is invalid.")
		return
	if camera_pivot == null \
	or not is_equal_approx(camera_pivot.position.y, 2.0) \
	or not is_equal_approx(arm.spring_length, 5.5) \
	or not is_equal_approx(arm.rotation.x, deg_to_rad(-8.0)):
		_fail("Initial third-person camera framing defaults drifted.")
		return
	if pool == null or pool.session_limit != 64:
		_fail("Session tag limit must default to 64.")
		return
	var gameplay_far := camera.far
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
		"ContextWorld/SanFranciscoBillboard",
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
	var reach := far_share * WATER_LARGEST_CAMERA_FAR_M + WATER_CAMERA_REACH_M
	if water_mesh.size != Vector2(2.0, 2.0) \
	or water_mesh.subdivide_width != water_mesh.subdivide_depth \
	or grid_rows % 2 != 1 or grid_rows != water_mesh.subdivide_width + 1 \
	or far_share <= 0.0 or far_share >= 1.0 \
	or gameplay_far > WATER_LARGEST_CAMERA_FAR_M \
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
	var billboard := world.get_node("ContextWorld/SanFranciscoBillboard") as MeshInstance3D
	var billboard_mesh := billboard.mesh as QuadMesh if billboard != null else null
	var billboard_material := billboard_mesh.material as StandardMaterial3D if billboard_mesh != null else null
	var billboard_texture := billboard_material.albedo_texture if billboard_material != null else null
	if billboard == null \
	or billboard_mesh == null \
	or billboard_material == null \
	or billboard_texture == null:
		_fail("SF billboard mesh, material, or texture is missing.")
		return
	if billboard.transform != EXPECTED_BILLBOARD_TRANSFORM \
	or billboard_mesh.size != EXPECTED_BILLBOARD_SIZE:
		_fail("SF billboard exact transform or QuadMesh size drifted.")
		return
	if billboard_texture.resource_path != EXPECTED_BILLBOARD_TEXTURE \
	or Vector2i(billboard_texture.get_width(), billboard_texture.get_height()) != EXPECTED_BILLBOARD_TEXTURE_SIZE:
		_fail("SF billboard texture identity or dimensions drifted.")
		return
	if billboard.layers != 1 \
	or billboard.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF \
	or not billboard.find_children("*", "CollisionObject3D", true, false).is_empty():
		_fail("SF billboard must remain layer-1, shadowless, and non-colliding.")
		return
	if billboard_material.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA \
	or billboard_material.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED \
	or billboard_material.cull_mode != BaseMaterial3D.CULL_DISABLED \
	or billboard_material.billboard_mode != BaseMaterial3D.BILLBOARD_ENABLED:
		_fail("SF billboard material must remain transparent, unshaded, double-sided, and camera-facing.")
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
	var daylight := environment.sky.sky_material as ProceduralSkyMaterial
	if daylight == null \
	or daylight.sky_energy_multiplier <= 0.0 \
	or daylight.ground_energy_multiplier <= 0.0:
		_fail("Approved daylight needs an editable procedural sky with lit sky and ground hemispheres.")
		return
	var sun := main.get_node("Sun") as DirectionalLight3D
	var solar := Vector3(-float(sun.get_meta("solar_elevation_deg")), 180.0 - float(sun.get_meta("solar_azimuth_deg")), 0.0)
	if not sun.rotation_degrees.is_equal_approx(solar):
		_fail("Sun rotation must follow its solar metadata: (-elevation, 180 - azimuth, 0).")
		return
	main.free()
	call_deferred("_check_ferry_solidity")


## The ferry terminal's scenery (game/scripts/world/ferry_terminal.gd) lies off the
## walk route, but a jetpack landing on it must never fall through: in the loaded
## world, straight down onto the float's deck, the breakwater, the docked boat and
## the gangway, the first world-solid hit is the terminal's own body, which refuses
## the spray (receiver_kind none).
func _check_ferry_solidity() -> void:
	create_timer(240.0, true, false, true).timeout.connect(func() -> void: _fail("The ferry solidity check timed out."))
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	main.capture_mouse_on_ready = false
	var world := main.get_node("WorldRoot") as WorldLoader
	var load_failures: Array[String] = []
	world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: load_failures.append("%s: %s" % [code, message]))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while not main.is_play_ready() and load_failures.is_empty() and Time.get_ticks_msec() - started < 180000:
		await process_frame
	if not load_failures.is_empty() or not main.is_play_ready():
		_fail("The world did not reach play for the ferry solidity check: %s" % [load_failures])
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
	main.queue_free()
	print("PASS: gameplay inputs, 4/20 m/s movement defaults, 30/40 m/s^2 response, jetpack and fast drop defaults, boundary cases, scene hierarchies, water visual-only contract, billboard contract, layer defaults, procedural daylight, the ferry terminal solid from above (%s), and the pitch's ball (%s)" % [", ".join(heights), ball])
	quit(0)


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
	return "walked %.1f m on, at rest %.1f m on, run off at %.1f m/s, back from the bay and from below the land" % [pushed, rolled, fastest]


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


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
