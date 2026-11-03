extends SceneTree
## Tree shootout (variant A): turns the raw generated textures in
## game/resources/vegetation_shootout/source/ into the atlases the tree builder
## uses. Keys the flat magenta backgrounds into alpha, removes magenta spill,
## fills transparent pixels with nearby leaf colour (so mipmaps don't halo) and
## packs the atlas layout that shootout_tree_builder.gd expects.
##
##   tools/godot --headless --path . --script tools/tree_shootout/prepare_textures.gd

const SRC := "res://game/resources/vegetation_shootout/source/"
const OUT := "res://game/resources/vegetation_shootout/"
const KEY := Color(1.0, 0.0, 1.0)


func _initialize() -> void:
	var errors: Array[String] = []
	# Palm atlas, 2048 x 2048 (UV rects in shootout_tree_builder.gd):
	#   fan leaf (0,0)-(1024,1024)   dead leaf A (1024,0)-(1536,1024)
	#   boot     (0,1024)-(1024,2048) dead leaf B (1536,0)-(2048,1024)
	#   old fan  (1024,1024)-(2048,2048)
	var palm := Image.create_empty(2048, 2048, false, Image.FORMAT_RGBA8)
	var fan := _keyed(_load(SRC + "palm_fan_leaf.png", errors), 1024, 1024)
	var dead := _load(SRC + "palm_dead_leaf.png", errors)
	var boot := _load(SRC + "palm_boot.png", errors)
	if not errors.is_empty():
		_finish(errors)
		return
	# The dead leaf is a 2:3 portrait with the leaf in its middle third: keep a
	# centred 1:2 strip so it fills a 512 x 1024 cell.
	var strip := dead.get_region(Rect2i(dead.get_width() / 8, 0, dead.get_width() * 3 / 4, dead.get_height()))
	var dead_a := _keyed(strip, 512, 1024)
	var dead_b := dead_a.duplicate() as Image
	dead_b.flip_x()
	_grade(dead_b, Color(0.86, 0.84, 0.82), 0.0)
	var old_fan := fan.duplicate() as Image
	old_fan.flip_x()
	# Older, lower fronds: a little more olive and less saturated.
	_grade(old_fan, Color(1.05, 0.88, 0.5), 0.45)
	boot.resize(1024, 1024, Image.INTERPOLATE_LANCZOS)
	boot.convert(Image.FORMAT_RGBA8)
	palm.blit_rect(fan, Rect2i(0, 0, 1024, 1024), Vector2i(0, 0))
	palm.blit_rect(dead_a, Rect2i(0, 0, 512, 1024), Vector2i(1024, 0))
	palm.blit_rect(dead_b, Rect2i(0, 0, 512, 1024), Vector2i(1536, 0))
	palm.blit_rect(boot, Rect2i(0, 0, 1024, 1024), Vector2i(0, 1024))
	palm.blit_rect(old_fan, Rect2i(0, 0, 1024, 1024), Vector2i(1024, 1024))
	_save(palm, OUT + "palm_foliage_atlas.png", errors)

	# Cypress atlas, 2048 x 1024: side clump (0,0)-(1024,1024), top plate (1024,0)-(2048,1024).
	var cypress := Image.create_empty(2048, 1024, false, Image.FORMAT_RGBA8)
	var clump := _load(SRC + "cypress_clump.png", errors)
	var plate := _load(SRC + "cypress_plate.png", errors)
	if not errors.is_empty():
		_finish(errors)
		return
	cypress.blit_rect(_keyed(clump, 1024, 1024), Rect2i(0, 0, 1024, 1024), Vector2i(0, 0))
	cypress.blit_rect(_keyed(plate, 1024, 1024), Rect2i(0, 0, 1024, 1024), Vector2i(1024, 0))
	_save(cypress, OUT + "cypress_foliage_atlas.png", errors)

	for name: String in ["palm_bark", "cypress_bark"]:
		var bark := _load(SRC + name + ".png", errors)
		if bark == null:
			continue
		bark.resize(1024, 1024, Image.INTERPOLATE_LANCZOS)
		if name == "cypress_bark":
			# The generated bark is redder than Monterey cypress's grey-brown.
			_grade(bark, Color(0.95, 0.93, 0.92), 0.45)
		bark.convert(Image.FORMAT_RGB8)
		_save(bark, OUT + name + ".png", errors)
	_finish(errors)


