extends RefCounted
## The fit checks for one building in the loaded island; see building_fit_test.gd.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const VISUAL_LAYER := 1 << 19
const SAMPLE_FAILURE_LIMIT := 0.10
## Keep the existing short-route allowance; longer routes scale with stock speed.
const MIN_WALK_SECONDS := 15.0
const WALK_ACCELERATION_ALLOWANCE_SECONDS := 2.0
## How close (metres) a walk must end to the building or stair top to count as arrived.
const ARRIVAL_DISTANCE_M := 1.5

var _h: WorldHarness
var _failures: Array[String] = []
## Collision objects the player bumped into during the last _walk_toward.
var _touched: Array[Object] = []
var _wall_touched := false
## Closest the player came to the target during the last _walk_toward (metres).
var _closest := INF
var _prefix := ""
var _unsafe := false
var _support_context: Dictionary = {}


func _init(harness: WorldHarness) -> void:
	_h = harness


## Unsafe source/setup/recovery/rest failures stop this driver's whole lifetime.
func has_unsafe_failure() -> bool:
	return _unsafe


## Preplacement inspection only: no teleport, gameplay enable or movement input.
## A completed query supplies no fit, movement, active-rest or acceptance credit.
func diagnose_side(source_key: String, side_name: String) -> String:
	var sides := {"north": Vector3.FORWARD, "south": Vector3.BACK, "west": Vector3.LEFT, "east": Vector3.RIGHT}
	if _unsafe or not sides.has(side_name) or not _diagnostic_player_idle():
		_unsafe = true
		return "diagnostic prerequisite failed: unsafe driver, invalid side or active player/input"
	var before := _h.player.global_transform
	var recoveries := _h.world.get_runtime_evidence().recovery_count
	var nodes := _h.building_nodes(source_key)
	var architecture := _h.architectural_walls(nodes)
	if not architecture.ok:
		_unsafe = true
		return "diagnostic source geometry: " + architecture.reason
	var support := _h.approach_support(source_key, nodes, architecture)
	if not support.ok:
		_unsafe = true
		return "diagnostic support identity: " + support.reason
	_support_context = support.context
	var side: Vector3 = sides[side_name]
	var box: AABB = architecture.bounds
	var half_depth := absf(side.x) * box.size.x * 0.5 + absf(side.z) * box.size.z * 0.5
	var half_width := absf(side.z) * box.size.x * 0.5 + absf(side.x) * box.size.z * 0.5
	var setup := _walk_start(box.get_center(), side, half_depth, half_width, architecture.rids, architecture.shapes, architecture.faces)
	var unchanged := _h.player.global_transform == before and _h.world.get_runtime_evidence().recovery_count == recoveries
	var idle := _diagnostic_player_idle()
	print("DIAGNOSTIC ONLY source=%s side=%s candidate_found=%s player_unchanged=%s disabled_input_released=%s; no movement or active-REST proof" % [source_key, side_name, setup.ok, unchanged, idle])
	if not unchanged or not idle:
		_unsafe = true
		return "diagnostic changed player/recovery state or lost disabled/input-released state"
	return "" if setup.ok else "candidate preflight HOLD: " + str(setup.reason)


func _diagnostic_player_idle() -> bool:
	if _h.player.is_physics_processing() or _h.player.velocity != Vector3.ZERO:
		return false
	for action in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		if Input.is_action_pressed(action):
			return false
	return true


## Runs the checks for one building and returns its failures (empty = pass).
## The walk-up and stairs are the slow part (seconds of simulated walking each).
## stairs: [{"bottom": [x, z], "top": [x, z]}, ...] from the building's catalog entry.
func check(source_key: String, walk_up: bool, prefix: String = "", stairs: Array = [], routes: Array = [], spray_case: Dictionary = {}) -> Array[String]:
	if _unsafe:
		return [prefix + "check not run: a previous unsafe failure stopped this driver"]
	_failures = []
	_prefix = prefix
	var nodes := _h.building_nodes(source_key)
	var meshes := _h.visual_meshes(nodes)
	if meshes.is_empty():
		_unsafe = true
		return [prefix + "no visible geometry found for building %s" % source_key]
	var box := _h.bounds(meshes)
	var own := _h.collision_rids(nodes)
	if own.is_empty():
		_unsafe = true
		return [prefix + "no source collision found for building %s" % source_key]
	var architecture := _h.architectural_walls(nodes)
	if not architecture.ok:
		_unsafe = true
		return [prefix + "source architecture: " + architecture.reason]
	var support := _h.approach_support(source_key, nodes, architecture)
	if not support.ok:
		_unsafe = true
		return [prefix + "source support: " + support.reason]
	_support_context = support.context
	var proxies := _add_visual_proxies(meshes)
	await _h.tree.physics_frame
	await _h.tree.physics_frame
	print("%sBuilding %s: %d meshes, size %.1f x %.1f x %.1f m" % [prefix, source_key, meshes.size(), box.size.x, box.size.y, box.size.z])
	_check_roof(box, own)
	_check_walls(box, own)
	if walk_up:
		await _check_walk_up(architecture.bounds, architecture.rids, architecture.shapes, architecture.faces)
		for stair: Dictionary in stairs:
			if _unsafe:
				break
			await _check_stairs(stair)
		if not _unsafe:
			await _check_routes(routes, box)
	if not _unsafe and not spray_case.is_empty():
		await _check_spray(source_key, spray_case, box)
	for proxy in proxies:
		proxy.queue_free()
	await _h.tree.physics_frame
	return _failures


## Collision copies of the visible meshes on a separate layer, so rays can
## compare "what you see" against "what the player collides with".
func _add_visual_proxies(meshes: Array) -> Array[Node]:
	var added: Array[Node] = []
	for entry in meshes:
		var shape := (entry[0] as Mesh).create_trimesh_shape()
		if shape == null:
			continue
		shape.backface_collision = true
		var body := StaticBody3D.new()
		body.collision_layer = VISUAL_LAYER
		body.collision_mask = 0
		body.set_meta("mesh_name", entry[2])
		var collider := CollisionShape3D.new()
		collider.shape = shape
		body.add_child(collider)
		_h.main.add_child(body)
		body.global_transform = entry[1]
		added.append(body)
	return added


