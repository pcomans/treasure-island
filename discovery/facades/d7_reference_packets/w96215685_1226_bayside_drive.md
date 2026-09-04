# D7 source packet — 1226 Bayside Drive (`w96215685`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215685`, v5, `2018-01-25T19:29:08Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1226`, `addr:street=Bayside Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215685` / `building:w96215685:wall` / `building:w96215685:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `608.160 m²`; height `6 m`; NAVD88 base/top `2.494 / 8.494 m` |
| Perimeter | serialized `143.613 m`; visible `143.612 m`; `26` runs |
| Facing-run partition | N `0.5–1.0°`: `0,2–4,10,20`; E `90.7–91.1°`: `1,18–19,21,23–25`; S `180.5–180.9°`: `7,13,15–17,22`; W `270.7–271.0°`: `5–6,8–9,11–12,14` |
| Source / wall geometry SHA-256 | `d9fe0a11ac5506840c4fe1dbcb3e4f34ed9dd0b8d802f038ffc08560ee2c1e14` / `d7cb43ccf54d690f51252dbaf57ab4c05f3b7f896cb2095240353980e22d2697` |
| Registry record / chunk SHA-256 | `b9d385d89263dc1ce00bacf946750e15f9fb70f3c670faaa90835e67c7fa102a` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483175 / 724700` identify `1226 BAYSIDE DR` on
parcel `1939001`, current in that dataset on 2026-09-03. The Navy's 2015 Site
12 table lists then-provider Community Housing Partnership. A City-hosted
conversion overview identifies 1226 as Island Bay Homes affordable supportive
housing, and a 2023 TIDA Director's Report contains an address-specific service
item. These are dated administrative references, not present occupancy,
branding, or facade proof.

- [March 2025 pano `kOmRrzFrGO--xPmeCkOBOQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=kOmRrzFrGO--xPmeCkOBOQ&heading=256.5&pitch=0&fov=75), camera `37.8301419,-122.3754775`, heading `256.5°`: direct centroid ray at about `22.4 m`; supports E runs `1,18–19,21,23–25`.

Written observation: a long, warm-beige, stepped horizontal-sided two-storey
row with white trim, red-brown shallow roof, repeated upper windows, mixed
white/green ground doors, lower windows/screens, and shallow shed awnings over
parts of the lower elevation. The awnings are not the deep carport family.
Vehicles hide some lower endpoints; other sides, exact unit cadence,
alterations, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **long warm-beige E row with red-brown roof, stepped planes,
white/green entries, and shallow shed awnings**. Close confusion: 1205 and
other long Bayside rows. Share restrained tileable siding/trim/roof plus a
shallow-awning module; keep this target's steps, awning extents, and entry/
opening rhythm local. Prototype blocker: **none for a detached E-side study**.
No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
