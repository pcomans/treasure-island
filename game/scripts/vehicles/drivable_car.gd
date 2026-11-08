class_name DrivableCar
extends RigidBody3D
## A street-clutter parked car set moving: the one the player drives, or one a
## driven car shoved (game/scripts/vehicles/vehicle_manager.gd swaps it in for
## its static row). An arcade car on raycast suspension, a real rigid body: it
## goes airborne, lands, bounces, leans in corners and can flip and roll in
## crashes, off a ramp taken askew, in hard turns and when a kerb or an obstacle
## trips it sideways (owner, 2026-11-08: "flipping cars in games is fun").
##
## Each physics tick four rays, one per wheel, find the ground under the kit's
## wheel centres (street_clutter_kit.gd drivable(); the drawn ground's lift over
## the land collision is added, as for the player character's feet). A spring
## and damper per wheel hold the body up, sized so it rests at the parked car's
## height; tyre forces at each contact cancel side slip and drive or brake along
## the wheel, held to a friction circle. The handbrake lets the rear slide. A
## mild yaw assist steadies ordinary driving, a mild anti-roll bar keeps gentle
## cornering flat; nothing levels the car in the air, so it lands however it was
## flying. A car resting on its roof or side, nearly still, for RIGHT_AFTER_S
## rights itself with a short pop and roll.
##
## The body is on the street-prop layer, like the parked cars: the player and
## other cars collide with it, the spray ray stops on it and the camera arms
## ignore it. Its visual is a top-level node moved each frame between the last
## two physics states (Engine.get_physics_interpolation_fraction), so it stays
## smooth when the frame rate and the 60 Hz physics differ (the web build).
##
## Handling numbers are production inference for arcade feel, not measured.

signal recovered(cause: String, from_position: Vector3)
signal righted

const KIT := preload("res://game/scripts/world/street_clutter_kit.gd")

const PHYSICS_WORLD_SOLID := 1
const PHYSICS_SPRAY_SURFACE := 1 << 2
const PHYSICS_STREET_PROP := 1 << 3
const RENDER_WORLD_VISIBLE := 1

