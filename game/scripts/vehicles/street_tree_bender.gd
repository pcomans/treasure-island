extends Node
## Small trees a car pushes through (owner, 2026-11-13: "Could you just bend them
## out of the way"). A tree whose trunk is thinner than the vegetation kit's
## BENDING_TRUNK_RADIUS_M (the young gums, island oaks and smaller young cypresses
## of the plantings and the young Norfolk pine) keeps its trunk on bodies of its
## own (street_vegetation_builder.gd BendingTrunks, listed with each tree's
## instances in the root's bending_rows metadata), so this works in the world
## generated at startup and in the baked one alike. The stock player still stops
## at it, as before; a live car or K-rail has a collision exception with those
## bodies, and its wheels, its righting and the chase camera's arm skip them
## (vehicle_manager.gd), so it drives through.
##
## Each tick a moving body's reach (vehicle_reach.gd) hands this bender the bending
## trunks it found (reach_tree). A trunk within BEND_MARGIN_M of the body's box,
## now or BEND_LEAD_S on at the body's speed (so it is already going when the
## bumper arrives), leans away from it, further the deeper the body is in: up to
## the tree's own limit once the trunk is BEND_RAMP_M inside that margin. The
## limit is how far the tree can lean before its crown meets the ground (the least
## rise, seen from its foot, of its mesh's points clear of its trunk and stakes,
## allowing CROWN_SINK_M), between BEND_MIN_DEG and BEND_MAX_DEG: a tall young gum
## leans about 60 to 70 degrees, a low round oak 30 to 50 and the car pushes
## through the rest of its leaves, as through a shrub's; a young cypress or pine
## feathered to the ground still leans BEND_MIN_DEG, the lowest sprays on its far
## side dipping into the ground for the moment it leans. It leans toward the side
## of the body's middle line it stands on and BEND_FORWARD of that the way the
## body goes, so a trunk under a car comes out at its side. While a body keeps
## touching it the tree follows that lean quickly (PUSH_HZ, critically damped).
## It stays down while the body that bent it is over it, even standing still
## with no reach looking round it, and as far over as it went while its crown,
## standing, would be on the chase camera's arm (view: between the driven car and
## the camera, which trails the car through the trees it has just bent), so the
## view does not end up inside a crown springing back. Once nothing holds it, it
## springs back up, overshooting a little (SPRING_HZ, SPRING_DAMPING), and stands
## exactly as it was; the arm coming over it after that does not bend it again. The lean is
## the tree's own instance in each of its batches (every detail
## level and its shadow mesh) turned about its foot, so a bending tree stays in
## its batches and adds no draw call, and a standing tree is drawn as before. The
## body keeps going, each tree taking SPEED_SHARE_PER_TREE of its speed the first
## tick it touches it.

const BEND_MARGIN_M := 0.35
const BEND_LEAD_S := 0.05
const BEND_RAMP_M := 0.9
const BEND_MIN_DEG := 25.0
const BEND_MAX_DEG := 78.0
const BEND_FORWARD := 0.3
const PUSH_HZ := 5.0
const SPRING_HZ := 1.1
const SPRING_DAMPING := 0.5
const SPEED_SHARE_PER_TREE := 0.03
## How far a crown may dip under the ground at its limit (m, in the tree's own
## mesh: its leaves' tips), and how near its trunk's axis its mesh's points are
## trunk and stakes, left out of the limit (m).
const CROWN_SINK_M := 0.15
const TRUNK_CLEAR_M := 0.5
## How far clear of a standing crown the chase camera's arm passes for the tree to
## spring back (m).
const VIEW_CLEAR_M := 0.6
## A tree this close to upright and this still stands as it was again.
const REST_RAD := 0.002
const REST_RADPS := 0.01

