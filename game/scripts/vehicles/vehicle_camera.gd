class_name VehicleCamera
extends Node3D
## The chase camera while the player drives (game/scripts/vehicles/vehicle_manager.gd):
## the player rig's own structure and settings, a pivot -> SpringArm3D ->
## Camera3D with the gameplay camera's field of view, near and far planes and
## the arm's margin (game/scenes/player/player.tscn). Its arm stops at the world
## and at street props, parked cars among them, so it never sits inside one; the
## driven car itself is left out, and so are the small trees' trunks that bend
## out of a car's way (arm_skips, street_tree_bender.gd), which the car passes
## through. It is current only while driving; the on-foot rig (player_camera.gd)
## is left as it is.
##
## The pivot rides above the car as drawn this frame (the car's interpolated
## visual), so it moves smoothly whatever the frame rate, and never below the
## water's surface (a car sinking in the bay). Its yaw swings behind the car's
## heading, slowly when the car creeps and briskly at speed, and in the air it
## follows the flight instead of a tumbling car. With speed the view widens and
## the arm lengthens a little. Moving the mouse (with the pointer captured)
## glances round with the on-foot sensitivity and pitch limits; a second after
## the mouse stops, the view eases back behind the car.
##
## Getting in, the view moves from where the on-foot camera was to behind the
## car, the short way round, and stays there with the car parked; getting out,
## from here to the on-foot camera: a blend camera of its own carries the view
## between them, so neither change is a cut. It swings round the pivot over the
## car, level, rather than cutting across, so it never passes through the car,
## and its yaw and pitch ease with no roll.
##
## Off the island (the car out past the outline, on the riprap or in the water)
## the view stops following the car down among the stones: it blends
## (WATCH_BLEND_S) to a watch camera of its own, held where the car left the
## island, WATCH_BACK_M back the way it came, WATCH_SIDE_M to one side and
## WATCH_UP_M over it, so it sees the car's way down the rocks and into the
## water from beside it; on the first side from which both the car and the water
## WATCH_AHEAD_M ahead of it are in sight past the world, the street props and
## the cars' ground over the rocks, else straight back and WATCH_HIGH_M over it
## (and WATCH_WATER_M over the water at least). It turns to keep the car in view
## (easing over WATCH_LOOK_S), on the water's surface once the car is under it.
## Back on the island for WATCH_END_S without going back to land (driven up off
## the riprap) it blends back to the chase view; a car driven along the edge, in
## and out, keeps the watch. When the car is put back on land (the water's
## return, R), the chase view starts behind it at once, settled (snap_behind).

const DRIVABLE_CAR := preload("res://game/scripts/vehicles/drivable_car.gd")
const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
const PITCH_REST := deg_to_rad(-10.0)
const MIN_PITCH := deg_to_rad(-60.0)
const MAX_PITCH := deg_to_rad(25.0)
## Yaw follow time constants (s): creeping and at speed (FOLLOW_SPEED_MPS).
const FOLLOW_SLOW_S := 1.0
const FOLLOW_FAST_S := 0.3
const FOLLOW_SPEED_MPS := 10.0
## A glance holds this long after the mouse stops, then eases back (s).
const GLANCE_HOLD_S := 1.0
const GLANCE_RETURN_S := 0.45
## Field of view at rest; toward SPEED_FULL_MPS it widens by FOV_WIDEN degrees
## and the arm lengthens by PULL_BACK_M, easing in and out over SPEED_EASE_S.
const FOV := 70.0
const FOV_WIDEN := 10.0
const PULL_BACK_M := 1.2
const SPEED_FULL_MPS := 30.0
const SPEED_EASE_S := 0.5
## The blends getting in and out (s).
const ENTER_BLEND_S := 0.6
const EXIT_BLEND_S := 0.8
## The pivot stays at least this far over the water.
const WATER_CLEAR_M := 1.2
## The watch camera off the island (see above), and how near the car it may get
## across the ground before it backs off.
const WATCH_BACK_M := 3.0
const WATCH_SIDE_M := 7.0
const WATCH_UP_M := 4.5
const WATCH_HIGH_M := 6.5
const WATCH_AHEAD_M := 8.0
const WATCH_WATER_M := 2.5
const WATCH_BLEND_S := 0.5
const WATCH_LOOK_S := 0.12
const WATCH_NEAR_M := 4.0
const WATCH_END_S := 0.6

