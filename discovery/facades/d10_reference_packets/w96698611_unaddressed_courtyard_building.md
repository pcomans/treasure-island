# D10 source packet — unaddressed courtyard building (`w96698611`)

Checked: **2026-09-04**  
Readiness: **component/upper-wall-and-roof study ready**

Packet-time catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D10 packet-time registry snapshot `ti.facade-runtime-registry/4`, SHA-256 `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`. Frozen source: OSM way `w96698611`, v2, `2023-09-30T18:30:38Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `building=yes`. No proper name exists in the frozen source. No frozen street address exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96698611` / `building:w96698611:wall` / `building:w96698611:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-1` |
| Mass | area `990.060 m²`; height `6 m`; NAVD88 base/top `3.828 / 9.828 m` |
| Perimeter | serialized `169.193 m`; visible `169.192 m`; `40` runs |
| Facing-run partition | E `88.6–88.9°`: `0–1,3,5–6,12,28,35–36,38`; S `178.7–178.8°`: `16,20,23,26–27,29–30,34,39`; W `268.6–268.8°`: `10,14–15,17,19,21–22,24–25,31–33`; N `358.7–359.0°`: `2,4,7–9,11,13,18,37` |
| Source / wall geometry SHA-256 | `023a5b60c7f92b8ed0c17f739f41d1bb60639a5b6c3bae02cec8adb0b01441d9` / `e3456f392fc37c96b0f7ec5d46050d7b1c4f04927f141f53682ac4b775f4074d` |
| Registry record / chunk SHA-256 | `2c54a09f555089bf55e882cc98b5855585cf39095b480f30d348185be335317b` / `5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray. Facing runs are exact outward-normal partitions, not an inferred opening schedule.

## Identity, lifecycle, and public-side appearance

No safe `CITY-EAS` or `CITY-XWALK` footprint binding was found: the nearest candidate addresses are roughly `70–74 m` away. The packet therefore retains only the frozen way identity and geometry; it does not invent an address, name, use, or occupancy.

- [March 2025 pano `6CTYyOTK1Yd4PnoZclnuxg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=6CTYyOTK1Yd4PnoZclnuxg&heading=242.3&pitch=0&fov=75), camera `37.8257331,-122.3728904`, direct centroid ray `242.3°` at about `26.5 m`: supports the E-facing family. A June 2019 view provides the same upper-volume boundary but no complete facade.

Written observation: dense red-leaf canopy/hedge and a tall pale fence hide almost the entire plane. Only a weathered dark-brown horizontal-clad upper wall/roof volume, gray hipped roof, and a pergola-like edge are attributable.

## Recognition boundary and handoff

Minimum cue: **dark-brown upper horizontal cladding, gray hipped roof, and pergola-like edge**. Close confusion: nearby courtyard structures and dark-clad utility/residential volumes. Share generic dark siding, gray hip-roof, and pergola-edge components; no opening cadence or hidden lower treatment is authorized. Prototype/component blocker: **the lower facade and opening schedule remain blocked by dense vegetation and the tall fence**. Address, proper name, use, lower facade, entries, hidden sides, lifecycle, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, capture/currentness caveats, packet-time/current registry split, and rights boundary: [D10 index](README.md).
