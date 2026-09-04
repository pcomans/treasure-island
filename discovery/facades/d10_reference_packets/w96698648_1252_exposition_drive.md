# D10 source packet — 1252 Exposition Drive (`w96698648`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Packet-time catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D10 packet-time registry snapshot `ti.facade-runtime-registry/4`, SHA-256 `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`. Frozen source: OSM way `w96698648`, v5, `2018-01-25T19:29:11Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1252`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96698648` / `building:w96698648:wall` / `building:w96698648:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-3` |
| Mass | area `490.219 m²`; height `6 m`; NAVD88 base/top `3.115 / 9.115 m` |
| Perimeter | serialized `115.713 m`; visible `115.713 m`; `22` runs |
| Facing-run partition | ENE `62.6°`: `0,2–3,5–7`; SSE `152.5–152.7°`: `1,14,20–21`; WSW `242.6°`: `10–13,15,17–19`; NNW `332.4–332.7°`: `4,8–9,16` |
| Source / wall geometry SHA-256 | `cd34021f34e8d73fb0332ed77d4ebbbe098e3323dde802c17de593c6f788753e` / `fdbb96bcaad7da03d8da03ec99c1ec17743393e58a6d722efa2e531c026af690` |
| Registry record / chunk SHA-256 | `87b12491d99e4d91d169ca331e8e7e631156b8f7f41db291f9c2c85ef4cf1bab` / `d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray. Facing runs are exact outward-normal partitions, not an inferred opening schedule.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483586 / 725377`, point `37.8290601,-122.3718675`, supports 1252 Exposition Drive on parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54.000`, about `3.4 m` from the centroid. The frozen way supplies house number 1252 but no street.

- [March 2025 pano `qx_9deE29P7CNgtNpldcvw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=qx_9deE29P7CNgtNpldcvw&heading=252.9&pitch=0&fov=75), camera `37.8290910,-122.3716190`, direct centroid ray `252.9°` at about `20.6 m`: supports the ENE-facing family.

Written observation: a two-storey gray horizontal-sided frontage, shallow tan/gray roof, regular upper windows, continuous deep dark flat canopy on thin posts, dark doors, and utility/privacy boxes; parked vehicles interrupt portions of the base.

## Recognition boundary and handoff

Minimum cue: **gray siding, shallow tan/gray roof, regular upper windows, and deep dark post-supported canopy**. Close confusion: 1249/1253 Exposition and Gateview deep-canopy rows. Share gray siding, roof, glazing, door, privacy-box, and parametric canopy modules; retain this ENE cadence and canopy proportion locally. Prototype/component blocker: **none for a detached ENE study; parked-vehicle intersections and exact endpoints require receiver-relative matching**. Frozen street value, hidden sides, exact obscured endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, capture/currentness caveats, packet-time/current registry split, and rights boundary: [D10 index](README.md).
