extends Resource
## A visual study configuration, not an OSM footprint or placement contract.
@export_range(1, 8, 1) var bay_count: int = 3
@export_range(0, 8, 1) var canopy_bays: int = 2
@export_range(0, 7, 1) var canopy_start: int = 0
@export var walls: Color = Color(0.27, 0.33, 0.34)
@export var doors: Color = Color(0.075, 0.13, 0.19)

func is_valid() -> bool:
	return bay_count >= 1 and bay_count <= 8 and canopy_bays >= 0 and canopy_start >= 0 and canopy_start + canopy_bays <= bay_count
