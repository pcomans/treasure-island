class_name VehicleManager
extends Node3D
## Drivable cars (owner, 2026-11-08): the player walks up to any parked car of
## the street clutter, presses F (vehicle_enter_exit) and drives it; F again gets
## out beside it. A car left alone stays where it stopped for the session; a
## restart rebuilds the world, so everything is back in place.
##
## The parked cars stay static MultiMesh instances with a collision box each
## (street_clutter_builder.gd). Entering one, or a moving live car about to hit
## one (or the driven car pressing against one), swaps it for a live body: its
## instance is drawn at zero scale, its box is disabled and a DrivableCar in the
## same body, paint and place takes over, which a car can push about. A jersey
## water barrier (K-rail) about to be hit swaps the same way for a heavy live
## barrier. A live car or K-rail that comes to rest freezes there (static, no
## per-frame work); a hit wakes it again, so it can be shoved any number of
## times. The rows that can swap are the clutter root's swappable_rows
## metadata, so this works on the world generated at startup and on the baked
## one alike. Freezing: DrivableCar._park (at rest, nobody in it) and
## _settle_barrier; waking: DrivableCar.wake from enter(), DrivableCar.place
## (drive_from) and _wake (a hit in _shove).
##
## Driving: W/S drive, brake and reverse, A/D steer, Space the handbrake (its
## own action on the jetpack's key; the jetpack is off in a car), R puts the car
## back on land at its last safe spot, the mouse glances (vehicle_camera.gd,
## which also blends the view from and back to the on-foot camera). The stock
## controller stops while driving (player_controller.gd begin_driving), its
## avatar hides and the player rides at the seat. A car driven off the shore
## rolls down the riprap on the cars' ground over its stones
## (shoreline_builder.gd), watched from the shore (vehicle_camera.gd); where it
## meets the water it splashes (car_splash.gd) and sinks with the player in it
## before it goes back to land (drivable_car.gd); F does nothing until then. R
## and the return put it on a level spot well clear of the shore, on its brakes
## until driven, the view behind it. Cars stop where the outline crosses the
## causeway (a car-only barrier, shoreline_builder.gd).
##
## Fences: a live car or K-rail passes through the breakable fences' collision
## (an exception per fence body) and breaks each bay it overlaps while it moves
## (street_fence_breaker.gd); on foot every intact bay stays solid. Shrubs and
## hedges have no collision and tree trunks do, so a car drives through a shrub
## and stops at a tree.
##
## The manager pauses with the game (F and R do nothing in the pause menu).
##
## Touch (the browser's touch controls, touch_controls.gd): no key prompts show;
## the use button shows instead, a car while can_enter() or driving, and a tap on
## it is F. In a car the touch stick drives and steers (its vector, not the WASD
## actions) and RISE, which presses the handbrake as Space does, brakes.

signal entered(row_id: String)
signal exited(row_id: String)
signal car_recovered(cause: String, from_position: Vector3)

const KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
const CAR_HERO_LEVEL := preload("res://game/scripts/vehicles/car_hero_level.gd")
const YARD_KIT := preload("res://game/scripts/world/street_yard_kit.gd")
const FENCE_BREAKER := preload("res://game/scripts/vehicles/street_fence_breaker.gd")
const DRIVABLE_CAR := preload("res://game/scripts/vehicles/drivable_car.gd")
const VEHICLE_CAMERA := preload("res://game/scripts/vehicles/vehicle_camera.gd")
const CAR_SPLASH := preload("res://game/scripts/vehicles/car_splash.gd")
const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
const PHYSICS_LOOSE_PROP := 1 << 4
## The cars' ground over the riprap and their barrier at the causeway
## (shoreline_builder.gd), which a live K-rail shoved there meets too.
const PHYSICS_CAR_GROUND := ShorelineBuilder.PHYSICS_CAR_GROUND
const RENDER_WORLD_VISIBLE := 1
## How close (m) the player must be to a car's body to get in.
const ENTER_REACH_M := 2.5
## The swappable rows' lookup grid (m).
const GRID_M := 16.0
## A moving car swaps a static parked car or K-rail it will reach within this
## time (s) or margin (m), so the hit is between two live bodies. Slower (below
## SHOVE_SPEED_MPS) it swaps what it touches (its hull grown by
## CONTACT_MARGIN_M) while it moves at all (SHOVE_CREEP_MPS) or its driver
## presses on, so a car pressed against a parked one at full throttle always
## pushes it, and a K-rail or car rammed against a frozen one wakes that one
## (the hit stops it almost dead, so the creep speed is low).
const LOOKAHEAD_S := 0.15
const LOOKAHEAD_MARGIN_M := 0.4
const SHOVE_SPEED_MPS := 1.5
const SHOVE_CREEP_MPS := 0.05
const CONTACT_MARGIN_M := 0.12
## A shoved or rolling car or K-rail breaks the fence bays it moves into above this (m/s).
const BREAK_SPEED_MPS := 0.5
## A frozen body is woken by a hit at most once in this long (s).
const WAKE_GAP_S := 0.5
## A moving car hands a loose prop it reaches (the pitch's ball,
## game/scripts/world/soccer_ball.gd) its velocity along the contact, plus this
## share of their closing speed, at most LOOSE_PUSH_MAX_MPS, with a little lift,
## as a bumper would: the hull's raked nose sits about a ball's height up, so on
## contact alone a car rides over the ball. Like the ball's own push from a
## character's capsule.
const LOOSE_PUSH_REBOUND := 0.6
const LOOSE_PUSH_LIFT := 0.12
const LOOSE_PUSH_MAX_MPS := 24.0
const LOOSE_PUSH_MARGIN_M := 0.2
## A K-rail: a water-filled jersey unit stands in for concrete; heavy.
const BARRIER_MASS_KG := 900.0
const BARRIER_PARK_S := 1.0
const PROMPT_ENTER := "F  Drive"
const PROMPT_EXIT := "F  Get out"
const PROMPT_EXIT_SHOW_S := 4.0
## Where the player gets out, in the car's level frame: the driver's side, the
## passenger's, behind, in front; the roof if all are blocked.
const EXIT_SIDE_M := 0.75
const EXIT_END_M := 1.3

var _world: WorldLoader
var _player: PlayerController
var _hud: GameHUD
var _touch := false
var _kit: KIT
var _yard: YARD_KIT
var _clutter: Node3D
var _rows: Dictionary = {}
var _cells: Dictionary = {}
var _live: Dictionary = {}
var _active: DRIVABLE_CAR
var _camera: VEHICLE_CAMERA
var _visible_ground := VisibleGround.new()
var _breaker: FENCE_BREAKER
## Draws the parked cars nearest the camera at the hero level (desktop only).
var _hero: CAR_HERO_LEVEL
## The breakable fence bodies (live bodies' collision exceptions) and every
## fence body (what the wheels' rays skip).
var _breakable_fences: Array[RID] = []
var _fences: Array[RID] = []
var _enter_down := false
var _recover_down := false
## The car F would get into now, on foot ("" none): the prompt's and the touch
## use button's test.
var _nearest := ""
var _prompt := ""
var _exit_prompt_s := 0.0
var _query := PhysicsShapeQueryParameters3D.new()
var _loose_query := PhysicsShapeQueryParameters3D.new()


func _init() -> void:
	# Main runs always (its pause menu); cars, F and R stop with the game.
	process_mode = Node.PROCESS_MODE_PAUSABLE