## Per body: mass (kg), top speed (m/s), launch acceleration (m/s^2), and the
## collision outline from the kit's body profiles (tools/lib/street-clutter-kit.mjs
## CAR_BODIES): the belt (hood) height, the rear deck height, the cabin's
## windshield base and top, roof end and rear glass base (m from the front
## bumper) and its roof height.
const BODIES := {
	"crossover": {"mass": 1750.0, "top": 37.0, "accel": 8.5, "belt": 1.04, "deck": 1.06, "cabin": [1.35, 2.18, 4.25, 4.58], "roof": 1.66},
	"suv": {"mass": 2050.0, "top": 35.0, "accel": 8.0, "belt": 1.1, "deck": 1.11, "cabin": [1.42, 2.25, 4.7, 4.94], "roof": 1.76},
	"sedan": {"mass": 1550.0, "top": 40.0, "accel": 9.0, "belt": 0.93, "deck": 1.03, "cabin": [1.42, 2.3, 3.35, 3.98], "roof": 1.44},
	"fastback": {"mass": 1800.0, "top": 42.0, "accel": 10.0, "belt": 0.89, "deck": 1.02, "cabin": [1.22, 2.15, 3.3, 4.3], "roof": 1.43},
	"hatchback": {"mass": 1350.0, "top": 38.0, "accel": 9.0, "belt": 0.94, "deck": 1.0, "cabin": [1.36, 2.2, 3.62, 4.32], "roof": 1.46},
	"wagon": {"mass": 1600.0, "top": 38.0, "accel": 8.5, "belt": 0.99, "deck": 1.02, "cabin": [1.5, 2.36, 4.5, 4.82], "roof": 1.58},
	"pickup": {"mass": 2300.0, "top": 34.0, "accel": 7.5, "belt": 1.25, "deck": 1.21, "cabin": [1.75, 2.38, 3.7, 3.8], "roof": 1.95},
	"utility": {"mass": 2600.0, "top": 31.0, "accel": 6.5, "belt": 1.25, "deck": 1.5, "cabin": [1.75, 2.38, 3.7, 3.8], "roof": 1.95},
	"van": {"mass": 2500.0, "top": 30.0, "accel": 6.5, "belt": 1.26, "deck": 1.26, "cabin": [0.98, 1.82, 5.82, 5.9], "roof": 2.62},
}
const REVERSE_TOP_MPS := 10.0
const REVERSE_ACCEL_MPS2 := 6.0
const BRAKE_MPS2 := 14.0
## Rolling resistance and engine braking with no throttle (m/s^2), air drag
## (m/s^2 per (m/s)^2) and downforce on the wheels (the same, along the car's
## down): arcade-strong, so a fast car keeps its wheels on the terrain's gentle
## crests instead of floating over them; in the air there is none.
const COAST_MPS2 := 0.6
const DRAG := 0.00035
const DOWNFORCE := 0.004
## Suspension: ride frequency (Hz), damping ratios (bump, rebound), the travel
## above the rest position (m); the droop below it is the static deflection at
## that frequency, so the wheels sit at the kit's wheel centres at rest.
const RIDE_HZ := 1.35
const DAMPING_BUMP := 0.45
const DAMPING_REBOUND := 0.6
const TRAVEL_BUMP_M := 0.12
## Anti-roll per axle as a share of the wheel rate: mild, so gentle cornering
## stays flat and reckless driving still tips a car.
const ANTI_ROLL := 0.3
## Centre of mass height as a share of the body height: low-ish but real, so
## the tall bodies (vans, pickups) roll more readily than the low ones.
const COM_SHARE := 0.32
## Tyres: friction coefficients, the side slip a tyre cancels per second (as a
## share of its quarter of the car's mass) and the handbrake's rear grip share.
const GRIP_FRONT := 1.35
const GRIP_REAR := 1.25
const LATERAL_STIFFNESS := 16.0
const HANDBRAKE_GRIP := 0.3
## A car nobody drives (left parked, or shoved) brakes gently and its tyres
## scrub at this share of their grip, so a driven car can push it about.
const UNOCCUPIED_GRIP := 0.5
const UNOCCUPIED_BRAKE_MPS2 := 5.0
## Steering: full lock at rest and at STEER_FULL_SPEED_MPS, and how fast the
## wheels turn in (at rest and at that speed: keys are all or nothing, so the
## wheels turn in gently at speed) and back (rad/s).
const STEER_MAX := deg_to_rad(32.0)
const STEER_MIN := deg_to_rad(7.0)
const STEER_FULL_SPEED_MPS := 35.0
const STEER_RATE_IN := 3.5
const STEER_RATE_IN_FAST := 1.0
const STEER_RATE_OUT := 5.0
## Mild yaw assist: excess yaw rate beyond what the steering asks is damped at
## this rate (1/s) while the car is on its wheels and the handbrake is off.
const YAW_ASSIST := 1.6
## Self-righting: on its roof or side (its up within this of horizontal), nearly
## still, for this long; then a pop and roll of this length and height.
const RIGHT_UP_DOT := 0.5
const RIGHT_AFTER_S := 3.0
const RIGHT_STILL_MPS := 1.0
const RIGHT_STILL_RADPS := 1.0
const RIGHT_DURATION_S := 0.6
const RIGHT_POP_M := 1.1
## A car left alone (no driver) and at rest this long freezes: a static body
## where it stopped, for the rest of the session, until someone drives it.
const PARK_AFTER_S := 0.75
const PARK_SPEED_MPS := 0.15
## Recovery off the island (owner: a car driven into the bay comes back on land
## with the player): safe samples on the island, every SAFE_EVERY_S; the reset
## takes the newest at least SAFE_AGE_S old.
const SAFE_EVERY_S := 0.25
const SAFE_AGE_S := 2.0
const SAFE_SAMPLES := 64
const OUTSIDE_RESET_S := 0.6
const FALL_RECOVERY_Y := -20.0
const WATER_MARGIN_M := 0.3
## The detail hand-over and draw range, as the parked cars' (street_clutter_kit.gd).
const LOD_NEAR_M := KIT.LOD_NEAR_M
const FAR_RANGE_M := 260.0
## The driver's seat in the car frame: where the player rides, for the systems
## that follow the player (the grass round the player, the web state).
const SEAT := Vector3(-0.38, 0.55, -0.15)

