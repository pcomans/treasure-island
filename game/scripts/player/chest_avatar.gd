class_name ChestAvatar
extends Node3D
## The player character: a wooden treasure chest full of gold on rubber-hose
## legs and arms, in the 1930s cartoon style, with its eyes on the lid
## (geometry and materials in chest_avatar_parts.gd). Visual only: it reads the
## stock player's motion (real velocity, floor contact, the jetpack action) and
## never changes it; it has no collision and stays about the size of the old
## capsule, so camera framing and spray aim are unchanged.
##
## Everything is procedural and driven by that motion, each physics tick after
## the controller has moved the player:
## - Gait: a phase advances with ground speed, about two strides a second at
##   the stock walk and quicker above it. Each foot stays planted in the
##   world while it carries the chest, so it never slides, then swings to a spot
##   predicted from the velocity, on the ground a short ray finds there with the
##   player's own collision mask (stairs and street props included), lifted onto
##   any road, path or area drawn a few centimetres above the land the player
##   stands on (VisibleGround). Arms swing against the legs; the chest bobs, leans
##   and sways. Running at speed shakes gold out of the lid: a few coins tumble
##   out behind, bounce and shrink away (a small reused pool; nothing stays).
## - Air: the legs dangle and pedal and reach for the ground before landing; the
##   arms flail on the way up and float out on the slow descent. Landing
##   squashes the chest, plants both feet and pops a few coins out. Coming down
##   on the fast drop (C) also kicks up a little dust poof round the feet
##   (landing_poof.gd).
## - Lid: a sprung hinge, simulated. It is driven by the chest's own
##   acceleration (the lid's inertia in the chest's accelerating frame: thrust
##   pushes it shut, releasing the jet or the rebound of a landing throws it
##   open, starting to run lifts it), by airflow (running holds it ajar, the
##   slow descent makes it flutter), by footstep jolts and the jet's rattle. Its
##   closed stop is elastic, so it chatters, and soft-limited when wide open.
## - Coins: loose coins hop in the same accelerating frame and tumble while
##   they fly, kept under the lid. Hands follow their poses on damped springs.
## - Eyes blink now and then and look towards the camera. They sit on the lid's
##   outer face; as it opens wide they ride its arch up to the raised front edge
##   and peek over it (the eye shader draws nothing inside the lid).

const Parts := preload("res://game/scripts/player/chest_avatar_parts.gd")
const GroundDressing := preload("res://game/scripts/world/ground_dressing.gd")

## Feet stand on what the player stands on: its own collision mask (world solid
## and street props); this is the fallback without a player.
const GROUND_MASK := 1
## Ground speed (m/s) below which the chest stands.
const STAND_SPEED := 0.25
## A planted foot further than this from its standing spot takes a settling step.
const SETTLE_DISTANCE := 0.09
const FOOT_SPREAD := 0.19
const FOOT_FORWARD := 0.03
const FOOT_TOE_OUT := 0.12
## Floor contact must be lost this long (s) before the chest counts as airborne,
## unless it is thrusting or rising.
const AIR_GRACE := 0.12
## Stride cycles per second at most: at the 20 m/s run more would strobe at web
## frame rates; the knee-less hoses stretch (and stay curved) instead.
const CADENCE_MAX := 5.0
## Walking: WALK_CADENCE stride cycles a second (a step of each foot) at the
## stock walk speed, with fewer, shorter strides below it, and a foot down for
## WALK_DUTY of each stride so the long strides stay within a rubber-hose
## stretch. Above the walk both blend into the run's own, which they equal from
## RUN_CADENCE_SPEED on (where the run's cadence reaches CADENCE_MAX): the run
## and its blend from there are unchanged.
const WALK_SPEED := 4.0
const WALK_CADENCE := 2.0
const WALK_DUTY := 0.5
const RUN_CADENCE_SPEED := 7.4

## Lid hinge: natural frequency (Hz), damping ratio, rest angle (rad), gains
## from the hinge's acceleration (rad/s^2 per m/s^2), airflow lift (rad per
## (m/s)^2) and the closed and open stops. Tuned offline against the stock
## controller's accelerations (30 m/s^2 run start, 40 braking, 12 jet).
const LID_FREQUENCY := 3.0
const LID_DAMPING := 0.16
const LID_REST := 0.026
const LID_GAIN_UP := 12.0
const LID_GAIN_FORWARD := 3.6
const LID_ACCEL_TAU := 0.05
const LID_ACCEL_LIMIT := 60.0
const LID_AIR_FORWARD := 0.0007
const LID_AIR_FALL := 0.06
const LID_AIR_MAX := 0.32
const LID_RESTITUTION := 0.42
const LID_STICK := 0.45
const LID_OPEN_MAX := 1.0
const LID_BOB_COUPLING := 0.35
const LID_STEP_KICK := 1.1
const LID_RATTLE := 0.9
const LID_SUBSTEPS := 4

const SQUASH_FREQUENCY := 3.2
const SQUASH_DAMPING := 0.3
## Squash speed per 1.5 m/s of landing impact: a clear rubber-hose squash
## (about -0.22) and stretch.
const LANDING_SQUASH := 8.0
## Lid angles (rad) over which the eyes slide from their rest seat to
## Parts.EYE_ARCH_OPEN on the lid's arch.
const EYE_SLIDE_FROM := 0.17
const EYE_SLIDE_TO := 0.79
const ARM_FREQUENCY := 2.6
const ARM_DAMPING := 0.35
const ARM_INERTIA := 0.012
const LEG_FREQUENCY := 3.0
const LEG_DAMPING := 0.4
const LEG_INERTIA := 0.008
## Share of the gait bob's acceleration that the loose coins feel.
const COIN_BOB_COUPLING := 0.5
const LOOSE_COINS := 7
const PUFFS := 16
const PUFF_LIFE := 0.65
## Coins shaken out of the chest: a fixed pool, each coin living this long (s),
## spilled by footsteps above SPILL_SPEED (m/s) with this chance.
const SPILL_COINS := 16
const SPILL_LIFE := 1.6
const SPILL_SPEED := 9.0
const SPILL_CHANCE := 0.35
## Spilled coins are drawn larger than the heap's, to read at camera distance.
const SPILL_SCALE := 1.6
## A landing kicks up the dust poof only on the fast drop: C held (and not Space,
## which wins over it) and coming down at least this share of the fast-drop speed.
## The slow descent, which also follows walking off a ledge, is 1.5 m/s; a tap of
## C in the last metre or so before touchdown does not count.
const POOF_SPEED_SHARE := 0.5

