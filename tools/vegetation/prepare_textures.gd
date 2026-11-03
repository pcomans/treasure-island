extends SceneTree
## Packs the street-vegetation textures (game/resources/textures/world/vegetation/)
## from the untouched generated source images, which stay outside Git with the
## vegetation work notes (the texture README names each one's prompt). Keys the
## flat magenta backgrounds of the leaf and grass images into alpha, removes the
## magenta spill, fills transparent pixels with nearby leaf colour (so mipmaps
## don't halo), grades and packs the atlases whose cells
## game/scripts/world/street_vegetation_kit.gd reads, and resizes the tiled barks.
##
##   tools/godot --headless --path . --script tools/vegetation/prepare_textures.gd -- --source DIR
##   tools/godot --headless --path . --import   # then import the new PNGs

const OUT := "res://game/resources/textures/world/vegetation/"
## The sources this tool reads, by file name in the source folder.
const SOURCES := [
	"palm_fan_leaf.png", "palm_dead_leaf.png", "palm_boot.png",
	"fan_bark_grey.png",
	"canary_frond_a.png", "canary_frond_b.png", "canary_trunk_a.png", "canary_knob.png",
	"cypress_clump.png", "cypress_plate.png", "cypress_bark.png",
	"grass_clump_a.png", "grass_clump_b.png",
]


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 2 or args[0] != "--source" or args[1].begins_with("--"):
		push_error("usage: -- --source DIR (the folder of untouched generated source images)")
		quit(2)
		return
	var source_dir := args[1].trim_suffix("/") + "/"
	var errors: Array[String] = []
	var images := {}
	for name: String in SOURCES:
		images[name] = _load(source_dir + name, errors)
	if not errors.is_empty():
		_finish(errors)
		return

	# Fan palm atlas, 1024 x 1024 (UV rects in street_vegetation_kit.gd):
	#   live fan (0,0)-(512,512)            dead frond A (512,0)-(768,512)
	#   leaf-base boot (0,512)-(512,1024)   dead frond B (768,0)-(1024,512)
	#   old fan (512,512)-(1024,1024)
	var palm := Image.create_empty(1024, 1024, false, Image.FORMAT_RGBA8)
	var fan := _keyed(images["palm_fan_leaf.png"], 512, 512)
	# Greyer, cooler green than the generated leaf: Washingtonia crowns read
	# grey-green in the dated Treasure Island photos.
	_grade(fan, Color(0.93, 0.97, 0.94), 0.45)
	var dead: Image = images["palm_dead_leaf.png"]
	# The dead frond is a 2:3 portrait with the leaf in its middle: keep a
	# centred 1:2 strip so it fills a 256 x 512 cell.
	var strip := dead.get_region(Rect2i(dead.get_width() / 8, 0, dead.get_width() * 3 / 4, dead.get_height()))
	var dead_a := _keyed(strip, 256, 512)
	# Weathered tan-brown rather than a darker fresh-dead orange.
	_grade(dead_a, Color(0.96, 0.9, 0.82), 0.2)
	var dead_b := dead_a.duplicate() as Image
	dead_b.flip_x()
	_grade(dead_b, Color(0.84, 0.8, 0.76), 0.1)
	var old_fan := fan.duplicate() as Image
	old_fan.flip_x()
	# Older, lower fronds: a little more olive, not yellow.
	_grade(old_fan, Color(1.02, 0.95, 0.74), 0.2)
	var boot: Image = images["palm_boot.png"]
	boot.resize(512, 512, Image.INTERPOLATE_LANCZOS)
	_grade(boot, Color(0.9, 0.86, 0.82), 0.25)
	palm.blit_rect(fan, Rect2i(0, 0, 512, 512), Vector2i(0, 0))
	palm.blit_rect(dead_a, Rect2i(0, 0, 256, 512), Vector2i(512, 0))
	palm.blit_rect(dead_b, Rect2i(0, 0, 256, 512), Vector2i(768, 0))
	palm.blit_rect(boot, Rect2i(0, 0, 512, 512), Vector2i(0, 512))
	palm.blit_rect(old_fan, Rect2i(0, 0, 512, 512), Vector2i(512, 512))
	_save(palm, OUT + "fan_palm_foliage_atlas.png", errors)

	# Canary Island date palm fronds, 512 x 2048: two 256 x 2048 cells, each a
	# whole frond stretched to fill its cell, from its bare petiole at the bottom
	# edge to its tip at the top, the rachis on the cell's centre line. The
	# generated fronds are drawn stubby (about 1:3); the kit's ribbons are about
	# 1:5, so the leaflets come out long and swept forward as on the palm.
	var fronds := Image.create_empty(512, 2048, false, Image.FORMAT_RGBA8)
	var frond_names := ["canary_frond_b.png", "canary_frond_a.png"]
	for index in frond_names.size():
		var frond := _keyed_stretch(images[frond_names[index]], 256, 2048)
		fronds.blit_rect(frond, Rect2i(0, 0, 256, 2048), Vector2i(256 * index, 0))
	_save(fronds, OUT + "canary_frond_atlas.png", errors)

	# Cypress atlas, 1024 x 512: side clump (0,0)-(512,512), top plate (512,0)-(1024,512).
	var cypress := Image.create_empty(1024, 512, false, Image.FORMAT_RGBA8)
	cypress.blit_rect(_keyed(images["cypress_clump.png"], 512, 512), Rect2i(0, 0, 512, 512), Vector2i(0, 0))
	cypress.blit_rect(_keyed(images["cypress_plate.png"], 512, 512), Rect2i(0, 0, 512, 512), Vector2i(512, 0))
	_save(cypress, OUT + "cypress_foliage_atlas.png", errors)

	# Clumping grass, 1024 x 512: the green clump fills (0,0)-(512,512); the
	# wider straw clump keeps its 3:2 shape, bottom-aligned in (512,171)-(1024,512).
	var grass := Image.create_empty(1024, 512, false, Image.FORMAT_RGBA8)
	var grass_green := _keyed(images["grass_clump_a.png"], 512, 512)
	var grass_straw := _keyed(images["grass_clump_b.png"], 512, 341)
	_straw(grass_green)
	_straw(grass_straw)
	grass.blit_rect(grass_green, Rect2i(0, 0, 512, 512), Vector2i(0, 0))
	grass.blit_rect(grass_straw, Rect2i(0, 0, 512, 341), Vector2i(512, 171))
	_fill_transparent(grass)
	_save(grass, OUT + "grass_atlas.png", errors)

	# Tiled barks, 512 x 512 opaque: [output, tint, desaturation].
	var barks := {
		"fan_bark_grey.png": ["fan_palm_bark.png", Color(1.0, 1.0, 1.0), 0.0],
		# Greyer than the generated warm brown: the palms' leaf-scar trunks read
		# grey-brown in the dated Building 1 photos.
		"canary_trunk_a.png": ["canary_trunk_bark.png", Color(1.0, 0.98, 0.97), 0.4],
		# The trimmed leaf bases read brown, not orange, in the Building 1 photos.
		"canary_knob.png": ["canary_knob.png", Color(1.0, 0.97, 0.94), 0.3],
		# The generated bark is redder than Monterey cypress's grey-brown.
		"cypress_bark.png": ["cypress_bark.png", Color(0.95, 0.93, 0.92), 0.45],
	}
	for source: String in barks.keys():
		var bark: Image = images[source]
		bark.resize(512, 512, Image.INTERPOLATE_LANCZOS)
		_grade(bark, barks[source][1], barks[source][2])
		bark.convert(Image.FORMAT_RGB8)
		_save(bark, OUT + str(barks[source][0]), errors)
	_finish(errors)


