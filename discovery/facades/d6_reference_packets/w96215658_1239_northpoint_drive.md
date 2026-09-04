# D6 source packet — 1239 Northpoint Drive (`w96215658`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; camera-side label caveat retained**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215658`, v5,
`2020-05-26T19:59:19Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1239`, `addr:street=Northpoint Drive`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the address is not promoted to a name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215658` / `building:w96215658:wall` / `building:w96215658:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-4` |
| Mass | area `609.117 m²`; height `6 m`; NAVD88 base/top `2.947 / 8.947 m` |
| Perimeter | serialized `145.230 m`; visible `145.229 m`; `34` runs |
| Facing-run partition | WSW `254.2–255.9°`: `0–4,6–8,10–13,16–18`; NNW `345.0–345.8°`: `5,14–15,26,32–33`; SSE `164.9–165.4°`: `9,19–20,24,29`; ENE `75.2–75.4°`: `21–23,25,27–28,30–31` |
| Source / wall geometry SHA-256 | `eecf91635ba952e06e341bced2fe34644a5111bd2640fe2c0a75518bf1422cc8` / `c6664f9a1783aa3a23bade94eea4b2e7f3026ffca53f898a448902d3d3fad58e` |
| Registry record / chunk SHA-256 | `4c5386249aad479fd6bdb02f656573a38d3767c9c51b21d56d35b8a8372b21a5` / `bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483510` is `1239 NORTHPOINT DR`, address ID `725288`,
parcel `1939001`, point `37.8312521,-122.3727077`, current in that dataset
on 2026-09-03. `TIDA-JSCO-2026` lists 1239 as managed premises as of
2025-07-01; inclusion does not prove occupancy.

- [March 2025 pano `-beLMMM0walkjEnahL2Rsg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=-beLMMM0walkjEnahL2Rsg&heading=124.8&pitch=0&fov=75), camera `37.8312197,-122.3729121`, heading `124.8°`: the ray reaches the footprint centroid at about `29.2 m` and exposes the WSW long family `0–4,6–8,10–13,16–18` with NNW-end context. Google's 1240 label belongs to the camera-side row and is not used as target identity.

Written observation: long two-storey pale taupe/gray horizontal-sided row;
white trim; shallow gable roof; no canopy on the observed long face; repeated
but visibly varied upper-window widths/cadence; ground doors, windows, privacy
wings, and frontage parking. Vehicles obscure parts of the ground sequence.
Exact opening endpoints, count, hidden sides, alterations, and occupancy remain
unknown.

## Recognition boundary and handoff

Minimum cue: **a longer canopy-free taupe-gray Northpoint row with visibly
varied upper-window widths rather than one uniform slider stamp**. Close
confusion: 1225, 1234, 1236, and 1227 Northpoint. Reuse tileable siding,
trim, roof, glass, doors, and privacy components; preserve 1239's WSW window
variety, canopy absence, solid intervals, and longer footprint locally.
Prototype blocker: **none for a detached WSW-side study**. Exact
receiver-relative endpoints and the vehicle-hidden ground sequence remain
required before live placement. No panorama pixels are retained or proposed as
texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
