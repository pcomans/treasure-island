class_name DrivableCar
extends RigidBody3D
## A street-clutter parked car or a storage yard's van, truck or RV set moving:
## the one the player drives, or one a driven car shoved
## (game/scripts/vehicles/vehicle_manager.gd swaps it in for its static row). An arcade car on raycast suspension, a real rigid body: it
## goes airborne, lands, bounces, leans in corners and can flip and roll in
## crashes, off a ramp taken askew, in hard turns and when a kerb or an obstacle
## trips it sideways (owner, 2026-11-08: "flipping cars in games is fun").
##
## Each physics tick four rays, one per wheel, find the ground under the kit's
## wheel centres (street_clutter_kit.gd or street_yard_kit.gd drivable(); the
## drawn ground's lift over
## the land collision is added, as for the player character's feet). A spring
## and damper per wheel hold the body up, sized so it rests at the parked car's
## height; tyre forces at each contact cancel side slip and drive or brake along
## the wheel, held to a friction circle. The handbrake lets the rear slide. A
## mild yaw assist steadies ordinary driving, a mild anti-roll bar keeps gentle
## cornering flat; nothing levels the car in the air, so it lands however it was
## flying. A car resting on its roof or side, nearly still, for RIGHT_AFTER_S
## rights itself with a short pop and roll. Driven off the shore it rolls down
## the riprap on the cars' own ground over the stones (shoreline_builder.gd
## _car_ground; the stones are drawn only), so it never sinks into them; where
## its body first reaches the water it splashes there (the splashed signal),
## slides on off the stones and sinks below the surface, then goes back to land
## facing away from the water, with the player still in it. Back on land it
## stands on its brakes on a level spot well clear of the shore until its driver
## drives off.
##
## The body is on the street-prop layer, like the parked cars: the player and
## other cars collide with it, the on-foot camera's arm ignores it and the
## chase camera's arm stops at it (unless it is the car
## being driven). It and its wheels meet the world, the street props and the
## cars' ground over the riprap and its barrier at the causeway
## (PHYSICS_CAR_GROUND), which is frictionless for the body (so a car that
## bottoms out on the crest slides on over it). Come to rest on the island with
## nobody in it, it freezes (static, as solid as a parked car) and does no
## per-frame work until wake(): getting in, being put down, or a hit
## (vehicle_manager.gd _shove). Its visual is a top-level node moved each frame
## between the last two physics states (Engine.get_physics_interpolation_fraction),
## so it stays smooth when the frame rate and the 60 Hz physics differ (the web
## build).
##
## Handling numbers are production inference for arcade feel, not measured.

signal recovered(cause: String, from_position: Vector3)
## The car's body met the water off the island at this point on its surface
## (over the corner that reached it first), at this speed.
signal splashed(at: Vector3, speed: float)

const KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
const CAR_DRIVER := preload("res://game/scripts/vehicles/car_driver.gd")

const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
## The cars' ground over the riprap and their barrier at the causeway.
const PHYSICS_CAR_GROUND := ShorelineBuilder.PHYSICS_CAR_GROUND
## What the body, its wheels and its own queries meet.
const GROUND_MASK := PHYSICS_WORLD_SOLID | PHYSICS_STREET_PROP | PHYSICS_CAR_GROUND
const RENDER_WORLD_VISIBLE := 1

