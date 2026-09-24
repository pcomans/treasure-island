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

The [focused demo](../../tests/housing_row_family_demo.gd) checks shared geometry, variant structure, material isolation and generated normals, and can capture paired whole/detail views. Its successful [whole](../../../evidence/first-playable/housing-family-study-2026-09-23/001/whole.png) and [detail](../../../evidence/first-playable/housing-family-study-2026-09-23/001/detail.png) images show the isolated study. There is no terrain fit, collision, source-ID attachment or production acceptance here. Before using it for a real target, compare actual references and preserve that target's footprint, orientation, grade and identity through the existing integration and independent checks.