var row_id := ""
var body := ""
## Driver input, set each tick by the vehicle manager: drive -1..1 (S..W),
## steer -1..1 (A..D, positive right), handbrake.
var drive_input := 0.0
var steer_input := 0.0
var handbrake := false
var occupied := false
## The playable outline and the drawn ground (set by the vehicle manager).
var boundary: WorldBoundary
var visible_ground: VisibleGround
var water_y := -0.12

var length_m := 4.5
var width_m := 1.8
var height_m := 1.5
var wheel_radius := 0.34
var wheelbase := 2.8
var _wheel_rest: Array[Vector3] = []
var _droop := 0.1
var _rate := 0.0
var _damp_bump := 0.0
var _damp_rebound := 0.0
var _top := 38.0
var _accel := 9.0
var _ray := PhysicsRayQueryParameters3D.new()
var _compression := PackedFloat32Array([0.0, 0.0, 0.0, 0.0])
var _contact := [false, false, false, false]
var _spin := PackedFloat32Array([0.0, 0.0, 0.0, 0.0])
var _steer := 0.0
var _grounded := 0
var _upright_wait := 0.0
var _righting := -1.0
var _right_from := Transform3D.IDENTITY
var _right_to := Transform3D.IDENTITY
var _park_wait := 0.0
var _safe: Array[Dictionary] = []
var _safe_clock := 0.0
var _outside_s := 0.0
var _clock := 0.0
var _recover_request := ""
var _teleport := Transform3D.IDENTITY
var _teleport_pending := false

var _prev := Transform3D.IDENTITY
var _curr := Transform3D.IDENTITY
var _visual: Node3D
var _wheels: MultiMesh
var _air_spin_damp := 0.6


## Builds the car for a kit body (KIT.drivable(body)) in its paint and puts it
## at placement; excludes are bodies its wheels and its own queries skip (the
## fences it drives through and their debris).
func setup(car_body: String, parts: Dictionary, material: Material, custom: Color, placement: Transform3D, excludes: Array[RID]) -> void:
	body = car_body
	var spec: Dictionary = BODIES[car_body]
	var front: Vector3 = parts.front
	var rear: Vector3 = parts.rear
	wheel_radius = float(parts.radius)
	wheelbase = rear.z - front.z
	var chassis_box: AABB = (parts.chassis as Mesh).get_aabb()
	length_m = chassis_box.size.z
	width_m = 2.0 * (front.x + float(parts.tyre_width) * 0.5 + 0.035)
	height_m = maxf(float(spec.roof), chassis_box.end.y)
	_wheel_rest = [Vector3(-front.x, front.y, front.z), front, Vector3(-rear.x, rear.y, rear.z), rear]
	mass = float(spec.mass)
	_top = float(spec.top)
	_accel = float(spec.accel)
	var omega := TAU * RIDE_HZ
	_rate = mass * 0.25 * omega * omega
	_droop = _gravity() / (omega * omega)
	_damp_bump = 2.0 * DAMPING_BUMP * sqrt(_rate * mass * 0.25)
	_damp_rebound = 2.0 * DAMPING_REBOUND * sqrt(_rate * mass * 0.25)
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = Vector3(0.0, height_m * COM_SHARE, (front.z + rear.z) * 0.5)
	# A box's principal moments over the body's own size.
	inertia = Vector3(
		mass / 12.0 * (height_m * height_m + length_m * length_m),
		mass / 12.0 * (width_m * width_m + length_m * length_m),
		mass / 12.0 * (width_m * width_m + height_m * height_m))
	collision_layer = PHYSICS_STREET_PROP | PHYSICS_SPRAY_SURFACE
	collision_mask = PHYSICS_WORLD_SOLID | PHYSICS_STREET_PROP
	continuous_cd = true
	can_sleep = false
	var surface := PhysicsMaterial.new()
	surface.friction = 0.4
	surface.bounce = 0.25
	physics_material_override = surface
	set_meta("feature_kind", "drivable_car")
	set_meta("receiver_kind", "none")
	set_meta("opaque", true)
	set_meta("street_detail_id", row_id)
	for hull: PackedVector3Array in _hulls(spec):
		var shape := ConvexPolygonShape3D.new()
		shape.points = hull
		var collision := CollisionShape3D.new()
		collision.shape = shape
		add_child(collision)
	_ray.collision_mask = PHYSICS_WORLD_SOLID | PHYSICS_STREET_PROP
	_ray.hit_back_faces = false
	_ray.collide_with_areas = false
	set_excludes(excludes)
	_build_visual(parts, material, custom)
	transform = placement
	_prev = placement
	_curr = placement
	_safe = [{"transform": placement, "time": -INF}]
	for i in 4:
		_compression[i] = _droop


