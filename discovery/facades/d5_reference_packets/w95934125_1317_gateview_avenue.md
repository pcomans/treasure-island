# D5 source packet — 1317 Gateview Avenue (`w95934125`)

Checked: **2026-09-04**  
Readiness: **component/side-study ready; fenced lower facade is not whole-building evidence**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934125`, v5, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1317`, `addr:street=Gateview Avenue`,
`building=abandoned`, `building:levels=2`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934125` / `building:w95934125:wall` / `building:w95934125:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-2` |
| Mass | area `732.648 m²`; height `6 m`; NAVD88 base/top `2.207 / 8.207 m` |
| Perimeter | serialized `170.472 m`; visible `170.473 m`; `34` runs |
| Facing-run partition | WSW `242.6°`: `0–1,3–5,7–8`; SSE `152.6–152.8°`: `2,9,11–12,18–19,21,28`; NNW `332.5–332.7°`: `6,16,23,25,30,32–33`; ENE `62.5–62.6°`: `10,13–15,17,20,22,24,26–27,29,31` |
| Source / wall geometry SHA-256 | `730fa641c105a839e2e5527ff2f43cf64408a4f123306a319ca0a50ad3e2440b` / `a51790db6479515d48ec0a623da88f0864e957ea9aba45080cda392a79e80ece` |
| Registry record / chunk SHA-256 | `3537997ae045f8022bbe4c6449cec82655797411e417397d15ace85fedc3a6ef` / `35bf23d64e860d39c5b79a98be7830f4f477143f7e9490c6739dec0627062d11` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `483579` is `1317 GATEVIEW AVE`, parcel `1939001`, point
`37.8265489390,-122.3777582925`, current in that dataset on 2026-09-03. The
frozen `building=abandoned` tag is a dated source state, not a claim about
occupancy in 2025 or 2026. The target structure is visibly standing in the
March 2025 observation; the image does not resolve legal use or habitability.

- [March 2025 pano `uRl0jeIdSuHK96_NR4QjEg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=uRl0jeIdSuHK96_NR4QjEg&heading=270&pitch=0&fov=75), camera `37.8264174,-122.3774487`, heading `270°`: target-bound ENE side association, runs `10,13–15,17,20,22,24,26–27,29,31`. Written observation: a weathered cream horizontal-sided two-storey row behind privacy-mesh fencing, shallow main roof, several dark or boarded upper openings, and a deep gable canopy/porch form; the lower solid/void schedule is substantially hidden.

Unknown: front-side composition, lower openings, canopy bay count, hidden-side
schedules, occupancy, and post-March-2025 change. No panorama pixels are
retained.

## Recognition boundary and handoff

Minimum component cue: **weathered cream siding, dark/boarded upper openings,
and the deep gable canopy above the fenced ENE side**. Close confusion: 1314,
1315, 1316, and 1318 Gateview. A bounded ENE siding/canopy/upper-opening study
is allowed; whole-building recognition, an unobscured ground-floor schedule,
or a neighbor-derived front is not. Prototype blocker: **target-identifiable,
dated front evidence remains missing for a whole-building study**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).