## The chase camera's rig, set by the vehicle manager.
var view: VehicleCamera
## Bending trees by id: {transform, radius, top, limit (rad), crown (its reach
## from the trunk's axis, m), instances: [[MultiMeshInstance3D, index]]}.
var _rows: Dictionary = {}
## Their trunks by physics body RID: {shape index: id}.
var _shape_rows: Dictionary = {}
var _bodies: Array[RID] = []
## The trees bending now, by id: {angle (rad), rate (rad/s), push (rad, the lean the
## bodies touching it ask for this tick), peak (the most they asked since it was
## last let go), touched (the last tick a body did), axis, body (the one that
## touched it last)}.
var _moving: Dictionary = {}
## The most each tree has leaned this session (degrees), for tests.
var _most: Dictionary = {}


func configure(vegetation_layer: Node) -> void:
	_rows.clear()
	_shape_rows.clear()
	_bodies.clear()
	_moving.clear()
	var root := vegetation_layer.get_node_or_null("GeneratedStreetVegetation")
	if root == null:
		return
	var indices := {}
	var crowns := {}
	var listed: Dictionary = root.get_meta("bending_rows", {})
	for id: String in listed:
		var entry: Dictionary = listed[id]
		var row := {"transform": entry.transform, "radius": float(entry.radius), "top": float(entry.top), "limit": deg_to_rad(BEND_MAX_DEG), "crown": 0.0, "instances": []}
		for ref: Array in entry.instances:
			var instance := root.get_node_or_null(str(ref[0])) as MultiMeshInstance3D
			if instance != null and instance.multimesh != null:
				(row.instances as Array).append([instance, int(ref[1])])
		if not (row.instances as Array).is_empty():
			# Its nearest level's mesh (the first listed), once a mesh.
			var mesh := ((row.instances as Array)[0][0] as MultiMeshInstance3D).multimesh.mesh
			if mesh != null:
				if not crowns.has(mesh):
					crowns[mesh] = crown_of(mesh)
				row.limit = crowns[mesh].limit
				row.crown = float(crowns[mesh].reach) * (entry.transform as Transform3D).basis.get_scale().x
		for ref: Array in entry.shapes:
			var body := root.get_node_or_null(str(ref[0])) as StaticBody3D
			var collision := body.get_node_or_null(str(ref[1])) as CollisionShape3D if body != null else null
			if collision == null:
				continue
			if not indices.has(body):
				# The body's shapes by node, once: their indices in the physics server.
				var by_node := {}
				for owner_id in body.get_shape_owners():
					by_node[body.shape_owner_get_owner(owner_id)] = body.shape_owner_get_shape_index(owner_id, 0)
				indices[body] = by_node
				_bodies.append(body.get_rid())
			var by_index: Dictionary = _shape_rows.get(body.get_rid(), {})
			by_index[indices[body][collision]] = id
			_shape_rows[body.get_rid()] = by_index
		_rows[id] = row


## A tree drawn with mesh (its own space: foot at the origin, up +Y): limit, how
## far (rad) it can lean about its foot before its crown meets the ground (the
## least rise, seen from the foot, of the mesh's points further than
## TRUNK_CLEAR_M from its axis, allowing CROWN_SINK_M; between BEND_MIN_DEG and
## BEND_MAX_DEG), and reach, how far its points reach from that axis (its unit).
static func crown_of(mesh: Mesh) -> Dictionary:
	# The least squared slope (rise over distance out) of those points.
	var least := INF
	var furthest := 0.0
	var clear := TRUNK_CLEAR_M * TRUNK_CLEAR_M
	for surface in mesh.get_surface_count():
		var points: PackedVector3Array = mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
		for point: Vector3 in points:
			var out := point.x * point.x + point.z * point.z
			furthest = maxf(furthest, out)
			if out > clear:
				var rise := maxf(point.y + CROWN_SINK_M, 0.0)
				least = minf(least, rise * rise / out)
	return {"limit": clampf(atan(sqrt(least)), deg_to_rad(BEND_MIN_DEG), deg_to_rad(BEND_MAX_DEG)), "reach": sqrt(furthest)}


