extends SceneTree
## The ground dressing's placement rules (game/scripts/world/ground_dressing.gd):
## the density setting, the cells round the camera and the tufts each cell holds.
## What the grass looks like is judged from rendered frames.

const GROUND_DRESSING := preload("res://game/scripts/world/ground_dressing.gd")

var _failed := false


func _initialize() -> void:
	_check_density_choice()
	var cameras: Array[Vector3] = [Vector3(0.5, 6.0, 0.5), Vector3(-391.7, 5.5, 633.2), Vector3(127.9, 42.0, -128.1), Vector3(3.9, 6.0, 4.1)]
	for level: String in GROUND_DRESSING.LEVELS:
		var ring_m := float(GROUND_DRESSING.LEVELS[level].ring_m)
		for at: Vector3 in cameras:
			_check_cells(at, ring_m)
	_check_nothing_from_high_above()
	_check_every_family_is_dressed()
	_check_tile_points()
	_check_chip_window()
	_check_chip_cells()
	if _failed:
		quit(1)
		return
	print("PASS: ground dressing placement rules hold")
	quit(0)


func _require(condition: bool, message: String) -> bool:
	if not condition:
		push_error(message)
		_failed = true
	return condition


func _check_density_choice() -> void:
	_require(GROUND_DRESSING.density_choice(PackedStringArray(), "medium").level == "medium", "The setting chooses the density without a flag.")
	_require(GROUND_DRESSING.density_choice(PackedStringArray(["--ground-dressing", "low"]), "high").level == "low", "The flag beats the setting.")
	_require(GROUND_DRESSING.density_choice(PackedStringArray(["--ground-dressing", "off"]), "high").level == GROUND_DRESSING.OFF, "The flag can turn the grass off.")
	_require(not GROUND_DRESSING.density_choice(PackedStringArray(["--ground-dressing", "lots"]), "high").ok, "A bad level is refused, not defaulted.")
	_require(not GROUND_DRESSING.density_choice(PackedStringArray(["--ground-dressing"]), "high").ok, "A flag without a value is refused.")


## Every point of the ring lies in exactly one cell, and that cell holds every
## tuft rank the shader stands at that point.
func _check_cells(at: Vector3, ring_m: float) -> void:
	var cells := GROUND_DRESSING.cells_around(at, ring_m)
	if not _require(not cells.is_empty(), "A camera near the ground has cells round it."):
		return
	var step_m := ring_m / 17.0
	for x in range(-18, 19):
		for z in range(-18, 19):
			var point := Vector3(at.x + float(x) * step_m + 0.11, GROUND_DRESSING.GROUND_Y_M, at.z + float(z) * step_m + 0.07)
			var distance := at.distance_to(point)
			if distance > ring_m:
				continue
			var holders := 0
			for cell: Vector3i in cells:
				var size: float = GROUND_DRESSING.CELL_M * float(1 << cell.z)
				if point.x >= cell.x * size and point.x < (cell.x + 1) * size and point.z >= cell.y * size and point.z < (cell.y + 1) * size:
					holders += 1
					var nearest: float = cells[cell]
					if not _require(nearest <= distance + 0.001, "A cell's nearest point is no further than a point in it."):
						return
					var held: float = GROUND_DRESSING.tier_share(GROUND_DRESSING.tier_at(nearest))
					if not _require(held >= GROUND_DRESSING.share_at(distance) - 0.001, "A cell holds every tuft that stands anywhere in it."):
						return
			if not _require(holders == 1, "Point %s of the ring lies in %d cells." % [point, holders]):
				return


func _check_nothing_from_high_above() -> void:
	var ring_m := float(GROUND_DRESSING.LEVELS.high.ring_m)
	_require(GROUND_DRESSING.cells_around(Vector3(10.0, GROUND_DRESSING.GROUND_Y_M + ring_m + 40.0, 10.0), ring_m).is_empty(), "No cells from above the ring: the ground alone carries the look from there.")


