# D9 source packet — 1110 Hutchins Court (`w96665910`)

Checked: **2026-09-04**  
Readiness: **component/side-material-and-window study ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665910`, v4, `2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1110`, `addr:street=Hutchins Court`, `building=yes`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665910` / `building:w96665910:wall` / `building:w96665910:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `306.768 m²`; height `6 m`; NAVD88 base/top `2.341 / 8.341 m` |
| Perimeter | serialized `77.772 m`; visible `77.771 m`; `10` runs |
| Facing-run partition | NNE `16.9°`: `0–3`; ESE `106.9°`: `9`; SSW `196.9°`: `7–8`; WNW `286.9°`: `4–6` |
| Source / wall geometry SHA-256 | `09f68d767842d78e2d6049eba55173e7c1187c1b7179438d249acea1a51cf8ed` / `4c61628231975166511d6069a78605be023f6eed90bc22cb8673f04a44399d7f` |
| Registry record / chunk SHA-256 | `085e0553c06c40aa29a7fba0ef0df1068e392e763ea75b7d542d786b9407abc6` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483623 / 725414`, point `37.8281146,-122.3762294` identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. That administrative row does not prove tenancy, legal status, survival after the panorama date, or an unchanged facade.

- [February 2018 pano `0mcdi2-xL08UtW0ykeUp3w`](https://www.google.com/maps/@?api=1&map_action=pano&pano=0mcdi2-xL08UtW0ykeUp3w&heading=93.2&pitch=0&fov=75), camera `37.8281670,-122.3764100`, direct centroid ray `93.2°` at about `39.9 m`: supports the WNW-facing family. The provider's 1112 Hutchins label is a neighbor and is excluded from target identity.

Written observation: only WNW-side fragments are attributable: gray horizontal siding, white-trimmed upper windows, a shallow gray roof edge, and a dark blue entry/privacy element. A tree, lamp standard, utility boxes, and parked vehicles prevent a complete target-side reading.

## Recognition boundary and handoff

Minimum cue: **gray WNW siding, white upper-window trim, shallow roof edge, and dark-blue entry/privacy fragment**. Close confusion: 1112/1114/1116/1118 Hutchins and adjacent Mason rows. Authorize the shared siding, trim, window, roof-edge, and blue-entry components only; do not transfer the white row across the parking court or invent hidden cadence. Prototype/component blocker: **the complete WNW facade is blocked by tree, pole, utility, and vehicle occlusion; only observed material/window/entry components are ready**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).
