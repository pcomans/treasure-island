# Vegetation model provenance

## Kenney Nature Kit palette

- Asset: `Nature Kit` (archive-reported version `2.1`)
- Creator and publisher: Kenney
- Official asset page: https://kenney.nl/assets/nature-kit
- Exact official download used: https://kenney.nl/media/pages/assets/nature-kit/37ac38a37b-1677698939/kenney_nature-kit.zip
- License: Creative Commons Zero (`CC0`)
- License URL: https://creativecommons.org/publicdomain/zero/1.0/
- Acquired (UTC): `2026-08-28T22:17:11Z`
- Original archive size: `10,537,521` bytes
- Original archive SHA-256: `fa7974a0d342bfe63c38664ba9f8ec1a4aab8ea25f099bdc56870e33588c4d9d`
- Acquisition record and preserved upstream license:
  `third_party_staging/kenney_nature_kit/PROVENANCE.md`

Kenney's archive contains `329` GLB models. To avoid shipping unrelated rocks,
cliffs, props, and duplicate formats, this project extracts only the following
15 premade glTF 2.0 binary meshes, unchanged:

| Model path below `kenney_nature_kit/` | Intended palette role | Bytes | Triangles |
|---|---|---:|---:|
| `grass.glb` | fine grass clump | 11,496 | 132 |
| `grass_large.glb` | large grass clump | 18,504 | 224 |
| `grass_leafsLarge.glb` | broad-leaf ground plant | 13,988 | 144 |
| `plant_bushDetailed.glb` | detailed shrub | 10,172 | 104 |
| `plant_bushLarge.glb` | large shrub | 6,436 | 60 |
| `plant_bushSmall.glb` | small shrub | 3,212 | 16 |
| `tree_detailed.glb` | mature branched broadleaf | 31,412 | 402 |
| `tree_oak.glb` | mature oak-like broadleaf | 14,644 | 196 |
| `tree_palmBend.glb` | strongly bent/wind-shaped palm | 14,820 | 200 |
| `tree_palmDetailedShort.glb` | short detailed palm | 28,212 | 336 |
| `tree_palmDetailedTall.glb` | tall detailed palm | 28,204 | 336 |
| `tree_pineTallA_detailed.glb` | mature conifer A | 10,708 | 134 |
| `tree_pineTallB_detailed.glb` | mature conifer B | 12,632 | 166 |
| `tree_plateau.glb` | flat-crowned/wind-shaped broadleaf | 16,304 | 215 |
| `tree_thin.glb` | narrow irregular broadleaf | 17,200 | 228 |

The curated set totals `237,944` bytes, `8,832` source vertices, and `2,893`
triangles before Godot import. Each file has embedded flat-color materials and
requires no external texture. The upstream archive's CRC-backed ZIP integrity
test and each successful selective extraction establish that these bytes came
from the recorded archive.

CC0 does not require attribution. Optional project credit:
`Kenney Nature Kit — kenney.nl (CC0)`.

## Minimal Godot 4 import recommendation

Godot 4.7's official [available 3D formats documentation](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html)
recommends glTF 2.0 and directly supports binary `.glb` scenes.

Use the GLB files directly as imported `PackedScene` resources and instance
them without mesh conversion. Keep the default scene import initially. Share
the imported resources; for dense repeated grass or shrub placement, batch each
model through one `MultiMeshInstance3D` per spatial chunk. Do not create physics
collision for grass or shrubs. Add only simple trunk collision to trees that
actually affect traversal, and add visibility ranges or LODs only if the full
island produces a measured performance problem.
