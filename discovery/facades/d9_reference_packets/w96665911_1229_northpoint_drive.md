# D9 source packet — 1229 Northpoint Drive (`w96665911`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665911`, v6, `2020-05-26T19:59:19Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1229`, `addr:street=Northpoint Drive`, `building=abandoned`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665911` / `building:w96665911:wall` / `building:w96665911:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-4` |
| Mass | area `461.949 m²`; height `6 m`; NAVD88 base/top `2.044 / 8.044 m` |
| Perimeter | serialized `109.096 m`; visible `109.099 m`; `12` runs |
| Facing-run partition | NNE `18.8–19.4°`: `0–1,3`; ESE `109.1°`: `10–11`; SSW `199.1–199.8°`: `7,9`; WNW `289.1–289.4°`: `2,4–6,8` |
| Source / wall geometry SHA-256 | `31aeb1fdf61d7a144f25895a8403d38d2c01a974053b30ed78e18c7d2b73d23c` / `f9d50e87883dbdb932fdad45ed488b1d84054a786aa6ab373b7b383f520a199e` |
| Registry record / chunk SHA-256 | `a1d4fb715a2671ebab6513e2580e1182948dacb508118c3e518e38bc5c004b77` / `932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

The frozen lifecycle tag is `building=abandoned`; the March 2025 panorama shows the shell present but does not establish legal status, safety, or occupancy. `CITY-EAS` base/address IDs `483505 / 725283`, point `37.8309894,-122.3748213`, identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. The address row does not supersede the lifecycle caveat.

- [March 2025 pano `GxcnlVI-FBbf7iCwGCcjOg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=GxcnlVI-FBbf7iCwGCcjOg&heading=277.4&pitch=0&fov=75), camera `37.8311651,-122.3745235`, direct centroid ray `277.4°` at about `21.2 m`: supports the ESE-facing family. The provider label matches 1229 Northpoint Drive.

Written observation: a present two-storey pale-gray horizontal-sided row with a shallow gabled end, gray roof, repeated upper and ground openings along the long side, visible surface weathering, and a low flat-roof utility enclosure attached at the end. Some openings appear closed or boarded.

## Recognition boundary and handoff

Minimum cue: **weathered pale-gray gable end, long repeated side cadence, and low end utility enclosure**. Close confusion: 1232/1237/1238/1240/1241/1242 Northpoint and other pale Site 12 rows. Share pale siding, roof, trim, window, door, board-up, and utility-enclosure modules; keep the gable/end-annex silhouette and weathering distribution local. Prototype/component blocker: **none for a detached ESE-side study; the frozen `building=abandoned` tag and observed closures do not authorize an occupancy claim**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).