@export_range(0.0005, 0.01, 0.0001) var look_sensitivity := 0.003

var spring_arm: SpringArm3D
var camera: Camera3D
## Bodies the arm passes through, as the car does: the trunks of the small trees
## that bend (set by the vehicle manager).
var arm_skips: Array[RID] = []
var _blend: Camera3D
var _car: DRIVABLE_CAR
var _yaw := 0.0
var _glance_yaw := 0.0
var _glance_pitch := 0.0
var _since_glance := 0.0
var _speed_share := 0.0
var _arm_length := 6.0
var _clearance := SphereShape3D.new()
var _query := PhysicsShapeQueryParameters3D.new()
var _blend_from := Transform3D.IDENTITY
## The point the blend swings round: the pivot over the car (followed while
## the car is held, kept where it was once let go).
var _blend_centre := Vector3.ZERO
var _blend_from_fov := FOV
var _blend_to: Camera3D
var _blend_t := -1.0
var _blend_s := ENTER_BLEND_S
## The car's view is ours to show (attach take_view): a capture's own camera
## keeps the view otherwise.
var _takes_view := true
var _watch: Camera3D
var _watching := false
## How long the watched car has been back on the island.
var _back_s := 0.0
var _watch_at := Vector3.ZERO
var _watch_look := Vector3.ZERO


func _init() -> void:
	top_level = true
	spring_arm = SpringArm3D.new()
	spring_arm.name = "SpringArm3D"
	spring_arm.margin = 0.15
	spring_arm.collision_mask = PHYSICS_WORLD_SOLID | PHYSICS_STREET_PROP
	spring_arm.rotation = Vector3(PITCH_REST, 0.0, 0.0)
	add_child(spring_arm)
	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.fov = FOV
	spring_arm.add_child(camera)
	_blend = Camera3D.new()
	_blend.name = "BlendCamera"
	_blend.top_level = true
	add_child(_blend)
	_watch = Camera3D.new()
	_watch.name = "WatchCamera"
	_watch.top_level = true
	add_child(_watch)
	_clearance.radius = 0.3
	spring_arm.shape = _clearance
	_query.shape = _clearance
	_query.margin = 0.001
	_query.collision_mask = 1


func _ready() -> void:
	set_process(false)
	set_process_unhandled_input(false)


## Takes the on-foot gameplay camera's near and far planes (player.tscn) for the
## chase camera and its blend, so driving sees as far: the distant horizon.
func use_planes_of(gameplay: Camera3D) -> void:
	for view: Camera3D in [camera, _blend, _watch]:
		view.near = gameplay.near
		view.far = gameplay.far


## Takes over behind car, blending from from_camera (the view the player had)
## when there is one; with take_view false (a capture's own camera is showing)
## it follows the car without taking the view.
func attach(car: DRIVABLE_CAR, from_camera: Camera3D, take_view: bool = true) -> void:
	_car = car
	_takes_view = take_view
	_watching = false
	var forward := -car.visual_transform().basis.z
	_yaw = atan2(-forward.x, -forward.z) if Vector2(forward.x, forward.z).length() > 0.2 else 0.0
	_glance_yaw = 0.0
	_glance_pitch = 0.0
	_since_glance = GLANCE_HOLD_S
	_speed_share = 0.0
	_arm_length = 4.2 + 0.55 * car.length_m
	spring_arm.clear_excluded_objects()
	spring_arm.add_excluded_object(car.get_rid())
	for skip: RID in arm_skips:
		spring_arm.add_excluded_object(skip)
	_place(0.0, true)
	# The arm's end before its first physics update, so a blend starting now
	# heads for the view behind the car, not the pivot over it.
	camera.position = Vector3(0.0, 0.0, spring_arm.spring_length)
	if not take_view:
		_blend_t = -1.0
	elif from_camera != null and from_camera != camera:
		_start_blend(from_camera.global_transform, from_camera.fov, camera, ENTER_BLEND_S)
	else:
		_blend_t = -1.0
		camera.make_current()
	set_process(true)
	set_process_unhandled_input(true)


