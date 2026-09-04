# D9 source packet — 1242 Northpoint Drive (`w96665916`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665916`, v5, `2020-05-26T19:59:19Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1242`, `addr:street=Northpoint Drive`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665916` / `building:w96665916:wall` / `building:w96665916:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-3` |
| Mass | area `490.229 m²`; height `6 m`; NAVD88 base/top `2.987 / 8.987 m` |
| Perimeter | serialized `115.714 m`; visible `115.714 m`; `26` runs |
| Facing-run partition | ENE `75.4°`: `0–2,4–5,7`; SSE `165.3–165.7°`: `6,20,24–25`; WSW `255.4–255.5°`: `10–13,15–19,21–23`; NNW `345.3–345.4°`: `3,8–9,14` |
| Source / wall geometry SHA-256 | `b5fb5072734c40e12d8975d097975bbb6ca8ac795276eaa09b18096a46e84a79` / `1e45ae64887ac0c68a006fe0f3a6562c76fe47a8f6b3e3249f4fe2548eb070cf` |
| Registry record / chunk SHA-256 | `51aaa55be3f3cbfd3b5066ced17ae6c2739c0bf51de1da411fa6b671c7a9d0d3` / `d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483519 / 725297`, point `37.8306038,-122.3729491` identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. That administrative row does not prove tenancy, legal status, survival after the panorama date, or an unchanged facade.

- [March 2025 pano `e8g22JYDxfjmZNnenrUeVQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=e8g22JYDxfjmZNnenrUeVQ&heading=240.4&pitch=0&fov=75), camera `37.8306855,-122.3727385`, direct centroid ray `240.4°` at about `18.5 m`: supports the ENE-facing family. The provider's 1241 Northpoint label is a neighbor and is excluded from target identity.

Written observation: a long two-storey light blue-gray horizontal-sided frontage with a shallow gray roof, repeated white-trimmed upper windows, and a deep continuous flat parking canopy. Beneath it, blue doors and gray-blue privacy/mailbox boxes establish the lower rhythm.

## Recognition boundary and handoff

Minimum cue: **long light-blue-gray ENE row, repeated upper windows, deep flat canopy, and blue-door/privacy-box rhythm**. Close confusion: 1237/1238/1240/1241/1244 Northpoint and other canopy-bearing Site 12 rows. Share the pale siding/trim/roof family and parametric flat-canopy, door, and privacy-box modules; keep canopy extent, post rhythm, and ENE opening cadence local. Prototype/component blocker: **none for a detached ENE-side study; vehicle-covered lower endpoints still need receiver-relative matching**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).
