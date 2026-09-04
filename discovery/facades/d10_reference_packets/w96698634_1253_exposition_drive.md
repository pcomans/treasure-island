# D10 source packet — 1253 Exposition Drive (`w96698634`)

Checked: **2026-09-04**  
Readiness: **component/upper-side-and-boarded-opening study ready**

Packet-time catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D10 packet-time registry snapshot `ti.facade-runtime-registry/4`, SHA-256 `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`. Frozen source: OSM way `w96698634`, v5, `2018-01-22T18:58:54Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1253`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96698634` / `building:w96698634:wall` / `building:w96698634:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-3` |
| Mass | area `490.069 m²`; height `6 m`; NAVD88 base/top `3.288 / 9.288 m` |
| Perimeter | serialized `115.706 m`; visible `115.708 m`; `22` runs |
| Facing-run partition | ENE `61.7–61.8°`: `0–1,3–5,7–8`; SSE `151.8–151.9°`: `6,15,20–21`; WSW `241.7–241.8°`: `10–11,13–14,16–19`; NNW `331.6–331.8°`: `2,9,12` |
| Source / wall geometry SHA-256 | `91b11f3c953481ae03035072335d5724212e5d4d55dca7d99d082ed411f4d68e` / `f6e6ca7b6c3be15fcb7fd19c7b59cb318fbcde2f4792e211ca52611f80508f8b` |
| Registry record / chunk SHA-256 | `f01536b10dc7554bb94a748eb305fa8f0da09b01f076af5eec719a3a8d416289` / `d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray. Facing runs are exact outward-normal partitions, not an inferred opening schedule.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483584 / 725375`, point `37.8289881,-122.3713954`, supports 1253 Exposition Drive on parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54.000`, about `8.9 m` from the centroid. The frozen way supplies house number 1253 but no street.

- [September 2025 pano `BnT497okiFGQ5f5ppVNNoA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=BnT497okiFGQ5f5ppVNNoA&heading=255.2&pitch=0&fov=75), camera `37.8290747,-122.3711024`, direct centroid ray `255.2°` at about `18.8 m`: supports the ENE-facing family.

Written observation: gray horizontal siding across a two-storey long side, a shallow gray roof, a regular upper-window band, and partly boarded lower windows. A wood fence and vehicle obscure the base and lower cadence.

## Recognition boundary and handoff

Minimum cue: **gray horizontal siding, shallow gray roof, regular upper-window band, and partial lower boarding**. Close confusion: 1249/1252 Exposition and other gray Site 12 rows. Share the gray siding, roof, window, and boarding components; authorize only the observed upper-side/boarding subset for 1253. Prototype/component blocker: **a complete target-side prototype remains blocked because fence and vehicle occlusion hide the base, entries, and lower schedule**. Street identity in frozen data, complete lower cadence, hidden runs, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, capture/currentness caveats, packet-time/current registry split, and rights boundary: [D10 index](README.md).
