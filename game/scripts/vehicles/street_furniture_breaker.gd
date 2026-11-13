extends Node3D
## Street furniture a car knocks over (owner, 2026-11-13: the street lamps; sign
## poles and the like could follow with an entry in the furniture kit's FELLABLE
## and its fell_head). street_furniture_builder.gd lists every such row in its
## root's fellable_rows metadata (its prop, params and placement, its pieces'
## instances in the cell MultiMeshes, its collision shapes and its name blades'
## labels), so one can be felled in the world generated at startup and in the
## baked one alike while every standing one stays batched as before.
##
## Each tick a moving live car's or K-rail's reach (vehicle_reach.gd) hands this
## breaker the poles it found (reach_pole). One its box meets within the next
## physics tick, coming on at FELL_SPEED_MPS or more along the face that meets it,
## falls before the physics step can stop the car on it: its instances draw at
## zero scale, its shapes are disabled (it no longer stops a car, a player or the
## chase camera where it stood), its name blades go with it, and it is built
## alone as a debris body, launched the way the car went at the car's speed and
## toward the side of the car it stood on, tipping over that way. It is on no
## physics layer and scans the world and the street props: Godot Physics pushes a
## body only by what is in its own mask, so a car or K-rail that meets it shoves
## it aside and is never pushed back, it can come to rest against a prop, and
## nothing (car, player, chase camera, a reach, other debris) ever meets it. Come
## to rest on the ground (REST_S, or after SETTLE_MAX_S) it is frozen with its
## shapes off, so felled lamps lying about cost no physics; one resting on
## something else (a parked car, a fence) only sleeps, so it falls if that moves.
## It stays down for the session (a restart rebuilds the world). The body that
## felled it keeps going with the felled prop's share of its momentum taken (its
## speed times mass / (mass + the prop's mass)). Slower than FELL_SPEED_MPS a lamp
## stops a car as it always did: a slow nudge does not fell it, nor does pressing
## on against it.

const KIT := preload("res://game/scripts/world/street_furniture_kit.gd")
const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
## A pole falls when a moving body's box meets it within FELL_TICKS physics
## ticks, coming on at this speed or more (m/s) along the face of the box that
## meets it. Tried on the stock controls (knock-over-lamps-20261113): see
## KNOWN_ISSUES.md. Production inference.
const FELL_SPEED_MPS := 4.0
const FELL_TICKS := 1.0
## How the felled prop leaves: the body's speed along its way after the hit
## (CARRY of it), ASIDE_MPS toward the side of the body's middle line it stood
## on, a pop up (m/s), and a tip toward where it goes, TIP_ASIDE of the way to
## that side (rad/s at 10 m/s; scaled by speed within 0.5 to 1.5 times). Its
## damping (1/s) and grip bring it to rest within some metres of where it lands.
const CARRY := 1.0
const ASIDE_MPS := 2.0
const POP_MPS := 0.8
const TIP_RADPS := 1.3
const TIP_ASIDE := 0.6
const LINEAR_DAMP := 0.6
const ANGULAR_DAMP := 0.8
const FRICTION := 1.0
## Debris settles (frozen, no collision) after this long at rest, or at most after
## SETTLE_MAX_S.
const REST_S := 0.6
const SETTLE_MAX_S := 8.0

## Rows by id: {prop, params, transform, mass, range_m, foot, height, radius,
## instances: [[MultiMeshInstance3D, index, piece frame]], shapes:
## [CollisionShape3D], labels: [Label3D]}.
var _rows: Dictionary = {}
## The fellable shapes by physics body RID: {shape index: row id}.
var _shape_rows: Dictionary = {}
## Felled rows, in the order they fell: id -> the street_detail_id of the body
## that knocked it over ("" for none).
var _felled: Dictionary = {}
var _settling: Array[RigidBody3D] = []


