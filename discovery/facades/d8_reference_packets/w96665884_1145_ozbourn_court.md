# D8 source packet — 1145 Ozbourn Court (`w96665884`)

Checked: **2026-09-04**  
Readiness: **component/historical mass-and-upper-window study ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96665884`, v5, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1145`, `addr:street=Ozbourn Court`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665884` / `building:w96665884:wall` / `building:w96665884:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-3` |
| Mass | area `516.069 m²`; height `6 m`; NAVD88 base/top `2.541 / 8.541 m` |
| Perimeter | serialized `113.775 m`; visible `113.775 m`; `12` runs |
| Facing-run partition | NE `34.3–34.7°`: `0–1,10`; SE `124.7°`: `7–9,11`; SW `214.7°`: `6`; NW `304.7°`: `2–5` |
| Source / wall geometry SHA-256 | `22bb02cd0eb131e147616c670db2983a90344a7a51896a95f65c3e56bc7f5ea5` / `89b2e9e650f0fcb86b6cd5e632dfbc4cb32ee2e43f0e5fc3725afeb86d0ee308` |
| Registry record / chunk SHA-256 | `6f140bf7e7f1ffc0e62c30a57870c6befd4a6d404dc6828de36e8f233eb2d50d` / `7f0ecd2e16fe4327f351496ed8c2f8640d68278fbaf33d428b6314ec862d9944` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483610 / 725401` identify `1145 OZBOURN CT` on
parcel `1939001`, current in that dataset on 2026-09-03. A September 2025 TIDA
Director's Report records broken windows at address-specific units; it supports
dated condition context, not a complete facade or occupancy state.

- [April 2019 pano `n93IglgyTqGTKr0ywhxjig`](https://www.google.com/maps/@?api=1&map_action=pano&pano=n93IglgyTqGTKr0ywhxjig&heading=318.8&pitch=0&fov=70), camera `37.8293875,-122.3772764`, direct centroid ray at about `39.7 m`: bounds a historical SE-side/massing view. The provider's `1141 Ozbourn` label names a neighbor and is excluded.

Written observation: pale horizontal siding, a shallow roof, upper-window
groups, lawn, and several stepped/projection masses are visible across the
court, but trees and hedges hide most lower openings and entrances. The 2019
color/condition cannot be asserted as current.

## Recognition boundary and handoff

Minimum cue: **stepped two-storey Ozbourn mass with pale siding, shallow roof,
and the observed upper-window groupings**. Close confusion: 1141/1143 Ozbourn
and Mariner housing. Share quiet siding, trim, roof, and window components;
do not invent the lower entry schedule or transplant one from a neighbor.
Component blocker: **dense vegetation, distance, and historical-only imagery
prevent a full target-side prototype**. No panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).
