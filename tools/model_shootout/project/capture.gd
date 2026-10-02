extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.size() != 2 and args.size() != 3:
		push_error("Expected absolute model.gd, output directory and optional study")
		quit(2)
		return
	var study: String = args[2] if args.size() == 3 else "housing"
	if study != "housing" and study != "mersea":
		push_error("Unknown study: " + study)
		quit(2)
		return
	var script := GDScript.new()
	script.source_code = FileAccess.get_file_as_string(args[0])
	if script.reload() != OK:
		push_error("MODEL_PARSE_FAILED")
		quit(3)
		return
	var model: Variant = script.call("build")
	if not model is Node3D:
		push_error("MODEL_INTERFACE_FAILED")
		quit(4)
		return
	var scene := Node3D.new()
	root.add_child(scene)
	scene.add_child(model)
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(200,200)
	ground.mesh = plane
	ground.position.y = -0.025
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.35,0.37,0.34)
	mat.roughness = 0.9
	ground.material_override = mat
	scene.add_child(ground)
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.30,0.49,0.68)
	sky_mat.sky_horizon_color = Color(0.72,0.79,0.82)
	sky_mat.ground_bottom_color = Color(0.25,0.28,0.25)
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.75,0.82,0.91)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env_node.environment = env
	scene.add_child(env_node)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42,-32,0)
	sun.light_energy = 1.4
	sun.shadow_enabled = true
	scene.add_child(sun)
	var camera := Camera3D.new()
	camera.fov = 60.0
	camera.near = 0.1
	camera.far = 250.0
	scene.add_child(camera)
	camera.make_current()
	DirAccess.make_dir_recursive_absolute(args[1])
	var poses: Array = [
		["01-frontal",Vector3(0,1.7,30),Vector3(0,3,0)],
		["02-three-quarter",Vector3(23,1.7,27),Vector3(0,3,0)],
		["03-near",Vector3(0,1.7,11),Vector3(0,3,0)]
	]
	if study == "mersea":
		poses = [
			["01-frontal",Vector3(0,10,62),Vector3(0,1,0)],
			["02-three-quarter",Vector3(46,36,50),Vector3(0,0,0)],
			["03-near",Vector3(7,1.7,12),Vector3(-4,1.8,-8)]
		]
	for pose: Array in poses:
		camera.position = pose[1]
		camera.look_at(pose[2],Vector3.UP)
		for frame in 16:
			await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		var path: String = args[1].path_join(str(pose[0])+".png")
		if image.is_empty() or image.get_width()!=1440 or image.get_height()!=900 or image.save_png(path)!=OK:
			push_error("CAPTURE_FAILED "+path)
			quit(5)
			return
		print("TASTE_CAPTURE "+path)
	print("TASTE_CAPTURE_COMPLETE")
	quit(0)
