extends SceneTree
## Packs the street-vegetation textures (game/resources/textures/world/vegetation/)
## from the untouched generated source images, which stay outside Git with the
## vegetation work notes (the texture README names each one's prompt). Keys the
## flat magenta (or, behind pink, lilac and red flowers and red leaves, cyan)
## backgrounds of the leaf and grass images into alpha, removes the key colour's spill, fills transparent
## pixels with nearby leaf colour (so mipmaps don't halo), grades and packs the
## atlases whose cells game/scripts/world/street_vegetation_kit.gd reads, and
## resizes the tiled barks. Writes each PNG's `.import` beside it
## (tools/vegetation/texture_import.gd: lossless, with mipmaps), so a re-pack
## always imports with the mip chain the foliage and bark shaders sample.
##
##   tools/godot --headless --path . --script tools/vegetation/prepare_textures.gd -- --source DIR [--only SET,...]
##   tools/godot --headless --path . --import   # then import the new PNGs
##
## --only packs just the named sets (default: all of them).

const TextureImport := preload("res://tools/vegetation/texture_import.gd")
const OUT := "res://game/resources/textures/world/vegetation/"
## The sets this tool packs and the sources each reads, by file name in the source folder.
const SETS := {
	"palms": ["palm_fan_leaf.png", "palm_dead_leaf.png", "palm_boot.png", "canary_frond_a.png", "canary_frond_b.png"],
	"cypress": ["cypress_clump.png", "cypress_plate.png"],
	"grass": ["grass_clump_a.png", "grass_clump_b.png"],
	"barks": ["fan_bark_grey.png", "canary_trunk_a.png", "canary_knob.png", "cypress_bark.png"],
	"meadow": MEADOW_CELLS,
	"perennial": PERENNIAL_CELLS,
	"marsh": ["marsh_tangle_a.png", "marsh_tangle_b.png", "tall_fringe.png", "marsh_seeded_shrub.png", "marsh_thin_stems.png"],
	"young_planting": ["young_tree_a.png", "young_tree_b.png", "young_shrub.png"],
	"young_trees": ["gum_leaves.png", "oak_leaves.png", "gum_bark.png", "oak_bark.png"],
	"park_ground": ["park_mulch.png", "park_gravel.png"],
	"pine": ["pine_crest.png", "pine_crest_candles.png", "pine_candle_row.png", "pine_bark.png"],
	"broadleaf": ["broadleaf_clump.png", "broadleaf_bronze.png", "christmas_spray.png", "christmas_spray_flowers.png", "broadleaf_bark.png", "christmas_bark.png"],
	"set_pieces": ["eucalyptus_spray.png", "weeping_mass.png", "norfolk_branch_top.png", "norfolk_branch_side.png", "eucalyptus_shred_bark.png"],
	"shrubs": [
		"hawthorn_spray.png", "pittosporum_broad.png", "red_tip_shoots.png", "conical_spray.png",
		"hedge_mat.png", "glossy_mat.png", "hedge_stems_open.png", "phormium_leaf.png",
		"hedge_surface.png", "glossy_hedge_flower_surface.png",
	],
}
## The shrub atlas's 512 x 512 cells, row by row in 2048 x 1024 (SHRUB_CELLS in
## the kit): the Avenue N shrubs' ragged mats, stems and upright flame, the
## hedges' ragged mats and stems, and the flax leaf, each stretched to fill its
## cell; the kit's card sizes set their proportions.
const SHRUB_CELL_SOURCES := [
	"hawthorn_spray.png", "pittosporum_broad.png", "red_tip_shoots.png", "conical_spray.png",
	"hedge_mat.png", "glossy_mat.png", "hedge_stems_open.png", "phormium_leaf.png",
]
## The rollout models' leaf images graded toward the dated Street View crops:
## [tint, desaturation]. Set from the mean colour of their crowns beside the crops':
## every generated leaf came out far more saturated than the crops (0.4-0.7 against
## 0.2-0.45 in HSV), and the spreading broadleaf much darker (value 0.23 against
## 0.33) and yellower, so it is brightened past its source and cooled; the Job Corps
## trees, in the shade of their own big crowns, are measured from frames against the
## whole crown in the owner's photos, not its sunlit part. The bronze
## clump came out orange, the flax wine red rather than near-black maroon, the hedge
## stems pale. The cells with flowers keep more of their colour.
const ROLLOUT_GRADES := {
	"pine_crest.png": [Color(0.9, 0.92, 0.94), 0.36],
	"pine_crest_candles.png": [Color(0.9, 0.92, 0.94), 0.3],
	"pine_candle_row.png": [Color(0.84, 0.78, 0.7), 0.55],
	"broadleaf_clump.png": [Color(1.04, 1.12, 1.06), 0.62],
	"broadleaf_bronze.png": [Color(0.94, 0.84, 0.8), 0.62],
	"christmas_spray.png": [Color(0.82, 0.84, 0.8), 0.38],
	"christmas_spray_flowers.png": [Color(1.0, 0.76, 0.82), 0.3],
	"eucalyptus_spray.png": [Color(0.65, 0.67, 0.69), 0.45],
	"weeping_mass.png": [Color(0.745, 0.74, 0.78), 0.3],
	"norfolk_branch_top.png": [Color(0.98, 0.98, 0.92), 0.42],
	"norfolk_branch_side.png": [Color(0.98, 0.98, 0.92), 0.42],
	"hawthorn_spray.png": [Color(0.81, 0.81, 0.87), 0.36],
	"pittosporum_broad.png": [Color(0.7, 0.67, 0.88), 0.34],
	"hedge_mat.png": [Color(0.74, 0.78, 0.76), 0.42],
	"glossy_mat.png": [Color(0.86, 0.84, 1.0), 0.52],
	"red_tip_shoots.png": [Color(0.92, 0.92, 0.86), 0.15],
	"conical_spray.png": [Color(0.9, 0.95, 0.96), 0.38],
	"hedge_stems_open.png": [Color(0.46, 0.44, 0.42), 0.35],
	"phormium_leaf.png": [Color(0.46, 0.36, 0.4), 0.3],
}
## The meadow atlas's 512 x 512 cells, row by row in 2048 x 2048 (LOW_CELLS in
## the kit): side views drawn on crossed cards, and the litter.
const MEADOW_CELLS := [
	"reedgrass_clump.png", "sedge_tussock.png", "rush_clump.png", "bronze_grass.png",
	"blue_eyed_grass.png", "thrift_stalks.png", "umbel_stalks.png", "buckwheat_side.png",
	"woolly_stalks.png", "monkey_stalks.png", "tansy_stalks.png", "buckwheat_stalks.png",
	"sagebrush_side.png", "sage_side.png", "litter.png", "seeded_stems.png",
]
## The perennial atlas's 512 x 512 cells in 2048 x 1536: face-on foliage
## clusters, the top views the kit lays over clumps as caps, and in the last
## cell, the meadow atlas being full, a seed-laden shrub's side view.
const PERENNIAL_CELLS := [
	"daisy_foliage.png", "thrift_cushion.png", "woolly_foliage.png", "sagebrush_foliage.png",
	"yarrow_foliage.png", "buckwheat_foliage.png", "monkeyflower_foliage.png", "tansy_foliage.png",
	"tussock_top.png", "bronze_top.png", "daisy_flowers.png", "seeded_tufts.png",
]
const MAGENTA := Color(1.0, 0.0, 1.0)
const CYAN := Color(0.0, 1.0, 1.0)
## Sources generated on cyan, so their pink, lilac and blue flowers survive the key.
const ON_CYAN := ["marsh_seeded_shrub.png", "seeded_tufts.png", "blue_eyed_grass.png", "thrift_stalks.png", "daisy_flowers.png", "sage_side.png", "christmas_spray_flowers.png", "hawthorn_spray.png", "red_tip_shoots.png", "phormium_leaf.png"]
## Pixels a low-plant image keeps clear round its atlas cell's edge, so mipmaps
## don't pull a neighbouring cell's leaves into a card's outline.
const CELL_MARGIN := 8
## Top views the kit lays over clumps as caps fade out from their middle, so a
## cap fills a clump's dense core from above without a flat rim of its own.
const CAP_CELLS := ["tussock_top.png", "bronze_top.png"]
## Low-plant images graded toward the dated Cityside photos and November:
## [tint, desaturation] and optionally a power on each channel, which darkens the
## stems of a card and leaves its pale seed heads. The generated sedge, tansy and monkeyflower came out
## lime, the rush yellow-green, the bronze sedge orange rather than copper-tan,
## the sagebrush frosty, the dried flower heads too red; the litter is pulled
## down to dull debris.
const LOW_GRADES := {
	"sedge_tussock.png": [Color(0.72, 0.78, 0.68), 0.5],
	"rush_clump.png": [Color(0.86, 0.92, 0.88), 0.2],
	"bronze_grass.png": [Color(0.82, 0.74, 0.66), 0.6],
	"sagebrush_foliage.png": [Color(0.8, 0.86, 0.78), 0.0],
	"sagebrush_side.png": [Color(0.74, 0.84, 0.72), 0.0],
	"litter.png": [Color(0.64, 0.62, 0.6), 0.55],
	"seeded_stems.png": [Color(1.0, 0.95, 0.9), 0.55, 0.75],
	"seeded_tufts.png": [Color(0.86, 0.84, 0.8), 0.7],
	"marsh_seeded_shrub.png": [Color(0.84, 0.77, 0.7), 0.25],
	"young_tree_a.png": [Color(0.86, 0.86, 0.8), 0.2],
	"young_tree_b.png": [Color(0.9, 0.92, 0.84), 0.2],
	"young_shrub.png": [Color(0.8, 0.82, 0.74), 0.25],
	"marsh_thin_stems.png": [Color(0.92, 0.86, 0.74), 0.3],
	"marsh_tangle_a.png": [Color(0.84, 0.8, 0.74), 0.4],
	"marsh_tangle_b.png": [Color(0.84, 0.8, 0.74), 0.35],
	"tall_fringe.png": [Color(0.86, 0.86, 0.72), 0.25],
	"woolly_stalks.png": [Color(0.78, 0.72, 0.66), 0.55],
	"buckwheat_stalks.png": [Color(0.84, 0.74, 0.64), 0.7],
	"buckwheat_foliage.png": [Color(0.8, 0.76, 0.68), 0.55],
	"buckwheat_side.png": [Color(0.82, 0.84, 0.78), 0.6],
	"monkeyflower_foliage.png": [Color(0.86, 0.9, 0.82), 0.2],
	"tansy_foliage.png": [Color(0.84, 0.88, 0.8), 0.25],
	"daisy_foliage.png": [Color(0.82, 0.86, 0.82), 0.45],
	"woolly_foliage.png": [Color(0.74, 0.8, 0.72), 0.15],
	"tussock_top.png": [Color(0.8, 0.9, 0.78), 0.3],
	"bronze_top.png": [Color(0.9, 0.85, 0.8), 0.3],
	"thrift_cushion.png": [Color(0.84, 0.88, 0.84), 0.3],
}


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var sets: Array = SETS.keys()
	if args.size() == 4 and args[2] == "--only":
		sets = Array(args[3].split(","))
	if not (args.size() == 2 or args.size() == 4) or args[0] != "--source" or args[1].begins_with("--") or sets.any(func(name: Variant) -> bool: return not SETS.has(name)):
		push_error("usage: -- --source DIR [--only SET,...] (DIR: the folder of untouched generated source images; SET: %s)" % ", ".join(PackedStringArray(SETS.keys())))
		quit(2)
		return
	var source_dir := args[1].trim_suffix("/") + "/"
	var errors: Array[String] = []
	var images := {}
	for set_name: String in sets:
		for name: String in SETS[set_name]:
			images[name] = _load(source_dir + name, errors)
	if not errors.is_empty():
		_finish(errors)
		return
	for set_name: String in sets:
		call("_pack_" + set_name, images, errors)
	_finish(errors)


