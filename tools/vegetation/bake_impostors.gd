extends SceneTree
## Bakes the far-impostor image of every tree variant of the street-vegetation
## kit (game/scripts/world/street_vegetation_kit.gd) from its LOD0, framed as
## the kit frames it (a palm's crown, a whole cypress, gum or oak), and writes
## them to game/resources/textures/world/vegetation/impostors/. The bake is lit
## by flat white ambient light only, with the breeze off, so the image holds
## the leaves' colour and shading; the game lights the impostor at runtime.
##
##   tools/godot --path . --script tools/vegetation/bake_impostors.gd [-- --only PROP[:VARIANT],...]
##   tools/godot --headless --path . --import   # then import the new PNGs
##
## --only bakes just those props (every variant) or prop variants, so the
## images of trees that did not change are left as they are.

const Kit := preload("res://game/scripts/world/street_vegetation_kit.gd")
const TextureImport := preload("res://tools/vegetation/texture_import.gd")
## Longest side of the saved image per prop; the bake renders at twice this and halves it.
const PIXELS := {"mexican_fan_palm": 256, "canary_date_palm": 256, "monterey_cypress": 512, "sydney_blue_gum_young": 256, "island_oak_young": 256}

var _errors: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("baking needs a renderer; omit --headless")
		quit(1)
		return
	var only := {}
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		if args.size() != 2 or args[0] != "--only":
			push_error("usage: [-- --only PROP[:VARIANT],...]")
			quit(2)
			return
		for entry: String in args[1].split(","):
			var parts := entry.split(":")
			if not PIXELS.has(parts[0]) or parts.size() > 2 or (parts.size() == 2 and (not parts[1].is_valid_int() or int(parts[1]) < 0 or int(parts[1]) >= Kit.variant_count(parts[0]))):
				push_error("--only: no tree variant %s" % entry)
				quit(2)
				return
			only[entry] = true
	print("BAKE_RENDERER %s / %s / %s" % [RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name(), DisplayServer.get_name()])
	var kit := Kit.new()
	kit.wind_strength = 0.0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(Kit.TEXTURES + "impostors"))
	for prop: String in PIXELS.keys():
		for variant in Kit.variant_count(prop):
			if only.is_empty() or only.has(prop) or only.has("%s:%d" % [prop, variant]):
				await _bake(kit, prop, variant)
	for message in _errors:
		push_error(message)
	quit(0 if _errors.is_empty() else 1)


func _bake(kit: Kit, prop: String, variant: int) -> void:
	var frame := kit.impostor_frame(prop, variant)
	var size: Vector2 = frame.size
	var longest: int = PIXELS[prop]
	var pixels := Vector2i(longest, longest)
	if size.x > size.y:
		pixels.y = maxi(64, int(round(longest * size.y / size.x)))
	else:
		pixels.x = maxi(64, int(round(longest * size.x / size.y)))
	var viewport := SubViewport.new()
	viewport.size = pixels * 2
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_DISABLED
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_CLEAR_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color.WHITE
	environment.ambient_light_energy = 1.0
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	viewport.add_child(world_environment)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.size = size.y
	camera.near = 0.5
	camera.far = 200.0
	camera.position = (frame.center as Vector3) + Vector3(0.0, 0.0, 80.0)
	viewport.add_child(camera)
	camera.current = true
	var instance := MeshInstance3D.new()
	instance.mesh = (frame.tree as Dictionary).lod0
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	viewport.add_child(instance)
	for _i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
	viewport.queue_free()
	if image == null or image.is_empty():
		_errors.append("no image rendered for %s %d" % [prop, variant])
		return
	image.convert(Image.FORMAT_RGBA8)
	# Halve with premultiplied alpha so edges don't darken, then refill the
	# colour of transparent pixels so mipmaps don't halo.
	image.premultiply_alpha()
	image.resize(pixels.x, pixels.y, Image.INTERPOLATE_BILINEAR)
	_unpremultiply(image)
	_fill_transparent(image)
	var path := Kit.impostor_texture_path(prop, variant)
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_errors.append("could not save %s (error %d)" % [path, error])
		return
	error = TextureImport.write(path)
	if error != OK:
		_errors.append("could not write %s.import (error %d)" % [path, error])
		return
	print("BAKED %s %dx%d frame centre=%s size=%s" % [path, pixels.x, pixels.y, frame.center, size])


func _unpremultiply(image: Image) -> void:
	var data := image.get_data()
	for i in range(0, data.size(), 4):
		var a := data[i + 3]
		if a > 0 and a < 255:
			for c in 3:
				data[i + c] = mini(255, int(round(data[i + c] * 255.0 / a)))
	image.set_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data)


## Transparent pixels take the average colour of the nearby foliage.
func _fill_transparent(image: Image) -> void:
	var w := image.get_width()
	var h := image.get_height()
	var levels: Array[PackedByteArray] = []
	for divisor in [8, 32, 128]:
		var small := image.duplicate() as Image
		small.premultiply_alpha()
		small.resize(maxi(1, w / divisor), maxi(1, h / divisor), Image.INTERPOLATE_TRILINEAR)
		small.resize(w, h, Image.INTERPOLATE_BILINEAR)
		levels.append(small.get_data())
	var data := image.get_data()
	for i in range(0, data.size(), 4):
		if data[i + 3] >= 200:
			continue
		for level in levels:
			var a := level[i + 3]
			if a >= 6:
				var keep := data[i + 3] / 200.0
				for c in 3:
					data[i + c] = int(round(lerpf(level[i + c] * 255.0 / a, data[i + c], keep)))
				break
	image.set_data(w, h, false, Image.FORMAT_RGBA8, data)