## First hit on the building's own collision along the ray, as the player
## collides (same collision layers), looking past anything else in the way
## (trees, a neighbour's eaves). Empty if none.
func _own_hit(from: Vector3, to: Vector3, own: Array[RID]) -> Dictionary:
	var others: Array[RID] = []
	for _attempt in 8:
		var hit := _h.ray(from, to, _h.player.collision_mask, others)
		if hit.is_empty() or (hit.rid as RID) in own:
			return hit
		others.append(hit.rid as RID)
	return {}


## The solid surface that holds up a visible part at height seen_y: the first
## hit at or below it, looking past other objects (trees, eaves) above it. For a
## ground-level part like a lawn or apron that is the terrain under it.
func _support_under(from: Vector3, to: Vector3, seen_y: float, own: Array[RID]) -> Dictionary:
	var others: Array[RID] = []
	for _attempt in 8:
		var hit := _h.ray(from, to, _h.player.collision_mask, others)
		if hit.is_empty() or (hit.rid as RID) in own or (hit.position as Vector3).y <= seen_y + 0.5:
			return hit
		others.append(hit.rid as RID)
	return {}


func _check_roof(box: AABB, own: Array[RID]) -> void:
	var samples := 0
	var holes: Array[String] = []
	for i in 8:
		for j in 8:
			var x := box.position.x + box.size.x * (float(i) + 0.5) / 8.0
			var z := box.position.z + box.size.z * (float(j) + 0.5) / 8.0
			var top := Vector3(x, box.end.y + 5.0, z)
			var bottom := Vector3(x, box.position.y - 1.0, z)
			var seen := _h.ray(top, bottom, VISUAL_LAYER)
			if seen.is_empty():
				continue
			# Lawns, aprons and paths lie on the ground; only raised parts are roof.
			var ground := _surface_y(Vector2(x, z), own)
			if not is_nan(ground) and (seen.position as Vector3).y < ground + 1.0:
				continue
			samples += 1
			var solid := _support_under(top, bottom, (seen.position as Vector3).y, own)
			if solid.is_empty() or (solid.position as Vector3).y < (seen.position as Vector3).y - 1.0:
				holes.append("(%.1f, %.1f) %s" % [x, z, _mesh_name(seen)])
	_report("roof", samples, holes, "visible roof the player falls through at")


func _check_walls(box: AABB, own: Array[RID]) -> void:
	var samples := 0
	var grounded_samples := 0
	var open: Array[String] = []
	var floating: Array[String] = []
	var center := box.get_center()
	for side: Vector3 in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
		var across := Vector3(side.z, 0.0, -side.x)
		var half_depth := absf(side.x) * box.size.x * 0.5 + absf(side.z) * box.size.z * 0.5
		var half_width := absf(across.x) * box.size.x * 0.5 + absf(across.z) * box.size.z * 0.5
		for k in 5:
			var offset := across * half_width * (float(k) / 2.0 - 1.0) * 0.8
			var outside := Vector3(center.x, 0.0, center.z) + offset + side * (half_depth + 2.0)
			var ground := _surface_y(Vector2(outside.x, outside.z), own)
			if is_nan(ground):
				continue
			var start := Vector3(outside.x, ground + 1.0, outside.z)
			var end := start - side * (half_depth * 2.0 + 4.0)
			var seen := _h.ray(start, end, VISUAL_LAYER)
			if seen.is_empty():
				continue
			var seen_at := start.distance_to(seen.position as Vector3)
			# Terrain or another object in front of the wall: no player gets there either.
			var first := _h.ray(start, end, _h.player.collision_mask)
			if not first.is_empty() and not (first.rid as RID) in own and start.distance_to(first.position as Vector3) < seen_at - 0.5:
				continue
			samples += 1
			var solid := _own_hit(start, end, own)
			if solid.is_empty() or start.distance_to(solid.position as Vector3) > seen_at + 0.5:
				open.append("(%.1f, %.1f) %s" % [seen.position.x, seen.position.z, _mesh_name(seen)])
			# The same wall should still be there just above the local ground.
			var wall_xz := Vector2((seen.position as Vector3).x, (seen.position as Vector3).z) + Vector2(side.x, side.z) * 0.3
			var local_ground := _surface_y(wall_xz, own)
			if is_nan(local_ground):
				continue
			grounded_samples += 1
			var low_start := Vector3(start.x, local_ground + 0.15, start.z)
			var low := _h.ray(low_start, low_start - side * (half_depth * 2.0 + 4.0), VISUAL_LAYER)
			if low.is_empty() or low_start.distance_to(low.position as Vector3) > seen_at + 1.0:
				floating.append("(%.1f, %.1f)" % [seen.position.x, seen.position.z])
	_report("walls", samples, open, "visible wall the player walks through at")
	_report("grounded", grounded_samples, floating, "wall not reaching the ground at")


