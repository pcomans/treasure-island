# D7 source packet — 1143 Ozbourn Court (`w96215676`)

Checked: **2026-09-04**  
Readiness: **target-side historical prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215676`, v5, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1143`, `addr:street=Ozbourn Court`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215676` / `building:w96215676:wall` / `building:w96215676:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-3` |
| Mass | area `431.131 m²`; height `6 m`; NAVD88 base/top `2.564 / 8.564 m` |
| Perimeter | serialized `109.819 m`; visible `109.818 m`; `14` runs |
| Facing-run partition | NE `34.9–35.0°`: `0–1,10`; SE `124.9°`: `8–9,11–13`; SW `214.9°`: `3,6–7`; NW `304.9°`: `2,4–5` |
| Source / wall geometry SHA-256 | `a7de4f770d25c56385b3eef7cd59c2728679bab33c0533e5c8d2a4b93185a1d9` / `aab900e2bf507674b76113320147153e572610ccedd723e31b56f6c7ff171233` |
| Registry record / chunk SHA-256 | `f5391a33b27db902c376e5041f842c76f4c0c80bda472072991bed63fa603522` / `7f0ecd2e16fe4327f351496ed8c2f8640d68278fbaf33d428b6314ec862d9944` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483609 / 725400` identify `1143 OZBOURN CT` on
parcel `1939001`, current in that dataset on 2026-09-03. The 2015 Navy table
lists the address with then-provider The Villages at Treasure Island, and the
TIDA exhibit as of 2025-07-01 retains it. These are administrative facts only.

- [April 2019 pano `uMQ89In9y-H1rC4r_3gfoA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=uMQ89In9y-H1rC4r_3gfoA&heading=292.8&pitch=0&fov=75), camera `37.8291699,-122.3774693`, heading `292.8°`: direct centroid ray at about `28.0 m`; supports SE runs `8–9,11–13`. It is historical evidence predating the frozen OSM timestamp and cannot prove a 2026 facade.

Written observation: a white/pale horizontal-sided two-storey row with a
shallow red-brown roof, green doors, repeated white-framed upper windows, and
no pronounced front canopy. Two mature trees partially cover the center but
do not erase the main long-side family. Exact schedule behind foliage, other
sides, alterations after April 2019, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum dated cue: **white SE row with red-brown shallow roof and green-door
rhythm, without a deep canopy**. Close confusion: 1141/1139 Ozbourn and pale
Bayside rows. Share a quiet siding field and red-roof/green-door component
family only; keep the SE cadence and foliage-obscured gaps local. Prototype
blocker: **none for a detached April-2019 historical study**. Current-facade
claims remain blocked. No panorama pixels are retained or proposed as textures.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
