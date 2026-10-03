extends SceneTree
## Screenshots for the visual reviewer, taken in the real loaded island.
##
##   tools/godot --path . --resolution 1600x900 --script game/tests/shared/building_shots.gd -- --source w291189336 --out /tmp/shots
##   tools/godot --path . --resolution 1600x900 --script game/tests/shared/building_shots.gd -- --island --out /tmp/shots
##
## --source KEY: four gameplay-camera views of the building from around it
##   (closeup-*.png) and two raised views showing it in its surroundings (context-*.png).
## --island: fixed overview views of the whole island (island-*.png), the same
##   every run, so before/after shots of a change compare directly.
## Both can be passed together. Needs a GPU display; tools/godot provides one.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")

var _h: WorldHarness
var _errors: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := WorldHarness.user_args()
	var out := str(args.get("out", ""))
	if out == "" or (not args.has("source") and not args.has("island")):
		_fail("usage: -- [--source KEY] [--island] --out DIR")
		return
	DirAccess.make_dir_recursive_absolute(out)
	_h = WorldHarness.new(self)
	var error := await _h.load_world()
	if error != "":
		_fail(error)
		return
	print("RENDERER: %s / %s" % [RenderingServer.get_video_adapter_name(), DisplayServer.get_name()])
	if args.has("source"):
		await _building_shots(str(args.source), out)
	if args.has("island"):
		await _island_shots(out)
	if _errors.is_empty():
		print("PASS: screenshots in %s" % out)
	else:
		for message in _errors:
			push_error(message)
	_h.main.queue_free()
	quit(0 if _errors.is_empty() else 1)


func _building_shots(source_key: String, out: String) -> void:
	var nodes := _h.building_nodes(source_key)
	var meshes := _h.visual_meshes(nodes)
	if meshes.is_empty():
		_errors.append("no visible geometry found for building %s" % source_key)
		return
	var box := _h.bounds(meshes)
	var center := box.get_center()
	var own := _h.collision_rids(nodes)
	var radius := maxf(Vector2(box.size.x, box.size.z).length() * 0.5 + 10.0, 15.0)
	var target := Vector3(center.x, box.position.y + box.size.y * 0.4, center.z)
	# Gameplay-camera views from the four sides, trying nearby spots when a
	# side is blocked (water, another building, outside the boundary).
	for side in ["north", "east", "south", "west"]:
		var base_angle: float = {"north": -PI / 2.0, "east": 0.0, "south": PI / 2.0, "west": PI}[side]
		var taken := false
		for attempt in [[0.0, 1.0], [0.35, 1.0], [-0.35, 1.0], [0.0, 1.4], [0.0, 0.75], [0.7, 1.2], [-0.7, 1.2]]:
			var angle := base_angle + float(attempt[0])
			var spot := Vector2(center.x, center.z) + Vector2(cos(angle), sin(angle)) * radius * float(attempt[1])
			if await _h.settle_player(spot) != "":
				continue
			_h.aim_camera(target)
			await physics_frame
			await physics_frame
			if not _sees_building(target, own):
				continue
			var error := await _h.save_screenshot("%s/closeup-%s.png" % [out, side])
			if error != "":
				_errors.append(error)
			taken = true
			break
		if not taken:
			print("NOTE: no clear gameplay view of %s from the %s" % [source_key, side])
	# Raised views of the building in its surroundings.
	var camera := Camera3D.new()
	camera.fov = 60.0
	camera.far = 5000.0
	_h.main.add_child(camera)
	for view in [["southwest", Vector3(-1.0, 0.0, 1.0)], ["northeast", Vector3(1.0, 0.0, -1.0)]]:
		var direction := (view[1] as Vector3).normalized()
		camera.global_position = center + direction * radius * 3.0 + Vector3.UP * (box.size.y + radius * 1.2)
		camera.look_at(center, Vector3.UP)
		camera.make_current()
		var error := await _h.save_screenshot("%s/context-%s.png" % [out, view[0]])
		if error != "":
			_errors.append(error)
	camera.queue_free()
	_h.player.get_camera().make_current()


func _sees_building(target: Vector3, own: Array[RID]) -> bool:
	var from := _h.player.get_camera().global_position
	var hit := _h.ray(from, target)
	return hit.is_empty() or (hit.rid as RID) in own


func _island_shots(out: String) -> void:
	var low := Vector2(INF, INF)
	var high := Vector2(-INF, -INF)
	for component: Dictionary in _h.world.get_boundary().get_boundary_data().components:
		for point: Array in component.outer:
			low = Vector2(minf(low.x, point[0]), minf(low.y, point[1]))
			high = Vector2(maxf(high.x, point[0]), maxf(high.y, point[1]))
	var center := Vector3((low.x + high.x) * 0.5, 0.0, (low.y + high.y) * 0.5)
	var span := (high - low).length()
	var camera := Camera3D.new()
	camera.fov = 55.0
	camera.far = 10000.0
	_h.main.add_child(camera)
	var views := [
		["top", Vector3(0.0, span * 0.75, span * 0.05)],
		["from-southwest", Vector3(-span * 0.36, span * 0.26, span * 0.36)],
		["from-southeast", Vector3(span * 0.36, span * 0.26, span * 0.36)],
		["from-northwest", Vector3(-span * 0.36, span * 0.26, -span * 0.36)],
		["from-northeast", Vector3(span * 0.36, span * 0.26, -span * 0.36)],
	]
	for view in views:
		camera.global_position = center + (view[1] as Vector3)
		camera.look_at(center, Vector3.UP)
		camera.make_current()
		var error := await _h.save_screenshot("%s/island-%s.png" % [out, view[0]])
		if error != "":
			_errors.append(error)
	camera.queue_free()
	_h.player.get_camera().make_current()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
