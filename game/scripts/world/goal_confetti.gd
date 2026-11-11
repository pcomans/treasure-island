extends CPUParticles3D
## The burst of a goal (owner, 2026-11-11; soccer_ball.gd starts it): paper
## confetti in bright colours thrown up out of the goal's mouth, along its
## crossbar and out over the pitch, fluttering as it slows and drifts down, gone in
## under three seconds.
##
## One node per burst, freed when its last piece is gone. A CPUParticles3D is
## simulated on the CPU and drawn as one MultiMesh, so it looks the same in
## Forward+ and in Compatibility (the web build). Each piece is an unshaded card,
## upright and spinning about its upright axis, so it flutters as it falls (edge on,
## it all but vanishes), with no texture and no transparency to sort. Its colour is
## the palette's on screen: unshaded colour still goes through the camera's exposure
## and tone map, so each piece is given the colour that comes out of them as
## designed (on_screen). It pauses with the game, as the world it hangs under does.

## The confetti's colours as they show on screen (sRGB): red, yellow, green, blue,
## pink, orange and purple. No white, which the clouds would swallow.
const COLOURS := [Color("ff3b30"), Color("ffcc00"), Color("34c759"), Color("0a84ff"), Color("ff2d92"), Color("ff9500"), Color("af52de")]
const LIFETIME_S := 2.6
## Pieces per metre of the mouth's width, from MIN_PIECES to MAX_PIECES: about 290
## at a full-size soccer goal, so the burst still reads from 20 m.
const PIECES_PER_M := 40.0
const MIN_PIECES := 90
const MAX_PIECES := 320
## A piece of paper, before its random scale (m).
const PIECE_M := Vector2(0.12, 0.16)

static var _mesh: QuadMesh


## Starts the burst at a goal (once this node is in the tree): the goal's frame
## (origin on the middle of the goal line, -Z toward the pitch), its mouth's half
## width and its crossbar's height (m).
func start(goal: Transform3D, half_m: float, crossbar_m: float) -> void:
	amount = clampi(roundi(PIECES_PER_M * half_m * 2.0), MIN_PIECES, MAX_PIECES)
	emission_box_extents = Vector3(half_m, 0.1, 0.15)
	global_transform = Transform3D(goal.basis, goal * Vector3(0.0, crossbar_m, -0.2))
	color_initial_ramp = _palette(_environment())
	emitting = true


func _init() -> void:
	one_shot = true
	emitting = false
	explosiveness = 0.85
	lifetime = LIFETIME_S
	lifetime_randomness = 0.2
	local_coords = false
	draw_order = CPUParticles3D.DRAW_ORDER_INDEX
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Thrown up and out over the pitch (the goal's -Z), widely spread.
	emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	direction = Vector3(0.0, 1.0, -0.55)
	spread = 42.0
	initial_velocity_min = 4.0
	initial_velocity_max = 9.0
	# Paper: drag takes most of its speed and gravity only a little of its fall.
	gravity = Vector3(0.0, -3.5, 0.0)
	damping_min = 2.0
	damping_max = 3.5
	# Each card turns about its upright axis at its own speed: a flutter.
	particle_flag_rotate_y = true
	angle_min = 0.0
	angle_max = 360.0
	angular_velocity_min = -720.0
	angular_velocity_max = 720.0
	scale_amount_min = 0.7
	scale_amount_max = 1.3
	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 1.0))
	shrink.add_point(Vector2(0.8, 1.0))
	shrink.add_point(Vector2(1.0, 0.0))
	scale_amount_curve = shrink
	mesh = _piece()
	# Every piece stays within this box round the crossbar's middle.
	custom_aabb = AABB(Vector3(-12.0, -6.0, -14.0), Vector3(24.0, 16.0, 20.0))
	finished.connect(queue_free)


## The environment the burst is drawn through: the camera's own, else the world's.
func _environment() -> Environment:
	var camera := get_viewport().get_camera_3d() if get_viewport() != null else null
	if camera != null and camera.environment != null:
		return camera.environment
	return get_world_3d().environment if get_world_3d() != null else null


## The palette as a gradient of solid bands, each piece taking one colour, given
## as the colour that shows on screen through `environment`.
static func _palette(environment: Environment) -> Gradient:
	var palette := Gradient.new()
	palette.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var offsets := PackedFloat32Array()
	var colours := PackedColorArray()
	for index in COLOURS.size():
		offsets.append(float(index) / float(COLOURS.size()))
		colours.append(on_screen(COLOURS[index], environment))
	palette.offsets = offsets
	palette.colors = colours
	return palette


## The linear colour to give an unshaded piece so that it shows on screen as
## `colour` (sRGB) through the environment's exposure and tone map: each channel
## put back through the tone curve (Filmic's; Linear's for the others, which this
## game does not use).
static func on_screen(colour: Color, environment: Environment) -> Color:
	var exposure := 1.0 if environment == null else maxf(environment.tonemap_exposure, 0.001)
	var filmic := environment != null and environment.tonemap_mode == Environment.TONE_MAPPER_FILMIC
	var white := 1.0 if environment == null else maxf(environment.tonemap_white, 0.001)
	var linear := colour.srgb_to_linear()
	var given := Color(0.0, 0.0, 0.0, 1.0)
	for channel in 3:
		var value := clampf(linear[channel], 0.0, 1.0)
		given[channel] = (_unfilmic(value, white) if filmic else value) / exposure
	return given


## Godot's Filmic tone curve (its tonemap shader), before its division by the
## curve at white.
static func _filmic(x: float) -> float:
	const A := 0.88
	const B := 0.6
	const C := 0.1
	const D := 0.2
	const E := 0.01
	const F := 0.3
	return (x * (A * x + C * B) + D * E) / (x * (A * x + B) + D * F) - E / F


## The input that Filmic, with this white, turns into `value` (0 to 1).
static func _unfilmic(value: float, white: float) -> float:
	var target := value * _filmic(white)
	var low := 0.0
	var high := white
	for _step in 32:
		var middle := (low + high) * 0.5
		if _filmic(middle) < target:
			low = middle
		else:
			high = middle
	return (low + high) * 0.5


## One piece: a small upright card, in the colour its particle was given.
static func _piece() -> QuadMesh:
	if _mesh == null:
		var material := StandardMaterial3D.new()
		material.resource_name = "goal_confetti"
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.vertex_color_use_as_albedo = true
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		_mesh = QuadMesh.new()
		_mesh.size = PIECE_M
		_mesh.material = material
	return _mesh
