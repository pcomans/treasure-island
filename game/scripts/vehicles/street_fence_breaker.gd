extends Node3D
## Fences a driven car breaks through (owner, 2026-11-08), one bay at a time,
## without un-batching the fence meshes.
##
## street_fence_builder.gd leaves each fence row one static body with a box per
## bay (the stock player still collides with every intact bay) and, per cell
## mesh, the vertex ranges of each bay's own geometry (its rails, fabric,
## screen, slats or panel frame) and of each post (a panel fence's stand and
## clamp). A live car or K-rail has a collision exception with every breakable
## fence body, so it never bounces off a fence; each tick a moving one's hull is
## tested against the fence bays it overlaps (vehicle_manager.gd: the driven car
## always, a shoved or rolling one while it moves). A bay it touches breaks: its
## vertices in the cell meshes collapse to a point
## (ArrayMesh.surface_update_vertex_region, a few hundred bytes on either
## renderer), its box is disabled, so the gap is open on foot too, and the
## fence kit builds that bay alone as a light debris body that topples away from
## the car, settles and stays, visual only. The two posts a broken bay hung
## between stand until a moving hull touches one (tested against the post's
## box): then it goes down the same way, as its own debris, toppling away from
## the car; a post nothing touched stays, so the intact bays beside a gap still
## look held up. Broken bays and felled posts are kept by fence row and key
## (keys repeat from row to row) and stay so for the session; a restart
## rebuilds the world.
##
## A fence row whose params say "breakable": false (the Job Corps perimeter,
## owner 2026-11-08) gets no exception and no break: a car stops at it like a
## wall. The wheels' rays skip every fence, breakable or not, so a wheel never
## stands on a fence's top.

const FENCE_KIT := preload("res://game/scripts/world/street_fence_kit.gd")
const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
const RENDER_WORLD_VISIBLE := 1
## Debris mass (kg) per fence type, per metre of bay.
const DEBRIS_KG_PER_M := {
	"chain_link": 10.0, "chain_link_barbed": 12.0, "chain_link_screened": 12.0, "chain_link_slatted": 16.0,
	"construction_panel": 12.0, "wood_privacy": 22.0, "steel_picket": 20.0, "ball_stop_net": 6.0,
}
## How the debris leaves: a share of the car's velocity, a pop up (m/s) and a
## tip about the bay's line (rad/s).
const DEBRIS_CARRY := 0.6
const DEBRIS_POP_MPS := 1.6
const DEBRIS_TIP_RADPS := 2.2
## A felled post's mass (kg) per fence type.
const POST_KG := {
	"chain_link": 8.0, "chain_link_barbed": 10.0, "chain_link_screened": 8.0, "chain_link_slatted": 8.0,
	"construction_panel": 14.0, "wood_privacy": 12.0, "steel_picket": 10.0, "ball_stop_net": 60.0,
}
## A post is tested against a moving hull within this distance of its foot (m).
const POST_REACH_M := 6.0
## Debris settles (frozen, no collision) after this long at rest, or at most
## after DEBRIS_SETTLE_MAX_S; past DEBRIS_KEEP settled pieces the oldest piece
## goes (its bay stays broken).
const DEBRIS_REST_S := 0.6
const DEBRIS_SETTLE_MAX_S := 6.0
const DEBRIS_KEEP := 400
const DEBRIS_RANGE_M := 150.0
## The car keeps going: each bay takes this share of its speed.
const SPEED_SHARE_PER_BAY := 0.03

var _kit: FENCE_KIT
## Breakable fence bodies by RID; their bays by shape owner.
var _bodies: Dictionary = {}
var _rids: Array[RID] = []
## Every fence body, breakable or not.
var _all_rids: Array[RID] = []
var _query := PhysicsShapeQueryParameters3D.new()
var _post_query := PhysicsShapeQueryParameters3D.new()
var _post_box := BoxShape3D.new()
var _settled: Array[RigidBody3D] = []
## Broken bays and felled posts by fence_id(): "ROW_ID|KEY" -> true, in order.
var _broken := {}
var _felled := {}
## The standing posts of broken bays, "ROW_ID|KEY" -> [group, key]: what a
## moving hull is tested against.
var _exposed := {}


