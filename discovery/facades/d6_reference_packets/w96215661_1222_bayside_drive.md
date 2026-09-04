# D6 source packet — 1222 Bayside Drive (`w96215661`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215661`, v5,
`2018-01-22T18:57:18Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1222`, `addr:street=Bayside Drive`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the address is identity evidence, not an invented name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215661` / `building:w96215661:wall` / `building:w96215661:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `489.879 m²`; height `6 m`; NAVD88 base/top `2.034 / 8.034 m` |
| Perimeter | serialized `115.705 m`; visible `115.706 m`; `20` runs |
| Facing-run partition | WSW `241.5–242.7°`: `0–1,3,13–14`; SSE `152.4–152.5°`: `2,4–5,7`; ENE `62.2–62.6°`: `6,8–9,17–18`; NNW `332.4–332.5°`: `10–12,15–16,19` |
| Source / wall geometry SHA-256 | `bcb142cfee091178ed2370e4dad94a6c984c4f8efa10c1f9e0b43d70fbda5e4f` / `1e4c9a52ecab1a1a029d1875d179e4b5ea98d766c71007829c4b615b6f8a064a` |
| Registry record / chunk SHA-256 | `73f02595f7317b0634060737fc247eae863cfc896e7d0c97069cbf3f2f6c9b9b` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483173` is `1222 BAYSIDE DR`, address ID `724698`,
parcel `1939001`, point `37.8301798,-122.3765707`, current in that dataset
on 2026-09-03. 1222 is absent from the `TIDA-JSCO-2026` premises exhibit;
absence is not demolition, occupancy, or appearance evidence.

- [March 2025 pano `pymolsv7OnDZ-dcCUNoB4Q`](https://www.google.com/maps/@?api=1&map_action=pano&pano=pymolsv7OnDZ-dcCUNoB4Q&heading=130.3&pitch=0&fov=75), camera `37.8303753,-122.3766978`, heading `130.3°`: exact-address, close NNW/public-side association; the target centroid is about `23.3 m` away and NNW runs are `10–12,15–16,19`.

Written observation: full long two-storey, visibly weathered pale blue-gray
horizontal siding; white trim; low flat/shallow roofline; repeated large upper
sliders; ground broad windows and solid doors; blue-gray privacy/bin
enclosures. No canopy is present on the observed face. Exact alternation,
opening endpoints, other sides, alterations after March 2025, and occupancy
remain unknown.

## Recognition boundary and handoff

Minimum cue: **the heavily weathered canopy-free blue-gray Bayside frontage
with its large repeated upper sliders**. Close confusion: 1220 and 1224
Bayside. Reuse tileable neutral siding/trim/roof/glass, but put high-contrast
wear in nonrepeating local overlays and preserve 1222's NNW solid/void rhythm
and canopy absence. Do not tile a baked dirt streak or import 1224's cleaner
field. Prototype blocker: **none for a detached NNW-side study**. Exact
receiver-relative endpoints remain required before live placement. No
panorama pixels are retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