var _player: CharacterBody3D
var _materials: Parts.Materials
var _body: Node3D
var _lid: Node3D
var _coin_multimesh: MultiMesh
var _puff_multimesh: MultiMesh
var _puff_instance: MultiMeshInstance3D
var _legs: Array[Leg] = []
var _arms: Array[Arm] = []
var _coins: Array[Coin] = []
var _puffs: Array[Puff] = []
var _spills: Array[Spill] = []
var _spill_multimesh: MultiMesh
var _spill_instance: MultiMeshInstance3D
var _poof: LandingPoof
var _poof_warmed := false
var _eye_mount: Node3D
## The eye mount relative to the arch frame under it, and that frame's arch angle.
var _eye_seat := Transform3D.IDENTITY
var _eye_arch_rest := 0.0
var _blobs: Array[MeshInstance3D] = []
var _ray := PhysicsRayQueryParameters3D.new()
var _space: PhysicsDirectSpaceState3D
var _hit_normal := Vector3.UP
var _hit := false
var _world: WorldLoader
var _visible_ground := VisibleGround.new()
var _ground_stale := true
var _lift := 0.0
## The visible ground under the chest this tick (y -INF when none was found).
var _under := Vector3.ZERO

var _reset_pending := true
var _last_position := Vector3.ZERO
var _last_yaw := 0.0
var _time := 0.0
var _velocity := Vector3.ZERO
var _acceleration := Vector3.ZERO
var _airborne := false
var _air_time := 0.0
var _fall_speed := 0.0
var _phase := 0.02
var _cadence := 2.0
var _duty := 0.58
var _w_move := 0.0
var _w_run := 0.0
var _w_air := 0.0
var _w_rise := 0.0
var _lean := 0.0
var _roll := 0.0
var _squash := 0.0
var _squash_speed := 0.0
var _squash_accel := 0.0
var _lid_angle := 0.0
var _lid_speed := 0.0
var _lid_accel := Vector2.ZERO
var _rattle_timer := 0.0
var _blink_timer := 2.0
var _blink_time := -1.0
var _double_blink := false
var _squint := 0.0
var _look := Vector2(0.0, -0.08)
var _flame := 0.0
var _puff_timer := 0.0
var _puff_side := 1.0
var _rng := RandomNumberGenerator.new()


class Leg:
	extends RefCounted
	var side := 1.0
	var phase_offset := 0.0
	var swinging := false
	## World: the planted sole centre, the ground normal under it, the shoe's yaw.
	var foot := Vector3.ZERO
	var normal := Vector3.UP
	var yaw := 0.0
	## World: where the swing started and where it lands.
	var lift := Vector3.ZERO
	var lift_yaw := 0.0
	var target := Vector3.ZERO
	var target_normal := Vector3.UP
	## World: the sole centre this tick (planted or swinging).
	var current := Vector3.ZERO
	var current_yaw := 0.0
	var pitch := 0.0
	## Avatar frame: the dangling foot while airborne, a damped spring.
	var air := Vector3.ZERO
	var air_velocity := Vector3.ZERO
	var material: ShaderMaterial
	var shoe: Node3D


class Arm:
	extends RefCounted
	var side := 1.0
	## Avatar frame: the hand's spring offset from its pose, and its velocity.
	var offset := Vector3.ZERO
	var offset_velocity := Vector3.ZERO
	var hand := Vector3.ZERO
	var trail := Vector3.ZERO
	var material: ShaderMaterial
	var glove: Node3D


class Coin:
	extends RefCounted
	var rest := Transform3D.IDENTITY
	var height := 0.0
	var speed := 0.0
	var spin := 0.0
	var spin_speed := 0.0
	var axis := Vector3.RIGHT
	var moved := true


class Puff:
	extends RefCounted
	var position := Vector3.ZERO
	var velocity := Vector3.ZERO
	var age := 99.0
	var size := 0.1


class Spill:
	extends RefCounted
	var position := Vector3.ZERO
	var velocity := Vector3.ZERO
	var axis := Vector3.RIGHT
	var spin := 0.0
	var spin_speed := 0.0
	var age := 99.0
	var bounces := 0
	## The ground under the coin, re-found when it has moved on.
	var ground := -INF
	var ground_xz := Vector2(INF, INF)


func _ready() -> void:
	_rng.seed = 1930
	var node := get_parent()
	while node != null and not node is CharacterBody3D:
		node = node.get_parent()
	_player = node as CharacterBody3D
	_build()
	_ray.collision_mask = GROUND_MASK
	_ray.collide_with_areas = false
	if _player != null:
		_ray.collision_mask = _player.collision_mask
		_ray.exclude = [_player.get_rid()]
		# Run after the controller has moved the player (as the camera does).
		process_physics_priority = _player.process_physics_priority + 1
		# The world beside the player (main.tscn): its draped roads and areas,
		# indexed again whenever it (re)loads.
		var main := _player.get_parent()
		if main != null:
			for child in main.get_children():
				if child is WorldLoader:
					_world = child
					_world.world_ready.connect(func(_report: Dictionary) -> void: _ground_stale = true)
					break


## Read-only state for evidence captures.
func describe() -> Dictionary:
	return {
		"lid_deg": rad_to_deg(_lid_angle), "phase": _phase, "airborne": _airborne,
		"speed": Vector2(_velocity.x, _velocity.z).length(), "squash": _squash,
		"flame": _flame, "swinging": [_legs[0].swinging, _legs[1].swinging] if _legs.size() == 2 else [],
		"feet": [_legs[0].current, _legs[1].current] if _legs.size() == 2 else [],
		"spilled": _spills.filter(func(coin: Spill) -> bool: return coin.age < SPILL_LIFE).size(),
		"dust": _poof != null and _poof.emitting,
		"dust_ground": _poof != null and _poof.ground_offered,
	}


# --- Building the rig.

