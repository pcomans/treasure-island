# D6 source packet — 1307 Gateview Avenue (`w96215657`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; duplicate frozen number resolved to this exact street-tagged footprint**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215657`, v5,
`2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1307`, `addr:street=Gateview Avenue`,
`building=apartments`, `height=6`. No levels tag or source name is
invented.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215657` / `building:w96215657:wall` / `building:w96215657:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-1` |
| Mass | area `776.796 m²`; height `6 m`; NAVD88 base/top `2.039 / 8.039 m` |
| Perimeter | serialized `170.318 m`; visible `170.319 m`; `30` runs |
| Facing-run partition | WSW `243.6°`: `0–3,5–7`; NNW `333.6–333.8°`: `4,13,20,26–27,29`; SSE `153.5–153.6°`: `8,11,16,18,22–23`; ENE `63.5–63.6°`: `9–10,12,14–15,17,19,21,24–25,28` |
| Source / wall geometry SHA-256 | `56e9125a0fdb12656119af8c9ba34043d1c8b03459480c302dbb7ad4d496bfe4` / `bc859b754b2efef4dbda13d48523cdf34b4830bcfcfcf4a2e8a4d06c3cd35ed2` |
| Registry record / chunk SHA-256 | `71dec892a799c4d31312c9e10fccaf07958b4272ceb719606b6611c6539cd1e9` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483568` / address ID `725359` is `1307 GATEVIEW AVE`,
parcel `1939001`, point `37.8240426,-122.3767551`, current in that dataset
on 2026-09-03. The point is about `15 m` from this footprint centroid and
about `41 m` from frozen way `w95934103`, which has number 1307 but no
street tag. The complete frozen address plus closer spatial join make
`w96215657` the exact civic-address target; no facade claim transfers between
the two catalog units. `TIDA-JSCO-2026` lists 1307 as managed premises as of
2025-07-01, which does not prove occupancy.

- [March 2025 pano `ntymJsDZY54MZWCncwx5og`](https://www.google.com/maps/@?api=1&map_action=pano&pano=ntymJsDZY54MZWCncwx5og&heading=242.3&pitch=0&fov=75), camera `37.8239944,-122.3765583`, heading `242.3°`: the ray reaches this footprint at about `22 m` and exposes the ENE family `9–10,12,14–15,17,19,21,24–25,28`. Google's 1308 label belongs to the camera-side context and is not used as target identity.

Written observation: two-storey pale khaki/gray horizontal siding; white trim;
low roof; a prominent centered broad gabled two-car canopy with open lower
void, flanking upper windows, recessed ground entries, and substantial
tree/hedge/vehicle occlusion. Exact bay count, opening endpoints, canopy/post
dimensions, other sides, alterations, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **the centered broad gabled open canopy interrupting a long pale
sided ENE elevation**. Close confusion: 1305, 1308, 1312, 1316–1318 Gateview,
and the separate `w95934103` source. Reuse tileable siding/trim/roof and a
parametric gable-canopy component; preserve this source key, ENE cadence,
central void, and local canopy hierarchy. Prototype blocker: **none for a
detached ENE-side study**. Exact receiver-relative endpoints and occluded
ground sequence remain required before live placement. No panorama pixels are
retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).
