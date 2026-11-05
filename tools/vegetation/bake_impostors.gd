extends SceneTree
## Bakes the far-impostor image of every tree, shrub and flax variant of the
## street-vegetation kit (game/scripts/world/street_vegetation_kit.gd) from its
## LOD0, framed as the kit frames it (a palm's crown alone, any other whole
## plant), and writes them to game/resources/textures/world/vegetation/impostors/.
## A prop with an impostor grid gets one view per grid cell, turned evenly round
## it. The bake runs with the breeze off and, older props, flat white ambient
## light, so the image holds the leaves' colour; the game lights the impostor at
## runtime. The rollout's models (the kit's impostor_frame says which) add a light
## straight down, so their images hold the crown's own shade from any side, then
## are brightened or darkened until they meet their near level under the game's
## own sun and sky (main.tscn), with a ramp of gain down the image that meets the
## near level's upper and lower halves. A BAKE_CHECK line reports how the impostor
## and the near level compare from four sides and with the instance turned so the
## camera falls halfway between two views, at the hand-over distance (LOD1, what the
## impostor replaces) and at 30 m (LOD0): tone overall, side by side and by half (the
## gain evens out the overall tone, so a fault shows in the others), top height,
## width and covered pixels; and the near level's mean leaf colour from the sun side
## beside the mean of its dated crop (FOLIAGE_CROPS).
##
##   tools/godot --path . --script tools/vegetation/bake_impostors.gd [-- --only PROP[:VARIANT],...]
##   tools/godot --headless --path . --import   # then import the new PNGs
##
## --only bakes just those props (every variant) or prop variants, so the
## images of trees that did not change are left as they are.

const Kit := preload("res://game/scripts/world/street_vegetation_kit.gd")
const TextureImport := preload("res://tools/vegetation/texture_import.gd")
## Longest side of the saved image of one view; the bake renders at twice this and halves it.
const PIXELS := {
	"mexican_fan_palm": 256, "canary_date_palm": 256, "monterey_cypress": 512, "sydney_blue_gum_young": 256, "island_oak_young": 256,
	"monterey_pine": 256, "spreading_broadleaf": 256, "nz_christmas_tree": 192, "eucalyptus_mature": 256, "weeping_broadleaf": 256, "norfolk_island_pine": 128,
	"indian_hawthorn": 96, "pittosporum_tobira": 96, "red_tip_shrub": 64, "conical_shrub": 128, "nz_flax": 64,
}
## The bake's light: ambient, and a light straight down that shades a crown from
## the top from every side alike, its undersides and hollows well darker than its
## top. The two add up to about white on a top leaf.
const BAKE_AMBIENT := 0.45
const BAKE_TOP_LIGHT := 0.6
## The eye height of the tone and height check, and the side of its square frames.
const EYE_M := 2.2
const CHECK_PIXELS := 256
## Mean sRGB of leaves in the dated crops, kept with the vegetation work notes
## outside Git (p5, c2 and c4, b5, the owner's Job Corps photos, n1, s1, s2, s3); they vary with the light of the
## day, and a crop shows the lit part of a plant where the check takes all of it,
## darker by about 1.3 in sRGB, so read a gap as a direction, not a number to hit.
const FOLIAGE_CROPS := {
	"monterey_pine": [88, 97, 71], "spreading_broadleaf": [79, 84, 63], "nz_christmas_tree": [68, 70, 58], "norfolk_island_pine": [121, 120, 78],
	"eucalyptus_mature": [95, 97, 83], "weeping_broadleaf": [82, 83, 68],
	"indian_hawthorn": [116, 117, 59], "pittosporum_tobira": [110, 111, 61], "conical_shrub": [99, 104, 68],
}
## How far the ramp of gain may go at either end of a plant.
const RAMP_LIMITS := Vector2(0.6, 1.6)
## Each 8-bit sRGB value in linear light.
var _LINEAR := PackedFloat32Array()

var _errors: Array[String] = []
var _lighting := {}


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
	_lighting = _main_lighting()
	for value in 256:
		_LINEAR.append(Color(value / 255.0, 0.0, 0.0).srgb_to_linear().r)
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


