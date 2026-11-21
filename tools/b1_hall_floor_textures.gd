extends SceneTree
## Building 1's hall floor textures (game/resources/textures/world/b1_hall/floor_*.png),
## drawn here in code from the hall's own plan, not from any photograph:
##   tools/godot --headless --path . --script tools/b1_hall_floor_textures.gd
## It builds the hall as the world does (building_1_hero_model.gd) and reads the
## terrazzo's polar frame and the walls, door and bays in it from the hall's root
## ("floor_layout", building_1_interior.gd floor_layout): regenerate whenever the plan
## moves those. Fixed seeds: the same plan gives the same pictures.
## - floor_layout.png (LAYOUT_SIZE, sRGB): the terrazzo's colour over its frame (u along
##   the angles, v out along the radius, as the floor's UVs): warm tan panels on a polar
##   grid of thin dark divider strips (PANEL_M), every second panel a shade darker
##   (ALTERNATE) and each a little uneven, two wide grey-brown bands along the crescent
##   with dark edge strips (BAND_OFFSETS_M, BAND_M), broad soft patches, and dust along
##   the foot of the walls;
## - floor_wear.png (WEAR_SIZE, linear): its roughness over the same frame, which the
##   material's roughness scales (1 the dullest): lanes of traffic down the middle of the
##   hall and in from the door duller, the floor near the walls and under the balcony more
##   polished, each panel's polish a little its own, the strips and the dust along the
##   walls dull, and fine scuffs;
## - floor_terrazzo.png (TILE_SIZE, sRGB): the aggregate, a seamless tile the floor
##   multiplies in every TILE_M metres on the ground plane: chips of cream, tan, grey,
##   brown, rust, white and dark grey stone in a warm pale matrix.
## A texture it cannot save is an error, and the run then exits 1.
## The panel size, bands, lanes and colours are production inference from the 2023
## interior photographs (their pattern and tone, never their pixels): see
## game/resources/textures/world/b1_hall/PROVENANCE.md.

const HERO := preload("res://game/scripts/world/facades/building_1_hero_model.gd")
const OUT := "res://game/resources/textures/world/b1_hall/"
const LAYOUT_SIZE := Vector2i(4096, 2048)
const WEAR_SIZE := Vector2i(2048, 1024)
const TILE_SIZE := 1024
## The aggregate tile's span on the floor (m): the palette's detail_tile_m.
const TILE_M := 1.5
## The divider strips' grid: concentric every PANEL_M out from the hall's front wall, and
## radial every PANEL_M of arc at the hall's middle radius; a strip STRIP_M wide.
const PANEL_M := 1.5
const STRIP_M := 0.012
## The two curved bands: their middles this far either side of the hall's middle radius
## (between the colonnade and the east wall), BAND_M wide, with dark edge strips.
const BAND_OFFSETS_M := [-3.75, 3.75]
const BAND_M := 0.45
## Colours (sRGB): the warm tan field, the bands and the strips; and two multipliers of
## the colour under them: the alternate panels' darker shade and the dust's.
const FIELD := Color(0.86, 0.76, 0.62)
const ALTERNATE := Color(0.95, 0.95, 0.94)
const BAND := Color(0.66, 0.58, 0.49)
const STRIP := Color(0.42, 0.37, 0.32)
const DUST := Color(0.8, 0.78, 0.74)
## Dust along the foot of the walls (m): full within DUST_M, gone by DUST_FADE_M.
const DUST_M := 0.1
const DUST_FADE_M := 0.45

var _layout: Dictionary
## Whether a texture could not be saved.
var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var result: Dictionary = HERO.build_record(HERO._record_from_chunk(HERO.MAIN_CHUNK_PATH, HERO.BUILDING_WALL_KEY))
	var extras: Array = result.get("extra_nodes", [])
	if not bool(result.get("ok", false)) or extras.is_empty():
		push_error("The hero wall record does not build its hall: %s" % result.get("message", ""))
		quit(1)
		return
	var hall := (extras[0] as Dictionary).result.node as Node3D
	_layout = hall.get_meta("floor_layout", {})
	if _layout.is_empty():
		push_error("The hall's root carries no floor_layout.")
		quit(1)
		return
	print("FLOOR frame: theta %s rad, radius %s m; front_in %.3f, column %.3f, east %.3f m" % [_layout.theta, _layout.radius, _layout.front_in, _layout.column, _layout.east])
	var started := Time.get_ticks_msec()
	_save(_paint_layout(), "floor_layout.png")
	_save(_paint_wear(), "floor_wear.png")
	_save(_paint_terrazzo(), "floor_terrazzo.png")
	print("FLOOR textures drawn in %.1f s" % ((Time.get_ticks_msec() - started) / 1000.0))
	for extra: Dictionary in extras:
		(extra.result.node as Node).free()
	if result.get("node") is Node:
		(result.node as Node).free()
	quit(1 if _failed else 0)


