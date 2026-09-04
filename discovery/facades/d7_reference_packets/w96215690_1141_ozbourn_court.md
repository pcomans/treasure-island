# D7 source packet — 1141 Ozbourn Court (`w96215690`)

Checked: **2026-09-04**  
Readiness: **component/entry-and-window study ready; foliage-occluded long schedule blocked**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215690`, v5, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1141`, `addr:street=Ozbourn Court`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215690` / `building:w96215690:wall` / `building:w96215690:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-3` |
| Mass | area `431.030 m²`; height `6 m`; NAVD88 base/top `2.756 / 8.756 m` |
| Perimeter | serialized `109.824 m`; visible `109.823 m`; `14` runs |
| Facing-run partition | NE `35.0°`: `0–3,5`; SE `125.0°`: `9,13`; SW `215.0°`: `7–8,10–12`; NW `305.0–305.1°`: `4,6` |
| Source / wall geometry SHA-256 | `c32066adf59f30a1a22478bce26c7265a729cc74513664ba3f5ed150823e83fd` / `cf057b04cc29d2d83a24f55be0320b8716b6325d74080173e1859c752c6a0b4c` |
| Registry record / chunk SHA-256 | `9940ae28f198e32dde325df1a53633a87314712e2a823269bfbf5298fbb26f4c` / `7f0ecd2e16fe4327f351496ed8c2f8640d68278fbaf33d428b6314ec862d9944` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483608 / 725399` identify `1141 OZBOURN CT` on
parcel `1939001`, current in that dataset on 2026-09-03. The Navy's 2015 Site
12 table and TIDA's managed-premises exhibit as of 2025-07-01 retain the same
address. Those administrative facts do not prove occupancy or exterior state.

- [April 2019 pano `vJmlzhWwpLrMtacRzGRgow`](https://www.google.com/maps/@?api=1&map_action=pano&pano=vJmlzhWwpLrMtacRzGRgow&heading=212.4&pitch=0&fov=75), camera `37.8290974,-122.3774082`, heading `212.4°`: direct centroid ray at about `16.7 m`; supports NE runs `0–3,5`. It predates the frozen OSM timestamp and is not proof of a current facade.

Target-bound observation: gray-beige horizontal siding, a shallow gray roof,
paired white-framed upper-window groups, and glimpses of the entry level
without a pronounced deep canopy. Dense tree and hedge cover prevents a
defensible complete long-side cadence. Exact doors, lower openings, full run
schedule, other sides, later alterations, and occupancy remain unknown.

## Recognition boundary and handoff

This supports a **quiet gray-beige siding, shallow-roof, paired-upper-window
component on the NE side**, not a complete facade. Close confusion: 1139/1143
Ozbourn and pale Site 12 rows. Share only neutral material and paired-window
components; do not transfer 1143's red-roof/green-door schedule through the
foliage. Blocker for a full target-side prototype: **a dated rights-clear view
that resolves the NE entry and opening sequence**. No panorama pixels are
retained or proposed as texture inputs.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