## The bending trees' trunk bodies, which a live car passes through.
func trunk_bodies() -> Array[RID]:
	return _bodies.duplicate()


## What a moving body's reach hands this bender, by physics body.
func reach_owners() -> Dictionary:
	var owners := {}
	for rid: RID in _shape_rows:
		owners[rid] = reach_tree
	return owners


func bending_ids() -> Array:
	return _rows.keys()


## A bending tree's foot, trunk radius, top, crown reach (m) and lean limit
## (degrees), {} if it is not one.
func tree(id: String) -> Dictionary:
	var row: Dictionary = _rows.get(id, {})
	return {} if row.is_empty() else {"foot": (row.transform as Transform3D).origin, "radius": row.radius, "top": row.top, "crown": row.crown, "limit_deg": rad_to_deg(float(row.limit))}


## How far a tree leans now (degrees, 0 standing).
func lean_degrees(id: String) -> float:
	return rad_to_deg(float((_moving.get(id, {}) as Dictionary).get("angle", 0.0)))


## The most a tree has leaned this session (degrees).
func most_lean_degrees(id: String) -> float:
	return float(_most.get(id, 0.0))


## A bending tree's trunk in a moving body's reach: it leans away from the body's
## box when within BEND_MARGIN_M of it, now or BEND_LEAD_S on.
func reach_tree(reach: VehicleReach, hit: Dictionary) -> void:
	var by_index: Dictionary = _shape_rows.get(hit.get("rid", RID()), {})
	var id := str(by_index.get(int(hit.get("shape", -1)), ""))
	if id == "":
		return
	var row: Dictionary = _rows[id]
	var push := _push(row, reach.box_xf, reach.half, reach.local_velocity * BEND_LEAD_S)
	if push <= 0.0:
		return
	var tick := Engine.get_physics_frames()
	var state: Dictionary = _moving.get(id, {})
	if state.is_empty():
		state = {"angle": 0.0, "rate": 0.0, "push": 0.0, "peak": 0.0, "touched": -10, "axis": Vector3.RIGHT, "body": null}
		_moving[id] = state
	if int(state.touched) < tick - 1:
		# A new touch: which way it leans, and the speed it takes.
		state.axis = _lean_axis(reach, (row.transform as Transform3D).origin, id)
		reach.body.linear_velocity *= 1.0 - SPEED_SHARE_PER_TREE
	if int(state.touched) != tick:
		state.push = 0.0
	state.push = maxf(float(state.push), push)
	state.touched = tick
	state.body = reach.body


## The lean (rad) a body's box (its centre frame in the world and half size) asks
## of a tree: none beyond the trunk's radius and BEND_MARGIN_M from the box, here
## or moved on by lead (in the box's frame); the tree's limit once the trunk is
## BEND_RAMP_M further in.
static func _push(row: Dictionary, box_xf: Transform3D, half: Vector3, lead: Vector3) -> float:
	# The trunk's axis against the box, in plan in the box's frame: how far outside
	# the box it stands (negative inside, by the nearest side).
	var local := box_xf.inverse() * (row.transform as Transform3D).origin
	var gap := minf(_gap(local, half), _gap(local - lead, half))
	var reach_m := float(row.radius) + BEND_MARGIN_M
	if gap > reach_m:
		return 0.0
	return float(row.limit) * clampf((reach_m - gap) / BEND_RAMP_M, 0.0, 1.0)


static func _gap(local: Vector3, half: Vector3) -> float:
	var dx := absf(local.x) - half.x
	var dz := absf(local.z) - half.z
	return Vector2(maxf(dx, 0.0), maxf(dz, 0.0)).length() if dx > 0.0 or dz > 0.0 else maxf(dx, dz)


