extends SceneTree
## Checks that a building fits into the island and plays right, in the real loaded world.
##
##   tools/godot --headless --path . --script game/tests/shared/building_fit_test.gd -- --source w291189336
##
## 1. Roof: wherever the building is visible from above, the player can stand on it
##    (collision is there, not just a picture of a roof).
## 2. Walls: wherever a wall is visible at chest height, it also blocks the player.
## 3. Grounded: visible walls reach down to the ground next to them (no floating building).
## 4. Walk-up: from each side the stock player walks up to the building, stays on
##    the ground and never needs a fall recovery. Ending up under the building
##    (carport, arcade, open hall) is only noted; walking through walls is check 2.
##
## Prints PASS or FAIL lines and exits non-zero on failure.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")
const VISUAL_LAYER := 1 << 19
const SAMPLE_FAILURE_LIMIT := 0.10

var _h: WorldHarness
var _failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := WorldHarness.user_args()
	if not args.has("source"):
		push_error("usage: -- --source KEY")
		quit(1)
		return
	var source_key := str(args.source)
	_h = WorldHarness.new(self)
	var error := await _h.load_world()
	if error != "":
		push_error(error)
		quit(1)
		return
	var nodes := _h.building_nodes(source_key)
	var meshes := _h.visual_meshes(nodes)
	if meshes.is_empty():
		push_error("FAIL: no visible geometry found for building %s" % source_key)
		quit(1)
		return
	var box := _h.bounds(meshes)
	var own := _h.collision_rids(nodes)
	_add_visual_proxies(meshes)
	await physics_frame
	await physics_frame
	print("Building %s: %d meshes, size %.1f x %.1f x %.1f m" % [source_key, meshes.size(), box.size.x, box.size.y, box.size.z])
	_check_roof(box)
	_check_walls(box, own)
	await _check_walk_up(box)
	if _failures.is_empty():
		print("PASS: building %s fits and plays" % source_key)
	else:
		for message in _failures:
			print("FAIL: " + message)
	_h.main.queue_free()
	quit(0 if _failures.is_empty() else 1)


## Collision copies of the visible meshes on a separate layer, so rays can
## compare "what you see" against "what the player collides with".
func _add_visual_proxies(meshes: Array) -> void:
	for entry in meshes:
		var shape := (entry[0] as Mesh).create_trimesh_shape()
		if shape == null:
			continue
		shape.backface_collision = true
		var body := StaticBody3D.new()
		body.collision_layer = VISUAL_LAYER
		body.collision_mask = 0
		var collider := CollisionShape3D.new()
		collider.shape = shape
		body.add_child(collider)
		_h.main.add_child(body)
		body.global_transform = entry[1]


func _check_roof(box: AABB) -> void:
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
			samples += 1
			var solid := _h.ray(top, bottom)
			if solid.is_empty() or (solid.position as Vector3).y < (seen.position as Vector3).y - 1.0:
				holes.append("(%.1f, %.1f)" % [x, z])
	_report("roof", samples, holes, "visible roof the player falls through at")


func _check_walls(box: AABB, own: Array[RID]) -> void:
	var samples := 0
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
			var ground := _open_ground_y(Vector2(outside.x, outside.z), own)
			if is_nan(ground):
				continue
			var start := Vector3(outside.x, ground + 1.0, outside.z)
			var end := start - side * (half_depth * 2.0 + 4.0)
			var seen := _h.ray(start, end, VISUAL_LAYER)
			if seen.is_empty():
				continue
			samples += 1
			var seen_at := start.distance_to(seen.position as Vector3)
			var solid := _h.ray(start, end)
			if solid.is_empty() or start.distance_to(solid.position as Vector3) > seen_at + 0.5:
				open.append("(%.1f, %.1f)" % [seen.position.x, seen.position.z])
			# The same wall should still be there just above the local ground.
			var wall_xz := Vector2((seen.position as Vector3).x, (seen.position as Vector3).z) + Vector2(side.x, side.z) * 0.3
			var local_ground := _open_ground_y(wall_xz, own)
			if is_nan(local_ground):
				continue
			var low_start := Vector3(start.x, local_ground + 0.15, start.z)
			var low := _h.ray(low_start, low_start - side * (half_depth * 2.0 + 4.0), VISUAL_LAYER)
			if low.is_empty() or low_start.distance_to(low.position as Vector3) > seen_at + 1.0:
				floating.append("(%.1f, %.1f)" % [seen.position.x, seen.position.z])
	_report("walls", samples, open, "visible wall the player walks through at")
	_report("grounded", samples, floating, "wall not reaching the ground at")


func _check_walk_up(box: AABB) -> void:
	var evidence := _h.world.get_runtime_evidence()
	var center := box.get_center()
	var walked := 0
	for side: Vector3 in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
		var half_depth := absf(side.x) * box.size.x * 0.5 + absf(side.z) * box.size.z * 0.5
		var start := Vector2(center.x, center.z) + Vector2(side.x, side.z) * (half_depth + 5.0)
		if await _h.settle_player(start) != "":
			continue
		walked += 1
		var recoveries := evidence.recovery_count
		_h.aim_camera(Vector3(center.x, _h.player.global_position.y + 1.5, center.z))
		_h.player.set_gameplay_enabled(true)
		Input.action_press("move_forward")
		for _frame in 240:
			await physics_frame
		_h.release_input()
		for _frame in 30:
			await physics_frame
		_h.player.set_gameplay_enabled(false)
		var at := _h.player.global_position
		var name := "walk-up from %s" % _side_name(side)
		if evidence.recovery_count != recoveries:
			_failures.append("%s: player fell and had to be recovered" % name)
		elif not _h.player.is_on_floor():
			_failures.append("%s: player ended up not standing on anything at %s" % [name, at])
		elif _inside(box, at):
			print("NOTE: %s ended under the building at (%.1f, %.1f); check the screenshots that this is an opening" % [name, at.x, at.z])
	if walked == 0:
		print("NOTE: walk-up skipped, no walkable ground on any side")
	else:
		print("walk-up: tried %d sides" % walked)


## True when solid building geometry is right above the player, i.e. they are under its mass.
func _inside(box: AABB, at: Vector3) -> bool:
	if not box.grow(-0.5).has_point(Vector3(at.x, box.get_center().y, at.z)):
		return false
	return not _h.ray(at + Vector3.UP * 2.0, Vector3(at.x, box.end.y + 1.0, at.z), VISUAL_LAYER).is_empty()


## Height of open land/road at xz, ignoring this building; NAN on roofs, water etc.
func _open_ground_y(xz: Vector2, own: Array[RID]) -> float:
	var hit := _h.ray(Vector3(xz.x, 300.0, xz.y), Vector3(xz.x, -50.0, xz.y), WorldHarness.WORLD_SOLID_MASK, own)
	return float((hit.position as Vector3).y) if _h.is_walkable_ground(hit) else NAN


func _side_name(side: Vector3) -> String:
	return {Vector3.FORWARD: "north", Vector3.BACK: "south", Vector3.LEFT: "west", Vector3.RIGHT: "east"}[side]


func _report(check: String, samples: int, bad: Array[String], what: String) -> void:
	if samples == 0:
		print("%s: nothing to sample" % check)
		return
	var share := float(bad.size()) / float(samples)
	print("%s: %d of %d samples bad" % [check, bad.size(), samples])
	if share > SAMPLE_FAILURE_LIMIT:
		_failures.append("%s %s" % [what, ", ".join(bad.slice(0, 8))])
