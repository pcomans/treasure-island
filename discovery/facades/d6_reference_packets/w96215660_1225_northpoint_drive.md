# D6 source packet — 1225 Northpoint Drive (`w96215660`)

Checked: **2026-09-04**  
Readiness: **component/end-side study ready; detailed long elevations remain appearance-blocked**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215660`, v5,
`2020-05-26T19:59:19Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1225`, `addr:street=Northpoint Drive`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the address is not promoted to a name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215660` / `building:w96215660:wall` / `building:w96215660:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `490.234 m²`; height `6 m`; NAVD88 base/top `2.237 / 8.237 m` |
| Perimeter | serialized `115.758 m`; visible `115.757 m`; `24` runs |
| Facing-run partition | S `182.6–182.8°`: `0,4,19`; E `92.3–94.0°`: `1–3,5–8,10–13`; N `2.6–2.8°`: `9,14–15,21`; W `272.5–272.8°`: `16–18,20,22–23` |
| Source / wall geometry SHA-256 | `38219e26660fd29eff4691565f6ae569d8f139e892819609251198599fc71d27` / `c666f15212385e87ea68b69720d445c4a337ed7e047d7bb78afa8e6c3314c875` |
| Registry record / chunk SHA-256 | `f3ef8909a5fc0666f23c79ea54bd35e7c9fac0249c50d485970ecb4937342b22` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483503` is `1225 NORTHPOINT DR`, address ID `725281`,
parcel `1939001`, point `37.8301928,-122.3748374`, current in that dataset
on 2026-09-03. 1225 is absent from the `TIDA-JSCO-2026` premises exhibit;
absence is not survival, occupancy, or facade evidence.

- [March 2025 pano `ItRdW8bYgwQNwbFSpnGG_g`](https://www.google.com/maps/@?api=1&map_action=pano&pano=ItRdW8bYgwQNwbFSpnGG_g&heading=210.7&pitch=0&fov=75), camera `37.8306259,-122.3746034`, heading `210.7°`: the target lies about `44.3 m` away. The distant oblique view supports only the N end family `9,14–15,21`; overlapping long rows and nearby canopies cannot be assigned safely.

Target-bound written observation: a two-storey light-sided end with stacked
openings below a shallow roof. The visible long-face rhythm, doors, privacy
pieces, and canopies belong to merged neighboring context and are not assigned.
Exact material value, end opening endpoints, every long-side schedule,
alterations, and occupancy remain unknown.

## Recognition boundary and handoff

This is not enough for a whole target recognition cue. It can seed a **shallow
N-end component study with light siding, white trim, stacked openings, and a
shallow roof**, while keeping all long sides neutral. Close confusion:
1227/1234/1236 and other Northpoint rows. Generic tileable siding/trim/roof
materials may be shared; no neighbor's window, door, canopy, or privacy cadence
may transfer. Blocker for a target-side prototype: **a dated rights-clear close
view/elevation that separates either exact long face of `w96215660`**. No
panorama pixels are retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