## Indexes the swappable rows of the loaded world. touch: a touch-only browser,
## which has no F key, so it shows no prompt (its use button shows instead).
func configure(world: WorldLoader, player: PlayerController, hud: GameHUD, touch: bool = false) -> void:
	_world = world
	_player = player
	_hud = hud
	_touch = touch
	_kit = KIT.new()
	_rows.clear()
	_cells.clear()
	_clutter = null
	if "clutter" in world.get_street_detail_layers():
		_clutter = world.street_detail_layer("clutter").get_node_or_null("GeneratedStreetClutter") as Node3D
	if _clutter != null:
		var listed: Dictionary = _clutter.get_meta("swappable_rows", {})
		for id: String in listed:
			var entry: Dictionary = (listed[id] as Dictionary).duplicate()
			entry["live"] = false
			_rows[id] = entry
			var origin: Vector3 = (entry.transform as Transform3D).origin
			var cell := Vector2i(floori(origin.x / GRID_M), floori(origin.z / GRID_M))
			if not _cells.has(cell):
				_cells[cell] = []
			(_cells[cell] as Array).append(id)
	if _hero != null:
		_hero.queue_free()
		_hero = null
	if _clutter != null and KIT.hero_level_enabled():
		_hero = CAR_HERO_LEVEL.new()
		_hero.name = "CarHeroLevel"
		add_child(_hero)
		_hero.configure(_kit, _clutter, _rows, _cells, GRID_M)
	_visible_ground.build([world.ground_and_areas, world.roads_and_paths])
	_breaker = FENCE_BREAKER.new()
	_breaker.name = "FenceBreaker"
	add_child(_breaker)
	if "fences" in world.get_street_detail_layers():
		_breaker.configure(world.street_detail_layer("fences"))
	_breakable_fences = _breaker.fence_bodies()
	_fences = _breaker.all_fence_bodies()
	_camera = VEHICLE_CAMERA.new()
	_camera.name = "VehicleCamera"
	_camera.use_planes_of(_player.get_camera())
	add_child(_camera)
	_query.collision_mask = PHYSICS_STREET_PROP
	_query.collide_with_areas = false
	_query.collide_with_bodies = true


func is_driving() -> bool:
	return _active != null


## On foot within reach of a car to get into: where "F  Drive" shows.
func can_enter() -> bool:
	return _active == null and _nearest != ""


func active_car() -> DRIVABLE_CAR:
	return _active


## The live car or barrier of a row, or null while it is static.
func live_node(id: String) -> Node3D:
	return _live.get(id, null)


func swappable_ids() -> Array:
	return _rows.keys()


func row(id: String) -> Dictionary:
	return _rows.get(id, {})


func fence_breaker() -> FENCE_BREAKER:
	return _breaker


func _physics_process(delta: float) -> void:
	if _player == null:
		return
	var enter_now := Input.is_action_pressed("vehicle_enter_exit")
	var enter_pressed := enter_now and not _enter_down
	_enter_down = enter_now
	var recover_now := Input.is_action_pressed("recover")
	var recover_pressed := recover_now and not _recover_down
	_recover_down = recover_now
	if _active != null:
		_drive(delta, enter_pressed, recover_pressed)
	else:
		_on_foot(enter_pressed)
	# Every moving live car or K-rail (not only the driven one) sets moving what
	# it is about to hit, and a shoved or rolling one breaks the fence bays it
	# moves into (the driven car's are broken in _drive).
	for id: String in _live.keys():
		var body := _live[id] as RigidBody3D
		if body == null or body.freeze:
			continue
		var speed := body.linear_velocity.length()
		if speed > SHOVE_SPEED_MPS:
			_shove(body, LOOKAHEAD_S, LOOKAHEAD_MARGIN_M)
		elif speed > SHOVE_CREEP_MPS or (body == _active and absf(_active.drive_input) > 0.1):
			_shove(body, 0.0, CONTACT_MARGIN_M)
		if body != _active and speed > BREAK_SPEED_MPS:
			_breaker.break_overlaps(body)
		if not body is DRIVABLE_CAR:
			_settle_barrier(body, delta)
		elif speed > BREAK_SPEED_MPS:
			_push_loose(body)


func _on_foot(enter_pressed: bool) -> void:
	if not _player.is_processing_unhandled_input():
		_nearest = ""
		_set_prompt("")
		return
	_nearest = _nearest_car(_player.global_position)
	_set_prompt(PROMPT_ENTER if _nearest != "" and not _touch else "")
	if enter_pressed and _nearest != "":
		enter(_nearest)


