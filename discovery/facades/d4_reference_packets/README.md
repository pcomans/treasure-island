# D4 receiver-first reference packets

Checked: **2026-09-04**

Scope: **the next 15 previously unpacketized standalone physical-building
units in the stable 213-unit recognition-catalog order; reference research and
reversible art handoff only**

This directory changes no source geometry, generated world, catalog, registry,
runtime material, prototype, or live receiver attachment. Child
`building_part` sources are excluded as separate entities. A ready packet only
authorizes a detached, side-bounded study; it does not establish recognition,
as-built fidelity, whole-building completion, or acceptance.

## Frozen cohort and readiness

The cohort was derived by walking `facade-recognition-catalog.json` in stored
unit order and excluding the 61 unit IDs already covered by P1, P2, P3, D1, D2,
or D3 packet indexes. All 15 results are standalone direct footprints with no
part children.

| Order | Unit | Address / identity | Best target-bound evidence | Readiness |
| ---: | --- | --- | --- | --- |
| 1 | `w95934093` | 1432 Halibut Court | Apr 2019 front; cleared Mar 2025 | **historical target-side prototype-ready** |
| 2 | `w95934096` | 1412 Flounder Court | Mar 2025 front | **target-side prototype-ready** |
| 3 | `w95934097` | 1404 Sturgeon Street | Mar 2025 front | **target-side prototype-ready** |
| 4 | `w95934098` | 1435 Halibut Court | Apr 2019 front; cleared Mar 2025 | **historical target-side prototype-ready** |
| 5 | `w95934099` | 1433 Halibut Court | Apr 2019 front; cleared Mar 2025 | **historical target-side prototype-ready** |
| 6 | `w95934100` | 1430 Halibut Court | Mar 2025 front, partly vehicle-occluded | **target-side prototype-ready** |
| 7 | `w95934101` | 1409 Flounder Court | Mar 2025 front | **target-side prototype-ready** |
| 8 | `w95934102` | frozen number 1306; City crosswalk to 1306 Gateview | opposite row only; target side not recovered | **appearance-blocked** |
| 9 | `w95934103` | frozen number 1307; City crosswalk to 1307 Gateview | Mar 2025 frontage | **target-side prototype-ready** |
| 10 | `w95934104` | 1403 Sturgeon Street | Mar 2025 oblique side/end | **target-side prototype-ready** |
| 11 | `w95934106` | 1305 Gateview Avenue | Mar 2025 frontage | **target-side prototype-ready** |
| 12 | `w95934108` | 1405 Sturgeon Street | Mar 2025 front | **target-side prototype-ready** |
| 13 | `w95934110` | 1411 Flounder Court | Jun 2021 rear/side only | **component/side-study ready** |
| 14 | `w95934115` | 1413 Flounder Court | Mar 2021 end/rear only | **component/side-study ready** |
| 15 | `w95934122` | 1434 Halibut Court | Apr 2019 front; cleared Mar 2025 | **historical target-side prototype-ready** |

Totals: **12 prototype-ready / 2 component-ready / 1 appearance-blocked**.
Four of the 12 ready packets are intentionally historical: their April 2019
appearance can support the frozen 2020 snapshot representation, while March
2025 imagery shows that the physical structures are now absent. No packet turns
that historical evidence into a current-building claim.

## Frozen local authority