## From each side, the stock player walks toward the building and must arrive
## at qualified native walls, standing, without a fall recovery.
## Start selection is read-only: an obstructed candidate never moves the player.
func _walk_start(center: Vector3, side: Vector3, half_depth: float, half_width: float, own: Array[RID], wall_shapes: Dictionary, wall_faces: Array[Dictionary]) -> Dictionary:
	var rejected: Array[String] = []
	var across := Vector3(side.z, 0.0, -side.x)
	# Preserve the original fifteen candidates before trying native solid-wall
	# anchors. Every proposal uses the same complete preflight before placement.
	var candidates: Array[Dictionary] = []
	for lane: float in [0.0, -0.25, 0.25, -0.125, 0.125]:
		candidates.append({"offset": half_width * 2.0 * lane, "label": "lane %.2f" % lane})
	for anchor: float in _wall_anchors(center, side, wall_faces, wall_shapes, candidates):
		candidates.append({"offset": anchor, "label": "native-wall offset %.3f" % anchor})
	for proposal: Dictionary in candidates:
		var lane_center := center + across * float(proposal.offset)
		for margin: float in [5.0, 2.0, 10.0]:
			var candidate := str(proposal.label) + " / "
			var xz := Vector2(lane_center.x, lane_center.z) + Vector2(side.x, side.z) * (half_depth + margin)
			var point := Vector3(xz.x, 0.0, xz.y)
			if not _h.world.get_boundary().contains_position(point):
				rejected.append(candidate + ("%.1f m: outside playable boundary" % margin))
				continue
			var ground := _h.ray(point + Vector3.UP * 300.0, point + Vector3.DOWN * 50.0, _h.player.collision_mask)
			if not _h.is_approach_support(ground, _support_context):
				var hit_name := "no support" if ground.is_empty() else str((ground.collider as Node).get_path())
				rejected.append(candidate + ("%.1f m: no walkable ground (%s)" % [margin, hit_name]))
				continue
			var descent := _preflight_descent(ground.position)
			if not descent.ok:
				rejected.append(candidate + ("%.1f m: %s" % [margin, descent.reason]))
				continue
			var chest := Vector3(xz.x, (ground.position as Vector3).y + 1.0, xz.y)
			var far := Vector3(lane_center.x, chest.y, lane_center.z) - side * (half_depth + 2.0)
			var crossing := _wall_hit(chest, far, own, wall_shapes)
			if crossing.is_empty():
				rejected.append(candidate + ("%.1f m: no qualified native wall crossing" % margin))
				continue
			var corridor_error := _preflight_corridor(descent.pose, crossing.position, -side, own, wall_shapes)
			if corridor_error != "":
				rejected.append(candidate + ("%.1f m: %s" % [margin, corridor_error]))
				continue
			print("%sWALK_START side=%s candidate=%s at=%s margin=%.1f support=%s rejected=%s" % [_prefix, _side_name(side), proposal.label, xz, margin, (ground.collider as Node).get_path(), rejected])
			print("%sWALK_TARGET side=%s at=%s body=%s shape=%s normal=%s" % [_prefix, _side_name(side), crossing.position, (crossing.collider as Node).get_path(), crossing.shape, crossing.normal])
			return {"ok": true, "xz": xz, "destination": (crossing.position as Vector3) - side}
	return {"ok": false, "reason": "; ".join(rejected)}


## Geometry proposes lanes, never arrival. Qualified native rays and full stock
## capsule preflight still decide whether a proposed lane can be used.
func _wall_anchors(center: Vector3, side: Vector3, faces: Array[Dictionary], shapes: Dictionary, existing: Array[Dictionary]) -> Array[float]:
	var ranked: Array[Dictionary] = []
	var across := Vector3(side.z, 0.0, -side.x)
	var up := _h.player.up_direction.normalized()
	var floor_dot := cos(_h.player.floor_max_angle)
	for face: Dictionary in faces:
		if not shapes.has(face.rid) or int(face.shape) not in shapes[face.rid]:
			continue
		var vertices: PackedVector3Array = face.vertices
		for i in range(0, vertices.size(), 3):
			var a := vertices[i]
			var b := vertices[i + 1]
			var c := vertices[i + 2]
			var normal := (b - a).cross(c - a)
			if not normal.is_finite() or normal.is_zero_approx():
				continue
			normal = normal.normalized()
			if absf(normal.dot(up)) >= floor_dot or is_zero_approx(normal.dot(side)):
				continue
			if ((a + b + c) / 3.0 - center).dot(side) < 0.0:
				continue
			var bottom := minf(a.dot(up), minf(b.dot(up), c.dot(up)))
			var level := bottom + 1.0
			var cuts: Array[Vector3] = []
			var triangle: Array[Vector3] = [a, b, c]
			for edge in 3:
				var p := triangle[edge]
				var q := triangle[(edge + 1) % 3]
				var height := q.dot(up) - p.dot(up)
				if is_zero_approx(height):
					continue
				var weight := (level - p.dot(up)) / height
				if weight >= 0.0 and weight <= 1.0:
					cuts.append(p.lerp(q, weight))
			if cuts.size() < 2:
				continue
			var low := INF
			var high := -INF
			for point: Vector3 in cuts:
				var offset := (point - center).dot(across)
				low = minf(low, offset)
				high = maxf(high, offset)
			if not is_finite(low) or not is_finite(high) or is_equal_approx(low, high):
				continue
			ranked.append({"offset": (low + high) * 0.5, "bottom": bottom, "width": high - low})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.bottom != b.bottom: return a.bottom < b.bottom
		if a.width != b.width: return a.width > b.width
		if absf(a.offset) != absf(b.offset): return absf(a.offset) < absf(b.offset)
		return a.offset < b.offset)
	var result: Array[float] = []
	var seen: Array[float] = []
	for candidate: Dictionary in existing:
		seen.append(float(candidate.offset))
	for candidate: Dictionary in ranked:
		var offset := float(candidate.offset)
		if seen.any(func(value: float) -> bool: return is_equal_approx(value, offset)):
			continue
		seen.append(offset)
		result.append(offset)
		if result.size() == 8:
			break
	return result


## Test the actual stock body without moving it. Unlike the former sweep ending
## 5 cm above a central ray, this reaches first support and queries near-rest
## contacts across the entire native capsule, including its local shape offset.
func _preflight_descent(ground: Vector3) -> Dictionary:
	var player := _h.player
	var up := player.up_direction.normalized()
	# settle_player places an identity body two metres above global-Y ground.
	if not up.is_equal_approx(Vector3.UP):
		return {"ok": false, "reason": "unsupported up direction for stock settle setup"}
	var pose := Transform3D(Basis.IDENTITY, ground + Vector3.UP * 2.0)
	var clear := PhysicsShapeQueryParameters3D.new()
	clear.shape = player.collision_shape.shape
	clear.transform = pose * player.collision_shape.transform
	clear.margin = player.safe_margin
	clear.collision_mask = player.collision_mask
	clear.exclude = [player.get_rid()]
	clear.collide_with_areas = false
	if not player.get_world_3d().direct_space_state.intersect_shape(clear, 1).is_empty():
		return {"ok": false, "reason": "stock drop pose is obstructed"}
	var params := PhysicsTestMotionParameters3D.new()
	params.from = pose
	params.margin = player.safe_margin
	params.max_collisions = 32 # Native API limit; a saturated result is unknown.
	params.recovery_as_collision = true
	params.collide_separation_ray = true
	var snap := maxf(player.floor_snap_length, player.safe_margin * 2.0)
	var floor_dot := cos(player.floor_max_angle)
	for phase in ["descent", "near-rest"]:
		params.motion = -up * (2.0 + snap if phase == "descent" else snap)
		var result := PhysicsTestMotionResult3D.new()
		# Uses the real body's enabled shapes, offsets, mask and exceptions.
		if not PhysicsServer3D.body_test_motion(player.get_rid(), params, result):
			return {"ok": false, "reason": phase + ": no native support contact"}
		var count := result.get_collision_count()
		if count == 0 or count >= params.max_collisions:
			return {"ok": false, "reason": phase + ": incomplete native contact coverage"}
		for contact in count:
			var body := result.get_collider(contact)
			var normal := result.get_collision_normal(contact)
			var identity := str((body as Node).get_path()) if body is Node else "unknown"
			if not normal.is_finite() or normal.dot(up) < floor_dot:
				return {"ok": false, "reason": phase + ": blocked descent by " + identity}
			if not _h.is_approach_support({"collider": body, "normal": normal, "shape": result.get_collider_shape(contact), "position": result.get_collision_point(contact)}, _support_context):
				return {"ok": false, "reason": phase + ": unqualified support " + identity}
			print("%sWALK_PREFLIGHT_SUPPORT phase=%s ground=%s body=%s shape=%d normal=%s" % [_prefix, phase, ground, identity, result.get_collider_shape(contact), normal])
		if not result.get_travel().is_finite():
			return {"ok": false, "reason": phase + ": nonfinite native travel"}
		params.from.origin += result.get_travel()
	return {"ok": true, "pose": params.from}