## Per body: mass (kg), top speed (m/s), launch acceleration (m/s^2), and the
## collision outline from the kit's body profiles (tools/lib/street-clutter-kit.mjs
## CAR_BODIES): the belt (hood) height, the rear deck height, the cabin's
## windshield base and top, roof end and rear glass base (m from the front
## bumper) and its roof height. The yards' vans, trucks and RVs (owner,
## 2026-11-11; tools/lib/street-yard-meshes.mjs YARD_DRIVABLE, by kit name) are
## heavier and slower, on the same suspension, grip and mild anti-roll, so the
## tall ones tip in a fast corner; KISS arcade values, production inference.
## Their outline is boxes [front, back (m from the front bumper), bottom, top,
## half width] read off the kit's profiles (the first one's bottom edges raked as
## a car's), their width the body's (m; a car's comes from its wheel track).
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
	"van_step": {"mass": 4500.0, "top": 27.0, "accel": 5.0, "roof": 2.95, "width": 2.4,
		"boxes": [[0.0, 7.0, 0.42, 1.25, 1.2], [0.42, 7.0, 1.25, 2.55, 1.2], [0.82, 7.0, 2.55, 2.95, 1.2]]},
	"food_truck_step_van": {"mass": 5200.0, "top": 26.0, "accel": 4.5, "roof": 2.98, "width": 2.4,
		"boxes": [[0.0, 7.3, 0.42, 1.25, 1.2], [0.42, 7.3, 1.25, 2.55, 1.2], [0.82, 7.3, 2.55, 2.98, 1.2]]},
	"box_truck_medium": {"mass": 6500.0, "top": 26.0, "accel": 4.5, "roof": 3.5, "width": 2.4,
		"boxes": [[0.0, 7.4, 0.45, 0.98, 1.2], [0.0, 2.05, 0.98, 2.48, 1.0], [2.17, 7.4, 0.98, 3.5, 1.2]]},
	"box_truck_large": {"mass": 9500.0, "top": 24.0, "accel": 3.6, "roof": 4.0, "width": 2.6,
		"boxes": [[0.0, 10.4, 0.42, 1.18, 1.3], [0.0, 1.3, 1.18, 1.72, 1.17], [1.3, 2.75, 1.18, 2.8, 1.17], [2.87, 10.4, 1.18, 4.0, 1.3]]},
	"rv_class_c": {"mass": 5500.0, "top": 27.0, "accel": 4.5, "roof": 3.2, "width": 2.4,
		"boxes": [[0.0, 8.5, 0.45, 1.3, 1.2], [0.75, 1.85, 1.3, 2.24, 1.0], [0.95, 1.73, 2.24, 3.2, 1.2], [1.73, 8.5, 1.3, 3.2, 1.2]]},
	"rv_class_a": {"mass": 10000.0, "top": 25.0, "accel": 3.5, "roof": 3.45, "width": 2.55,
		"boxes": [[0.0, 11.6, 0.42, 1.25, 1.275], [0.1, 11.6, 1.25, 2.6, 1.275], [0.9, 11.6, 2.6, 3.45, 1.275]]},
}
## Bodies that drive as another body's BODIES entry: the yard's cargo van is the
## street van's body, so a retune of the van moves both.
const ALIASES := {"van_cargo": "van"}
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
## Where it rights itself: RIGHT_LIFT_M over where it lay, or, if its hulls
## would meet a wall, a car or a prop there, the first clear of these offsets
## (m, in its level frame: across, up, along).
const RIGHT_LIFT_M := 0.25
const RIGHT_OFFSETS: Array[Vector3] = [Vector3(1.2, 0.25, 0.0), Vector3(-1.2, 0.25, 0.0), Vector3(0.0, 0.25, 1.5), Vector3(0.0, 0.25, -1.5), Vector3(0.0, 1.0, 0.0), Vector3(2.4, 0.25, 0.0), Vector3(-2.4, 0.25, 0.0)]
## A wheel in the air spins down at this share of its rolling rate (1/s).
const AIR_SPIN_DAMP := 0.6
## A car left alone (no driver) and at rest this long freezes: a static body
## where it stopped, for the rest of the session, until it is woken (wake()).
const PARK_AFTER_S := 0.75
const PARK_SPEED_MPS := 0.15
## Recovery off the island (owner: a car driven into the bay comes back on land
## with the player). Every SAFE_EVERY_S the car notes where it is when that is
## a stable spot to come back to: on all four wheels, tilted less than
## SAFE_TILT_DEG, turning slowly, inside the outline and SAFE_SHORE_M or more
## from its edge, so never on the shore's slope nor by the rocks; and whether
## it is on a road or path (the drawn ground there lifted ROAD_LIFT_M or more,
## VisibleGround). The return (from the water, R) takes the newest spot
## at least SAFE_AGE_S old where its hulls have room, a road spot instead when
## one lies within ROAD_PREFER_M of it, facing the way it was going there, or
## the other way if that leads away from where it left; then turned, if need
## be, for RESET_CLEAR_M of island ahead. There it is held on its brakes until
## it has settled (RESET_SETTLE_S at least, three wheels or more down) and its
## driver presses W or S, so it never rolls off the spot it was put on. Where
## its body first meets the water (its lowest corner under the surface, off the
## outline) it splashes, and from then on it is in the water (is_sinking): while
## any of it is still over the cars' ground it rolls on down that on its wheels,
## slowed by the water on the part of it that is in (WATER_DRAG), so it goes in
## clear of the stones' tops; then it sinks: it keeps a share of its speed
## (WATER_IMPACT_KEEP), is held up by a share of its weight once under
## (SINK_BUOYANCY: too little to float, so it goes under within the second) and
## slowed (WATER_DRAG, WATER_SPIN_DRAG, 1/s), and slid on seaward at CLEAR_MPS at
## least should it drift back over the cars' ground. It goes back SINK_UNDER_S
## after its top went under the surface, SINK_MIN_S after the splash at the
## soonest and SINK_MAX_S at the latest. Off the outline on its wheels and
## nearly still (under STRANDED_MPS) for STRANDED_S (stopped on the riprap), or
## off it at all for OUTSIDE_LIMIT_S, it goes back without the water; a car
## rolling down the riprap is not stranded, and a car nobody drives never parks
## off the outline, so this brings it back too.
const SAFE_EVERY_S := 0.25
const SAFE_AGE_S := 2.0
const SAFE_SAMPLES := 64
const SAFE_TILT_DEG := 4.0
const SAFE_SHORE_M := 12.0
const SAFE_TURN_RADPS := 1.5
const ROAD_LIFT_M := 0.07
const ROAD_PREFER_M := 50.0
const RESET_CLEAR_M := 10.0
const RESET_SETTLE_S := 0.5
## Put back this far over the spot it noted (where it stood on its wheels), so it
## settles there with barely a drop.
const RESET_LIFT_M := 0.03
const SINK_MIN_S := 1.0
const SINK_UNDER_S := 0.25
const SINK_MAX_S := 4.0
const CLEAR_MPS := 2.5
const WATER_IMPACT_KEEP := 0.45
const SINK_BUOYANCY := 0.45
const WATER_DRAG := 1.8
const WATER_SPIN_DRAG := 2.5
const STRANDED_S := 2.0
const STRANDED_MPS := 1.0
const OUTSIDE_LIMIT_S := 8.0
const FALL_RECOVERY_Y := -20.0
## The outline test is redone only once the car has moved this far (m).
const OUTLINE_RECHECK_M := 1.0
## The detail hand-over and draw range, as the parked cars' (street_clutter_kit.gd);
## a yard vehicle's parts give its own (street_yard_kit.gd drivable()).
const LOD_NEAR_M := KIT.LOD_NEAR_M
const FAR_RANGE_M := 260.0
## The driver's seat in the car frame: where the player rides, for the systems
## that follow the player (the grass round the player, the web state).
const SEAT := Vector3(-0.38, 0.55, -0.15)