func _pack_palms(images: Dictionary, errors: Array[String]) -> void:
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


func _pack_cypress(images: Dictionary, errors: Array[String]) -> void:
	# Cypress atlas, 1024 x 512: side clump (0,0)-(512,512), top plate (512,0)-(1024,512).
	var cypress := Image.create_empty(1024, 512, false, Image.FORMAT_RGBA8)
	cypress.blit_rect(_keyed(images["cypress_clump.png"], 512, 512), Rect2i(0, 0, 512, 512), Vector2i(0, 0))
	cypress.blit_rect(_keyed(images["cypress_plate.png"], 512, 512), Rect2i(0, 0, 512, 512), Vector2i(512, 0))
	_save(cypress, OUT + "cypress_foliage_atlas.png", errors)


func _pack_grass(images: Dictionary, errors: Array[String]) -> void:
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


func _pack_barks(images: Dictionary, errors: Array[String]) -> void:
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
	_save_barks(images, barks, errors)


## Tiled barks from source: [output, tint, desaturation, and optionally contrast
## about the bark's mid tone, so a furrowed bark keeps its relief at a distance].
func _save_barks(images: Dictionary, barks: Dictionary, errors: Array[String]) -> void:
	for source: String in barks.keys():
		var bark: Image = images[source]
		bark.resize(512, 512, Image.INTERPOLATE_LANCZOS)
		_grade(bark, barks[source][1], barks[source][2])
		bark.convert(Image.FORMAT_RGB8)
		if (barks[source] as Array).size() > 3:
			_contrast(bark, float(barks[source][3]))
		_save(bark, OUT + str(barks[source][0]), errors)


