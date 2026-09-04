# D4 source packet — 1435 Halibut Court (`w95934098`)

Checked: **2026-09-04**  
Readiness: **historical target-side prototype-ready for the frozen snapshot; current facade absent**

Catalog provenance: `ti.facade-recognition-catalog/3`, SHA-256
`0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934098`, v4, `2020-07-09T13:50:42Z`, frozen-file
SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
`1435 Halibut Court`, `building=yes`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934098` / `building:w95934098:wall` / `building:w95934098:roof` |
| Relationship / chunk | standalone direct; no part child; `x_-2__z_-1` |
| Mass | area `475.338 m²`; height `6 m`; NAVD88 base/top `3.093 / 9.093 m` |
| Perimeter | serialized `110.824 m`; visible `110.823 m`; `18` runs |
| Facing-run partition | WSW `242.2°`: `0–1,3,13`; SSE `152.0–152.2°`: `2,4–7,9`; ENE `62.2°`: `8,10–11,16`; NNW `332.2°`: `12,14–15,17` |
| Source / wall geometry SHA-256 | `9d9d780d52161673bbca24e15e8b1ac3082d3ac4d6806b611324eb3fa1ee7231` / `4bd42a5ff8b5a2339bc77d9eb328a9a0cb06bcc3463e41247e563b44de2d2deb` |
| Registry record / chunk SHA-256 | `e70b02a38a490f527d798649104903bed5f7b6130b82930a05c189c3f53beaaf` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall `building_wall` / `plaster_grey_04`; roof `building_roof` / `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725357` is `1435 HALIBUT CT`, parcel `1939001`, point
`37.824775650,-122.374394802`, matching the frozen exact address.

- [April 2019 pano `HKFHgtqE2Sph_6ZMyo34oA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=HKFHgtqE2Sph_6ZMyo34oA&heading=150&pitch=0&fov=75), camera `37.8249083,-122.3744109`, heading `149.87°`: target bearing resolves 1435 despite a nearby 1434 UI label; front NNW association, runs `12,14–15,17`. Written observation: two large gabled end wings with paired garage openings, blush central connector, two exterior stairs, salmon-toned shutters/garage doors, and a red-brown shallow roof.
- [March 2025 pano `hKCx2j7NGrLJLaPQWTPtbQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=hKCx2j7NGrLJLaPQWTPtbQ&heading=150&pitch=0&fov=75), camera `37.8250144,-122.3743823`, heading `149.87°`: clear pad at the target footprint.

Unknown: exact bay widths/order, shutter count, stair dimensions, hidden side
schedules, demolition date, and changes between April 2019 and clearance. No
panorama pixels are retained.

## Recognition boundary and handoff

Minimum historical cue: **paired gabled garage wings plus twin exterior stairs
and salmon accent family**. Confusion: 1432–1434 Halibut and the Flounder /
Sturgeon rows. A detached historical NNW study is unblocked. Keep whole
garage/stair/shutter modules entity-local; tileability applies only to neutral
fields and roof. Current state is cleared, and no current facade may be claimed.
Shared sources: [D4 index](README.md).