var row_id := ""
var body := ""
## What it is drawn with at every level, as setup() was given it (instance
## custom data: paint, style, twist and dirt; street_clutter_kit.gd car_custom).
var look := Color()
## Driver input, set each tick by the vehicle manager: drive -1..1 (S..W),
## steer -1..1 (A..D, positive right), handbrake.
var drive_input := 0.0
var steer_input := 0.0
var handbrake := false
var occupied := false:
	set(value):
		occupied = value
		if _driver != null:
			_driver.visible = value
## The playable outline and the drawn ground (set by the vehicle manager).
var boundary: WorldBoundary
var visible_ground: VisibleGround
var water_y := -0.12
## The breakable fence bodies it passes through (set by the vehicle manager);
## its righting may end overlapping one, never an unbreakable one.
var breakable_fences: Array[RID] = []

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
## The stable spots to come back to: [{transform, time, road}], oldest first.
var _safe: Array[Dictionary] = []
var _safe_clock := 0.0
var _outside_s := 0.0
## Off the outline on its wheels and nearly still: how long so far.
var _stranded_s := 0.0
var _inside := true
var _inside_at := Vector3.INF
## How long since it splashed (in the water; -1 until it does, and again once it
## is back on the island), whether it has started to sink (it rolls on in on its
## wheels until then), and where it was at the splash.
var _wet := -1.0
var _sinking := false
var _sink_from := Vector3.ZERO
## How long its top has been under the surface (sinking; -1 until it is).
var _under_s := -1.0
var _below := PhysicsRayQueryParameters3D.new()
## Back on land, held on its brakes (RESET_SETTLE_S): how long so far.
var _holding := false
var _hold_s := 0.0
var _clock := 0.0
var _recover_request := ""
var _teleport := Transform3D.IDENTITY
var _teleport_pending := false

var _prev := Transform3D.IDENTITY
var _curr := Transform3D.IDENTITY
var _visual: Node3D
## The wheels: all four, or the front two where the rear ones are another mesh
## (_rear_wheels: a truck's twin tyres).
var _wheels: MultiMesh
## The hero level's driver at the wheel (shown while occupied), where it draws.
var _driver: Node3D
## The hero level's wheels and brakes, where it draws.
var _hero_wheels: MultiMesh
var _hero_brakes: MultiMesh
var _rear_wheels: MultiMesh
## The front of the body (its chassis mesh's) in the car frame, where a boxy
## body's outline is measured from.
var _front_z := -2.25
var _hull_query := PhysicsShapeQueryParameters3D.new()


## The BODIES entry a body drives with (through ALIASES), or {} for a body
## nobody can drive.
static func spec_of(car_body: String) -> Dictionary:
	return BODIES.get(ALIASES.get(car_body, car_body), {})


