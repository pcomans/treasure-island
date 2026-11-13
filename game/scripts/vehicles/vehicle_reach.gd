class_name VehicleReach
extends RefCounted
## One look round a moving live car or K-rail a physics tick (owner, 2026-11-13:
## "one call for collider volumes around us", not one check per kind of thing).
## vehicle_manager.gd asks the physics server once (find) for everything on the
## street-prop, loose-prop and reach layers in the box round all the body can
## reach this tick, and hands each thing found to whoever owns it: a parked car's
## or K-rail's row goes live and a frozen live one wakes (vehicle_manager.gd), a
## fence bay breaks and a broken bay's standing post goes down
## (street_fence_breaker.gd), a street lamp falls (street_furniture_breaker.gd),
## the pitch's ball is pushed. Each owner judges its own things against the
## body's box with its own margin (overlaps, distance_to, pole_contact): plain
## arithmetic on the shapes' boxes, so a new kind of breakable thing adds an
## owner, not another query. Things nothing collides with but a reach should
## find (a broken fence's standing posts) stand on PHYSICS_REACH, which only
## this query looks at.
##
## The body's box is the box round its collision pieces in its own frame
## (reach_box: a car's DrivableCar._reach_box; a K-rail's from its shapes). The
## query never asks Godot Physics to test a car's convex pieces against another
## car's, which cost milliseconds a pair (LEARNINGS: measure a pile-up).

const PHYSICS_STREET_PROP := 1 << 3
const PHYSICS_LOOSE_PROP := 1 << 4
## Layer 7: shapes only a reach finds (no body collides with them).
const PHYSICS_REACH := 1 << 6
## What a reach looks for.
const MASK := PHYSICS_STREET_PROP | PHYSICS_LOOSE_PROP | PHYSICS_REACH
## The hits asked for at first; a full list is asked again with room for four
## times as many (up to MAX_HITS), so a crowded spot never pushes a car, a bay
## or a lamp out of it.
const FIRST_HITS := 32
const MAX_HITS := 2048

## The body looking, and its state at the start of this tick.
var body: RigidBody3D
var xf := Transform3D.IDENTITY
## The box round its collision pieces in its frame, that box's centre frame in
## the world and its half size.
var box := AABB()
var box_xf := Transform3D.IDENTITY
var half := Vector3.ZERO
var velocity := Vector3.ZERO
## The velocity in the body's frame.
var local_velocity := Vector3.ZERO
var speed := 0.0
var delta := 1.0 / 60.0
## What this tick asks of the owners (vehicle_manager.gd sets them): shove what
## it will reach within the look-ahead (ahead) or what it touches (touch); break
## fence bays and fell standing posts (breaks); push loose props (pushes).
var driven := false
var ahead := false
var touch := false
var breaks := false
var pushes := false
## The largest number of hits one find returned (a diagnostic for tests).
var most_hits := 0

## A shape's box in its own frame, by shape (shape_box). The shapes it is asked
## about are the world's and the live bodies', which never change size once built;
## the vehicle manager empties it when it takes a new world (forget_shapes), so it
## holds no shape past its world.
static var _shape_boxes: Dictionary = {}


## Takes the body's state for this tick.
func look_from(target: RigidBody3D, tick: float) -> void:
	body = target
	xf = target.global_transform
	box = reach_box(target)
	half = box.size * 0.5
	box_xf = xf * Transform3D(Basis.IDENTITY, box.get_center())
	velocity = target.linear_velocity
	local_velocity = xf.basis.inverse() * velocity
	speed = velocity.length()
	delta = tick


## Every shape on MASK in region (a box in the body's frame), however many.
func find(query: PhysicsShapeQueryParameters3D, shape: BoxShape3D, region: AABB) -> Array[Dictionary]:
	shape.size = region.size
	query.shape = shape
	query.margin = 0.0
	query.transform = xf * Transform3D(Basis.IDENTITY, region.get_center())
	query.collision_mask = MASK
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.exclude = [body.get_rid()]
	var space := body.get_world_3d().direct_space_state
	var limit := FIRST_HITS
	var hits := space.intersect_shape(query, limit)
	while hits.size() >= limit and limit < MAX_HITS:
		limit *= 4
		hits = space.intersect_shape(query, limit)
	most_hits = maxi(most_hits, hits.size())
	return hits


