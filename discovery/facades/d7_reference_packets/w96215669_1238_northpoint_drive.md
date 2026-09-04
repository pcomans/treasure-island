# D7 source packet — 1238 Northpoint Drive (`w96215669`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215669`, v5, `2020-05-26T19:59:19Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1238`, `addr:street=Northpoint Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists
in the source or catalog; the address is not promoted to a name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215669` / `building:w96215669:wall` / `building:w96215669:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-4` |
| Mass | area `490.141 m²`; height `6 m`; NAVD88 base/top `2.415 / 8.415 m` |
| Perimeter | serialized `115.683 m`; visible `115.683 m`; `24` runs |
| Facing-run partition | NNE `17.0°`: `0–1,3–4,6`; ESE `106.2–107.9°`: `5,16,22–23`; SSW `196.9–197.3°`: `8–11,13–15,17–21`; WNW `285.2–286.8°`: `2,7,12` |
| Source / wall geometry SHA-256 | `66faff2e89dd1706ebdf8fac4981cec33822a4a60f9ee52b1c7875889a61d0a2` / `816b58518f509379ef12f2f43ae57ceec88e1fa356f51c9d2273972090b1bcd9` |
| Registry record / chunk SHA-256 | `4dc367186a10bbe7564383798d51c68a21c2e0fb286535244b339b69fdffe753` / `bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483517 / 725295` identify `1238 NORTHPOINT DR`
on parcel `1939001`, current in that dataset on 2026-09-03.
`NAVY-SITE12-2015` lists the same address with then-provider The Villages at
Treasure Island. `TIDA-JSCO-2026` includes 1238 in the managed-premises exhibit
as of 2025-07-01. These are administrative facts, not occupancy or facade proof.

- [March 2025 pano `jbUBJGVjgf9oHvuIBdiWkg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=jbUBJGVjgf9oHvuIBdiWkg&heading=197.9&pitch=0&fov=75), camera `37.8316121,-122.3733435`, heading `197.9°`: direct geometry-centroid ray at about `25.5 m`; supports the NNE public side, runs `0–1,3–4,6`. The camera-side Google label says 1235 and is not target identity.

Written observation: a long canopy-free, cool blue-gray horizontal-sided
two-storey row; white trim; shallow gray roof; repeated broad upper windows;
dark blue ground doors and windows; short dark privacy/bin screens; and a
subtle central step/recess in the long elevation. Exact opening endpoints,
unit widths/counts, other sides, alterations, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **long blue-gray NNE row with dark-blue entry rhythm, privacy
screens, and no pronounced canopy**. Close confusion: 1235/1239/1240/1241
Northpoint and canopy-free Mariner/Bayside rows. Tileable blue-gray siding,
white trim, neutral glass, and roof fields may share the northern-housing
library; this target's NNE step, entry/privacy rhythm, and canopy absence stay
local. Prototype blocker: **none for a detached NNE-side study**. No panorama
pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
