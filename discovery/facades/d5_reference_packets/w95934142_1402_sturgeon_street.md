# D5 source packet — 1402 Sturgeon Street (`w95934142`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready from complementary oblique views; detached study only**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934142`, v4, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1402`, `addr:street=Sturgeon Street`, `building=yes`,
`height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934142` / `building:w95934142:wall` / `building:w95934142:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `475.323 m²`; height `6 m`; NAVD88 base/top `2.393 / 8.393 m` |
| Perimeter | serialized `110.824 m`; visible `110.823 m`; `22` runs |
| Facing-run partition | SSW `195.7°`: `0–1,3,6–8`; ESE `105.7°`: `2,9–11,14–15`; WNW `285.7–285.8°`: `4–5,19,21`; NNE `15.6–15.7°`: `12–13,16–18,20` |
| Source / wall geometry SHA-256 | `42ae45a967195fca46b8ff4dcd48504534048972cf7260a7a5f81fbf8b303332` / `1d54c8899a098e3d9ee435ee08c5c9cf778315f6d26263bc659064bbc7abe7d7` |
| Registry record / chunk SHA-256 | `f414c09b9269cf6757c5d08bb2ffcbb4fffe8a4cfef04360fd5567c1ccd64edf` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `483497` is `1402 STURGEON ST`, parcel `1939001`, point
`37.8266824105,-122.3764279174`, current in that dataset on 2026-09-03.
`TIDA-JSCO-2026` includes 1402 Sturgeon as of 2025-07-01. These sources do not
establish occupancy or facade details.

- [March 2025 pano `8xBjSWPMGItW8wjrsln9oQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=8xBjSWPMGItW8wjrsln9oQ&heading=316&pitch=0&fov=75), camera `37.8264614,-122.3759208`, heading `316°`: close partial ESE public-side association, principally runs `2,9–11,14–15`.
- [November 2025 pano `GmuTsOm1-FO47a4FOWEQHA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=GmuTsOm1-FO47a4FOWEQHA&heading=83&pitch=0&fov=75), camera `37.8266407,-122.3769985`, heading `83°`: wider complementary WNW-side association, principally runs `4–5,19,21`.

Together the written observations support a pale two-storey paired-end/garage
row, shallow gabled roof masses, a lower central link, exterior stair forms,
and a sparse rectangular opening rhythm. Neither oblique view supports an exact
whole-perimeter schedule. No panorama pixels are retained.

## Recognition boundary and handoff

Minimum cue: **paired garage/end massing plus central stair/link composition**.
Close confusion: 1400 and 1404 Sturgeon and the Flounder/Halibut rows. A study
may cover the observed ESE/WNW sides while leaving unsupported SSW/NNE bays
quiet. Share tileable neutral fields, never a neighbor's exact garage/window
schedule. Prototype blocker: **none for a conservative complementary-side
study; whole-perimeter detailing remains unsupported**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).