## The bodies the wheels and the car's queries skip, besides itself.
func set_excludes(excludes: Array[RID]) -> void:
	var list: Array[RID] = [get_rid()]
	list.append_array(excludes)
	_ray.exclude = list


func _gravity() -> float:
	return float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))


## Two convex hulls in the car frame (front -Z): the lower body, its nose and
## tail raked up so kerbs and ramp toes don't snag, and the cabin.
func _hulls(spec: Dictionary) -> Array[PackedVector3Array]:
	var half_l := length_m * 0.5
	var hw := width_m * 0.49
	var bottom := maxf(0.14, wheel_radius * 0.6)
	var belt := float(spec.belt)
	var deck := float(spec.deck)
	var lower := PackedVector3Array()
	for sx: float in [-1.0, 1.0]:
		lower.append(Vector3(sx * hw, bottom, -half_l + 0.42))
		lower.append(Vector3(sx * hw, bottom, half_l - 0.36))
		lower.append(Vector3(sx * hw, bottom + 0.17, -half_l))
		lower.append(Vector3(sx * hw, bottom + 0.17, half_l))
		lower.append(Vector3(sx * hw * 0.97, belt, -half_l + 0.06))
		lower.append(Vector3(sx * hw * 0.97, deck, half_l - 0.04))
	var cab: Array = spec.cabin
	var cabin := PackedVector3Array()
	for sx: float in [-1.0, 1.0]:
		cabin.append(Vector3(sx * hw * 0.9, belt - 0.02, -half_l + float(cab[0])))
		cabin.append(Vector3(sx * hw * 0.9, deck - 0.02, -half_l + float(cab[3])))
		cabin.append(Vector3(sx * hw * 0.78, float(spec.roof), -half_l + float(cab[1])))
		cabin.append(Vector3(sx * hw * 0.78, float(spec.roof), -half_l + float(cab[2])))
	return [lower, cabin]


func _build_visual(parts: Dictionary, material: Material, custom: Color) -> void:
	_visual = Node3D.new()
	_visual.name = "Visual"
	_visual.top_level = true
	add_child(_visual)
	var bounds := AABB(Vector3(-width_m, -0.5, -length_m), Vector3(width_m * 2.0, height_m + 1.5, length_m * 2.0))
	_visual.add_child(_instance("Chassis", parts.chassis, 1, custom, material, bounds, 0.0, LOD_NEAR_M))
	var wheels := _instance("Wheels", parts.tyre, 4, custom, material, bounds, 0.0, LOD_NEAR_M)
	_wheels = wheels.multimesh
	_visual.add_child(wheels)
	_visual.add_child(_instance("Far", parts.far, 1, custom, material, bounds, LOD_NEAR_M, FAR_RANGE_M))
	_update_wheels()