func _contrast(image: Image, amount: float) -> void:
	var data := image.get_data()
	var mid := 0.0
	for value in data:
		mid += value
	mid /= data.size()
	for i in data.size():
		data[i] = clampi(int(round(mid + (data[i] - mid) * amount)), 0, 255)
	image.set_data(image.get_width(), image.get_height(), false, image.get_format(), data)


## Cityside Park's grasses, sedges and rushes, its shrubs seen from the side,
## the flower stalks of its perennials and the litter under its shrubs, 2048 x
## 2048 in 512 x 512 cells (MEADOW_CELLS), each image cropped to its plant and
## stretched to fill its cell inside CELL_MARGIN; the kit's card sizes set the
## plants' proportions.
func _pack_meadow(images: Dictionary, errors: Array[String]) -> void:
	var cells := MEADOW_CELLS
	var atlas := Image.create_empty(2048, 2048, false, Image.FORMAT_RGBA8)
	for index in cells.size():
		var name: String = cells[index]
		var cell := _keyed_fit(images[name], 512 - 2 * CELL_MARGIN, 512 - 2 * CELL_MARGIN, CYAN if name in ON_CYAN else MAGENTA)
		# Clears the pink the magenta key leaves in pale blade tips (not the copper sedge's orange).
		if name in ["reedgrass_clump.png", "sedge_tussock.png", "rush_clump.png", "seeded_stems.png"]:
			_straw(cell)
		if LOW_GRADES.has(name):
			_grade(cell, LOW_GRADES[name][0], LOW_GRADES[name][1], LOW_GRADES[name][2] if LOW_GRADES[name].size() > 2 else 1.0)
		atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(512 * (index % 4) + CELL_MARGIN, 512 * (index / 4) + CELL_MARGIN))
	_fill_transparent(atlas)
	_save(atlas, OUT + "meadow_atlas.png", errors)