## Whether a box (its centre frame in the world, unscaled, and half size)
## overlaps the body's box grown by margin.
func overlaps(other_xf: Transform3D, other_half: Vector3, margin: float) -> bool:
	return boxes_overlap(box_xf, half + Vector3.ONE * margin, other_xf, other_half)


## How far a world point lies outside the body's box (0 inside).
func distance_to(point: Vector3) -> float:
	var local := box_xf.inverse() * point
	return Vector3(maxf(absf(local.x) - half.x, 0.0), maxf(absf(local.y) - half.y, 0.0), maxf(absf(local.z) - half.z, 0.0)).length()


## When the body's box, moving as it moves now (its turn left out), first meets an
## upright pole (a capsule of radius on the world-vertical line from foot up to
## height): {t (s from now, 0 if it does already), closing (m/s: the body's speed
## into the face of its box it meets the pole with)}, or {} if not within limit_s.
## Worked in plan in the body's frame, where the pole's line crosses the middle
## height of the box; a body tipped far over (on its side or roof) gets {}, so
## physics alone meets the pole.
func pole_contact(foot: Vector3, height: float, radius: float, limit_s: float) -> Dictionary:
	var to_local := xf.inverse()
	var bottom := to_local * foot
	var top := to_local * (foot + Vector3.UP * height)
	var rise := top.y - bottom.y
	if rise < height * 0.7:
		return {}
	var middle := box.get_center().y
	if middle < bottom.y - radius or middle > top.y + radius:
		return {}
	var at := bottom.lerp(top, clampf((middle - bottom.y) / rise, 0.0, 1.0))
	# The pole moves against the body at -local_velocity; the box grown by radius.
	var mover := Vector2(-local_velocity.x, -local_velocity.z)
	var start := Vector2(at.x, at.z)
	var low := Vector2(box.position.x - radius, box.position.z - radius)
	var high := Vector2(box.end.x + radius, box.end.z + radius)
	var enter := 0.0
	var leave := limit_s
	var normal := Vector2.ZERO
	for axis in 2:
		var p := start[axis]
		var w := mover[axis]
		if absf(w) < 1e-6:
			if p < low[axis] or p > high[axis]:
				return {}
			continue
		var t_low := (low[axis] - p) / w
		var t_high := (high[axis] - p) / w
		# The face it comes in through: low when moving up the axis.
		var face := Vector2.ZERO
		face[axis] = -1.0 if w > 0.0 else 1.0
		var t_in := minf(t_low, t_high)
		var t_out := maxf(t_low, t_high)
		if t_in > enter:
			enter = t_in
			normal = face
		leave = minf(leave, t_out)
		if enter > leave:
			return {}
	if normal == Vector2.ZERO:
		# Already inside the grown box: the face it is nearest to.
		var gaps := [start.x - low.x, high.x - start.x, start.y - low.y, high.y - start.y]
		var nearest := 0
		for index in range(1, 4):
			if gaps[index] < gaps[nearest]:
				nearest = index
		normal = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)][nearest]
	# The body's speed out through that face of its box (toward the pole).
	var closing := Vector2(local_velocity.x, local_velocity.z).dot(normal)
	return {"t": enter, "closing": closing, "normal": normal}


## The box round a live body's collision pieces in its frame: a car's
## (DrivableCar._reach_box), or any other body's (a K-rail's), worked out once
## from its enabled shapes (a K-rail's and the ball's are never disabled).
static func reach_box(target: RigidBody3D) -> AABB:
	if target is DrivableCar:
		return (target as DrivableCar).reach_aabb()
	if target.has_meta("reach_box"):
		return target.get_meta("reach_box")
	var result := AABB()
	var first := true
	for owner_id in target.get_shape_owners():
		if target.is_shape_owner_disabled(owner_id):
			continue
		var owner_xf := target.shape_owner_get_transform(owner_id)
		for index in target.shape_owner_get_shape_count(owner_id):
			var piece := owner_xf * shape_box(target.shape_owner_get_shape(owner_id, index))
			result = piece if first else result.merge(piece)
			first = false
	target.set_meta("reach_box", result)
	return result


## Empties the shape box cache (a new world).
static func forget_shapes() -> void:
	_shape_boxes.clear()