## Builds the car for a kit body (KIT.drivable(body)) in its paint and puts it
## at placement; excludes are bodies its wheels and its own queries skip (the
## fences it drives through and their debris).
func setup(car_body: String, parts: Dictionary, material: Material, custom: Color, placement: Transform3D, excludes: Array[RID], hero: Node3D = null) -> void:
	body = car_body
	look = custom
	var spec := spec_of(car_body)
	var front: Vector3 = parts.front
	var rear: Vector3 = parts.rear
	wheel_radius = float(parts.radius)
	wheelbase = rear.z - front.z
	var chassis_box: AABB = (parts.chassis as Mesh).get_aabb()
	length_m = chassis_box.size.z
	_front_z = chassis_box.position.z
	width_m = float(spec.get("width", 2.0 * (front.x + float(parts.tyre_width) * 0.5 + 0.035)))
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
	collision_layer = PHYSICS_STREET_PROP
	collision_mask = GROUND_MASK
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
	# A kit car collides as its drawn body (parts.hulls); a body without them as two boxes.
	var hulls: Array = parts.get("hulls", [])
	for hull: PackedVector3Array in (hulls if not hulls.is_empty() else _hulls(spec)):
		var shape := ConvexPolygonShape3D.new()
		shape.points = hull
		var collision := CollisionShape3D.new()
		collision.shape = shape
		add_child(collision)
	_ray.collision_mask = GROUND_MASK
	_below.collision_mask = PHYSICS_CAR_GROUND
	_below.hit_back_faces = false
	_below.collide_with_areas = false
	_ray.hit_back_faces = false
	_ray.collide_with_areas = false
	set_excludes(excludes)
	_build_visual(parts, material, custom, hero)
	transform = placement
	_prev = placement
	_curr = placement
	# The visual is top level: put it there now, not at the first frame, so a
	# camera taking over this tick sees the car where it is.
	_visual.transform = placement
	_safe = [{"transform": placement, "time": -INF, "road": false}]
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
## tail raked up so kerbs and ramp toes don't snag, and the cabin. A boxy body
## (spec boxes) has its boxes instead (_box_hulls).
func _hulls(spec: Dictionary) -> Array[PackedVector3Array]:
	if spec.has("boxes"):
		return _box_hulls(spec.boxes)
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


## A boxy body's hulls: each box [front, back (m from the front of the body),
## bottom, top, half width], the first one's bottom edges raked as a car's lower
## body's, so kerbs and ramp toes don't snag.
func _box_hulls(boxes: Array) -> Array[PackedVector3Array]:
	var hulls: Array[PackedVector3Array] = []
	for index in boxes.size():
		var box: Array = boxes[index]
		var z0 := _front_z + float(box[0])
		var z1 := _front_z + float(box[1])
		var bottom := float(box[2])
		var top := float(box[3])
		var hw := float(box[4])
		var hull := PackedVector3Array()
		for sx: float in [-1.0, 1.0]:
			hull.append(Vector3(sx * hw, top, z0))
			hull.append(Vector3(sx * hw, top, z1))
			if index == 0:
				hull.append(Vector3(sx * hw, bottom, z0 + 0.42))
				hull.append(Vector3(sx * hw, bottom, z1 - 0.36))
				hull.append(Vector3(sx * hw, bottom + 0.17, z0))
				hull.append(Vector3(sx * hw, bottom + 0.17, z1))
			else:
				hull.append(Vector3(sx * hw, bottom, z0))
				hull.append(Vector3(sx * hw, bottom, z1))
		hulls.append(hull)
	return hulls


## The car's drawn levels, each over its own range from the car: the hero level
## (hero: the kit's hero_visual, where it is on) nearest, then the near chassis
## with its wheels (a boxy body's rear wheels apart, parts.tyre_rear), then the
## far mesh. Only the shadow caster and the far mesh cast a shadow; a body
## without a shadow caster (a yard vehicle) casts its own from its near level.
func _build_visual(parts: Dictionary, material: Material, custom: Color, hero: Node3D) -> void:
	_visual = Node3D.new()
	_visual.name = "Visual"
	_visual.top_level = true
	add_child(_visual)
	var bounds := AABB(Vector3(-width_m, -0.5, -length_m), Vector3(width_m * 2.0, height_m + 1.5, length_m * 2.0))
	var off := GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var near_from := 0.0
	if hero != null:
		near_from = KIT.HERO_FAR_M
		for child: Node in hero.get_children():
			var piece := child as MultiMeshInstance3D
			piece.multimesh.custom_aabb = bounds
			piece.visibility_range_end = near_from
			piece.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
		_hero_wheels = (hero.get_node("Wheels") as MultiMeshInstance3D).multimesh
		_hero_brakes = (hero.get_node("Brakes") as MultiMeshInstance3D).multimesh
		if hero.has_meta("driver_seat"):
			_driver = CAR_DRIVER.build(hero.get_meta("driver_seat"), hero.get_meta("driver_hand_left"), hero.get_meta("driver_hand_right"))
			_driver.visible = occupied
			for piece: Node in _driver.find_children("*", "GeometryInstance3D", true, false):
				(piece as GeometryInstance3D).visibility_range_end = near_from
			hero.add_child(_driver)
		_visual.add_child(hero)
	var near_m := float(parts.get("lod_near_m", LOD_NEAR_M))
	var shadow_caster: Variant = parts.get("shadow")
	var near_shadows := off if shadow_caster is Mesh else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	_visual.add_child(_instance("Chassis", parts.chassis, 1, custom, material, bounds, near_from, near_m, near_shadows))
	var wheels := _instance("Wheels", parts.tyre, 2 if parts.has("tyre_rear") else 4, custom, material, bounds, near_from, near_m, near_shadows)
	_wheels = wheels.multimesh
	_visual.add_child(wheels)
	if parts.has("tyre_rear"):
		var rear_wheels := _instance("RearWheels", parts.tyre_rear, 2, custom, material, bounds, near_from, near_m, near_shadows)
		_rear_wheels = rear_wheels.multimesh
		_visual.add_child(rear_wheels)
	if shadow_caster is Mesh:
		_visual.add_child(_instance("Shadow", shadow_caster, 1, custom, material, bounds, 0.0, near_m, GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY))
	_visual.add_child(_instance("Far", parts.far, 1, custom, material, bounds, near_m, float(parts.get("range_m", FAR_RANGE_M)), GeometryInstance3D.SHADOW_CASTING_SETTING_ON))
	_update_wheels()


