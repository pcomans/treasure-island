extends Node3D
## Street furniture a car knocks over (owner, 2026-11-13: the street lamps; sign
## poles and the like could follow with an entry in the furniture kit's
## FELLABLE). street_furniture_builder.gd lists every such row in its root's
## fellable_rows metadata (its prop, params and placement, its pieces' instances
## in the cell MultiMeshes, its collision shapes and its name blades' labels), so
## one can be felled in the world generated at startup and in the baked one alike
## while every standing one stays batched as before.
##
## Each tick a moving live car's or K-rail's reach (vehicle_reach.gd) hands this
## breaker the poles it found (reach_pole). One its box meets within the next
## physics tick, coming on at FELL_SPEED_MPS or more along the face that meets it,
## falls before the physics step can stop the car on it: its instances draw at
## zero scale, its shapes are disabled (it no longer stops a car, a player or the
## chase camera where it stood), its name blades go with it, and it is built
## alone as a debris body that goes over where it stood (visual review,
## 2026-11-13: not carried down the street on the bumper): its foot knocked on a
## little the way the car went and out toward the side of the car's middle line it
## stood on, it tips over about its foot toward that side and somewhat ahead, and
## the body that felled it passes through it (a collision exception) and carries
## on. It is on no physics layer and scans the world and the street props: Godot
## Physics pushes a body only by what is in its own mask, so another car or K-rail
## that meets it shoves it aside and is never pushed back, it can come to rest
## against a prop, and nothing (car, player, chase camera, a reach, other debris)
## ever meets it. It collides as the convex hulls of what is drawn of it, slice by
## slice up its height (the furniture kit's fall_slices), so it lies on its drawn
## pole and head, neither in the ground nor held over it. Come to rest (REST_S, or at most SETTLE_MAX_S
## after it fell or last woke) on the ground it is frozen with its shapes off, so
## felled lamps lying about cost no physics; one resting on something else (a
## parked car, a fence) is put to sleep, so it costs none either and falls if that
## moves, and settles again from there. It stays down for the session (a restart
## rebuilds the world). The body that felled it keeps going with the felled
## prop's share of its momentum taken (its speed times mass / (mass + the prop's
## mass)). Slower than FELL_SPEED_MPS a lamp stops a car as it always did: a slow
## nudge does not fell it, nor does pressing on against it.

const KIT := preload("res://game/scripts/world/street_furniture_kit.gd")
const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
## A pole falls when a moving body's box meets it within FELL_TICKS physics
## ticks, coming on at this speed or more (m/s) along the face of the box that
## meets it. Tried on the stock controls (knock-over-lamps-20261113): see
## KNOWN_ISSUES.md. Production inference.
const FELL_SPEED_MPS := 4.0
const FELL_TICKS := 1.0
## How the felled prop goes over: its foot knocked on FOOT_CARRY of the body's
## speed after the hit along its way (at most FOOT_MAX_MPS), FOOT_ASIDE_MPS toward
## the side of the body's middle line it stood on and a pop up (m/s); it tips
## about its foot toward that side, FALL_AHEAD of the way the body went, at
## TIP_RADPS (rad/s at 10 m/s; scaled by speed within 0.7 to 1.4 times), its weight
## MASS_HEIGHT of its pole's height up. Its damping (1/s) and grip bring it to rest
## where it lands.
const FOOT_CARRY := 0.25
const FOOT_MAX_MPS := 4.0
const FOOT_ASIDE_MPS := 1.5
const POP_MPS := 0.4
const TIP_RADPS := 1.0
const FALL_AHEAD := 0.7
const MASS_HEIGHT := 0.5
const LINEAR_DAMP := 0.6
const ANGULAR_DAMP := 0.8
const FRICTION := 1.0
## Debris settles after this long at rest, or at most SETTLE_MAX_S after it fell
## or last woke: frozen with no collision on the ground, asleep on anything else.
const REST_S := 0.6
const SETTLE_MAX_S := 8.0
## Sound (game/scripts/audio/sound.gd): the hit as it goes over, louder the faster
## the body that felled it, and the clang of its head on the ground, louder the
## heavier the prop: the tick its turning drops to FALL_STOP_SHARE or less of the
## last tick's once it leans past FALL_LEAN_UP (its up's height: past about 60
## degrees), or once it lies past FALL_FLAT_UP, whichever comes first.
const FALL_LEAN_UP := 0.5
const FALL_FLAT_UP := 0.2
const FALL_STOP_SHARE := 0.6
const FALL_SPIN_MIN := 0.5

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
## The hulls a felled prop's mesh collides as (_hulls), by mesh.
var _hulls_by_mesh: Dictionary = {}


