extends CPUParticles3D
## The burst of a goal (owner, 2026-11-11; soccer_ball.gd starts it): paper
## confetti in bright colours thrown up out of the goal's mouth, along its
## crossbar and out over the pitch, tumbling as it slows and drifts down, gone in
## under three seconds.
##
## One node per burst, freed when its last piece is gone. A CPUParticles3D is
## simulated on the CPU and drawn as one MultiMesh, so it looks the same in
## Forward+ and in Compatibility (the web build); its pieces are unshaded quads in
## the colours of the palette, with no texture and no transparency to sort. It
## pauses with the game, as the world it hangs under does.

## The confetti's colours, one per piece.
const COLOURS := [Color("ff3b30"), Color("ffcc00"), Color("34c759"), Color("0a84ff"), Color("ff2d92"), Color("ff9500"), Color("f2f2f2")]
const LIFETIME_S := 2.6
## Pieces per metre of the mouth's width, from MIN_PIECES to MAX_PIECES.
const PIECES_PER_M := 22.0
const MIN_PIECES := 50
const MAX_PIECES := 160
## A piece of paper, before its random scale (m).
const PIECE_M := Vector2(0.12, 0.17)

static var _mesh: QuadMesh
static var _palette: Gradient


## Starts the burst at a goal (once this node is in the tree): the goal's frame
## (origin on the middle of the goal line, -Z toward the pitch), its mouth's half
## width and its crossbar's height (m).
func start(goal: Transform3D, half_m: float, crossbar_m: float) -> void:
	amount = clampi(roundi(PIECES_PER_M * half_m * 2.0), MIN_PIECES, MAX_PIECES)
	emission_box_extents = Vector3(half_m, 0.1, 0.15)
	global_transform = Transform3D(goal.basis, goal * Vector3(0.0, crossbar_m, -0.2))
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
	spread = 38.0
	initial_velocity_min = 3.5
	initial_velocity_max = 8.0
	# Paper: drag takes most of its speed and gravity only a little of its fall.
	gravity = Vector3(0.0, -3.5, 0.0)
	damping_min = 2.0
	damping_max = 3.5
	angle_min = 0.0
	angle_max = 360.0
	angular_velocity_min = -540.0
	angular_velocity_max = 540.0
	scale_amount_min = 0.7
	scale_amount_max = 1.3
	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 1.0))
	shrink.add_point(Vector2(0.8, 1.0))
	shrink.add_point(Vector2(1.0, 0.0))
	scale_amount_curve = shrink
	color_initial_ramp = _colours()
	mesh = _piece()
	# Every piece stays within this box round the crossbar's middle.
	custom_aabb = AABB(Vector3(-12.0, -6.0, -14.0), Vector3(24.0, 16.0, 20.0))
	finished.connect(queue_free)


## The palette as a gradient of solid bands: each piece takes one colour.
static func _colours() -> Gradient:
	if _palette == null:
		_palette = Gradient.new()
		_palette.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
		var offsets := PackedFloat32Array()
		var colours := PackedColorArray()
		for index in COLOURS.size():
			offsets.append(float(index) / float(COLOURS.size()))
			colours.append(COLOURS[index])
		_palette.offsets = offsets
		_palette.colors = colours
	return _palette


## One piece: a small quad facing the camera, turning as it flies, in the colour
## its particle was given.
static func _piece() -> QuadMesh:
	if _mesh == null:
		var material := StandardMaterial3D.new()
		material.resource_name = "goal_confetti"
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.vertex_color_use_as_albedo = true
		material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
		material.billboard_keep_scale = true
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		_mesh = QuadMesh.new()
		_mesh.size = PIECE_M
		_mesh.material = material
	return _mesh
