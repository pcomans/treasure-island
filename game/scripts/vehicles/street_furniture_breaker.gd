extends Node3D
## Street furniture a car knocks over: the street lamps (owner, 2026-11-13), the
## sign posts, signal masts, utility poles and bollards, and so the pitches' light
## towers and the park's event light poles (owner, 2026-11-14: "Sign posts, signal
## masts, utility poles and bollards", "these all need to be breakable"): every
## prop in the furniture kit's FELLABLE, which gives each its mass, the speed it
## falls to (fell_mps) and how it goes over. street_furniture_builder.gd lists
## every such row in its root's fellable_rows metadata (its prop, params and
## placement, its pieces' instances in the cell MultiMeshes, its collision shapes,
## its name labels and a utility pole's wire spans, fellable_wires), so one can be
## felled in the world generated at startup and in the baked one alike while
## every standing one stays batched as before.
##
## Each tick a moving live car's or K-rail's reach (vehicle_reach.gd) hands this
## breaker the props it found (reach_pole): no query of its own. One its box meets
## within the next physics tick, coming on at the prop's fell_mps or more along the
## face that meets it (a round pole as the line up its capsule; a prop of several
## shapes, a light tower on its trailer, as their plan footprint), falls before
## the physics step can stop the car on it: its instances draw at zero scale, its
## shapes are disabled (it no longer stops a car, a player or the chase camera
## where it stood), whatever it carries goes with it (name blades and their
## labels, a mast's heads and arm sign, a pole's crossarms and lamp; not a bus
## stop's pad, which stays), and it is built alone as a debris body that goes over
## where it stood (visual review, 2026-11-13: not carried down the street on the
## bumper): its foot knocked on a little the way the car went and out toward the
## side of the car's middle line it stood on, it tips over about its foot (a
## footprint about its far edge) toward that side and somewhat ahead, and the body
## that felled it passes through it (a collision exception) and carries on. It is
## on no physics layer and scans the world and the street props: Godot Physics
## pushes a body only by what is in its own mask, so another car or K-rail that
## meets it shoves it aside and is never pushed back, it can come to rest against
## a prop, and nothing (car, player, chase camera, a reach, other debris) ever
## meets it. It collides as the convex hulls of what is drawn of it, slice by
## slice up its height (the furniture kit's fall_slices), so it lies on its drawn
## pole and head, neither in the ground nor held over it, and it falls through the
## invisible ramps in front of the kerbs' faces onto the gutter and against the
## kerb that are drawn (_pass_kerb_ramps). Come to rest (REST_S, or
## at most SETTLE_MAX_S after it fell or last woke) on the ground it is frozen with
## its shapes off, so felled props lying about cost no physics; one resting on
## something else (a parked car, a fence) is put to sleep, so it costs none either
## and falls if that moves, and settles again from there. It stays down for the
## session (a restart rebuilds the world). The body that felled it keeps going with
## the felled prop's share of its momentum taken (its speed times mass / (mass +
## the prop's mass)). Slower than its fell_mps a prop stops a car as it always
## did: a slow nudge does not fell it, nor does pressing on against it.
##
## A felled utility pole's wire spans (each to a neighbouring pole) are no longer
## drawn where they hung: each is drawn instead from the standing neighbour's
## insulators to the felled pole's, as one small MultiMesh of the shared wire mesh,
## following its crossarm down as it falls and then still where it lies; a span
## between two felled poles is gone.