func _save(image: Image, name: String) -> void:
	var error := image.save_png(ProjectSettings.globalize_path(OUT + name))
	print("FLOOR %s: %d x %d, error %d" % [name, image.get_width(), image.get_height(), error])
	if error != OK:
		push_error("Could not save " + name)
		_failed = true


## The frame's angle and radius at a pixel's centre.
func _theta(x: int, width: int) -> float:
	var theta := _layout.theta as Vector2
	return theta.x + (float(x) + 0.5) / float(width) * (theta.y - theta.x)


func _radius(y: int, height: int) -> float:
	var radius := _layout.radius as Vector2
	return radius.x + (float(y) + 0.5) / float(height) * (radius.y - radius.x)


## The panel grid: the angle step (radial strips) and the concentric strips' origin.
func _theta_step() -> float:
	return PANEL_M / ((float(_layout.column) + float(_layout.east)) * 0.5)


## How much of a pixel (its size along the distance, m) a strip of width w covers,
## centred d metres away: the box filter's overlap, so a strip thinner than a pixel
## draws as a fainter line.
static func _cover(d: float, w: float, pixel: float) -> float:
	var a := absf(d)
	return maxf(0.0, minf(a + w * 0.5, pixel * 0.5) - maxf(a - w * 0.5, -pixel * 0.5)) / pixel


## A repeatable hash of two integers and a seed, 0 to 1.
static func _hash(a: int, b: int, seed: int) -> float:
	var h := (a * 374761393 + b * 668265263 + seed * 982451653) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	h = h ^ (h >> 16)
	return float(h & 0xffff) / 65535.0


## Smooth value noise, 0 to 1, with a feature size of `cell` in the same units as x, y.
static func _noise(x: float, y: float, cell: float, seed: int) -> float:
	var fx := x / cell
	var fy := y / cell
	var ix := floori(fx)
	var iy := floori(fy)
	var tx := fx - float(ix)
	var ty := fy - float(iy)
	tx = tx * tx * (3.0 - 2.0 * tx)
	ty = ty * ty * (3.0 - 2.0 * ty)
	var a := lerpf(_hash(ix, iy, seed), _hash(ix + 1, iy, seed), tx)
	var b := lerpf(_hash(ix, iy + 1, seed), _hash(ix + 1, iy + 1, seed), tx)
	return lerpf(a, b, ty)


## The same noise repeating every `period` cells, for a tile that must not seam.
static func _noise_periodic(x: float, y: float, cell: float, period: int, seed: int) -> float:
	var fx := x / cell
	var fy := y / cell
	var ix := floori(fx)
	var iy := floori(fy)
	var tx := fx - float(ix)
	var ty := fy - float(iy)
	tx = tx * tx * (3.0 - 2.0 * tx)
	ty = ty * ty * (3.0 - 2.0 * ty)
	var x0 := posmod(ix, period)
	var x1 := posmod(ix + 1, period)
	var y0 := posmod(iy, period)
	var y1 := posmod(iy + 1, period)
	var a := lerpf(_hash(x0, y0, seed), _hash(x1, y0, seed), tx)
	var b := lerpf(_hash(x0, y1, seed), _hash(x1, y1, seed), tx)
	return lerpf(a, b, ty)


## Each column's angle and what of the walls stands across it: [theta, in the
## vestibule's opening, the bay's back radius (0 if no bay), the angle to the bay's
## nearer side, the angle to the nearer end of the hall].
func _columns(width: int) -> Array:
	var vestibule := _layout.vestibule as Vector2
	var columns: Array = []
	for x in width:
		var theta := _theta(x, width)
		var back := 0.0
		var side := INF
		for bay: Array in _layout.bays:
			if theta > float(bay[0]) and theta < float(bay[1]):
				back = float(_layout.east) + float(bay[2])
				side = minf(theta - float(bay[0]), float(bay[1]) - theta)
		columns.append([theta, theta > vestibule.x and theta < vestibule.y, back, side, minf(theta - float(_layout.annex_north), float(_layout.south) - theta)])
	return columns


