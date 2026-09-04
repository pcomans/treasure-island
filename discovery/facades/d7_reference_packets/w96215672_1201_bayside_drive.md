# D7 source packet — 1201 Bayside Drive (`w96215672`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215672`, v5, `2018-01-22T18:57:18Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1201`, `addr:street=Bayside Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215672` / `building:w96215672:wall` / `building:w96215672:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `490.179 m²`; height `6 m`; NAVD88 base/top `2.512 / 8.512 m` |
| Perimeter | serialized `115.726 m`; visible `115.724 m`; `20` runs |
| Facing-run partition | NE `34.7–34.8°`: `0–1,3,5–8`; SE `124.5–124.8°`: `4,16,19`; SW `214.7–214.8°`: `11–12,14–15,17–18`; NW `304.5–304.8°`: `2,9–10,13` |
| Source / wall geometry SHA-256 | `f756e4d6d453b4b1cfe468eb121ef7818d61a8ef6c6b33e3a5aa2776990277ba` / `fcf13ea993d8d6a690dc7dc3b590698d64d8aa875b0576422f808021cd7600a7` |
| Registry record / chunk SHA-256 | `5edf978c6e0d6d03359386880620ae9cf5140369f6deddc017b7c7734e7eee2a` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483164 / 724689` identify `1201 BAYSIDE DR` on
parcel `1939001`, current in that dataset on 2026-09-03. The 2015 Navy table
and 2025-07-01 TIDA managed exhibit both retain the address in Site 12 housing.
Neither establishes an unchanged exterior or occupancy.

- [March 2025 pano `-0e5UfeRbgsLQ8MDw82Jsg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=-0e5UfeRbgsLQ8MDw82Jsg&heading=225.2&pitch=0&fov=75), camera `37.8297278,-122.3763734`, heading `225.2°`: exact-address, direct centroid view at about `20.5 m`; supports NE runs `0–1,3,5–8`.

Written observation: long canopy-free cool blue-gray horizontal-sided row;
white trim and downspouts; shallow gray roof; repeated broad upper sliders;
dark red/maroon doors; broad ground windows; and several dark privacy/bin
screens that interrupt an otherwise regular elevation. Exact module endpoints,
rear/ends, alterations, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **cool-blue NE row with maroon entry rhythm, broad upper sliders,
and privacy-screen breaks without a front canopy**. Close confusion: 1203/1205
Bayside and 1212/1219 Mariner. Share tileable siding/trim/glass/roof fields;
keep this target's NE door/window/privacy rhythm and canopy absence local.
Prototype blocker: **none for a detached NE-side study**. No panorama pixels
are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
