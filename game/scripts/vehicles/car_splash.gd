extends Node3D
## A car meeting the bay (drivable_car.gd splashed): white spray thrown up
## from where it went in, a low cloud of foam settling round it and a ring of
## foam spreading on the surface, all fading; then it frees itself. Soft round
## and ring-shaped sprites (radial gradient textures, made once) on CPU
## particles and one flat quad, drawn alike by Forward+ and the web build's
## Compatibility renderer.

## Spray: sprites for a car's length, their launch speed (m/s) at rest and per
## m/s of the car's speed (capped), and their life (s).
const SPRAY := 90
const LAUNCH_MPS := 2.5
const LAUNCH_PER_MPS := 0.24
const LAUNCH_MAX_MPS := 9.5
const SPRAY_LIFE_S := 1.4
## Foam: a few broad sprites rolling out low over the water.
const FOAM := 14
const FOAM_LIFE_S := 1.6
## The ring: its starting and final radius as shares of the car's length, and
## its life (s).
const RING_FROM := 0.45
const RING_TO := 1.4
const RING_LIFE_S := 2.4
const RENDER_WORLD_VISIBLE := 1

static var _dot: GradientTexture2D
static var _ring_texture: GradientTexture2D

var _ring: MeshInstance3D
var _ring_material: StandardMaterial3D
var _age := 0.0
var _length := 4.5


## Starts the splash at a point on the water for a car of this length that
## went in at this speed (m/s).
func start(at: Vector3, speed: float, car_length_m: float) -> void:
	_length = car_length_m
	global_position = at + Vector3.UP * 0.03
	var launch := minf(LAUNCH_MAX_MPS, LAUNCH_MPS + LAUNCH_PER_MPS * speed)
	var spray := _particles("Spray", SPRAY, SPRAY_LIFE_S, 0.92, car_length_m * 0.3, 0.8)
	spray.direction = Vector3.UP
	spray.spread = 34.0
	spray.initial_velocity_min = launch * 0.5
	spray.initial_velocity_max = launch
	spray.gravity = Vector3(0.0, -9.8, 0.0)
	spray.damping_min = 0.6
	spray.damping_max = 1.6
	spray.scale_amount_min = 0.12
	spray.scale_amount_max = 0.4
	spray.scale_amount_curve = _curve(1.0, 0.45)
	add_child(spray)
	spray.emitting = true
	var foam := _particles("Foam", FOAM, FOAM_LIFE_S, 0.8, car_length_m * 0.3, 0.45)
	foam.direction = Vector3.UP
	foam.spread = 80.0
	foam.initial_velocity_min = 0.6
	foam.initial_velocity_max = 1.8
	foam.gravity = Vector3(0.0, -1.2, 0.0)
	foam.damping_min = 0.8
	foam.damping_max = 1.4
	foam.scale_amount_min = 0.8
	foam.scale_amount_max = 1.6
	foam.scale_amount_curve = _curve(0.7, 1.0)
	add_child(foam)
	foam.emitting = true
	var quad := PlaneMesh.new()
	quad.size = Vector2(2.0, 2.0)
	_ring_material = _sprite_material(_ring_sprite(), false)
	_ring_material.billboard_mode = BaseMaterial3D.BILLBOARD_DISABLED
	quad.material = _ring_material
	_ring = MeshInstance3D.new()
	_ring.name = "Foam ring"
	_ring.mesh = quad
	_ring.layers = RENDER_WORLD_VISIBLE
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ring)
	_age = 0.0
	_update_ring()


func _particles(node_name: String, amount: int, life: float, explosiveness: float, reach: float, alpha: float) -> CPUParticles3D:
	var particles := CPUParticles3D.new()
	particles.name = node_name
	particles.one_shot = true
	particles.explosiveness = explosiveness
	particles.amount = amount
	particles.lifetime = life
	particles.local_coords = false
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector3(reach, 0.05, reach)
	var fade := Gradient.new()
	fade.set_color(0, Color(1.0, 1.0, 1.0, alpha))
	fade.set_color(1, Color(0.9, 0.95, 1.0, 0.0))
	particles.color_ramp = fade
	var sprite := QuadMesh.new()
	sprite.size = Vector2(1.0, 1.0)
	sprite.material = _sprite_material(_dot_sprite(), true)
	particles.mesh = sprite
	particles.layers = RENDER_WORLD_VISIBLE
	particles.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return particles


static func _curve(from: float, to: float) -> Curve:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, from))
	curve.add_point(Vector2(1.0, to))
	return curve


## A soft white sprite facing the camera, its alpha from the texture (and the
## particle colour when vertex_alpha).
static func _sprite_material(texture: Texture2D, vertex_alpha: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = texture
	material.albedo_color = Color(0.96, 0.98, 1.0, 1.0)
	material.vertex_color_use_as_albedo = vertex_alpha
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	material.billboard_keep_scale = true
	return material


## A round white dot fading to nothing at its edge.
static func _dot_sprite() -> GradientTexture2D:
	if _dot == null:
		var gradient := Gradient.new()
		gradient.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
		gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
		gradient.add_point(0.45, Color(1.0, 1.0, 1.0, 0.75))
		_dot = _radial(gradient)
	return _dot


## A soft white ring: clear in the middle and beyond its edge.
static func _ring_sprite() -> GradientTexture2D:
	if _ring_texture == null:
		var gradient := Gradient.new()
		gradient.set_color(0, Color(1.0, 1.0, 1.0, 0.0))
		gradient.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
		gradient.add_point(0.55, Color(1.0, 1.0, 1.0, 0.08))
		gradient.add_point(0.8, Color(1.0, 1.0, 1.0, 0.7))
		gradient.add_point(0.92, Color(1.0, 1.0, 1.0, 0.25))
		_ring_texture = _radial(gradient)
	return _ring_texture


static func _radial(gradient: Gradient) -> GradientTexture2D:
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 64
	texture.height = 64
	return texture


func _process(delta: float) -> void:
	_age += delta
	if _ring != null:
		_update_ring()
	if _age > maxf(maxf(SPRAY_LIFE_S, FOAM_LIFE_S), RING_LIFE_S) + 0.2:
		queue_free()


func _update_ring() -> void:
	var t := clampf(_age / RING_LIFE_S, 0.0, 1.0)
	var eased := 1.0 - (1.0 - t) * (1.0 - t)
	var radius := _length * lerpf(RING_FROM, RING_TO, eased)
	_ring.scale = Vector3(radius, 1.0, radius)
	_ring_material.albedo_color.a = 0.55 * (1.0 - t)