## A new ground-cover family can't quietly grow nothing.
func _check_every_family_is_dressed() -> void:
	for family: String in GROUND_DRESSING.GROUND_COVER.FAMILIES:
		_require(GROUND_DRESSING.DRESS.has(family), "Ground-cover family %s has no dressing." % family)


## Any first share of the tile's points spreads over the whole tile.
func _check_tile_points() -> void:
	for count: int in [16, 64, 256]:
		var quarters := [0, 0, 0, 0]
		for index in count:
			var point := GROUND_DRESSING.tile_point(index)
			if not _require(point.x >= 0.0 and point.x < GROUND_DRESSING.CELL_M and point.y >= 0.0 and point.y < GROUND_DRESSING.CELL_M, "Tile points stay in the tile."):
				return
			var quarter := (1 if point.x >= GROUND_DRESSING.CELL_M * 0.5 else 0) + (2 if point.y >= GROUND_DRESSING.CELL_M * 0.5 else 0)
			quarters[quarter] += 1
		for share: int in quarters:
			_require(absf(float(share) / float(count) - 0.25) < 0.1, "The first %d tile points spread evenly." % count)


## The chips capture's window holds the chip ring wherever the camera can be before a
## recapture, which comes once it is RECENTRE_M from the window's centre.
func _check_chip_window() -> void:
	for level: String in GROUND_DRESSING.LEVELS:
		var reach := GROUND_DRESSING.RECENTRE_M + float(GROUND_DRESSING.LEVELS[level].chip_ring_m)
		_require(reach <= GROUND_DRESSING.CHIP_WINDOW_M * 0.5, "The %s chip ring reaches %.1f m from the chips window's centre, past its half width." % [level, reach])


## Chip cells stand only over a bed: the quadtree cells over the ground cells its
## triangles reach, every point of it among them, and none round a camera far from it.
func _check_chip_cells() -> void:
	# A bed of 6 m by 3 m, and a strip 0.8 m wide and 40 m long on a slant.
	var bed := PackedVector2Array([Vector2(10.0, 10.0), Vector2(16.0, 10.0), Vector2(16.0, 13.0), Vector2(10.0, 10.0), Vector2(16.0, 13.0), Vector2(10.0, 13.0)])
	var along := Vector2(0.8, 0.6) * 40.0
	var across := Vector2(-0.6, 0.8) * 0.8
	var start := Vector2(-60.0, 30.0)
	var strip := PackedVector2Array([start, start + along, start + along + across, start, start + along + across, start + across])
	var ground := {}
	GROUND_DRESSING.mulch_cells(bed, ground)
	GROUND_DRESSING.mulch_cells(strip, ground)
	ground = GROUND_DRESSING.grow_cells(ground, GROUND_DRESSING.MULCH_MARGIN_CELLS)
	var cell_m: float = GROUND_DRESSING.CELL_M
	for step in 81:
		var point := start + along * (float(step) / 80.0) + across * 0.5
		if not _require(ground.has(Vector2i(floori(point.x / cell_m), floori(point.y / cell_m))), "A point of the strip lies in a chip ground cell."):
			return
	for x in 13:
		for z in 7:
			var point := Vector2(10.0 + float(x) * 0.5, 10.0 + float(z) * 0.5)
			if not _require(ground.has(Vector2i(floori(point.x / cell_m), floori(point.y / cell_m))), "A point of the bed lies in a chip ground cell."):
				return
	var cells := GROUND_DRESSING.cells_around(Vector3(12.0, 6.0, 11.0), 10.0)
	var kept := GROUND_DRESSING.cells_over(cells, ground)
	_require(not kept.is_empty() and kept.size() < cells.size(), "Chip cells over a bed are kept and the rest dropped.")
	for cell: Vector3i in kept:
		var span := 1 << cell.z
		var touches := false
		for x in span:
			for z in span:
				touches = touches or ground.has(Vector2i(cell.x * span + x, cell.y * span + z))
		_require(touches, "A kept chip cell lies over a chip ground cell.")
	_require(GROUND_DRESSING.cells_over(GROUND_DRESSING.cells_around(Vector3(200.0, 6.0, 200.0), 10.0), ground).is_empty(), "No chip cells far from every bed.")
