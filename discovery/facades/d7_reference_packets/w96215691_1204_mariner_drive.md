# D7 source packet — 1204 Mariner Drive (`w96215691`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215691`, v5, `2018-01-25T19:29:08Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1204`, `addr:street=Mariner Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215691` / `building:w96215691:wall` / `building:w96215691:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `490.064 m²`; height `6 m`; NAVD88 base/top `2.640 / 8.640 m` |
| Perimeter | serialized `115.717 m`; visible `115.715 m`; `28` runs |
| Facing-run partition | NNE `23.5°`: `0–2,4–5,7–9`; ESE `113.4–113.5°`: `6,22,27`; SSW `203.4–203.6°`: `12–16,18–21,23–26`; WNW `293.3–293.6°`: `3,10–11,17` |
| Source / wall geometry SHA-256 | `e4d13eabe16f8e1f85e441b6b6bc030f95e0f26d6ef4f2ba418d5b89c3f4939e` / `f0f07737d1e4d411ac9c642a7f5da9a64e395c61bee03cdcb3034cea8540c383` |
| Registry record / chunk SHA-256 | `6a127ed1e92066f31237c6f513d7bec8802ddf0879c6579b2f524dc3f443633c` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483614 / 725405` identify `1204 MARINER DR` on
parcel `1939001`, current in that dataset on 2026-09-03. The Navy's 2015 Site
12 table and TIDA's managed-premises exhibit as of 2025-07-01 retain the same
address. Neither establishes occupancy or an unchanged facade.

- [March 2025 pano `Y2H190dUc9fxaa3sHiBusw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=Y2H190dUc9fxaa3sHiBusw&heading=200.1&pitch=0&fov=75), camera `37.8291608,-122.3750876`, heading `200.1°`: direct centroid ray at about `21.9 m`; supports NNE runs `0–2,4–5,7–9`.

Written observation: a full blue-gray horizontal-sided two-storey row with
white trim, shallow gray roof, repeated broad upper windows, maroon doors,
privacy elements, and a deep flat canopy arranged in two offset/segmented
stretches on white posts. A tree and vehicles obscure some lower endpoints.
Other sides, exact canopy joins/opening cadence, alterations, and occupancy
remain unknown.

## Recognition boundary and handoff

Minimum cue: **blue-gray NNE frontage with maroon entry rhythm and the offset,
two-segment deep canopy silhouette**. Close confusion: 1202/1206 Mariner and
canopy-bearing Northpoint rows. Share tileable siding/trim/roof and a parametric
canopy/post kit; keep this target's canopy segmentation, NNE plane steps, and
entry/opening rhythm local. Prototype blocker: **none for a detached NNE-side
study**; endpoint placement still needs receiver-relative preflight. No
panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