func configure(fences_layer: Node) -> void:
	_bodies.clear()
	_rids.clear()
	_all_rids.clear()
	_query.collision_mask = PHYSICS_STREET_PROP
	_query.collide_with_areas = false
	_post_query.collision_mask = PHYSICS_STREET_PROP
	_post_query.collide_with_areas = false
	_post_query.shape = _post_box
	for body: Node in fences_layer.find_children("Collision", "StaticBody3D", true, false):
		var fence := body as StaticBody3D
		if str(fence.get_meta("street_detail_kind", "")) != "fence":
			continue
		_all_rids.append(fence.get_rid())
		if not bool(fence.get_meta("breakable", true)):
			continue
		var group := fence.get_parent() as Node3D
		if group == null or not group.has_meta("fence_bays"):
			continue
		_bodies[fence.get_rid()] = {"body": fence, "group": group}
		_rids.append(fence.get_rid())


## The breakable fence bodies a live car or K-rail passes through (breaking them).
func fence_bodies() -> Array[RID]:
	return _rids.duplicate()


## Every fence body, breakable or not: what the wheels' rays skip.
func all_fence_bodies() -> Array[RID]:
	return _all_rids.duplicate()


func broken_count() -> int:
	return _broken.size()


## A bay's or post's identity across every fence: its fence row's
## street_detail_id and its key (a bay's "run:index" or a post's "prun:index",
## which repeat from row to row).
static func fence_id(group: Node3D, key: String) -> String:
	return "%s|%s" % [str(group.get_meta("street_detail_id", group.name)), key]


func is_broken(group: Node3D, bay_key: String) -> bool:
	return _broken.has(fence_id(group, bay_key))


## The broken bays (fence_id), in the order they broke.
func broken_keys() -> Array:
	return _broken.keys()


func is_post_felled(group: Node3D, post_key: String) -> bool:
	return _felled.has(fence_id(group, post_key))


## The felled posts (fence_id), in the order they went down.
func felled_keys() -> Array:
	return _felled.keys()


## Breaks every intact bay the car's (or K-rail's) reach overlaps now
## (DrivableCar.reach_queries: a car's box round its hull, whose pieces queried
## against the cars beside it cost milliseconds a tick).
func break_overlaps(car: RigidBody3D) -> void:
	if _bodies.is_empty() or car == null:
		return
	var space := car.get_world_3d().direct_space_state
	_query.exclude = [car.get_rid()]
	for reach: Dictionary in DrivableCar.reach_queries(car, 0.05):
		_query.shape = reach.shape
		_query.margin = reach.margin
		_query.transform = car.global_transform * (reach.transform as Transform3D)
		for hit: Dictionary in space.intersect_shape(_query, 16):
			var rid: RID = hit.get("rid", RID())
			if not _bodies.has(rid):
				continue
			var fence: StaticBody3D = _bodies[rid].body
			var shape_owner := fence.shape_find_owner(int(hit.get("shape", -1)))
			var shape := fence.shape_owner_get_owner(shape_owner) as CollisionShape3D if shape_owner >= 0 else null
			if shape != null and not shape.disabled:
				break_bay(_bodies[rid].group, shape, car.linear_velocity)
				car.linear_velocity *= 1.0 - SPEED_SHARE_PER_BAY
	_fell_touched_posts(car)


## Breaks one bay: hides its geometry, opens its box and drops its debris; the
## posts it hung between now go down where a moving hull touches them.
func break_bay(group: Node3D, shape: CollisionShape3D, velocity: Vector3) -> void:
	var key := str(shape.get_meta("fence_bay", ""))
	if key == "" or _broken.has(fence_id(group, key)):
		return
	var bays: Dictionary = group.get_meta("fence_bays", {})
	if not bays.has(key):
		return
	var bay: Dictionary = bays[key]
	shape.disabled = true
	_broken[fence_id(group, key)] = true
	_collapse_ranges(group, bay.get("ranges", []))
	_drop_debris(group, bay, velocity)
	for post_key: Variant in bay.get("posts", []):
		var id := fence_id(group, str(post_key))
		if not _felled.has(id):
			_exposed[id] = [group, str(post_key)]


## Fells every standing post of a broken bay that the car's (or K-rail's) hull
## touches now: the post's box, grown by a few centimetres, meets the hull.
func _fell_touched_posts(car: RigidBody3D) -> void:
	if _exposed.is_empty():
		return
	var space := car.get_world_3d().direct_space_state
	var at := car.global_position
	_post_query.margin = 0.03
	for id: String in _exposed.keys():
		var holder: Variant = _exposed[id][0]
		var key := str(_exposed[id][1])
		var group: Node3D = holder as Node3D if is_instance_valid(holder) else null
		var post: Dictionary = (group.get_meta("fence_posts", {}) as Dictionary).get(key, {}) if group != null else {}
		if post.is_empty():
			_exposed.erase(id)
			continue
		var foot: Vector3 = post.frame.foot
		if Vector2(foot.x - at.x, foot.z - at.z).length() > POST_REACH_M:
			continue
		_post_box.size = post.size
		_post_query.transform = _post_transform(post)
		for hit: Dictionary in space.intersect_shape(_post_query, 8):
			if hit.get("rid", RID()) == car.get_rid():
				fell_post(group, key, car.linear_velocity)
				break