## Lets go of the car; while this rig's view is the one shown, blends it to
## to_camera. With blend false (a reset) to_camera shows at once.
func detach(to_camera: Camera3D, blend: bool = true) -> void:
	_car = null
	_watching = false
	set_process_unhandled_input(false)
	var showing := get_viewport().get_camera_3d() if is_inside_tree() else null
	if to_camera == null:
		return
	if not blend:
		_blend_t = -1.0
		set_process(false)
		to_camera.make_current()
	elif showing == camera or showing == _blend or showing == _watch:
		_start_blend(showing.global_transform, showing.fov, to_camera, EXIT_BLEND_S)
	else:
		# Another camera (a capture's) is showing: leave it be.
		_blend_t = -1.0
		set_process(false)


## True while the chase view follows a car (not watching it off the island).
func is_following() -> bool:
	return _car != null and not _watching


## True while the view is between the on-foot camera and this one.
func is_blending() -> bool:
	return _blend_t >= 0.0


## Ends a blend now: its target shows, unless another camera took over.
func finish_blend() -> void:
	if _blend_t < 0.0:
		return
	_blend_t = -1.0
	if _blend.current and _blend_to != null and is_instance_valid(_blend_to):
		_blend_to.make_current()


## The view's world yaw and pitch now (handed back to the on-foot rig).
func view_yaw() -> float:
	return _yaw + _glance_yaw


func view_pitch() -> float:
	return clampf(PITCH_REST + _glance_pitch, MIN_PITCH, MAX_PITCH)


func _unhandled_input(event: InputEvent) -> void:
	if _car == null or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		glance((event as InputEventMouseMotion).relative)


## Looks round by this much mouse motion; the view eases back after a moment.
func glance(relative: Vector2) -> void:
	_glance_yaw -= relative.x * look_sensitivity
	_glance_pitch = clampf(PITCH_REST + _glance_pitch - relative.y * look_sensitivity, MIN_PITCH, MAX_PITCH) - PITCH_REST
	_since_glance = 0.0


func _process(delta: float) -> void:
	if _car != null and is_instance_valid(_car):
		if not _watching and _car.is_off_island():
			_start_watch()
		elif _watching:
			_back_s = 0.0 if _car.is_off_island() else _back_s + delta
			if _back_s >= WATCH_END_S:
				_end_watch()
		_place(delta, false)
		if _watching:
			_step_watch(delta)
	if _blend_t >= 0.0:
		_step_blend(delta)
	elif _car == null:
		set_process(false)


## Whether the view showing is this rig's (chase, blend or watch camera).
func _showing_ours() -> bool:
	if not is_inside_tree():
		return false
	var showing := get_viewport().get_camera_3d()
	return showing == camera or showing == _blend or showing == _watch


## Off the island: the watch point beside the car's way down (or back and high
## over it), and a blend to it from the view showing.
func _start_watch() -> void:
	_watching = true
	_back_s = 0.0
	var car_at := _car.visual_transform().origin
	var travel := Vector3(_car.linear_velocity.x, 0.0, _car.linear_velocity.z)
	var away := travel.normalized() if travel.length() > 0.5 else Vector3(-sin(_yaw), 0.0, -cos(_yaw))
	var side := away.cross(Vector3.UP).normalized()
	var ahead := car_at + away * WATCH_AHEAD_M
	ahead.y = _car.water_y + 0.3
	var back := car_at - away * WATCH_BACK_M
	var spots: Array[Vector3] = [back + side * WATCH_SIDE_M + Vector3.UP * WATCH_UP_M, back - side * WATCH_SIDE_M + Vector3.UP * WATCH_UP_M]
	_watch_at = car_at - away * WATCH_BACK_M * 2.0 + Vector3.UP * WATCH_HIGH_M
	for spot: Vector3 in spots:
		if _in_sight(spot, car_at + Vector3.UP * 0.8) and _in_sight(spot, ahead):
			_watch_at = spot
			break
	_watch_at.y = maxf(_watch_at.y, _car.water_y + WATCH_WATER_M)
	_watch_look = car_at + Vector3.UP * 0.6
	_aim_watch()
	_watch.fov = camera.fov
	if _takes_view and _showing_ours():
		var showing := get_viewport().get_camera_3d()
		_start_blend(showing.global_transform, showing.fov, _watch, WATCH_BLEND_S)


