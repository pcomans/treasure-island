extends Node3D
## Fences a driven car breaks through (owner, 2026-11-08), one bay at a time,
## without un-batching the fence meshes.
##
## street_fence_builder.gd leaves each fence row one static body with a box per
## bay (the stock player still collides with every intact bay) and, per cell
## mesh, the vertex ranges of each bay's own geometry (its rails, fabric,
## screen, slats or panel frame; posts and panel stands stay standing). A live
## car has a collision exception with every breakable fence body, so it never
## bounces off a fence; each tick its hull is tested against the fence bays it
## overlaps. A bay it touches breaks: its vertices in the cell meshes collapse
## to a point (ArrayMesh.surface_update_vertex_region, a few hundred bytes on
## either renderer), its box is disabled, so the gap is open on foot too, and the
## fence kit builds that bay alone as a light debris body that topples away from
## the car, settles and stays, visual only. Broken bays stay broken for the
## session; a restart rebuilds the world.
##
## A fence row whose params say "breakable": false (the Job Corps perimeter,
## owner 2026-11-08) gets no exception and no break: a car stops at it like a wall.

const FENCE_KIT := preload("res://game/scripts/world/street_fence_kit.gd")
const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
const RENDER_WORLD_VISIBLE := 1
## Debris mass (kg) per fence type, per metre of bay.
const DEBRIS_KG_PER_M := {
	"chain_link": 10.0, "chain_link_barbed": 12.0, "chain_link_screened": 12.0, "chain_link_slatted": 16.0,
	"construction_panel": 12.0, "wood_privacy": 22.0, "steel_picket": 20.0,
}
## How the debris leaves: a share of the car's velocity, a pop up (m/s) and a
## tip about the bay's line (rad/s).
const DEBRIS_CARRY := 0.6
const DEBRIS_POP_MPS := 1.6
const DEBRIS_TIP_RADPS := 2.2
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
var _query := PhysicsShapeQueryParameters3D.new()
var _settled: Array[RigidBody3D] = []
var _broken := {}


func configure(fences_layer: Node) -> void:
	_bodies.clear()
	_rids.clear()
	_query.collision_mask = PHYSICS_STREET_PROP
	_query.collide_with_areas = false
	for body: Node in fences_layer.find_children("Collision", "StaticBody3D", true, false):
		var fence := body as StaticBody3D
		if str(fence.get_meta("street_detail_kind", "")) != "fence" or not bool(fence.get_meta("breakable", true)):
			continue
		var group := fence.get_parent() as Node3D
		if group == null or not group.has_meta("fence_bays"):
			continue
		_bodies[fence.get_rid()] = {"body": fence, "group": group}
		_rids.append(fence.get_rid())


## The breakable fence bodies a car passes through and its wheels ignore.
func fence_bodies() -> Array[RID]:
	return _rids.duplicate()


func broken_count() -> int:
	return _broken.size()


func is_broken(bay_key: String) -> bool:
	return _broken.has(bay_key)


## Breaks every intact bay the car's hull overlaps now.
func break_overlaps(car: RigidBody3D, _manager: Node) -> void:
	if _bodies.is_empty() or car == null:
		return
	var space := car.get_world_3d().direct_space_state
	_query.exclude = [car.get_rid()]
	_query.margin = 0.05
	for owner_id in car.get_shape_owners():
		for index in car.shape_owner_get_shape_count(owner_id):
			_query.shape = car.shape_owner_get_shape(owner_id, index)
			_query.transform = car.global_transform * car.shape_owner_get_transform(owner_id)
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


## Breaks one bay: hides its geometry, opens its box and drops its debris.
func break_bay(group: Node3D, shape: CollisionShape3D, velocity: Vector3) -> void:
	var key := str(shape.get_meta("fence_bay", ""))
	if key == "" or _broken.has(key):
		return
	var bays: Dictionary = group.get_meta("fence_bays", {})
	if not bays.has(key):
		return
	var bay: Dictionary = bays[key]
	shape.disabled = true
	_broken[key] = true
	for ref: Array in bay.get("ranges", []):
		var instance := group.get_node_or_null(str(ref[0])) as MeshInstance3D
		if instance != null and instance.mesh is ArrayMesh:
			_collapse(instance.mesh as ArrayMesh, int(ref[1]), int(ref[2]), int(ref[3]))
	_drop_debris(group, bay, velocity)


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
