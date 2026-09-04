# D5 source packet — 1308 Gateview Avenue (`w95934123`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; detached study only**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934123`, v5, `2018-01-22T18:56:12Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1308`, `building=residential`, `building:levels=2`,
`height=6`. The street name is a current City cross-reference, not a missing
frozen tag rewritten after the fact.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934123` / `building:w95934123:wall` / `building:w95934123:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-1` |
| Mass | area `732.754 m²`; height `6 m`; NAVD88 base/top `2.251 / 8.251 m` |
| Perimeter | serialized `170.479 m`; visible `170.479 m`; `34` runs |
| Facing-run partition | WSW `243.0–243.1°`: `0–1,3,5,7–8,10–11,14,17,20,32`; SSE `152.8–153.1°`: `2,9,12–13,18–19,21,27`; NNW `333.0–333.1°`: `4,6,15–16,24,31,33`; ENE `63.1°`: `22–23,25–26,28–30` |
| Source / wall geometry SHA-256 | `6028c89be31ebfd095777b86f6d5d4a9094002b7b5fd73efb2fc940f9a9f3917` / `7a9add0e304b6bbdb5e553cab89c978674246b875ce566128616918c876bcee5` |
| Registry record / chunk SHA-256 | `5bf75fcc75fdbc83d45a97a6a4168a439e8c31bcbc473105147f831a09458abd` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver. The direct wall and roof are the only
geometry authorized by this packet.

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `483572` is `1308 GATEVIEW AVE`, parcel `1939001`, point
`37.8241315780,-122.3763957302`, with `data_as_of=2026-09-03T18:00:54`.
`TIDA-JSCO-2026` includes 1308 Gateview in its managed-premises list as of
2025-07-01. These support identity and administrative currency, not occupancy
or an exact facade schedule.

- [March 2025 pano `zO-a_ZQWv5tAHydoH3VsFQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=zO-a_ZQWv5tAHydoH3VsFQ&heading=19&pitch=0&fov=75), camera `37.8240737,-122.3766091`, heading `19°`: target-bound public Gateview corner/frontage association across the WSW/SSE run families. Written observation: a long pale/cream two-storey horizontal-sided row, repeated upper sliders, a deep repeated gable-roof porch/carport rhythm, ground entries/windows and open lower voids, with a low shallow main roof.

Unknown: exact bay widths, hidden-side schedules, individual door/window
assignment, canopy depth, repairs, and current occupancy. No panorama pixels are
retained.

## Recognition boundary and handoff

Minimum cue: **the long upper-slider band over repeated deep gable canopy/open
ground-level voids**. Close confusion: 1301, 1303, 1305, 1306, 1307, 1310,
1314, and 1316 Gateview rows. A detached study may share a tileable neutral
siding/roof/trim family, but it must preserve this target's long 34-run mass and
observed canopy/void rhythm; it may not copy a neighbor's opening schedule.
Prototype blocker: **none for the observed WSW/SSE public-side study**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).