## The game's Sun and WorldEnvironment properties, read from main.tscn without instancing it.
func _main_lighting() -> Dictionary:
	var state := (load("res://game/scenes/main.tscn") as PackedScene).get_state()
	var found := {}
	for node in state.get_node_count():
		var node_name := str(state.get_node_name(node))
		if node_name == "Sun" or node_name == "WorldEnvironment":
			var properties := {}
			for index in state.get_node_property_count(node):
				properties[str(state.get_node_property_name(node, index))] = state.get_node_property_value(node, index)
			found[node_name] = properties
	return found


func _bake(kit: Kit, prop: String, variant: int) -> void:
	var frame := kit.impostor_frame(prop, variant)
	var size: Vector2 = frame.size
	var grid: Vector2i = frame.grid
	var longest: int = PIXELS[prop]
	var pixels := Vector2i(longest, longest)
	if size.x > size.y:
		pixels.y = maxi(32, int(round(longest * size.y / size.x)))
	else:
		pixels.x = maxi(32, int(round(longest * size.x / size.y)))
	var atlas := Image.create_empty(pixels.x * grid.x, pixels.y * grid.y, false, Image.FORMAT_RGBA8)
	var viewport := _bake_viewport(frame, pixels * 2, bool(frame.match_tone))
	var camera: Camera3D = viewport.get_meta("camera")
	var center: Vector3 = frame.center
	var distance := maxf(size.x, size.y) * 0.5 + 6.0
	for view in grid.x * grid.y:
		var turn := TAU * view / (grid.x * grid.y)
		camera.look_at_from_position(center + Vector3(sin(turn), 0.0, cos(turn)) * distance, center, Vector3.UP)
		for _i in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		var image := viewport.get_texture().get_image()
		if image == null or image.is_empty():
			_errors.append("no image rendered for %s %d" % [prop, variant])
			viewport.queue_free()
			return
		image.convert(Image.FORMAT_RGBA8)
		# Halve with premultiplied alpha so edges don't darken.
		image.premultiply_alpha()
		image.resize(pixels.x, pixels.y, Image.INTERPOLATE_BILINEAR)
		_unpremultiply(image)
		atlas.blit_rect(image, Rect2i(Vector2i.ZERO, pixels), Vector2i((view % grid.x) * pixels.x, (view / grid.x) * pixels.y))
	viewport.queue_free()
	# Refill the colour of transparent pixels so mipmaps don't halo.
	_fill_transparent(atlas)
	if bool(frame.match_tone):
		atlas = await _match_tone(kit, prop, variant, atlas)
	var path := Kit.impostor_texture_path(prop, variant)
	var error := atlas.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		_errors.append("could not save %s (error %d)" % [path, error])
		return
	error = TextureImport.write(path)
	if error != OK:
		_errors.append("could not write %s.import (error %d)" % [path, error])
		return
	print("BAKED %s %dx%d views=%d frame centre=%s size=%s" % [path, atlas.get_width(), atlas.get_height(), grid.x * grid.y, frame.center, size])


## A transparent viewport of the frame's mesh (a palm's crown surface alone), its
## camera as meta: lit flat, or shaded from above for an image that holds the crown's own shade.
func _bake_viewport(frame: Dictionary, pixels: Vector2i, shaded: bool) -> SubViewport:
	var size: Vector2 = frame.size
	var viewport := SubViewport.new()
	viewport.size = pixels
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_DISABLED
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_CLEAR_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color.WHITE
	environment.ambient_light_energy = BAKE_AMBIENT if shaded else 1.0
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	viewport.add_child(world_environment)
	var reach := maxf(size.x, size.y) * 0.5 + 6.0
	if shaded:
		var light := DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
		light.light_energy = BAKE_TOP_LIGHT
		light.shadow_enabled = true
		light.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		light.directional_shadow_max_distance = reach * 2.5
		viewport.add_child(light)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_HEIGHT
	camera.size = size.y
	camera.near = 0.5
	camera.far = reach * 2.5
	viewport.add_child(camera)
	camera.current = true
	var tree: Dictionary = frame.tree
	var mesh: ArrayMesh = tree.lod0
	var crown := int(tree.crown_surface)
	if crown >= 0:
		var alone := ArrayMesh.new()
		alone.add_surface_from_arrays(mesh.surface_get_primitive_type(crown), mesh.surface_get_arrays(crown))
		alone.surface_set_material(0, mesh.surface_get_material(crown))
		mesh = alone
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	viewport.add_child(instance)
	viewport.set_meta("camera", camera)
	return viewport


