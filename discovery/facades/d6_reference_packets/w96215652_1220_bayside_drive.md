# D6 source packet — 1220 Bayside Drive (`w96215652`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; exact material-only front map exists**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215652`, v5,
`2018-01-25T19:29:05Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1220`, `addr:street=Bayside Drive`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the civic address is not promoted to a building name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215652` / `building:w96215652:wall` / `building:w96215652:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `608.496 m²`; height `6 m`; NAVD88 base/top `2.345 / 8.345 m` |
| Perimeter | serialized `145.346 m`; visible `145.344 m`; `26` runs |
| Facing-run partition | SW `214.6–214.7°`: `0–1,3–4,6–8,10–11`; NW `304.6–304.9°`: `2,9,19,24–25`; SE `124.6–124.7°`: `5,12,15,22`; NE `34.6–34.7°`: `13–14,16–18,20–21,23` |
| Source / wall geometry SHA-256 | `5a9a8d34000a6174a08d1444036412cf24abd0e81cc9535679444d643b8095df` / `f9f060d5d62f4597b50acb5ede09eda34b7c3bb8919b41756420e9f4f4b48479` |
| Registry record / chunk SHA-256 | `9a5469fb6ef6cd23af64ded1aa87ce3dddb4b9c1a7dd5feabace6ef5571a4c59` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483172` is `1220 BAYSIDE DR`, address ID `724697`,
parcel `1939001`, point `37.8297815,-122.3761201`, current in that dataset
on 2026-09-03. `TIDA-JSCO-2026` lists 1220 as managed premises as of
2025-07-01; that does not prove occupancy or facade currentness.

- [March 2025 pano `y_1iTmB2k8lf_QeGek_yjQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=y_1iTmB2k8lf_QeGek_yjQ&heading=1&pitch=0&fov=75), camera `37.8296212,-122.3761997`, heading `1°`: exact-address SW/public-front observation. `BATCH_05_RUN_MAPPING.json` assigns only SW primary runs `0–1,3–4,6–8,10–11`; interleaved short facets and the rear remain excluded.

Written observation: two-storey light warm-gray/beige horizontal siding,
white trim/downspouts, shallow muted reddish-brown roof, repeated broad upper
sliders, and ground windows alternating with plain dark doors and pale side
panels. Short privacy/bin enclosures are separate pieces. No pronounced canopy
is established. Exact alternation, endpoints, other sides, alterations, and
occupancy remain unknown. See [the fuller target spec](../1220_BAYSIDE_DRIVE_REFERENCE_SPEC.md)
and [Batch 05 mapping](../BATCH_05_RUN_MAPPING.md).

## Recognition boundary and handoff

Minimum cue: **a longer warm-beige Bayside row with repeated broad sliders and
a canopy-free public face**. Close confusion: 1222/1224 Bayside and the cool
Mariner/Northpoint rows. Tileable siding/trim/roof/glass may share the northern
housing family; the warmer field, SW unit alternation, privacy pieces, and
canopy absence remain target-specific. Prototype blocker: **none for a detached
SW-front study**. Rear, short facets, and exact module endpoints remain
fallback until receiver-relative reconciliation. No panorama pixels are
retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