## Metres from a point (its column's data, its radius) to the nearest foot of a wall on
## the floor: the front wall (but in the vestibule's opening), the east wall (but in its
## bays), each bay's back and sides, and the north and south ends.
func _to_wall(column: Array, r: float) -> float:
	var front_in := float(_layout.front_in)
	var east := float(_layout.east)
	var nearest := float(column[4]) * r
	if r >= front_in - 0.05 and not column[1]:
		nearest = minf(nearest, absf(r - front_in))
	var back: float = column[2]
	if back > 0.0:
		nearest = minf(nearest, absf(back - r))
		if r > east:
			nearest = minf(nearest, float(column[3]) * r)
	else:
		nearest = minf(nearest, absf(east - r))
	return nearest


func _paint_layout() -> Image:
	var w := LAYOUT_SIZE.x
	var h := LAYOUT_SIZE.y
	var data := PackedByteArray()
	data.resize(w * h * 3)
	var front_in := float(_layout.front_in)
	var mid := (float(_layout.column) + float(_layout.east)) * 0.5
	var step := _theta_step()
	var theta0 := (_layout.theta as Vector2).x
	var dr := ((_layout.radius as Vector2).y - (_layout.radius as Vector2).x) / float(h)
	var dt := ((_layout.theta as Vector2).y - theta0) / float(w)
	var columns := _columns(w)
	for y in h:
		var r := _radius(y, h)
		# Concentric strips every PANEL_M out from the front wall's foot.
		var ring := floori((r - front_in) / PANEL_M)
		var ring_d := (r - front_in) - (float(ring) + 0.5) * PANEL_M
		var ring_edge := PANEL_M * 0.5 - absf(ring_d)
		var band := 0.0
		var band_edge := 0.0
		for offset: float in BAND_OFFSETS_M:
			var d := r - (mid + offset)
			band = maxf(band, _cover(d, BAND_M, dr))
			band_edge = maxf(band_edge, maxf(_cover(d - BAND_M * 0.5, STRIP_M, dr), _cover(d + BAND_M * 0.5, STRIP_M, dr)))
		var ring_strip := _cover(ring_edge, STRIP_M, dr)
		var px := dt * r
		for x in w:
			var column: Array = columns[x]
			var theta: float = column[0]
			var spoke := floori((theta - theta0) / step)
			var spoke_edge := (step * 0.5 - absf((theta - theta0) - (float(spoke) + 0.5) * step)) * r
			var strip := maxf(ring_strip, maxf(_cover(spoke_edge, STRIP_M, px), band_edge))
			# The panel's own shade: every second one darker, each a little uneven.
			var colour := FIELD
			if (ring + spoke) % 2 != 0:
				colour = Color(colour.r * ALTERNATE.r, colour.g * ALTERNATE.g, colour.b * ALTERNATE.b)
			var own := 1.0 + (_hash(spoke, ring, 11) - 0.5) * 0.06
			var warm := (_hash(spoke, ring, 12) - 0.5) * 0.03
			colour = Color(colour.r * own * (1.0 + warm), colour.g * own, colour.b * own * (1.0 - warm))
			colour = colour.lerp(BAND, band)
			# Broad soft patches, metres across, and a fine mottle.
			var arc := theta * mid
			var patch := 1.0 + (_noise(arc, r, 3.5, 21) - 0.5) * 0.08 + (_noise(arc, r, 0.6, 22) - 0.5) * 0.03
			colour = Color(colour.r * patch, colour.g * patch, colour.b * patch)
			colour = colour.lerp(STRIP, strip)
			# Dust along the foot of the walls.
			var wall := _to_wall(column, r)
			if wall < DUST_FADE_M:
				var dust := 1.0 - smoothstep(DUST_M, DUST_FADE_M, wall)
				colour = colour.lerp(Color(colour.r * DUST.r, colour.g * DUST.g, colour.b * DUST.b), dust)
			var i := (y * w + x) * 3
			data[i] = clampi(roundi(colour.r * 255.0), 0, 255)
			data[i + 1] = clampi(roundi(colour.g * 255.0), 0, 255)
			data[i + 2] = clampi(roundi(colour.b * 255.0), 0, 255)
	return Image.create_from_data(w, h, false, Image.FORMAT_RGB8, data)


