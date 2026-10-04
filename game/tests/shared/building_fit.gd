extends RefCounted
## The fit checks for one building in the loaded island; see building_fit_test.gd.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const VISUAL_LAYER := 1 << 19
const SAMPLE_FAILURE_LIMIT := 0.10
## Longest walk: 15 s at 60 fps. Walks end earlier once the player stops moving.
const WALK_FRAMES := 900
## How close (metres) a walk must end to the building or stair top to count as arrived.
const ARRIVAL_DISTANCE_M := 1.5

var _h: WorldHarness
var _failures: Array[String] = []
## Collision objects the player bumped into during the last _walk_toward.
var _touched: Array[Object] = []
var _prefix := ""


func _init(harness: WorldHarness) -> void:
	_h = harness


## Runs the checks for one building and returns its failures (empty = pass).
## The walk-up and stairs are the slow part (seconds of simulated walking each).
## stairs: [{"bottom": [x, z], "top": [x, z]}, ...] from the building's catalog entry.
func check(source_key: String, walk_up: bool, prefix: String = "", stairs: Array = []) -> Array[String]:
	_failures = []
	_prefix = prefix
	var nodes := _h.building_nodes(source_key)
	var meshes := _h.visual_meshes(nodes)
	if meshes.is_empty():
		return [prefix + "no visible geometry found for building %s" % source_key]
	var box := _h.bounds(meshes)
	var own := _h.collision_rids(nodes)
	var proxies := _add_visual_proxies(meshes)
	await _h.tree.physics_frame
	await _h.tree.physics_frame
	print("%sBuilding %s: %d meshes, size %.1f x %.1f x %.1f m" % [prefix, source_key, meshes.size(), box.size.x, box.size.y, box.size.z])
	_check_roof(box, own)
	_check_walls(box, own)
	if walk_up:
		await _check_walk_up(box, own)
		for stair: Dictionary in stairs:
			await _check_stairs(stair)
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
## at its walls (or under an opening), standing, without a fall recovery.
func _check_walk_up(box: AABB, own: Array[RID]) -> void:
	var center := box.get_center()
	var walked := 0
	var skipped_on_building := false
	for side: Vector3 in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
		var half_depth := absf(side.x) * box.size.x * 0.5 + absf(side.z) * box.size.z * 0.5
		var start := Vector2(center.x, center.z) + Vector2(side.x, side.z) * (half_depth + 5.0)
		var name := "walk-up from %s" % _side_name(side)
		var placed := await _h.settle_player(start)
		if placed in [WorldHarness.OFF_ISLAND, WorldHarness.ON_BUILDING]:
			skipped_on_building = skipped_on_building or placed == WorldHarness.ON_BUILDING
			continue
		if placed != "":
			_failures.append(_prefix + "%s: player can't start at (%.1f, %.1f): %s" % [name, start.x, start.y, placed])
			continue
		walked += 1
		var problem := await _walk_toward(Vector3(center.x, _h.player.global_position.y + 1.5, center.z), own)
		var at := _h.player.global_position
		var blocker := _blocker(own)
		if problem != "":
			_failures.append(_prefix + "%s: %s" % [name, problem])
		elif _inside(box, at):
			print(_prefix + "NOTE: %s ended under the building at (%.1f, %.1f); check the screenshots that this is an opening" % [name, at.x, at.z])
		elif _touched_own(own) or _distance_to_walls(at, center, own) <= ARRIVAL_DISTANCE_M:
			pass
		elif blocker != "":
			print(_prefix + "NOTE: %s was blocked by %s at (%.1f, %.1f)" % [name, blocker, at.x, at.z])
		else:
			_failures.append(_prefix + "%s: player got stuck short of the building at (%.1f, %.1f) without hitting anything" % [name, at.x, at.z])
	if walked > 0:
		print("%swalk-up: %d sides" % [_prefix, walked])
	elif skipped_on_building:
		print(_prefix + "NOTE: walk-up skipped; the building stands on another building")
	else:
		_failures.append(_prefix + "walk-up: no side has open ground to start from")


## Walks from the bottom of a stair flight to its top and back down.
func _check_stairs(stair: Dictionary) -> void:
	var bottom := Vector2(stair.bottom[0], stair.bottom[1])
	var top := Vector2(stair.top[0], stair.top[1])
	var name := "stairs (%.1f, %.1f) -> (%.1f, %.1f)" % [bottom.x, bottom.y, top.x, top.y]
	var error := await _h.settle_player(bottom)
	if error != "":
		_failures.append(_prefix + "%s: can't start at the bottom: %s" % [name, error])
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


## Holds forward toward target until the player bumps into the building
## (own), arrives, or stops moving; returns a problem or "".
func _walk_toward(target: Vector3, own: Array[RID] = []) -> String:
	var evidence := _h.world.get_runtime_evidence()
	var recoveries := evidence.recovery_count
	_h.aim_camera(target)
	_h.player.set_gameplay_enabled(true)
	Input.action_press("move_forward")
	_touched = []
	var still_frames := 0
	for frame in WALK_FRAMES:
		await _h.tree.physics_frame
		for i in _h.player.get_slide_collision_count():
			var body := _h.player.get_slide_collision(i).get_collider()
			if body != null and (_h.player.get_slide_collision(i).get_normal().dot(Vector3.UP) < 0.7) and body not in _touched:
				_touched.append(body)
		var at := _h.player.global_position
		if Vector2(at.x, at.z).distance_to(Vector2(target.x, target.z)) < 0.5 or _touched_own(own):
			break
		still_frames = still_frames + 1 if Vector2(_h.player.velocity.x, _h.player.velocity.z).length() < 0.2 else 0
		if frame > 60 and still_frames > 60:
			break
	_h.release_input()
	for _frame in 30:
		await _h.tree.physics_frame
	_h.player.set_gameplay_enabled(false)
	if evidence.recovery_count != recoveries:
		return "player fell and had to be recovered"
	if not _h.player.is_on_floor():
		return "player ended up not standing on anything at %s" % _h.player.global_position
	return ""


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


## Distance from the player to the building's own collision toward its centre
## (0 when nothing of the building is in that direction, e.g. under an opening).
func _distance_to_walls(at: Vector3, center: Vector3, own: Array[RID]) -> float:
	var chest := at + Vector3.UP
	var wall := _own_hit(chest, Vector3(center.x, chest.y, center.z), own)
	return chest.distance_to(wall.position as Vector3) if not wall.is_empty() else 0.0


## True when solid building geometry is right above the player, i.e. they are under its mass.
func _inside(box: AABB, at: Vector3) -> bool:
	if not box.grow(-0.5).has_point(Vector3(at.x, box.get_center().y, at.z)):
		return false
	return not _h.ray(at + Vector3.UP * 2.0, Vector3(at.x, box.end.y + 1.0, at.z), VISUAL_LAYER).is_empty()


## Height of the surface the building stands on at xz: ground, or another
## building's roof for a building on top of one. NAN if there's nothing level.
func _surface_y(xz: Vector2, own: Array[RID]) -> float:
	var hit := _h.ray(Vector3(xz.x, 300.0, xz.y), Vector3(xz.x, -50.0, xz.y), _h.player.collision_mask, own)
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