func _load(path: String, errors: Array[String]) -> Image:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		errors.append("could not load " + path)
		return null
	image.convert(Image.FORMAT_RGBA8)
	return image


## Magenta key -> straight alpha, spill removed, transparent pixels refilled.
func _keyed(source: Image, width: int, height: int) -> Image:
	var image := source.duplicate() as Image
	image.convert(Image.FORMAT_RGBA8)
	var data := image.get_data()
	for i in range(0, data.size(), 4):
		var r := data[i] / 255.0
		var g := data[i + 1] / 255.0
		var b := data[i + 2] / 255.0
		var distance := sqrt((1.0 - r) * (1.0 - r) + g * g + (1.0 - b) * (1.0 - b))
		var alpha := clampf((distance - 0.18) / 0.5, 0.0, 1.0)
		if alpha <= 0.0:
			data[i + 3] = 0
			continue
		# Remove the magenta share of an edge blend, then any remaining spill:
		# natural leaf and bark colours never have both red and blue above green.
		r = clampf((r - (1.0 - alpha)) / alpha, 0.0, 1.0)
		g = clampf(g / alpha, 0.0, 1.0)
		b = clampf((b - (1.0 - alpha)) / alpha, 0.0, 1.0)
		var spill := minf(r, b) - g
		if spill > 0.0:
			r -= spill
			b -= spill
		data[i] = int(round(r * 255.0))
		data[i + 1] = int(round(g * 255.0))
		data[i + 2] = int(round(b * 255.0))
		data[i + 3] = int(round(alpha * 255.0))
	image.set_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data)
	image.resize(width, height, Image.INTERPOLATE_LANCZOS)
	_fill_transparent(image)
	return image


## Gives fully and mostly transparent pixels the average colour of the nearby
## leaf (from progressively coarser premultiplied copies), so mipmaps and
## bilinear filtering blend toward foliage colour instead of magenta or black.
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
	var mean := _mean_colour(image)
	var data := image.get_data()
	for i in range(0, data.size(), 4):
		if data[i + 3] >= 200:
			continue
		var fill := mean
		for level in levels:
			var a := level[i + 3]
			if a >= 6:
				fill = Color(level[i] / float(a), level[i + 1] / float(a), level[i + 2] / float(a))
				break
		var keep := data[i + 3] / 200.0
		data[i] = int(round(lerpf(fill.r * 255.0, data[i], keep)))
		data[i + 1] = int(round(lerpf(fill.g * 255.0, data[i + 1], keep)))
		data[i + 2] = int(round(lerpf(fill.b * 255.0, data[i + 2], keep)))
	image.set_data(w, h, false, Image.FORMAT_RGBA8, data)


func _mean_colour(image: Image) -> Color:
	var data := image.get_data()
	var sum := Vector3.ZERO
	var count := 0
	for i in range(0, data.size(), 4):
		if data[i + 3] >= 200:
			sum += Vector3(data[i], data[i + 1], data[i + 2])
			count += 1
	if count == 0:
		return Color(0.2, 0.3, 0.15)
	sum /= 255.0 * count
	return Color(sum.x, sum.y, sum.z)


## Multiplies visible colour by tint and pulls it toward grey by desaturate (0..1).
func _grade(image: Image, tint: Color, desaturate: float) -> void:
	var data := image.get_data()
	for i in range(0, data.size(), 4):
		var r := data[i] / 255.0
		var g := data[i + 1] / 255.0
		var b := data[i + 2] / 255.0
		var grey := r * 0.3 + g * 0.59 + b * 0.11
		data[i] = int(round(clampf(lerpf(r, grey, desaturate) * tint.r, 0.0, 1.0) * 255.0))
		data[i + 1] = int(round(clampf(lerpf(g, grey, desaturate) * tint.g, 0.0, 1.0) * 255.0))
		data[i + 2] = int(round(clampf(lerpf(b, grey, desaturate) * tint.b, 0.0, 1.0) * 255.0))
	image.set_data(image.get_width(), image.get_height(), false, image.get_format(), data)


func _save(image: Image, path: String, errors: Array[String]) -> void:
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		errors.append("could not save %s (error %d)" % [path, error])
	else:
		print("WROTE %s %dx%d" % [path, image.get_width(), image.get_height()])


func _finish(errors: Array[String]) -> void:
	for message in errors:
		push_error(message)
	quit(0 if errors.is_empty() else 1)
