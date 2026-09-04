# D7 source packet — 1205 Bayside Drive (`w96215678`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215678`, v5, `2018-01-22T18:57:19Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1205`, `addr:street=Bayside Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215678` / `building:w96215678:wall` / `building:w96215678:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-3` |
| Mass | area `474.295 m²`; height `6 m`; NAVD88 base/top `2.837 / 8.837 m` |
| Perimeter | serialized `110.129 m`; visible `110.130 m`; `16` runs |
| Facing-run partition | N `2.2–2.6°`: `0–1,4`; E `92.5°`: `12–15`; S `182.4–182.5°`: `7,9–11`; W `272.5°`: `2–3,5–6,8` |
| Source / wall geometry SHA-256 | `eb9cb787ac9af287ae5757fd8a2658316e173f1a4a466210da19b12aed7f148f` / `0d8b628de5ec8babcb9cfd86d61361842b3d2a57a47d92ef5bd701a38968f0e1` |
| Registry record / chunk SHA-256 | `fe44c3497c14fe498b7e81db32d5d676904489301948a4a223939c9ae57601af` / `7f0ecd2e16fe4327f351496ed8c2f8640d68278fbaf33d428b6314ec862d9944` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483166 / 724691` identify `1205 BAYSIDE DR` on
parcel `1939001`, current in that dataset on 2026-09-03. The Navy Site 12
table lists the address with then-provider The Villages. TIDA's official 2024
fourth amendment with Community Housing Partnership includes 1205 effective
2024-07-01. These administrative records do not prove present occupancy,
appearance, or management after their dated scopes.

- [March 2025 pano `1FhzZGQPXpHTTkkB65erpw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=1FhzZGQPXpHTTkkB65erpw&heading=264.8&pitch=0&fov=75), camera `37.8301775,-122.3769080`, heading `264.8°`: direct centroid ray at about `24.5 m`; supports E runs `12–15`.

Written observation: a warm cream horizontal-sided two-storey row with white
trim, shallow red-brown roof, green/gray ground doors, repeated upper windows,
and a long shallow horizontal awning/band over the lower openings. This band is
shallower and visually distinct from the deep carport family. Cars obscure
some lower endpoints; other sides, exact cadence, alterations, and occupancy
remain unknown.

## Recognition boundary and handoff

Minimum cue: **warm-cream E frontage with red-brown roof, green/gray entries,
and a long shallow lower awning/band**. Close confusion: 1201/1203 Bayside and
1226's shallow-awning row. Share tileable siding/trim/roof plus a generic
shallow-awning kit; preserve this target's band extent and E-side entry/window
rhythm. Prototype blocker: **none for a detached E-side study**. No panorama
pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