const KIT := preload("res://game/scripts/world/street_furniture_kit.gd")
const BUILDER := preload("res://game/scripts/world/street_furniture_builder.gd")
const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
## A FELLABLE prop falls when a moving body's box meets it within FELL_TICKS
## physics ticks, coming on at its fell_mps or more (m/s) along the face of the box
## that meets it; FELL_SPEED_MPS is the street lamps', and any prop's that names
## none. Tried on the stock controls (knock-over-lamps-20261113): see
## KNOWN_ISSUES.md. Production inference.
const FELL_SPEED_MPS := 4.0
const FELL_TICKS := 1.0
## How the felled prop goes over: its foot knocked on FOOT_CARRY of the body's
## speed after the hit along its way (at most FOOT_MAX_MPS), FOOT_ASIDE_MPS toward
## the side of the body's middle line it stood on and a pop up (m/s); it tips
## about its foot toward that side, FALL_AHEAD of the way the body went, at
## TIP_RADPS (rad/s at 10 m/s, times its tip; scaled by speed within 0.7 to 1.4
## times), its weight MASS_HEIGHT (or its mass_height) of its height up (and a
## mast's its mass_arm out along its arm). Its damping (1/s) and grip bring it to
## rest where it lands.
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
## Frozen on the ground, it is put on the drawn ground (_onto_drawn_ground): the
## lowest of its hulls' points in each REST_CELL_M square in plan looks once
## straight down from REST_RAY_M over it to as far under it, and only the land
## counts; a lift of more than REST_LIFT_MAX_M is something over it, not ground,
## and is skipped.
const REST_CELL_M := 0.25
const REST_RAY_M := 0.5
const REST_LIFT_MAX_M := 0.3
## The ground a felled prop is lifted onto (its collider's parent's feature_kind),
## and the invisible ramps in front of the kerbs' faces (there so the stock player
## walks on and off a kerb), which it falls through: those within its height and
## RAMP_REACH_M of where it falls (at most RAMP_QUERY_MAX world bodies looked at).
const LAND_KIND := "land_ground"
const KERB_RAMP_KIND := "street_kerb_support"
const RAMP_REACH_M := 2.0
const RAMP_QUERY_MAX := 64
## A felled utility pole's wires hang slack from the standing pole: sagging up to
## DROP_SAG of their length (as it goes over, from their own sag standing), in
## DROP_PIECES pieces at least, and never into the ground, taken as a straight line
## between the two poles' feet.
const DROP_SAG := 0.07
const DROP_PIECES := 14
## The material lit parts (a signal head's green lens, a pedestrian head's hand)
## show while the prop stands (the furniture kit's lit surface, by its resource
## name); felled, they are drawn shaded and darkened by LENS_OFF: off.
const LIT_MATERIAL := "street_furniture_lit"
const LENS_OFF := Color(0.3, 0.3, 0.3)
## Sound (game/scripts/audio/sound.gd): the hit as it goes over, louder the faster
## the body that felled it and the heavier the prop (a lamp's as before; a light
## sign post's softer, a mast's or pole's at least a heavy lamp's), and the clang of
## its head on the ground, louder the heavier the prop: the tick its turning drops
## to FALL_STOP_SHARE or less of the last tick's once it leans past FALL_LEAN_UP
## (its up's height: past about 60 degrees), or once it lies past FALL_FLAT_UP,
## whichever comes first. Both at the prop's pitch (FELLABLE pitch).
const FALL_LEAN_UP := 0.5
const FALL_FLAT_UP := 0.2
const FALL_STOP_SHARE := 0.6
const FALL_SPIN_MIN := 0.5

## Rows by id: {prop, params, transform, mass, fell_mps, mass_height, mass_arm_m, tip, pitch,
## range_m, foot, height, radius, footprint (half plan size; zero for a round pole),
## footprint_xf, instances: [[MultiMeshInstance3D, index, piece frame]], shapes:
## [CollisionShape3D], labels: [Label3D], spans: [index in _spans]}.
var _rows: Dictionary = {}
## The fellable shapes by physics body RID: {shape index: row id}.
var _shape_rows: Dictionary = {}
## The least fell_mps of any row (m/s): a slower body fells nothing.
var _least_fell_mps := INF
## Felled rows, in the order they fell: id -> the street_detail_id of the body
## that knocked it over ("" for none).
var _felled: Dictionary = {}
var _settling: Array[RigidBody3D] = []
## The hulls a felled prop's mesh collides as (_hulls), by mesh.
var _hulls_by_mesh: Dictionary = {}
## The wire spans of the utility poles: {poles: [id, id], pieces: [[MultiMeshInstance3D,
## first index, count]], wires: [[from, to, sag, radius, pieces]], dropped: the
## MultiMeshInstance3D drawing it from the standing pole to the felled one (null
## while both stand), debris, end (the felled pole's end, 0 or 1), local (that end
## of each wire in the felled pole's frame), gone (both poles felled)}.
var _spans: Array = []
## The shared wire mesh, from the built wires.
var _wire_mesh: Mesh
## The drawn ground over the land (VisibleGround: how far the roads, paths and
## areas drawn over it stand above its collision), set by the vehicle manager.
var visible_ground: VisibleGround
## The lit parts' material once a prop is felled (LENS_OFF), made at the first.
static var _lenses_off: StandardMaterial3D