func _build() -> void:
	var m := Parts.make_materials()
	_materials = m
	_body = Node3D.new()
	_body.name = "Body"
	_body.position = Vector3(0.0, Parts.HIP_HEIGHT, 0.0)
	add_child(_body)
	_mesh(_body, "Chest", Parts.body(m), true)
	_mesh(_body, "ChestOutline", Parts.body_outline(m), false)
	_lid = Node3D.new()
	_lid.name = "Lid"
	_lid.position = Parts.HINGE
	_body.add_child(_lid)
	_mesh(_lid, "LidBoards", Parts.lid(m), true)
	_mesh(_lid, "LidOutline", Parts.lid_outline(m), false)
	_eye_mount = Node3D.new()
	_eye_mount.name = "EyeMount"
	_eye_mount.position = Parts.EYE_MOUNT
	_eye_arch_rest = Parts.eye_arch_rest()
	_eye_seat = Parts.lid_arch_frame(_eye_arch_rest).affine_inverse() * _eye_mount.transform
	_lid.add_child(_eye_mount)
	_mesh(_eye_mount, "Eyes", Parts.eyes(m), false)
	var flames := _mesh(_body, "JetFlames", Parts.flames(m), false)
	flames.custom_aabb = AABB(Vector3(-0.3, -0.7, -0.6), Vector3(0.6, 0.8, 0.5))
	# Loose coins on the heap, one MultiMesh.
	_coin_multimesh = MultiMesh.new()
	_coin_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_coin_multimesh.mesh = Parts.loose_coin(m)
	_coin_multimesh.instance_count = LOOSE_COINS
	var coins := MultiMeshInstance3D.new()
	coins.name = "LooseCoins"
	coins.multimesh = _coin_multimesh
	coins.custom_aabb = AABB(Vector3(-0.4, 0.3, -0.3), Vector3(0.8, 0.5, 0.6))
	coins.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_body.add_child(coins)
	for rest in Parts.loose_coin_rests(LOOSE_COINS):
		var coin := Coin.new()
		coin.rest = rest
		coin.axis = Vector3(_rng.randf_range(-1, 1), 0, _rng.randf_range(-1, 1)).normalized()
		_coins.append(coin)
	# Limbs: hoses bent by their shader, gloves and shoes as nodes.
	var hose_mesh := Parts.hose(Parts.hose_material(Parts.ARM_RADIUS))
	var limb_box := AABB(Vector3(-1.5, -1.0, -1.5), Vector3(3.0, 3.5, 3.0))
	for side: float in [1.0, -1.0]:
		var leg := Leg.new()
		leg.side = side
		leg.phase_offset = 0.0 if side > 0.0 else 0.5
		leg.material = Parts.hose_material(Parts.LEG_RADIUS)
		var leg_hose := _mesh(self, "LegHose", hose_mesh, true)
		leg_hose.material_override = leg.material
		leg_hose.custom_aabb = limb_box
		leg.shoe = Node3D.new()
		leg.shoe.name = "Shoe"
		add_child(leg.shoe)
		_mesh(leg.shoe, "ShoeMesh", Parts.shoe(m, false), true)
		_mesh(leg.shoe, "ShoeOutline", Parts.shoe(m, true), false)
		_legs.append(leg)
		var arm := Arm.new()
		arm.side = side
		arm.material = Parts.hose_material(Parts.ARM_RADIUS)
		var arm_hose := _mesh(self, "ArmHose", hose_mesh, true)
		arm_hose.material_override = arm.material
		arm_hose.custom_aabb = limb_box
		arm.glove = Node3D.new()
		arm.glove.name = "Glove"
		add_child(arm.glove)
		_mesh(arm.glove, "GloveMesh", Parts.glove(m, side, false), true)
		_mesh(arm.glove, "GloveOutline", Parts.glove(m, side, true), false)
		_arms.append(arm)
	# Smoke puffs from the jet stay where they were blown, in world space.
	_puff_multimesh = MultiMesh.new()
	_puff_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_puff_multimesh.mesh = Parts.puff(m)
	_puff_multimesh.instance_count = PUFFS
	_puff_instance = MultiMeshInstance3D.new()
	_puff_instance.name = "JetPuffs"
	_puff_instance.top_level = true
	_puff_instance.multimesh = _puff_multimesh
	_puff_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_puff_instance)
	for i in PUFFS:
		_puffs.append(Puff.new())
		_puff_multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * 0.0001), Vector3.ZERO))
	# Coins shaken out of the chest, in world space too; purely visual.
	_spill_multimesh = MultiMesh.new()
	_spill_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_spill_multimesh.mesh = _coin_multimesh.mesh
	_spill_multimesh.instance_count = SPILL_COINS
	_spill_instance = MultiMeshInstance3D.new()
	_spill_instance.name = "SpilledCoins"
	_spill_instance.top_level = true
	_spill_instance.multimesh = _spill_multimesh
	_spill_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_spill_instance)
	for i in SPILL_COINS:
		_spills.append(Spill.new())
		_spill_multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * 0.0001), Vector3.ZERO))
	# The dust of a fast-drop landing, in world space too.
	_poof = LandingPoof.new()
	_poof.name = "LandingPoof"
	add_child(_poof)
	# The web build draws no sun shadows: soft blobs under the shoes and chest.
	if OS.has_feature("web"):
		var disc := Parts.blob(m)
		for i in 3:
			var blob := _mesh(self, "BlobShadow", disc, false)
			blob.top_level = true
			_blobs.append(blob)


func _mesh(parent: Node3D, node_name: String, mesh: Mesh, shadow: bool) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
	return instance


# --- The tick.

func _physics_process(delta: float) -> void:
	if _player == null or delta <= 0.0:
		return
	if not is_visible_in_tree():
		_reset_pending = true
		return
	_space = get_world_3d().direct_space_state
	if not _poof_warmed:
		_poof_warmed = true
		# Compile the dust's shader behind the start-up screen, not at the first landing.
		if DisplayServer.get_name() != "headless":
			_poof.warm_up(global_position)
	if _ground_stale and _world != null:
		_ground_stale = false
		_visible_ground.build([_world.ground_and_areas, _world.roads_and_paths])
	var xf := global_transform
	var origin := _player.global_position
	var active := _player.is_physics_processing()
	var velocity := _player.get_real_velocity() if active else Vector3.ZERO
	if _reset_pending or origin.distance_to(_last_position) > 1.0 + velocity.length() * delta * 4.0:
		_reset(xf)
	_last_position = origin
	_time += delta
	var on_floor := _player.is_on_floor()
	var thrust := active and _player.is_processing_unhandled_input() and Input.is_action_pressed("jetpack")
	var dropping := active and _player.is_processing_unhandled_input() and Input.is_action_pressed("fast_drop") and not Input.is_action_pressed("jetpack")

	# Smoothed velocity and its acceleration, world frame.
	var previous := _velocity
	_velocity = _velocity.lerp(velocity, 1.0 - exp(-delta / 0.03))
	_acceleration = ((_velocity - previous) / delta).limit_length(90.0)
	var planar := Vector3(_velocity.x, 0.0, _velocity.z)
	var speed := planar.length()
	var basis_inv := xf.basis.orthonormalized().inverse()
	var local_acc := basis_inv * _acceleration
	var local_vel := basis_inv * _velocity
	var yaw := atan2(xf.basis.z.x, xf.basis.z.z)
	var yaw_rate := wrapf(yaw - _last_yaw, -PI, PI) / delta
	_last_yaw = yaw

	# Ground or air.
	_air_time = 0.0 if on_floor else _air_time + delta
	if not on_floor:
		_fall_speed = maxf(0.0, -velocity.y)
	if _airborne and on_floor:
		_airborne = false
		_land(xf, _fall_speed, yaw)
		if dropping and _fall_speed >= POOF_SPEED_SHARE * _fast_drop_speed():
			_poof.burst(_ground(xf.origin, xf.origin.y), _ground_capture())
	elif not _airborne and not on_floor and (thrust or velocity.y > 1.0 or _air_time > AIR_GRACE):
		_airborne = true
		_take_off(xf, thrust)
	var rising := thrust or velocity.y > 1.0
	_w_move = _approach(_w_move, 0.0 if _airborne else clampf((speed - STAND_SPEED) / 0.8, 0.0, 1.0), delta, 0.1)
	_w_run = _approach(_w_run, smoothstep(5.0, 14.0, speed), delta, 0.15)
	_w_air = _approach(_w_air, 1.0 if _airborne else 0.0, delta, 0.1)
	_w_rise = _approach(_w_rise, 1.0 if rising else 0.0, delta, 0.15)

	# The visible ground under the chest, so it stands on a road or path drawn
	# above the land rather than in it.
	var under := _ground(origin, origin.y)
	_under = under if _hit else Vector3(origin.x, -INF, origin.z)
	_lift = _approach(_lift, clampf(under.y - origin.y, 0.0, 0.12) if _hit and absf(under.y - origin.y) < 0.3 else 0.0, delta, 0.06)
	var bob_accel := _update_gait(xf, planar, speed, yaw, delta)
	_update_body(speed, local_acc, yaw_rate, delta)
	var lid_drive_y := local_acc.y + LID_BOB_COUPLING * bob_accel + _squash_accel * (0.45 + Parts.BODY_H)
	_update_lid(lid_drive_y, local_acc.z, local_vel, thrust, delta)
	_update_coins(local_acc.y + COIN_BOB_COUPLING * bob_accel + _squash_accel * (0.45 + Parts.GOLD_BASE), delta)
	var body_xf := _body.transform
	for arm in _arms:
		_update_arm(arm, body_xf, local_acc, delta)
	var inv := xf.affine_inverse()
	for leg in _legs:
		_update_leg(leg, body_xf, inv, yaw, local_acc, delta)
	_update_eyes(delta)
	_update_jet(thrust, delta)
	_update_spills(delta)
	_update_blobs(xf)


