# D6 receiver-first reference packets

Checked: **2026-09-04**

Scope: **the next 15 previously unpacketized standalone physical-building
entities in the stable 213-unit recognition-catalog order; bounded reference
research and reversible art handoff only**

This directory changes no source geometry, generated world, catalog, registry,
runtime material, prototype, or live receiver attachment. Child
`building_part` sources are not counted as physical entities. A ready packet
authorizes only a detached, observed-side study; it does not establish
recognition, as-built fidelity, whole-building completion, current occupancy,
or acceptance.

## Frozen cohort and readiness

The cohort was derived by walking `facade-recognition-catalog.json` in stored
unit order and excluding the 91 unit IDs already covered by the P1, P2, P3,
D1, D2, D3, D4, or D5 packet indexes. All 15 results are standalone direct
footprints with no part children. Three also have older Batch 04/05 target
specs; D6 consolidates those into the current per-entity packet format and
uses the later exact run-mapping correction where it narrows an old prose
claim.

| Order | Unit | Address / identity | Best target-bound evidence | Readiness |
| ---: | --- | --- | --- | --- |
| 1 | `w96215649` | 1212 Mariner Drive | Mar/Sep 2025 NNW front + ENE end; exact map | **target-side prototype-ready** |
| 2 | `w96215651` | 1202 Mariner Drive | Mar 2025 ENE frontage/corner | **target-side prototype-ready** |
| 3 | `w96215652` | 1220 Bayside Drive | Mar 2025 SW front; exact map | **target-side prototype-ready** |
| 4 | `w96215653` | 1227 Northpoint Drive | Mar 2025 E front + N end; exact map | **target-side prototype-ready** |
| 5 | `w96215655` | 1312 Gateview Avenue | Mar 2025 W frontage/canopies | **target-side prototype-ready** |
| 6 | `w96215656` | 1224 Bayside Drive | Mar 2025 NNW front | **target-side prototype-ready** |
| 7 | `w96215657` | 1307 Gateview Avenue | Mar 2025 ENE frontage; duplicate number resolved | **target-side prototype-ready** |
| 8 | `w96215658` | 1239 Northpoint Drive | Mar 2025 WSW front | **target-side prototype-ready** |
| 9 | `w96215659` | 1234 Northpoint Drive | Mar 2025 W canopy/front | **target-side prototype-ready** |
| 10 | `w96215660` | 1225 Northpoint Drive | Mar 2025 distant N end only | **component/end-side study ready** |
| 11 | `w96215661` | 1222 Bayside Drive | Mar 2025 NNW front | **target-side prototype-ready** |
| 12 | `w96215662` | 1139 Ozbourn Court | Jan 2023 NE end + Apr 2019 NW context | **component/end-and-side study ready** |
| 13 | `w96215666` | 1215 Bayside Drive | Mar 2025 W canopy/front | **target-side prototype-ready** |
| 14 | `w96215667` | frozen 1248 / current 1395 Gateview Court | Apr 2019 ESE front; currentness limited | **target-side historical prototype-ready** |
| 15 | `w96215668` | 1236 Northpoint Drive; frozen `abandoned` | Mar 2025 boarded NNW front | **target-side prototype-ready** |

Totals: **13 prototype-ready / 2 component-ready / 0 wholly
appearance-blocked**. The two component packets preserve useful target-bound
end/side evidence while refusing to fill missing long elevations from
neighbors. A City address row or management-list entry is administrative
evidence only. The observed standing, boarded 1236 does not erase its frozen
2020 `building=abandoned` tag, and neither fact establishes legal occupancy.

## Frozen local authority

