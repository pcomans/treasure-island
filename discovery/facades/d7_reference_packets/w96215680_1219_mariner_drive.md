# D7 source packet — 1219 Mariner Drive (`w96215680`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215680`, v5, `2018-01-25T19:29:07Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1219`, `addr:street=Mariner Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215680` / `building:w96215680:wall` / `building:w96215680:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `490.109 m²`; height `6 m`; NAVD88 base/top `2.836 / 8.836 m` |
| Perimeter | serialized `115.713 m`; visible `115.712 m`; `26` runs |
| Facing-run partition | N `3.4–3.6°`: `0–2,4–8,11–13`; E `93.2–93.5°`: `9–10,21,24–25`; S `183.5–183.6°`: `16–17,19–20,22–23`; W `273.5–273.6°`: `3,14–15,18` |
| Source / wall geometry SHA-256 | `3e641df120a61af61bd88fe7cb82ff9babc6564554a2f727c311e4f0c7004f57` / `244dde9453bd4d4a66234323ca5ef31c76e112f1df480f78e95023152ee5889a` |
| Registry record / chunk SHA-256 | `ebbb2cd86e8ae74e20f35817ea6cbad4a5ea0d882ed65fc12ba140f45b8455f6` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483620 / 725411` identify `1219 MARINER DR` on
parcel `1939001`, current in that dataset on 2026-09-03. The 2015 Navy table
and TIDA managed-premises exhibit as of 2025-07-01 retain the same address.
Neither establishes occupancy or an unchanged exterior.

- [March 2025 pano `zpNL8pV7Qx4cwOba6sKnhg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=zpNL8pV7Qx4cwOba6sKnhg&heading=6.9&pitch=0&fov=75), camera `37.8291157,-122.3746345`, heading `6.9°`: direct centroid ray at about `18.0 m`; supports S runs `16–17,19–20,22–23`.

Written observation: a full pale off-white horizontal-sided two-storey row;
white trim; shallow gray roof; blue ground doors; repeated broad upper
windows; privacy elements; no deep front canopy; and a slight plane step near
one end. Exact opening endpoints, other sides, alterations, and occupancy are
unknown.

## Recognition boundary and handoff

Minimum cue: **pale S frontage with blue-door rhythm, broad upper openings,
one subtle end step, and no canopy**. Close confusion: 1212/1221 Mariner and
canopy-free Bayside/Northpoint rows. Share tileable siding, trim, glass, and
roof fields; keep this S-side step, door/window cadence, and canopy absence
local. Prototype blocker: **none for a detached S-side study**. No panorama
pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
