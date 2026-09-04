# D6 source packet — 1139 Ozbourn Court (`w96215662`)

Checked: **2026-09-04**  
Readiness: **component/end-and-side study ready; exact opening schedule remains appearance-blocked**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215662`, v5,
`2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1139`, `addr:street=Ozbourn Court`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the civic address is not promoted to a name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215662` / `building:w96215662:wall` / `building:w96215662:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-3` |
| Mass | area `431.141 m²`; height `6 m`; NAVD88 base/top `2.400 / 8.400 m` |
| Perimeter | serialized `109.839 m`; visible `109.838 m`; `14` runs |
| Facing-run partition | SW `214.7°`: `0–1,9`; SE `124.7°`: `2–3,5`; NE `34.6–34.7°`: `4,6–7`; NW `304.7°`: `8,10–13` |
| Source / wall geometry SHA-256 | `c4ff31809b555a6c2a9615965924f110f414e2419dee459d99f068158b89284f` / `410768d204e93e8b9da3725bc55f9df1559fc7526b4443c4f185af9fbfc71c73` |
| Registry record / chunk SHA-256 | `2aecec7fbcbe1bd733598b2d2c2bf092dfd0e893c22ec84f4573c1ec9c81ddb9` / `7f0ecd2e16fe4327f351496ed8c2f8640d68278fbaf33d428b6314ec862d9944` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483607` is `1139 OZBOURN CT`, address ID `725398`,
parcel `1939001`, point `37.8290743,-122.3769724`, current in that dataset
on 2026-09-03. 1139 is absent from the `TIDA-JSCO-2026` premises exhibit;
absence is not demolition, occupancy, or appearance evidence.

- [January 2023 pano `F4E_ZwkS0bYdfNly3BPRpg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=F4E_ZwkS0bYdfNly3BPRpg&heading=254.6&pitch=0&fov=75), camera `37.8291270,-122.3765935`, heading `254.6°`: target about `41.2 m` away behind a tall fence; supports NE-end family `4,6–7` and only oblique side context.
- [April 2019 pano `uMQ89In9y-H1rC4r_3gfoA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=uMQ89In9y-H1rC4r_3gfoA&heading=111.2&pitch=0&fov=75), camera `37.8291699,-122.3774693`, heading `111.2°`: target about `42.0 m` away; supports historical NW-long-family context `8,10–13`, but nearby rows and cars prevent a confident exact opening schedule.

Target-bound written observation: pale blue-gray two-storey siding, shallow
brown-gray gable roof, stacked end openings, upper long-side windows, and a
small centered projecting gable visible through fencing/occlusion. Exact
front/rear ownership, unit cadence, ground openings, other sides, survival
after January 2023, alterations, and occupancy remain unknown.

## Recognition boundary and handoff

This evidence supports an **Ozbourn-specific end/projecting-gable component and
quiet NW-side field**, not a whole facade schedule. Close confusion: adjacent
Ozbourn/Reeves housing rows. Tileable siding/trim/roof may share the northern
housing family; the centered projecting gable, fence relationship, and any
later-proven solid/void sequence remain local. Blocker for a target-side
prototype: **a dated rights-clear closer view/elevation that separates one
long face and its openings from neighboring rows**. No panorama pixels are
retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