## The perennials' and shrubs' face-on foliage clusters and the caps' top views,
## 2048 x 1536 in 512 x 512 cells like the meadow atlas (PERENNIAL_CELLS).
func _pack_perennial(images: Dictionary, errors: Array[String]) -> void:
	var cells := PERENNIAL_CELLS
	var atlas := Image.create_empty(2048, 1536, false, Image.FORMAT_RGBA8)
	for index in cells.size():
		var name: String = cells[index]
		var cell := _keyed_fit(images[name], 512 - 2 * CELL_MARGIN, 512 - 2 * CELL_MARGIN, CYAN if name in ON_CYAN else MAGENTA)
		if LOW_GRADES.has(name):
			_grade(cell, LOW_GRADES[name][0], LOW_GRADES[name][1], LOW_GRADES[name][2] if LOW_GRADES[name].size() > 2 else 1.0)
		if name in CAP_CELLS:
			_radial_fade(cell, 0.14, 0.36)
		atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(512 * (index % 4) + CELL_MARGIN, 512 * (index / 4) + CELL_MARGIN))
	_fill_transparent(atlas)
	_save(atlas, OUT + "perennial_atlas.png", errors)


## The Mersea ditch's plants, 2048 x 1024: two wide tangles of dead grass and twigs along
## the top row, the tall fringe, the seed-laden shrub and the thin stems below. The wide
## cards' ends are frayed so a card never stops in a straight cut; the kit's card sizes
## set the plants' proportions.
func _pack_marsh(images: Dictionary, errors: Array[String]) -> void:
	var atlas := Image.create_empty(2048, 1024, false, Image.FORMAT_RGBA8)
	var cells := {
		"marsh_tangle_a.png": Rect2i(0, 0, 1024, 512), "marsh_tangle_b.png": Rect2i(1024, 0, 1024, 512),
		"tall_fringe.png": Rect2i(0, 512, 1024, 512), "marsh_seeded_shrub.png": Rect2i(1024, 512, 512, 512), "marsh_thin_stems.png": Rect2i(1536, 512, 512, 512),
	}
	for name: String in cells:
		var cell: Rect2i = cells[name]
		var image := _keyed_fit(images[name], cell.size.x - 2 * CELL_MARGIN, cell.size.y - 2 * CELL_MARGIN, CYAN if name in ON_CYAN else MAGENTA)
		if name != "marsh_seeded_shrub.png":
			_straw(image)
		_grade(image, LOW_GRADES[name][0], LOW_GRADES[name][1])
		if cell.size.x == 1024:
			_fray_ends(image, 0.14)
		atlas.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), cell.position + Vector2i(CELL_MARGIN, CELL_MARGIN))
	_fill_transparent(atlas)
	_save(atlas, OUT + "marsh_atlas.png", errors)


