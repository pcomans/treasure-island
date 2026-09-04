# D6 source packet — 1312 Gateview Avenue (`w96215655`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215655`, v5,
`2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1312`, `addr:street=Gateview Avenue`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the civic address is not promoted to a name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215655` / `building:w96215655:wall` / `building:w96215655:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-1` |
| Mass | area `776.664 m²`; height `6 m`; NAVD88 base/top `2.508 / 8.508 m` |
| Perimeter | serialized `170.289 m`; visible `170.285 m`; `36` runs |
| Facing-run partition | S `189.2–189.3°`: `0–1,3–4,8,21–22,29–30`; W `279.2–279.3°`: `2,13–14,18–20,23,25,28,31,34–35`; E `99.2–99.3°`: `5–7,9–10`; N `8.9–9.3°`: `11–12,15–17,24,26–27,32–33` |
| Source / wall geometry SHA-256 | `46859aded3706bc7e8902fbb7e12bc1c65637bf5b086431c9486a43bdbf7ac6d` / `6f4d6f9caeee0e1c571b13c44393d258e1838e0267f2d753986cf5cd9bfbe021` |
| Registry record / chunk SHA-256 | `56cc9f0710517cbd9e2147ece60631aec5ef3f69bd242f5ed808edb277b90bb4` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483574` is `1312 GATEVIEW AVE`, address ID `725365`,
parcel `1939001`, point `37.8254430,-122.3767873`, current in that dataset
on 2026-09-03. `TIDA-JSCO-2026` lists 1312 as managed premises as of
2025-07-01; inclusion does not prove occupancy.

- [March 2025 pano `D391BGWg_Rf6bYA6-u5Pew`](https://www.google.com/maps/@?api=1&map_action=pano&pano=D391BGWg_Rf6bYA6-u5Pew&heading=100.2&pitch=0&fov=75), camera `37.8253937,-122.3770401`, heading `100.2°`: exact-address, close W/public-side association; the target centroid is about `26.8 m` away and W runs are `2,13–14,18–20,23,25,28,31,34–35`.

Written observation: long two-storey pale blue-gray horizontal siding; white
trim; shallow low roof; a broad central double-width gabled carport canopy
with adjacent narrower gabled covers; upper sliders and quieter ground
door/window fields. A tree, cars, and the canopy obscure part of the lower
sequence. Exact unit count, opening endpoints, canopy/post dimensions, hidden
sides, alterations, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **a long pale Gateview row organized around its broad central
gabled carport canopy and adjacent smaller covers**. Close confusion: 1307,
1308, 1316, 1317, and 1318 Gateview. Reuse tileable siding/trim/roof and a
parametric gabled-carport family, but keep 1312's W-side canopy hierarchy,
solid/void rhythm, and post placement local; 1307's ENE cadence is not a
schedule source. Prototype blocker: **none for a detached W-side study**.
Receiver-relative endpoints and the occluded lower sequence remain mandatory
before live placement. No panorama pixels are retained or proposed as texture
inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
