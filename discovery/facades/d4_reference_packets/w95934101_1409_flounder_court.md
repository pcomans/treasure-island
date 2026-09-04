# D4 source packet — 1409 Flounder Court (`w95934101`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; no recognition or live attachment authorized**

Catalog provenance: `ti.facade-recognition-catalog/3`, SHA-256
`0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934101`, v4, `2020-07-09T13:50:42Z`, frozen-file
SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
`1409 Flounder Court`, `building=yes`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934101` / `building:w95934101:wall` / `building:w95934101:roof` |
| Relationship / chunk | standalone direct; no part child; `x_-2__z_-2` |
| Mass | area `475.393 m²`; height `6 m`; NAVD88 base/top `3.001 / 9.001 m` |
| Perimeter | serialized / visible `110.820 / 110.817 m`; `16` runs |
| Facing-run partition | WSW `243.8°`: `0,2–3,5–6`; SSE `153.8–153.9°`: `1,7–8,10`; NNW `333.8–333.9°`: `4,13,15`; ENE `63.8–63.9°`: `9,11–12,14` |
| Source / wall geometry SHA-256 | `4e6f75b340c34f40006313352cce6e9ee53062f0f1d23ef5e9f6616cd84daefb` / `229e44497b1f9e493a015de6dc0c4a77a2cc32ac537375e23edd93c83300806b` |
| Registry record / chunk SHA-256 | `60b18b83cc01f30aaf93f861445887ebe47b2108c687e89220346b08cff9c093` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall `building_wall` / `plaster_grey_04`; roof `building_roof` / `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725322` is `1409 FLOUNDER CT`, parcel `1939001`, point
`37.826441599,-122.374469215`, matching the frozen exact address. A March 2025
capture shows the target standing; occupancy and later condition are unknown.

[March 2025 pano `VYbLAjblETVT3Wn-HAMbZg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=VYbLAjblETVT3Wn-HAMbZg&heading=63&pitch=0&fov=75),
camera `37.8264491,-122.3746830`, heading `63.33°`, is aimed at the 1409 point
and front/WSW runs `0,2–3,5–6`; a nearby UI label says 1410, while a visible
1409 marker and the spatial bearing identify the target. Written observation:
a broad three-garage gabled end block, a central two-storey connector with two
exterior stair/entry voids, pale cream stucco, sparse windows, and a shallow
brown roof. The far end and some lower openings are occluded.

Unknown: far-wing configuration, exact door/window cadence, stair dimensions,
other orientations, occupancy, and post-March-2025 alteration. No panorama
pixels are retained.

## Recognition boundary and handoff

Minimum cue: **three-garage gabled wing plus the paired stair/entry voids in a
lower central connector**. Confusion: 1411/1412/1413 Flounder and the similar
Halibut/Sturgeon rows. A detached WSW study is unblocked; do not mirror the
visible wing or infer the hidden end. Tileable neutral plaster/roof is suitable,
but garage/stair/opening modules remain whole and local. Shared sources:
[D4 index](README.md).