## A post's box in the world: along the run, up from its foot, along its normal.
static func _post_transform(post: Dictionary) -> Transform3D:
	var normal: Vector3 = post.frame.normal
	var size: Vector3 = post.size
	return Transform3D(Basis(Vector3.UP.cross(normal).normalized(), Vector3.UP, normal), (post.frame.foot as Vector3) + Vector3.UP * size.y * 0.5)


## Fells one post: hides its geometry and drops it as debris, toppling the way
## the car went.
func fell_post(group: Node3D, post_key: String, velocity: Vector3) -> void:
	var id := fence_id(group, post_key)
	if _felled.has(id):
		return
	var post: Dictionary = (group.get_meta("fence_posts", {}) as Dictionary).get(post_key, {})
	if post.is_empty():
		return
	_felled[id] = true
	_exposed.erase(id)
	_collapse_ranges(group, post.get("ranges", []))
	_drop_post(group, post, velocity)


## Collapses each of [[mesh instance, surface, first vertex, count], ...].
static func _collapse_ranges(group: Node3D, ranges: Array) -> void:
	for ref: Array in ranges:
		var instance := group.get_node_or_null(str(ref[0])) as MeshInstance3D
		if instance != null and instance.mesh is ArrayMesh:
			_collapse(instance.mesh as ArrayMesh, int(ref[1]), int(ref[2]), int(ref[3]))


## Draws vertices [from, from + count) of a surface at one point: their
## triangles have no area and so draw nothing.
static func _collapse(mesh: ArrayMesh, surface: int, from: int, count: int) -> void:
	if surface < 0 or surface >= mesh.get_surface_count() or count <= 0:
		return
	var format := mesh.surface_get_format(surface)
	var vertices := mesh.surface_get_array_len(surface)
	if from + count > vertices:
		return
	var stride := RenderingServer.mesh_surface_get_format_vertex_stride(format, vertices)
	var position_offset := RenderingServer.mesh_surface_get_format_offset(format, vertices, Mesh.ARRAY_VERTEX)
	var position_bytes := 12
	var data := PackedByteArray()
	if stride == position_bytes and position_offset == 0:
		# Positions are a block of their own: one contiguous write.
		data.resize(count * position_bytes)
		data.fill(0)
		mesh.surface_update_vertex_region(surface, from * position_bytes, data)
	else:
		# Interleaved: the whole span, positions at their offset, the rest zero.
		data.resize(count * stride)
		data.fill(0)
		mesh.surface_update_vertex_region(surface, from * stride, data)


## A felled post as a light debris body standing where it stood, pushed the
## way the car went and tipping over away from it.
func _drop_post(group: Node3D, post: Dictionary, velocity: Vector3) -> void:
	if _kit == null:
		_kit = FENCE_KIT.new()
	var type := str(group.get_meta("fence_type", ""))
	if not FENCE_KIT.TYPES.has(type):
		return
	var frame: Dictionary = (post.frame as Dictionary).duplicate()
	var foot: Vector3 = frame.foot
	frame.foot = Vector3.ZERO
	var cells := {}
	_kit.add_post(cells, 1.0e6, type, group.get_meta("fence_params", {}), frame)
	var debris := RigidBody3D.new()
	debris.name = "FencePost%d" % _felled.size()
	debris.collision_layer = 0
	debris.collision_mask = PHYSICS_WORLD_SOLID
	debris.mass = float(POST_KG.get(type, 10.0))
	debris.can_sleep = true
	debris.set_meta("street_detail_kind", "fence_debris")
	debris.set_meta("age", 0.0)
	for key: String in cells:
		var parts: Dictionary = _kit.commit(cells[key])
		if parts.solid == null:
			continue
		var instance := MeshInstance3D.new()
		instance.mesh = parts.solid
		instance.layers = RENDER_WORLD_VISIBLE
		instance.visibility_range_end = DEBRIS_RANGE_M
		debris.add_child(instance)
	var box := BoxShape3D.new()
	box.size = post.size
	var collision := CollisionShape3D.new()
	collision.shape = box
	collision.transform = Transform3D(_post_transform(post).basis, Vector3.UP * (post.size as Vector3).y * 0.5)
	debris.add_child(collision)
	debris.position = foot
	add_child(debris)
	var push := Vector3(velocity.x, 0.0, velocity.z)
	debris.linear_velocity = push * DEBRIS_CARRY + Vector3.UP * DEBRIS_POP_MPS * 0.5
	# Turning about UP x push tips its top the way the car went.
	if push.length() > 0.01:
		debris.angular_velocity = Vector3.UP.cross(push.normalized()) * DEBRIS_TIP_RADPS * clampf(push.length() / 8.0, 0.4, 1.5)


