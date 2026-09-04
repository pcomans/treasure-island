# D8 source packet — 1210 Mariner Drive (`w96665893`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96665893`, v5, `2018-01-25T19:29:09Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1210`, `addr:street=Mariner Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665893` / `building:w96665893:wall` / `building:w96665893:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-3` |
| Mass | area `349.426 m²`; height `6 m`; NAVD88 base/top `2.578 / 8.578 m` |
| Perimeter | serialized `86.800 m`; visible `86.799 m`; `18` runs |
| Facing-run partition | E `87.0°`: `0–1,12`; S `177.0–177.1°`: `8–11,13–17`; W `266.8–267.1°`: `4,6–7`; N `357.0–357.1°`: `2–3,5` |
| Source / wall geometry SHA-256 | `c96b73fa8dde045163a599ff15d690795421f86674987db11f0c6ababea2724f` / `a3004450a3881f63ce8475e8bc2241f9119bcaeaf8281fc934b2817116c96315` |
| Registry record / chunk SHA-256 | `5f59b69bfff15bba8596125f20a89e8731ba183926406692017ad5965fb4e5ef` / `d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483617 / 725408` identify `1210 MARINER DR` on
parcel `1939001`, current in that dataset on 2026-09-03. The official 2017
housing table records four units and 6,720 square feet, while TIDA's 2025
managed-premises exhibit retains the address. Neither record proves tenancy.

- [March 2025 pano `fxeD0MyE_l4b5gxxnpqK6Q`](https://www.google.com/maps/@?api=1&map_action=pano&pano=fxeD0MyE_l4b5gxxnpqK6Q&heading=164.3&pitch=0&fov=75), camera `37.8290704,-122.3735935`, direct centroid ray at about `21.0 m`: supports the N-facing frontage.

Written observation: a clear two-storey gray horizontal-sided front, shallow
hipped roof, repeated upper windows, green/blue/dark doors, gray privacy boxes,
and varied lower windows. The facade has no deep continuous canopy. Small
vegetation and vehicles provide local lower occlusion.

## Recognition boundary and handoff

Minimum cue: **compact gray N frontage with shallow hip, mixed-color doors,
repeated upper windows, and gray privacy boxes**. Close confusion: 1208 Mariner
and compact Keppler/Hutchins rows. Share the housing kit, but retain the mixed
door rhythm, footprint proportions, and lack of canopy. Prototype blocker:
**none for the observed N-side study; unobserved sides remain neutral**. No
panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).