static func _approach(value: float, target: float, delta: float, tau: float) -> float:
	return lerpf(value, target, 1.0 - exp(-delta / tau))


# --- Gait: planted feet, swings to predicted landing spots, standing still.

func _rest_foot(xf: Transform3D, leg: Leg) -> Vector3:
	return xf * Vector3(leg.side * FOOT_SPREAD, 0.0, FOOT_FORWARD)


func _ground(point: Vector3, reference_y: float) -> Vector3:
	return _ground_between(point.x, point.z, reference_y + 0.65, reference_y - 0.9, reference_y)


## The visible ground under (x, z) between two heights, or (x, fallback_y, z)
## with _hit false. A land hit takes the lift of any road, path or area drawn
## over it; other solids (kerbs, stairs, props) are their own visible surface.
func _ground_between(x: float, z: float, top: float, bottom: float, fallback_y: float) -> Vector3:
	_ray.from = Vector3(x, top, z)
	_ray.to = Vector3(x, bottom, z)
	var hit := _space.intersect_ray(_ray)
	_hit = not hit.is_empty()
	if not _hit:
		_hit_normal = Vector3.UP
		return Vector3(x, fallback_y, z)
	_hit_normal = hit.normal
	var position: Vector3 = hit.position
	var collider := hit.get("collider") as Node
	if collider != null and collider.get_parent() != null and str(collider.get_parent().get_meta("feature_kind", "")) == "land_ground":
		position.y += _visible_ground.lift_at(position.x, position.z)
	return position


func _needs_settle(xf: Transform3D) -> bool:
	for leg in _legs:
		if leg.swinging:
			return true
		var rest := _rest_foot(xf, leg)
		if Vector2(leg.foot.x - rest.x, leg.foot.z - rest.z).length() > SETTLE_DISTANCE or absf(leg.foot.y - xf.origin.y) > 0.3:
			return true
	return false


## Advances the gait; returns the bob's vertical acceleration (for the lid).
func _update_gait(xf: Transform3D, planar: Vector3, speed: float, yaw: float, delta: float) -> float:
	if _airborne:
		return 0.0
	var moving := speed > STAND_SPEED
	if not moving and not _needs_settle(xf):
		return 0.0
	var walk := 1.0 - smoothstep(WALK_SPEED, RUN_CADENCE_SPEED, speed)
	var run_cadence := minf(1.6 + 1.25 * sqrt(speed), CADENCE_MAX)
	_cadence = lerpf(run_cadence, WALK_CADENCE * pow(speed / WALK_SPEED, 0.45), walk) if moving else 2.8
	_duty = lerpf(lerpf(0.58, 0.28, _w_run), WALK_DUTY, walk)
	_phase = fposmod(_phase + _cadence * delta, 1.0)
	var swing_height := clampf(0.07 + 0.012 * speed, 0.08, 0.24)
	var stance_time := _duty / _cadence
	for leg in _legs:
		var p := fposmod(_phase + leg.phase_offset, 1.0)
		var in_stance := p < _duty
		if in_stance and leg.swinging:
			leg.swinging = false
			leg.foot = leg.target
			leg.normal = leg.target_normal
			leg.yaw = yaw + leg.side * FOOT_TOE_OUT
			_footstep(speed)
		elif not in_stance and not leg.swinging:
			leg.swinging = true
			leg.lift = leg.foot
			leg.lift_yaw = leg.yaw
		if not leg.swinging:
			continue
		var u := clampf((p - _duty) / (1.0 - _duty), 0.0, 1.0)
		var remaining := (1.0 - u) * (1.0 - _duty) / _cadence
		var aim := _rest_foot(xf, leg) + (planar * (remaining + stance_time * 0.5) if moving else Vector3.ZERO)
		leg.target = _ground(aim, xf.origin.y)
		leg.target_normal = _hit_normal
		var ease := u * u * (3.0 - 2.0 * u)
		var rise := leg.target.y - leg.lift.y
		# Step up quickly and down late, so the toe clears a stair's nosing.
		var vertical := (1.0 - pow(1.0 - u, 2.0)) if rise > 0.0 else u * u
		var step := Vector2(leg.target.x - leg.lift.x, leg.target.z - leg.lift.z).length()
		leg.current = leg.lift.lerp(leg.target, ease)
		leg.current.y = lerpf(leg.lift.y, leg.target.y, vertical) + sin(PI * u) * swing_height * clampf(step / 0.2, 0.0, 1.0)
		leg.current_yaw = lerp_angle(leg.lift_yaw, yaw + leg.side * FOOT_TOE_OUT, ease)
		leg.pitch = -0.6 * sin(PI * u) * (1.0 - 2.0 * u) * clampf(step / 0.3, 0.0, 1.2)
	# The bob: lowest at each touchdown when walking, mid-stance when running.
	var amplitude := (0.03 * (1.0 - _w_run) + 0.022 * _w_run) * _w_move
	var angle := 4.0 * PI * (_phase - _duty * 0.5 * _w_run)
	return amplitude * 0.5 * pow(4.0 * PI * _cadence, 2.0) * cos(angle)


func _footstep(speed: float) -> void:
	var strength := clampf((speed - 1.0) / 10.0, 0.12, 1.3)
	_lid_speed += LID_STEP_KICK * strength
	if speed > SPILL_SPEED and _rng.randf() < SPILL_CHANCE:
		_spill(1, false)
	if speed > 6.0:
		for coin in _coins:
			if coin.height <= 0.0 and _rng.randf() < 0.5:
				coin.speed += _rng.randf_range(0.2, 0.55) * strength
				coin.spin_speed = _rng.randf_range(-14.0, 14.0)