func _drive(delta: float, exit_pressed: bool, recover_pressed: bool) -> void:
	var car := _active
	if not is_instance_valid(car):
		_active = null
		return
	# The touch stick sets the player's touch vector, not the WASD actions. Its
	# value is taken to the square, so a corner is full throttle and lock, as W+D.
	var stick := _player.touch_input_vector
	if stick.is_zero_approx():
		car.drive_input = Input.get_axis("move_back", "move_forward")
		car.steer_input = Input.get_axis("move_left", "move_right")
	else:
		stick *= stick.length() / maxf(absf(stick.x), absf(stick.y))
		car.drive_input = clampf(-stick.y, -1.0, 1.0)
		car.steer_input = clampf(stick.x, -1.0, 1.0)
	car.handbrake = Input.is_action_pressed("handbrake")
	if recover_pressed:
		car.request_recover("manual")
	# The player rides along at the seat (the grass bends there, the web state reads it).
	_player.global_position = car.seat_transform().origin
	_exit_prompt_s = maxf(0.0, _exit_prompt_s - delta)
	_set_prompt(PROMPT_EXIT if _exit_prompt_s > 0.0 and not _touch else "")
	_breaker.break_overlaps(car)
	# Sinking in the bay, the car takes the player back to land with it.
	if exit_pressed and not car.is_sinking():
		exit_car()


## Gets the player into the car of a swappable row (a parked car, or one that
## is already live). False if the row is not a car.
func enter(id: String) -> bool:
	if _active != null or not _rows.has(id) or str(_rows[id].prop) != "parked_car":
		return false
	var car := _make_live(id) as DRIVABLE_CAR
	if car == null:
		return false
	# The view blends from the player's own camera; a capture's camera keeps showing.
	var showing := get_viewport().get_camera_3d()
	var take := showing == null or showing == _player.get_camera() or _camera.is_ancestor_of(showing)
	car.wake()
	car.occupied = true
	_active = car
	_nearest = ""
	_player.begin_driving()
	_camera.attach(car, showing if take else null, take)
	_exit_prompt_s = PROMPT_EXIT_SHOW_S
	entered.emit(id)
	return true


## Gets the player out beside the car, on the ground, facing as the camera was;
## the view blends back to the on-foot camera (blend false: at once).
func exit_car(blend: bool = true) -> void:
	var car := _active
	if car == null:
		return
	var spot := _exit_spot(car)
	car.occupied = false
	car.drive_input = 0.0
	car.steer_input = 0.0
	car.handbrake = false
	_active = null
	var rig := _player.get_node("CameraPivot") as Node3D
	var arm := rig.get_node("SpringArm3D") as Node3D
	rig.rotation.y = _camera.view_yaw()
	arm.rotation.x = clampf(_camera.view_pitch(), deg_to_rad((rig as PlayerCamera).minimum_pitch_degrees), deg_to_rad((rig as PlayerCamera).maximum_pitch_degrees))
	_player.end_driving(spot.at, bool(spot.beside))
	if bool(spot.blocked):
		# No room beside the car or on its roof: back to the last safe place.
		_player.get_recovery_controller().recover("vehicle_exit")
	_camera.detach(_player.get_camera(), blend)
	_set_prompt("")
	exited.emit(car.row_id)


## Puts a row's car on the ground at xz, facing heading, with the player in it
## (tests and capture drivers start a drive this way): "" or why it can't.
func drive_from(id: String, xz: Vector2, heading: Vector2) -> String:
	force_exit()
	if not _rows.has(id) or str(_rows[id].prop) != "parked_car":
		return "%s is not a parked car" % id
	var car := _make_live(id) as DRIVABLE_CAR
	if car == null:
		return "%s could not be made live" % id
	var ray := PhysicsRayQueryParameters3D.create(Vector3(xz.x, 200.0, xz.y), Vector3(xz.x, -50.0, xz.y), PHYSICS_WORLD_SOLID | PHYSICS_STREET_PROP, [car.get_rid(), _player.get_rid()])
	ray.hit_back_faces = false
	var hit := car.get_world_3d().direct_space_state.intersect_ray(ray)
	if hit.is_empty():
		return "no ground at %s" % xz
	var forward := Vector3(heading.x, 0.0, heading.y).normalized()
	car.place(Transform3D(Basis(forward.cross(Vector3.UP).normalized(), Vector3.UP, -forward), (hit.position as Vector3) + Vector3.UP * 0.25))
	return "" if enter(id) else "could not get into %s" % id