## The axis a tree turns about (by a positive angle) to lean away from the body:
## toward the side of the body's middle line it stands on, BEND_FORWARD of that the
## way the body goes (the body's front if it barely moves); a tree on the middle
## line takes a side from its id.
static func _lean_axis(reach: VehicleReach, foot: Vector3, id: String) -> Vector3:
	var way := Vector3(reach.velocity.x, 0.0, reach.velocity.z)
	if way.length() < 0.3:
		way = -reach.xf.basis.z
		way.y = 0.0
	way = way.normalized() if way.length() > 0.01 else Vector3.FORWARD
	var off := foot - reach.xf.origin
	off.y = 0.0
	var aside := off - way * off.dot(way)
	if aside.length() < 0.05:
		aside = way.cross(Vector3.UP) * (1.0 if hash(id) & 1 == 0 else -1.0)
	var toward := (aside.normalized() + way * BEND_FORWARD).normalized()
	# Turning about UP x toward tips the top toward it.
	return Vector3.UP.cross(toward).normalized()


func _physics_process(delta: float) -> void:
	if _moving.is_empty():
		return
	var tick := Engine.get_physics_frames()
	for id: String in _moving.keys():
		var state: Dictionary = _moving[id]
		var row: Dictionary = _rows[id]
		# The manager, this node's parent, has looked round the moving bodies this tick.
		var pushed := int(state.touched) >= tick - 1
		var target := float(state.push) if pushed else 0.0
		if not pushed and is_instance_valid(state.body):
			# No reach looked round the body that bent it (stopped on it, say): down
			# while that body is still over it.
			var body := state.body as RigidBody3D
			var box := VehicleReach.reach_box(body)
			target = _push(row, body.global_transform * Transform3D(Basis.IDENTITY, box.get_center()), box.size * 0.5, Vector3.ZERO)
			pushed = target > 0.0
			if not pushed:
				state.body = null
		if pushed:
			state.peak = maxf(float(state.peak), target)
		if float(state.peak) > 0.0 and _on_view(row):
			# Its crown, standing, would be on the chase camera's arm: as far over as
			# the bodies pushed it until the camera has passed.
			target = maxf(target, float(state.peak))
			pushed = true
		elif not pushed:
			state.peak = 0.0
		var omega := TAU * (PUSH_HZ if pushed else SPRING_HZ)
		var damping := 1.0 if pushed else SPRING_DAMPING
		var rate := float(state.rate) + (omega * omega * (target - float(state.angle)) - 2.0 * damping * omega * float(state.rate)) * delta
		var angle := float(state.angle) + rate * delta
		state.rate = rate
		state.angle = angle
		_most[id] = maxf(float(_most.get(id, 0.0)), rad_to_deg(angle))
		var placement: Transform3D = row.transform
		if not pushed and absf(angle) < REST_RAD and absf(rate) < REST_RADPS:
			_draw(row, placement)
			_moving.erase(id)
			continue
		_draw(row, Transform3D(Basis(state.axis as Vector3, angle) * placement.basis, placement.origin))


## Whether a tree's crown, standing, would be on the chase camera's arm (in plan:
## within its crown's reach and VIEW_CLEAR_M of the line from the pivot over the
## driven car to the camera), while that camera follows a car.
func _on_view(row: Dictionary) -> bool:
	if not is_instance_valid(view) or not view.is_following():
		return false
	var foot: Vector3 = (row.transform as Transform3D).origin
	var from := Vector2(view.spring_arm.global_position.x, view.spring_arm.global_position.z)
	var to := Vector2(view.camera.global_position.x, view.camera.global_position.z)
	var at := Geometry2D.get_closest_point_to_segment(Vector2(foot.x, foot.z), from, to)
	return at.distance_to(Vector2(foot.x, foot.z)) < float(row.crown) + VIEW_CLEAR_M


## The tree's instance in each of its batches.
static func _draw(row: Dictionary, xf: Transform3D) -> void:
	for ref: Array in row.instances:
		var instance := ref[0] as MultiMeshInstance3D
		if is_instance_valid(instance):
			instance.multimesh.set_instance_transform(int(ref[1]), xf)