static func _instance(node_name: String, mesh: Mesh, count: int, custom: Color, material: Material, bounds: AABB, begin_m: float, end_m: float, shadows: int) -> MultiMeshInstance3D:
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
	instance.cast_shadow = shadows
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


## In the water, from the splash until it goes back to land: rolling on in on
## its wheels, then sinking.
func is_sinking() -> bool:
	return _wet >= 0.0


## Off the island: past the outline (on the riprap, over the water) or in the water.
func is_off_island() -> bool:
	return not _inside or _wet >= 0.0


## Back on land and held on its brakes until it has settled and is driven off.
func is_holding() -> bool:
	return _holding


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
		"occupied": occupied, "righting": is_righting(), "sinking": is_sinking(), "holding": _holding, "frozen": freeze,
		"body": body, "row": row_id,
	}


## Asks for the off-island reset at the next physics tick ("manual" for R).
func request_recover(cause: String = "manual") -> void:
	_recover_request = cause


## Puts the car down at a new place with no motion (used by tests); its visual
## goes there at once, for a camera taking over this tick. A place on the
## island becomes the only spot it can come back to until it notes others.
func place(at: Transform3D) -> void:
	wake()
	_teleport = at
	_teleport_pending = true
	_prev = at
	_curr = at
	if _visual != null:
		_visual.transform = at
	if boundary != null and boundary.contains_position(at.origin):
		_safe = [{"transform": at, "time": -INF, "road": false}]


# --- Physics.

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var dt := state.step
	_clock += dt
	if _teleport_pending:
		_teleport_pending = false
		_righting = -1.0
		_wet = -1.0
		_sinking = false
		_holding = false
		_outside_s = 0.0
		_stranded_s = 0.0
		_set_state(state, _teleport, Vector3.ZERO)
		return
	if _righting >= 0.0:
		_step_righting(state, dt)
		return
	if _wet >= 0.0:
		_wet += dt
	if _sinking:
		_step_sinking(state, dt)
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
	# Just put back on land: held on its brakes until settled and driven off.
	var held := false
	if _holding:
		_hold_s += dt
		if _hold_s >= RESET_SETTLE_S and _grounded >= 3 and velocity.length() < 0.2 and (absf(drive_input) > 0.1 or not occupied):
			_holding = false
		else:
			throttle = 0.0
			braking = true
			held = true
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
		if held:
			# Held where it was put, the tyre grips like a parked one: it takes
			# its share of the weight's pull along the ground, and of its own
			# spring's push along it where the body does not sit square to the
			# ground under this wheel, as well as any slip, so the car does not
			# creep down a gentle slope.
			var pull := Vector3.DOWN * _gravity() + up * force / quarter
			pull -= normal * pull.dot(normal)
			longitudinal = -(v_long / dt + pull.dot(along)) * quarter
			lateral = -(v_lat / dt + pull.dot(side)) * quarter
		var tyre := Vector2(lateral, longitudinal)
		var limit := grip * force
		if tyre.length() > limit:
			tyre *= limit / maxf(tyre.length(), 0.001)
		state.apply_force(side * tyre.x + along * tyre.y, contact - origin)
		_spin[i] = 0.0 if locked else _spin[i] - v_long / wheel_radius * dt
	for i in 4:
		if hits[i] == null:
			_spin[i] -= forward_speed_now / wheel_radius * dt * AIR_SPIN_DAMP
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
	if _wet >= 0.0:
		# Rolling on in: the water slows the part of it that is in.
		state.apply_central_force(-velocity * mass * WATER_DRAG * clampf((water_y - lowest_y(xf)) / maxf(height_m, 0.5), 0.0, 1.0))
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
	_right_to = _right_target(state.get_space_state(), xf)
	_righting = 0.0


