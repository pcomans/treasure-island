# D7 source packet — 1244 Northpoint Drive (`w96215671`)

Checked: **2026-09-04**  
Readiness: **component/entry-side study ready; tree-occluded long schedule blocked**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215671`, v5, `2020-05-26T19:59:19Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1244`, `addr:street=Northpoint Drive`,
`building=residential`, `building:levels=2`, `height=6`. The civic address is
not a proper name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215671` / `building:w96215671:wall` / `building:w96215671:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-3` |
| Mass | area `608.485 m²`; height `6 m`; NAVD88 base/top `3.127 / 9.127 m` |
| Perimeter | serialized `143.528 m`; visible `143.531 m`; `32` runs |
| Facing-run partition | NNE `30.1–31.1°`: `0,9,21,30`; ESE `120.4–120.7°`: `20,22–23,26–29,31`; SSW `210.2–210.7°`: `5,14,18–19,24–25`; WNW `299.9–301.5°`: `1–4,6–8,10–13,15–17` |
| Source / wall geometry SHA-256 | `cccfcb9426bd1d6b019ce3bfd2c66c3e5013a278da92f2463678bc3cb4d51588` / `e5d24c2796c5b84bb1ed8851944b9230e4fba111fabbfb05098de039d36d331f` |
| Registry record / chunk SHA-256 | `d4e60e17b301fa4e9272a9457b64eb7ef3ff48950bac4672e990c50283273d43` / `d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483520 / 725298` identify `1244 NORTHPOINT DR`
on parcel `1939001`, current in that dataset on 2026-09-03.
`NAVY-SITE12-2015` lists the address with then-provider Catholic Charities;
`TIDA-JSCO-2026` includes it in the managed-premises exhibit as of 2025-07-01.
Provider and management records are not visible branding or occupancy proof.

- [March 2025 pano `VCf2k0IelYMBT0totpCPcg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=VCf2k0IelYMBT0totpCPcg&heading=298&pitch=0&fov=75), camera `37.8299969,-122.3728987`, heading `298.0°`: direct centroid ray at about `20.3 m`; supports the ESE entry-side family `20,22–23,26–29,31`. The camera-side label says 1242. A large tree hides the center and prevents an exact full-side schedule.

Target-bound observation: very pale cream/white horizontal siding, shallow
light roof, repeated upper rectangular windows, ochre/yellow door panels in
recessed full-height entry strips, and white privacy screens at ground level.
Exact cadence across the occluded center, unit count, other sides, alterations,
and occupancy remain unknown.

## Recognition boundary and handoff

This supports an **ochre-door/recessed-entry and white-screen component on the
ESE side**, not a complete long elevation. Close confusion: 1242/1243/1245
Northpoint and other pale Site 12 rows. Tileable pale siding, white trim, and
roof may be shared; the ochre entry strips and any later-proven opening cadence
stay local. Blocker for a full target-side prototype: **a dated rights-clear
view/elevation that clears the central tree and resolves the ESE sequence**.
No panorama pixels are retained or proposed as textures.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).
