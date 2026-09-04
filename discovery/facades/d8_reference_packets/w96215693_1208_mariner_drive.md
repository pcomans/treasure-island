# D8 source packet — 1208 Mariner Drive (`w96215693`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215693`, v5, `2018-01-25T19:29:08Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1208`, `addr:street=Mariner Drive`,
`building=residential`, `building:levels=2`, `height=7`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215693` / `building:w96215693:wall` / `building:w96215693:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `490.339 m²`; height `7 m`; NAVD88 base/top `2.710 / 9.710 m` |
| Perimeter | serialized `115.739 m`; visible `115.737 m`; `28` runs |
| Facing-run partition | N `3.8–3.9°`: `0–1,3–4,6–7`; E `93.6–93.9°`: `2,14,25–27`; S `183.8–184.0°`: `9–13,15–17,20–24`; W `273.9–274.0°`: `5,8,18–19` |
| Source / wall geometry SHA-256 | `5b8440aba065da92d678273dd951323ec53702acee9301ae6fadda2c2391c1ca` / `d0ee03c446e6a7b313be6718b038825fe1591578cabad50579141ff55c722aba` |
| Registry record / chunk SHA-256 | `a451772ec987e9bf49095f3c60e776b091f2330898cf1f4b9cf6d064caaf3978` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483616 / 725407` identify `1208 MARINER DR` on
parcel `1939001`, current in that dataset on 2026-09-03. `TIDA-JSCO-2026`
retains the address in its managed-premises exhibit as of 2025-07-01. Those
administrative records do not prove tenancy or an unchanged exterior.

- [March 2025 pano `QIOIKR9xX8irMgjVK2ct6w`](https://www.google.com/maps/@?api=1&map_action=pano&pano=QIOIKR9xX8irMgjVK2ct6w&heading=171.6&pitch=0&fov=75), camera `37.8290912,-122.3740580`, direct centroid ray at about `21.4 m`: supports the N-facing family.

Written observation: a full two-storey pale blue-gray horizontal-sided front,
white trim, shallow gray hipped roof, repeated upper windows, ground entries
and windows, and no deep canopy. Vehicles obscure parts of the lower band.
Exact opening endpoints, unobserved sides, alterations, and occupancy remain
unknown.

## Recognition boundary and handoff

Minimum cue: **pale blue-gray N frontage, shallow gray hip, repeated upper
windows, and no canopy**. Close confusion: 1206/1210 Mariner and nearby
Gateview rows. Reuse the restrained siding, trim, roof, glass, and door
families, but keep this footprint's N cadence and canopy absence local.
Prototype blocker: **none for a detached N-side study; lower modules still need
receiver-relative photo matching around vehicle occlusion**. No panorama pixels
are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).