## A shape's box in its own frame (cached per shape).
static func shape_box(shape: Shape3D) -> AABB:
	if shape == null:
		return AABB()
	if _shape_boxes.has(shape):
		return _shape_boxes[shape]
	var result := AABB()
	if shape is BoxShape3D:
		var size := (shape as BoxShape3D).size
		result = AABB(-size * 0.5, size)
	elif shape is CapsuleShape3D:
		var capsule := shape as CapsuleShape3D
		result = AABB(Vector3(-capsule.radius, -capsule.height * 0.5, -capsule.radius), Vector3(capsule.radius * 2.0, capsule.height, capsule.radius * 2.0))
	elif shape is CylinderShape3D:
		var cylinder := shape as CylinderShape3D
		result = AABB(Vector3(-cylinder.radius, -cylinder.height * 0.5, -cylinder.radius), Vector3(cylinder.radius * 2.0, cylinder.height, cylinder.radius * 2.0))
	elif shape is SphereShape3D:
		var radius := (shape as SphereShape3D).radius
		result = AABB(-Vector3.ONE * radius, Vector3.ONE * radius * 2.0)
	elif shape is ConvexPolygonShape3D:
		var points := (shape as ConvexPolygonShape3D).points
		for index in points.size():
			result = AABB(points[index], Vector3.ZERO) if index == 0 else result.expand(points[index])
	else:
		var debug := shape.get_debug_mesh()
		result = debug.get_aabb() if debug != null else AABB()
	_shape_boxes[shape] = result
	return result


## Whether two boxes overlap, each given by its centre frame in the world (an
## unscaled rotation) and its half size: the separating-axis test over the 15
## axes of two boxes, as Godot Physics tests two boxes with no margin.
static func boxes_overlap(a: Transform3D, a_half: Vector3, b: Transform3D, b_half: Vector3) -> bool:
	var rel := a.inverse() * b
	var t := rel.origin
	# r_ij: a's axis i against b's axis j (b's axes in a's frame are rel's columns).
	var r00 := rel.basis.x.x
	var r10 := rel.basis.x.y
	var r20 := rel.basis.x.z
	var r01 := rel.basis.y.x
	var r11 := rel.basis.y.y
	var r21 := rel.basis.y.z
	var r02 := rel.basis.z.x
	var r12 := rel.basis.z.y
	var r22 := rel.basis.z.z
	var e := 1e-6
	var q00 := absf(r00) + e
	var q10 := absf(r10) + e
	var q20 := absf(r20) + e
	var q01 := absf(r01) + e
	var q11 := absf(r11) + e
	var q21 := absf(r21) + e
	var q02 := absf(r02) + e
	var q12 := absf(r12) + e
	var q22 := absf(r22) + e
	var ax := a_half.x
	var ay := a_half.y
	var az := a_half.z
	var bx := b_half.x
	var by := b_half.y
	var bz := b_half.z
	# a's faces.
	if absf(t.x) > ax + bx * q00 + by * q01 + bz * q02:
		return false
	if absf(t.y) > ay + bx * q10 + by * q11 + bz * q12:
		return false
	if absf(t.z) > az + bx * q20 + by * q21 + bz * q22:
		return false
	# b's faces.
	if absf(t.x * r00 + t.y * r10 + t.z * r20) > ax * q00 + ay * q10 + az * q20 + bx:
		return false
	if absf(t.x * r01 + t.y * r11 + t.z * r21) > ax * q01 + ay * q11 + az * q21 + by:
		return false
	if absf(t.x * r02 + t.y * r12 + t.z * r22) > ax * q02 + ay * q12 + az * q22 + bz:
		return false
	# Edge against edge.
	if absf(t.z * r10 - t.y * r20) > ay * q20 + az * q10 + by * q02 + bz * q01:
		return false
	if absf(t.z * r11 - t.y * r21) > ay * q21 + az * q11 + bx * q02 + bz * q00:
		return false
	if absf(t.z * r12 - t.y * r22) > ay * q22 + az * q12 + bx * q01 + by * q00:
		return false
	if absf(t.x * r20 - t.z * r00) > ax * q20 + az * q00 + by * q12 + bz * q11:
		return false
	if absf(t.x * r21 - t.z * r01) > ax * q21 + az * q01 + bx * q12 + bz * q10:
		return false
	if absf(t.x * r22 - t.z * r02) > ax * q22 + az * q02 + bx * q11 + by * q10:
		return false
	if absf(t.y * r00 - t.x * r10) > ax * q10 + ay * q00 + by * q22 + bz * q21:
		return false
	if absf(t.y * r01 - t.x * r11) > ax * q11 + ay * q01 + bx * q22 + bz * q20:
		return false
	if absf(t.y * r02 - t.x * r12) > ax * q12 + ay * q02 + bx * q21 + by * q20:
		return false
	return true
