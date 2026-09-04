# D7 source packet — 1221 Mariner Drive (`w96215682`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215682`, v5, `2018-01-25T19:29:08Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1221`, `addr:street=Mariner Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215682` / `building:w96215682:wall` / `building:w96215682:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `490.288 m²`; height `6 m`; NAVD88 base/top `2.756 / 8.756 m` |
| Perimeter | serialized `115.732 m`; visible `115.731 m`; `26` runs |
| Facing-run partition | N `3.4–3.6°`: `0–2,4–6,9–12`; E `93.5–93.6°`: `7–8,20,23–25`; S `183.5–183.6°`: `15–17,19,21–22`; W `273.6°`: `3,13–14,18` |
| Source / wall geometry SHA-256 | `d3da61d647291dda50883a10135a1dc80f3edf074d13c7df126dd9ec5cf92d71` / `89fb9b03463d3c5663aeb1211f44c397557adfac4be440f898ec4dc63a0bee82` |
| Registry record / chunk SHA-256 | `0c88ec287fddf384f35c579b27ca36ae5b20dde18f90708f52ad786053dd0f77` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483621 / 725412` identify `1221 MARINER DR` on
parcel `1939001`, current in that dataset on 2026-09-03. The Navy's 2015 Site
12 table and TIDA's managed exhibit as of 2025-07-01 retain the address; these
administrative facts do not prove present tenancy or exterior condition.

- [March 2025 pano `QIOIKR9xX8irMgjVK2ct6w`](https://www.google.com/maps/@?api=1&map_action=pano&pano=QIOIKR9xX8irMgjVK2ct6w&heading=15.9&pitch=0&fov=75), camera `37.8290912,-122.3740580`, heading `15.9°`: direct centroid ray at about `18.7 m`; supports S runs `15–17,19,21–22`.

Written observation: a pale horizontal-sided two-storey row with white trim,
shallow gray roof, repeated upper openings, maroon ground doors, lower windows
and screens, all behind a deep flat carport canopy on slim posts. Vehicles and
the canopy obscure lower endpoints. Other sides, exact post/opening cadence,
alterations, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **pale S row behind a deep flat canopy, with maroon entry rhythm**.
Close confusion: 1219/1223 Mariner and canopy-bearing Northpoint rows. Share
tileable siding/trim/roof and a parametric canopy/post kit; keep this target's
S-side canopy extent, step pattern, and entry/window schedule local. Prototype
blocker: **none for a detached S-side study**; receiver-relative endpoint
preflight remains required. No panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
