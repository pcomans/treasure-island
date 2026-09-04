# D8 source packet — Building 292 candidate (`w96665889`)

Checked: **2026-09-04**  
Readiness: **appearance-blocked**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96665889`, v3, `2018-01-25T19:29:09Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `building=yes`, `height=4`. The source has no address or name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665889` / `building:w96665889:wall` / `building:w96665889:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-3` |
| Mass | area `953.128 m²`; height `4 m`; NAVD88 base/top `3.346 / 7.346 m` |
| Perimeter | serialized `204.363 m`; visible `204.363 m`; `20` runs |
| Facing-run partition | ENE `62.2°`: `0–8`; SSE `152.2°`: `19`; WSW `242.2°`: `10–18`; NNW `332.2°`: `9` |
| Source / wall geometry SHA-256 | `0944db97af14605c41de084c6b725eab38631957fa40aeeb4d7eb522fd86ea66` / `10560418da00e77ca94631fca282435bd911cd0f44685a4ace398690eb32631f` |
| Registry record / chunk SHA-256 | `69ddf1bcc0b78f5ca44297f4283a124131a856b09cc15afdc7a97b44f8cf1937` / `d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-XWALK` identifies Building 292 at 701 14th Street, and `CITY-EAS`
base/address IDs `483158 / 724677` identify that yard entrance. Official City
premises diagrams describe B292 as part of the SFPW on-island corporation yard,
and a Navy record describes B292 as a 1944 storage shed. Spatial uniqueness
makes this footprint a strong B292 candidate, but no checked source explicitly
binds OSM `w96665889`; the name remains non-canonical.

- [September 2025 pano `miyacxV1TZN_HHYyS3im0Q`](https://www.google.com/maps/@?api=1&map_action=pano&pano=miyacxV1TZN_HHYyS3im0Q&heading=323.1&pitch=0&fov=70), camera `37.8296201,-122.3713055`, direct centroid ray at about `58.5 m`: the public ray reaches an opaque chain-link gate and trees; the target facade is not meaningfully visible.

Written observation: only the fenced yard boundary, opaque gate treatment, and
vegetation can be assigned to the sightline. Wall color, roof form, openings,
doors, bays, and condition are unknown and must not be inferred from another
yard building or a generic storage-shed type.

## Recognition boundary and handoff

Minimum cue: **none yet beyond the exact low, large footprint and possible
B292 yard context**. Close confusion: other corporation-yard/storage buildings
near 14th Street. Geometry alone is not a recognizable facade. Appearance
blocker: **the only current public sightline is gate/tree-occluded, and neither
an official facade record nor a rights-clear target image was found**. No
panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).
