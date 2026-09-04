# D8 source packet — 1112 Hutchins Court (`w96665897`)

Checked: **2026-09-04**  
Readiness: **target-side historical prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96665897`, v5, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1112`, `addr:street=Hutchins Court`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665897` / `building:w96665897:wall` / `building:w96665897:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `275.084 m²`; height `6 m`; NAVD88 base/top `2.586 / 8.586 m` |
| Perimeter | serialized `79.073 m`; visible `79.072 m`; `10` runs |
| Facing-run partition | NNE `16.5°`: `0–3`; ESE `106.6°`: `9`; SSW `196.5°`: `6–8`; WNW `286.6°`: `4–5` |
| Source / wall geometry SHA-256 | `7e4f94cf512ba1eb7a503a3afbcc14bbbbd79fae5100c46a982c8e7c43a36fa5` / `68c36015dbd83016aea330f0e768d20dfab8116d6bbd2bb8b4a9b71cb69fd4c7` |
| Registry record / chunk SHA-256 | `a1bb69969155be462202668ba5af7ccde24507c1c554b64934f99c7173243b73` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483624 / 725415` identify `1112 HUTCHINS CT` on
parcel `1939001`, current in that dataset on 2026-09-03. The official 2017
housing table records four units and 4,992 square feet; administrative presence
does not prove present survival or unchanged appearance.

- [April 2019 pano `16r0WAQn8IKkPumWKcuXiw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=16r0WAQn8IKkPumWKcuXiw&heading=20.2&pitch=0&fov=72), camera `37.8282132,-122.3764836`, direct centroid ray at about `19.2 m`: supports the historical SSW-facing front. The provider's `1168 Hutchins` label is excluded.

Written observation: a clear compact two-storey gray horizontal-sided front,
near-flat/shallow roof, repeated upper windows, blue doors, slate-blue privacy
boxes, lower windows, and shrubs. The door/box colors and condition are dated
2019 observations.

## Recognition boundary and handoff

Minimum cue: **compact gray Hutchins front with blue-door rhythm, slate-blue
privacy boxes, repeated upper windows, and a very shallow roof**. Close confusion:
1118 Hutchins and 1111 Keppler. Share the Site 12 base kit, but keep
this SSW cadence and dated blue accents local. Prototype blocker: **none for a
detached historical SSW-side study; current color/condition need later
confirmation**. No panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).