func _paint_wear() -> Image:
	var w := WEAR_SIZE.x
	var h := WEAR_SIZE.y
	var data := PackedByteArray()
	data.resize(w * h)
	var front_in := float(_layout.front_in)
	var colonnade := float(_layout.column)
	var mid := (colonnade + float(_layout.east)) * 0.5
	var door := _layout.door as Vector2
	var door_mid := (door.x + door.y) * 0.5
	var step := _theta_step()
	var theta0 := (_layout.theta as Vector2).x
	var dr := ((_layout.radius as Vector2).y - (_layout.radius as Vector2).x) / float(h)
	var dt := ((_layout.theta as Vector2).y - theta0) / float(w)
	var columns := _columns(w)
	for y in h:
		var r := _radius(y, h)
		var ring := floori((r - front_in) / PANEL_M)
		var ring_edge := PANEL_M * 0.5 - absf((r - front_in) - (float(ring) + 0.5) * PANEL_M)
		# The lane of traffic down the middle of the hall.
		var lane := 1.0 - smoothstep(1.2, 3.2, absf(r - mid))
		# Under the balcony, between the front wall and the colonnade: less walked on.
		var balcony := 1.0 - smoothstep(colonnade - 0.6, colonnade + 0.6, r) if r > front_in else 0.0
		var px := dt * r
		for x in w:
			var column: Array = columns[x]
			var theta: float = column[0]
			var rough := 0.8
			# In from the door: a fan widening from the vestibule to the lane.
			var reach := clampf((r - front_in) / maxf(mid - front_in, 0.001), 0.0, 1.0)
			var fan := (1.0 - smoothstep(0.6 + 1.6 * reach, 1.6 + 2.4 * reach, absf(theta - door_mid) * r)) * (1.0 - smoothstep(mid - 1.0, mid + 1.0, r))
			rough += 0.2 * maxf(lane, fan)
			rough -= 0.15 * balcony * (1.0 - fan)
			# Polished near the walls, with dust right at their foot.
			var wall := _to_wall(column, r)
			rough -= 0.22 * (smoothstep(DUST_M, 0.5, wall) * (1.0 - smoothstep(0.6, 1.6, wall)))
			rough = lerpf(rough, 1.0, 1.0 - smoothstep(DUST_M * 0.5, DUST_M * 1.5, wall))
			# Each panel's polish its own.
			var spoke := floori((theta - theta0) / step)
			rough += (_hash(spoke, ring, 31) - 0.5) * 0.12
			rough += (_noise(theta * mid, r, 0.9, 32) - 0.5) * 0.08
			# Scuffs: short strokes, a few in each 0.25 m cell.
			rough += 0.16 * _scuff(theta * mid, r, px, dr)
			# The strips and the bands' edges hold dirt.
			var spoke_edge := (step * 0.5 - absf((theta - theta0) - (float(spoke) + 0.5) * step)) * r
			rough = lerpf(rough, 1.0, maxf(_cover(ring_edge, STRIP_M, dr), _cover(spoke_edge, STRIP_M, px)))
			data[y * w + x] = clampi(roundi(clampf(rough, 0.3, 1.0) * 255.0), 0, 255)
	return Image.create_from_data(w, h, false, Image.FORMAT_L8, data)


## How much of a pixel at (a, r) (metres along the arc and out) a scuff covers: in each
## CELL (0.25 m) square, with the square's own chance, one short stroke at its own angle.
func _scuff(a: float, r: float, pa: float, pr: float) -> float:
	const CELL := 0.25
	var ia := floori(a / CELL)
	var ir := floori(r / CELL)
	var best := 0.0
	var pixel := maxf(pa, pr)
	for i in range(ia - 1, ia + 2):
		for j in range(ir - 1, ir + 2):
			if _hash(i, j, 41) > 0.35:
				continue
			var ca := (float(i) + _hash(i, j, 42)) * CELL
			var cr := (float(j) + _hash(i, j, 43)) * CELL
			var angle := _hash(i, j, 44) * PI
			var half := 0.03 + _hash(i, j, 45) * 0.07
			var along := Vector2(cos(angle), sin(angle))
			var offset := Vector2(a - ca, r - cr)
			var t := clampf(offset.dot(along), -half, half)
			var d := (offset - along * t).length()
			best = maxf(best, _cover(d, 0.003, pixel) * (0.5 + 0.5 * _hash(i, j, 46)))
	return best


