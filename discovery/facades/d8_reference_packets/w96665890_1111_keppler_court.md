# D8 source packet — 1111 Keppler Court (`w96665890`)

Checked: **2026-09-04**  
Readiness: **target-side historical prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96665890`, v5, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1111`, `addr:street=Keppler Court`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665890` / `building:w96665890:wall` / `building:w96665890:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `306.637 m²`; height `6 m`; NAVD88 base/top `2.390 / 8.390 m` |
| Perimeter | serialized `77.769 m`; visible `77.768 m`; `10` runs |
| Facing-run partition | NNE `17.0°`: `0`; ESE `106.9°`: `7–9`; SSW `197.0°`: `3–6`; WNW `286.9°`: `1–2` |
| Source / wall geometry SHA-256 | `86b793e475a7c67ae30fcf3a331c444457c07b10735775fc371ccdf517fe788e` / `c7149b2a97b4b46b5542d32b29e10016efca483736e7aece1c9ba7e4775247e3` |
| Registry record / chunk SHA-256 | `902d04e0e0bdd7b83584b0fde389da12ab79eec99789d7323ae0e9f948a42837` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483557 / 725348` identify `1111 KEPPLER CT` on
parcel `1939001`, current in that dataset on 2026-09-03. The official 2017
housing table records four units and 5,160 square feet; current administrative
presence does not prove survival or unchanged 2019 appearance.

- [April 2019 pano `9T6FszoANzyG-g8_D8NI8Q`](https://www.google.com/maps/@?api=1&map_action=pano&pano=9T6FszoANzyG-g8_D8NI8Q&heading=117.4&pitch=0&fov=72), camera `37.8274826,-122.3767403`, direct centroid ray at about `22.8 m`: supports the historical WNW-facing front. The provider's `1109 Keppler` label names a neighbor and is excluded.

Written observation: a clear compact two-storey gray horizontal-sided front,
shallow hipped roof, repeated upper windows, yellow entry doors, modest lower
windows, and two large gray privacy/mailbox boxes. The yellow and condition are
dated observations, not current claims.

## Recognition boundary and handoff

Minimum cue: **compact gray Keppler front with yellow-door rhythm, repeated
upper windows, shallow hip, and paired gray privacy boxes**. Close confusion:
1113/1115 Keppler and 1112 Hutchins. Share the Site 12 kit, but retain this WNW
cadence, door color as a dated option, and box placement. Prototype blocker:
**none for a detached historical WNW-side study; current color/condition need
new evidence before promotion**. No panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).