## Clears more and more upright slivers toward an image's left and right ends, over
## fraction of its width, by a fixed seed, so a card's ends thin out into stray stalks.
func _fray_ends(image: Image, fraction: float) -> void:
	var w := image.get_width()
	var data := image.get_data()
	var random := RandomNumberGenerator.new()
	random.seed = 4177
	var sliver := 3
	for from_x in range(0, w, sliver):
		var keep := minf(1.0, minf(float(from_x), float(w - 1 - from_x)) / (fraction * w))
		if random.randf() < keep * keep * 1.6:
			continue
		for y in image.get_height():
			for x in range(from_x, mini(w, from_x + sliver)):
				data[(y * w + x) * 4 + 3] = 0
	image.set_data(w, image.get_height(), false, Image.FORMAT_RGBA8, data)


## The Mersea promenade's young planting, 1536 x 1024: two staked saplings and a low
## leafy shrub in tall cells, side views for the kit's crossed cards.
func _pack_young_planting(images: Dictionary, errors: Array[String]) -> void:
	var atlas := Image.create_empty(1536, 1024, false, Image.FORMAT_RGBA8)
	var names := ["young_tree_a.png", "young_tree_b.png", "young_shrub.png"]
	for index in names.size():
		var name: String = names[index]
		var image := _keyed_fit(images[name], 512 - 2 * CELL_MARGIN, 1024 - 2 * CELL_MARGIN, MAGENTA)
		_grade(image, LOW_GRADES[name][0], LOW_GRADES[name][1])
		atlas.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(512 * index + CELL_MARGIN, CELL_MARGIN))
	_fill_transparent(atlas)
	_save(atlas, OUT + "young_planting_atlas.png", errors)


