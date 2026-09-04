# D6 source packet — 1227 Northpoint Drive (`w96215653`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; exact front/end material map exists**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215653`, v5,
`2020-05-26T19:59:19Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1227`, `addr:street=Northpoint Drive`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the address is not promoted to a building name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215653` / `building:w96215653:wall` / `building:w96215653:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-4` |
| Mass | area `489.416 m²`; height `6 m`; NAVD88 base/top `1.952 / 7.952 m` |
| Perimeter | serialized / visible `115.841 / 115.841 m`; `22` runs |
| Facing-run partition | S `182.3–182.8°`: `0,3,12`; W `272.4–272.5°`: `1–2,18,20–21`; E `92.2–93.2°`: `4–7,9–11,13–16`; N `2.4–2.5°`: `8,17,19` |
| Source / wall geometry SHA-256 | `5ceefbb6a1d5d13e4a9ad16c69dd88ed519a31661026bfcafdcaa27a300f3fc4` / `e5b43c44c408e90f05d0b4742397b131be699921c6896bb723f2874afeaeafb4` |
| Registry record / chunk SHA-256 | `23526603fe7e46db4ffe292941dddf74f07f30c607a159ec1639148dd3ceb7cd` / `932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483504` is `1227 NORTHPOINT DR`, address ID `725282`,
parcel `1939001`, point `37.8305530,-122.3748588`, current in that dataset
on 2026-09-03. `TIDA-JSCO-2026` lists 1227 as managed premises as of
2025-07-01; inclusion does not prove occupancy.

- [March 2025 pano `kTg6yZ_s4Mxm8SssPFhnfg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=kTg6yZ_s4Mxm8SssPFhnfg&heading=224&pitch=0&fov=75), camera `37.8309911,-122.3745776`, heading `224°`: exact-address E/public-front plus N-end observation. Exact material-only mapping: E runs `4–7,9–11,13–16` and outer N run `17`.
- [March 2025 pano `3GnbRQIwA2Bqn39tvao7wg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=3GnbRQIwA2Bqn39tvao7wg&heading=81&pitch=0&fov=75), camera `37.8305929,-122.3754959`, heading `81°`: distant W/rear context only; exact openings and modules are not authorized.

Written observation: two-storey cool-gray horizontal siding; white
trim/gutters; shallow gray shingle gable; repeated upper sliders over ground
windows/dark entries; gray-blue privacy/bin enclosures; mostly solid north
gable end. Farther flat-carport overlap is unresolved and not assigned. Exact
alternation, rear, carport ownership, south end, alterations, and occupancy
remain unknown. See [the fuller target spec](../1227_NORTHPOINT_DRIVE_REFERENCE_SPEC.md)
and [Batch 05 mapping](../BATCH_05_RUN_MAPPING.md).

## Recognition boundary and handoff

Minimum cue: **cool-gray repeated front units terminating in the mostly solid
north gable end**. Close confusion: 1225/1234/1236/1239 Northpoint. Reuse
tileable siding, trim, glass, roof, privacy, and generic shallow-gable
components; keep the E solid/void sequence, N-end motif, and any later-proven
carport local. Prototype blocker: **none for a detached E-front/N-end study**.
Rear modules, carport, short facets, and live endpoint placement remain
blocked. No panorama pixels are retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
