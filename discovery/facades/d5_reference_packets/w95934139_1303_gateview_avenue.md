# D5 source packet — 1303 Gateview Avenue (`w95934139`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; detached study only**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934139`, v6, `2018-08-12T03:45:30Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1303`, `addr:street=Gateview Avenue`,
`building=apartments`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934139` / `building:w95934139:wall` / `building:w95934139:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_0` |
| Mass | area `732.920 m²`; height `6 m`; NAVD88 base/top `2.708 / 8.708 m` |
| Perimeter | serialized `170.483 m`; visible `170.485 m`; `34` runs |
| Facing-run partition | WSW `243.9–244.0°`: `0,2–3,10,20–21,27,29`; NNW `333.8–334.1°`: `1,15–16,19,22,24,26,28,30–31,33`; SSE `154.0°`: `4–7,9,11–12`; ENE `63.9–64.2°`: `8,13–14,17–18,23,25,32` |
| Source / wall geometry SHA-256 | `3549067d25f392cac9c3dbecc78201c306206ab6b8c74d211fcc2b0b5db50505` / `277717837698b08703bcf3f028e8fd443fe4df5cafe950382a9488ca99e2bd00` |
| Registry record / chunk SHA-256 | `7d385aa67acf699dd65006c58bef6c1345aab5de567fe3e2375edb409ae25af8` / `3e7d1cb020d4a8f8a2852121a181a1e2d441fee40de42d744d37fbbcba59168b` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

The frozen address is supported by `CITY-XWALK`, whose current value is `1303
GATEVIEW AV`. No matching live `CITY-EAS` base-address row was recovered.
`TIDA-JSCO-2026` includes 1303 Gateview as of 2025-07-01. These sources do not
prove occupancy or an exact facade schedule.

- [March 2025 pano `aF5PPnLG2uEHEJ9GA_GaaQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=aF5PPnLG2uEHEJ9GA_GaaQ&heading=111&pitch=0&fov=75), camera `37.8237599,-122.3763305`, heading `111°`: direct target-bound WSW/NNW public corner association at roughly 34 m. Written observation: a long cool blue-gray horizontal-sided two-storey row with white trim, repeated upper sliders, broad deep gable canopies/carports, ground entries/windows, and open lower voids beneath a shallow roof.

Unknown: exact per-bay dimensions, hidden SSE/ENE schedules, repairs, and
occupancy. No panorama pixels are retained.

## Recognition boundary and handoff

Minimum cue: **cool blue-gray long row, repeated white upper sliders, and deep
gable canopy/open lower rhythm**. Close confusion: 1301, 1305, 1307, 1308,
1314, and 1316 Gateview. A detached study may share neutral siding/roof/trim
infrastructure with the Gateview family, but must preserve this 34-run mass and
observed solid/void rhythm; it may not donate its facade to blocked 1301.
Prototype blocker: **none for the observed WSW/NNW public-side study**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).