func _paint_terrazzo() -> Image:
	var n := TILE_SIZE
	var data := PackedByteArray()
	data.resize(n * n * 3)
	var per_m := float(n) / TILE_M
	# The chips: crushed stone, so each an angular convex shape (the inside of CUTS
	# random half-planes about its centre), muted and close in tone, packed densely in a
	# pale warm matrix; on a torus of the tile's size, so the tile repeats without a seam.
	const PALETTE := [
		[Color(0.97, 0.94, 0.88), 0.24], [Color(0.9, 0.82, 0.7), 0.22], [Color(0.84, 0.82, 0.78), 0.17],
		[Color(0.76, 0.68, 0.58), 0.14], [Color(0.68, 0.62, 0.55), 0.1], [Color(0.8, 0.66, 0.54), 0.07],
		[Color(1.0, 0.99, 0.97), 0.04], [Color(0.5, 0.48, 0.46), 0.02],
	]
	const CUTS := 6
	# Chips placed by cells that divide the tile exactly, up to four in each.
	const CELL_PX := 16
	var cells := n / CELL_PX
	var chips: Array = []
	for cell in cells * cells:
		chips.append([])
	var count := 0
	for cy in cells:
		for cx in cells:
			for k in 4:
				var seed := (cy * cells + cx) * 7 + k
				if _hash(seed, k, 51) > 0.8:
					continue
				var centre := Vector2((float(cx) + _hash(seed, 1, 52)) * CELL_PX, (float(cy) + _hash(seed, 2, 53)) * CELL_PX)
				# Most chips 3-9 mm in radius, a few half as big again.
				var size := lerpf(3.0, 9.0, pow(_hash(seed, 3, 54), 1.8)) * 0.001 * per_m
				if _hash(seed, 4, 55) > 0.94:
					size *= 1.5
				var pick := _hash(seed, 5, 56)
				var colour: Color = PALETTE[0][0]
				for entry: Array in PALETTE:
					if pick < float(entry[1]):
						colour = entry[0]
						break
					pick -= float(entry[1])
				var normals: Array[Vector2] = []
				var reaches: Array[float] = []
				for cut in CUTS:
					var angle := (float(cut) + _hash(seed, 10 + cut, 57) * 0.8) * TAU / float(CUTS)
					normals.append(Vector2(cos(angle), sin(angle)))
					reaches.append(size * (0.65 + _hash(seed, 20 + cut, 58) * 0.5))
				chips[cy * cells + cx].append([centre, size, colour, normals, reaches])
				count += 1
	var matrix := Color(0.97, 0.94, 0.89)
	for y in n:
		for x in n:
			var p := Vector2(float(x) + 0.5, float(y) + 0.5)
			var colour := matrix * (1.0 + (_noise_periodic(float(x), float(y), 8.0, n / 8, 61) - 0.5) * 0.05 + (_hash(x, y, 62) - 0.5) * 0.03)
			var ccx := x / CELL_PX
			var ccy := y / CELL_PX
			for oy in range(-1, 2):
				for ox in range(-1, 2):
					var cell_x := posmod(ccx + ox, cells)
					var cell_y := posmod(ccy + oy, cells)
					for chip: Array in chips[cell_y * cells + cell_x]:
						var centre: Vector2 = chip[0]
						var d := p - centre
						d.x -= roundf(d.x / float(n)) * float(n)
						d.y -= roundf(d.y / float(n)) * float(n)
						var size: float = chip[1]
						if d.length_squared() > size * size * 1.44 + 2.0:
							continue
						# How far inside the chip's nearest edge the pixel's centre is.
						var inside := INF
						var normals: Array[Vector2] = chip[3]
						var reaches: Array[float] = chip[4]
						for cut in CUTS:
							inside = minf(inside, reaches[cut] - d.dot(normals[cut]))
						var cover := clampf(inside + 0.5, 0.0, 1.0)
						if cover > 0.0:
							var tone: Color = chip[2]
							# A chip's own faint grain.
							tone = tone * (1.0 + (_hash(x, y, 63) - 0.5) * 0.04)
							colour = colour.lerp(tone, cover)
			var i := (y * n + x) * 3
			data[i] = clampi(roundi(colour.r * 255.0), 0, 255)
			data[i + 1] = clampi(roundi(colour.g * 255.0), 0, 255)
			data[i + 2] = clampi(roundi(colour.b * 255.0), 0, 255)
	print("FLOOR terrazzo chips: %d on a %d px tile of %.2f m" % [count, n, TILE_M])
	return Image.create_from_data(n, n, false, Image.FORMAT_RGB8, data)
