# D4 source packet — 1404 Sturgeon Street (`w95934097`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; no recognition or live attachment authorized**

Catalog provenance: `ti.facade-recognition-catalog/3`, SHA-256
`0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934097`, v4, `2020-07-09T13:50:42Z`, frozen-file
SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
`1404 Sturgeon Street`, `building=yes`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934097` / `building:w95934097:wall` / `building:w95934097:roof` |
| Relationship / chunk | standalone direct; no part child; `x_-2__z_-2` |
| Mass | area `475.410 m²`; height `6 m`; NAVD88 base/top `2.816 / 8.816 m` |
| Perimeter | serialized `110.824 m`; visible `110.822 m`; `18` runs |
| Facing-run partition | SSW `195.7°`: `0,2–3,5–6`; ESE `105.7–105.8°`: `1,7,9–10`; WNW `285.6–285.7°`: `4,14,16–17`; NNE `15.6–15.7°`: `8,11–13,15` |
| Source / wall geometry SHA-256 | `dee8ce488a1d9de4f6e5f5d92c1f0e3ea36fbb26acebdee374ec8ab1d087cd1f` / `0d6707f1ce70435bd83ccca770c4ade332ee5e7b0268c44369d496bf9f1e40e1` |
| Registry record / chunk SHA-256 | `7428c7140ccdf5fb05c6e703532fd7b00a20c77fd53b00b77790ce8179b170e2` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall `building_wall` / `plaster_grey_04`; roof `building_roof` / `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725277` is `1404 STURGEON ST`, parcel `1939001`, point
`37.826578599,-122.375902204`; `TIDA-JSCO-2026` also lists 1404 among managed
premises as of 2025-07-01. Neither source proves occupancy or later condition.

[March 2025 pano `8xBjSWPMGItW8wjrsln9oQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=8xBjSWPMGItW8wjrsln9oQ&heading=27&pitch=0&fov=75),
camera `37.8264614,-122.3759208`, heading `26.53°`, binds the public/front SSW
family, runs `0,2–3,5–6`. Written observation: warm pale stucco; two gabled end
blocks over garage pairs; a lower central connector with exterior stairs;
red-brick low piers/plinth accents; pale green-gray doors; dark metal rails; and
a shallow roof/eave. Exact bay widths and occluded returns are unproven.

Unknown: complete door/window cadence, stair/rail scale, brick bond, roof pitch,
WNW/ESE/NNE schedules, occupancy, and post-March-2025 alteration. No panorama
pixels are retained.

## Recognition boundary and handoff

Minimum cue: **twin gabled garage blocks, central exterior-stair connector, and
brick-pier/plinth accents**. Confusion: 1403/1405 Sturgeon and 1409–1413
Flounder. A detached SSW study is unblocked; use tileable plaster/roof fields
with complete brick, stair, rail, garage, and opening modules. Other sides and
receiver endpoint placement remain blocked for live work. Shared sources:
[D4 index](README.md).