static func _instance(node_name: String, mesh: Mesh, count: int, custom: Color, material: Material, bounds: AABB, begin_m: float, end_m: float) -> MultiMeshInstance3D:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.mesh = mesh
	multimesh.instance_count = count
	for index in count:
		multimesh.set_instance_transform(index, Transform3D.IDENTITY)
		multimesh.set_instance_custom_data(index, custom)
	multimesh.custom_aabb = bounds
	var instance := MultiMeshInstance3D.new()
	instance.name = node_name
	instance.multimesh = multimesh
	instance.material_override = material
	instance.layers = RENDER_WORLD_VISIBLE
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	instance.visibility_range_begin = begin_m
	instance.visibility_range_end = end_m
	instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
	return instance


# --- State for the manager, tests and captures.

func speed() -> float:
	return linear_velocity.length()


func forward_speed() -> float:
	return linear_velocity.dot(-global_transform.basis.z)


func grounded_wheels() -> int:
	return _grounded


func up_dot() -> float:
	return global_transform.basis.y.dot(Vector3.UP)


func is_righting() -> bool:
	return _righting >= 0.0


## The car's frame as drawn this frame (between the last two physics states).
func visual_transform() -> Transform3D:
	return _visual.global_transform if _visual != null else global_transform


func seat_transform() -> Transform3D:
	return Transform3D(Basis.IDENTITY, global_transform * SEAT)


func describe() -> Dictionary:
	var basis := global_transform.basis
	return {
		"speed": snappedf(speed(), 0.01), "forward": snappedf(forward_speed(), 0.01), "wheels": _grounded,
		"up": snappedf(up_dot(), 0.001), "pitch": snappedf(rad_to_deg(asin(clampf(-basis.z.y, -1.0, 1.0))), 0.1),
		"roll": snappedf(rad_to_deg(asin(clampf(basis.x.y, -1.0, 1.0))), 0.1), "steer": snappedf(rad_to_deg(_steer), 0.1),
		"compression": [snappedf(_compression[0], 0.001), snappedf(_compression[1], 0.001), snappedf(_compression[2], 0.001), snappedf(_compression[3], 0.001)],
		"occupied": occupied, "righting": is_righting(), "frozen": freeze,
	}


## Asks for the off-island reset at the next physics tick ("manual" for R).
func request_recover(cause: String = "manual") -> void:
	_recover_request = cause


## Puts the car down at a new place with no motion (used by tests).
func place(at: Transform3D) -> void:
	_teleport = at
	_teleport_pending = true
	freeze = false