## Where to right itself from xf: upright, RIGHT_LIFT_M over where it lies, or
## moved by the first of RIGHT_OFFSETS that leaves its hulls clear of the world
## and the street props (the pop and roll itself ignores collisions, so a car
## on its side against a wall mustn't turn into the wall). If none is clear it
## rights itself where it lies.
func _right_target(space: PhysicsDirectSpaceState3D, xf: Transform3D) -> Transform3D:
	var basis := _upright_basis(xf.basis)
	var target := Transform3D(basis, xf.origin + Vector3.UP * RIGHT_LIFT_M)
	if _hulls_clear(space, target):
		return target
	for offset: Vector3 in RIGHT_OFFSETS:
		var moved := Transform3D(basis, xf.origin + basis.x * offset.x + Vector3.UP * offset.y - basis.z * offset.z)
		if _hulls_clear(space, moved):
			return moved
	return target


## Whether the car's hulls at xf meet nothing solid: the world, a street prop or
## the cars' ground (itself and the breakable fences it drives through left out;
## an unbreakable fence counts, as the car can't pass it).
func _hulls_clear(space: PhysicsDirectSpaceState3D, xf: Transform3D) -> bool:
	_hull_query.collision_mask = GROUND_MASK
	var skip: Array[RID] = [get_rid()]
	skip.append_array(breakable_fences)
	_hull_query.exclude = skip
	_hull_query.margin = 0.02
	for owner_id in get_shape_owners():
		for index in shape_owner_get_shape_count(owner_id):
			_hull_query.shape = shape_owner_get_shape(owner_id, index)
			_hull_query.transform = xf * shape_owner_get_transform(owner_id)
			if not space.intersect_shape(_hull_query, 1).is_empty():
				return false
	return true


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
		return
	state.transform = xf
	state.linear_velocity = Vector3.ZERO
	state.angular_velocity = Vector3.ZERO


## Puts the body at xf with this velocity and no spin (put down, put back, the
## end of a righting).
func _set_state(state: PhysicsDirectBodyState3D, xf: Transform3D, velocity: Vector3) -> void:
	state.transform = xf
	state.linear_velocity = velocity
	state.angular_velocity = Vector3.ZERO
	_prev = xf
	_curr = xf
	# The visual goes there at once too, so a camera that reads it this frame,
	# before this car's _process, sees the car where it now is.
	if _visual != null:
		_visual.global_transform = xf
	for i in 4:
		_compression[i] = _droop


## Off the island: into the water (its lowest corner under the surface, off the
## outline) it splashes there and, once clear of the cars' ground, sinks;
## stranded off the outline, fallen far below the world, or R: back to land at
## once. On the island it notes the stable spots to come back to.
func _watch_recovery(state: PhysicsDirectBodyState3D, dt: float) -> void:
	if boundary == null:
		return
	var xf := state.transform
	var origin := xf.origin
	if origin.distance_squared_to(_inside_at) > OUTLINE_RECHECK_M * OUTLINE_RECHECK_M:
		_inside = boundary.contains_position(origin)
		_inside_at = origin
	var inside := _inside
	var lowest := lowest_point(xf)
	var wet := lowest.y < water_y and not boundary.contains_position(lowest)
	if inside and not wet:
		_wet = -1.0
	_outside_s = 0.0 if inside else _outside_s + dt
	_stranded_s = _stranded_s + dt if not inside and _grounded > 0 and state.linear_velocity.length() < STRANDED_MPS else 0.0
	_safe_clock += dt
	if _safe_clock >= SAFE_EVERY_S:
		_safe_clock = 0.0
		if inside and _grounded == 4 and xf.basis.y.dot(Vector3.UP) >= cos(deg_to_rad(SAFE_TILT_DEG)) and state.angular_velocity.length() < SAFE_TURN_RADPS \
		and boundary.edge_distance(origin) >= SAFE_SHORE_M:
			var road := visible_ground != null and visible_ground.lift_at(origin.x, origin.z) >= ROAD_LIFT_M
			_safe.append({"transform": xf, "time": _clock, "road": road})
			if _safe.size() > SAFE_SAMPLES:
				_safe.pop_front()
	var cause := _recover_request
	_recover_request = ""
	if cause == "":
		if wet and _wet < 0.0:
			_wet = 0.0
			_sink_from = origin
			splashed.emit.call_deferred(Vector3(lowest.x, water_y, lowest.z), state.linear_velocity.length())
		if origin.y < FALL_RECOVERY_Y:
			cause = "fell_below_world"
		elif _wet >= 0.0 and lowest.y < water_y and _ground_below(state) == Vector3.ZERO:
			_start_sinking(state)
			return
		elif not inside and (_stranded_s > STRANDED_S or _outside_s > OUTSIDE_LIMIT_S):
			cause = "outside_boundary"
	if cause != "":
		_reset(state, cause, origin)


