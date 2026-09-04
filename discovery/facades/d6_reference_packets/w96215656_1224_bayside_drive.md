# D6 source packet — 1224 Bayside Drive (`w96215656`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215656`, v5,
`2018-01-25T19:29:05Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1224`, `addr:street=Bayside Drive`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the address is identity evidence, not an invented name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215656` / `building:w96215656:wall` / `building:w96215656:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `489.945 m²`; height `6 m`; NAVD88 base/top `2.073 / 8.073 m` |
| Perimeter | serialized `115.700 m`; visible `115.703 m`; `18` runs |
| Facing-run partition | WSW `241.5–242.7°`: `0–1,6,13`; SSE `152.4–152.5°`: `2–5,7,9`; ENE `62.2–62.6°`: `8,10,15`; NNW `332.4–332.5°`: `11–12,14,16–17` |
| Source / wall geometry SHA-256 | `0263244628a41e71670a6ff02f4e01540d40dd0acb5d3bc3db4d408aee8d6659` / `23db68bf3d0800c8ef93fdc51ecf53ccbcd57f3feb071692771f9e759c46f74b` |
| Registry record / chunk SHA-256 | `b444578b5b5f526200693d405996e281e3bc4f49217bbeeab5dc855424ca50a8` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483174` is `1224 BAYSIDE DR`, address ID `724699`,
parcel `1939001`, point `37.8304425,-122.3759806`, current in that dataset
on 2026-09-03. `TIDA-JSCO-2026` lists 1224 as managed premises as of
2025-07-01; inclusion does not prove occupancy or later alteration.

- [March 2025 pano `5RtJoyukhQOJURsGbsW4aQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=5RtJoyukhQOJURsGbsW4aQ&heading=149&pitch=0&fov=75), camera `37.8306294,-122.3760941`, heading `149°`: exact-address, close NNW/public-side association; the target centroid is about `21.6 m` away and NNW runs are `11–12,14,16–17`.

Written observation: full long two-storey pale blue-gray horizontal-sided
front; white trim/downspouts; shallow muted reddish-brown roof; repeated broad
upper sliders; ground broad windows alternating with plain doors; short
blue-gray privacy/bin enclosures. No carport canopy is present on this observed
face. Exact alternation, opening endpoints, hidden sides, alterations, and
occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **a compact pale-blue Bayside row whose NNW face stays open and
canopy-free beneath the repeated upper sliders**. Close confusion: 1220 and
1222 Bayside. Reuse tileable siding, trim, roof, glass, door, and privacy
materials/components, but preserve 1224's NNW solid/void rhythm and observed
canopy absence; do not import 1220's warmer field or 1222's heavier weathering.
Prototype blocker: **none for a detached NNW-side study**. Exact
receiver-relative unit endpoints remain required before live placement. No
panorama pixels are retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