## Out of the car now, wherever it is, with the on-foot camera showing at once
## and any blend ended (a test or capture driver resetting).
func force_exit() -> void:
	if _active != null:
		exit_car(false)
	_camera.finish_blend()


## The driving camera rig (tests read its blend).
func driving_camera() -> VEHICLE_CAMERA:
	return _camera


## A glance of the driving camera by this much mouse motion (a capture driver's
## stand-in for the mouse).
func glance(relative: Vector2) -> void:
	if _active != null:
		_camera.glance(relative)


## The nearest car the player can get into from here, or "". Parked cars are
## found by their row's cell; a live car (driven or shoved) wherever it is now.
func _nearest_car(at: Vector3) -> String:
	var best := ""
	var best_distance := ENTER_REACH_M
	var cell := Vector2i(floori(at.x / GRID_M), floori(at.z / GRID_M))
	for dx in range(-1, 2):
		for dz in range(-1, 2):
			for id: String in _cells.get(cell + Vector2i(dx, dz), []):
				var entry: Dictionary = _rows[id]
				if str(entry.prop) != "parked_car" or _live.has(id):
					continue
				var distance := _distance_to_car(id, at)
				if distance < best_distance:
					best_distance = distance
					best = id
	for id: String in _live:
		if not _live[id] is DRIVABLE_CAR:
			continue
		var distance := _distance_to_car(id, at)
		if distance < best_distance:
			best_distance = distance
			best = id
	return best


## How far a point is from a car's plan box (0 inside), and too far when the
## heights differ by more than a storey.
func _distance_to_car(id: String, at: Vector3) -> float:
	var entry: Dictionary = _rows[id]
	var xf: Transform3D = entry.transform
	var box := Vector3(1.0, 1.0, 2.5)
	var live: Node3D = _live.get(id, null)
	if live is DRIVABLE_CAR:
		var car := live as DRIVABLE_CAR
		xf = car.global_transform
		box = Vector3(car.width_m * 0.5, car.height_m, car.length_m * 0.5)
	else:
		var parts := _kit.drivable(str((entry.params as Dictionary).get("body", "")))
		if parts.ok:
			var chassis: AABB = (parts.chassis as Mesh).get_aabb()
			box = Vector3(chassis.size.x * 0.5, chassis.end.y, chassis.size.z * 0.5)
	var local := xf.affine_inverse() * at
	if local.y < -2.0 or local.y > box.y + 2.0:
		return INF
	return Vector2(maxf(0.0, absf(local.x) - box.x), maxf(0.0, absf(local.z) - box.z)).length()


## The swap: hides a static row and puts its live body in its place.
func _make_live(id: String) -> Node3D:
	if _live.has(id):
		return _live[id]
	if not _rows.has(id) or _clutter == null:
		return null
	var entry: Dictionary = _rows[id]
	var node: Node3D = null
	if str(entry.prop) == "parked_car":
		node = _new_car(id, entry)
	else:
		node = _new_barrier(id, entry)
	if node == null:
		return null
	if _hero != null:
		_hero.release(id)
	for ref: Array in entry.instances:
		var instance := _clutter.get_node_or_null(str(ref[0])) as MultiMeshInstance3D
		if instance != null and instance.multimesh != null:
			instance.multimesh.set_instance_transform(int(ref[1]), Transform3D(Basis().scaled(Vector3.ZERO), (entry.transform as Transform3D).origin))
	for ref: Array in entry.shapes:
		var body := _clutter.get_node_or_null(str(ref[0]))
		var shape := body.get_node_or_null(str(ref[1])) as CollisionShape3D if body != null else null
		if shape != null:
			shape.disabled = true
	add_child(node)
	entry.live = true
	_live[id] = node
	return node


