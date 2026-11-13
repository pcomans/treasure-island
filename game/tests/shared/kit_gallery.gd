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
##
## "rings": [{"name": "...", "xz": [x, z], "yaw_deg": 0, "target_y": 0.8,
## "fov": 50, "steps": [{"height": 1.6, "radius": 5.0, "count": 8,
## "start_deg": 0}, ...]}, ...] adds views round a point: each step puts
## `count` cameras at that height and distance, evenly round from start_deg
## (0 in front of an item turned by yaw_deg, that is toward its -Z; 90 its
## right, +X), all aimed at the point target_y up. They are named
## NAME-h<height in cm>-a<degrees>.
## "looks": ["paint", "clay"] (default ["paint"]; --looks paint,clay overrides
## it) shoots every view in each look: paint is what the world draws
## (gallery-NAME.png), clay every item in one plain matte grey with no paint,
## dust, glass or decals under a low raking sun (gallery-NAME-clay.png), so
## the form shows. "clay_light": {"elevation_deg": 14, "relative_deg": 70}
## sets that sun for each view: this low, coming from this far round (toward
## the camera's left) from straight behind the camera, so it rakes across
## whatever faces the camera.
## --only PREFIX[,PREFIX...] shoots only the views whose names start so.

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
	var item_nodes: Array[Node3D] = []
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
		item_nodes.append(node)
	var views: Array = (plan.views as Array).duplicate()
	var rings_error := _ring_views(plan.get("rings", []), views)
	if rings_error != "":
		_fail(rings_error)
		return
	var looks: Array = plan.get("looks", ["paint"])
	if args.has("looks"):
		looks = str(args.looks).split(",", false)
	for look: Variant in looks:
		if not str(look) in ["paint", "clay"]:
			_fail("unknown look %s (paint or clay)" % look)
			return
	var only := PackedStringArray()
	if args.has("only"):
		only = str(args.only).split(",", false)
	var camera := Camera3D.new()
	camera.far = 2000.0
	stage.add_child(camera)
	camera.make_current()
	print("KIT_GALLERY renderer=%s method=%s adapter=%s items=%d views=%d looks=%s" % [DisplayServer.get_name(), RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name(), plan.items.size(), views.size(), ",".join(PackedStringArray(looks))])
	var sun := stage.get_node("Sun") as DirectionalLight3D
	var sun_basis := sun.global_transform.basis
	var clay := _clay_material()
	for look: Variant in looks:
		var clay_look := str(look) == "clay"
		_set_look(item_nodes, clay if clay_look else null)
		var light: Dictionary = plan.get("clay_light", {})
		sun.global_transform.basis = sun_basis
		for _i in 8:
			await process_frame
		for view: Variant in views:
			if not view is Dictionary or not view.get("name") is String or not view.get("camera_xyz") is Array or not view.get("target_xyz") is Array:
				_fail("each view needs name, camera_xyz and target_xyz: %s" % [view])
				return
			if not only.is_empty() and not Array(only).any(func(prefix: String) -> bool: return str(view.name).begins_with(prefix)):
				continue
			camera.fov = float(view.get("fov", 60.0))
			camera.global_position = Vector3(view.camera_xyz[0], view.camera_xyz[1], view.camera_xyz[2])
			camera.look_at(Vector3(view.target_xyz[0], view.target_xyz[1], view.target_xyz[2]), Vector3.UP)
			if clay_look:
				sun.global_transform.basis = _raking(camera, float(light.get("elevation_deg", 14.0)), float(light.get("relative_deg", 70.0)))
			for _i in 4:
				await process_frame
				await RenderingServer.frame_post_draw
			var path := "%s/gallery-%s%s.png" % [args.out, view.name, "-clay" if clay_look else ""]
			if root.get_texture().get_image().save_png(path) != OK:
				_fail("could not save " + path)
				return
			print("GALLERY_VIEW %s%s" % [view.name, " clay" if clay_look else ""])
			if view.has("frame_time_frames") and not clay_look:
				await _frame_time(int(view.frame_time_frames), str(view.name))
	quit(0)


## Appends the plan's rings as views ("" or what is wrong with them).
func _ring_views(rings: Variant, views: Array) -> String:
	if not rings is Array:
		return "rings must be a list"
	for ring: Variant in rings:
		if not ring is Dictionary or not ring.get("name") is String or not ring.get("xz") is Array or not ring.get("steps") is Array:
			return "each ring needs name, xz and steps: %s" % [ring]
		var centre := Vector3(float(ring.xz[0]), 0.0, float(ring.xz[1]))
		var yaw := deg_to_rad(float(ring.get("yaw_deg", 0.0)))
		var target := centre + Vector3.UP * float(ring.get("target_y", 0.8))
		for step: Variant in ring.steps:
			if not step is Dictionary or not step.has("height") or not step.has("radius") or not step.has("count"):
				return "each ring step needs height, radius and count: %s" % [step]
			var count := int(step.count)
			for index in count:
				var degrees := float(step.get("start_deg", 0.0)) + 360.0 * float(index) / float(count)
				var turn := deg_to_rad(degrees)
				var offset := Basis(Vector3.UP, yaw) * Vector3(sin(turn), 0.0, -cos(turn)) * float(step.radius)
				var eye := centre + offset + Vector3.UP * float(step.height)
				views.append({
					"name": "%s-h%03d-a%03d" % [ring.name, roundi(float(step.height) * 100.0), posmod(roundi(degrees), 360)],
					"camera_xyz": [eye.x, eye.y, eye.z],
					"target_xyz": [target.x, target.y, target.z],
					"fov": float(ring.get("fov", 50.0)),
				})
	return ""


## A sun basis `elevation_deg` above the horizon whose light comes from
## `relative_deg` round toward the camera's left from straight behind it.
static func _raking(camera: Camera3D, elevation_deg: float, relative_deg: float) -> Basis:
	var look := -camera.global_transform.basis.z
	var flat := Vector3(look.x, 0.0, look.z)
	if flat.length() < 0.05:
		flat = -camera.global_transform.basis.y
		flat.y = 0.0
	flat = flat.normalized().rotated(Vector3.UP, -deg_to_rad(relative_deg))
	var travel := (flat * cos(deg_to_rad(elevation_deg)) + Vector3.DOWN * sin(deg_to_rad(elevation_deg))).normalized()
	return Basis.looking_at(travel, Vector3.UP)


## Every drawn piece of the items in `material` (null: back to their own).
func _set_look(item_nodes: Array[Node3D], material: Material) -> void:
	for node: Node3D in item_nodes:
		for found: Node in node.find_children("*", "GeometryInstance3D", true, false):
			var piece := found as GeometryInstance3D
			if not piece.has_meta("own_material"):
				piece.set_meta("own_material", piece.material_override)
			piece.material_override = material if material != null else piece.get_meta("own_material") as Material


## The clay look: one plain matte grey, nothing else.
func _clay_material() -> StandardMaterial3D:
	var clay := StandardMaterial3D.new()
	clay.resource_name = "kit_gallery_clay"
	clay.albedo_color = Color(0.62, 0.62, 0.62)
	clay.roughness = 0.8
	clay.metallic = 0.0
	clay.metallic_specular = 0.35
	return clay


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
		node.name = state.get_node_name(index)
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
