# D4 source packet — frozen number 1307 / 1307 Gateview Avenue (`w95934103`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; no recognition or live attachment authorized**

Catalog provenance: `ti.facade-recognition-catalog/3`, SHA-256
`0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934103`, v5, `2018-08-12T03:45:07Z`, frozen-file
SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1307`, `building=apartments`, `height=6`; **no frozen
street tag**.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934103` / `building:w95934103:wall` / `building:w95934103:roof` |
| Relationship / chunk | standalone direct; no part child; `x_-3__z_-1` |
| Mass | area `732.871 m²`; height `6 m`; NAVD88 base/top `2.033 / 8.033 m` |
| Perimeter | serialized / visible `170.525 / 170.525 m`; `32` runs |
| Facing-run partition | WSW `242.6°`: `0,2–5,7–8`; SSE `152.4–152.6°`: `1,9,11,16,18–19,26`; NNW `332.5–332.6°`: `6,14,21,23,28,30–31`; ENE `62.5–62.6°`: `10,12–13,15,17,20,22,24–25,27,29` |
| Source / wall geometry SHA-256 | `12cf743205ca3d8cb93861f3b5e017114eb114ed47f4eadbf0840d828ec4c3a8` / `ae3314072a6c59a1ef2a4c421551611c3f9e6d0e6f5ed8c208b07de035797ab3` |
| Registry record / chunk SHA-256 | `d00deaef4066847cfd83bd4d4f50d53dbd4485afcbd5843db2addec1a955a48b` / `e45c1670c1714cbb982a14a809054a640e53f9a4add5e3c6080a0f98efb877d2` |
| Current neutral materials | wall `building_wall` / `plaster_grey_04`; roof `building_roof` / `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725359` is `1307 GATEVIEW AVE`, parcel `1939001`, point
`37.824042594,-122.376755146`. The matching frozen number, spatial agreement,
and `TIDA-JSCO-2026` managed-premises list support a high-confidence
spatial/number crosswalk, not a frozen street-tag fact. The building is visibly
standing in March 2025; occupancy and later condition are unknown.

[March 2025 pano `zO-a_ZQWv5tAHydoH3VsFQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=zO-a_ZQWv5tAHydoH3VsFQ&heading=243&pitch=0&fov=75),
camera `37.8240737,-122.3766091`, heading `242.52°`, resolves the 1307 frontage
and ENE family, runs `10,12–13,15,17,20,22,24–25,27,29`. Written observation:
warm-gray horizontal siding, a low roof, repeated upper sliders, ground doors,
and large paired gable-roof porch/carport canopies with open lower voids.
Vehicles and perspective obscure exact unit boundaries.

Unknown: exact bay/order/count, which lower voids are carports versus porches,
canopy depth/pitch, unseen orientations, substrate, occupancy, and post-March
2025 alteration. No panorama pixels are retained.

## Recognition boundary and handoff

Minimum cue: **the paired deep gable-canopy rhythm beneath a long warm-gray
sided upper row**. Confusion: 1305, blocked 1306, and 1318 Gateview. A detached
ENE study is unblocked. Siding and roof fields may target tileability; complete
canopy, slider, door, and open-void modules remain local. Do not transfer the
1305 or 1318 cadence. Shared sources: [D4 index](README.md).