func _new_car(id: String, entry: Dictionary) -> DRIVABLE_CAR:
	var params: Dictionary = entry.params
	var parts := _kit.drivable(str(params.get("body", "")))
	var custom := KIT.car_custom(params, 0.0)
	if not parts.ok or not custom.ok:
		push_warning("Vehicle %s: %s" % [id, parts.get("message", custom.get("message", ""))])
		return null
	var car := DRIVABLE_CAR.new()
	car.name = "Car_" + id.validate_node_name()
	car.row_id = id
	car.boundary = _world.get_boundary()
	car.visible_ground = _visible_ground
	car.water_y = GeneratedWorldContract.STREET_DETAIL_WATER_Y_M
	car.breakable_fences = _breakable_fences
	car.setup(str(params.body), parts, _kit.material(), custom.custom, entry.transform, _fences, _kit.hero_visual(str(params.body), custom.custom))
	car.recovered.connect(_on_car_recovered.bind(car))
	car.splashed.connect(_splash.bind(car))
	for fence: RID in _breakable_fences:
		PhysicsServer3D.body_add_collision_exception(car.get_rid(), fence)
	return car


## A K-rail as a heavy live barrier: the yard kit's pieces and shapes for its row.
func _new_barrier(id: String, entry: Dictionary) -> RigidBody3D:
	if _yard == null:
		_yard = YARD_KIT.new()
	var built: Dictionary = _yard.pieces(str(entry.prop), entry.params, int(entry.get("seed", 0)), entry.get("footprint", {}))
	if not built.ok:
		push_warning("Barrier %s: %s" % [id, built.message])
		return null
	var barrier := RigidBody3D.new()
	barrier.name = "Barrier_" + id.validate_node_name()
	barrier.mass = BARRIER_MASS_KG
	barrier.collision_layer = PHYSICS_STREET_PROP
	barrier.collision_mask = PHYSICS_WORLD_SOLID | PHYSICS_STREET_PROP | PHYSICS_CAR_GROUND
	barrier.can_sleep = true
	var surface := PhysicsMaterial.new()
	surface.friction = 0.8
	surface.bounce = 0.05
	barrier.physics_material_override = surface
	barrier.set_meta("feature_kind", "street_clutter")
	barrier.set_meta("receiver_kind", "none")
	barrier.set_meta("street_detail_id", id)
	barrier.transform = entry.transform
	for piece: Dictionary in built.pieces:
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_custom_data = true
		multimesh.mesh = (piece.meshes as Array)[0]
		multimesh.instance_count = 1
		multimesh.set_instance_transform(0, piece.transform)
		multimesh.set_instance_custom_data(0, piece.custom)
		var instance := MultiMeshInstance3D.new()
		instance.multimesh = multimesh
		instance.material_override = piece.get("material", _yard.material())
		instance.layers = RENDER_WORLD_VISIBLE
		instance.visibility_range_end = float(built.range_m)
		barrier.add_child(instance)
	for shape_entry: Dictionary in built.shapes:
		var collision := CollisionShape3D.new()
		collision.shape = shape_entry.shape
		collision.transform = shape_entry.transform
		barrier.add_child(collision)
	barrier.set_meta("park_wait", 0.0)
	for fence: RID in _breakable_fences:
		PhysicsServer3D.body_add_collision_exception(barrier.get_rid(), fence)
	return barrier