func _load(path: String, errors: Array[String]) -> Image:
	var image := Image.load_from_file(path)
	if image == null or image.is_empty():
		errors.append("could not load " + path)
		return null
	image.convert(Image.FORMAT_RGBA8)
	return image


## Magenta key -> straight alpha, spill removed, transparent pixels refilled.
func _keyed(source: Image, width: int, height: int) -> Image:
	var image := _key(source)
	image.resize(width, height, Image.INTERPOLATE_LANCZOS)
	_fill_transparent(image)
	return image


## Keyed, cropped to the leaf (symmetric about its middle, so its axis stays on
## the cell's centre line) and stretched to fill width x height.
func _keyed_stretch(source: Image, width: int, height: int) -> Image:
	var image := _key(source)
	var used := image.get_used_rect()
	var middle := used.get_center().x
	var half := maxi(middle - used.position.x, used.end.x - middle)
	var crop := Rect2i(middle - half, used.position.y, half * 2, used.size.y).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var leaf := image.get_region(crop)
	# Refill before resizing too, so the stretch blends leaf colour, not key colour, into the edges.
	_fill_transparent(leaf)
	leaf.resize(width, height, Image.INTERPOLATE_LANCZOS)
	_fill_transparent(leaf)
	return leaf


func _key(source: Image) -> Image:
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


## Clears the pink the magenta key leaves in pale blade tips: dry grass is never
## bluer than it is green, nor much redder.
func _straw(image: Image) -> void:
	var data := image.get_data()
	for i in range(0, data.size(), 4):
		if data[i + 3] == 0:
			continue
		var g := data[i + 1]
		data[i + 2] = mini(data[i + 2], int(g * 0.88))
		data[i] = mini(data[i], int(g * 1.18) + 10)
	image.set_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data)


## Multiplies visible colour by tint and pulls it toward grey by desaturate (0..1).
func _grade(image: Image, tint: Color, desaturate: float) -> void:
	image.convert(Image.FORMAT_RGBA8)
	var data := image.get_data()
	for i in range(0, data.size(), 4):
		var r := data[i] / 255.0
		var g := data[i + 1] / 255.0
		var b := data[i + 2] / 255.0
		var grey := r * 0.3 + g * 0.59 + b * 0.11
		data[i] = int(round(clampf(lerpf(r, grey, desaturate) * tint.r, 0.0, 1.0) * 255.0))
		data[i + 1] = int(round(clampf(lerpf(g, grey, desaturate) * tint.g, 0.0, 1.0) * 255.0))
		data[i + 2] = int(round(clampf(lerpf(b, grey, desaturate) * tint.b, 0.0, 1.0) * 255.0))
	image.set_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data)


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
