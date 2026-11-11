class_name SoccerBall
extends RigidBody3D
## The football on the synthetic-turf pitch: the street-detail furniture row of prop
## soccer_ball, which tools/lib/street-furniture-generation.mjs stands on the full-size
## pitch's centre spot (the soccer_pitch zone's centre_spot rule). A size-5 ball
## (0.22 m, 0.43 kg): it bounces off the land, walls and street props, and rolling
## resistance and air drag bring it to rest on the turf.
##
## A CharacterBody3D does not push rigid bodies, and the stock player does not collide
## with the ball at all (the ball is on the loose-prop layer, outside the player's
## mask). Instead, when a character's capsule reaches the ball, the ball takes an
## impulse along the contact from the character's velocity: a walk keeps it rolling
## just ahead, a run sends it off. Bodies that move through physics (cars, later)
## push it as bodies on a layer in its mask.
##
## Off the playable outline (on the riprap or in the bay) or fallen through the
## ground, it goes back to its centre spot; a new game starts it there.
##
## A goal (owner, 2026-11-11): the ball wholly over a goal's line, having come in
## through its mouth (between the uprights' inner faces, under the crossbar where a
## net hangs, anywhere up the rugby H's uprights), sets off a burst of confetti at
## that goal (goal_confetti.gd) and GOAL_RESET_S later goes back to its spot, at
## rest. Every goal on the island counts, whatever sent the ball in (a kick, a car,
## a roll); a ball that touches a post from outside, or passes beside the goal,
## does not. The goals are the street furniture's goal rows, with their mouths
## (street_furniture_builder.gd hands them over from street_furniture_kit.gd).

signal scored(goal_id: String)

const PROP := "soccer_ball"
const GROUP := "soccer_ball"
const RADIUS_M := 0.11
const MASS_KG := 0.43
## Physics layer 5, loose props (project.godot): it meets the world (1) and the
## street props (4); characters (2) reach it through its touch area only.
const LOOSE_PROP_LAYER := 1 << 4
const WORLD_SOLID := 1
const STREET_PROP := 1 << 3
const CHARACTER_LAYER := 1 << 1
## A push leaves the ball the character's speed along the contact plus this share of
## their closing speed (a light ball springs off a heavy foot), at most MAX_PUSH_SPEED_MPS.
const PUSH_REBOUND := 0.1
const MAX_PUSH_SPEED_MPS := 24.0
## How near the character's capsule the ball's surface counts as touching it.
const CONTACT_MARGIN_M := 0.04
## Rolling resistance on the ground, a deceleration in the middle of artificial turf's
## range in FIFA's ball-roll test (a ball off its 1 m ramp rolls 4 to 10 m), and air drag
## (0.5 rho Cd A / m: a ball loses about 8 m/s^2 at 25 m/s).
const ROLLING_DECEL_MPS2 := 1.0
const AIR_DRAG_PER_M := 0.0133
## A contact this upright is ground the ball rolls on.
const GROUND_NORMAL_Y := 0.6
## Fallen this far below its spot: through the ground.
const FALL_RESET_M := 4.0
## After a goal the ball stays in the net this long (s), the confetti flying, then
## goes back to its spot.
const GOAL_RESET_S := 2.0
## A ball that came in through a mouth and is this far out to the side of it,
## above it or behind the goal is no longer in that goal.
const MOUTH_MARGIN_M := 0.5
const CONFETTI := preload("res://game/scripts/world/goal_confetti.gd")
const WHITE := Color(0.93, 0.93, 0.9)
const BLACK := Color(0.07, 0.07, 0.08)

## Where it starts and goes back to: on the centre spot, resting on the ground.
@export var spot := Transform3D.IDENTITY
## Every goal it can go into: {id, prop, transform (origin on the middle of the
## goal line, -Z toward the pitch), half_m, height_m, crossbar_m, depth_m}
## (street_furniture_kit.gd goal_mouth).
@export var goals: Array = []