## The lowest of the car's box corners (wheels to roof) at xf, however it lies.
func lowest_y(xf: Transform3D) -> float:
	return lowest_point(xf).y


## Where that lowest corner is.
func lowest_point(xf: Transform3D) -> Vector3:
	var lowest := Vector3.INF
	for corner in 8:
		var local := Vector3((corner & 1) * 2 - 1, 0.0, ((corner >> 1) & 1) * 2 - 1) * Vector3(width_m * 0.45, 0.0, length_m * 0.45)
		local.y = height_m if corner >= 4 else 0.05
		var at := xf * local
		if at.y < lowest.y:
			lowest = at
	return lowest


## The highest of the car's box corners (wheels to roof) at xf, however it lies.
func highest_y(xf: Transform3D) -> float:
	var highest := -INF
	for corner in 8:
		var local := Vector3((corner & 1) * 2 - 1, 0.0, ((corner >> 1) & 1) * 2 - 1) * Vector3(width_m * 0.45, 0.0, length_m * 0.45)
		local.y = height_m if corner >= 4 else 0.05
		highest = maxf(highest, (xf * local).y)
	return highest


## In the water and clear of the cars' ground: the car starts to sink.
func _start_sinking(state: PhysicsDirectBodyState3D) -> void:
	_sinking = true
	_under_s = -1.0
	_upright_wait = 0.0
	state.linear_velocity *= WATER_IMPACT_KEEP


## Sinking: no wheels, held up by part of its weight once under, slowed, slid on
## down the cars' ground should any of it be over that; then back to land
## (SINK_UNDER_S after its top went under, between SINK_MIN_S and SINK_MAX_S
## after the splash).
func _step_sinking(state: PhysicsDirectBodyState3D, dt: float) -> void:
	_grounded = 0
	for i in 4:
		_contact[i] = false
		_compression[i] = 0.0
	var xf := state.transform
	var under := clampf((water_y - lowest_y(xf)) / maxf(height_m, 0.5), 0.0, 1.0)
	state.apply_central_force(Vector3.UP * mass * _gravity() * SINK_BUOYANCY * under)
	state.apply_central_force(-state.linear_velocity * mass * WATER_DRAG)
	state.apply_torque(-state.angular_velocity * (inertia.x + inertia.y + inertia.z) / 3.0 * WATER_SPIN_DRAG)
	var slope := _ground_below(state)
	if slope != Vector3.ZERO:
		var downhill := Vector3(slope.x, 0.0, slope.z)
		if downhill.length() > 0.05:
			downhill = downhill.normalized()
			var along := state.linear_velocity.dot(downhill)
			if along < CLEAR_MPS:
				state.linear_velocity += downhill * (CLEAR_MPS - along)
	if highest_y(xf) < water_y:
		_under_s = maxf(_under_s, 0.0) + dt
	if (_wet >= SINK_MIN_S and _under_s >= SINK_UNDER_S) or _wet >= SINK_MAX_S:
		_reset(state, "water", _sink_from)