## The image brightened or darkened (per colour channel, in linear light) until
## the impostor's mean colour under the game's light meets its near level's at the
## hand-over distance, seen from four sides, then ramped down its height to meet
## the near level's upper and lower halves; prints the BAKE_CHECK comparison.
func _match_tone(kit: Kit, prop: String, variant: int, atlas: Image) -> Image:
	var tree := kit.build(prop, variant)
	var mipped := atlas.duplicate() as Image
	mipped.generate_mipmaps()
	var far_mesh := kit.impostor_mesh(prop, variant, ImageTexture.create_from_image(mipped))
	if far_mesh == null:
		return atlas
	var hand_over := float((Kit.PROPS[prop].ranges as Array)[1])
	var box: AABB = (tree.lod0 as ArrayMesh).get_aabb()
	var extent := maxf(box.size.y, maxf(box.size.x, box.size.z))
	var scene := _lit_scene(tree, far_mesh)
	var grid: Vector2i = kit.impostor_frame(prop, variant).grid
	var views := grid.x * grid.y
	var material: ShaderMaterial = far_mesh.surface_get_material(far_mesh.get_surface_count() - 1)
	var gain := Vector3.ONE
	var start := Vector3.ZERO
	var stats := {}
	for attempt in 3:
		material.set_shader_parameter("tint", Color(gain.x, gain.y, gain.z).linear_to_srgb())
		stats = await _compare(scene, "lod1", hand_over, box, extent, views)
		var near: Vector3 = stats.near_mean
		var far: Vector3 = stats.far_mean
		if attempt == 0:
			start = far / near
		gain *= Vector3(near.x / maxf(far.x, 0.0001), near.y / maxf(far.y, 0.0001), near.z / maxf(far.z, 0.0001))
		gain = gain.clamp(Vector3.ONE * 0.04, Vector3.ONE * 2.5)
	# The gain is settled; measure the halves with it, and bake both into the image.
	material.set_shader_parameter("tint", Color(gain.x, gain.y, gain.z).linear_to_srgb())
	stats = await _compare(scene, "lod1", hand_over, box, extent, views)
	var ramp := Vector2(clampf(1.0 / (1.0 + float(stats.upper_gap)), RAMP_LIMITS.x, RAMP_LIMITS.y), clampf(1.0 / (1.0 + float(stats.lower_gap)), RAMP_LIMITS.x, RAMP_LIMITS.y))
	var graded := _graded(atlas, gain, ramp, grid.y)
	mipped = graded.duplicate() as Image
	mipped.generate_mipmaps()
	material.set_shader_parameter("albedo_texture", ImageTexture.create_from_image(mipped))
	material.set_shader_parameter("tint", Color.WHITE)
	stats = await _compare(scene, "lod1", hand_over, box, extent, views)
	var close: Dictionary = await _compare(scene, "lod0", 30.0, box, extent, views)
	(scene.viewport as SubViewport).queue_free()
	var leaf: Vector3 = close.leaf
	var crop: Array = FOLIAGE_CROPS.get(prop, [])
	print("BAKE_CHECK %s %d gain=%s ramp=%s tone_before=%+.0f%% | at %dm vs LOD1: %s | at 30m vs LOD0: %s | leaf rgb %d,%d,%d crop %s" % [prop, variant, gain, ramp, (_luma(start) - 1.0) * 100.0, int(hand_over), _report(stats), _report(close),
		roundi(leaf.x), roundi(leaf.y), roundi(leaf.z), ",".join(PackedStringArray(crop.map(func(value: int) -> String: return str(value)))) if not crop.is_empty() else "none"])
	return graded


## How far the impostor is from the near level in stats, each as a share of the near level's.
func _report(stats: Dictionary) -> String:
	var near: Vector3 = stats.near_mean
	var far: Vector3 = stats.far_mean
	return "tone %+.0f%% (sides %s, turned %s, upper %+.0f%%, lower %+.0f%%) top %+.1f%% width %+.1f%% cover %+.0f%%" % [(_luma(far) / maxf(_luma(near), 0.0001) - 1.0) * 100.0, stats.sides, stats.turned, stats.upper_gap * 100.0, stats.lower_gap * 100.0, stats.top_gap * 100.0, stats.width_gap * 100.0, stats.cover_gap * 100.0]