func _land(xf: Transform3D, fall_speed: float, yaw: float) -> void:
	var impact := clampf(fall_speed / 1.5, 0.2, 1.4)
	_squash_speed -= LANDING_SQUASH * impact
	if impact > 0.7:
		_spill(3, true)
	_squint = maxf(_squint, 0.8 * impact)
	for leg in _legs:
		var world := xf * leg.air
		leg.foot = _ground(world, xf.origin.y)
		leg.normal = _hit_normal
		leg.current = leg.foot
		leg.yaw = yaw + leg.side * FOOT_TOE_OUT
		leg.current_yaw = leg.yaw
		leg.swinging = false
		leg.pitch = 0.0
	# Both feet down: inside the gait's double-support window.
	_phase = 0.02
	for coin in _coins:
		coin.spin_speed = _rng.randf_range(-10.0, 10.0)


## The stock controller's fast-drop speed (m/s); without one nothing is a fast drop.
func _fast_drop_speed() -> float:
	return (_player as PlayerController).fast_drop_speed_mps if _player is PlayerController else INF


## The grass's ground captures, for the dust's colour, or {} where none are drawn
## (the web's Compatibility renderer, headless runs, the dressing off).
func _ground_capture() -> Dictionary:
	var main := _player.get_parent()
	if main == null:
		return {}
	var dressing := main.get_node_or_null("GroundDressing") as GroundDressing
	return dressing.ground_capture() if dressing != null else {}


func _take_off(xf: Transform3D, thrust: bool) -> void:
	if thrust:
		_spill(2, false)
	var inv := xf.affine_inverse()
	for leg in _legs:
		leg.air = inv * leg.current
		leg.air_velocity = Vector3.ZERO
		leg.swinging = false
	_squash_speed += 0.9


func _reset(xf: Transform3D) -> void:
	_reset_pending = false
	_space = get_world_3d().direct_space_state
	var yaw := atan2(xf.basis.z.x, xf.basis.z.z)
	_last_yaw = yaw
	_velocity = Vector3.ZERO
	_acceleration = Vector3.ZERO
	_airborne = not _player.is_on_floor()
	_air_time = 0.0
	_phase = 0.02
	_w_move = 0.0
	_w_air = 1.0 if _airborne else 0.0
	_squash = 0.0
	_squash_speed = 0.0
	_lid_angle = LID_REST
	_lid_speed = 0.0
	_lid_accel = Vector2.ZERO
	for leg in _legs:
		leg.foot = _ground(_rest_foot(xf, leg), xf.origin.y)
		leg.normal = _hit_normal
		leg.current = leg.foot
		leg.yaw = yaw + leg.side * FOOT_TOE_OUT
		leg.current_yaw = leg.yaw
		leg.swinging = false
		leg.pitch = 0.0
		leg.air = Vector3(leg.side * FOOT_SPREAD, 0.12, FOOT_FORWARD)
		leg.air_velocity = Vector3.ZERO
	for arm in _arms:
		arm.offset = Vector3.ZERO
		arm.offset_velocity = Vector3.ZERO
		arm.trail = Vector3.ZERO
		arm.hand = Vector3.ZERO
	for coin in _coins:
		coin.height = 0.0
		coin.speed = 0.0
		coin.spin = 0.0
		coin.moved = true
	for coin in _spills:
		coin.age = SPILL_LIFE


# --- Body: bob, breathing, lean, sway and squash.

func _update_body(speed: float, local_acc: Vector3, yaw_rate: float, delta: float) -> void:
	var k := pow(TAU * SQUASH_FREQUENCY, 2.0)
	var c := 2.0 * SQUASH_DAMPING * TAU * SQUASH_FREQUENCY
	var stretch := 0.05 * _w_rise * _w_air
	_squash_accel = -k * (_squash - stretch) - c * _squash_speed
	_squash_speed += _squash_accel * delta
	_squash = clampf(_squash + _squash_speed * delta, -0.32, 0.25)
	var amplitude := (0.03 * (1.0 - _w_run) + 0.022 * _w_run) * _w_move
	var bob := amplitude * 0.5 * (1.0 - cos(4.0 * PI * (_phase - _duty * 0.5 * _w_run)))
	var breathe := sin(_time * TAU * 0.9) * 0.012 * (1.0 - _w_move) * (1.0 - _w_air)
	var hover := sin(_time * TAU * 1.3) * 0.02 * _w_air
	var height := Parts.HIP_HEIGHT + _lift + bob + breathe + hover + _squash * 0.45 - 0.09 * _w_run * _w_move
	# Lean forward with speed and acceleration, back while rising; roll into
	# turns and sway over the stance foot.
	var lean_target := (0.009 * speed + 0.006 * local_acc.z) * (1.0 - _w_air) - 0.12 * _w_rise * _w_air + 0.08 * (1.0 - _w_rise) * _w_air
	var sway := -0.05 * sin(TAU * _phase) * _w_move * (1.0 - _w_run * 0.6)
	var roll_target := clampf(-yaw_rate * speed * 0.02, -0.3, 0.3) + sway + sin(_time * TAU * 0.7) * 0.05 * _w_air
	_lean = _approach(_lean, clampf(lean_target, -0.35, 0.45), delta, 0.08)
	_roll = _approach(_roll, roll_target, delta, 0.06)
	var stretch_y := 1.0 + _squash
	var stretch_xz := 1.0 / sqrt(stretch_y)
	_body.transform = Transform3D(Basis.from_euler(Vector3(_lean, 0.0, _roll)) * Basis.from_scale(Vector3(stretch_xz, stretch_y, stretch_xz)), Vector3(0.0, height, 0.0))


# --- Lid: a sprung hinge in the chest's accelerating frame.