## A barrier comes to rest and freezes there (solid, as before it was hit).
func _settle_barrier(barrier: RigidBody3D, delta: float) -> void:
	if barrier.freeze:
		return
	if barrier.global_position.y < DRIVABLE_CAR.FALL_RECOVERY_Y:
		barrier.global_transform = _rows[str(barrier.get_meta("street_detail_id"))].transform
		barrier.linear_velocity = Vector3.ZERO
		barrier.angular_velocity = Vector3.ZERO
	if barrier.linear_velocity.length() < 0.1 and barrier.angular_velocity.length() < 0.1:
		var wait := float(barrier.get_meta("park_wait", 0.0)) + delta
		barrier.set_meta("park_wait", wait)
		if wait >= BARRIER_PARK_S:
			barrier.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
			barrier.freeze = true
	else:
		barrier.set_meta("park_wait", 0.0)


## Sets moving whatever parked car or K-rail a moving live body (car or K-rail)
## is about to hit: its hull lookahead_s ahead, grown by margin (0 s: what it
## touches now). A static row swaps for its live body; a live one that has come
## to rest and frozen wakes.
func _shove(car: RigidBody3D, lookahead_s: float, margin: float) -> void:
	var space := car.get_world_3d().direct_space_state
	var ahead := Transform3D(car.global_transform.basis, car.global_position + car.linear_velocity * lookahead_s)
	_query.margin = margin
	_query.exclude = [car.get_rid()]
	for owner_id in car.get_shape_owners():
		for index in car.shape_owner_get_shape_count(owner_id):
			_query.shape = car.shape_owner_get_shape(owner_id, index)
			_query.transform = ahead * car.shape_owner_get_transform(owner_id)
			for hit: Dictionary in space.intersect_shape(_query, 16):
				var body := hit.get("collider") as CollisionObject3D
				if body is RigidBody3D and body.get_parent() == self and (body as RigidBody3D).freeze:
					_wake(body as RigidBody3D)
					continue
				if body == null or body.get_parent() != _clutter:
					continue
				var shape_owner := body.shape_find_owner(int(hit.get("shape", -1)))
				var shape := body.shape_owner_get_owner(shape_owner) as Node if shape_owner >= 0 else null
				if shape == null:
					continue
				var id := str(shape.get_meta("street_detail_id", ""))
				if _rows.has(id) and not bool(_rows[id].live):
					var node := _make_live(id)
					if node is DRIVABLE_CAR:
						(node as DRIVABLE_CAR).occupied = false


## Pushes the loose props (the pitch's ball) a moving car's hull is about to
## meet, as a bumper: see LOOSE_PUSH_REBOUND.
func _push_loose(car: RigidBody3D) -> void:
	var space := car.get_world_3d().direct_space_state
	_loose_query.collision_mask = PHYSICS_LOOSE_PROP
	_loose_query.collide_with_areas = false
	_loose_query.margin = LOOSE_PUSH_MARGIN_M
	_loose_query.exclude = [car.get_rid()]
	var pushed := {}
	for owner_id in car.get_shape_owners():
		for index in car.shape_owner_get_shape_count(owner_id):
			_loose_query.shape = car.shape_owner_get_shape(owner_id, index)
			_loose_query.transform = car.global_transform * car.shape_owner_get_transform(owner_id)
			for hit: Dictionary in space.intersect_shape(_loose_query, 4):
				var prop := hit.get("collider") as RigidBody3D
				if prop == null or pushed.has(prop):
					continue
				pushed[prop] = true
				var offset := prop.global_position - car.global_position
				var normal := Vector3(offset.x, 0.0, offset.z)
				if normal.length_squared() < 0.000001:
					continue
				normal = normal.normalized()
				var closing := (car.linear_velocity - prop.linear_velocity).dot(normal)
				if closing <= 0.0:
					continue
				var target := minf(car.linear_velocity.dot(normal) + LOOSE_PUSH_REBOUND * closing, LOOSE_PUSH_MAX_MPS)
				var change := target - prop.linear_velocity.dot(normal)
				if change > 0.0:
					prop.apply_central_impulse((normal + Vector3.UP * LOOSE_PUSH_LIFT) * change * prop.mass)


