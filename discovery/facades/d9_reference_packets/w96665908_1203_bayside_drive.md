# D9 source packet — 1203 Bayside Drive (`w96665908`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665908`, v5, `2018-01-22T18:57:19Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1203`, `addr:street=Bayside Drive`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665908` / `building:w96665908:wall` / `building:w96665908:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-3` |
| Mass | area `305.957 m²`; height `6 m`; NAVD88 base/top `2.410 / 8.410 m` |
| Perimeter | serialized `81.810 m`; visible `81.810 m`; `16` runs |
| Facing-run partition | NE `34.3°`: `0–2,4–5`; SE `123.9–124.3°`: `12,15`; SW `214.3°`: `9–11,13–14`; NW `304.2–304.3°`: `3,6–8` |
| Source / wall geometry SHA-256 | `db08030498a3812e7b4b0d8a50e50468c7105cfe0ac83e3ae01ffcc7eaa358a9` / `65d8fcb93d8de43d229d40a7d0dd19c1da6b8eb09d53feed8db0dd1f80ea5b7c` |
| Registry record / chunk SHA-256 | `cb63011175d6ad4d1396c4ddbbb9af5e1cbfb1537ec59c575d70ac61484d2efa` / `7f0ecd2e16fe4327f351496ed8c2f8640d68278fbaf33d428b6314ec862d9944` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483165 / 724690`, point `37.8296968,-122.3767585` identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. That administrative row does not prove tenancy, legal status, survival after the panorama date, or an unchanged facade.

- [March 2025 pano `_LPgneeA72ykO2t85rdQbw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=_LPgneeA72ykO2t85rdQbw&heading=326.4&pitch=0&fov=75), camera `37.8295603,-122.3761321`, direct centroid ray `326.4°` at about `2.7 m`: supports the SE-facing family. The provider's 1220 Bayside label is a neighbor and is excluded from target identity.

Written observation: a compact two-storey pale blue-gray horizontal-sided block with a shallow gable, white corner/roof trim, repeated upper windows, blue privacy screens, and a recessed entry run. The very near camera exposes the end and a substantial long-side fragment but not a single orthographic elevation.

## Recognition boundary and handoff

Minimum cue: **compact pale-blue-gray block, shallow gable end, repeated upper windows, and blue screened entry run**. Close confusion: 1201/1205/1220/1226 Bayside and nearby gray Site 12 blocks. Share pale siding, white trim, glass, door, and privacy-screen modules; preserve the compact footprint, gable end, and observed SE corner organization. Prototype/component blocker: **none for a detached observed-corner study; exact far-end and hidden-side schedules remain intentionally unresolved**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).
