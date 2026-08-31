extends SceneTree

const REQUIRED_ACTIONS := [
	"move_forward", "move_back", "move_left", "move_right", "run", "jetpack",
	"spray", "recover", "pause", "quit_game", "toggle_debug",
]
const EXPECTED_BILLBOARD_TEXTURE := "res://game/resources/textures/context/sf_skyline_owner_silhouette_final.png"
const EXPECTED_BILLBOARD_TEXTURE_SHA256 := "9c499ca3db08769142aac69b61e7d8fdf2aa84cd084b6716a19e7c504ba0b0c5"
const EXPECTED_BILLBOARD_TEXTURE_SIZE := Vector2i(2212, 340)
const EXPECTED_BILLBOARD_SIZE := Vector2(3900.0, 600.0)
const EXPECTED_BILLBOARD_TRANSFORM := Transform3D(Basis.IDENTITY, Vector3(-1875.0, 264.85, 4306.4))
const EXPECTED_WATER_SIZE := Vector2(6000.0, 6000.0)
const EXPECTED_WATER_Y := -0.12
const EXPECTED_WATER_COLOR := Color(0.17, 0.45, 0.61, 0.82)
const EXPECTED_WATER_ROUGHNESS := 0.72


func _initialize() -> void:
	for action: String in REQUIRED_ACTIONS:
		if not InputMap.has_action(action):
			_fail("Missing input action: %s" % action)
			return
	if not _action_has_physical_key("jetpack", KEY_SPACE):
		_fail("Jetpack input must be bound to physical Space.")
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
	if player == null or player.collision_layer != 2 or player.collision_mask != 1:
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
	player.free()

	var world_scene := load("res://game/scenes/world/world_root.tscn") as PackedScene
	var world := world_scene.instantiate() as Node3D
	for required_path: String in [
		"PlayableWorld/GroundAndAreas",
		"PlayableWorld/RoadsAndPaths",
		"PlayableWorld/Buildings",
		"ContextWorld/Water",
		"ContextWorld/YerbaBuenaIsland",
		"ContextWorld/BayBridge",
		"ContextWorld/WesternBayBridgeModel",
		"ContextWorld/BoundaryAttachedVisuals",
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
	var water_material := water_mesh.material as StandardMaterial3D if water_mesh != null else null
	if water == null or water_mesh == null or water_material == null:
		_fail("Water must remain a MeshInstance3D with a PlaneMesh and StandardMaterial3D.")
		return
	if water_mesh.size != EXPECTED_WATER_SIZE \
	or not is_equal_approx(_off_tree_world_transform(water, world).origin.y, EXPECTED_WATER_Y) \
	or water.layers != 1 \
	or water.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
		_fail("Water size, world elevation, render layer, or shadow setting drifted.")
		return
	if water_material.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA \
	or not water_material.albedo_color.is_equal_approx(EXPECTED_WATER_COLOR) \
	or not is_equal_approx(water_material.roughness, EXPECTED_WATER_ROUGHNESS):
		_fail("Water translucent color or roughness drifted.")
		return
	if not water.find_children("*", "CollisionObject3D", true, false).is_empty() \
	or not water.find_children("*", "CollisionShape3D", true, false).is_empty() \
	or not water.find_children("*", "CollisionPolygon3D", true, false).is_empty():
		_fail("Water must remain visual-only with no collision body, shape, or polygon descendants.")
		return
	var western_bridge := world.get_node("ContextWorld/WesternBayBridgeModel") as Node3D
	if western_bridge == null \
	or western_bridge.find_children("*", "MeshInstance3D", true, false).is_empty() \
	or not western_bridge.find_children("*", "CollisionObject3D", true, false).is_empty() \
	or str(western_bridge.get_meta("license", "")) != "CC BY 4.0":
		_fail("Western Bay Bridge asset must be visible, attributed, and non-colliding.")
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
	or Vector2i(billboard_texture.get_width(), billboard_texture.get_height()) != EXPECTED_BILLBOARD_TEXTURE_SIZE \
	or FileAccess.get_sha256(EXPECTED_BILLBOARD_TEXTURE) != EXPECTED_BILLBOARD_TEXTURE_SHA256:
		_fail("SF billboard texture identity, dimensions, or source hash drifted.")
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
	or environment.ambient_light_source != Environment.AMBIENT_SOURCE_COLOR \
	or not environment.ambient_light_color.is_equal_approx(Color(0.71, 0.77, 0.82, 1.0)) \
	or not is_equal_approx(environment.ambient_light_energy, 0.65) \
	or not is_zero_approx(environment.ambient_light_sky_contribution):
		_fail("Main scene must use explicit color ambient fill without a missing Sky dependency.")
		return
	main.free()
	print("PASS: gameplay inputs, 4/20 m/s movement defaults, 30/40 m/s^2 response, jetpack defaults, boundary cases, scene hierarchies, water visual-only contract, billboard contract, layer defaults, and ambient fill")
	quit(0)


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
