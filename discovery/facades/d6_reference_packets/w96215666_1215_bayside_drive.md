# D6 source packet — 1215 Bayside Drive (`w96215666`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215666`, v5,
`2018-01-25T19:29:06Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1215`, `addr:street=Bayside Drive`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the address is not promoted to a name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215666` / `building:w96215666:wall` / `building:w96215666:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `490.280 m²`; height `6 m`; NAVD88 base/top `2.070 / 8.070 m` |
| Perimeter | serialized `115.737 m`; visible `115.738 m`; `20` runs |
| Facing-run partition | S `180.2–180.5°`: `0,6,9`; W `270.1–270.2°`: `1,3–5,17–19`; N `0.2–0.6°`: `2,12,15–16`; E `90.1–90.2°`: `7–8,10–11,13–14` |
| Source / wall geometry SHA-256 | `41e37183fbe60bae3c3537b653efd8f30558fe1f77b652f95936086de075f092` / `967206386c9f23d04bbc45c3d9ef97367166b2f3d0e0df4daf86d53cc2e73470` |
| Registry record / chunk SHA-256 | `ff64c89e228a468311566d73746c0a8fd6843d6b6c321c122f3367e26e4b1a9a` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483171` is `1215 BAYSIDE DR`, address ID `724696`,
parcel `1939001`, point `37.8302306,-122.3752779`, current in that dataset
on 2026-09-03. `TIDA-JSCO-2026` lists 1215 as managed premises as of
2025-07-01; inclusion does not prove occupancy.

- [March 2025 pano `0gFWtnoFEAfXkS7PruJyzg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=0gFWtnoFEAfXkS7PruJyzg&heading=94.2&pitch=0&fov=75), camera `37.8302346,-122.3754753`, heading `94.2°`: exact-address, close W/public-side association; the target centroid is about `21.0 m` away and W runs are `1,3–5,17–19`.

Written observation: compact two-storey pale gray-blue horizontal-sided row;
white trim/gutters; shallow gray roof; repeated upper sliders; one continuous
deep flat canopy that strongly obscures the lower dark doors/windows. Exact
bay count, opening endpoints, post spacing, hidden sides, alterations, and
occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **the compact Bayside row whose deep continuous flat canopy
compresses the visible lower facade beneath a regular upper-slider band**.
Close confusion: 1202 Mariner, 1234 Northpoint, and 1248/1395 Gateview. Reuse
tileable siding/trim/roof and a parametric flat-canopy component, but preserve
1215's W-side canopy extent, upper rhythm, ground occlusion, and solid
intervals locally. Prototype blocker: **none for a detached W-side study**.
Exact receiver-relative endpoints and the canopy-hidden lower sequence remain
required before live placement. No panorama pixels are retained or proposed as
texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
