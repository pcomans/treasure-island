# D9 source packet — 1237 Northpoint Drive (`w96665904`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665904`, v6, `2021-03-29T07:50:30Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1237`, `addr:street=Northpoint Drive`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665904` / `building:w96665904:wall` / `building:w96665904:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-4` |
| Mass | area `490.449 m²`; height `6 m`; NAVD88 base/top `2.846 / 8.846 m` |
| Perimeter | serialized `115.822 m`; visible `115.822 m`; `27` runs |
| Facing-run partition | NE `50.5–51.4°`: `0–2,4–7,9–13`; SE `140.6–141.5°`: `8,23,26`; SW `230.7–231.1°`: `15–17,20–22,24–25`; NW `320.9–322.8°`: `3,14,18–19` |
| Source / wall geometry SHA-256 | `ba85d87a9e2f2706d56ebf3f2713a479b522668a36db6905d307014252349034` / `cc4180cdba574adc3df3ebf6effc5a13b32741b3fc96bff787d202f4a7dc2bae` |
| Registry record / chunk SHA-256 | `b31b3a18064e9c451c0434ffd810f10a22b1010f49aa7cf2d8f1e50b83143b32` / `bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483509 / 725287`, point `37.8316376,-122.3729437` identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. That administrative row does not prove tenancy, legal status, survival after the panorama date, or an unchanged facade.

- [March 2025 pano `q2PPHDTkZouRguJjiUUDBw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=q2PPHDTkZouRguJjiUUDBw&heading=68.0&pitch=0&fov=75), camera `37.8313930,-122.3729938`, direct centroid ray `68.0°` at about `31.2 m`: supports the SW-facing family. The provider label matches 1237 Northpoint Drive.

Written observation: a long two-storey light gray horizontal-sided frontage with a shallow gray hipped roof, white trim, a regular upper-window band, recessed maroon/brown entries, and small white/gray privacy boxes. Parked vehicles interrupt the lower-center view.

## Recognition boundary and handoff

Minimum cue: **light-gray SW frontage, shallow gray hip, regular upper-window band, and maroon/brown recessed-entry rhythm**. Close confusion: 1229/1238/1240/1241/1242 Northpoint and other Site 12 rows. Share the pragmatic tileable pale-gray siding, white trim, shallow-roof, glass, door, and privacy-box kit; keep this receiver's SW cadence and entry rhythm local. Prototype/component blocker: **none for a detached SW-side study; exact lower opening endpoints behind vehicles still require receiver-relative matching**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).