func _update_lid(accel_up: float, accel_forward: float, local_vel: Vector3, thrust: bool, delta: float) -> void:
	var drive := Vector2(clampf(accel_up, -LID_ACCEL_LIMIT, LID_ACCEL_LIMIT), clampf(accel_forward, -LID_ACCEL_LIMIT, LID_ACCEL_LIMIT))
	_lid_accel = _lid_accel.lerp(drive, 1.0 - exp(-delta / LID_ACCEL_TAU))
	var flutter := sin(_time * 7.13 + 1.0) * sin(_time * 3.71 + 2.0)
	var air := LID_AIR_FORWARD * pow(maxf(local_vel.z, 0.0), 2.0) + LID_AIR_FALL * pow(maxf(-local_vel.y, 0.0), 2.0) * (1.0 + 0.45 * flutter)
	# Standing still, the lid lifts a little with each breath.
	var breath := 0.035 * (0.5 + 0.5 * sin(_time * TAU * 0.9 - 0.8)) * (1.0 - _w_move) * (1.0 - _w_air)
	var target := LID_REST + breath + minf(air, LID_AIR_MAX)
	if thrust:
		_rattle_timer -= delta
		if _rattle_timer <= 0.0:
			_rattle_timer += 1.0 / 12.0
			_lid_speed += LID_RATTLE * _rng.randf_range(0.3, 1.0)
	var k := pow(TAU * LID_FREQUENCY, 2.0)
	var c := 2.0 * LID_DAMPING * TAU * LID_FREQUENCY
	var h := delta / float(LID_SUBSTEPS)
	for _i in LID_SUBSTEPS:
		var alpha := -k * (_lid_angle - target) - c * _lid_speed - LID_GAIN_UP * _lid_accel.x + LID_GAIN_FORWARD * _lid_accel.y
		if _lid_angle > LID_OPEN_MAX:
			alpha += -1200.0 * (_lid_angle - LID_OPEN_MAX) - 40.0 * _lid_speed
		_lid_speed = clampf(_lid_speed + alpha * h, -30.0, 30.0)
		_lid_angle += _lid_speed * h
		if _lid_angle < 0.0:
			_lid_angle = 0.0
			if _lid_speed < -LID_STICK:
				var impact := -_lid_speed
				_lid_speed = impact * LID_RESTITUTION
				if impact > 3.0:
					_squint = maxf(_squint, 0.45)
					_jingle(impact * 0.05)
			else:
				_lid_speed = 0.0
	_lid.rotation = Vector3(-_lid_angle, 0.0, 0.0)
	# The eyes stay seated on the lid's outer face, sliding up its arch to the
	# raised front edge as it opens; the shader is told where they sit.
	var arch := lerpf(_eye_arch_rest, Parts.EYE_ARCH_OPEN, smoothstep(EYE_SLIDE_FROM, EYE_SLIDE_TO, _lid_angle))
	var mount := Parts.lid_arch_frame(arch) * _eye_seat
	_eye_mount.transform = mount
	_materials.eye.set_shader_parameter("mount_origin", mount.origin)
	_materials.eye.set_shader_parameter("mount_angle", atan2(mount.basis.y.z, mount.basis.y.y))


# --- Coins: hop in the chest's frame, tumble in the air, stay under the lid.

func _jingle(strength: float) -> void:
	for coin in _coins:
		if _rng.randf() < 0.6:
			coin.speed += _rng.randf_range(0.3, 1.0) * strength
			coin.spin_speed = _rng.randf_range(-12.0, 12.0)


func _update_coins(accel_up: float, delta: float) -> void:
	# Gravity plus the inertial push of the chest's own vertical acceleration.
	var relative := -9.8 - clampf(accel_up, -80.0, 80.0)
	for i in _coins.size():
		var coin := _coins[i]
		var z := coin.rest.origin.z
		var room := Parts.BODY_H + Parts.LID_LIP + (Parts.LID_ARCH - Parts.WALL) * sqrt(maxf(0.0, 1.0 - pow(z / (Parts.LID_D * 0.5 - Parts.WALL), 2.0)))
		room += _lid_angle * (z - Parts.HINGE.z) - coin.rest.origin.y - 0.02 - Parts.COIN_RADIUS * absf(sin(coin.spin))
		if coin.height <= 0.0 and coin.speed <= 0.0 and relative <= 0.0:
			if absf(coin.spin) > 0.001:
				coin.spin = lerpf(coin.spin, roundf(coin.spin / PI) * PI, 1.0 - exp(-delta / 0.05))
				coin.moved = true
		else:
			coin.speed += relative * delta
			coin.height += coin.speed * delta
			coin.spin += coin.spin_speed * delta
			if coin.height <= 0.0:
				coin.height = 0.0
				coin.speed = -coin.speed * 0.3 if coin.speed < -0.5 else 0.0
				coin.spin_speed *= 0.5
			elif coin.height > room:
				coin.height = maxf(room, 0.0)
				coin.speed = minf(coin.speed, 0.0)
			coin.moved = true
		if coin.moved:
			coin.moved = absf(coin.spin) > 0.001 or coin.height > 0.0
			var lift := Transform3D(Basis(coin.axis, coin.spin), Vector3.UP * coin.height)
			_coin_multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, coin.rest.origin) * lift * Transform3D(coin.rest.basis, Vector3.ZERO))


# --- Arms: swing, flail or float; damped springs; noodle hoses.

func _update_arm(arm: Arm, body_xf: Transform3D, local_acc: Vector3, delta: float) -> void:
	var out := body_xf.basis.x.normalized() * arm.side
	var up := body_xf.basis.y.normalized()
	var fwd := body_xf.basis.z.normalized()
	var shoulder := body_xf * Vector3(arm.side * Parts.SHOULDER.x, Parts.SHOULDER.y, Parts.SHOULDER.z)
	# Walking and running: the arm swings against the same side's leg.
	var swing := -cos(TAU * _phase) * arm.side * lerpf(0.75, 1.15, _w_run) * _w_move
	swing += sin(_time * 1.3 + arm.side) * 0.08 * (1.0 - _w_move)
	var reach := lerpf(0.40, 0.32, _w_run * _w_move)
	var ground_pose := out * lerpf(0.05, 0.12, _w_run) - up * (cos(swing) * reach) + fwd * (sin(swing) * reach) + up * 0.07 * _w_run * _w_move
	# Rising: flailing up and out. Descending: floating out to the sides.
	var t := _time
	var rise_pose := out * (0.30 + 0.06 * sin(t * 9.0 + arm.side)) + up * (0.20 + 0.12 * sin(t * 19.0 + arm.side * 1.7)) + fwd * (0.10 * cos(t * 13.0 + arm.side))
	var fall_pose := out * 0.37 + up * (0.03 + 0.07 * sin(t * 6.5 + arm.side * 0.8)) + fwd * 0.05
	var pose := ground_pose.lerp(fall_pose.lerp(rise_pose, _w_rise), _w_air)
	# The hand lags behind the chest's accelerations on a damped spring.
	var k := pow(TAU * ARM_FREQUENCY, 2.0)
	var c := 2.0 * ARM_DAMPING * TAU * ARM_FREQUENCY
	arm.offset_velocity += (-k * arm.offset - c * arm.offset_velocity - local_acc * k * ARM_INERTIA) * delta
	arm.offset = (arm.offset + arm.offset_velocity * delta).limit_length(0.22)
	var hand := shoulder + pose + arm.offset
	if arm.hand != Vector3.ZERO:
		arm.trail = arm.trail.lerp((hand - arm.hand) / delta, 1.0 - exp(-delta / 0.08))
	arm.hand = hand
	# The hose leaves the shoulder outwards, then bends to arrive along the
	# hand's direction, trailing behind the hand's motion.
	var p0 := shoulder - out * 0.03
	var slack := maxf(0.0, Parts.ARM_LENGTH - p0.distance_to(hand))
	var lam := 0.10 + slack * 0.6
	var p1 := p0 + (out * 0.8 - up * 0.6).normalized() * lam
	var arrive := (hand - (shoulder + out * 0.12)).normalized()
	var p2 := hand - arrive * lam - (arm.trail * 0.03).limit_length(0.12)
	_bend(arm.material, p0, p1, p2, hand, fwd)
	# The glove continues the hose; its palm faces the chest.
	var y_axis := -(hand - p2).normalized()
	var x_axis := body_xf.basis.x.normalized()
	if absf(x_axis.dot(y_axis)) > 0.95:
		x_axis = y_axis.cross(fwd).normalized()
	x_axis = (x_axis - y_axis * x_axis.dot(y_axis)).normalized()
	arm.glove.transform = Transform3D(Basis(x_axis, y_axis, x_axis.cross(y_axis)), hand)