## The young trees: their foliage atlas, 1024 x 512, a hanging spray of gum
## leaves (0,0)-(512,512) and a cluster of oak leaves (512,0)-(1024,512), and
## their tiled barks.
func _pack_young_trees(images: Dictionary, errors: Array[String]) -> void:
	var atlas := Image.create_empty(1024, 512, false, Image.FORMAT_RGBA8)
	for index in 2:
		var name: String = ["gum_leaves.png", "oak_leaves.png"][index]
		# The oak's round cluster is kept clear of the cell's edges, so a card
		# never shows a straight cut through the leaves.
		var inset := CELL_MARGIN + (48 if name == "oak_leaves.png" else 0)
		var cell := _keyed_fit(images[name], 512 - 2 * inset, 512 - 2 * inset, MAGENTA)
		# Sydney blue gum crowns read grey-green (ph10), with few bronze young leaves.
		if name == "gum_leaves.png":
			_grade(cell, Color(0.86, 0.94, 0.95), 0.5)
		atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(512 * index + inset, inset))
	_fill_transparent(atlas)
	_save(atlas, OUT + "young_tree_foliage_atlas.png", errors)
	_save_barks(images, {
		# The gum's pale bark, a little greyer than generated (ph10, cmg14).
		"gum_bark.png": ["gum_bark.png", Color(0.98, 0.98, 0.97), 0.15],
		"oak_bark.png": ["oak_bark.png", Color(1.0, 1.0, 1.0), 0.1],
	}, errors)


## The park beds' ground, 512 x 512 tiles like the street mulch: the grey
## shredded wood mulch and the pea gravel of Cityside Park's beds.
func _pack_park_ground(images: Dictionary, errors: Array[String]) -> void:
	_save_barks(images, {
		# Darker than generated: in the game's sun the generated mulch read pale pink-grey
		# and the gravel near white, against the dark beds of the dated photos.
		"park_mulch.png": ["park_mulch.png", Color(0.72, 0.7, 0.68), 0.2],
		"park_gravel.png": ["park_gravel.png", Color(0.62, 0.62, 0.62), 0.1],
	}, errors)


## The Monterey pine: its foliage atlas, 1024 x 1024, a crest of upright needle
## tufts (0,0)-(1024,448), the same with candles (0,448)-(1024,896) and a row of
## candles alone (0,896)-(1024,1024); and its tiled bark, dark grey-brown (p4)
## rather than the generated red-brown.
func _pack_pine(images: Dictionary, errors: Array[String]) -> void:
	var atlas := Image.create_empty(1024, 1024, false, Image.FORMAT_RGBA8)
	_pack_cell(atlas, images, "pine_crest.png", Rect2i(0, 0, 1024, 448), CELL_MARGIN)
	_pack_cell(atlas, images, "pine_crest_candles.png", Rect2i(0, 448, 1024, 448), CELL_MARGIN)
	_pack_cell(atlas, images, "pine_candle_row.png", Rect2i(0, 896, 1024, 128), CELL_MARGIN)
	_fill_transparent(atlas)
	_save(atlas, OUT + "pine_foliage_atlas.png", errors)
	_save_barks(images, {"pine_bark.png": ["pine_bark.png", Color(0.72, 0.72, 0.74), 0.6, 1.3]}, errors)


## The broadleaf atlas, 1024 x 1024 (BROADLEAF_* and CHRISTMAS_* in the kit):
## the spreading broadleaf's drooping clump and its bronze-tipped clump on top,
## the Christmas tree's drooping sprays, plain and in flower, below, each stretched
## to fill its cell; and the two trees' tiled barks, the broadleaf's a dark
## fissured grey-brown (c2).
func _pack_broadleaf(images: Dictionary, errors: Array[String]) -> void:
	var atlas := Image.create_empty(1024, 1024, false, Image.FORMAT_RGBA8)
	_pack_cell(atlas, images, "broadleaf_clump.png", Rect2i(0, 0, 512, 512), CELL_MARGIN + 24)
	_pack_cell(atlas, images, "broadleaf_bronze.png", Rect2i(512, 0, 512, 512), CELL_MARGIN + 24)
	_pack_cell(atlas, images, "christmas_spray.png", Rect2i(0, 512, 512, 512), CELL_MARGIN)
	_pack_cell(atlas, images, "christmas_spray_flowers.png", Rect2i(512, 512, 512, 512), CELL_MARGIN)
	_fill_transparent(atlas)
	_save(atlas, OUT + "broadleaf_foliage_atlas.png", errors)
	_save_barks(images, {
		"broadleaf_bark.png": ["broadleaf_bark.png", Color(0.72, 0.7, 0.68), 0.55, 1.5],
		"christmas_bark.png": ["christmas_bark.png", Color(1.0, 1.0, 1.0), 0.0],
	}, errors)


