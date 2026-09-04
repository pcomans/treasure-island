# D10 source packet — 1249 Exposition Drive (`w96698643`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Packet-time catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D10 packet-time registry snapshot `ti.facade-runtime-registry/4`, SHA-256 `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`. Frozen source: OSM way `w96698643`, v5, `2018-01-25T19:29:11Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1249`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96698643` / `building:w96698643:wall` / `building:w96698643:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-3` |
| Mass | area `490.122 m²`; height `6 m`; NAVD88 base/top `3.221 / 9.221 m` |
| Perimeter | serialized `115.713 m`; visible `115.714 m`; `20` runs |
| Facing-run partition | ENE `61.9–62.0°`: `0–1,3,12–13`; SSE `151.8–151.9°`: `10–11,14–16,18–19`; WSW `241.8–242.2°`: `6,9,17`; NNW `331.8–331.9°`: `2,4–5,7–8` |
| Source / wall geometry SHA-256 | `51b0a6b87600a3a80591a367305e774c43921cbb1566adfffc9945e921ce43cd` / `7f76166d9cecf06bb557bb4b9f850ffb2cb3f4bce715024adcb52756a7bf8429` |
| Registry record / chunk SHA-256 | `0a70a23cfa4690b4948f292ccd2f0e18f1b6b4b593e92659ec93d96b098374c0` / `d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray. Facing runs are exact outward-normal partitions, not an inferred opening schedule.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483582 / 725373`, point `37.8296576,-122.3722859`, supports 1249 Exposition Drive on parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54.000`, about `25.8 m` from the centroid. The frozen way supplies house number 1249 but no street.

- [March 2025 pano `4uBsPyve1glFjTam2OWVpA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=4uBsPyve1glFjTam2OWVpA&heading=2.8&pitch=0&fov=75), camera `37.8295334,-122.3720601`, direct centroid ray `2.8°` at about `28.6 m`: supports the SSE-facing family.

Written observation: a two-storey light-gray/white horizontal-sided frontage with a shallow roof, regular upper-window band, varied dark/greenish doors, lower windows, pale/dark privacy boxes, and central tree/parked-car interruption.

## Recognition boundary and handoff

Minimum cue: **light-gray/white frontage, shallow roof, regular upper windows, and varied dark/green entry/privacy rhythm**. Close confusion: 1252/1253 Exposition and other pale Site 12 rows. Share pale siding, roof-edge, glazing, door, and privacy-box modules; preserve the varied door tones and observed SSE cadence locally. Prototype/component blocker: **none for a detached SSE study; tree/car-hidden lower endpoints require receiver-relative matching**. Frozen street value, hidden sides, exact obscured endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, capture/currentness caveats, packet-time/current registry split, and rights boundary: [D10 index](README.md).
