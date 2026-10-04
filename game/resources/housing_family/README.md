# Housing row family study

[housing_row_family.gd](../../scripts/world/facades/housing_row_family.gd) assembles shared fixed-width bays, terminal caps and canopy modules. It reuses the 1232 opening and entry helpers; dimensions and cadence are production inference. These are visual study layouts, not address-specific replacements or accepted live buildings.

Select [short_row.tres](short_row.tres) (3 bays, 2 canopy spans) or [long_row.tres](long_row.tres) (5 bays, 4 spans starting at bay 1). Duplicate a resource for another configuration rather than copying the builder. The resource fields are:

| Field | Meaning |
|---|---|
| `bay_count` | 1–8 fixed 6 m bays; openings retain their size. |
| `canopy_start` | Zero-based first covered bay. |
| `canopy_bays` | Number of covered bays; zero removes the canopy. Start plus extent must not exceed `bay_count`. |
| `walls`, `doors` | Semantic colors; each assembled instance has its own materials. |

Keep one family object to share its module meshes across instances. Duplicate the config before changing a loaded resource in memory:

```gdscript
var family = preload("res://game/scripts/world/facades/housing_row_family.gd").new()
var config = preload("res://game/resources/housing_family/short_row.tres").duplicate(true)
config.bay_count = 4
config.canopy_start = 1
config.canopy_bays = 3
config.walls = Color("3979b5")
config.doors = Color("ba3028")
var house = family.instantiate(config)
add_child(house)
house.position = Vector3(12, 0, -8)
house.rotation.y = deg_to_rad(90)
```

Coordinates are metres: the row begins at local X=0, grows along +X, fronts +Z and extends 8 m toward −Z. Place and rotate the root at scale 1; change bay count rather than stretching the root. Palette changes are applied at instantiation, so rebuild an instance after editing its config.

The family has no standalone demo; check it in the real island with `game/tests/shared/building_shots.gd` and `building_fit_test.gd`.

## Separate housing-instance experiment

The owner-authorized `experiment/housing-family-instances` branch starts at `9c7f2440d3db6a7f2d0a5d474c612c0362a01c16` for A/B comparison with MAIN. Its [canonical target inventory](../../../discovery/HOUSING_FAMILY_INSTANCES.md) records current photo-confirmed, written-only and imagery-insufficient coverage separately from the frozen 23-target A/B capture. The straight prototype needs stepped runs, target opening schedules and appropriate roof/canopy variants before site use; a matching palette or six-metre cadence alone does not establish a fit. Keep per-target identity/grade/geometry and independent acceptance checks even when geometry is shared.