# --- Physics.

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var dt := state.step
	_clock += dt
	if _teleport_pending:
		_teleport_pending = false
		_set_state(state, _teleport, Vector3.ZERO)
		return
	if _righting >= 0.0:
		_step_righting(state, dt)
		return
	var xf := state.transform
	var basis := xf.basis
	var up := basis.y
	var origin := xf.origin
	var space := state.get_space_state()
	var velocity := state.linear_velocity
	var forward := -basis.z
	var forward_speed_now := velocity.dot(forward)
	# Steering eases toward the input's angle, less lock the faster the car goes.
	var pace := clampf(absf(forward_speed_now) / STEER_FULL_SPEED_MPS, 0.0, 1.0)
	var lock := lerpf(STEER_MAX, STEER_MIN, pace)
	var target := -steer_input * lock if occupied else 0.0
	var turning_in := absf(target) > absf(_steer) and (signf(target) == signf(_steer) or _steer == 0.0)
	var rate := lerpf(STEER_RATE_IN, STEER_RATE_IN_FAST, pace) if turning_in else STEER_RATE_OUT
	_steer = move_toward(_steer, target, rate * dt)
	# Throttle, brake or reverse from W/S, as most driving games do.
	var throttle := 0.0
	var braking := not occupied
	if occupied:
		if drive_input > 0.1:
			if forward_speed_now < -1.0:
				braking = true
			else:
				throttle = drive_input
		elif drive_input < -0.1:
			if forward_speed_now > 1.0:
				braking = true
			else:
				throttle = drive_input
	var hand := handbrake or not occupied
	# Pass 1: each wheel's ray, compression and contact.
	var travel := TRAVEL_BUMP_M + _droop
	var reach := travel + wheel_radius
	var hits: Array = [null, null, null, null]
	_grounded = 0
	for i in 4:
		var mount := xf * (_wheel_rest[i] + Vector3.UP * TRAVEL_BUMP_M)
		_ray.from = mount
		_ray.to = mount - up * reach
		var hit := space.intersect_ray(_ray)
		if hit.is_empty():
			_compression[i] = 0.0
			_contact[i] = false
			continue
		var point: Vector3 = hit.position
		var lift := _lift(hit, point)
		var distance := (mount - point).dot(up) - lift
		_compression[i] = clampf(reach - distance, 0.0, travel + 0.08)
		_contact[i] = true
		hits[i] = {"point": point + up * lift, "normal": hit.normal}
		_grounded += 1
	# Pass 2: suspension, anti-roll and tyre forces; each wheel on the ground
	# drives its quarter (a wheel in the air drives nothing).
	var load_sum := 0.0
	var driven := 4
	for i in 4:
		if hits[i] == null:
			continue
		var front := i < 2
		var x := _compression[i]
		# The compression's rate from the body's own motion at the wheel, so a
		# wheel touching down again doesn't read a jump as a speed.
		var mount_velocity := state.get_velocity_at_local_position(xf * _wheel_rest[i] - origin)
		var speed_x := -mount_velocity.dot(up)
		var force := _rate * x + (_damp_bump if speed_x > 0.0 else _damp_rebound) * speed_x
		# Bump stop: the last 15 % of the travel stiffens sharply.
		var stop := x - travel * 0.85
		if stop > 0.0:
			force += _rate * 8.0 * stop + _damp_bump * 2.0 * maxf(speed_x, 0.0)
		# Anti-roll: the more compressed side of an axle pushes up harder.
		var pair := i ^ 1
		force += ANTI_ROLL * _rate * (x - _compression[pair]) * (1.0 if _contact[pair] else 0.0)
		force = clampf(force, 0.0, mass * 12.0 * _gravity())
		var contact: Vector3 = hits[i].point
		var normal: Vector3 = (hits[i].normal as Vector3).normalized()
		state.apply_force(up * force, contact - origin)
		load_sum += force
		# The tyre frame on the ground: forward along the steered wheel.
		var heading := forward.rotated(up, _steer) if front else forward
		var along := (heading - normal * heading.dot(normal)).normalized()
		var side := along.cross(normal)
		var contact_velocity := state.get_velocity_at_local_position(contact - origin)
		var v_long := contact_velocity.dot(along)
		var v_lat := contact_velocity.dot(side)
		var quarter := mass * 0.25
		var grip := (GRIP_FRONT if front else GRIP_REAR) * (1.0 if occupied else UNOCCUPIED_GRIP)
		var locked := false
		if hand and not front:
			grip *= HANDBRAKE_GRIP
			locked = true
		var lateral := -v_lat * LATERAL_STIFFNESS * quarter
		var longitudinal := 0.0
		if throttle > 0.0 and not (locked and occupied):
			var share := maxf(0.0, 1.0 - pow(maxf(forward_speed_now, 0.0) / _top, 2.0))
			longitudinal += throttle * mass * _accel * share / float(driven)
		elif throttle < 0.0:
			var share_back := maxf(0.0, 1.0 - pow(maxf(-forward_speed_now, 0.0) / REVERSE_TOP_MPS, 2.0))
			longitudinal += throttle * mass * REVERSE_ACCEL_MPS2 * share_back / float(driven)
		var stopping := 0.0
		if not occupied:
			stopping = UNOCCUPIED_BRAKE_MPS2 * quarter
		elif braking or locked:
			stopping = BRAKE_MPS2 * quarter
		elif is_zero_approx(throttle):
			stopping = COAST_MPS2 * quarter
		if stopping > 0.0:
			# Never more than stops the wheel's share this tick, so it can't reverse it.
			longitudinal -= signf(v_long) * minf(stopping, absf(v_long) * quarter / dt)
		var tyre := Vector2(lateral, longitudinal)
		var limit := grip * force
		if tyre.length() > limit:
			tyre *= limit / maxf(tyre.length(), 0.001)
		state.apply_force(side * tyre.x + along * tyre.y, contact - origin)
		_spin[i] = 0.0 if locked else _spin[i] - v_long / wheel_radius * dt
	for i in 4:
		if hits[i] == null:
			_spin[i] -= forward_speed_now / wheel_radius * dt * _air_spin_damp
	# Air drag, and a little downforce on the wheels.
	var speed_now := velocity.length()
	if speed_now > 0.1:
		state.apply_central_force(-velocity * speed_now * DRAG * mass)
	if _grounded >= 2:
		state.apply_central_force(-up * DOWNFORCE * forward_speed_now * forward_speed_now * mass)
	# Mild yaw assist on the wheels: damp the yaw beyond what the steering asks.
	if _grounded >= 3 and not hand and occupied:
		var wanted := forward_speed_now * tan(_steer) / maxf(wheelbase, 1.0)
		var yaw_rate := state.angular_velocity.dot(up)
		var excess := yaw_rate - wanted
		if signf(excess) == signf(yaw_rate) and absf(yaw_rate) > absf(wanted):
			state.apply_torque(-up * excess * YAW_ASSIST * inertia.y)
	_watch_upright(state, dt)
	_watch_recovery(state, dt)