## The set pieces' atlas, 1024 x 1024 (EUCALYPTUS_SPRAY, WEEPING_MASS and NORFOLK_*
## in the kit): the eucalyptus's hanging spray over the weeping tree's hanging mass in
## the left column, a Norfolk Island pine branch from above and from the side in the
## right; and the eucalyptus's tiled bark, its ribbons pale enough for the kit's
## vertex colours to warm them low on the trunk.
func _pack_set_pieces(images: Dictionary, errors: Array[String]) -> void:
	var atlas := Image.create_empty(1024, 1024, false, Image.FORMAT_RGBA8)
	_pack_cell(atlas, images, "eucalyptus_spray.png", Rect2i(0, 0, 512, 512), CELL_MARGIN)
	_pack_cell(atlas, images, "weeping_mass.png", Rect2i(0, 512, 512, 512), CELL_MARGIN)
	_pack_cell(atlas, images, "norfolk_branch_top.png", Rect2i(512, 0, 512, 512), CELL_MARGIN)
	_pack_cell(atlas, images, "norfolk_branch_side.png", Rect2i(512, 512, 512, 512), CELL_MARGIN)
	_fill_transparent(atlas)
	_save(atlas, OUT + "set_piece_foliage_atlas.png", errors)
	_save_barks(images, {"eucalyptus_shred_bark.png": ["eucalyptus_bark.png", Color(0.9, 0.88, 0.87), 0.5]}, errors)


## The shrub atlas, 2048 x 1024 (SHRUB_CELL_SOURCES; SHRUB_CELLS in the kit); and
## the hedges' two tiled clipped-leaf cores, the glossy one in flower.
func _pack_shrubs(images: Dictionary, errors: Array[String]) -> void:
	var atlas := Image.create_empty(2048, 1024, false, Image.FORMAT_RGBA8)
	for index in SHRUB_CELL_SOURCES.size():
		_pack_cell(atlas, images, SHRUB_CELL_SOURCES[index], Rect2i(512 * (index % 4), 512 * (index / 4), 512, 512), CELL_MARGIN)
	_fill_transparent(atlas)
	_save(atlas, OUT + "shrub_foliage_atlas.png", errors)
	_save_barks(images, {
		"hedge_surface.png": ["hedge_surface.png", Color(0.8, 0.84, 0.82), 0.42],
		"glossy_hedge_flower_surface.png": ["glossy_hedge_surface.png", Color(0.88, 0.88, 0.98), 0.5, 1.2],
	}, errors)


## Keys a source on its background, crops it to the plant, stretches it to fill
## cell less inset all round, grades it (ROLLOUT_GRADES) and blits it in.
func _pack_cell(atlas: Image, images: Dictionary, name: String, cell: Rect2i, inset: int) -> void:
	var image := _keyed_fit(images[name], cell.size.x - 2 * inset, cell.size.y - 2 * inset, CYAN if name in ON_CYAN else MAGENTA)
	if ROLLOUT_GRADES.has(name):
		_grade(image, ROLLOUT_GRADES[name][0], ROLLOUT_GRADES[name][1])
	atlas.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), cell.position + Vector2i(inset, inset))


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


## Keyed on key, cropped to the plant and stretched to fill width x height.
func _keyed_fit(source: Image, width: int, height: int, key: Color) -> Image:
	var image := _key(source, key)
	var leaf := image.get_region(_solid_rect(image))
	# Refill before resizing too, so the stretch blends leaf colour, not key colour, into the edges.
	_fill_transparent(leaf)
	leaf.resize(width, height, Image.INTERPOLATE_LANCZOS)
	_fill_transparent(leaf)
	return leaf


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