| Input | Version / SHA-256 | Role |
| --- | --- | --- |
| `data/osm/treasure-island-2026-08-27.osm` | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549` | frozen source identity, lifecycle tags, and addresses |
| `discovery/FACADE_RECEIVER_INVENTORY.json` | `ti.facade-receiver-inventory/1`; `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f` | exact geometry, receiver, material, and run contract |
| `discovery/facades/facade-recognition-catalog.json` | `ti.facade-recognition-catalog/4`; `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` | sealed 213-unit order and claim state |
| `game/resources/facades/facade-runtime-registry.json` | `ti.facade-runtime-registry/4`; `c60e20fb625fa98809975f08357370d71c330443a7546d88fadfcd7df3584d19` | sealed direct runtime wall/record binding |
| `generated/world/manifest.json` | `ti.godot-world/2`; `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` | generated chunk authority |

Compass groups in each packet are exact outward-normal partitions from the
generated wall record. A camera-to-group association identifies only an
observed side family; it does not turn a written visual observation into exact
module endpoints. Receiver-relative endpoint/module preflight remains required
before any live placement.

## Validation result

**D6 packet audit: PASS.** A fresh catalog walk reproduced the same 15 IDs
after 91 prior packet IDs. All 15 are unique standalone units with zero part
children and exactly one direct wall plus one direct roof. The audit recomputed
`45` stable hashes (chunk file, full wall record, and wall geometry), checked
`255` packet fields against the sealed inventory/registry, reproduced all
`60` exact cardinal facing-run partitions, resolved all `15` local packet
links, and reproduced readiness totals `13 / 2 / 0`. The five frozen
authority-file hashes also matched the values above. No image or binary file
exists in this directory.

`tools/validate_godot_world.mjs` separately passed with `38` chunks, `739`
source rows, `729` physical objects, and generated content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
This read-only result does not promote a D6 packet or alter runtime state.

## Primary, official, and direct-observation sources

| ID | Source | What it supports | Boundary |
| --- | --- | --- | --- |
| `CITY-EAS` | [SF Enterprise Addressing System](https://data.sfgov.org/d/3mea-di5p) and [live API](https://data.sfgov.org/resource/3mea-di5p.json) | exact civic address records/points, parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54` | an address record does not prove survival, occupancy, or an unchanged facade |
| `CITY-XWALK` | [SF Treasure Island Address Change database](https://data.sfgov.org/d/ghba-upwh) and [live API](https://data.sfgov.org/resource/ghba-upwh.json) | checked rows mapping 1248 Gateview Court to 1395 Gateview Ct Units A–H | a crosswalk is not appearance/currentness evidence; the distant 1395 Gateview Avenue EAS row is excluded |
| `TIDA-JSCO-2026` | [TIDA/John Stewart Company agreement](https://media.api.sf.gov/documents/011426_6j_JSCO.pdf) | agreement effective 2026-02-01 and managed-premises exhibit as of 2025-07-01 | the scope covers occupied, vacant, and offline units; inclusion or absence is not tenancy, survival, or facade evidence |
| `GOOGLE-SV` | target-bound Google-hosted panoramas linked per packet | capture month, camera point, public-side visibility, and written appearance observation | direct observation only; labels on adjacent/camera-side rows are not target identities |

Each packet records panorama ID, capture month, camera coordinate, heading, and
a bounded receiver-facing association. Temporary local thumbnails were used
only for inspection and removed afterward. The repository retains **only
written observations and provenance**: no panorama, screenshot, thumbnail, or
other third-party pixels are copied, embedded, trained on, or proposed as
textures.

## Reusable families without identity collapse

- The 15 entities support one restrained northern-housing material library:
  tileable pale blue-gray/warm-gray horizontal siding, quiet white trim, muted
  shallow-roof fields, neutral glass, doors, privacy panels, and low-frequency
  wear. Imperfect early neutral-field tiling is acceptable; partial openings
  at seams, repeating high-contrast dirt, and address-specific marks are not.
- Flat-canopy infrastructure can be shared by 1202, 1234, 1215, and historical
  1248/1395. Canopy depth/extent, slender-post spacing, lower occlusion, and
  solid/void rhythm remain per entity. Canopy-free 1212, 1220, 1224, 1239, and
  1222 must not inherit it.
- Gabled-carport infrastructure can be shared by 1307 and 1312, but their
  central voids, canopy hierarchy, orientation, and unit cadence remain
  separate. 1227's ambiguous farther carport receives no module.
- 1139's centered projecting-gable/end component and 1236's dated boarded
  panels are local modules. Board panels and strong wear should be complete,
  nonrepeating overlays rather than baked into a repeating siding tile.
- Doors, windows, sliders, downspouts, canopies, fences, privacy boxes,
  board-ups, ends, and unique repairs stay complete modules. No neighboring
  facade supplies a missing target schedule.

## Packet index

- [`w96215649` / 1212 Mariner Drive](w96215649_1212_mariner_drive.md)
- [`w96215651` / 1202 Mariner Drive](w96215651_1202_mariner_drive.md)
- [`w96215652` / 1220 Bayside Drive](w96215652_1220_bayside_drive.md)
- [`w96215653` / 1227 Northpoint Drive](w96215653_1227_northpoint_drive.md)
- [`w96215655` / 1312 Gateview Avenue](w96215655_1312_gateview_avenue.md)
- [`w96215656` / 1224 Bayside Drive](w96215656_1224_bayside_drive.md)
- [`w96215657` / 1307 Gateview Avenue](w96215657_1307_gateview_avenue.md)
- [`w96215658` / 1239 Northpoint Drive](w96215658_1239_northpoint_drive.md)
- [`w96215659` / 1234 Northpoint Drive](w96215659_1234_northpoint_drive.md)
- [`w96215660` / 1225 Northpoint Drive](w96215660_1225_northpoint_drive.md)
- [`w96215661` / 1222 Bayside Drive](w96215661_1222_bayside_drive.md)
- [`w96215662` / 1139 Ozbourn Court](w96215662_1139_ozbourn_court.md)
- [`w96215666` / 1215 Bayside Drive](w96215666_1215_bayside_drive.md)
- [`w96215667` / frozen 1248, current 1395 Gateview Court](w96215667_1248_1395_gateview_court.md)
- [`w96215668` / 1236 Northpoint Drive](w96215668_1236_northpoint_drive.md)

## Owner-only dependency

There is **no exhausted owner-only dependency** for D6. Thirteen detached
target-side studies and two bounded component studies can proceed independently.
For fuller studies, 1225 needs a dated rights-clear close long-side view and
1139 needs a closer view separating one long face from its neighbors. Public
and automated source discovery remains available, so neither is added to
`HUMAN.md` and neither blocks the other 13.