## A live car or K-rail that came to rest and froze, set moving again by a hit
## (at most once in WAKE_GAP_S, so two bodies at rest against each other can't
## keep waking each other).
func _wake(body: RigidBody3D) -> void:
	var frame := Engine.get_physics_frames()
	var gap := int(WAKE_GAP_S * Engine.physics_ticks_per_second)
	if frame - int(body.get_meta("woken_frame", -gap)) < gap:
		return
	body.set_meta("woken_frame", frame)
	if body is DRIVABLE_CAR:
		var car := body as DRIVABLE_CAR
		car.occupied = false
		car.wake()
	else:
		body.set_meta("park_wait", 0.0)
		body.freeze = false


## A car put back on land (the water's return, R): the driven one's chase view
## starts behind it, settled.
func _on_car_recovered(cause: String, from: Vector3, car: DRIVABLE_CAR) -> void:
	if car == _active:
		_camera.snap_behind()
	car_recovered.emit(cause, from)


## The splash where a car met the water.
func _splash(at: Vector3, speed: float, car: DRIVABLE_CAR) -> void:
	var splash := CAR_SPLASH.new()
	splash.name = "Splash"
	add_child(splash, true)
	splash.start(at, speed, car.length_m)


## Where the player gets out: {at, beside, blocked}. Beside the car (the
## driver's side first) on clear ground: beside true, and the recovery's safe
## place moves there. Else on the car's roof if the player fits there: beside
## false, no safe place. Else blocked: back to the last safe place.
func _exit_spot(car: DRIVABLE_CAR) -> Dictionary:
	var xf := car.global_transform
	var forward := -xf.basis.z
	forward.y = 0.0
	if forward.length() < 0.2:
		forward = Vector3.UP.cross(xf.basis.x)
		forward.y = 0.0
	forward = forward.normalized() if forward.length() > 0.01 else Vector3.FORWARD
	var right := forward.cross(Vector3.UP).normalized()
	var origin := xf.origin
	var side := car.width_m * 0.5 + EXIT_SIDE_M
	var ends := car.length_m * 0.5 + EXIT_END_M
	var seat_z := -0.1
	var candidates: Array[Vector3] = [
		origin - right * side + forward * seat_z,
		origin + right * side + forward * seat_z,
		origin - forward * ends,
		origin + forward * ends,
	]
	var space := car.get_world_3d().direct_space_state
	var capsule := (_player.get_node("CollisionShape3D") as CollisionShape3D).shape.duplicate() as CapsuleShape3D
	capsule.radius = maxf(0.05, capsule.radius - 0.03)
	capsule.height = maxf(capsule.radius * 2.0, capsule.height - 0.06)
	var probe := PhysicsShapeQueryParameters3D.new()
	probe.shape = capsule
	probe.collision_mask = _player.collision_mask
	probe.exclude = [_player.get_rid()]
	for spot: Vector3 in candidates:
		var ray := PhysicsRayQueryParameters3D.create(spot + Vector3.UP * 2.5, spot + Vector3.DOWN * 3.0, _player.collision_mask, [_player.get_rid(), car.get_rid()])
		ray.hit_back_faces = false
		var hit := space.intersect_ray(ray)
		if hit.is_empty() or (hit.normal as Vector3).dot(Vector3.UP) < 0.6:
			continue
		var feet: Vector3 = hit.position
		probe.transform = Transform3D(Basis.IDENTITY, feet + Vector3.UP * 0.93)
		if space.intersect_shape(probe, 1).is_empty():
			return {"at": Transform3D(Basis.IDENTITY, feet + Vector3.UP * 0.05), "beside": true, "blocked": false}
	var roof := origin + Vector3.UP * (car.height_m + 0.3)
	probe.transform = Transform3D(Basis.IDENTITY, roof + Vector3.UP * 0.93)
	probe.exclude = [_player.get_rid(), car.get_rid()]
	var clear := space.intersect_shape(probe, 1).is_empty()
	return {"at": Transform3D(Basis.IDENTITY, roof), "beside": false, "blocked": not clear}


func _set_prompt(text: String) -> void:
	if text == _prompt or _hud == null:
		return
	_prompt = text
	_hud.set_prompt(text)
