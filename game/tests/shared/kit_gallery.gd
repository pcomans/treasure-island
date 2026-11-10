extends SceneTree
## A gallery of street-kit items without the island: the kit's own meshes and
## material on a plain ground under main.tscn's sun and environment, shot from a
## plan's fixed cameras in one launch that takes seconds. For modelling rounds
## on kit items (cars, cones, ...); the island views stay building_shots.gd's.
##
##   <godot> --path . --resolution 1440x900 --script game/tests/shared/kit_gallery.gd -- --plan game/tests/shared/kit_gallery_cars.json --out /tmp/gallery
##
## The plan: {"items": [{"prop": "parked_car", "params": {...}, "level": "lod0",
## "xz": [x, z], "yaw_deg": 0}, ...], "views": [{"name": "...", "camera_xyz":
## [x, y, z], "target_xyz": [x, y, z], "fov": 55}, ...]}. An item is built by
## the kit's preview(prop, params, level, placement): what the world draws for
## one such item at that detail level ("hero", "lod0", "lod1", "shadow"), at any
## distance. Saved as gallery-NAME.png. A view may add "frame_time_frames": N to
## print a FRAME_TIME line for N frames from its camera. Add --rendering-method
## gl_compatibility --rendering-driver opengl3 for the web renderer.

const KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
const MAIN_SCENE := "res://game/scenes/main.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _fail(message: String) -> void:
	push_error("kit gallery: " + message)
	quit(1)


func _run() -> void:
	var args := _user_args()
	if not args.has("plan") or not args.has("out"):
		_fail("needs --plan FILE and --out DIR")
		return
	var text := FileAccess.get_file_as_string(str(args.plan))
	var plan: Variant = JSON.parse_string(text)
	if not plan is Dictionary or not plan.get("items") is Array or not plan.get("views") is Array:
		_fail("the plan needs items and views")
		return
	DirAccess.make_dir_recursive_absolute(str(args.out))
	root.size = Vector2i(1440, 900)
	var stage := Node3D.new()
	stage.name = "KitGallery"
	root.add_child(stage)
	var lighting := _lighting()
	if lighting != "":
		_fail(lighting)
		return
	stage.add_child(_ground())
	var kit := KIT.new()
	for item: Variant in plan.items:
		if not item is Dictionary or not item.get("prop") is String or not item.get("xz") is Array:
			_fail("each item needs prop and xz: %s" % [item])
			return
		var placement := Transform3D(Basis(Vector3.UP, deg_to_rad(float(item.get("yaw_deg", 0.0)))), Vector3(float(item.xz[0]), 0.0, float(item.xz[1])))
		var node: Node3D = kit.preview(str(item.prop), item.get("params", {}), str(item.get("level", "lod0")), placement)
		if node == null:
			_fail("the kit has no %s at %s: %s" % [item.prop, item.get("level", "lod0"), item.get("params", {})])
			return
		stage.add_child(node)
	var camera := Camera3D.new()
	camera.far = 2000.0
	stage.add_child(camera)
	camera.make_current()
	print("KIT_GALLERY renderer=%s method=%s adapter=%s items=%d views=%d" % [DisplayServer.get_name(), RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name(), plan.items.size(), plan.views.size()])
	for _i in 8:
		await process_frame
	for view: Variant in plan.views:
		if not view is Dictionary or not view.get("name") is String or not view.get("camera_xyz") is Array or not view.get("target_xyz") is Array:
			_fail("each view needs name, camera_xyz and target_xyz: %s" % [view])
			return
		camera.fov = float(view.get("fov", 60.0))
		camera.global_position = Vector3(view.camera_xyz[0], view.camera_xyz[1], view.camera_xyz[2])
		camera.look_at(Vector3(view.target_xyz[0], view.target_xyz[1], view.target_xyz[2]), Vector3.UP)
		for _i in 4:
			await process_frame
			await RenderingServer.frame_post_draw
		var path := "%s/gallery-%s.png" % [args.out, view.name]
		if root.get_texture().get_image().save_png(path) != OK:
			_fail("could not save " + path)
			return
		print("GALLERY_VIEW %s" % view.name)
		if view.has("frame_time_frames"):
			await _frame_time(int(view.frame_time_frames), str(view.name))
	quit(0)


## main.tscn's environment and sun, read from the scene file without running it.
func _lighting() -> String:
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		return "could not load " + MAIN_SCENE
	var state := packed.get_state()
	var found := 0
	for index in state.get_node_count():
		var node: Node = null
		match str(state.get_node_name(index)):
			"WorldEnvironment":
				node = WorldEnvironment.new()
			"Sun":
				node = DirectionalLight3D.new()
			_:
				continue
		for property in state.get_node_property_count(index):
			node.set(state.get_node_property_name(index, property), state.get_node_property_value(index, property))
		root.get_node("KitGallery").add_child(node)
		found += 1
	return "" if found == 2 else "main.tscn has no WorldEnvironment and Sun"


func _ground() -> MeshInstance3D:
	var plane := PlaneMesh.new()
	plane.size = Vector2(600.0, 600.0)
	var asphalt := StandardMaterial3D.new()
	asphalt.albedo_color = Color(0.25, 0.25, 0.26)
	asphalt.roughness = 0.92
	asphalt.metallic_specular = 0.2
	plane.material = asphalt
	var ground := MeshInstance3D.new()
	ground.name = "Ground"
	ground.mesh = plane
	return ground


func _frame_time(frames: int, label: String) -> void:
	var vsync := DisplayServer.window_get_vsync_mode()
	var cap := Engine.max_fps
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	for _i in 30:
		await RenderingServer.frame_post_draw
	var times := PackedFloat64Array()
	var last := Time.get_ticks_usec()
	for _i in frames:
		await RenderingServer.frame_post_draw
		var now := Time.get_ticks_usec()
		times.append(float(now - last) / 1000.0)
		last = now
	DisplayServer.window_set_vsync_mode(vsync)
	Engine.max_fps = cap
	times.sort()
	var total := 0.0
	for time in times:
		total += time
	print("FRAME_TIME gallery-%s frames=%d mean_ms=%.2f median_ms=%.2f draw_calls=%d primitives=%d method=%s" % [
		label, times.size(), total / float(times.size()), times[times.size() / 2],
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		RenderingServer.get_current_rendering_method(),
	])


func _user_args() -> Dictionary:
	var args := {}
	var list := OS.get_cmdline_user_args()
	var i := 0
	while i + 1 < list.size():
		args[list[i].trim_prefix("--")] = list[i + 1]
		i += 2
	return args
