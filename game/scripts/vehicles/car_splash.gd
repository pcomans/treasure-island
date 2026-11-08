extends Node3D
## A car meeting the bay (drivable_car.gd splashed): a burst of white spray
## thrown up from where it went in and a ring of foam spreading on the surface,
## both fading; then it frees itself. CPU particles and one mesh, drawn alike by
## Forward+ and the web build's Compatibility renderer.

## Spray: droplets for a car's length, their launch speed (m/s) at rest and
## per m/s of the car's speed (capped), and their life (s).
const DROPS := 72
const LAUNCH_MPS := 2.5
const LAUNCH_PER_MPS := 0.22
const LAUNCH_MAX_MPS := 9.0
const DROP_LIFE_S := 1.3
## Foam: the ring's starting and final radius as shares of the car's length,
## its life (s).
const RING_FROM := 0.5
const RING_TO := 1.6
const RING_LIFE_S := 1.8
const RENDER_WORLD_VISIBLE := 1

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
	var drops := CPUParticles3D.new()
	drops.name = "Spray"
	drops.one_shot = true
	drops.explosiveness = 0.9
	drops.amount = DROPS
	drops.lifetime = DROP_LIFE_S
	drops.local_coords = false
	drops.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	drops.emission_box_extents = Vector3(car_length_m * 0.3, 0.05, car_length_m * 0.3)
	drops.direction = Vector3.UP
	drops.spread = 32.0
	drops.initial_velocity_min = launch * 0.55
	drops.initial_velocity_max = launch
	drops.gravity = Vector3(0.0, -9.8, 0.0)
	drops.damping_min = 0.4
	drops.damping_max = 1.2
	drops.scale_amount_min = 0.12
	drops.scale_amount_max = 0.34
	var shrink := Curve.new()
	shrink.add_point(Vector2(0.0, 1.0))
	shrink.add_point(Vector2(1.0, 0.35))
	drops.scale_amount_curve = shrink
	var fade := Gradient.new()
	fade.set_color(0, Color(1.0, 1.0, 1.0, 0.95))
	fade.set_color(1, Color(0.92, 0.96, 1.0, 0.0))
	drops.color_ramp = fade
	var droplet := SphereMesh.new()
	droplet.radius = 0.5
	droplet.height = 1.0
	droplet.radial_segments = 8
	droplet.rings = 4
	droplet.material = _white(true)
	drops.mesh = droplet
	drops.layers = RENDER_WORLD_VISIBLE
	drops.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(drops)
	drops.emitting = true
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.72
	ring_mesh.outer_radius = 1.0
	ring_mesh.rings = 32
	ring_mesh.ring_segments = 6
	_ring_material = _white(false)
	ring_mesh.material = _ring_material
	_ring = MeshInstance3D.new()
	_ring.name = "Foam"
	_ring.mesh = ring_mesh
	_ring.layers = RENDER_WORLD_VISIBLE
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ring)
	_age = 0.0
	_update_ring()


static func _white(vertex_alpha: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.95, 0.97, 1.0, 0.85)
	material.vertex_color_use_as_albedo = vertex_alpha
	return material


func _process(delta: float) -> void:
	_age += delta
	if _ring != null:
		_update_ring()
	if _age > maxf(DROP_LIFE_S, RING_LIFE_S) + 0.2:
		queue_free()


func _update_ring() -> void:
	var t := clampf(_age / RING_LIFE_S, 0.0, 1.0)
	var eased := 1.0 - (1.0 - t) * (1.0 - t)
	var radius := _length * lerpf(RING_FROM, RING_TO, eased)
	_ring.scale = Vector3(radius, 0.06, radius)
	_ring_material.albedo_color.a = 0.8 * (1.0 - t)
