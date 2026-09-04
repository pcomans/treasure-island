# D7 source packet — 1206 Mariner Drive (`w96215677`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215677`, v5, `2018-01-25T19:29:07Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1206`, `addr:street=Mariner Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215677` / `building:w96215677:wall` / `building:w96215677:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `490.167 m²`; height `6 m`; NAVD88 base/top `2.877 / 8.877 m` |
| Perimeter | serialized `115.721 m`; visible `115.719 m`; `26` runs |
| Facing-run partition | N `3.5–3.6°`: `0–1,3–4,6–7`; E `93.5–93.6°`: `5,20,24–25`; S `183.4–183.6°`: `11–13,15–19,21–23`; W `273.2–273.5°`: `2,8–10,14` |
| Source / wall geometry SHA-256 | `f7eed3823d34b979c36d4f32d3d19cb3e5e12e600723b245dd3250cbfacae739` / `8a1555b5c5ce3b19eb79e3ec6661064c3a50b5852b36f254000be632d99da9c2` |
| Registry record / chunk SHA-256 | `9c00b984071877bb677b5e69cea09cf96f44169510e0d06140453482e43b1381` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483615 / 725406` identify `1206 MARINER DR` on
parcel `1939001`, current in that dataset on 2026-09-03. The Navy's 2015
Site 12 table lists then-provider Catholic Charities, while TIDA's managed
exhibit as of 2025-07-01 retains the address. Neither proves occupancy or
unchanged exterior condition.

- [March 2025 pano `zpNL8pV7Qx4cwOba6sKnhg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=zpNL8pV7Qx4cwOba6sKnhg&heading=171.0&pitch=0&fov=75), camera `37.8291157,-122.3746345`, heading `171.0°`: direct centroid ray at about `23.1 m`; supports N runs `0–1,3–4,6–7`.

Written observation: a full warm, weathered gray/cream two-storey horizontal-
sided row; white trim; shallow red-brown roof; green doors; repeated but
slightly irregular upper-window groups; ground windows and privacy elements;
and no deep front canopy. Exact opening endpoints, other sides, alterations,
and occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **weathered cream N frontage with a red-brown roof, green-door
rhythm, irregular upper windows, and no canopy**. Close confusion: 1204/1208
Mariner and 1141/1143 Ozbourn. Share restrained siding, trim, roof, and door
families; keep this N-side irregular cadence and canopy absence local. Prototype
blocker: **none for a detached N-side study**. No panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
