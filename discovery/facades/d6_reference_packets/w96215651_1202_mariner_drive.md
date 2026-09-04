# D6 source packet — 1202 Mariner Drive (`w96215651`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; camera-side label caveat retained**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215651`, v5,
`2018-01-25T19:29:04Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1202`, `addr:street=Mariner Drive`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the address is identity evidence, not an invented building name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215651` / `building:w96215651:wall` / `building:w96215651:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `490.135 m²`; height `6 m`; NAVD88 base/top `2.459 / 8.459 m` |
| Perimeter | serialized `115.712 m`; visible `115.711 m`; `26` runs |
| Facing-run partition | WSW `238.8°`: `0–1,3–5,7`; NNW `328.8–328.9°`: `2,15,24–25`; SSE `148.6–148.9°`: `6,8–9,20`; ENE `58.7–58.9°`: `10–14,16–19,21–23` |
| Source / wall geometry SHA-256 | `0509239b444322431a9620b44dbc6b84459cdc6e35237373977ed607de83e925` / `380209e51da7573526b01561ce09f2842a62625608ea60383ecba166d8dc3a97` |
| Registry record / chunk SHA-256 | `5e0a96af672400a9dbe0cc6cc912df1c72acb0c651285b22f8ea790a8726a4a2` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483613` is `1202 MARINER DR`, address ID `725404`,
parcel `1939001`, point `37.8293412,-122.3756581`, current in that dataset
on 2026-09-03. 1202 is absent from the `TIDA-JSCO-2026` premises exhibit;
absence is not demolition, vacancy, or appearance evidence.

- [March 2025 pano `iRZgfjq7elflbb6FRkLYgw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=iRZgfjq7elflbb6FRkLYgw&heading=207.3&pitch=0&fov=75), camera `37.8294799,-122.3754769`, heading `207.3°`: the ray reaches the frozen footprint centroid at about `23.5 m` and principally exposes the ENE long family `10–14,16–19,21–23` plus NNW-end context. Google's 1217 label belongs to the camera-side row and is not used as target identity.

Written observation: long two-storey pale cool-gray horizontal-sided row;
white trim; shallow muted brown-gray roof; continuous deep flat carport canopy
on slender weathered posts; repeated upper sliders; ground windows/doors and
blue-gray privacy/bin enclosures partly hidden by vehicles. Exact bay count,
opening endpoints, post spacing, other sides, alterations, and occupancy remain
unknown.

## Recognition boundary and handoff

Minimum cue: **the long pale Mariner row under one continuous deep flat canopy,
with the canopy/posts dominating the lower silhouette**. Close confusion: 1234
Northpoint, 1215 Bayside, and 1248/1395 Gateview. Reuse tileable siding, trim,
roof, glass, and a parametrically sized flat-canopy component, but keep 1202's
ENE solid/void rhythm, canopy extent, privacy pieces, and orientation local.
Prototype blocker: **none for a detached ENE-side study**; receiver-relative
endpoints and an unobscured lower schedule are still required before live
placement. No panorama pixels are retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