func configure(furniture_layer: Node) -> void:
	_rows.clear()
	_shape_rows.clear()
	var root := furniture_layer.get_node_or_null("GeneratedStreetFurniture") as Node3D
	if root == null:
		return
	var listed: Dictionary = root.get_meta("fellable_rows", {})
	for id: String in listed:
		var entry: Dictionary = listed[id]
		var prop := str(entry.get("prop", ""))
		if not KIT.FELLABLE.has(prop):
			continue
		var row := {
			"prop": prop, "params": entry.get("params", {}), "transform": entry.transform,
			"mass": float(KIT.FELLABLE[prop].mass_kg), "range_m": float(KIT.PROPS[prop].range_m),
			"instances": [], "shapes": [], "labels": [],
		}
		# Its shapes' indices in the physics server, kept once the row is accepted.
		var indices: Array = []
		for ref: Array in entry.instances:
			var instance := root.get_node_or_null(str(ref[0])) as MultiMeshInstance3D
			if instance != null and instance.multimesh != null:
				(row.instances as Array).append([instance, int(ref[1]), ref[2]])
		for ref: Array in entry.shapes:
			var body := root.get_node_or_null(str(ref[0])) as StaticBody3D
			var collision := body.get_node_or_null(str(ref[1])) as CollisionShape3D if body != null else null
			if collision == null:
				continue
			(row.shapes as Array).append(collision)
			# The pole: its first upright capsule, from its foot up.
			if not row.has("foot") and collision.shape is CapsuleShape3D:
				var capsule := collision.shape as CapsuleShape3D
				row["foot"] = collision.global_position - Vector3.UP * capsule.height * 0.5
				row["height"] = capsule.height
				row["radius"] = capsule.radius
			for owner_id in body.get_shape_owners():
				if body.shape_owner_get_owner(owner_id) == collision:
					indices.append([body.get_rid(), body.shape_owner_get_shape_index(owner_id, 0)])
		for ref: Array in entry.labels:
			var group := root.get_node_or_null(str(ref[0]))
			var label := group.get_node_or_null(str(ref[1])) as Label3D if group != null else null
			if label != null:
				(row.labels as Array).append(label)
		if not row.has("foot") or (row.instances as Array).is_empty():
			continue
		_rows[id] = row
		for ref: Array in indices:
			var by_index: Dictionary = _shape_rows.get(ref[0], {})
			by_index[ref[1]] = id
			_shape_rows[ref[0]] = by_index


## What a moving body's reach hands this breaker, by physics body: the street
## furniture bodies that hold a fellable prop's shapes.
func reach_owners() -> Dictionary:
	var owners := {}
	for rid: RID in _shape_rows:
		owners[rid] = reach_pole
	return owners


func fellable_ids() -> Array:
	return _rows.keys()


func is_felled(id: String) -> bool:
	return _felled.has(id)


## The felled rows, in the order they fell.
func felled_ids() -> Array:
	return _felled.keys()


## The row id of the car or K-rail that knocked a felled row over ("" if none).
func felled_by(id: String) -> String:
	return str(_felled.get(id, ""))


## A row's foot, height and radius as the reach meets it: {foot, height, radius}
## ({} if it is not a fellable row).
func pole(id: String) -> Dictionary:
	var row: Dictionary = _rows.get(id, {})
	return {} if row.is_empty() else {"foot": row.foot, "height": row.height, "radius": row.radius}


## A fellable prop's shape in a moving body's reach: it falls if the body's box
## meets it within FELL_TICKS ticks coming on at FELL_SPEED_MPS or more.
func reach_pole(reach: VehicleReach, hit: Dictionary) -> void:
	if reach.speed < FELL_SPEED_MPS:
		return
	var by_index: Dictionary = _shape_rows.get(hit.get("rid", RID()), {})
	var id := str(by_index.get(int(hit.get("shape", -1)), ""))
	if id == "" or _felled.has(id):
		return
	var row: Dictionary = _rows[id]
	var contact := reach.pole_contact(row.foot, row.height, row.radius, reach.delta * FELL_TICKS)
	if contact.is_empty() or float(contact.closing) < FELL_SPEED_MPS:
		return
	fell(id, reach.body)


