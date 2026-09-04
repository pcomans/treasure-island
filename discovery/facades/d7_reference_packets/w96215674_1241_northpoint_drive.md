# D7 source packet — 1241 Northpoint Drive (`w96215674`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215674`, v5, `2020-05-26T19:59:19Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1241`, `addr:street=Northpoint Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215674` / `building:w96215674:wall` / `building:w96215674:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-3` |
| Mass | area `489.360 m²`; height `6 m`; NAVD88 base/top `3.287 / 9.287 m` |
| Perimeter | serialized `115.778 m`; visible `115.778 m`; `26` runs |
| Facing-run partition | ENE `75.5–76.2°`: `0–3,5–8,10–12`; SSE `165.8–166.5°`: `4,18,25`; WSW `255.8–256.0°`: `16–17,19,22–24`; NNW `345.8–346.3°`: `9,13–15,20–21` |
| Source / wall geometry SHA-256 | `e384b1fc1af7e200a8044de8f954b9f24bca792bc0a924df03896292b72f7b36` / `8f7196b54525079fd587948a5d701bfcbd88252e4f09fdb14ae10b6e1605ed38` |
| Registry record / chunk SHA-256 | `03e265258e8444f126bd5b24bc23e8bbfdd921eb6fc2a5a9f2fea8efc939550f` / `d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483511 / 725289` identify `1241 NORTHPOINT DR`
on parcel `1939001`, current in that dataset on 2026-09-03. The Navy's 2015
Site 12 table and TIDA's managed-premises exhibit as of 2025-07-01 retain the
address. Those records do not establish occupancy or an unchanged facade.

- [March 2025 pano `lEEdGbebSdNEwLiMiCCw0g`](https://www.google.com/maps/@?api=1&map_action=pano&pano=lEEdGbebSdNEwLiMiCCw0g&heading=64.8&pitch=0&fov=75), camera `37.8305098,-122.3726894`, heading `64.8°`: direct centroid ray at about `20.8 m`; supports WSW runs `16–17,19,22–24`.

Written observation: a long pale-gray two-storey horizontal-sided row with
white trim, shallow gray roof, repeated upper windows, maroon ground doors,
privacy screens, and a deep continuous flat carport on slender posts. Vehicles
and the canopy hide lower endpoints. Other sides, exact opening/post cadence,
alterations, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **pale-gray WSW row behind a deep continuous flat canopy, with
maroon entry rhythm**. Close confusion: 1239/1240/1242 Northpoint and other
canopy-bearing Site 12 rows. Share tileable siding/trim/roof and a parametric
flat-canopy kit; keep this target's canopy extent, plane steps, entry/privacy
rhythm, and solid/void schedule local. Prototype blocker: **none for a detached
WSW-side study**. No panorama pixels are retained or proposed as textures.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