func _drop_debris(group: Node3D, bay: Dictionary, velocity: Vector3) -> void:
	if _kit == null:
		_kit = FENCE_KIT.new()
	var a: Vector3 = bay.a
	var b: Vector3 = bay.b
	var type := str(bay.type)
	var middle := (a + b) * 0.5
	var along := Vector3(b.x - a.x, 0.0, b.z - a.z)
	var length := along.length()
	if length < 0.2:
		return
	along /= length
	var local_a := a - middle
	var local_b := b - middle
	var cells := {}
	var params: Dictionary = bay.get("params", {})
	_kit.add_run(cells, 1.0e6, type, params, PackedVector3Array([local_a, local_b]), int(bay.get("seed", 0)), true)
	var debris := RigidBody3D.new()
	debris.name = "FenceDebris%d" % _broken.size()
	debris.collision_layer = 0
	debris.collision_mask = PHYSICS_WORLD_SOLID
	debris.mass = maxf(8.0, float(DEBRIS_KG_PER_M.get(type, 12.0)) * length)
	debris.can_sleep = true
	debris.set_meta("street_detail_kind", "fence_debris")
	debris.set_meta("age", 0.0)
	var height := FENCE_KIT.height_of(type, params)
	for key: String in cells:
		var parts: Dictionary = _kit.commit(cells[key])
		for part: Array in [[parts.solid, GeometryInstance3D.SHADOW_CASTING_SETTING_ON], [parts.fabric, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF], [parts.shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY]]:
			if part[0] == null:
				continue
			var instance := MeshInstance3D.new()
			instance.mesh = part[0]
			instance.cast_shadow = part[1]
			instance.layers = RENDER_WORLD_VISIBLE
			instance.visibility_range_end = DEBRIS_RANGE_M
			debris.add_child(instance)
	var box := BoxShape3D.new()
	box.size = Vector3(length, height, 0.12)
	var collision := CollisionShape3D.new()
	collision.shape = box
	collision.basis = Basis(along, Vector3.UP, along.cross(Vector3.UP))
	collision.position = Vector3(0.0, (a.y + b.y) * 0.5 - middle.y + height * 0.5, 0.0)
	debris.add_child(collision)
	debris.position = middle
	add_child(debris)
	# Pushed the way the car went, popped up and tipped over away from it.
	var push := Vector3(velocity.x, 0.0, velocity.z)
	debris.linear_velocity = push * DEBRIS_CARRY + Vector3.UP * DEBRIS_POP_MPS
	# Turning about the bay's line tips its top toward along x up: away from the car.
	var tip_axis := along if along.cross(Vector3.UP).dot(push) > 0.0 else -along
	debris.angular_velocity = tip_axis * DEBRIS_TIP_RADPS * clampf(push.length() / 8.0, 0.3, 1.5)


func _physics_process(_delta: float) -> void:
	for child: Node in get_children():
		var debris := child as RigidBody3D
		if debris == null or debris.freeze:
			continue
		var age := float(debris.get_meta("age", 0.0)) + _delta
		debris.set_meta("age", age)
		var resting := debris.linear_velocity.length() < 0.15 and debris.angular_velocity.length() < 0.2
		if resting:
			debris.set_meta("rest", float(debris.get_meta("rest", 0.0)) + _delta)
		else:
			debris.set_meta("rest", 0.0)
		if float(debris.get_meta("rest", 0.0)) >= DEBRIS_REST_S or age >= DEBRIS_SETTLE_MAX_S:
			debris.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
			debris.freeze = true
			for shape: Node in debris.find_children("*", "CollisionShape3D", false, false):
				(shape as CollisionShape3D).disabled = true
			_settled.append(debris)
			if _settled.size() > DEBRIS_KEEP:
				var oldest: RigidBody3D = _settled.pop_front()
				if is_instance_valid(oldest):
					oldest.queue_free()