## Fells a row: hides it, opens its shapes, drops it as debris knocked by the
## body (null: straight over, nothing slowed).
func fell(id: String, by: RigidBody3D = null) -> void:
	if _felled.has(id) or not _rows.has(id):
		return
	var row: Dictionary = _rows[id]
	_felled[id] = str(by.get_meta("street_detail_id", "")) if by != null else ""
	var placement: Transform3D = row.transform
	var debris := RigidBody3D.new()
	debris.name = "Felled%d" % _felled.size()
	debris.collision_layer = 0
	debris.collision_mask = PHYSICS_WORLD_SOLID | PHYSICS_STREET_PROP
	debris.mass = float(row.mass)
	debris.can_sleep = true
	debris.linear_damp = LINEAR_DAMP
	debris.angular_damp = ANGULAR_DAMP
	# What it rests on, when it comes to rest (_physics_process).
	debris.contact_monitor = true
	debris.max_contacts_reported = 4
	debris.set_meta("street_detail_kind", "felled_furniture")
	debris.set_meta("street_detail_id", id)
	debris.set_meta("age", 0.0)
	debris.set_meta("rest", 0.0)
	var surface := PhysicsMaterial.new()
	surface.friction = FRICTION
	surface.bounce = 0.1
	debris.physics_material_override = surface
	for ref: Array in row.instances:
		var instance := ref[0] as MultiMeshInstance3D
		if not is_instance_valid(instance):
			continue
		instance.multimesh.set_instance_transform(int(ref[1]), Transform3D(Basis().scaled(Vector3.ZERO), placement.origin))
		var mesh := MeshInstance3D.new()
		mesh.mesh = instance.multimesh.mesh
		mesh.transform = ref[2]
		mesh.layers = instance.layers
		mesh.cast_shadow = instance.cast_shadow
		mesh.visibility_range_end = float(row.range_m)
		debris.add_child(mesh)
	for collision: CollisionShape3D in row.shapes:
		if is_instance_valid(collision):
			collision.disabled = true
	# It lies on its pole's capsule and the box round its head.
	var pole_shape := CapsuleShape3D.new()
	pole_shape.radius = float(row.radius)
	pole_shape.height = maxf(float(row.height), float(row.radius) * 2.0)
	var pole := CollisionShape3D.new()
	pole.shape = pole_shape
	pole.position = Vector3.UP * pole_shape.height * 0.5
	debris.add_child(pole)
	var head := KIT.fell_head(str(row.prop), row.params)
	if head.size != Vector3.ZERO:
		var head_shape := BoxShape3D.new()
		head_shape.size = head.size
		var head_collision := CollisionShape3D.new()
		head_collision.shape = head_shape
		head_collision.position = head.get_center()
		debris.add_child(head_collision)
	debris.transform = placement
	add_child(debris)
	for label: Label3D in row.labels:
		if is_instance_valid(label):
			label.reparent(debris, true)
	_settling.append(debris)
	if by == null:
		return
	var velocity := by.linear_velocity
	var way := Vector3(velocity.x, 0.0, velocity.z)
	var speed := way.length()
	if speed < 0.01:
		return
	way /= speed
	var keep := by.mass / (by.mass + float(row.mass))
	by.linear_velocity = velocity * keep
	# Off the body's middle line, toward the side of it the prop stood on.
	var right := way.cross(Vector3.UP)
	var aside := right if (placement.origin - by.global_position).dot(right) >= 0.0 else -right
	debris.linear_velocity = way * speed * keep * CARRY + aside * ASIDE_MPS + Vector3.UP * POP_MPS
	# Turning about UP x toward tips its top toward where it goes.
	var toward := (way + aside * TIP_ASIDE).normalized()
	debris.angular_velocity = Vector3.UP.cross(toward) * TIP_RADPS * clampf(speed / 10.0, 0.5, 1.5)


func _physics_process(delta: float) -> void:
	for index in range(_settling.size() - 1, -1, -1):
		var debris := _settling[index]
		if not is_instance_valid(debris):
			_settling.remove_at(index)
			continue
		var age := float(debris.get_meta("age", 0.0)) + delta
		debris.set_meta("age", age)
		var resting := debris.linear_velocity.length() < 0.15 and debris.angular_velocity.length() < 0.2
		var rest := float(debris.get_meta("rest", 0.0)) + delta if resting else 0.0
		debris.set_meta("rest", rest)
		if rest >= REST_S or age >= SETTLE_MAX_S:
			_settling.remove_at(index)
			var grounded := _on_the_ground(debris)
			debris.contact_monitor = false
			if not grounded:
				continue
			debris.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
			debris.freeze = true
			for shape: Node in debris.find_children("*", "CollisionShape3D", false, false):
				(shape as CollisionShape3D).disabled = true


## Whether a body at rest touches only the world (the ground, a wall), nothing on
## the street-prop layer (a parked car, a fence) that could move or break away.
static func _on_the_ground(debris: RigidBody3D) -> bool:
	for other: Node3D in debris.get_colliding_bodies():
		var body := other as CollisionObject3D
		if body != null and body.collision_layer & PHYSICS_STREET_PROP:
			return false
	return true
