# D4 source packet — 1405 Sturgeon Street (`w95934108`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; no recognition or live attachment authorized**

Catalog provenance: `ti.facade-recognition-catalog/3`, SHA-256
`0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934108`, v4, `2020-07-09T13:50:42Z`, frozen-file
SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
`1405 Sturgeon Street`, `building=yes`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934108` / `building:w95934108:wall` / `building:w95934108:roof` |
| Relationship / chunk | standalone direct; no part child; `x_-2__z_-1` |
| Mass | area `475.281 m²`; height `6 m`; NAVD88 base/top `2.755 / 8.755 m` |
| Perimeter | serialized / visible `110.813 / 110.813 m`; `20` runs |
| Facing-run partition | WSW `243.4–243.5°`: `0–2,4,17–18`; SSE `153.5°`: `3,5–6,13`; ENE `63.5°`: `7–8,11–12,14`; NNW `333.4–333.5°`: `9–10,15–16,19` |
| Source / wall geometry SHA-256 | `c51a534f9cc042c366a505c6744790605ed1d528ff8988ce4d6ef0395d01f582` / `fabc6b466110e869076fa74b98b7dd28e6cae99623f7c6ac22f5436e6ad645e7` |
| Registry record / chunk SHA-256 | `572c0c425948f12de71ef4556d7be030639d081b58908b19b986a9aa06e42039` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall `building_wall` / `plaster_grey_04`; roof `building_roof` / `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725278` is `1405 STURGEON ST`, parcel `1939001`, point
`37.826046829,-122.375408678`, matching the frozen exact address. A March 2025
capture shows the target standing; occupancy and later condition are unknown.

[March 2025 pano `E8fUbp-OB6KUtmnh9rhHkQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=E8fUbp-OB6KUtmnh9rhHkQ&heading=242&pitch=0&fov=75),
camera `37.8261203,-122.3752900`, heading `242.42°`, is aimed at the target point
and front/ENE runs `7–8,11–12,14`; a nearby UI label says 1408. Written
observation: a strongly symmetrical pair of gabled three-garage wings, a lower
central two-storey connector, exterior stairs, pale stucco, pinkish stair
rails, sparse rectangular openings, and a red-brown shallow roof.

Unknown: exact garage/door dimensions, center opening order, stair scale,
hidden orientations, occupancy, and post-March-2025 alteration. No panorama
pixels are retained.

## Recognition boundary and handoff

Minimum cue: **two symmetrical three-garage gabled wings plus pink-railed
exterior stairs at the center**. Confusion: 1403/1404 Sturgeon and the
Flounder/Halibut family. A detached ENE study is unblocked. Preserve symmetry
only where observed; neutral fields may tile, but garages, stairs, rails, and
openings remain complete modules. Shared sources: [D4 index](README.md).
