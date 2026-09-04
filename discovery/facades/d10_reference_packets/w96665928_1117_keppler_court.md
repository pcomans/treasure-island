# D10 source packet — 1117 Keppler Court (`w96665928`)

Checked: **2026-09-04**  
Readiness: **component/NNE upper-side study ready**

Packet-time catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D10 packet-time registry snapshot `ti.facade-runtime-registry/4`, SHA-256 `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`. Frozen source: OSM way `w96665928`, v5, `2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1117`, `addr:street=Keppler Court`, `building=residential`, `building:levels=2`, `height=7`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665928` / `building:w96665928:wall` / `building:w96665928:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-2` |
| Mass | area `306.665 m²`; height `7 m`; NAVD88 base/top `2.384 / 9.384 m` |
| Perimeter | serialized `77.769 m`; visible `77.770 m`; `12` runs |
| Facing-run partition | NNE `16.7°`: `0–4`; ESE `106.7°`: `10–11`; SSW `196.7°`: `8–9`; WNW `286.7°`: `5–7` |
| Source / wall geometry SHA-256 | `42c025184a12d2c25fe67e1f73f6288ca07a57f7219b0f99742ea230db9646f6` / `ea441b7872b48a4ee9a7dd252ba59db54328d5f842388225ac1742ea622c1fc4` |
| Registry record / chunk SHA-256 | `a429b77840e813a9c88bdb729ba600a1c9346c34d0ff3335ae61c39a2a4fe3d1` / `35bf23d64e860d39c5b79a98be7830f4f477143f7e9490c6739dec0627062d11` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray. Facing runs are exact outward-normal partitions, not an inferred opening schedule.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483560 / 725351`, point `37.8277459,-122.3770153`, supports the 1117 Keppler Court civic address on parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54.000`. The address row does not prove tenancy, exact facade condition, or survival beyond the capture.

- [March 2025 pano `BUwc7lWFDZjF_yu6h20Oew`](https://www.google.com/maps/@?api=1&map_action=pano&pano=BUwc7lWFDZjF_yu6h20Oew&heading=187.3&pitch=0&fov=75), camera `37.8279618,-122.3769837`, direct centroid ray `187.3°` at about `17.4 m`: supports the NNE-facing family.

Written observation: pale-gray horizontal siding, a shallow gray roof edge, an uneven upper-window band, and wall vents/utility boxes. A tall red-brown fence and trees hide the lower side and entry cadence.

## Recognition boundary and handoff

Minimum cue: **pale-gray horizontal siding, shallow gray roof edge, irregular upper-window band, and visible utility fixtures**. Close confusion: 1109 Keppler, adjacent Mason Court rows, and other pale Site 12 housing. Share pale siding, roof-edge, glazing, vent, and utility-box components; preserve the observed upper-window spacing for this receiver. Prototype/component blocker: **a complete prototype is blocked by the tall fence and trees across the lower plane**. Lower openings, entries, hidden runs, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, capture/currentness caveats, packet-time/current registry split, and rights boundary: [D10 index](README.md).
