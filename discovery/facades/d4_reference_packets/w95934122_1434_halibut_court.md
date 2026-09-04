# D4 source packet — 1434 Halibut Court (`w95934122`)

Checked: **2026-09-04**  
Readiness: **historical target-side prototype-ready for the frozen snapshot; current facade absent**

Catalog provenance: `ti.facade-recognition-catalog/3`, SHA-256
`0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934122`, v4, `2020-07-09T13:50:42Z`, frozen-file
SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
`1434 Halibut Court`, `building=yes`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934122` / `building:w95934122:wall` / `building:w95934122:roof` |
| Relationship / chunk | standalone direct; no part child; `x_-2__z_-1` |
| Mass | area `475.523 m²`; height `6 m`; NAVD88 base/top `3.152 / 9.152 m` |
| Perimeter | serialized / visible `110.842 / 110.843 m`; `18` runs |
| Facing-run partition | WSW `243.6–243.7°`: `0–1,6,16`; SSE `153.6–153.7°`: `2–3,5,7`; ENE `63.6°`: `4,8–9,11`; NNW `333.6–333.7°`: `10,12–15,17` |
| Source / wall geometry SHA-256 | `4e69ca005a5ecd4fe54ad778053a3de9fed1520b322fb653b82250b2a43ecd33` / `ba400c5a5cc08cda0749f6bbf5551732fe82c0159f38ed17c4e41c6b612100b9` |
| Registry record / chunk SHA-256 | `2b7da020453e07cd69e334f44a617691398b5e8472e1e7cb4df622ebb7709259` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall `building_wall` / `plaster_grey_04`; roof `building_roof` / `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725356` is `1434 HALIBUT CT`, parcel `1939001`, point
`37.825093447,-122.374738125`, matching the frozen exact address.

- [April 2019 pano `HKFHgtqE2Sph_6ZMyo34oA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=HKFHgtqE2Sph_6ZMyo34oA&heading=332&pitch=0&fov=75), camera `37.8249083,-122.3744109`, heading `332.29°`: exact 1434 label and target front/SSE association, runs `2–3,5,7`. Written observation: a broad symmetrical pair of pale end wings/garage banks, a center connector with two exterior stairs, red doors, sparse openings, and a red-brown shallow roof.
- [March 2025 pano `hKCx2j7NGrLJLaPQWTPtbQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=hKCx2j7NGrLJLaPQWTPtbQ&heading=332&pitch=0&fov=75), camera `37.8250144,-122.3743823`, heading `332.29°`: clear pad at the target footprint.

Unknown: exact garage/door/window counts and dimensions, stair scale, hidden
sides, demolition date, and changes after April 2019. No panorama pixels are
retained.

## Recognition boundary and handoff

Minimum historical cue: **symmetrical twin garage/end wings, twin central
stairs, and red-door accents**. Confusion: 1430/1432/1433/1435 Halibut and the
neighboring row family. A detached historical SSE study is unblocked; do not
copy the less symmetric 1433 configuration. Neutral fields may tile, while
garage, stair, door, and opening modules stay whole and local. Current state is
cleared. Shared sources: [D4 index](README.md).