## How often it has gone back to its spot since it was made.
var resets := 0
## How many goals it has gone into since it was made.
var goals_scored := 0
var _reset_pending := false
## Where it was at the last physics tick, the goal whose mouth it came in through
## (-1 none) and how long it stays in the net after a goal (s).
var _previous := Vector3.ZERO
var _entered := -1
var _goal_wait_s := 0.0
var _boundary: WorldBoundary
var _touch: Area3D

static var _mesh: ArrayMesh


## A ball at rest at spot, which knows the goals it can go into. Its parts are built
## here, not in _ready, so the baked world (tools/prebuild_static_world.gd) restores
## them from the scene as they were.
static func create(spot_transform: Transform3D, goal_mouths: Array = []) -> SoccerBall:
	var ball := SoccerBall.new()
	ball.name = "SoccerBall"
	ball.spot = spot_transform
	ball.goals = goal_mouths.duplicate(true)
	ball.transform = spot_transform
	ball.add_to_group(GROUP, true)
	ball.set_meta("street_detail_layer", "furniture")
	ball.mass = MASS_KG
	ball.collision_layer = LOOSE_PROP_LAYER
	ball.collision_mask = WORLD_SOLID | STREET_PROP
	ball.continuous_cd = true
	ball.contact_monitor = true
	ball.max_contacts_reported = 4
	# Drag is the ball's own (_integrate_forces), not the project's default damping.
	ball.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	ball.linear_damp = 0.0
	ball.angular_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
	ball.angular_damp = 0.3
	var bounce := PhysicsMaterial.new()
	bounce.bounce = 0.55
	bounce.friction = 0.6
	ball.physics_material_override = bounce
	var shape := CollisionShape3D.new()
	shape.name = "Shape"
	var sphere := SphereShape3D.new()
	sphere.radius = RADIUS_M
	shape.shape = sphere
	ball.add_child(shape)
	var look := MeshInstance3D.new()
	look.name = "Mesh"
	look.mesh = ball_mesh()
	ball.add_child(look)
	var touch := Area3D.new()
	touch.name = "Touch"
	touch.collision_layer = 0
	touch.collision_mask = CHARACTER_LAYER
	touch.monitorable = false
	var reach := CollisionShape3D.new()
	reach.name = "Shape"
	var around := SphereShape3D.new()
	around.radius = RADIUS_M + CONTACT_MARGIN_M
	reach.shape = around
	touch.add_child(reach)
	ball.add_child(touch)
	return ball


