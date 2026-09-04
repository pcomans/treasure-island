# D9 source packet — 1149 Ozbourn Court (`w96665909`)

Checked: **2026-09-04**  
Readiness: **target-side historical prototype-ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665909`, v5, `2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1149`, `addr:street=Ozbourn Court`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665909` / `building:w96665909:wall` / `building:w96665909:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `275.148 m²`; height `6 m`; NAVD88 base/top `2.383 / 8.383 m` |
| Perimeter | serialized `79.073 m`; visible `79.073 m`; `8` runs |
| Facing-run partition | NE `34.8°`: `0–2`; SE `124.8°`: `7`; SW `214.8°`: `5–6`; NW `304.8°`: `3–4` |
| Source / wall geometry SHA-256 | `faa7aaf5b488c33a5ba17baebf8a7820bf4221c3d185be4e23e167d272c52ed6` / `d1c68c1a7208e5c560bd9ac69b45086174cbdd3e45c1d3453cfe22aded20115f` |
| Registry record / chunk SHA-256 | `3d3f173d5ee6fcdeb43e7fc4ae1557672ddd585c44a0f34210ec4f6ddba1c602` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483612 / 725403`, point `37.8293115,-122.3767632` identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. That administrative row does not prove tenancy, legal status, survival after the panorama date, or an unchanged facade.

- [April 2019 pano `n93IglgyTqGTKr0ywhxjig`](https://www.google.com/maps/@?api=1&map_action=pano&pano=n93IglgyTqGTKr0ywhxjig&heading=313.5&pitch=0&fov=75), camera `37.8293875,-122.3772764`, direct centroid ray `313.5°` at about `31.5 m`: supports the SE-facing family. The provider's 1141 Ozbourn label is a neighbor and is excluded from target identity.

Written observation: a compact two-storey light gray horizontal-sided frontage with a nearly hidden shallow roof edge, paired and single white-trimmed upper windows, a conspicuous yellow entry, and shrub-separated ground bays. Trees obscure the left end.

## Recognition boundary and handoff

Minimum cue: **compact light-gray SE frontage, shallow roof edge, asymmetric upper-window groups, and yellow entry**. Close confusion: 1141/1143/1145/1147 Ozbourn and other yellow-accent Site 12 units. Share gray siding, trim, glass, shallow-roof, yellow-door, and shrub-neutral modules; keep this compact width and asymmetric window grouping entity-specific. Prototype/component blocker: **none for a detached historical SE-side study; the tree-hidden left endpoint must stay unresolved until receiver-relative preflight**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).