## The cars' ground under any corner of the car's bottom or its middle: the mean
## of its normals there, or Vector3.ZERO where none of them is over it.
func _ground_below(state: PhysicsDirectBodyState3D) -> Vector3:
	var xf := state.transform
	var space := state.get_space_state()
	var normal := Vector3.ZERO
	for corner: Vector2 in [Vector2.ZERO, Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		var at := xf * Vector3(corner.x * width_m * 0.45, 0.05, corner.y * length_m * 0.45)
		_below.from = at + Vector3.UP * 1.0
		_below.to = at + Vector3.DOWN * 3.0
		var hit := space.intersect_ray(_below)
		if not hit.is_empty():
			normal += hit.normal as Vector3
	return normal.normalized() if normal.length() > 1e-4 else Vector3.ZERO


## Back to land (see SAFE_SHORE_M): to the stable spot _return_spot picks,
## upright, facing along the way it was going there unless that leads back
## toward where it left (from), and toward RESET_CLEAR_M of island ahead; held
## on its brakes until it has settled and is driven off.
func _reset(state: PhysicsDirectBodyState3D, cause: String, from: Vector3) -> void:
	var target := _return_spot(state.get_space_state())
	var forward := -_upright_basis(target.basis).z
	var away := Vector3(target.origin.x - from.x, 0.0, target.origin.z - from.z)
	if away.length() > 2.0 and forward.dot(away) < 0.0:
		forward = -forward
	for turn: float in [0.0, PI * 0.5, -PI * 0.5, PI]:
		var heading := forward.rotated(Vector3.UP, turn)
		if boundary.contains_position(target.origin + heading * RESET_CLEAR_M):
			forward = heading
			break
	var placed := Transform3D(Basis(forward.cross(Vector3.UP).normalized(), Vector3.UP, -forward), target.origin + Vector3.UP * RESET_LIFT_M)
	_outside_s = 0.0
	_stranded_s = 0.0
	# The spot is on the island (the camera's watch ends on it at once).
	_inside = true
	_inside_at = Vector3.INF
	_upright_wait = 0.0
	_righting = -1.0
	_wet = -1.0
	_sinking = false
	_recover_request = ""
	_holding = true
	_hold_s = 0.0
	_under_s = -1.0
	_set_state(state, placed, Vector3.ZERO)
	recovered.emit.call_deferred(cause, from)


## The stable spot to go back to: the newest noted at least SAFE_AGE_S ago where
## the car's hulls have room, or the newest road spot within ROAD_PREFER_M of
## it; if none has room, the newest at least SAFE_AGE_S old (else the oldest).
func _return_spot(space: PhysicsDirectSpaceState3D) -> Transform3D:
	var newest: Variant = null
	var fallback: Variant = null
	for index in range(_safe.size() - 1, -1, -1):
		var spot: Dictionary = _safe[index]
		if _clock - float(spot.time) < SAFE_AGE_S:
			continue
		var at: Transform3D = spot.transform
		if fallback == null:
			fallback = at
		if newest != null and at.origin.distance_to((newest as Transform3D).origin) > ROAD_PREFER_M:
			break
		if not _hulls_clear(space, Transform3D(_upright_basis(at.basis), at.origin + Vector3.UP * RESET_LIFT_M)):
			continue
		if bool(spot.get("road", false)):
			return at
		if newest == null:
			newest = at
	if newest != null:
		return newest
	return fallback if fallback != null else (_safe[0].transform as Transform3D)


func _physics_process(delta: float) -> void:
	_prev = _curr
	_curr = global_transform
	if freeze:
		return
	# A car nobody drives freezes once it has come to rest on the island: it stays
	# there. Off the outline it never does, so the stranded rule brings it back.
	if not occupied and _righting < 0.0 and _wet < 0.0 and linear_velocity.length() < PARK_SPEED_MPS and angular_velocity.length() < PARK_SPEED_MPS and up_dot() > RIGHT_UP_DOT \
	and (boundary == null or boundary.contains_position(global_position)):
		_park_wait += delta
		if _park_wait >= PARK_AFTER_S:
			_park()
	else:
		_park_wait = 0.0


## Frozen where it came to rest, as solid as a parked car: its visual and
## wheels drawn there once, then no per-frame work until wake().
func _park() -> void:
	_park_wait = 0.0
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	_prev = global_transform
	_curr = global_transform
	if _visual != null:
		_visual.global_transform = global_transform
	_update_wheels()
	set_process(false)
	set_physics_process(false)


## Moving again (got into, put down or hit): unfrozen, with its per-frame work
## back on.
func wake() -> void:
	_park_wait = 0.0
	_prev = global_transform
	_curr = global_transform
	freeze = false
	set_process(true)
	set_physics_process(true)


func _process(_delta: float) -> void:
	if _visual == null:
		return
	if freeze:
		_visual.global_transform = global_transform
	else:
		_visual.global_transform = _prev.interpolate_with(_curr, clampf(Engine.get_physics_interpolation_fraction(), 0.0, 1.0))
	_update_wheels()


## Wheel transforms in the car frame: travel, steering and spin; the left ones
## turned round so the rim faces out. The hero level's wheels take the same,
## its brakes the same without the spin (a left one's caliper turned round to
## the rear, as the right one's).
func _update_wheels() -> void:
	if _wheels == null or _wheel_rest.size() != 4:
		return
	for i in 4:
		var centre := _wheel_rest[i] + Vector3.UP * (_compression[i] - _droop)
		var steer := Basis(Vector3.UP, _steer) if i < 2 else Basis.IDENTITY
		var left := i % 2 == 0
		var face := Basis(Vector3.UP, PI) if left else Basis.IDENTITY
		var spin := Basis(Vector3.RIGHT, -_spin[i] if left else _spin[i])
		var placed := Transform3D(steer * face * spin, centre)
		if _rear_wheels != null and i >= 2:
			_rear_wheels.set_instance_transform(i - 2, placed)
		else:
			_wheels.set_instance_transform(i, placed)
		if _hero_wheels != null:
			_hero_wheels.set_instance_transform(i, placed)
			_hero_brakes.set_instance_transform(i, Transform3D(steer * face * (Basis(Vector3.RIGHT, 2.0 * KIT.CALIPER_ANGLE - PI) if left else Basis.IDENTITY), centre))
