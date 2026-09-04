# D8 source packet — 1118 Hutchins Court (`w96665885`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96665885`, v5, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1118`, `addr:street=Hutchins Court`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665885` / `building:w96665885:wall` / `building:w96665885:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `306.747 m²`; height `6 m`; NAVD88 base/top `2.351 / 8.351 m` |
| Perimeter | serialized `77.780 m`; visible `77.779 m`; `12` runs |
| Facing-run partition | NNE `16.7°`: `0–2`; ESE `106.7°`: `8–11`; SSW `196.7°`: `5–7`; WNW `286.8°`: `3–4` |
| Source / wall geometry SHA-256 | `12fcda294fec8b880ee297d180fcf66c67010ccc6d20e15932ab46916df72e64` / `b9eb932bc7867e0b75114bcb56d8275d3a21fa2623518e99ce983f57f0d33e1a` |
| Registry record / chunk SHA-256 | `5a9a98be3aa91aedaf42cb41b831e0044de9725881d04819b914000e12301db2` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483627 / 725418` identify `1118 HUTCHINS CT` on
parcel `1939001`, current in that dataset on 2026-09-03. The official 2017
housing table records a four-unit, 5,160-square-foot building, and TIDA's 2025
managed-premises exhibit retains the address; neither proves occupancy.

- [March 2025 pano `IQowSpymm28bKk6dmERCJA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=IQowSpymm28bKk6dmERCJA&heading=27.9&pitch=0&fov=72), camera `37.8279020,-122.3767655`, direct centroid ray at about `19.2 m`: supports the SSW-facing rear/long-side family. The provider's `1177 13th` label is excluded.

Written observation: a clear long/rear side with pale-gray horizontal siding,
broad upper windows, smaller lower windows, round vents, shallow roof/eaves,
and a tall wood fence that hides the base. Utility poles and lines cross the
view. The target-side material/window evidence is strong; entries are not
visible.

## Recognition boundary and handoff

Minimum cue: **compact pale-gray Hutchins row with broad upper windows, small
lower windows, round vents, and a fence-hidden base**. Close confusion: 1112
Hutchins and 1111 Keppler. Share the Site 12 siding/window/roof kit, but retain
this SSW proportion and vent rhythm. Prototype blocker: **none for the observed
rear/long-side study; the entry side remains unscheduled**. No panorama pixels
are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).
