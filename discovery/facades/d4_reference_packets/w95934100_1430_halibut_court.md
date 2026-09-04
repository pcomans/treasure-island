# D4 source packet — 1430 Halibut Court (`w95934100`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; no recognition or live attachment authorized**

Catalog provenance: `ti.facade-recognition-catalog/3`, SHA-256
`0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934100`, v5, `2020-07-09T13:50:42Z`, frozen-file
SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1430`, `addr:street=Halibut Court`,
`building=apartments`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934100` / `building:w95934100:wall` / `building:w95934100:roof` |
| Relationship / chunk | standalone direct; no part child; `x_-2__z_-1` |
| Mass | area `475.398 m²`; height `6 m`; NAVD88 base/top `2.573 / 8.573 m` |
| Perimeter | serialized / visible `110.831 / 110.831 m`; `20` runs |
| Facing-run partition | WSW `243.6–243.7°`: `0–1,5–6,18`; SSE `153.6–153.7°`: `2,4,7`; ENE `63.6°`: `3,8–9,12–15`; NNW `333.6–333.7°`: `10–11,16–17,19` |
| Source / wall geometry SHA-256 | `1abcca31078f052f92a9ed0f485facd411922c8623613ecc8600871f31134eb9` / `c3b3f3d004e4822df665a767bd946ae99ccd0d9fc71f4d8ecbc37f6d5600e42f` |
| Registry record / chunk SHA-256 | `9eb0f6cc3dcb7a90549569316865ade38f90cb2d9e68716bf7026731eb413a90` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall `building_wall` / `plaster_grey_04`; roof `building_roof` / `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725352` is `1430 HALIBUT CT`, parcel `1939001`, point
`37.824745989,-122.375499873`, matching the frozen address.
`TIDA-JSCO-2026` lists 1430 among managed premises as of 2025-07-01. This
supports administrative currentness, not occupancy or facade continuity.

[March 2025 pano `hTHzoF_k9oHgamBhDjOfLA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=hTHzoF_k9oHgamBhDjOfLA&heading=341&pitch=0&fov=75),
camera `37.8246290,-122.3753714`, heading `341.23°`, binds the front/SSE family,
runs `2,4,7`. Written observation, with a truck partially occluding the center:
two pale projecting gabled end blocks with garage banks, a lower central
connector, exterior stairs, cream/blush wall fields, and a red-brown shallow
roof. Exact center openings and garage count are not recoverable from this view.

Unknown: complete cadence, stair count/order behind the vehicle, roof pitch,
hidden WSW/ENE/NNW sides, tenancy, and changes after March 2025. No panorama
pixels are retained.

## Recognition boundary and handoff

Minimum cue: **pale paired gabled garage blocks bracketing a lower exterior-
stair connector**. Confusion: 1432–1435 Halibut and the matching Flounder /
Sturgeon footprint family. A detached SSE study is unblocked, with the occluded
center explicitly unresolved. Neutral fields may tile; complete garages,
stairs, and end-block silhouettes stay local. Shared sources: [D4 index](README.md).
