# D5 source packet — 1406 Sturgeon Street (`w95934128`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; detached study only**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934128`, v4, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1406`, `addr:street=Sturgeon Street`, `building=yes`,
`height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934128` / `building:w95934128:wall` / `building:w95934128:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `475.435 m²`; height `6 m`; NAVD88 base/top `2.851 / 8.851 m` |
| Perimeter | serialized `110.845 m`; visible `110.842 m`; `18` runs |
| Facing-run partition | SSW `203.9–204.0°`: `0–1,3–4,6–7`; ESE `113.9–114.0°`: `2,8,11`; WNW `293.8–293.9°`: `5,15,17`; NNE `23.8–23.9°`: `9–10,12–14,16` |
| Source / wall geometry SHA-256 | `c41a3d6d78f6e7bd074c2bf33654da1927835461a6bd31c2446a7ee1e43a00ac` / `1c374afaf664a7a001be91080b84d5d665bcadb30acfa3f3437be8c4b36beaf5` |
| Registry record / chunk SHA-256 | `c7269ab735acd086df9a684cb1b9db042383e08410bc956e702f05889e1d7b35` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `483501` is `1406 STURGEON ST`, parcel `1939001`, point
`37.8264896181,-122.3754167247`, current in that dataset on 2026-09-03. It is
absent from the `TIDA-JSCO-2026` managed list; that administrative absence does
not establish physical condition or occupancy.

- [March 2025 pano `8xBjSWPMGItW8wjrsln9oQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=8xBjSWPMGItW8wjrsln9oQ&heading=86&pitch=0&fov=75), camera `37.8264614,-122.3759208`, heading `86°`: direct target-bound SSW/WNW public corner view. Written observation: paired gabled garage wings, a lower central link with exterior stairs, pale tan stucco, salmon garage doors, sparse rectangular openings, and a muted shallow roof.

Unknown: exact garage/window cadence, stair landing dimensions, hidden ESE/NNE
schedules, repairs, and occupancy. No panorama pixels are retained.

## Recognition boundary and handoff

Minimum cue: **paired gabled garage wings, salmon door banks, and central
exterior stairs**. Close confusion: 1404 and 1408 Sturgeon plus the
Flounder/Halibut housing family. Preserve this receiver's paired-wing voids and
do not transfer 1404/1408 opening counts. Tileable pale plaster and roof fields
are reusable; garage banks, stairs, gables, and openings remain complete local
modules. Prototype blocker: **none for the observed public corner study**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).
