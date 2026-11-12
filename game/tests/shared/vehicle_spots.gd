extends RefCounted
## The yard vehicles the vehicle tests drive, and where they stand the stock
## player to get into one (headless_vehicle_contract.gd, headless_touch_drive.gd).
##
## A spot to get into a parked car or a yard van, truck or RV:
## off the vehicle's right or left side, or its back or front, BESIDE_M out from
## its parked collision box, with no other drivable vehicle within the vehicles'
## reach and OTHER_MARGIN_M, on the world's ground about level with its wheels
## (not on a car or another prop), with room for the player's capsule.

const DRIVABLE_CAR := preload("res://game/scripts/vehicles/drivable_car.gd")
const KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
const PHYSICS_WORLD_SOLID := 1
const PHYSICS_STREET_PROP := 1 << 3
const BESIDE_M := 0.75
const OTHER_MARGIN_M := 0.5
## The highest a spot's ground may stand above or below the vehicle's wheels (m).
const GROUND_STEP_M := 0.6


## The storage yards' bodies a player drives: the bodies drivable_car.gd knows
## (BODIES and ALIASES, whose yard ones are the kit's YARD_DRIVABLE) past the
## street cars'.
static func yard_bodies() -> Array:
	return (DRIVABLE_CAR.ALIASES.keys() + DRIVABLE_CAR.BODIES.keys()).filter(func(body: String) -> bool: return body not in KIT.CAR_BODIES)


## A parked (not yet live) vehicle of this body not in used, and a spot beside
## it: {"id", "at"} (at: the ground under the spot), or {} if there is none.
## Where no unused one has a spot (the world has two class A RVs), one used
## before: it stands where it was parked (got into and out of, nothing moved it).
static func beside(main: GameMain, vehicles: VehicleManager, body: String, used: Dictionary) -> Dictionary:
	var ids := vehicles.swappable_ids().filter(func(id: String) -> bool: return vehicles.drivable_body(id) == body)
	ids.sort()
	for again: bool in [false, true]:
		for id: String in ids:
			if used.has(id) != again or (not again and vehicles.live_node(id) != null):
				continue
			var box := parked_box(main, vehicles, id)
			if box.is_empty():
				continue
			var half: Vector3 = box.half
			var xf: Transform3D = box.xf
			for side: Vector3 in [Vector3(half.x + BESIDE_M, 0.0, 0.0), Vector3(-half.x - BESIDE_M, 0.0, 0.0), Vector3(0.0, 0.0, half.z + BESIDE_M), Vector3(0.0, 0.0, -half.z - BESIDE_M)]:
				var at: Vector3 = xf * side
				if _other_in_reach(main, vehicles, id, at):
					continue
				var ground := _open_ground(main, at, xf.origin.y - half.y)
				if ground.is_finite():
					return {"id": id, "at": ground}
	return {}


## A swappable row's parked collision as one box round all its shapes, in the
## row's own frame (street_clutter_builder.gd: a box over a yard vehicle's body,
## a car's convex pieces of its drawn body, their floor on the ground): {xf,
## half} (the box's transform and half size), or {}.
static func parked_box(main: GameMain, vehicles: VehicleManager, id: String) -> Dictionary:
	var row := vehicles.row(id)
	var shapes: Array = row.get("shapes", [])
	var clutter := main.world_root.street_detail_layer("clutter").get_node_or_null("GeneratedStreetClutter")
	if clutter == null or shapes.is_empty():
		return {}
	var frame: Transform3D = row.transform
	var to_row := frame.affine_inverse()
	var bounds := AABB()
	var found := false
	for ref: Array in shapes:
		var body := clutter.get_node_or_null(str(ref[0]))
		var shape := body.get_node_or_null(str(ref[1])) as CollisionShape3D if body != null else null
		if shape == null:
			continue
		var local := to_row * shape.global_transform
		var piece := AABB()
		if shape.shape is BoxShape3D:
			var size := (shape.shape as BoxShape3D).size
			piece = local * AABB(-size * 0.5, size)
		elif shape.shape is ConvexPolygonShape3D and not (shape.shape as ConvexPolygonShape3D).points.is_empty():
			var points := (shape.shape as ConvexPolygonShape3D).points
			piece = AABB(local * points[0], Vector3.ZERO)
			for point: Vector3 in points:
				piece = piece.expand(local * point)
		else:
			continue
		bounds = piece if not found else bounds.merge(piece)
		found = true
	if not found:
		return {}
	return {"xf": frame * Transform3D(Basis.IDENTITY, bounds.get_center()), "half": bounds.size * 0.5}


## Whether another drivable vehicle's parked box is within the vehicles' reach
## and the margin of this point, in plan.
static func _other_in_reach(main: GameMain, vehicles: VehicleManager, id: String, at: Vector3) -> bool:
	for other: String in vehicles.swappable_ids():
		if other == id or vehicles.drivable_body(other) == "":
			continue
		var origin := (vehicles.row(other).transform as Transform3D).origin
		if Vector2(origin.x - at.x, origin.z - at.z).length() > 16.0:
			continue
		var box := parked_box(main, vehicles, other)
		if box.is_empty():
			continue
		var local: Vector3 = (box.xf as Transform3D).affine_inverse() * at
		var half: Vector3 = box.half
		if Vector2(maxf(0.0, absf(local.x) - half.x), maxf(0.0, absf(local.z) - half.z)).length() < VehicleManager.ENTER_REACH_M + OTHER_MARGIN_M:
			return true
	return false


## The world's ground under this point if the stock player can stand there: the
## first solid straight down is the world's (not a street prop's), within
## GROUND_STEP_M of the vehicle's wheels, with room for the player. INF if not.
static func _open_ground(main: GameMain, at: Vector3, wheels_y: float) -> Vector3:
	var player := main.player
	var space := main.get_world_3d().direct_space_state
	var ray := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 3.0, at + Vector3.DOWN * 3.0, player.collision_mask, [player.get_rid()])
	ray.hit_back_faces = false
	var hit := space.intersect_ray(ray)
	var collider := hit.get("collider") as CollisionObject3D
	if collider == null or (collider.collision_layer & PHYSICS_WORLD_SOLID) == 0 or (collider.collision_layer & PHYSICS_STREET_PROP) != 0:
		return Vector3.INF
	var ground: Vector3 = hit.position
	if absf(ground.y - wheels_y) > GROUND_STEP_M:
		return Vector3.INF
	var room := PhysicsShapeQueryParameters3D.new()
	room.shape = player.collision_shape.shape
	room.transform = Transform3D(Basis.IDENTITY, ground + player.collision_shape.position + Vector3.UP * 0.15)
	room.collision_mask = player.collision_mask
	room.exclude = [player.get_rid()]
	return Vector3.INF if not space.intersect_shape(room, 1).is_empty() else ground
