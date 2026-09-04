# D6 source packet — 1212 Mariner Drive (`w96215649`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; exact material-only front/end map already exists**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215649`, v5,
`2018-01-25T19:29:04Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1212`, `addr:street=Mariner Drive`,
`building=residential`, `building:levels=2`, `height=6`. No name exists
in the frozen source or catalog; the civic address is not promoted to a name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215649` / `building:w96215649:wall` / `building:w96215649:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-3` |
| Mass | area `490.003 m²`; height `6 m`; NAVD88 base/top `2.650 / 8.650 m` |
| Perimeter | serialized `115.694 m`; visible `115.696 m`; `28` runs |
| Facing-run partition | WSW `254.6–254.7°`: `0–2,8–9,23`; SSE `164.6°`: `3–4,6–7,10–12`; ENE `74.5–74.9°`: `5,13,18`; NNW `344.6–344.8°`: `14–17,19–22,24–27` |
| Source / wall geometry SHA-256 | `8ae28e4692d5330eef1c181eb3b61c3359ce277e5b2a8c568b8c516e5ad6d1e8` / `7e342d1fe1fc51bb2bbdc30795af08c46bc2114f3d5045268bb34241deeabf84` |
| Registry record / chunk SHA-256 | `0249f49659d20573cc3a157406bc841fcac48f8ef599e44296a0effb4549d7dd` / `d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483618` is `1212 MARINER DR`, address ID `725409`,
parcel `1939001`, point `37.8290361,-122.3730027`, current in that dataset
on 2026-09-03. `TIDA-JSCO-2026` lists 1212 as managed premises as of
2025-07-01. Neither source proves occupancy or an unchanged facade.

- [March 2025 pano `moV9e3E7bv5UpjOrgfOOKA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=moV9e3E7bv5UpjOrgfOOKA&heading=172&pitch=0&fov=75), camera `37.8291812,-122.3730340`, heading `172°`: exact-address public/front observation mapped by `BATCH_04_RUN_MAPPING.json` to NNW runs `14–17,19–22,24–27`.
- [September 2025 pano `Z0fcNvA78OpNIXJaa9A79A`](https://www.google.com/maps/@?api=1&map_action=pano&pano=Z0fcNvA78OpNIXJaa9A79A&heading=230&pitch=0&fov=75), camera `37.8291852,-122.3727577`, heading `230°`: outer ENE end run `13` only. The previously described rear-long view fails the generated outward-half-plane reconciliation, so no rear run inherits it.

Written observation: two storeys; cool gray-blue horizontal siding; white
trim/gutters; shallow gray-brown roof; repeated broad upper sliders over broad
ground windows and dark red-brown entries; short dark privacy/bin wings; no
pronounced porch canopy. Exact unit widths/counts, opening endpoints, rear,
notches, opposite end, alterations, and occupancy remain unknown. The fuller
prior research and later corrected run boundary are in
[the target spec](../1212_MARINER_DRIVE_REFERENCE_SPEC.md) and
[Batch 04 mapping](../BATCH_04_RUN_MAPPING.md).

## Recognition boundary and handoff

Minimum cue: **a low long cool-gray row with repeated sliders/privacy wings and
no pronounced front canopy**. Close confusion: 1202 Mariner and the Bayside,
Northpoint, and Gateview rows. Tileable siding, white trim, muted roof, and
neutral glass can share a material family; 1212's canopy absence, entry/privacy
rhythm, end motif, and solid/void sequence remain local. Prototype blocker:
**none for a detached NNW-front/ENE-end study**. Live modules still require
receiver-relative endpoint placement; rear and excluded notches stay fallback.
No panorama pixels are retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