## Read-only obstruction filter, not a replacement for the actual stock walk.
## Re-anchor to native support after each short sweep instead of extrapolating
## one local contact normal across the whole route.
func _preflight_corridor(pose: Transform3D, wall: Vector3, inward: Vector3, own: Array[RID], wall_shapes: Dictionary) -> String:
	var player := _h.player
	var up := player.up_direction.normalized()
	var capsule := player.collision_shape.shape as CapsuleShape3D
	var snap := player.floor_snap_length
	var lane_margin := player.safe_margin
	if not is_finite(lane_margin) or lane_margin <= 0.0:
		return "corridor needs a finite positive stock recovery margin"
	if capsule == null or not is_finite(snap) or snap <= player.safe_margin * 2.0:
		return "corridor needs a stock capsule and positive native snap allowance"
	var step_length := minf(capsule.radius, (snap - player.safe_margin * 2.0) / maxf(1.0, tan(player.floor_max_angle)))
	if not is_finite(step_length) or step_length <= 0.0 or player.max_slides <= 0:
		return "corridor has invalid stock query bounds"
	var end := wall - inward * (ARRIVAL_DISTANCE_M - player.safe_margin)
	var distance := (end - pose.origin).dot(inward)
	if not is_finite(distance) or not pose.origin.is_finite():
		return "corridor has nonfinite route"
	var steps := maxi(0, ceili(distance / step_length))
	var params := PhysicsTestMotionParameters3D.new()
	params.from = pose
	var lane_origin := pose.origin
	var lateral := up.cross(inward).normalized()
	params.margin = player.safe_margin
	params.max_collisions = 32
	params.collide_separation_ray = true
	# Initial support, then one fresh snap after EVERY completed short sweep.
	for step in steps + 1:
		params.recovery_as_collision = true
		params.motion = -up * snap
		var support := _corridor_motion(params, inward, true)
		if not support.ok:
			return support.reason
		var down := support.travel as Vector3
		if (down - up * down.dot(up)).length() > lane_margin or absf(down.dot(up)) > snap + player.safe_margin:
			return "corridor support query left its native snap bounds: pose=%s motion=%s travel=%s" % [params.from.origin, params.motion, down]
		params.from.origin += down
		if absf((params.from.origin - lane_origin).dot(lateral)) > lane_margin:
			return "corridor support recovery left the original cardinal lane: origin=%s pose=%s margin=%s" % [lane_origin, params.from.origin, lane_margin]
		if step == steps:
			break
		var step_end := params.from.origin + inward * minf(step_length, (end - params.from.origin).dot(inward))
		var slope := float(support.slope)
		var query_rows: Array[String] = [str(support.details)]
		var step_complete := false
		params.recovery_as_collision = false
		for _slide in player.max_slides:
			var remaining := (step_end - params.from.origin).dot(inward)
			if remaining <= 0.0001:
				step_complete = true
				break
			params.motion = (inward + up * slope) * remaining
			var sweep := _corridor_motion(params, inward, false)
			if not sweep.ok:
				return sweep.reason
			query_rows.append(str(sweep.details))
			var travel := sweep.travel as Vector3
			if travel.dot(inward) <= 0.0001 or (travel - inward * travel.dot(inward) - up * travel.dot(up)).length() > lane_margin:
				return "corridor query lost inward progress or lane: pose=%s motion=%s travel=%s" % [params.from.origin, params.motion, travel]
			params.from.origin += travel
			if absf((params.from.origin - lane_origin).dot(lateral)) > lane_margin:
				return "corridor sweep left the original cardinal lane: origin=%s pose=%s margin=%s" % [lane_origin, params.from.origin, lane_margin]
			if not sweep.collided:
				# Native recovery can offset travel from requested motion even
				# when the entire sweep completed with no remaining motion.
				step_complete = true
				break
			slope = float(sweep.slope)
		if not step_complete and (step_end - params.from.origin).dot(inward) > 0.0001:
			return "corridor exhausted the stock slide budget within a local step: residual=%.9f step_end=%s final_pose=%s queries=[%s]" % [(step_end - params.from.origin).dot(inward), step_end, params.from.origin, "; ".join(query_rows)]
	# The actual recovered endpoint must qualify; coordinate subtraction is
	# not a substitute for the completed native sweeps or this wall query.
	if _distance_to_walls(params.from.origin, wall + inward, own, wall_shapes) > ARRIVAL_DISTANCE_M:
		return "corridor endpoint lacks qualified native wall proximity"
	print("%sWALK_CORRIDOR start=%s end=%s qualified_wall=%s step_length=%.4f steps=%d" % [_prefix, pose.origin, params.from.origin, wall, step_length, steps])
	return ""


