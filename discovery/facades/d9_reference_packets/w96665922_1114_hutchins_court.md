# D9 source packet — 1114 Hutchins Court (`w96665922`)

Checked: **2026-09-04**  
Readiness: **component/upper-side study ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665922`, v5, `2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1114`, `addr:street=Hutchins Court`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665922` / `building:w96665922:wall` / `building:w96665922:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `306.450 m²`; height `6 m`; NAVD88 base/top `2.459 / 8.459 m` |
| Perimeter | serialized `77.758 m`; visible `77.760 m`; `10` runs |
| Facing-run partition | NNE `16.7°`: `0–2`; ESE `106.8°`: `8–9`; SSW `196.7°`: `4–7`; WNW `286.7°`: `3` |
| Source / wall geometry SHA-256 | `21a4b982ac74b38dfeebe4e110fefd2f2c7a8c2c27a380cb3094051c3c6fb608` / `a04da748a5c43fd83653dae83d3d0a947a9f8faeeab6eb498a0208bd83f08caf` |
| Registry record / chunk SHA-256 | `b0d4d2a70117bfe09b17d81871c72a119fd3f413d5bc80573fa51ba6121037d6` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483625 / 725416`, point `37.8283561,-122.3767551` identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. That administrative row does not prove tenancy, legal status, survival after the panorama date, or an unchanged facade.

- [January 2023 pano `FTXy7teJxUUQwI2I73Pwmg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=FTXy7teJxUUQwI2I73Pwmg&heading=107.6&pitch=0&fov=75), camera `37.8285888,-122.3770164`, direct centroid ray `107.6°` at about `11.6 m`: supports the WNW-facing family. The provider's Gateview Avenue label supplies no target identity and is excluded.

Written observation: the visible WNW upper side is a long two-storey gray horizontal-sided plane with a shallow roof overhang, white downspouts/trim, and repeated rectangular windows. A tall opaque timber fence and trees conceal the entire lower side and entries.

## Recognition boundary and handoff

Minimum cue: **long gray WNW upper plane, shallow overhang, white downspouts, and repeated window band above a timber fence**. Close confusion: 1110/1112/1116/1118 Hutchins and adjacent Mason rows. Authorize the shared siding, trim, downspout, roof-edge, and upper-window modules; the fence-hidden lower modules and entrances remain entity-specific unknowns. Prototype/component blocker: **the opaque fence and trees block the full lower WNW facade; authorize only an upper-side component study**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).