func configure(furniture_layer: Node) -> void:
	_rows.clear()
	_shape_rows.clear()
	_hulls_by_mesh.clear()
	_spans.clear()
	_least_fell_mps = INF
	_wire_mesh = null
	var root := furniture_layer.get_node_or_null("GeneratedStreetFurniture") as Node3D
	if root == null:
		return
	for span: Dictionary in root.get_meta("fellable_wires", []):
		var pieces: Array = []
		for ref: Array in span.pieces:
			var instance := root.get_node_or_null(str(ref[0])) as MultiMeshInstance3D
			if instance != null and instance.multimesh != null:
				pieces.append([instance, int(ref[1]), int(ref[2])])
				if _wire_mesh == null:
					_wire_mesh = instance.multimesh.mesh
		_spans.append({"poles": span.poles, "pieces": pieces, "wires": span.wires, "dropped": null, "gone": false})
	# Each body's shape index by its CollisionShape3D, read once a body.
	var shape_indices: Dictionary = {}
	var listed: Dictionary = root.get_meta("fellable_rows", {})
	for id: String in listed:
		var entry: Dictionary = listed[id]
		var prop := str(entry.get("prop", ""))
		if not KIT.FELLABLE.has(prop):
			continue
		var kind: Dictionary = KIT.FELLABLE[prop]
		var params: Dictionary = entry.get("params", {})
		var arm: Variant = params.get("arm_m", 4.0)
		var row := {
			"prop": prop, "params": params, "transform": entry.transform,
			"mass": float(kind.mass_kg), "fell_mps": float(kind.get("fell_mps", FELL_SPEED_MPS)),
			"mass_height": float(kind.get("mass_height", MASS_HEIGHT)), "tip": float(kind.get("tip", 1.0)),
			"mass_arm_m": float(kind.get("mass_arm", 0.0)) * (float(arm) if arm is float or arm is int else 4.0),
			"pitch": float(kind.get("pitch", 1.0)), "range_m": float(KIT.PROPS[prop].range_m),
			"instances": [], "shapes": [], "labels": [], "spans": entry.get("spans", []),
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
			if not shape_indices.has(body):
				var by_owner := {}
				for owner_id in body.get_shape_owners():
					by_owner[body.shape_owner_get_owner(owner_id)] = body.shape_owner_get_shape_index(owner_id, 0)
				shape_indices[body] = by_owner
			var by_shape: Dictionary = shape_indices[body]
			if by_shape.has(collision):
				indices.append([body.get_rid(), by_shape[collision]])
		for ref: Array in entry.labels:
			var group := root.get_node_or_null(str(ref[0]))
			var label := group.get_node_or_null(str(ref[1])) as Label3D if group != null else null
			if label != null:
				(row.labels as Array).append(label)
		if not _place(row) or (row.instances as Array).is_empty():
			continue
		_rows[id] = row
		_least_fell_mps = minf(_least_fell_mps, float(row.fell_mps))
		for ref: Array in indices:
			var by_index: Dictionary = _shape_rows.get(ref[0], {})
			by_index[ref[1]] = id
			_shape_rows[ref[0]] = by_index
	_register_warm_up()


## What felled props draw, for the shader warm-up (ShaderWarmUp), as the island
## loads: each fellable prop's meshes as a mesh of its own (_fell; standing, they
## are instances), its lenses with their lamps off (made now, not at the first
## fall) and a dropped span's wires (instances).
func _register_warm_up() -> void:
	var meshes := {}
	for row: Dictionary in _rows.values():
		for ref: Array in row.instances:
			var instance := ref[0] as MultiMeshInstance3D
			if is_instance_valid(instance) and instance.multimesh.mesh != null:
				meshes[instance.multimesh.mesh] = true
	for mesh: Mesh in meshes:
		ShaderWarmUp.add_mesh(mesh, false)
		for surface in mesh.get_surface_count():
			var lit := mesh.surface_get_material(surface)
			if lit != null and lit.resource_name == LIT_MATERIAL:
				ShaderWarmUp.add(_lens_off_material(lit), false)
	ShaderWarmUp.add_mesh(_wire_mesh, true)


## Where a row stands for the reach: a round pole (one upright capsule) by its
## line, from its foot up (foot, height, radius); a prop of several shapes by
## their plan footprint in its own frame (footprint: half sizes; footprint_xf: its
## middle on the ground and its turn; foot that middle; height the top of its
## shapes). False if it has no shape.
func _place(row: Dictionary) -> bool:
	var shapes: Array = row.shapes
	if shapes.is_empty():
		return false
	var placement: Transform3D = row.transform
	row["footprint"] = Vector2.ZERO
	row["footprint_xf"] = Transform3D.IDENTITY
	var first := shapes[0] as CollisionShape3D
	if shapes.size() == 1 and first.shape is CapsuleShape3D:
		var capsule := first.shape as CapsuleShape3D
		row["foot"] = first.global_position - Vector3.UP * capsule.height * 0.5
		row["height"] = capsule.height
		row["radius"] = capsule.radius
		return true
	var to_prop := placement.affine_inverse()
	var plan := AABB()
	for index in shapes.size():
		var collision := shapes[index] as CollisionShape3D
		var piece := (to_prop * collision.global_transform) * VehicleReach.shape_box(collision.shape)
		plan = piece if index == 0 else plan.merge(piece)
	var middle := placement * Vector3(plan.get_center().x, 0.0, plan.get_center().z)
	row["foot"] = middle
	row["height"] = plan.end.y
	row["radius"] = 0.0
	row["footprint"] = Vector2(plan.size.x, plan.size.z) * 0.5
	row["footprint_xf"] = Transform3D(placement.basis, middle)
	return true


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


## A row's prop ("" if it is not a fellable row).
func prop_of(id: String) -> String:
	return str((_rows.get(id, {}) as Dictionary).get("prop", ""))


## How fast a body must meet a row to knock it over (m/s; INF if it is not a
## fellable row).
func fell_speed(id: String) -> float:
	return float((_rows.get(id, {}) as Dictionary).get("fell_mps", INF))


## The share of its speed a car of car_mass keeps knocking a row over.
func keeps(id: String, car_mass: float) -> float:
	var row: Dictionary = _rows.get(id, {})
	return car_mass / (car_mass + float(row.mass)) if not row.is_empty() else 1.0


## A row as the reach meets it: {foot, height, radius, footprint, footprint_xf}
## ({} if it is not a fellable row).
func pole(id: String) -> Dictionary:
	var row: Dictionary = _rows.get(id, {})
	return {} if row.is_empty() else {"foot": row.foot, "height": row.height, "radius": row.radius, "footprint": row.footprint, "footprint_xf": row.footprint_xf}


## The meshes (their resource names) of the pieces that go over with a row: not a
## piece that stays where it stood (a bus stop's pad). [] for a row that is not
## fellable.
func piece_names(id: String) -> PackedStringArray:
	var names := PackedStringArray()
	for ref: Array in (_rows.get(id, {}) as Dictionary).get("instances", []):
		names.append((ref[0] as MultiMeshInstance3D).multimesh.mesh.resource_name)
	return names


## Whether every piece of a fellable row keeps the slices it lies on when felled
## (its mesh's fall_slices, which the baked world must carry too): the ids of the
## rows with a piece that has none.
func rows_without_slices() -> Array[String]:
	var missing: Array[String] = []
	for id: String in _rows:
		for ref: Array in _rows[id].instances:
			var mesh := (ref[0] as MultiMeshInstance3D).multimesh.mesh
			if (mesh.get_meta("fall_slices", []) as Array).is_empty():
				missing.append(id)
				break
	return missing


## The wire spans a felled utility pole held up, as drawn now: per span {standing
## (the other pole's id), wires: [[from, to]] (from at the standing pole)}, or
## gone: true for a span between two felled poles. [] for a row with none.
func dropped_wires(id: String) -> Array:
	var found: Array = []
	for index: int in (_rows.get(id, {}) as Dictionary).get("spans", []):
		var span: Dictionary = _spans[index]
		if bool(span.gone):
			found.append({"gone": true})
		elif span.dropped != null:
			var ends: Array = []
			for wire_index in (span.wires as Array).size():
				ends.append(_wire_ends(span, wire_index))
			found.append({"standing": str(span.poles[1 - int(span.end)]), "wires": ends})
	return found


## A fellable prop's shape in a moving body's reach: it falls if the body's box
## meets it within FELL_TICKS ticks coming on at its fell_mps or more.
func reach_pole(reach: VehicleReach, hit: Dictionary) -> void:
	if reach.speed < _least_fell_mps:
		return
	var by_index: Dictionary = _shape_rows.get(hit.get("rid", RID()), {})
	var id := str(by_index.get(int(hit.get("shape", -1)), ""))
	if id == "" or _felled.has(id):
		return
	var row: Dictionary = _rows[id]
	if reach.speed < float(row.fell_mps):
		return
	var contact := reach.pole_contact(row.foot, row.height, row.radius, reach.delta * FELL_TICKS, row.footprint, row.footprint_xf)
	if contact.is_empty() or float(contact.closing) < float(row.fell_mps):
		return
	fell(id, reach.body)


## Fells a row: hides it, opens its shapes, drops it as debris knocked by the
## body (null: straight over, nothing slowed), and its wires with it.
func fell(id: String, by: RigidBody3D = null) -> void:
	if _felled.has(id) or not _rows.has(id):
		return
	var row: Dictionary = _rows[id]
	_felled[id] = str(by.get_meta("street_detail_id", "")) if by != null else ""
	var placement: Transform3D = row.transform
	var mass := float(row.mass)
	var height := float(row.height)
	var debris := RigidBody3D.new()
	debris.name = "Felled%d" % _felled.size()
	debris.collision_layer = 0
	debris.collision_mask = PHYSICS_WORLD_SOLID | PHYSICS_STREET_PROP
	debris.mass = mass
	debris.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	# Up its pole, and out along a mast's arm over the road (-Z).
	debris.center_of_mass = Vector3.UP * height * float(row.mass_height) + Vector3.FORWARD * float(row.mass_arm_m)
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
	debris.set_meta("height", height)
	debris.set_meta("pitch", float(row.pitch))
	debris.set_meta("spin", 0.0)
	debris.set_meta("landed", false)
	var hit_speed := by.linear_velocity.length() if by != null else 8.0
	Sound.play(&"lamp_hit", (row.foot as Vector3) + Vector3.UP * minf(0.9, height * 0.6), hit_strength(hit_speed, mass), float(row.pitch))
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
		# Its lit lenses go out.
		for surface_index in mesh.mesh.get_surface_count():
			var lit := mesh.mesh.surface_get_material(surface_index)
			if lit != null and lit.resource_name == LIT_MATERIAL:
				mesh.set_surface_override_material(surface_index, _lens_off_material(lit))
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
	_drop_wires(id, debris)
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
	var keep := by.mass / (by.mass + mass)
	by.linear_velocity = velocity * keep
	# Off the body's middle line, toward the side of it the prop stood on.
	var right := way.cross(Vector3.UP)
	var aside := right if (placement.origin - by.global_position).dot(right) >= 0.0 else -right
	var foot := way * minf(speed * keep * FOOT_CARRY, FOOT_MAX_MPS) + aside * FOOT_ASIDE_MPS + Vector3.UP * POP_MPS
	# Turning about UP x toward tips its top toward where it goes, about its foot
	# (a footprint about its edge that way): its weight moves on by the turn round
	# that pivot as well as the foot's own way.
	var toward := (aside + way * FALL_AHEAD).normalized()
	var spin := Vector3.UP.cross(toward) * TIP_RADPS * float(row.tip) * clampf(speed / 10.0, 0.7, 1.4)
	var pivot := placement.origin
	var footprint: Vector2 = row.footprint
	if footprint != Vector2.ZERO:
		var turn: Basis = (row.footprint_xf as Transform3D).basis
		pivot = (row.foot as Vector3) + toward * (footprint.x * absf(toward.dot(turn.x)) + footprint.y * absf(toward.dot(turn.z)))
	debris.angular_velocity = spin
	debris.linear_velocity = foot + spin.cross(placement * debris.center_of_mass - pivot)


## What a felled prop's lit parts are drawn with: the lit material's atlas and
## vertex colours, shaded and darkened (LENS_OFF), as a lens with its lamp off.
static func _lens_off_material(lit: Material) -> StandardMaterial3D:
	if _lenses_off == null:
		_lenses_off = StandardMaterial3D.new()
		_lenses_off.resource_name = "street_furniture_lens_off"
		var source := lit as BaseMaterial3D
		if source != null:
			_lenses_off.albedo_texture = source.albedo_texture
			_lenses_off.texture_filter = source.texture_filter
			_lenses_off.texture_repeat = source.texture_repeat
		_lenses_off.vertex_color_use_as_albedo = true
		_lenses_off.vertex_color_is_srgb = true
		_lenses_off.albedo_color = LENS_OFF
		_lenses_off.roughness = 0.35
	return _lenses_off


## The hit's loudness for a prop of mass (kg) met at speed (m/s): a lamp's
## (70 to 180 kg) as it always was, a lighter prop's softer, a heavier one's louder.
static func hit_strength(speed: float, mass: float) -> float:
	return clampf((0.4 + speed / 25.0 + maxf(mass - 180.0, 0.0) / 1500.0) * clampf(sqrt(mass / 70.0), 0.6, 1.0), 0.25, 1.0)


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


## A felled pole's wire spans: each hung from a standing pole now runs slack from
## that pole down to this one's debris (a MultiMesh of its own), its standing
## pieces drawn at zero scale where each was; one whose other pole fell before is
## gone.
func _drop_wires(id: String, debris: RigidBody3D) -> void:
	var row: Dictionary = _rows[id]
	var to_pole := (row.transform as Transform3D).affine_inverse()
	for index: int in row.spans:
		var span: Dictionary = _spans[index]
		if bool(span.gone):
			continue
		if span.dropped != null:
			(span.dropped as Node).queue_free()
			span.dropped = null
			span.gone = true
			continue
		_hide_span(span)
		if _wire_mesh == null:
			span.gone = true
			continue
		var end := 0 if str(span.poles[0]) == id else 1
		var local: Array[Vector3] = []
		var count := 0
		for wire: Array in span.wires:
			local.append(to_pole * (wire[end] as Vector3))
			count += maxi(int(wire[4]), DROP_PIECES)
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_custom_data = true
		multimesh.mesh = _wire_mesh
		multimesh.instance_count = count
		# Each piece's radius, for the wire shader, once.
		var at := 0
		for wire: Array in span.wires:
			for _piece in maxi(int(wire[4]), DROP_PIECES):
				multimesh.set_instance_custom_data(at, Color(float(wire[3]), 0.0, 0.0, 0.0))
				at += 1
		var drawn := MultiMeshInstance3D.new()
		drawn.name = "Wires%d" % index
		drawn.multimesh = multimesh
		drawn.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		drawn.visibility_range_end = KIT.WIRE_RANGE_M
		add_child(drawn)
		span.dropped = drawn
		span.debris = debris
		span.end = end
		span.local = local
		# The ground under its ends: the standing pole's foot and this one's.
		var standing: Dictionary = _rows.get(str(span.poles[1 - end]), {})
		var foot_y := (row.transform as Transform3D).origin.y
		span.floors = [(standing.transform as Transform3D).origin.y if not standing.is_empty() else foot_y, foot_y]
		_hang_dropped(span)
	debris.set_meta("spans", row.spans)


## Draws a span's standing pieces at zero scale, each where it hung (worked out
## again from its wires as the builder hung them, cell by cell), so the cells'
## batches keep their bounds.
func _hide_span(span: Dictionary) -> void:
	var runs: Array = span.pieces
	var origins: Array = []
	var run_of := {}
	for run_index in runs.size():
		origins.append([])
		var instance := runs[run_index][0] as MultiMeshInstance3D
		if is_instance_valid(instance):
			run_of[String(instance.name)] = run_index
	for wire: Array in span.wires:
		var middles: Array[Vector3] = []
		var pieces := BUILDER.wire_pieces(wire[0], wire[1], float(wire[2]), float(wire[3]), int(wire[4]), middles)
		for piece_index in pieces.size():
			var middle := middles[piece_index]
			var run_index := int(run_of.get("power_wire__c%d_%d" % [floori(middle.x / BUILDER.CELL_MAX_M), floori(middle.z / BUILDER.CELL_MAX_M)], -1))
			if run_index >= 0:
				(origins[run_index] as Array).append(pieces[piece_index].origin)
	for run_index in runs.size():
		var instance := runs[run_index][0] as MultiMeshInstance3D
		if not is_instance_valid(instance):
			continue
		var placed: Array = origins[run_index]
		for k in int(runs[run_index][2]):
			var origin: Vector3 = placed[k] if k < placed.size() else (span.wires[0][0] as Vector3)
			instance.multimesh.set_instance_transform(int(runs[run_index][1]) + k, Transform3D(Basis().scaled(Vector3.ZERO), origin))


## A wire of a dropped span: [from (at the standing pole), to (at the felled one)].
func _wire_ends(span: Dictionary, wire_index: int) -> Array:
	var wire: Array = span.wires[wire_index]
	var debris := span.debris as RigidBody3D
	var fallen: Vector3 = debris.global_transform * (span.local[wire_index] as Vector3) if is_instance_valid(debris) else wire[span.end]
	return [wire[1 - int(span.end)], fallen]


## Draws a dropped span's wires where its felled pole is now: slacker the further
## it has gone over (from their own sag standing to DROP_SAG lying), never under
## the ground between the two poles' feet.
func _hang_dropped(span: Dictionary) -> void:
	var drawn := span.dropped as MultiMeshInstance3D
	if drawn == null:
		return
	var debris := span.debris as RigidBody3D
	var over := clampf(1.0 - debris.global_transform.basis.y.y, 0.0, 1.0) if is_instance_valid(debris) else 1.0
	var floors: Array = span.floors
	var unused: Array[Vector3] = []
	var at := 0
	for wire_index in (span.wires as Array).size():
		var wire: Array = span.wires[wire_index]
		var ends := _wire_ends(span, wire_index)
		for piece: Transform3D in BUILDER.wire_pieces(ends[0], ends[1], lerpf(float(wire[2]), DROP_SAG, over), float(wire[3]), maxi(int(wire[4]), DROP_PIECES), unused, float(floors[0]), float(floors[1])):
			drawn.multimesh.set_instance_transform(at, piece)
			at += 1


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
		if not debris.has_meta("kerb_ramps"):
			_pass_kerb_ramps(debris)
		var age := float(debris.get_meta("age", 0.0)) + delta
		debris.set_meta("age", age)
		_sound_landing(debris)
		for span_index: int in debris.get_meta("spans", []):
			var span: Dictionary = _spans[span_index]
			if span.dropped != null and span.debris == debris:
				_hang_dropped(span)
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
			var lift := _onto_drawn_ground(debris)
			debris.set_meta("drawn_lift_m", lift)
			if lift > 0.0:
				# Its wires end on its lifted crossarm.
				for span_index: int in debris.get_meta("spans", []):
					var span: Dictionary = _spans[span_index]
					if span.dropped != null and span.debris == debris:
						_hang_dropped(span)
			for shape: Node in debris.find_children("*", "CollisionShape3D", false, false):
				(shape as CollisionShape3D).disabled = true


## A felled prop come to rest on the ground, put on the ground that is drawn there:
## the roads, paths and areas drawn over the land stand a few centimetres above its
## collision (VisibleGround), so a prop lying on the land would lie in a paved walk
## by that much. The lowest of its hulls' points in each REST_CELL_M square (under
## all of it, so a long pole's uphill end is looked under too) looks straight down
## once, at rest, never while it moves, through the invisible kerb ramps: only the
## land counts, its ground drawn there its height and the drawn lift over it.
## Anything else solid (a kerb, steps, a plinth) is drawn where its collision is,
## and a point over one is skipped, so a prop lying in a gutter against a kerb's
## face is not lifted to the kerb's top (code review, 2026-11-14). The prop is
## lifted as a whole by the deepest point's depth under the drawn land (no more
## than REST_LIFT_MAX_M: deeper is something over it, not ground). The lift (m), 0
## when none.
func _onto_drawn_ground(debris: RigidBody3D) -> float:
	var cells := {}
	for child: Node in debris.get_children():
		var collision := child as CollisionShape3D
		if collision == null or not collision.shape is ConvexPolygonShape3D:
			continue
		var xf := debris.global_transform * collision.transform
		for point: Vector3 in (collision.shape as ConvexPolygonShape3D).points:
			var at := xf * point
			var cell := Vector2i(floori(at.x / REST_CELL_M), floori(at.z / REST_CELL_M))
			if not cells.has(cell) or at.y < (cells[cell] as Vector3).y:
				cells[cell] = at
	var space := debris.get_world_3d().direct_space_state
	var lift := 0.0
	for at: Vector3 in cells.values():
		var hit := _ground_under(space, at, debris.get_meta("kerb_ramps", []))
		if hit.is_empty() or feature_kind(hit.collider) != LAND_KIND:
			continue
		var depth := (hit.position as Vector3).y + (visible_ground.lift_at(at.x, at.z) if visible_ground != null else 0.0) - at.y
		if depth <= REST_LIFT_MAX_M:
			lift = maxf(lift, depth)
	if lift > 0.0:
		debris.global_position += Vector3.UP * lift
	return lift


## The first world solid straight under a point (from REST_RAY_M over it to as far
## under it) that is not an invisible kerb ramp: {} or the ray's hit.
static func _ground_under(space: PhysicsDirectSpaceState3D, at: Vector3, ramps: Array) -> Dictionary:
	var ray := PhysicsRayQueryParameters3D.create(at + Vector3.UP * REST_RAY_M, at - Vector3.UP * REST_RAY_M, PHYSICS_WORLD_SOLID)
	ray.hit_back_faces = false
	var exclude: Array[RID] = []
	exclude.assign(ramps)
	for _attempt in 3:
		ray.exclude = exclude
		var hit := space.intersect_ray(ray)
		if hit.is_empty() or feature_kind(hit.collider) != KERB_RAMP_KIND:
			return hit
		exclude.append(hit.rid)
	return {}


## The kind of world feature a world body belongs to (its parent's feature_kind:
## the generated chunk records' collision bodies), "" for any other body.
static func feature_kind(body: Variant) -> String:
	var node := body as Node
	return str(node.get_parent().get_meta("feature_kind", "")) if node != null and node.get_parent() != null else ""


## A felled prop falls through the invisible ramps in front of the kerbs' faces
## (code review, 2026-11-14: they are there so the stock player walks on and off a
## kerb; resting on one, a prop in a gutter lay up to a kerb's height over the
## gutter that is drawn), onto the gutter and against the kerb's face: those within
## its height and RAMP_REACH_M of where it is on its first tick down (where it
## stood), looked for once. Their RIDs in its kerb_ramps metadata.
func _pass_kerb_ramps(debris: RigidBody3D) -> void:
	var sphere := SphereShape3D.new()
	sphere.radius = float(debris.get_meta("height", 4.0)) + RAMP_REACH_M
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(Basis.IDENTITY, debris.global_position)
	query.collision_mask = PHYSICS_WORLD_SOLID
	var ramps: Array[RID] = []
	for hit: Dictionary in debris.get_world_3d().direct_space_state.intersect_shape(query, RAMP_QUERY_MAX):
		var body := hit.get("collider") as PhysicsBody3D
		if body != null and feature_kind(body) == KERB_RAMP_KIND and not ramps.has(body.get_rid()):
			debris.add_collision_exception_with(body)
			ramps.append(body.get_rid())
	debris.set_meta("kerb_ramps", ramps)


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
	Sound.play(&"lamp_fall", head, clampf(0.45 + debris.mass / 300.0, 0.5, 1.0), float(debris.get_meta("pitch", 1.0)))


## Whether a body at rest touches only the world (the ground, a wall), nothing on
## the street-prop layer (a parked car, a fence) that could move or break away.
static func _on_the_ground(debris: RigidBody3D) -> bool:
	for other: Node3D in debris.get_colliding_bodies():
		var body := other as CollisionObject3D
		if body != null and body.collision_layer & PHYSICS_STREET_PROP:
			return false
	return true
