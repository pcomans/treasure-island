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
## --overhead "center_x,center_z,width,depth": orthographic world -Z-up site view.
## Pass the flag and comma-separated value as separate arguments.
## Options can be combined. Needs a GPU display; tools/godot provides one.
## --views FILE adds source-bound focused gameplay views without replacing these
## defaults: {"source": "KEY", "views": [{"name": "entrance",
## "player_xz": [x,z], "target_xyz": [x,y,z]}]}.

const WorldHarness := preload("res://game/tests/shared/world_harness.gd")

var _h: WorldHarness
var _errors: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := WorldHarness.user_args()
	var out := str(args.get("out", ""))
	if out == "" or (not args.has("source") and not args.has("island") and not args.has("overhead")):
		_fail("usage: -- [--source KEY] [--island] [--overhead center_x,center_z,width,depth] --out DIR")
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
	if args.has("views"):
		await _focused_views(str(args.get("source", "")), str(args.views), out)
	if args.has("island"):
		await _island_shots(out)
	if args.has("overhead"):
		await _overhead_shot(str(args.overhead), out)
	if _errors.is_empty():
		print("PASS: screenshots in %s" % out)
	else:
		for message in _errors:
			push_error(message)
	_h.main.queue_free()
	quit(0 if _errors.is_empty() else 1)


func _focused_views(source: String, path: String, out: String) -> void:
	var plan: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not plan is Dictionary or source == "" or plan.get("source", "") != source or not plan.get("views") is Array or plan.views.is_empty():
		_errors.append("focused views need a nonempty view list bound to --source")
		return
	var meshes := _h.visual_meshes(_h.building_nodes(source))
	if meshes.is_empty():
		_errors.append("focused views have no source geometry")
		return
	var bounds := _h.bounds(meshes).grow(1.0)
	var names := {}
	for view: Variant in plan.views:
		if not view is Dictionary or not view.get("name") is String or not _numbers(view.get("player_xz"), 2) or not _numbers(view.get("target_xyz"), 3):
			_errors.append("focused view needs name, player_xz and target_xyz")
			return
		var name: String = view.name
		if name == "" or name.validate_filename() != name or names.has(name):
			_errors.append("focused view names must be unique safe filenames")
			return
		names[name] = true
		var target := Vector3(view.target_xyz[0], view.target_xyz[1], view.target_xyz[2])
		if not bounds.has_point(target):
			_errors.append("focused view target lies outside the source building: " + name)
			return
		var error := await _h.settle_player(Vector2(view.player_xz[0], view.player_xz[1]))
		if error != "":
			_errors.append("focused view " + name + ": " + error)
			return
		_h.aim_camera(target)
		await physics_frame
		await physics_frame
		error = await _h.save_screenshot("%s/detail-%s.png" % [out, name])
		if error != "":
			_errors.append(error)
		print("FOCUSED_VIEW %s source=%s player=%s target=%s" % [name, source, _h.player.global_position, target])


func _numbers(value: Variant, size: int) -> bool:
	if not value is Array or value.size() != size:
		return false
	for number: Variant in value:
		if not (number is float or number is int) or not is_finite(float(number)):
			return false
	return true


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


func _overhead_shot(spec: String, out: String) -> void:
	var fields := spec.split(",")
	if fields.size() != 4:
		_errors.append("overhead requires center_x,center_z,width,depth")
		return
	for field in fields:
		if not field.is_valid_float():
			_errors.append("overhead fields must be numeric")
			return
	var width := float(fields[2])
	var depth := float(fields[3])
	if width <= 0.0 or depth <= 0.0:
		_errors.append("overhead extent must be positive")
		return
	var old_size := root.size
	root.size = Vector2i(roundi(1000.0 * width / depth), 1000)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = depth
	camera.far = 500.0
	_h.main.add_child(camera)
	var center := Vector3(float(fields[0]),0.0,float(fields[1]))
	camera.global_position = center + Vector3.UP * 100.0
	camera.look_at(center, Vector3.FORWARD)
	camera.make_current()
	await process_frame
	await process_frame
	var error := await _h.save_screenshot(out.path_join("site-overhead.png"))
	if error != "": _errors.append(error)
	print("OVERHEAD center=%s extent=%s north_up=-Z size=%s" % [center, Vector2(width,depth), root.size])
	camera.queue_free()
	_h.player.get_camera().make_current()
	root.size = old_size