func configure(furniture_layer: Node) -> void:
	_rows.clear()
	_shape_rows.clear()
	_hulls_by_mesh.clear()
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
	debris.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	debris.center_of_mass = Vector3.UP * float(row.height) * MASS_HEIGHT
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
	debris.set_meta("height", float(row.height))
	debris.set_meta("spin", 0.0)
	debris.set_meta("landed", false)
	var hit_speed := by.linear_velocity.length() if by != null else 8.0
	Sound.play(&"lamp_hit", (row.foot as Vector3) + Vector3.UP * 0.9, clampf(0.4 + hit_speed / 25.0, 0.4, 1.0))
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
		# It lies on what is drawn of it.
		for hull: ConvexPolygonShape3D in _hulls(instance.multimesh.mesh):
			var collision := CollisionShape3D.new()
			collision.shape = hull
			collision.transform = ref[2]
			debris.add_child(collision)
	for collision: CollisionShape3D in row.shapes:
		if is_instance_valid(collision):
			collision.disabled = true
	debris.transform = placement
	add_child(debris)
	for label: Label3D in row.labels:
		if is_instance_valid(label):
			label.reparent(debris, true)
	debris.sleeping_state_changed.connect(_on_debris_sleeping.bind(debris))
	_settle(debris)
	if by == null:
		return
	# The body that felled it carries on through it.
	debris.add_collision_exception_with(by)
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
	var foot := way * minf(speed * keep * FOOT_CARRY, FOOT_MAX_MPS) + aside * FOOT_ASIDE_MPS + Vector3.UP * POP_MPS
	# Turning about UP x toward tips its top toward where it goes, about its foot:
	# its weight moves on by the turn round the foot as well as the foot's own way.
	var toward := (aside + way * FALL_AHEAD).normalized()
	var spin := Vector3.UP.cross(toward) * TIP_RADPS * clampf(speed / 10.0, 0.7, 1.4)
	debris.angular_velocity = spin
	debris.linear_velocity = foot + spin.cross(placement.basis * debris.center_of_mass)


## The convex hulls a mesh collides as when felled: one a slice the furniture kit
## kept of it (fall_slices), or its box if it kept none. By mesh, once.
func _hulls(mesh: Mesh) -> Array:
	if _hulls_by_mesh.has(mesh):
		return _hulls_by_mesh[mesh]
	var hulls: Array = []
	for points: PackedVector3Array in mesh.get_meta("fall_slices", []):
		var hull := ConvexPolygonShape3D.new()
		hull.points = points
		hulls.append(hull)
	if hulls.is_empty():
		var box := mesh.get_aabb()
		var corners := PackedVector3Array()
		for corner in 8:
			corners.append(box.get_endpoint(corner))
		var hull := ConvexPolygonShape3D.new()
		hull.points = corners
		hulls.append(hull)
	_hulls_by_mesh[mesh] = hulls
	return hulls


## Tracks a debris body until it settles (again: one woken from its sleep).
func _settle(debris: RigidBody3D) -> void:
	debris.set_meta("age", 0.0)
	debris.set_meta("rest", 0.0)
	debris.contact_monitor = true
	if not _settling.has(debris):
		_settling.append(debris)


## A sleeping debris body woken (what it lay on moved): it settles again.
func _on_debris_sleeping(debris: RigidBody3D) -> void:
	if is_instance_valid(debris) and not debris.sleeping and not debris.freeze:
		_settle(debris)


func _physics_process(delta: float) -> void:
	for index in range(_settling.size() - 1, -1, -1):
		var debris := _settling[index]
		if not is_instance_valid(debris):
			_settling.remove_at(index)
			continue
		var age := float(debris.get_meta("age", 0.0)) + delta
		debris.set_meta("age", age)
		_sound_landing(debris)
		var resting := debris.linear_velocity.length() < 0.15 and debris.angular_velocity.length() < 0.2
		var rest := float(debris.get_meta("rest", 0.0)) + delta if resting else 0.0
		debris.set_meta("rest", rest)
		if rest >= REST_S or age >= SETTLE_MAX_S:
			_settling.remove_at(index)
			var grounded := _on_the_ground(debris)
			debris.contact_monitor = false
			if not grounded:
				# Propped on something that can move: asleep until that moves.
				debris.sleeping = true
				continue
			debris.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
			debris.freeze = true
			for shape: Node in debris.find_children("*", "CollisionShape3D", false, false):
				(shape as CollisionShape3D).disabled = true


## The felled prop's head meeting the ground, once (see FALL_LEAN_UP).
static func _sound_landing(debris: RigidBody3D) -> void:
	if bool(debris.get_meta("landed", true)):
		return
	var up := debris.global_transform.basis.y.y
	var spin := debris.angular_velocity.length()
	var was := float(debris.get_meta("spin", 0.0))
	debris.set_meta("spin", spin)
	if not ((up < FALL_LEAN_UP and was > FALL_SPIN_MIN and spin <= was * FALL_STOP_SHARE) or up < FALL_FLAT_UP):
		return
	debris.set_meta("landed", true)
	var head := debris.global_transform * (Vector3.UP * float(debris.get_meta("height", 4.0)) * 0.75)
	Sound.play(&"lamp_fall", head, clampf(0.45 + debris.mass / 300.0, 0.5, 1.0))


## Whether a body at rest touches only the world (the ground, a wall), nothing on
## the street-prop layer (a parked car, a fence) that could move or break away.
static func _on_the_ground(debris: RigidBody3D) -> bool:
	for other: Node3D in debris.get_colliding_bodies():
		var body := other as CollisionObject3D
		if body != null and body.collision_layer & PHYSICS_STREET_PROP:
			return false
	return true