## Back on the island without going back to land: blend back to the chase view.
func _end_watch() -> void:
	_watching = false
	if _takes_view and _showing_ours():
		var showing := get_viewport().get_camera_3d()
		_start_blend(showing.global_transform, showing.fov, camera, WATCH_BLEND_S)


## The watch camera this frame: at the watch point (backed off to WATCH_NEAR_M
## across the ground from the car if it came near), looking at the car, or at the
## water's surface over it once it is under.
func _step_watch(delta: float) -> void:
	var car_at := _car.visual_transform().origin
	var target := car_at + Vector3.UP * 0.6
	target.y = maxf(target.y, _car.water_y + 0.3)
	_watch_look = _watch_look.lerp(target, 1.0 - exp(-delta / WATCH_LOOK_S))
	var across := Vector2(_watch_at.x - car_at.x, _watch_at.z - car_at.z)
	if across.length() < WATCH_NEAR_M:
		var back := across.normalized() if across.length() > 0.01 else Vector2(sin(_yaw), cos(_yaw))
		_watch_at = Vector3(car_at.x + back.x * WATCH_NEAR_M, _watch_at.y, car_at.z + back.y * WATCH_NEAR_M)
	_aim_watch()


## Whether nothing solid (the world, a street prop, the cars' ground over the
## rocks) stands between from and to; the driven car is left out.
func _in_sight(from: Vector3, to: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(from, to, PHYSICS_WORLD_SOLID | PHYSICS_STREET_PROP | DRIVABLE_CAR.PHYSICS_CAR_GROUND, [_car.get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _aim_watch() -> void:
	var look := _watch_look - _watch_at
	if Vector2(look.x, look.z).length() < 0.3:
		look += Vector3(-sin(_yaw), 0.0, -cos(_yaw)) * 0.3
	_watch.global_transform = Transform3D(Basis.looking_at(look.normalized(), Vector3.UP), _watch_at)


## The car was put back on land (the water's return, R): the chase view starts
## behind it, settled, with no blend, from where its body is now.
func snap_behind() -> void:
	if _car == null or not is_instance_valid(_car):
		return
	_watching = false
	var xf := _car.global_transform
	var forward := -xf.basis.z
	if Vector2(forward.x, forward.z).length() > 0.2:
		_yaw = atan2(-forward.x, -forward.z)
	_glance_yaw = 0.0
	_glance_pitch = 0.0
	_since_glance = GLANCE_HOLD_S
	_speed_share = 0.0
	_place(0.0, true, xf)
	# The arm's end before its first physics update, as in attach.
	camera.position = Vector3(0.0, 0.0, spring_arm.spring_length)
	_blend_t = -1.0
	if _takes_view and _showing_ours():
		camera.make_current()


func _place(delta: float, snap: bool, at: Variant = null) -> void:
	var xf: Transform3D = at if at is Transform3D else _car.visual_transform()
	var velocity := _car.linear_velocity
	var planar := Vector2(velocity.x, velocity.z).length()
	# Behind the heading on the wheels; along the flight in the air.
	var target := _yaw
	if _car.grounded_wheels() > 0 or planar < 5.0:
		var forward := -xf.basis.z
		if Vector2(forward.x, forward.z).length() > 0.2:
			target = atan2(-forward.x, -forward.z)
	elif planar >= 5.0:
		target = atan2(-velocity.x, -velocity.z)
	var tau := lerpf(FOLLOW_SLOW_S, FOLLOW_FAST_S, clampf(planar / FOLLOW_SPEED_MPS, 0.0, 1.0))
	_yaw = target if snap else lerp_angle(_yaw, target, 1.0 - exp(-delta / tau))
	_since_glance += delta
	if _since_glance > GLANCE_HOLD_S and delta > 0.0:
		var ease := 1.0 - exp(-delta / GLANCE_RETURN_S)
		_glance_yaw = lerp_angle(_glance_yaw, 0.0, ease)
		_glance_pitch = lerpf(_glance_pitch, 0.0, ease)
	var speed_target := clampf(planar / SPEED_FULL_MPS, 0.0, 1.0)
	_speed_share = speed_target if snap else lerpf(_speed_share, speed_target, 1.0 - exp(-delta / SPEED_EASE_S))
	# The pivot above the car's roof, swept up from inside the car so a low
	# ceiling can't start the arm above it (as the on-foot rig does), and over
	# the water's surface.
	var floor_y := _car.water_y + WATER_CLEAR_M
	var anchor := xf.origin + Vector3.UP * (_car.height_m * 0.6)
	anchor.y = maxf(anchor.y, floor_y)
	var desired := xf.origin + Vector3.UP * (_car.height_m + 0.5)
	desired.y = maxf(desired.y, floor_y + 0.5)
	_query.transform = Transform3D(Basis.IDENTITY, anchor)
	_query.motion = desired - anchor
	_query.exclude = [_car.get_rid()]
	var fractions := get_world_3d().direct_space_state.cast_motion(_query) if is_inside_tree() else PackedFloat32Array([1.0, 1.0])
	global_position = anchor + _query.motion * clampf(fractions[0] - 0.01, 0.0, 1.0)
	rotation = Vector3(0.0, _yaw + _glance_yaw, 0.0)
	spring_arm.rotation = Vector3(view_pitch(), 0.0, 0.0)
	spring_arm.spring_length = _arm_length + PULL_BACK_M * _speed_share
	camera.fov = FOV + FOV_WIDEN * _speed_share


func _start_blend(from: Transform3D, from_fov: float, to: Camera3D, seconds: float) -> void:
	_blend_from = from
	_blend_centre = global_position
	_blend_from_fov = from_fov
	_blend_to = to
	_blend_s = seconds
	_blend_t = 0.0
	_blend.global_transform = from
	_blend.fov = from_fov
	_blend.make_current()
	set_process(true)


## Moves the blend camera along: eased from where the view was to the target
## camera wherever it is now; at the end the target shows, unless another
## camera took over meanwhile.
func _step_blend(delta: float) -> void:
	if _blend_to == null or not is_instance_valid(_blend_to):
		_blend_t = -1.0
		return
	_blend_t = minf(1.0, _blend_t + delta / _blend_s)
	var eased := _blend_t * _blend_t * (3.0 - 2.0 * _blend_t)
	var to := _blend_to.global_transform
	# Round the pivot, level: the plan offset's bearing turns and its length
	# and height ease.
	if _car != null and is_instance_valid(_car):
		_blend_centre = global_position
	var from_plan := Vector2(_blend_from.origin.x - _blend_centre.x, _blend_from.origin.z - _blend_centre.z)
	var to_plan := Vector2(to.origin.x - _blend_centre.x, to.origin.z - _blend_centre.z)
	var origin := _blend_from.origin.lerp(to.origin, eased)
	if from_plan.length() > 0.5 and to_plan.length() > 0.5:
		var bearing := lerp_angle(from_plan.angle(), to_plan.angle(), eased)
		var plan := Vector2.from_angle(bearing) * lerpf(from_plan.length(), to_plan.length(), eased)
		origin = Vector3(_blend_centre.x + plan.x, origin.y, _blend_centre.z + plan.y)
	# The view's yaw and pitch ease, its roll stays nil.
	var from_euler := _blend_from.basis.get_euler()
	var to_euler := to.basis.get_euler()
	var look := Vector3(lerp_angle(from_euler.x, to_euler.x, eased), lerp_angle(from_euler.y, to_euler.y, eased), 0.0)
	_blend.global_transform = Transform3D(Basis.from_euler(look), origin)
	_blend.fov = lerpf(_blend_from_fov, _blend_to.fov, eased)
	if _blend_t >= 1.0:
		_blend_t = -1.0
		if _blend.current:
			_blend_to.make_current()