# --- Legs: planted or dangling feet, shoes, knee-less hoses.

func _update_leg(leg: Leg, body_xf: Transform3D, inv: Transform3D, yaw: float, local_acc: Vector3, delta: float) -> void:
	var hip := body_xf * Vector3(leg.side * Parts.HIP.x, Parts.HIP.y + 0.02, Parts.HIP.z)
	var foot_xf: Transform3D
	if _airborne:
		var t := _time
		var kick := TAU * 2.2 * t + (0.0 if leg.side > 0.0 else PI)
		var rest := Vector3(leg.side * (Parts.HIP.x + 0.03), 0.0, 0.03)
		var rise_pose := rest + Vector3(0.0, hip.y - 0.47 + 0.07 * sin(kick), 0.06 + 0.10 * cos(kick))
		var fall_pose := rest + Vector3(0.0, hip.y - 0.50 + 0.02 * sin(t * 4.0 + leg.side), 0.02 + 0.04 * sin(t * TAU * 0.8 + leg.side))
		var target := fall_pose.lerp(rise_pose, _w_rise)
		# Reach for the ground just before landing.
		var below := _ground(global_transform * Vector3(rest.x, 0.0, rest.z), global_position.y)
		var gap := global_position.y - below.y if _hit else 99.0
		target.y = lerpf(target.y, -gap, smoothstep(0.5, 0.05, gap) * (1.0 - _w_rise))
		var k := pow(TAU * LEG_FREQUENCY, 2.0)
		var c := 2.0 * LEG_DAMPING * TAU * LEG_FREQUENCY
		leg.air_velocity += (-k * (leg.air - target) - c * leg.air_velocity - local_acc * k * LEG_INERTIA) * delta
		leg.air += leg.air_velocity * delta
		leg.current = global_transform * leg.air
		var toe := -0.45 + 0.25 * sin(kick) * _w_rise
		foot_xf = Transform3D(Basis(Vector3.UP, leg.side * FOOT_TOE_OUT) * Basis(Vector3.RIGHT, -toe), leg.air)
	else:
		if not leg.swinging:
			leg.current = leg.foot
			leg.current_yaw = leg.yaw
			leg.pitch = 0.0
		var local := inv * leg.current
		var normal := (inv.basis * (leg.normal if not leg.swinging else leg.target_normal.lerp(Vector3.UP, 0.5))).normalized()
		var tilt := Basis(Quaternion(Vector3.UP, normal)) if normal.dot(Vector3.UP) < 0.9999 else Basis.IDENTITY
		foot_xf = Transform3D(tilt * Basis(Vector3.UP, wrapf(leg.current_yaw - yaw, -PI, PI)) * Basis(Vector3.RIGHT, -leg.pitch), local)
	leg.shoe.transform = foot_xf
	var ankle := foot_xf * Parts.ANKLE
	var reach := hip.distance_to(ankle)
	var slack := maxf(0.0, Parts.LEG_LENGTH - reach)
	# Stretched past its length (a long running stride) the hose still bows.
	var stretch := maxf(0.0, reach - Parts.LEG_LENGTH)
	# Rubber-hose legs bow outwards and forwards, more as they compress.
	var forward := foot_xf.basis.z
	forward.y = 0.0
	forward = forward.normalized() if forward.length_squared() > 0.001 else body_xf.basis.z.normalized()
	var knee := (forward * 0.6 + body_xf.basis.x.normalized() * leg.side * 0.8).normalized()
	var lam := 0.09 + slack * 0.45 + stretch * 0.25
	var bow := 0.035 + slack * 0.9 + stretch * 0.35
	var p1 := hip - body_xf.basis.y.normalized() * lam + knee * bow
	var p2 := ankle + foot_xf.basis.y.normalized() * lam + knee * bow
	_bend(leg.material, hip, p1, p2, ankle, body_xf.basis.x.normalized())


## Sets a hose's Bezier. Its seam frame uses the normal of the curve's own
## plane, which no tangent of a (near) planar curve can run along.
static func _bend(material: ShaderMaterial, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, fallback: Vector3) -> void:
	var plane := (p3 - p0).cross((p1 - p0) + (p2 - p0))
	if plane.length_squared() < 1e-8:
		plane = (p3 - p0).cross(fallback)
	if plane.length_squared() < 1e-8:
		plane = fallback
	material.set_shader_parameter("p0", p0)
	material.set_shader_parameter("p1", p1)
	material.set_shader_parameter("p2", p2)
	material.set_shader_parameter("p3", p3)
	material.set_shader_parameter("bend_normal", plane.normalized())


# --- Eyes: blinking and looking at the camera.

func _update_eyes(delta: float) -> void:
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_blink_time = 0.0
		_double_blink = _rng.randf() < 0.25
		_blink_timer = _rng.randf_range(1.8, 4.6)
	var blink := 0.0
	if _blink_time >= 0.0:
		_blink_time += delta
		var length := 0.34 if _double_blink else 0.16
		var t := fposmod(_blink_time, 0.17) if _double_blink else _blink_time
		blink = clampf(1.0 - absf(t - 0.06) / 0.07, 0.0, 1.0)
		if _blink_time > length:
			_blink_time = -1.0
	_squint = _approach(_squint, 0.0, delta, 0.2)
	blink = maxf(blink, _squint * 0.75)
	var look := Vector2(0.0, -0.08)
	var camera := get_viewport().get_camera_3d()
	if camera != null:
		var to_camera := (_eye_mount.global_transform.affine_inverse() * camera.global_position).normalized()
		var facing := smoothstep(-0.1, 0.4, to_camera.z)
		look = look.lerp(Vector2(to_camera.x, to_camera.y + 0.25) * 0.55, facing)
	look.y += (0.3 * _w_rise - 0.25 * (1.0 - _w_rise)) * _w_air
	_look = _look.lerp(look.limit_length(0.5), 1.0 - exp(-delta / 0.06))
	_materials.eye.set_shader_parameter("look", _look)
	_materials.eye.set_shader_parameter("blink", blink)


# --- Spilled coins: shaken out of the lid gap, they bounce and shrink away.

