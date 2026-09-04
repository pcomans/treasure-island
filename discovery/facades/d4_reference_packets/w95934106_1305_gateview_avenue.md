# D4 source packet — 1305 Gateview Avenue (`w95934106`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; no recognition or live attachment authorized**

Catalog provenance: `ti.facade-recognition-catalog/3`, SHA-256
`0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934106`, v6, `2018-08-12T03:45:35Z`, frozen-file
SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1305`, `addr:street=Gateview Avenue`,
`building=apartments`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934106` / `building:w95934106:wall` / `building:w95934106:roof` |
| Relationship / chunk | standalone direct; no part child; `x_-2__z_0` |
| Mass | area `500.047 m²`; height `6 m`; NAVD88 base/top `2.379 / 8.379 m` |
| Perimeter | serialized / visible `121.646 / 121.647 m`; `28` runs |
| Facing-run partition | SSW `201.0–201.1°`: `0,2–5`; WNW `291.0–291.2°`: `1,12,22–23,26–27`; ESE `111.0–111.2°`: `6–7,10,15–16,19`; NNE `20.9–21.2°`: `8–9,11,13–14,17–18,20–21,24–25` |
| Source / wall geometry SHA-256 | `5be94ef8bc3dea1e7dc4506fd1bf9f973010a37b46a7f7174829409834dee72c` / `85df8274640f96ade62d6bdecd0107f0a6631bea60d19737b0acec77098f97cf` |
| Registry record / chunk SHA-256 | `551f46dd6ad84cda58e6fe2976964f6f633e849d641e7e869310e042ebb6b45b` / `3e7d1cb020d4a8f8a2852121a181a1e2d441fee40de42d744d37fbbcba59168b` |
| Current neutral materials | wall `building_wall` / `plaster_grey_04`; roof `building_roof` / `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725358` is `1305 GATEVIEW AVE`, parcel `1939001`, point
`37.823661232,-122.376417188`, matching the frozen address. `TIDA-DIR-2025`
records an address-level maintenance issue in February 2025. `TIDA-JSCO-2026`
removes 1305 from managed premises effective 2026-02-01; this is a management
change, **not evidence of demolition or vacancy**.

[March 2025 pano `aF5PPnLG2uEHEJ9GA_GaaQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=aF5PPnLG2uEHEJ9GA_GaaQ&heading=213&pitch=0&fov=75),
camera `37.8237599,-122.3763305`, heading `212.57°`, binds the frontage/NNE
family, runs `8–9,11,13–14,17–18,20–21,24–25`. Written observation: weathered
white horizontal siding; a low, nearly flat-looking roof with a raised central
parapet/mechanical strip; repeated upper sliders; two deep gable-roof
porch/carport canopies; paired ground doors; and open lower voids.

Unknown: exact unit cadence, canopy function/depth, parapet equipment, hidden
sides, occupancy after management removal, and post-March-2025 alteration. No
panorama pixels are retained.

## Recognition boundary and handoff

Minimum cue: **white sided upper row, paired deep gable canopies, and the raised
central roof strip**. Confusion: 1306/1307 and 1318 Gateview. A detached NNE
study is unblocked; siding/roof may target tileability, while canopies, sliders,
doors, and roof strip remain complete local modules. Do not treat the 2026
management removal as a demolition instruction. Shared sources:
[D4 index](README.md).