## The drawn ground's lift where a wheel meets the land (VisibleGround).
func _lift(hit: Dictionary, point: Vector3) -> float:
	if visible_ground == null:
		return 0.0
	var collider := hit.get("collider") as Node
	if collider == null or collider.get_parent() == null or str(collider.get_parent().get_meta("feature_kind", "")) != "land_ground":
		return 0.0
	return visible_ground.lift_at(point.x, point.z)


## On its roof or side and nearly still for RIGHT_AFTER_S: start righting.
func _watch_upright(state: PhysicsDirectBodyState3D, dt: float) -> void:
	var up := state.transform.basis.y
	if up.dot(Vector3.UP) < RIGHT_UP_DOT and state.linear_velocity.length() < RIGHT_STILL_MPS and state.angular_velocity.length() < RIGHT_STILL_RADPS:
		_upright_wait += dt
	else:
		_upright_wait = 0.0
	if _upright_wait < RIGHT_AFTER_S:
		return
	_upright_wait = 0.0
	var xf := state.transform
	_right_from = xf
	_right_to = Transform3D(_upright_basis(xf.basis), xf.origin + Vector3.UP * 0.25)
	_righting = 0.0


## Upright, keeping the car's heading (or its side's, if it stands on its nose).
static func _upright_basis(basis: Basis) -> Basis:
	var forward := -basis.z
	forward.y = 0.0
	if forward.length() < 0.2:
		forward = Vector3.UP.cross(basis.x)
		forward.y = 0.0
	if forward.length() < 0.01:
		forward = Vector3.FORWARD
	forward = forward.normalized()
	return Basis(forward.cross(Vector3.UP).normalized(), Vector3.UP, -forward).orthonormalized()


## The pop and roll: up and over in RIGHT_DURATION_S, then back to physics.
func _step_righting(state: PhysicsDirectBodyState3D, dt: float) -> void:
	_righting += dt / RIGHT_DURATION_S
	var t := clampf(_righting, 0.0, 1.0)
	var eased := t * t * (3.0 - 2.0 * t)
	var rotation_now := Quaternion(_right_from.basis.orthonormalized()).slerp(Quaternion(_right_to.basis), eased)
	var origin := _right_from.origin.lerp(_right_to.origin, eased) + Vector3.UP * RIGHT_POP_M * 4.0 * t * (1.0 - t)
	var xf := Transform3D(Basis(rotation_now), origin)
	if t >= 1.0:
		_righting = -1.0
		_set_state(state, xf, Vector3.DOWN * 0.5)
		righted.emit.call_deferred()
		return
	state.transform = xf
	state.linear_velocity = Vector3.ZERO
	state.angular_velocity = Vector3.ZERO


