# D4 source packet — 1412 Flounder Court (`w95934096`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; no recognition or live attachment authorized**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934096`, v4, `2020-07-09T13:50:42Z`, frozen-file
SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1412`, `addr:street=Flounder Court`, `building=yes`,
`height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934096` / `building:w95934096:wall` / `building:w95934096:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `475.298 m²`; height `6 m`; NAVD88 base/top `3.018 / 9.018 m` |
| Perimeter | serialized `110.822 m`; visible `110.821 m`; `22` runs |
| Facing-run partition | SSW `196.3–196.4°`: `0–1,3–5,7–8`; WNW `286.3–286.4°`: `2,15,20–21`; ESE `106.3–106.4°`: `6,9–12,17–18`; NNE `16.3–16.4°`: `13–14,16,19` |
| Source / wall geometry SHA-256 | `598e0e45834708ffd9576fd5d64f73bc136d272c5e0011824ce422657eb4d880` / `29095c33dab385efe7f5be95849504bfc85fcbbe9071e41c1010e761ead57dd1` |
| Registry record / chunk SHA-256 | `73ec76ca74255d4f565ba8c916d8f400e7ae81aa1c38ae54def979f82de75b9d` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall `building_wall` / `plaster_grey_04`; roof `building_roof` / `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725325` is `1412 FLOUNDER CT`, parcel `1939001`, point
`37.826708542,-122.375150496`, an exact frozen-address agreement. The structure
is visibly standing in March 2025; occupancy and later alteration are unknown.

[March 2025 pano `iCHqZ_Wp4GXw69BOJtI-bA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=iCHqZ_Wp4GXw69BOJtI-bA&heading=205&pitch=0&fov=75),
camera `37.8269624,-122.3750351`, heading `204.96°`, is spatially aimed at the
1412 EAS point and NNE runs `13–14,16,19`. A nearby UI label reads 1413 but is
not the viewed footprint. Written observation: a broad two-storey row with pale
stucco, shallow hip/cross-gable roof forms, paired garage banks, two exterior
stairs flanking the center, and sparse rectangular windows. Vehicle/vegetation
occlusion and perspective prevent an exact opening schedule.

Unknown: exact garage/door widths and alternation, stair geometry, roof pitch,
hidden SSW/WNW/ESE treatment, substrate, occupancy, and post-March-2025 change.
No panorama pixels are retained.

## Recognition boundary and handoff

Minimum cue: **paired garage banks and two flanking exterior stairs under a
shallow cross-gable/hip silhouette**. Confusion: 1409, 1411, 1413 Flounder and
the adjacent Halibut/Sturgeon 475 m² rows. A detached NNE study is unblocked;
use tileable neutral field/roof families but keep whole garage, stair, and
window modules local. Exact endpoint placement and all unseen sides remain
blocked for live integration. Shared sources: [D4 index](README.md).