| Input | Version / SHA-256 | Role |
| --- | --- | --- |
| `data/osm/treasure-island-2026-08-27.osm` | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549` | frozen source identity and tags |
| `discovery/FACADE_RECEIVER_INVENTORY.json` | `ti.facade-receiver-inventory/1`; `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f` | exact geometry, receiver, material, and run contract |
| `discovery/facades/facade-recognition-catalog.json` | `ti.facade-recognition-catalog/3`; `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0` | stable 213-unit order and claim state |
| `game/resources/facades/facade-runtime-registry.json` | `0542acffc5ef8742326a78503938bc4883ff6d6e5896edeece1aa5c3988978af` | direct runtime wall/record binding |
| `generated/world/manifest.json` | `ti.godot-world/2`; `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` | generated chunk authority |

Compass groups in each packet are exact outward-normal partitions from the
generated receiver. A panorama-to-group association identifies the observed
side family, not every opening endpoint. Receiver-relative endpoint/module
preflight remains mandatory before any live art placement.

## Validation result

**D4 packet audit: PASS.** A fresh derivation found the same 15 IDs after 61
prior packet IDs; all 15 are unique standalone units with zero part children
and one direct wall plus one direct roof receiver. Validation recomputed `45`
stable hashes (chunk file, complete wall record, and wall geometry), checked
`225` required packet fields against the current catalog/inventory/registry,
resolved all `15` local packet links, and reproduced readiness totals
`12 / 2 / 1`. `tools/validate_godot_world.mjs` separately passed with generated
content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.

Remote HEAD audit: `25/26` unique URLs returned HTTP `200`; the MOHCD AMR PDF
returned `403` to the generic audit client but was indexed and read during the
research pass. That access distinction is retained rather than calling the
authoritative document missing. A repository-wide clean-compile registry test
also reported that the checked-in registry differs from a clean compile while
concurrent runtime/catalog work was active. D4 does not edit either input or
claim that unrelated workspace-wide check as green; the exact current
receiver/hash comparisons above remain passing.

## Primary, official, and direct-observation sources

| ID | Source | What it supports | Boundary |
| --- | --- | --- | --- |
| `CITY-EAS` | [SF Enterprise Addressing System](https://data.sfgov.org/d/3mea-di5p) and [live API](https://data.sfgov.org/resource/3mea-di5p.json) | exact civic address records, points, parcel `1939001`, and `data_as_of=2026-09-03T18:00:54` | an address point does not prove a structure survives, is occupied, or retains a facade |
| `TIDA-JSCO-2026` | [TIDA/John Stewart Company agreement](https://media.api.sf.gov/documents/011426_6j_JSCO.pdf) | managed-premises list as of 2025-07-01; 1305 removal effective 2026-02-01 | management scope is not demolition, occupancy, or appearance evidence |
| `TIDA-DIR-2025` | [March 2025 Director's Report](https://media.api.sf.gov/documents/031225_Directors_Report_pAUgRAm.pdf) | dated address-level service/311 references including 1305 Gateview and 1413 Flounder | a service entry does not prove the whole exterior or later survival |
| `MOHCD-AMR-2025` | [2025 AMR deadlines](https://media.api.sf.gov/documents/2025_AMR_Deadlines_for_MOHCD-Financed_Projects.pdf) | administrative “Halibut Court / 1432 Halibut Ct” project reference | a project address can persist after physical clearance |
| `NAVY-SITE12-2015` | [Navy Site 12 survey report, part 1](https://media.defense.gov/2022/Mar/22/2002960622/-1/-1/0/TI_2015_FINAL_SURVEY_COMPLETION_REPORT_RAD_SCOPING%20SURVEYS_OF_IR_SITE12_HOUSING_UNITS_PART_1OF_9.PDF) | shared housing-cohort history and two-storey slab-on-grade context | no exact per-address opening or color schedule |
| `NAVY-5YR-2020` | [Navy Second Five-Year Review](https://media.defense.gov/2022/Mar/25/2002963837/-1/-1/0/TI_20200805_SECOND_FIVE_YEAR_REVIEW%20%282%29.PDF) | Site 12 lifecycle/context | no exact facade schedule or proof of present condition |

Exterior observations are direct Google-hosted panoramas. Every packet records
the exact panorama ID, capture month, camera coordinate, heading, and bounded
receiver-facing association. The repository retains **only written
observations and provenance**: no panorama, thumbnail, screenshot, or other
third-party pixels are copied, embedded, or proposed as game textures.

## Reusable families without identity collapse

- The 475 m² Halibut/Flounder/Sturgeon rows share a useful low two-storey
  housing grammar: projecting garage/end volumes, a lower central connector,
  exterior stairs, shallow roofs, and sparse punched openings. Each packet
  freezes its own visible solid/void cue; no address inherits another unit's
  exact garage count, stair order, shutters, brick accents, or opening cadence.
- `w95934103` and `w95934106` support a Gateview siding/canopy family: mostly
  horizontal siding, low roofs, upper sliders, ground entries, and deep
  gable-roof porch/carport zones. `w95934102` remains blocked and may not inherit
  either schedule merely because its massing and address are nearby.
- Generated neutral plaster, siding, roof, trim, and low-frequency wear studies
  should target tileability. Imperfect early tiling is not a prototype gate,
  but opening fragments at seams, high-contrast repeating dirt, and baked-in
  address-specific features are unacceptable. Doors, windows, stairs, garage
  banks, canopies, gables, plinths, and unique repairs stay complete and local.

## Packet index

- [`w95934093` / 1432 Halibut Court](w95934093_1432_halibut_court.md)
- [`w95934096` / 1412 Flounder Court](w95934096_1412_flounder_court.md)
- [`w95934097` / 1404 Sturgeon Street](w95934097_1404_sturgeon_street.md)
- [`w95934098` / 1435 Halibut Court](w95934098_1435_halibut_court.md)
- [`w95934099` / 1433 Halibut Court](w95934099_1433_halibut_court.md)
- [`w95934100` / 1430 Halibut Court](w95934100_1430_halibut_court.md)
- [`w95934101` / 1409 Flounder Court](w95934101_1409_flounder_court.md)
- [`w95934102` / 1306 Gateview candidate](w95934102_1306_gateview_avenue.md)
- [`w95934103` / 1307 Gateview candidate](w95934103_1307_gateview_avenue.md)
- [`w95934104` / 1403 Sturgeon Street](w95934104_1403_sturgeon_street.md)
- [`w95934106` / 1305 Gateview Avenue](w95934106_1305_gateview_avenue.md)
- [`w95934108` / 1405 Sturgeon Street](w95934108_1405_sturgeon_street.md)
- [`w95934110` / 1411 Flounder Court](w95934110_1411_flounder_court.md)
- [`w95934115` / 1413 Flounder Court](w95934115_1413_flounder_court.md)
- [`w95934122` / 1434 Halibut Court](w95934122_1434_halibut_court.md)

## Owner-only dependency

There is **no owner-only dependency for the 12 detached target-side studies or
the two bounded component studies**. `w95934102` needs a dated,
rights-clear, target-identifiable exterior/elevation tied to an exact compass
side; automated research should continue before asking the owner. This is not a
hard stop for the other 14 and is not added to `HUMAN.md`.
