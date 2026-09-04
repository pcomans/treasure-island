# D5 source packet — source-key-only housing footprint (`w95934130`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready by exact geometry; civic identity remains unresolved**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934130`, v3, `2018-01-22T18:56:12Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags only `building=yes`, `height=6`. No address or proper name is transferred
from an adjacent footprint.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934130` / `building:w95934130:wall` / `building:w95934130:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-1` |
| Mass | area `475.341 m²`; height `6 m`; NAVD88 base/top `2.730 / 8.730 m` |
| Perimeter | serialized `110.846 m`; visible `110.847 m`; `24` runs |
| Facing-run partition | WSW `243.8°`: `0–1,3,5–6`; SSE `153.8–153.9°`: `2,7–10,13–14`; NNW `333.8–333.9°`: `4,19,22–23`; ENE `63.8–63.9°`: `11–12,15–18,20–21` |
| Source / wall geometry SHA-256 | `421ac7228be442d271a301d01f57450a4724c3fb2d6c6af2a13e09d066ad753e` / `864b522618f4466e1c71eca89f09cf6c9ab4699c88d34f14d914b56dd155b29a` |
| Registry record / chunk SHA-256 | `32f2d6fbb540750d335b95414a2e151a0401df2ceb4dd7c6c47a9b3bcf736a02` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

The frozen source and current catalog expose no civic address or name. Its
catalog centroid is approximately `37.8259183,-122.3757622`; that coordinate is
used only to bind the direct view to the exact source geometry. No City address
record or neighboring address is asserted. The March 2025 view shows a
standing target mass but cannot establish tenancy or legal status.

- [March 2025 pano `8xBjSWPMGItW8wjrsln9oQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=8xBjSWPMGItW8wjrsln9oQ&heading=167&pitch=0&fov=75), camera `37.8264614,-122.3759208`, heading `167°`: direct centroid-bound NNW public-side association, principally runs `4,19,22–23`. Written observation: two gabled triple-garage/end wings, a lower central connector with two exterior stairs, pale stucco, gray garage doors, sparse upper openings, and a muted shallow roof.

Unknown: civic identity, exact garage/opening dimensions, hidden-side schedules,
alterations, and occupancy. No panorama pixels are retained.

## Recognition boundary and handoff

Minimum cue: **paired triple-garage gabled wings around a two-stair central
connector**. Close confusion: 1403, 1405, 1408, and 1410 in the neighboring
Sturgeon/Flounder cohort. A detached study must remain labeled `w95934130` and
may not acquire a guessed street address. Reusable neutral plaster/roof modules
are allowed; the target's solid/void and stair composition remains local.
Prototype blocker: **none for the geometry-bound NNW study; address labeling
remains blocked**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).