## Throws `count` coins out of the lid gap: from a run or a jet lift-off they
## fly up and drop behind; from a landing they pop up and out of the front.
func _spill(count: int, landing: bool) -> void:
	var body := _body.global_transform
	var forward := global_transform.basis.z.normalized()
	var across := global_transform.basis.x.normalized()
	for _i in count:
		var coin: Spill = null
		for candidate in _spills:
			if candidate.age >= SPILL_LIFE:
				coin = candidate
				break
		if coin == null:
			return
		coin.position = body * Vector3(_rng.randf_range(-0.24, 0.24), Parts.BODY_H + 0.05, _rng.randf_range(0.02, 0.2))
		var sideways := across * _rng.randf_range(-0.9, 0.9)
		if landing:
			coin.velocity = _velocity * 0.3 + forward * _rng.randf_range(0.6, 1.4) + sideways + Vector3.UP * _rng.randf_range(2.6, 3.6)
		else:
			coin.velocity = _velocity * _rng.randf_range(0.35, 0.6) - forward * _rng.randf_range(0.5, 1.5) + sideways + Vector3.UP * _rng.randf_range(2.0, 3.0)
		coin.axis = Vector3(_rng.randf_range(-1.0, 1.0), 0.0, _rng.randf_range(-1.0, 1.0)).normalized()
		coin.spin = _rng.randf_range(0.0, TAU)
		coin.spin_speed = _rng.randf_range(12.0, 24.0) * (1.0 if _rng.randf() < 0.5 else -1.0)
		coin.age = 0.0
		coin.bounces = 0
		coin.ground_xz = Vector2(INF, INF)


func _update_spills(delta: float) -> void:
	var box := AABB(global_position, Vector3.ZERO)
	var active := false
	for i in _spills.size():
		var coin := _spills[i]
		if coin.age >= SPILL_LIFE:
			continue
		coin.age += delta
		coin.velocity.y -= 9.8 * delta
		coin.position += coin.velocity * delta
		# Find the ground under the coin again once it has moved on.
		if Vector2(coin.position.x, coin.position.z).distance_to(coin.ground_xz) > 0.6:
			coin.ground_xz = Vector2(coin.position.x, coin.position.z)
			var below := _ground_between(coin.position.x, coin.position.z, coin.position.y + 0.4, coin.position.y - 6.0, -INF)
			coin.ground = below.y if _hit else -INF
		var rest_y := coin.ground + Parts.COIN_RADIUS * 0.4
		if coin.position.y < rest_y and coin.velocity.y < 0.0:
			coin.position.y = rest_y
			if coin.bounces < 2 and coin.velocity.y < -1.0:
				coin.bounces += 1
				coin.velocity = Vector3(coin.velocity.x * 0.55, -coin.velocity.y * 0.45, coin.velocity.z * 0.55)
				coin.spin_speed *= 0.6
			else:
				# Down for good: slide to a stop and settle flat.
				coin.velocity = Vector3(coin.velocity.x * 0.8, 0.0, coin.velocity.z * 0.8)
				coin.spin_speed = 0.0
				coin.spin = lerpf(coin.spin, roundf(coin.spin / PI) * PI, 0.3)
		coin.spin += coin.spin_speed * delta
		var size := SPILL_SCALE * (1.0 - smoothstep(SPILL_LIFE - 0.45, SPILL_LIFE, coin.age))
		if coin.age >= SPILL_LIFE:
			size = 0.0001
		else:
			active = true
			box = box.expand(coin.position)
		_spill_multimesh.set_instance_transform(i, Transform3D(Basis(coin.axis, coin.spin).scaled(Vector3.ONE * size), coin.position))
	_spill_instance.custom_aabb = box.grow(0.5) if active else AABB(global_position - Vector3.ONE, Vector3.ONE * 2.0)


# --- Web build only: blob shadows on the visible ground.

## Soft discs under each shoe and under the chest, shrinking as they rise.
func _update_blobs(xf: Transform3D) -> void:
	if _blobs.is_empty():
		return
	var yaw := atan2(xf.basis.z.x, xf.basis.z.z)
	for i in 2:
		var leg := _legs[i]
		var ground_y := leg.current.y
		if _airborne or leg.swinging:
			ground_y = _ground(leg.current, global_position.y).y
			if not _hit:
				ground_y = -INF
		var size := clampf(1.0 - (leg.current.y - ground_y) * 2.5, 0.0, 1.0)
		var at := Vector3(leg.current.x, ground_y + 0.012, leg.current.z)
		_blobs[i].visible = size > 0.02
		if _blobs[i].visible:
			_blobs[i].global_transform = Transform3D(Basis(Vector3.UP, leg.current_yaw) * Basis.from_scale(Vector3(0.12, 1.0, 0.2) * size), at)
	var body_size := clampf(1.0 - (global_position.y - _under.y) * 0.6, 0.0, 1.0)
	_blobs[2].visible = body_size > 0.02
	if _blobs[2].visible:
		_blobs[2].global_transform = Transform3D(Basis(Vector3.UP, yaw) * Basis.from_scale(Vector3(0.48, 1.0, 0.36) * body_size), Vector3(_under.x, _under.y + 0.01, _under.z))


# --- Jet: flames while thrusting, cartoon smoke puffs left behind.

func _update_jet(thrust: bool, delta: float) -> void:
	_flame = _approach(_flame, 1.0 if thrust else 0.0, delta, 0.04 if thrust else 0.07)
	_materials.flame.set_shader_parameter("intensity", _flame if _flame > 0.01 else 0.0)
	if thrust:
		_puff_timer -= delta
		while _puff_timer <= 0.0:
			_puff_timer += 0.055
			_spawn_puff()
	var active := false
	var box := AABB(global_position, Vector3.ZERO)
	for i in _puffs.size():
		var puff := _puffs[i]
		if puff.age >= PUFF_LIFE:
			continue
		puff.age += delta
		puff.velocity *= exp(-delta * 2.5)
		puff.position += puff.velocity * delta
		var life := puff.age / PUFF_LIFE
		var size := puff.size * (smoothstep(0.0, 0.2, life) * (1.0 - smoothstep(0.55, 1.0, life)) + 0.0001)
		if puff.age >= PUFF_LIFE:
			size = 0.0001
		else:
			active = true
		_puff_multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * size), puff.position))
		box = box.expand(puff.position)
	_puff_instance.custom_aabb = box.grow(0.3) if active else AABB(global_position - Vector3.ONE, Vector3.ONE * 2.0)


func _spawn_puff() -> void:
	var puff: Puff = null
	for candidate in _puffs:
		if candidate.age >= PUFF_LIFE:
			puff = candidate
			break
	if puff == null:
		return
	_puff_side = -_puff_side
	puff.position = _body.global_transform * Vector3(_puff_side * Parts.NOZZLE.x, Parts.NOZZLE.y - 0.12, Parts.NOZZLE.z)
	puff.velocity = Vector3(_rng.randf_range(-0.4, 0.4), -2.2, _rng.randf_range(-0.4, 0.4)) + _velocity * 0.15
	puff.age = 0.0
	puff.size = _rng.randf_range(0.07, 0.12)