static func _luma(color: Vector3) -> float:
	return 0.2126 * color.x + 0.7152 * color.y + 0.0722 * color.z


## The variant's levels, one at a time, under the game's light in a transparent viewport.
func _lit_scene(tree: Dictionary, far_mesh: Mesh) -> Dictionary:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(CHECK_PIXELS, CHECK_PIXELS)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_DISABLED
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var environment: Environment = ((_lighting.WorldEnvironment as Dictionary).environment as Environment).duplicate()
	environment.background_mode = Environment.BG_CLEAR_COLOR
	environment.fog_enabled = false
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	viewport.add_child(world_environment)
	var sun := DirectionalLight3D.new()
	var sun_properties: Dictionary = _lighting.Sun
	for key: String in sun_properties:
		sun.set(key, sun_properties[key])
	sun.directional_shadow_max_distance = 260.0
	viewport.add_child(sun)
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.current = true
	var meshes := {}
	for key: String in ["lod0", "lod1"]:
		var instance := MeshInstance3D.new()
		instance.mesh = tree[key]
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if tree.has("shadow") else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		viewport.add_child(instance)
		meshes[key] = instance
	var far := MeshInstance3D.new()
	far.mesh = far_mesh
	far.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	viewport.add_child(far)
	meshes["far"] = far
	var turning: Array[MeshInstance3D] = [meshes.lod0, meshes.lod1, far]
	if tree.has("shadow"):
		var shadow := MeshInstance3D.new()
		shadow.mesh = tree.shadow
		shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		viewport.add_child(shadow)
		turning.append(shadow)
	return {"viewport": viewport, "camera": camera, "meshes": meshes, "turning": turning}


## The near level against the impostor from four sides at distance, at eye height:
## their mean linear colours, how much lower, narrower and thinner the impostor is,
## and the near level's mean leaf colour from the sun side (the first side, about
## 15 degrees off the sun's bearing); then their tone with the plant turned so
## the camera falls halfway between two of its views (of views), as an instance can.
func _compare(scene: Dictionary, near_key: String, distance: float, box: AABB, extent: float, views: int) -> Dictionary:
	var camera: Camera3D = scene.camera
	# A frame with room for the plant's near side at that distance; only the zoom changes, not the perspective.
	camera.fov = rad_to_deg(2.0 * atan(extent * 0.5 / maxf(distance - extent * 0.5, 1.0) * 1.1))
	var near_sum := Vector3.ZERO
	var far_sum := Vector3.ZERO
	var top_gap := 0.0
	var width_gap := 0.0
	var cover_gap := 0.0
	var sides := PackedStringArray()
	var halves := [Vector2.ZERO, Vector2.ZERO]
	var leaf := Vector3.ZERO
	var aim := box.get_center()
	for side in 4:
		var turn := TAU * (float(side) + 0.15) / 4.0
		camera.look_at_from_position(aim + Vector3(sin(turn) * distance, EYE_M - aim.y, cos(turn) * distance), aim, Vector3.UP)
		var near := await _frame(scene, near_key)
		var far := await _frame(scene, "far")
		near_sum += near.mean
		far_sum += far.mean
		sides.append("%+.0f" % ((_luma(far.mean) / maxf(_luma(near.mean), 0.0001) - 1.0) * 100.0))
		halves[0] += Vector2(far.upper, near.upper)
		halves[1] += Vector2(far.lower, near.lower)
		if side == 0:
			leaf = near.leaf
		var tall := maxf(float(near.bottom - near.top), 1.0)
		top_gap += float(near.top - far.top) / tall
		width_gap += float((far.right - far.left) - (near.right - near.left)) / maxf(float(near.right - near.left), 1.0)
		cover_gap += float(far.count) / maxf(float(near.count), 1.0) - 1.0
	var turning: Array[MeshInstance3D] = scene.turning
	var yaw := PI / float(views)
	for instance in turning:
		instance.rotation.y = yaw
	var turned_aim := aim.rotated(Vector3.UP, yaw)
	camera.look_at_from_position(turned_aim + Vector3(0.0, EYE_M - aim.y, distance), turned_aim, Vector3.UP)
	var near_turned := await _frame(scene, near_key)
	var far_turned := await _frame(scene, "far")
	for instance in turning:
		instance.rotation.y = 0.0
	return {"near_mean": near_sum, "far_mean": far_sum, "sides": "/".join(sides), "upper_gap": halves[0].x / maxf(halves[0].y, 0.0001) - 1.0, "lower_gap": halves[1].x / maxf(halves[1].y, 0.0001) - 1.0,
		"turned": "%+.0f" % ((_luma(far_turned.mean) / maxf(_luma(near_turned.mean), 0.0001) - 1.0) * 100.0), "leaf": leaf, "top_gap": top_gap / 4.0, "width_gap": width_gap / 4.0, "cover_gap": cover_gap / 4.0}


