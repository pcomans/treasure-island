# D7 source packet — 1232 Northpoint Drive (`w96215673`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215673`, v5, `2020-05-26T19:59:19Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1232`, `addr:street=Northpoint Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215673` / `building:w96215673:wall` / `building:w96215673:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `489.389 m²`; height `6 m`; NAVD88 base/top `2.641 / 8.641 m` |
| Perimeter | serialized `115.744 m`; visible `115.743 m`; `24` runs |
| Facing-run partition | N `2.4–2.8°`: `0,2,14`; E `92.3–93.9°`: `10–13,15–18,20–23`; S `182.2–183.0°`: `6,8–9,19`; W `272.8–273.0°`: `1,3–5,7` |
| Source / wall geometry SHA-256 | `68cfe7d7d35c73dabc86f0c31952c9dfe4795dd220dd6c008e3db2095e64bae2` / `5cd14c2e155e089936bdd1852a9d9796ff97a8d86710b6eadfe27a3dedfeab29` |
| Registry record / chunk SHA-256 | `b61fdfdf554dfa6719120f2f0607acab9e49851abf0f86149d9c19ccd2214759` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483514 / 725292` identify `1232 NORTHPOINT DR`
on parcel `1939001`, current in that dataset on 2026-09-03. The Navy's 2015
Site 12 table and TIDA's 2025-07-01 managed exhibit retain the same address;
neither source establishes occupancy or facade condition.

- [March 2025 pano `CN9mis-1NnYxLSEucK7PvQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=CN9mis-1NnYxLSEucK7PvQ&heading=90.7&pitch=0&fov=75), camera `37.8303539,-122.3746228`, heading `90.7°`: exact-address view to the footprint centroid at about `18.3 m`; supports W runs `1,3–5,7`.

Written observation: cool blue-gray horizontal siding and white trim; shallow
gray roof; a deep continuous weathered flat carport canopy on slender posts;
repeated upper windows; dark blue/purple ground doors; broad lower windows;
and privacy/bin screens. Cars and the canopy occlude lower endpoints. Other
sides, exact post/opening dimensions, alterations, and occupancy are unknown.

## Recognition boundary and handoff

Minimum cue: **cool-blue W frontage behind a deep continuous flat carport,
with blue/purple entry rhythm**. Close confusion: 1234/1240/1241 Northpoint
and canopy-bearing Mariner rows. Reuse a tileable siding field and parametric
flat-canopy/post kit, but keep this W-side extent, lower solid/void rhythm, and
entry sequence local. Prototype blocker: **none for a detached W-side study**;
endpoint placement still needs receiver-relative preflight. No panorama pixels
are retained.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
