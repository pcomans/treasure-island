extends SceneTree
## Run with --headless for the contract, or -- --capture=/absolute/file.png for pixels.
const ASSET = preload("res://game/scripts/world/facades/northpoint_1232_asset.gd")
const SUPPORT = preload("res://game/scripts/world/facades/housing_quality_support.gd")
const FACTORY = preload("res://game/scripts/world/facades/northpoint_1232_live_factory.gd")
var failures: Array[String] = []

func check(condition: bool, message: String) -> void:
	if not condition: failures.append(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var cfg := FACTORY._json(FACTORY.CONFIG_PATH)
	var land := SUPPORT.land_triangles(cfg.ground_chunks)
	if not land.get("ok", false):
		push_error("Frozen ground unavailable")
		quit(1)
		return
	var record := FACTORY._record(FACTORY._json(FACTORY.CHUNK_PATH).records, FACTORY.WALL_KEY)
	var before := record.duplicate(true)
	var ground := func(p: Vector2) -> float: return SUPPORT.height_at(p, land.triangles)
	var source: Node3D = ASSET.MODEL.build(record, ground)
	var asset := ASSET.new()
	if asset.prepare(record, ground) != OK:
		push_error("Asset semantic binding failed")
		source.free()
		quit(1)
		return
	var original := asset.instantiate()
	var variant := asset.instantiate({"walls": Color("3979b5"), "doors": Color("ba3028")})
	var slots := {"walls": 0, "doors": 0}
	check(record == before, "Source record mutated")
	check(original.get_child_count() == source.get_child_count(), "Construction changed")
	for i in original.get_child_count():
		var a := original.get_child(i) as MeshInstance3D
		var b := variant.get_child(i) as MeshInstance3D
		var s := source.get_child(i) as MeshInstance3D
		check(a.mesh == b.mesh, "Instances must share geometry")
		check(a.material_override != b.material_override, "Material leaked between instances")
		check(a.mesh.get_faces() == s.mesh.get_faces(), "Source geometry changed")
		check((a.position + asset.origin).is_equal_approx(s.position) and a.basis.is_equal_approx(s.basis), "Source transform changed")
		for key: StringName in s.get_meta_list():
			check(a.get_meta(key) == s.get_meta(key), "Construction metadata changed")
		var slot := str(a.get_meta("appearance_slot", ""))
		if slots.has(slot): slots[slot] += 1
		if a.material_override is StandardMaterial3D:
			check(a.material_override.albedo_color == s.material_override.albedo_color and a.material_override.roughness == s.material_override.roughness, "Default finish changed")
			check(b.material_override.roughness == a.material_override.roughness, "Variant roughness changed")
			if slot == "doors": check(b.material_override.albedo_color == Color("ba3028"), "Door override missing")
			else: check(b.material_override.albedo_color == a.material_override.albedo_color, "Unrelated detail recolored")
		else:
			check(a.material_override.shader.code == s.material_override.shader.code, "Default shader changed")
			if slot == "walls":
				check(b.material_override.get_shader_parameter("wall_color") == Color("3979b5"), "Wall override missing")
			else: check(b.material_override.shader.code == a.material_override.shader.code, "Unrelated shader changed")
	check(slots.walls > 0 and slots.doors > 0, "Missing semantic slots")
	# Mutating the variant after instantiation must leave the default and template alone.
	for node: MeshInstance3D in variant.get_children():
		if node.get_meta("appearance_slot", "") == "doors": node.material_override.albedo_color = Color.GREEN
	var later := asset.instantiate()
	for i in later.get_child_count():
		var a := original.get_child(i) as MeshInstance3D
		var b := later.get_child(i) as MeshInstance3D
		if a.material_override is StandardMaterial3D: check(a.material_override.albedo_color == b.material_override.albedo_color, "Template polluted")
	later.free()
	variant.free()
	variant = asset.instantiate({"walls": Color("3979b5"), "doors": Color("ba3028")})
	source.free()
	if not failures.is_empty():
		for failure in failures: push_error(failure)
		original.free()
		variant.free()
		quit(1)
		return
	print("PASS: shared geometry, unchanged default/details/metadata, semantic palette, isolated materials and template; visual-only instances carry no target source identity.")
	var capture := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="): capture = arg.trim_prefix("--capture=")
	if capture.is_empty():
		original.free()
		variant.free()
		quit(0)
		return
	root.size = Vector2i(1600, 900)
	# Window managers may clamp the requested size; lay out the applied viewport.
	await process_frame
	var applied_size := Vector2i(root.get_visible_rect().size)
	var column_width := applied_size.x / 2
	for i in 2:
		var viewport := SubViewport.new()
		viewport.size = Vector2i(column_width, applied_size.y - 50)
		viewport.own_world_3d = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		var container := SubViewportContainer.new()
		container.position = Vector2(i * column_width, 50)
		root.add_child(container)
		container.add_child(viewport)
		var house: Node3D = original if i == 0 else variant
		viewport.add_child(house)
		# Real root placement, independent of the source world coordinates.
		house.position = Vector3(12, 0, -8)
		var camera := Camera3D.new()
		viewport.add_child(camera)
		camera.position = house.position + Vector3(-34, 22, -33)
		camera.look_at(house.position + Vector3(0, 4, 0))
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 56
		var light := DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-48, -40, 0)
		light.light_energy = 1.6
		viewport.add_child(light)
		var env := WorldEnvironment.new()
		env.environment = Environment.new()
		env.environment.background_mode = Environment.BG_COLOR
		env.environment.background_color = Color("cbd9e1")
		env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.environment.ambient_light_color = Color.WHITE
		env.environment.ambient_light_energy = 0.55
		viewport.add_child(env)
		var label := Label.new()
		label.text = "Original 1232 asset" if i == 0 else "Same asset · blue walls / red doors"
		label.position = Vector2(i * column_width + 30, 10)
		label.add_theme_font_size_override("font_size", 26)
		root.add_child(label)
	for i in 8: await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png(capture)
	print("Demo capture: ", capture, " result=", result)
	quit(0 if result == OK else 1)