## Both local sweeps and snaps use the actual body's shapes/mask/exceptions.
## Setup remains strict open ground; in-route floor eligibility follows the
## stock controller, including native area surfaces, without role whitelists.
func _corridor_motion(params: PhysicsTestMotionParameters3D, inward: Vector3, require_support: bool) -> Dictionary:
	if not params.from.origin.is_finite() or not params.motion.is_finite():
		return {"ok": false, "reason": "corridor has nonfinite query pose or motion"}
	var result := PhysicsTestMotionResult3D.new()
	var collided := PhysicsServer3D.body_test_motion(_h.player.get_rid(), params, result)
	var travel := result.get_travel()
	var remainder := result.get_remainder()
	var safe_fraction := result.get_collision_safe_fraction()
	var context := "pose=%s motion=%s travel=%s" % [params.from.origin, params.motion, travel]
	var details := context + " remainder=%s safe_fraction=%.9f recovery_as_collision=%s contacts=[" % [result.get_remainder(), result.get_collision_safe_fraction(), params.recovery_as_collision]
	if not travel.is_finite() or not remainder.is_finite() or not is_finite(safe_fraction) or (require_support and not collided):
		return {"ok": false, "reason": "corridor lacks finite native support/travel: " + context}
	if not collided and (remainder != Vector3.ZERO or safe_fraction != 1.0):
		return {"ok": false, "reason": "corridor has incomplete collision-free native motion: " + details + "]"}
	var slope := -INF
	if collided:
		var count := result.get_collision_count()
		if count == 0 or count >= params.max_collisions:
			return {"ok": false, "reason": "corridor has incomplete native contacts: " + context}
		var up := _h.player.up_direction.normalized()
		for contact in count:
			var body := result.get_collider(contact)
			var normal := result.get_collision_normal(contact)
			var point := result.get_collision_point(contact)
			details += "body=%s shape=%d point=%s normal=%s; " % [str((body as Node).get_path()) if body is Node else "unknown", result.get_collider_shape(contact), point, normal]
			if not body is CollisionObject3D or not normal.is_finite() or not point.is_finite():
				return {"ok": false, "reason": "corridor has unknown native contact: " + context}
			if normal.dot(up) < cos(_h.player.floor_max_angle):
				return {"ok": false, "reason": "corridor obstructed by %s shape=%d point=%s normal=%s %s" % [(body as Node).get_path(), result.get_collider_shape(contact), point, normal, context]}
			if not _support_context.is_empty() and not _h.is_approach_support({"collider": body, "normal": normal, "shape": result.get_collider_shape(contact), "position": point}, _support_context):
				return {"ok": false, "reason": "corridor left qualified rooftop support: " + details}
			slope = maxf(slope, -inward.dot(normal) / up.dot(normal))
	return {"ok": true, "collided": collided, "travel": travel, "slope": slope, "details": details + "]"}


