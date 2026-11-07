class_name LandingPoof
extends CPUParticles3D
## The little dust poof of a fast-drop landing. When the player character comes
## down on the fast drop (C) and touches ground, ChestAvatar calls burst() at the
## drawn ground under it: a short burst of soft dust spreads low and outward round
## the feet (the slow puffs stay by them, the fast ones roll out about a metre),
## rises a little and thins out, gone in about two thirds of a second. Visual
## only; it has no collision and reads nothing back.
##
## One reusable emitter: a CPUParticles3D is simulated on the CPU and drawn as
## one MultiMesh, so it behaves the same in Forward+ and in Compatibility (the
## web build), and costs nothing between landings. It is top level and its
## particles live in world space, so the dust stays where it was kicked up when
## the player runs on. Its puffs are drawn by landing_dust.gdshader, lit as thin
## dust in the scene's own light (backlit dust glows), in the colour of the ground
## landed on, paler and greyer: it reads the grass's ground captures
## (ground_dressing.gd) where they are drawn, and keeps a light dusty neutral where
## they aren't (the web). A CPUParticles3D draws nothing while idle, so its shader
## would compile at the first landing; warm_up() draws one burst that shows nothing
## at start-up instead.

signal poofed(at: Vector3)

## Whether the last burst had the ground captures to take its colour from.
var ground_offered := false
var _material: ShaderMaterial

const SHADER := preload("res://game/resources/player/landing_dust.gdshader")
const AMOUNT := 28
const LIFETIME_S := 0.65
## The puffs start on a ring of this radius round the feet, LIFT_M above the
## drawn ground, and leave it outward, tilted up by TILT_DEG.
const RING_RADIUS_M := 0.18
const RING_POINTS := 12
const LIFT_M := 0.02
const TILT_DEG := 14.0
## A puff is a quad this many metres wide at full size, its centre this share of
## its size above its pivot, so the pivot is at the bottom of the drawn blob.
const PUFF_SIZE_M := 1.0
const PUFF_PIVOT := 0.28


func _init() -> void:
	top_level = true
	emitting = false
	one_shot = true
	amount = AMOUNT
	lifetime = LIFETIME_S
	lifetime_randomness = 0.3
	explosiveness = 1.0
	local_coords = false
	draw_order = CPUParticles3D.DRAW_ORDER_VIEW_DEPTH
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Every puff stays within this box round the landing spot.
	custom_aabb = AABB(Vector3(-1.8, -0.3, -1.8), Vector3(3.6, 1.8, 3.6))
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * PUFF_SIZE_M
	quad.center_offset = Vector3(0.0, PUFF_PIVOT * PUFF_SIZE_M, 0.0)
	_material = ShaderMaterial.new()
	_material.resource_name = "landing_dust"
	_material.shader = SHADER
	quad.material = _material
	mesh = quad
	# The ring: each puff starts at one of these points and leaves along its normal.
	emission_shape = CPUParticles3D.EMISSION_SHAPE_DIRECTED_POINTS
	var points := PackedVector3Array()
	var normals := PackedVector3Array()
	var tilt := deg_to_rad(TILT_DEG)
	for i in RING_POINTS:
		var angle := TAU * (float(i) + 0.5) / float(RING_POINTS)
		var outward := Vector3(cos(angle), 0.0, sin(angle))
		points.append(outward * RING_RADIUS_M)
		normals.append(outward * cos(tilt) + Vector3.UP * sin(tilt))
	emission_points = points
	emission_normals = normals
	direction = Vector3(0.0, 0.0, 1.0)
	spread = 18.0
	# Dust drags to a stop within its life (a puff at 3.6 m/s goes about a metre,
	# one at 0.8 m/s a few centimetres) and drifts up a little.
	initial_velocity_min = 0.8
	initial_velocity_max = 3.6
	damping_min = 5.0
	damping_max = 7.0
	gravity = Vector3(0.0, 0.6, 0.0)
	angle_min = 0.0
	angle_max = 360.0
	angular_velocity_min = -40.0
	angular_velocity_max = 40.0
	scale_amount_min = 0.5
	scale_amount_max = 0.9
	var growth := Curve.new()
	growth.add_point(Vector2(0.0, 0.35), 0.0, 1.6)
	growth.add_point(Vector2(1.0, 1.0), 0.2, 0.0)
	scale_amount_curve = growth
	var fade := Gradient.new()
	fade.offsets = PackedFloat32Array([0.0, 0.07, 0.5, 1.0])
	fade.colors = PackedColorArray([Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.72), Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.0)])
	color_ramp = fade


## Kicks up the dust at `at`, a point on the drawn ground, and reports it. capture is
## GroundDressing.ground_capture(), or {} where there is none: the dust then keeps
## its own colour.
func burst(at: Vector3, capture: Dictionary = {}) -> void:
	ground_offered = not capture.is_empty()
	_material.set_shader_parameter("ground_capture", ground_offered)
	if ground_offered:
		_material.set_shader_parameter("ground_colour", capture.colour)
		_material.set_shader_parameter("ground_surface", capture.surface)
		_material.set_shader_parameter("ground_window", capture.window)
	_material.set_shader_parameter("landing_xz", Vector2(at.x, at.z))
	_material.set_shader_parameter("strength", 1.0)
	global_position = at + Vector3.UP * LIFT_M
	restart()
	poofed.emit(at)


## Draws one burst at `at` that shows nothing, so the dust's shader compiles now
## (behind the start-up screen) rather than at the first landing. Not a poof.
func warm_up(at: Vector3) -> void:
	_material.set_shader_parameter("strength", 0.0)
	global_position = at
	restart()