func _set_state(state: PhysicsDirectBodyState3D, xf: Transform3D, velocity: Vector3) -> void:
	state.transform = xf
	state.linear_velocity = velocity
	state.angular_velocity = Vector3.ZERO
	_prev = xf
	_curr = xf
	for i in 4:
		_compression[i] = _droop


## Off the island (outside the playable outline and down in the water, or
## outside for a moment, or fallen far), or R: back to a safe spot on land.
func _watch_recovery(state: PhysicsDirectBodyState3D, dt: float) -> void:
	if boundary == null:
		return
	var origin := state.transform.origin
	var inside := boundary.contains_position(origin)
	_outside_s = 0.0 if inside else _outside_s + dt
	_safe_clock += dt
	if inside and _grounded >= 3 and state.transform.basis.y.dot(Vector3.UP) > 0.9 and state.angular_velocity.length() < 1.5 and _safe_clock >= SAFE_EVERY_S:
		_safe_clock = 0.0
		_safe.append({"transform": state.transform, "time": _clock})
		if _safe.size() > SAFE_SAMPLES:
			_safe.pop_front()
	var cause := _recover_request
	_recover_request = ""
	if cause == "":
		if origin.y < FALL_RECOVERY_Y:
			cause = "fell_below_world"
		elif not inside and (origin.y < water_y + WATER_MARGIN_M or _outside_s > OUTSIDE_RESET_S):
			cause = "outside_boundary"
	if cause == "":
		return
	var target: Transform3D = _safe[0].transform
	for index in range(_safe.size() - 1, -1, -1):
		if _clock - float(_safe[index].time) >= SAFE_AGE_S:
			target = _safe[index].transform
			break
	target = Transform3D(_upright_basis(target.basis), target.origin + Vector3.UP * 0.15)
	# Facing the water it came off, turn it round.
	var ahead := target.origin - target.basis.z * 8.0
	if not boundary.contains_position(ahead):
		target.basis = Basis(Vector3.UP, PI) * target.basis
	_outside_s = 0.0
	_upright_wait = 0.0
	_righting = -1.0
	var from := origin
	_set_state(state, target, Vector3.ZERO)
	recovered.emit.call_deferred(cause, from)


func _physics_process(delta: float) -> void:
	_prev = _curr
	_curr = global_transform
	if freeze:
		return
	# A car nobody drives freezes once it has come to rest: it stays there.
	if not occupied and _righting < 0.0 and linear_velocity.length() < PARK_SPEED_MPS and angular_velocity.length() < PARK_SPEED_MPS and up_dot() > RIGHT_UP_DOT:
		_park_wait += delta
		if _park_wait >= PARK_AFTER_S:
			_park_wait = 0.0
			freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
			freeze = true
	else:
		_park_wait = 0.0


func _process(_delta: float) -> void:
	if _visual == null:
		return
	if freeze:
		_visual.global_transform = global_transform
	else:
		_visual.global_transform = _prev.interpolate_with(_curr, clampf(Engine.get_physics_interpolation_fraction(), 0.0, 1.0))
	_update_wheels()


## Wheel transforms in the car frame: travel, steering and spin; the left ones
## turned round so the rim faces out.
func _update_wheels() -> void:
	if _wheels == null or _wheel_rest.size() != 4:
		return
	for i in 4:
		var centre := _wheel_rest[i] + Vector3.UP * (_compression[i] - _droop)
		var steer := Basis(Vector3.UP, _steer) if i < 2 else Basis.IDENTITY
		var left := i % 2 == 0
		var face := Basis(Vector3.UP, PI) if left else Basis.IDENTITY
		var spin := Basis(Vector3.RIGHT, -_spin[i] if left else _spin[i])
		_wheels.set_instance_transform(i, Transform3D(steer * face * spin, centre))