func _check_walk_up(box: AABB, own: Array[RID], wall_shapes: Dictionary, wall_faces: Array[Dictionary]) -> void:
	var center := box.get_center()
	var passed := 0
	var attempted := 0
	var sides := [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
	for side: Vector3 in sides:
		if _unsafe:
			break
		var half_depth := absf(side.x) * box.size.x * 0.5 + absf(side.z) * box.size.z * 0.5
		var name := "walk-up from %s" % _side_name(side)
		var half_width := absf(side.z) * box.size.x * 0.5 + absf(side.x) * box.size.z * 0.5
		var setup := _walk_start(center, side, half_depth, half_width, own, wall_shapes, wall_faces)
		if not setup.ok:
			_failures.append(_prefix + "%s: no safe same-side start: %s" % [name, setup.reason])
			_unsafe = true
			break
		var start := setup.xz as Vector2
		var destination := setup.destination as Vector3
		attempted += 1
		var setup_recoveries := _h.world.get_runtime_evidence().recovery_count
		var placed := await _h.settle_player(start, _support_context)
		if placed != "":
			_failures.append(_prefix + "%s: player can't start at (%.1f, %.1f): %s" % [name, start.x, start.y, placed])
			_unsafe = true
			break
		# Qualify the stock body's actual final settling contacts, including the
		# last few centimetres below the read-only clearance sweep. A central
		# ground ray cannot rule out support from a neighboring low ledge.
		var ground_support := false
		var wrong_support := false
		var floor_up := _h.player.up_direction.normalized()
		var floor_up_dot := cos(_h.player.floor_max_angle)
		for slide_index in _h.player.get_slide_collision_count():
			var slide := _h.player.get_slide_collision(slide_index)
			for contact_index in slide.get_collision_count():
				var normal := slide.get_normal(contact_index)
				if normal.dot(floor_up) < floor_up_dot:
					continue
				var body := slide.get_collider(contact_index)
				var walkable := _h.is_approach_support({"collider": body, "normal": normal, "shape": slide.get_collider_shape_index(contact_index), "position": slide.get_position(contact_index)}, _support_context)
				ground_support = ground_support or walkable
				wrong_support = wrong_support or not walkable
				print("%sWALK_START_SUPPORT side=%s walkable=%s body=%s" % [_prefix, _side_name(side), walkable, str((body as Node).get_path()) if body is Node else "unknown"])
		if not ground_support or wrong_support or _h.world.get_runtime_evidence().recovery_count != setup_recoveries:
			_failures.append(_prefix + "%s: settled support was not exclusively native walkable ground, or setup required recovery" % name)
			_unsafe = true
			# No forward input is applied. Still prove active released rest before
			# the safe disabled final state, preserving the original support HOLD.
			_h.release_input()
			_h.player.set_gameplay_enabled(true)
			var rest_error := await _rest_and_disable(setup_recoveries)
			if rest_error != "":
				_failures.append(_prefix + "%s: %s" % [name, rest_error])
			break
		var problem := await _walk_toward(Vector3(destination.x, _h.player.global_position.y + 1.5, destination.z), own, wall_shapes)
		var at := _h.player.global_position
		var blocker := _blocker(own)
		var arrived := false
		if problem != "":
			_failures.append(_prefix + "%s: %s" % [name, problem])
		elif _wall_touched or _distance_to_walls(at, destination, own, wall_shapes) <= ARRIVAL_DISTANCE_M:
			arrived = true
		elif blocker != "":
			_failures.append(_prefix + "%s was blocked by %s at (%.1f, %.1f)" % [name, blocker, at.x, at.z])
		else:
			_failures.append(_prefix + "%s: player got stuck short of the building at (%.1f, %.1f) without hitting anything" % [name, at.x, at.z])
		if arrived:
			passed += 1
		print("%sWALK_UP side=%s arrived=%s at=%s contacts=%s" % [_prefix, _side_name(side), arrived, at, _touched.map(func(body: Object) -> String: return str((body as Node).get_path()))])
	print("%swalk-up: %d of %d required sides passed; %d attempted" % [_prefix, passed, sides.size(), attempted])
	if passed != sides.size():
		_failures.append(_prefix + "walk-up: required approaches incomplete; remaining cases were not accepted")


## Walks from the bottom of a stair flight to its top and back down.
func _check_stairs(stair: Dictionary) -> void:
	var bottom := Vector2(stair.bottom[0], stair.bottom[1])
	var top := Vector2(stair.top[0], stair.top[1])
	var name := "stairs (%.1f, %.1f) -> (%.1f, %.1f)" % [bottom.x, bottom.y, top.x, top.y]
	var error := await _h.settle_player(bottom, _support_context)
	if error != "":
		_failures.append(_prefix + "%s: can't start at the bottom: %s" % [name, error])
		_unsafe = true
		return
	var bottom_y := _h.player.global_position.y
	for leg: Vector2 in [top, bottom]:
		var problem := await _walk_toward(Vector3(leg.x, _h.player.global_position.y + 1.5, leg.y))
		var at := _h.player.global_position
		if problem != "":
			_failures.append(_prefix + "%s: %s" % [name, problem])
			return
		if Vector2(at.x, at.z).distance_to(leg) > ARRIVAL_DISTANCE_M:
			_failures.append(_prefix + "%s: player got stuck at (%.1f, %.1f, %.1f)" % [name, at.x, at.y, at.z])
			return
		if leg == top and at.y < bottom_y + 0.5:
			_failures.append(_prefix + "%s: reached the top position without climbing (y %.1f)" % [name, at.y])
			return
	print("%s%s: walked up and down" % [_prefix, name])


func _check_routes(routes: Array, box: AABB) -> void:
	var names := {}
	# Validate the complete route list before beginning any new movement case.
	for route: Variant in routes:
		if not route is Dictionary or not route.get("name") is String or route.name == "" or names.has(route.name) or not _numbers(route.get("start_xz")) or not _numbers(route.get("end_xz")):
			_failures.append(_prefix + "routes need unique names and finite start_xz/end_xz pairs")
			_unsafe = true
			return
		names[route.name] = true
		for value: Array in [route.start_xz, route.end_xz]:
			if not box.grow(15.0).has_point(Vector3(value[0], box.get_center().y, value[1])):
				_failures.append(_prefix + "route is outside the source building's surroundings: " + route.name)
				_unsafe = true
				return
	for route: Dictionary in routes:
		var start := Vector2(route.start_xz[0], route.start_xz[1])
		var end := Vector2(route.end_xz[0], route.end_xz[1])
		var problem := await _h.settle_player(start, _support_context)
		if problem != "":
			_failures.append(_prefix + "route " + route.name + " setup: " + problem)
			_unsafe = true
			return
		for target: Vector2 in [end, start]:
			if target == start:
				# Walk back along the same line, from the route's end point.
				problem = await _h.settle_player(end, _support_context)
				if problem != "":
					_failures.append(_prefix + "route " + route.name + " return setup: " + problem)
					_unsafe = true
					return
			problem = await _walk_toward(Vector3(target.x, _h.player.global_position.y + 1.5, target.y))
			var at := _h.player.global_position
			var distance := _closest
			print("ROUTE %s target=%s arrived=%s distance=%.3f contacts=%s" % [route.name, target, at, distance, _touched.map(func(body: Object) -> String: return str((body as Node).get_path()))])
			if problem != "" or distance > 0.75:
				_failures.append(_prefix + "route " + route.name + ": " + (problem if problem != "" else "stopped short of destination"))
				# The reverse leg depends on reaching the forward destination.
				break
		if _unsafe:
			return


func _numbers(value: Variant) -> bool:
	if not value is Array or value.size() != 2:
		return false
	for number: Variant in value:
		if not (number is float or number is int) or not is_finite(float(number)):
			return false
	return true


## One optional real stock spray, bound to this source and ordinary camera/player.
func _check_spray(source: String, plan: Dictionary, bounds: AABB) -> void:
	var screenshot_path := ""
	if plan.has("screenshot_path"):
		if not plan.screenshot_path is String or not _spray_screenshot_path_valid(plan.screenshot_path):
			_failures.append(_prefix + "spray screenshot needs a normalized absolute PNG path outside project/Git trees")
			_unsafe = true
			return
		screenshot_path = plan.screenshot_path
	if not _numbers(plan.get("player_xz")) or not plan.get("target_xyz") is Array or plan.target_xyz.size()!=3:
		_failures.append(_prefix+"spray needs finite player_xz/target_xyz")
		_unsafe=true
		return
	for value: Variant in plan.target_xyz:
		if not (value is float or value is int) or not is_finite(float(value)):
			_failures.append(_prefix+"spray target must be finite")
			_unsafe=true
			return
	var target:=Vector3(plan.target_xyz[0],plan.target_xyz[1],plan.target_xyz[2])
	if not bounds.grow(0.5).has_point(target):
		_failures.append(_prefix+"spray target outside source bounds")
		_unsafe=true
		return
	var error:=await _h.settle_player(Vector2(plan.player_xz[0],plan.player_xz[1]), _support_context)
	if error!="":
		_failures.append(_prefix+"spray setup: "+error)
		_unsafe=true
		return
	var recoveries:=_h.world.get_runtime_evidence().recovery_count
	_h.aim_camera(target)
	_h.player.set_gameplay_enabled(true)
	for _frame in 4:
		await _h.tree.physics_frame
		var support_error := _rooftop_floor_problem()
		if support_error != "":
			_h.release_input()
			_unsafe = true
			var rest_error := await _rest_and_disable(recoveries)
			_failures.append(_prefix + support_error + ("; " + rest_error if rest_error != "" else ""))
			return
	var spray:=_h.player.get_spray_controller()
	var pool:=spray.tag_instances
	var before:=pool.get_children()
	var results: Array[String]=[]
	var record:=func(code: String) -> void:results.append(code)
	spray.spray_result.connect(record)
	if _h.world.get_runtime_evidence().recovery_count==recoveries:spray.attempt_spray()
	spray.spray_result.disconnect(record)
	var placed: Array[Decal]=[]
	for child: Node in pool.get_children():
		if child is Decal and child not in before:placed.append(child)
	var valid:=results==["placed"] and placed.size()==1
	if valid:
		var tag: Decal=placed[0]
		valid=tag.get_meta("derived_object_key","")=="building:"+source+":wall" and tag.get_meta("source_keys",[])==[source] and tag.texture_albedo!=null and tag.cull_mask==SprayController.RENDER_BUILDING_WALL
		print("SPRAY source=%s result=%s decal=%s receiver=%s position=%s" % [source,results,tag.get_path(),tag.get_meta("derived_object_key",""),tag.global_position])
	var rest_error:=await _rest_and_disable(recoveries)
	if rest_error!="":_failures.append(_prefix+"spray "+rest_error)
	if not valid:
		_failures.append(_prefix+"spray did not place one actual source-bound wall decal: "+str(results))
		_unsafe=true
	if valid and rest_error == "" and not screenshot_path.is_empty():
		var screenshot_error := await _h.save_screenshot(screenshot_path)
		if screenshot_error != "":
			_failures.append(_prefix + "spray " + screenshot_error)
		else:
			print("SPRAY_SCREENSHOT source=%s path=%s" % [source, screenshot_path])
	# A fresh-world case can clear its sole new tag through the pool.
	# If prior tags exist, preserve the pool (including the new tag) until teardown.
	if before.is_empty():pool.clear_tags()


## Existing output directories only; reject symlink aliases into protected trees.
func _spray_screenshot_path_valid(path: String) -> bool:
	if not path.begins_with("/") or path != path.simplify_path() or path.get_extension().to_lower() != "png":
		return false
	var directory := DirAccess.open(path.get_base_dir())
	if directory == null or directory.is_link(path) or FileAccess.file_exists(path):
		return false
	var project := ProjectSettings.globalize_path("res://").simplify_path().trim_suffix("/")
	var parent := path.get_base_dir()
	while parent != "":
		if parent == project or directory.is_link(parent) or FileAccess.file_exists(parent.path_join(".git")) or DirAccess.dir_exists_absolute(parent.path_join(".git")):
			return false
		var next := parent.get_base_dir()
		if next == parent:
			break
		parent = next
	return true


## Holds forward toward target until the player bumps into the building
## (own), arrives, or stops moving; returns a problem or "".
func _walk_toward(target: Vector3, own: Array[RID] = [], wall_shapes: Dictionary = {}) -> String:
	var evidence := _h.world.get_runtime_evidence()
	var recoveries := evidence.recovery_count
	var start := _h.player.global_position
	var distance := Vector2(start.x, start.z).distance_to(Vector2(target.x, target.z))
	var speed := _h.player.walk_speed_mps
	if not is_finite(distance) or not is_finite(speed) or speed <= 0.0:
		_unsafe = true
		_h.player.set_gameplay_enabled(true)
		var rest_error := await _rest_and_disable(recoveries)
		return "invalid stock walk distance or speed" + ("; " + rest_error if rest_error != "" else "")
	var seconds := maxf(MIN_WALK_SECONDS, distance / speed + WALK_ACCELERATION_ALLOWANCE_SECONDS)
	var walk_frames := ceili(seconds * Engine.physics_ticks_per_second)
	print("%sWALK_BUDGET distance=%.3f speed=%.3f seconds=%.3f frames=%d target=%s" % [_prefix, distance, speed, seconds, walk_frames, target])
	_h.aim_camera(target)
	_h.player.set_gameplay_enabled(true)
	Input.action_press("move_forward")
	_touched = []
	_wall_touched = false
	var still_frames := 0
	_closest = INF
	var support_error := ""
	for frame in walk_frames:
		await _h.tree.physics_frame
		if evidence.recovery_count != recoveries:
			# Release held input immediately at the recovery boundary; do not
			# continue driving the respawned player toward the old destination.
			break
		support_error = _rooftop_floor_problem()
		if support_error != "":
			_h.release_input()
			_unsafe = true
			break
		for i in _h.player.get_slide_collision_count():
			var slide := _h.player.get_slide_collision(i)
			for contact in slide.get_collision_count():
				var body := slide.get_collider(contact)
				var normal := slide.get_normal(contact)
				if body != null and normal.dot(Vector3.UP) < 0.7 and body not in _touched:
					_touched.append(body)
				if body is CollisionObject3D and _architectural_contact((body as CollisionObject3D).get_rid(), slide.get_collider_shape_index(contact), normal, wall_shapes):
					_wall_touched = true

		var at := _h.player.global_position
		var remaining := Vector2(at.x, at.z).distance_to(Vector2(target.x, target.z))
		_closest = minf(_closest, remaining)
		# Stop on arrival, on reaching the building, or once the player has
		# passed the target and is walking away from it.
		if remaining < 0.5 or (_wall_touched if not wall_shapes.is_empty() else _touched_own(own)) or remaining > _closest + 1.0:
			break
		still_frames = still_frames + 1 if Vector2(_h.player.velocity.x, _h.player.velocity.z).length() < 0.2 else 0
		if frame > 60 and still_frames > 60:
			break
	var rest_error := await _rest_and_disable(recoveries)
	return support_error + ("; " if support_error != "" and rest_error != "" else "") + rest_error


## A frame may report no slide events. Qualify every reported floor subcontact,
## without turning missing per-frame events into a new controller requirement.
func _rooftop_floor_problem() -> String:
	if _support_context.is_empty():
		return ""
	var up := _h.player.up_direction.normalized()
	var floor_dot := cos(_h.player.floor_max_angle)
	for index in _h.player.get_slide_collision_count():
		var slide := _h.player.get_slide_collision(index)
		for contact in slide.get_collision_count():
			var normal := slide.get_normal(contact)
			if not normal.is_finite():
				return "active rooftop contact has an unknown normal"
			if normal.dot(up) < floor_dot:
				continue
			var body := slide.get_collider(contact)
			var point := slide.get_position(contact)
			var shape := slide.get_collider_shape_index(contact)
			if not _h.is_approach_support({"collider": body, "normal": normal, "shape": shape, "position": point}, _support_context):
				return "active rooftop support mismatch: body=%s shape=%d point=%s normal=%s" % [str((body as Node).get_path()) if body is Node else "unknown", shape, point, normal]
	return ""


func _rest_and_disable(recoveries: int) -> String:
	var evidence := _h.world.get_runtime_evidence()
	_h.release_input()
	var support_error := ""
	for _frame in 30:
		await _h.tree.physics_frame
		var problem := _rooftop_floor_problem()
		if problem != "":
			_unsafe = true
			support_error = problem
	# Stock disable clears velocity. Preserve actual active-controller rest and
	# support before that operation, then independently verify safe teardown.
	var at := _h.player.global_position
	var support := _h.ray(at + Vector3.UP * 0.2, at - Vector3.UP * 0.4, _h.player.collision_mask)
	var released := true
	for action in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		released = released and not Input.is_action_pressed(action)
	var active := _h.player.is_physics_processing()
	var grounded := _h.player.is_on_floor()
	var stopped := _h.player.velocity.length() <= 0.05
	var supported := not support.is_empty() and (support.normal as Vector3).dot(Vector3.UP) >= 0.7
	if not _support_context.is_empty():
		supported = supported and _h.is_approach_support(support, _support_context)
		var floor_seen := false
		for slide_index in _h.player.get_slide_collision_count():
			var slide := _h.player.get_slide_collision(slide_index)
			for contact in slide.get_collision_count():
				var normal := slide.get_normal(contact)
				if normal.dot(_h.player.up_direction.normalized()) < cos(_h.player.floor_max_angle):
					continue
				floor_seen = true
				supported = supported and _h.is_approach_support({"collider": slide.get_collider(contact), "normal": normal, "shape": slide.get_collider_shape_index(contact), "position": slide.get_position(contact)}, _support_context)
		supported = supported and floor_seen
	print("REST active=%s released=%s grounded=%s supported=%s velocity=%s at=%s support=%s" % [active, released, grounded, supported, _h.player.velocity, at, str((support.collider as Node).get_path()) if supported else "none"])
	_h.player.set_gameplay_enabled(false)
	var safe_final := not _h.player.is_physics_processing() and _h.player.velocity == Vector3.ZERO and released
	print("SAFE_FINAL disabled=%s zero_velocity=%s input_released=%s" % [not _h.player.is_physics_processing(), _h.player.velocity == Vector3.ZERO, released])
	if not (active and released and grounded and stopped and supported and safe_final):
		_unsafe = true
		return support_error + ("; " if support_error != "" else "") + "supported active-controller rest or safe disabled final state failed"
	if evidence.recovery_count != recoveries:
		_unsafe = true
		return support_error + ("; " if support_error != "" else "") + "player fell and had to be recovered"
	return support_error


func _touched_own(own: Array[RID]) -> bool:
	return _touched.any(func(body: Object) -> bool: return body is CollisionObject3D and (body as CollisionObject3D).get_rid() in own)


## Name of something other than the building the player bumped into, or "".
func _blocker(own: Array[RID]) -> String:
	for body in _touched:
		if body is CollisionObject3D and not (body as CollisionObject3D).get_rid() in own:
			var node := body as Node
			var record := node.get_parent()
			return str(record.get_meta("derived_object_key", node.name)) if record != null else str(node.name)
	return ""


## A native body can contain both walls and non-wall support shapes. Preserve
## the qualified shape index and require a side face, not a floor/roof contact.
func _architectural_contact(rid: RID, shape_index: int, normal: Vector3, wall_shapes: Dictionary) -> bool:
	return wall_shapes.has(rid) and shape_index in wall_shapes[rid] \
		and absf(normal.dot(_h.player.up_direction.normalized())) < cos(_h.player.floor_max_angle)


func _wall_hit(from: Vector3, to: Vector3, own: Array[RID], wall_shapes: Dictionary) -> Dictionary:
	var hit := _own_hit(from, to, own)
	if not hit.is_empty() and _architectural_contact(hit.rid, int(hit.shape), hit.normal, wall_shapes):
		return hit
	# Do not exclude a whole mixed RID to see through an unqualified shape.
	return {}


## Distance from the player to the building's own collision toward its centre.
## No wall hit cannot prove arrival; actual openings are checked separately.
func _distance_to_walls(at: Vector3, center: Vector3, own: Array[RID], wall_shapes: Dictionary) -> float:
	var chest := at + Vector3.UP
	var wall := _wall_hit(chest, Vector3(center.x, chest.y, center.z), own, wall_shapes)
	return chest.distance_to(wall.position as Vector3) if not wall.is_empty() else INF


## True when solid building geometry is right above the player, i.e. they are under its mass.
func _inside(box: AABB, at: Vector3) -> bool:
	if not box.grow(-0.5).has_point(Vector3(at.x, box.get_center().y, at.z)):
		return false
	return not _h.ray(at + Vector3.UP * 2.0, Vector3(at.x, box.end.y + 1.0, at.z), VISUAL_LAYER).is_empty()


## Height of the surface the building stands on at xz: ground, or another
## building's roof for a building on top of one. NAN if there's nothing level.
func _surface_y(xz: Vector2, own: Array[RID]) -> float:
	var hit := _h.ray(Vector3(xz.x, 300.0, xz.y), Vector3(xz.x, -50.0, xz.y), _h.player.collision_mask, own)
	if not _support_context.is_empty() and not _h.is_approach_support(hit, _support_context):
		return NAN
	return float((hit.position as Vector3).y) if not hit.is_empty() and (hit.normal as Vector3).dot(Vector3.UP) >= 0.7 else NAN


## Name of the visible part a ray hit on the visual layer.
func _mesh_name(seen: Dictionary) -> String:
	return str((seen.collider as Node).get_meta("mesh_name", "?"))


func _side_name(side: Vector3) -> String:
	return {Vector3.FORWARD: "north", Vector3.BACK: "south", Vector3.LEFT: "west", Vector3.RIGHT: "east"}[side]


## A check that found nothing to sample didn't test anything, so it fails.
func _report(check: String, samples: int, bad: Array[String], what: String) -> void:
	if samples == 0:
		_failures.append(_prefix + "%s: nothing to sample, so the check could not run" % check)
		return
	var share := float(bad.size()) / float(samples)
	print("%s%s: %d of %d samples bad" % [_prefix, check, bad.size(), samples])
	if share > SAMPLE_FAILURE_LIMIT:
		_failures.append(_prefix + "%s %s" % [what, ", ".join(bad.slice(0, 8))])