## The bounds of an image's mostly opaque pixels (alpha 128 and up), so a stray
## faint pixel left by the key does not widen a crop.
func _solid_rect(image: Image) -> Rect2i:
	var w := image.get_width()
	var data := image.get_data()
	var low := Vector2i(w, image.get_height())
	var high := Vector2i(-1, -1)
	for i in range(3, data.size(), 4):
		if data[i] >= 128:
			var pixel := (i - 3) / 4
			var x := pixel % w
			var y := pixel / w
			low = Vector2i(mini(low.x, x), mini(low.y, y))
			high = Vector2i(maxi(high.x, x), maxi(high.y, y))
	if high.x < 0:
		return Rect2i(Vector2i.ZERO, image.get_size())
	return Rect2i(low, high - low + Vector2i.ONE)


## Keys the flat background colour (pure magenta or pure cyan) into alpha.
func _key(source: Image, key := MAGENTA) -> Image:
	var image := source.duplicate() as Image
	image.convert(Image.FORMAT_RGBA8)
	var data := image.get_data()
	var cyan := key.is_equal_approx(CYAN)
	for i in range(0, data.size(), 4):
		var r := data[i] / 255.0
		var g := data[i + 1] / 255.0
		var b := data[i + 2] / 255.0
		var distance := sqrt((key.r - r) * (key.r - r) + (key.g - g) * (key.g - g) + (key.b - b) * (key.b - b))
		var alpha := clampf((distance - 0.18) / 0.5, 0.0, 1.0)
		if alpha <= 0.0:
			data[i + 3] = 0
			continue
		# Remove the key's share of an edge blend, then any remaining spill:
		# natural leaf and bark colours never have both key channels above the
		# third (on magenta: red and blue above green; on cyan: green and blue
		# above red, which keeps pink and lilac petals).
		r = clampf((r - (1.0 - alpha) * key.r) / alpha, 0.0, 1.0)
		g = clampf((g - (1.0 - alpha) * key.g) / alpha, 0.0, 1.0)
		b = clampf((b - (1.0 - alpha) * key.b) / alpha, 0.0, 1.0)
		if cyan:
			var spill := minf(g, b) - r
			if spill > 0.0:
				g -= spill
				b -= spill
		else:
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


## Fades alpha out from inner to outer (fractions of the image's width) from its middle.
func _radial_fade(image: Image, inner: float, outer: float) -> void:
	var w := image.get_width()
	var h := image.get_height()
	var data := image.get_data()
	for y in h:
		for x in w:
			var r := Vector2((x + 0.5) / w - 0.5, (y + 0.5) / h - 0.5).length()
			var i := (y * w + x) * 4 + 3
			data[i] = int(round(data[i] * (1.0 - smoothstep(inner, outer, r))))
	image.set_data(w, h, false, Image.FORMAT_RGBA8, data)


## Multiplies visible colour by tint and pulls it toward grey by desaturate (0..1).
func _grade(image: Image, tint: Color, desaturate: float, power := 1.0) -> void:
	image.convert(Image.FORMAT_RGBA8)
	var data := image.get_data()
	for i in range(0, data.size(), 4):
		var r := data[i] / 255.0
		var g := data[i + 1] / 255.0
		var b := data[i + 2] / 255.0
		var grey := r * 0.3 + g * 0.59 + b * 0.11
		data[i] = int(round(clampf(pow(lerpf(r, grey, desaturate), power) * tint.r, 0.0, 1.0) * 255.0))
		data[i + 1] = int(round(clampf(pow(lerpf(g, grey, desaturate), power) * tint.g, 0.0, 1.0) * 255.0))
		data[i + 2] = int(round(clampf(pow(lerpf(b, grey, desaturate), power) * tint.b, 0.0, 1.0) * 255.0))
	image.set_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data)


func _save(image: Image, path: String, errors: Array[String]) -> void:
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		errors.append("could not save %s (error %d)" % [path, error])
		return
	error = TextureImport.write(path)
	if error != OK:
		errors.append("could not write %s.import (error %d)" % [path, error])
		return
	print("WROTE %s %dx%d" % [path, image.get_width(), image.get_height()])


func _finish(errors: Array[String]) -> void:
	for message in errors:
		push_error(message)
	quit(0 if errors.is_empty() else 1)