## The classic black-and-white ball: a geodesic sphere on the icosahedron at six
## divisions an edge, the twelve corner patches (the first third of each edge round a
## corner, the truncated icosahedron's pentagons) black, the rest white.
static func ball_mesh() -> ArrayMesh:
	if _mesh != null:
		return _mesh
	var t := (1.0 + sqrt(5.0)) / 2.0
	var corners: Array[Vector3] = [Vector3(-1, t, 0), Vector3(1, t, 0), Vector3(-1, -t, 0), Vector3(1, -t, 0), Vector3(0, -1, t), Vector3(0, 1, t),
		Vector3(0, -1, -t), Vector3(0, 1, -t), Vector3(t, 0, -1), Vector3(t, 0, 1), Vector3(-t, 0, -1), Vector3(-t, 0, 1)]
	var faces := [[0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11], [1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
		[3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9], [4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1]]
	var divisions := 6
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var colors := PackedColorArray()
	for face: Array in faces:
		var a := corners[face[0]]
		var b := corners[face[1]]
		var c := corners[face[2]]
		var at := func(i: int, j: int) -> Vector3:
			return (a * float(divisions - i - j) + b * float(i) + c * float(j)).normalized()
		for i in divisions:
			for j in divisions - i:
				# The upward sub-triangle, then the downward one beside it.
				_triangle(vertices, normals, colors, [at.call(i, j), at.call(i + 1, j), at.call(i, j + 1)], Vector2(float(i) + 1.0 / 3.0, float(j) + 1.0 / 3.0) / float(divisions))
				if i + j < divisions - 1:
					_triangle(vertices, normals, colors, [at.call(i + 1, j), at.call(i + 1, j + 1), at.call(i, j + 1)], Vector2(float(i) + 2.0 / 3.0, float(j) + 2.0 / 3.0) / float(divisions))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	_mesh = ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var material := StandardMaterial3D.new()
	material.resource_name = "soccer_ball"
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.roughness = 0.5
	_mesh.surface_set_material(0, material)
	return _mesh


## One sub-triangle, wound for Godot's front faces (clockwise seen from outside), black
## when its centre's weights (b, c) put it in a corner's patch.
static func _triangle(vertices: PackedVector3Array, normals: PackedVector3Array, colors: PackedColorArray, points: Array, weights: Vector2) -> void:
	var corner := weights.x > 2.0 / 3.0 or weights.y > 2.0 / 3.0 or 1.0 - weights.x - weights.y > 2.0 / 3.0
	var p0: Vector3 = points[0]
	var p1: Vector3 = points[1]
	var p2: Vector3 = points[2]
	if (p1 - p0).cross(p2 - p0).dot(p0 + p1 + p2) > 0.0:
		var swap := p1
		p1 = p2
		p2 = swap
	for point: Vector3 in [p0, p1, p2]:
		vertices.append(point * RADIUS_M)
		normals.append(point)
		colors.append(BLACK if corner else WHITE)


func _ready() -> void:
	_touch = get_node("Touch") as Area3D
	_previous = global_position


## Puts the ball at rest at `at` (tests and capture drivers set a shot up this
## way); the move itself crosses no goal line, and a goal's wait is dropped.
func place(at: Vector3) -> void:
	global_position = at
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = false
	_previous = at
	_entered = -1
	_goal_wait_s = 0.0


## Back to the centre spot, at rest, on the next physics step.
func reset_to_spot() -> void:
	_reset_pending = true
	sleeping = false


func _physics_process(delta: float) -> void:
	if _reset_pending:
		return
	if _goal_wait_s > 0.0:
		_goal_wait_s -= delta
		if _goal_wait_s <= 0.0:
			reset_to_spot()
			return
	elif not sleeping:
		_check_goals()
	_previous = global_position
	# Asleep, it hasn't moved since it was last in play, so the outline test is skipped;
	# a touch still reaches it through the area, and its push wakes it.
	if not sleeping and _out_of_play():
		reset_to_spot()
		return
	for body: Node3D in _touch.get_overlapping_bodies():
		if body is CharacterBody3D:
			_push_from(body as CharacterBody3D)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _reset_pending:
		_reset_pending = false
		state.transform = spot
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		resets += 1
		_previous = spot.origin
		_entered = -1
		_goal_wait_s = 0.0
		return
	var velocity := state.linear_velocity
	var speed := velocity.length()
	if speed < 0.0001:
		return
	var on_ground := false
	for index in state.get_contact_count():
		if state.get_contact_local_normal(index).y > GROUND_NORMAL_Y:
			on_ground = true
			break
	var slowing := AIR_DRAG_PER_M * speed * speed + (ROLLING_DECEL_MPS2 if on_ground else 0.0)
	var share := maxf(0.0, speed - slowing * state.step) / speed
	state.linear_velocity = velocity * share
	if on_ground:
		# Rolling: the spin slows with the roll.
		state.angular_velocity *= share


## A goal: since the last tick the ball came in through a goal's mouth, crossing
## its line from the pitch between the uprights and under its top, and now it is
## wholly over the line. It counts once; going back out over the line, or out of
## the goal's box, forgets the mouth.
func _check_goals() -> void:
	var now := global_position
	for index in goals.size():
		var goal: Dictionary = goals[index]
		var to_goal := (goal.transform as Transform3D).affine_inverse()
		var before := to_goal * _previous
		var after := to_goal * now
		var half := float(goal.half_m)
		var height := float(goal.height_m)
		if before.z < 0.0 and after.z >= 0.0:
			var crossing := before.lerp(after, -before.z / (after.z - before.z))
			if absf(crossing.x) <= half and crossing.y <= height:
				_entered = index
		if _entered != index:
			continue
		if after.z < 0.0 or absf(after.x) > half + MOUTH_MARGIN_M or after.y > height + MOUTH_MARGIN_M or after.z > float(goal.depth_m) + MOUTH_MARGIN_M:
			_entered = -1
		elif after.z >= RADIUS_M:
			_score(goal)
			return


## Confetti at the goal, the count, and back to the spot after GOAL_RESET_S.
func _score(goal: Dictionary) -> void:
	_entered = -1
	goals_scored += 1
	_goal_wait_s = GOAL_RESET_S
	var confetti := CONFETTI.new()
	confetti.name = "GoalConfetti"
	get_parent().add_child(confetti, true)
	confetti.start(goal.transform, float(goal.half_m), float(goal.crossbar_m))
	scored.emit(str(goal.id))


## Out of play: off the island's playable outline (the riprap, the bay) or fallen
## through the ground.
func _out_of_play() -> bool:
	var at := global_position
	if at.y < spot.origin.y - FALL_RESET_M:
		return true
	if _boundary == null:
		var node := get_parent()
		while node != null and not node is WorldLoader:
			node = node.get_parent()
		if node != null:
			_boundary = (node as WorldLoader).get_boundary()
	return _boundary != null and _boundary.is_configured() and not _boundary.contains_position(at)


## A character's capsule touching the ball hands it the character's velocity along the
## contact (horizontal), plus a little rebound, whenever they close on each other.
func _push_from(character: CharacterBody3D) -> void:
	var capsule := _capsule(character)
	if capsule.is_empty():
		return
	var centre := global_position
	var closest := Geometry3D.get_closest_point_to_segment(centre, capsule.bottom, capsule.top)
	var offset := centre - closest
	if offset.length() > float(capsule.radius) + RADIUS_M + CONTACT_MARGIN_M:
		return
	var normal := Vector3(offset.x, 0.0, offset.z)
	if normal.length_squared() < 0.000001:
		normal = Vector3(character.velocity.x, 0.0, character.velocity.z)
	if normal.length_squared() < 0.000001:
		return
	normal = normal.normalized()
	var closing := (character.velocity - linear_velocity).dot(normal)
	if closing <= 0.0:
		# At the fast run (20 m/s, a third of a metre a tick) the touch reports the
		# capsule a tick late, already past the ball's centre. Only a ball the capsule
		# has passed since the last tick (behind its axis now, ahead of it a tick
		# before) was run through, and it takes the push of that earlier contact, along
		# its normal. A ball still ahead and moving off faster than the capsule closes,
		# as a glancing touch sends it aside, keeps the push it already had.
		var run := Vector3(character.velocity.x, 0.0, character.velocity.z)
		if run.length_squared() < 0.000001 or Vector3(offset.x, 0.0, offset.z).dot(run) > 0.0:
			return
		var back := character.velocity * get_physics_process_delta_time()
		var earlier := centre - Geometry3D.get_closest_point_to_segment(centre, capsule.bottom - back, capsule.top - back)
		earlier.y = 0.0
		if earlier.dot(run) <= 0.0:
			return
		normal = earlier.normalized()
		closing = (character.velocity - linear_velocity).dot(normal)
		if closing <= 0.0:
			return
	var target := minf(character.velocity.dot(normal) + PUSH_REBOUND * closing, MAX_PUSH_SPEED_MPS)
	var change := target - linear_velocity.dot(normal)
	if change > 0.0:
		apply_central_impulse(normal * change * mass)


## The character's first capsule in world space: {bottom, top, radius}, its axis's ends.
func _capsule(character: CharacterBody3D) -> Dictionary:
	for child: Node in character.get_children():
		var shape := child as CollisionShape3D
		if shape != null and shape.shape is CapsuleShape3D and not shape.disabled:
			var capsule := shape.shape as CapsuleShape3D
			var axis := shape.global_transform.basis.y.normalized() * maxf(0.0, capsule.height * 0.5 - capsule.radius)
			return {"bottom": shape.global_position - axis, "top": shape.global_position + axis, "radius": capsule.radius}
	return {}
