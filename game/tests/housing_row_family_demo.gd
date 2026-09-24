extends SceneTree
## Bounded structural visual study. No real-site identity or physics acceptance.
const FAMILY = preload("res://game/scripts/world/facades/housing_row_family.gd")
const SHORT = preload("res://game/resources/housing_family/short_row.tres")
const LONG = preload("res://game/resources/housing_family/long_row.tres")
var failures: Array[String] = []
var cameras: Array[Camera3D] = []
var houses: Array[Node3D] = []

func check(ok: bool, message: String) -> void:
	if not ok: failures.append(message)

func _initialize() -> void:
	call_deferred("run")

func meshes(node: Node) -> Array[Node]:
	return node.find_children("*", "MeshInstance3D", true, false)

func run() -> void:
	var family := FAMILY.new()
	var short := family.instantiate(SHORT)
	var long := family.instantiate(LONG)
	var default_copy := family.instantiate(SHORT)
	check(short != null and long != null, "Valid configurations must instantiate")
	if short == null or long == null:
		quit(1)
		return
	for pair in [[short, SHORT], [long, LONG]]:
		var house: Node3D = pair[0]
		var cfg: Resource = pair[1]
		check(house.scale == Vector3.ONE, "Row must not stretch modules")
		check(house.get_meta("row_length") == cfg.bay_count * FAMILY.BAY_WIDTH, "Length must follow bay count")
		check(house.get_node("RightCap").position.x == cfg.bay_count * FAMILY.BAY_WIDTH, "Terminal cap must close row")
		for i in cfg.bay_count:
			var bay := house.get_node("Bay_%02d" % i) as Node3D
			check(bay.scale == Vector3.ONE, "Bay dimensions changed")
			check(bay.position.x == i * FAMILY.BAY_WIDTH, "Disconnected or overlapping bay seams")
			var span: Vector2 = bay.get_meta("module_span")
			check(span == Vector2(0, FAMILY.BAY_WIDTH), "Repeat span changed")
			check(bay.get_meta("opening_dimensions") == Vector4(1.78, 1.30, 0.92, 2.13), "Opening proportion changed")
			if i > 0:
				var previous := house.get_node("Bay_%02d" % (i - 1)) as Node3D
				check(previous.position.x + span.y == bay.position.x, "Bay join has gap or overlap")
		for i in cfg.canopy_bays:
			var segment := house.get_node("Canopy_%02d" % i) as Node3D
			check(segment.position.x == (cfg.canopy_start + i) * FAMILY.BAY_WIDTH, "Canopy segment gap/overlap")
		check(house.get_node("CanopyEnd").position.x == (cfg.canopy_start + cfg.canopy_bays) * FAMILY.BAY_WIDTH, "Final canopy support detached")
		check(not house.has_meta("source_keys") and not house.has_meta("derived_object_key"), "Study must not claim site identity")
		check(house.find_children("*", "CollisionObject3D", true, false).is_empty(), "Study must not imply site collision")
	# Inspect generated surface normals, not just declared seam metadata.
	for node: MeshInstance3D in meshes(short):
		var surface := str(node.get_meta("module_surface", ""))
		if surface.is_empty(): continue
		var arrays: Array = node.mesh.surface_get_arrays(0)
		for normal: Vector3 in arrays[Mesh.ARRAY_NORMAL]:
			check(normal.y > 0.9 if surface == "roof_slope" else normal.x < -0.9, "Roof/gable outward normal reversed")
	var a := meshes(short.get_node("Bay_00"))
	var b := meshes(long.get_node("Bay_00"))
	var repeated := meshes(long.get_node("Bay_01"))
	for i in a.size():
		check(a[i].mesh == b[i].mesh and b[i].mesh == repeated[i].mesh, "Geometry must be genuinely shared")
		check(a[i].transform == b[i].transform, "Module proportions changed between variants")
		check(a[i].material_override != b[i].material_override, "Finish leaked across instances")
		var slot := str(a[i].get_meta("appearance_slot", ""))
		if slot == "walls":
			check(a[i].material_override.get_shader_parameter("wall_color") == SHORT.walls, "Default walls changed")
			check(b[i].material_override.get_shader_parameter("wall_color") == LONG.walls, "Variant walls missing")
		elif slot == "doors":
			check(a[i].material_override.albedo_color == SHORT.doors and b[i].material_override.albedo_color == LONG.doors, "Door palette failed")
		else:
			if a[i].material_override is StandardMaterial3D:
				check(a[i].material_override.albedo_color == b[i].material_override.albedo_color, "Unrelated detail recolored")
			else: check(a[i].material_override.shader.code == b[i].material_override.shader.code, "Roof finish changed")
	# Placement is independent of shape and finish; neither mutates family resources.
	short.position = Vector3(-20, 0, 8)
	short.rotation.y = 0.2
	check(long.position == Vector3.ZERO and long.rotation == Vector3.ZERO, "Root placement leaked")
	for mesh: MeshInstance3D in meshes(short):
		if mesh.get_meta("appearance_slot", "") == "doors": mesh.material_override.albedo_color = Color.GREEN
	for mesh: MeshInstance3D in meshes(default_copy):
		if mesh.get_meta("appearance_slot", "") == "doors": check(mesh.material_override.albedo_color == SHORT.doors, "Default instance mutated")
	var fresh := family.instantiate(SHORT)
	for mesh: MeshInstance3D in meshes(fresh):
		if mesh.get_meta("appearance_slot", "") == "doors": check(mesh.material_override.albedo_color == SHORT.doors, "Family template mutated")
	fresh.free()
	short.free()
	default_copy.free()
	short = family.instantiate(SHORT)
	if not failures.is_empty():
		for message in failures: push_error(message)
		short.free()
		long.free()
		quit(1)
		return
	print("PASS: structural variants, fixed shared modules, contiguous assembly, independent palette/placement, preserved defaults; visual study only.")
	var output := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	if output.is_empty():
		short.free()
		long.free()
		quit(0)
		return
	root.size = Vector2i(1600, 900)
	await process_frame
	var applied := Vector2i(root.get_visible_rect().size)
	var width := applied.x / 2
	for i in 2:
		var viewport := SubViewport.new()
		viewport.size = Vector2i(width, applied.y - 55)
		viewport.own_world_3d = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		var container := SubViewportContainer.new()
		container.position = Vector2(i * width, 55)
		root.add_child(container)
		container.add_child(viewport)
		var house: Node3D = short if i == 0 else long
		house.position = Vector3(12, 0, -8)
		viewport.add_child(house)
		houses.append(house)
		var length: float = house.get_meta("row_length")
		var camera := Camera3D.new()
		viewport.add_child(camera)
		camera.position = house.position + Vector3(-20 + length / 2, 17, 28)
		camera.look_at(house.position + Vector3(length / 2, 2, -0.5))
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 42
		cameras.append(camera)
		var light := DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-48, -30, 0)
		light.light_energy = 1.3
		light.shadow_enabled = true
		viewport.add_child(light)
		var env := WorldEnvironment.new()
		env.environment = Environment.new()
		env.environment.background_mode = Environment.BG_COLOR
		env.environment.background_color = Color("ccd8df")
		env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.environment.ambient_light_color = Color.WHITE
		env.environment.ambient_light_energy = 0.55
		viewport.add_child(env)
		var label := Label.new()
		label.text = "Study A · 3 bays / 2 canopy spans" if i == 0 else "Study B · 5 bays / 4 canopy spans"
		label.position = Vector2(i * width + 20, 13)
		label.add_theme_font_size_override("font_size", 22)
		root.add_child(label)
	if not await capture(output.path_join("whole.png")):
		quit(1)
		return
	for i in 2:
		cameras[i].position = houses[i].position + Vector3(-7, 5.6, 10)
		cameras[i].look_at(houses[i].position + Vector3(3, 2.5, 0))
		cameras[i].size = 11
	if not await capture(output.path_join("detail.png")):
		quit(1)
		return
	quit(0)

func capture(path: String) -> bool:
	for frame in 8: await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(path)
	if error != OK:
		push_error("Capture failed: " + path)
		return false
	print("Capture saved: ", path)
	return true