## One level alone in the frame: {mean linear colour, its luma in the upper and lower halves of its height, mean sRGB of its leaves (not bark), count, top, bottom, left, right} of its covered pixels.
func _frame(scene: Dictionary, key: String) -> Dictionary:
	var meshes: Dictionary = scene.meshes
	for name: String in meshes:
		(meshes[name] as MeshInstance3D).visible = name == key
	for _i in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := (scene.viewport as SubViewport).get_texture().get_image()
	image.convert(Image.FORMAT_RGBA8)
	var data := image.get_data()
	var sum := Vector3.ZERO
	var leaf := Vector3.ZERO
	var leaves := 0
	var count := 0
	var top := image.get_height()
	var bottom := 0
	var left := image.get_width()
	var right := 0
	var row_luma := PackedFloat32Array()
	var row_count := PackedInt32Array()
	row_luma.resize(image.get_height())
	row_count.resize(image.get_height())
	for y in image.get_height():
		for x in image.get_width():
			var i := (y * image.get_width() + x) * 4
			if data[i + 3] < 128:
				continue
			var pixel := Vector3(_LINEAR[data[i]], _LINEAR[data[i + 1]], _LINEAR[data[i + 2]])
			sum += pixel
			row_luma[y] += _luma(pixel)
			row_count[y] += 1
			count += 1
			if data[i + 1] >= data[i + 2] + 6 and data[i + 1] >= data[i] - 14:
				leaf += Vector3(data[i], data[i + 1], data[i + 2])
				leaves += 1
			top = mini(top, y)
			bottom = maxi(bottom, y)
			left = mini(left, x)
			right = maxi(right, x)
	var middle := (top + bottom) / 2
	var upper := Vector2.ZERO
	var lower := Vector2.ZERO
	for y in image.get_height():
		if y <= middle:
			upper += Vector2(row_luma[y], row_count[y])
		else:
			lower += Vector2(row_luma[y], row_count[y])
	return {"mean": sum / maxf(float(count), 1.0), "upper": upper.x / maxf(upper.y, 1.0), "lower": lower.x / maxf(lower.y, 1.0), "leaf": leaf / maxf(float(leaves), 1.0), "count": count, "top": top, "bottom": bottom, "left": left, "right": right}


## atlas with each channel scaled by gain in linear light, and by a ramp from ramp.x
## at the top of each of its rows of views to ramp.y at the bottom, through a table
## per channel and step of the ramp.
func _graded(atlas: Image, gain: Vector3, ramp: Vector2, view_rows: int) -> Image:
	var data := atlas.get_data()
	var width := atlas.get_width()
	var view_height := atlas.get_height() / view_rows
	var tables := {}
	for y in atlas.get_height():
		var v := float(y % view_height) / float(view_height)
		var scale := snappedf(lerpf(ramp.x, ramp.y, smoothstep(0.2, 0.8, v)), 0.01)
		if not tables.has(scale):
			var steps: Array[PackedByteArray] = []
			for channel in 3:
				var table := PackedByteArray()
				table.resize(256)
				for value in 256:
					var linear: float = _LINEAR[value] * gain[channel] * scale
					table[value] = clampi(roundi(Color(linear, linear, linear).linear_to_srgb().r * 255.0), 0, 255)
				steps.append(table)
			tables[scale] = steps
		var row: Array[PackedByteArray] = tables[scale]
		for x in width:
			var i := (y * width + x) * 4
			for channel in 3:
				data[i + channel] = row[channel][data[i + channel]]
	return Image.create_from_data(width, atlas.get_height(), false, Image.FORMAT_RGBA8, data)


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
