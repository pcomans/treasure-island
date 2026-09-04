# D9 source packet — 1147 Ozbourn Court (`w96665906`)

Checked: **2026-09-04**  
Readiness: **target-side historical prototype-ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665906`, v5, `2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1147`, `addr:street=Ozbourn Court`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665906` / `building:w96665906:wall` / `building:w96665906:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-3` |
| Mass | area `662.138 m²`; height `6 m`; NAVD88 base/top `2.506 / 8.506 m` |
| Perimeter | serialized `143.395 m`; visible `143.394 m`; `22` runs |
| Facing-run partition | NE `34.1°`: `0,2–6`; SE `124.1–124.2°`: `16–17,20–21`; SW `214.2°`: `9–11,13–15,18–19`; NW `304.2°`: `1,7–8,12` |
| Source / wall geometry SHA-256 | `79d24d2ce2933d5f39983f500f915260d3defec4e438140ccdb75d36765287ec` / `ce075525cc912107a2b0de484240142ee22efcfeb46820a1a1690bcf9330adbe` |
| Registry record / chunk SHA-256 | `c6b5a5dee8ae2b2b4dc0e9f1f5d313d4f4146be58a8d57a8790d2cec44f3e359` / `7f0ecd2e16fe4327f351496ed8c2f8640d68278fbaf33d428b6314ec862d9944` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483611 / 725402`, point `37.8295531,-122.3771280` identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. That administrative row does not prove tenancy, legal status, survival after the panorama date, or an unchanged facade.

- [April 2019 pano `1FzI-ZOk68OdMoEVAh0KqQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=1FzI-ZOk68OdMoEVAh0KqQ&heading=33.1&pitch=0&fov=75), camera `37.8293887,-122.3772222`, direct centroid ray `33.1°` at about `20.9 m`: supports the SW-facing family. The provider's 1141 Ozbourn label is a neighbor and is excluded from target identity.

Written observation: a long two-storey gray horizontal-sided row with a red-brown shallow hipped roof, repeated white-trimmed upper windows, and blue-gray ground privacy/service enclosures. Dense parked cars hide much of the lower frontage.

## Recognition boundary and handoff

Minimum cue: **long gray SW row, red-brown shallow hip, repeated upper-window cadence, and blue-gray lower enclosures**. Close confusion: 1141/1143/1145/1149 Ozbourn and other long Site 12 rows. Share the gray-siding, red-brown roof, trim, glass, and privacy-box kit; preserve this footprint length and upper cadence rather than borrowing a neighbor's lower schedule. Prototype/component blocker: **none for a detached historical mass/upper-and-enclosure study; parked-car occlusion blocks an exact lower opening schedule**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).
