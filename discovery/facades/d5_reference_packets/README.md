# D5 receiver-first reference packets

Checked: **2026-09-04**

Scope: **the next 15 previously unpacketized standalone physical-building
entities in the stable 213-unit recognition-catalog order; reference research
and reversible art handoff only**

This directory changes no source geometry, generated world, catalog, registry,
runtime material, prototype, or live receiver attachment. Child
`building_part` sources are not counted as separate physical entities. A ready
packet authorizes only a detached, side-bounded study; it does not establish
recognition, as-built fidelity, whole-building completion, or acceptance.

## Frozen cohort and readiness

The cohort was derived by walking `facade-recognition-catalog.json` in stored
unit order and excluding the 76 unit IDs already covered by the P1, P2, P3,
D1, D2, D3, or D4 packet indexes. All 15 results are standalone direct
footprints with no part children.

| Order | Unit | Address / identity | Best target-bound evidence | Readiness |
| ---: | --- | --- | --- | --- |
| 1 | `w95934123` | 1308 Gateview Avenue | Mar 2025 frontage/corner | **target-side prototype-ready** |
| 2 | `w95934124` | 1410 Flounder Court | Mar 2025 front | **target-side prototype-ready** |
| 3 | `w95934125` | 1317 Gateview Avenue; frozen `abandoned` | Mar 2025 fenced ENE side | **component/side-study ready** |
| 4 | `w95934126` | 1400 Sturgeon Street | Nov 2025 public corner | **target-side prototype-ready** |
| 5 | `w95934128` | 1406 Sturgeon Street | Mar 2025 front/corner | **target-side prototype-ready** |
| 6 | `w95934130` | source key only; no civic identity claimed | Mar 2025 NNW side | **target-side prototype-ready; identity unresolved** |
| 7 | `w95934132` | 1314 Gateview Avenue | distant merged row only | **appearance-blocked** |
| 8 | `w95934135` | 1431 Halibut Court | Mar 2025 front/corner | **target-side prototype-ready** |
| 9 | `w95934136` | 1301 Gateview Avenue | target occluded by 1303 | **appearance-blocked** |
| 10 | `w95934139` | 1303 Gateview Avenue | Mar 2025 frontage/corner | **target-side prototype-ready** |
| 11 | `w95934140` | 1408 Sturgeon Street | Mar 2025 front | **target-side prototype-ready** |
| 12 | `w95934142` | 1402 Sturgeon Street | Mar and Nov 2025 complementary sides | **target-side prototype-ready** |
| 13 | `w96215645` | 1122 Reeves Court | Jan 2023 fenced NW rear/end | **component/rear-side study ready** |
| 14 | `w96215646` | frozen 1230; City crosswalk to 1394 Gateview | Mar 2025 W frontage | **target-side prototype-ready** |
| 15 | `w96215648` | 1316 Gateview Avenue | Nov 2025 fenced NNW rear | **component/rear-side study ready** |

Totals: **10 prototype-ready / 3 component-ready / 2 appearance-blocked**.
The packets preserve lifecycle ambiguity: a live address or management-list
entry does not prove occupancy, survival after the last dated view, or an
unchanged facade. The standing March 2025 view of 1317 does not erase its
frozen 2020 `building=abandoned` tag, and that old tag does not prove its 2025
occupancy state.

## Frozen local authority

| Input | Version / SHA-256 | Role |
| --- | --- | --- |
| `data/osm/treasure-island-2026-08-27.osm` | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549` | frozen source identity, lifecycle tags, and addresses |
| `discovery/FACADE_RECEIVER_INVENTORY.json` | `ti.facade-receiver-inventory/1`; `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f` | exact geometry, receiver, material, and run contract |
| `discovery/facades/facade-recognition-catalog.json` | `ti.facade-recognition-catalog/3`; `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0` | stable 213-unit order and claim state |
| `game/resources/facades/facade-runtime-registry.json` | `ti.facade-runtime-registry/3`; `0542acffc5ef8742326a78503938bc4883ff6d6e5896edeece1aa5c3988978af` | direct runtime wall/record binding |
| `generated/world/manifest.json` | `ti.godot-world/2`; `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` | generated chunk authority |

Compass groups in each packet are exact outward-normal partitions from the
generated wall receiver. A camera-to-group association identifies only the
observed side family; it does not turn a written visual observation into exact
module endpoints. Receiver-relative endpoint/module preflight remains required
before any live placement.

## Validation result

**D5 packet audit: PASS.** A fresh catalog walk reproduced the same 15 IDs
after 76 prior packet IDs. All 15 are unique standalone units with zero part
children and exactly one direct wall plus one direct roof. The audit recomputed
`45` stable hashes (chunk file, full wall record, and wall geometry), checked
`255` packet fields against the current inventory/registry, reproduced all `60`
exact cardinal facing-run partitions, resolved all `15` local packet links, and
reproduced readiness totals `10 / 3 / 2`. The five frozen authority-file hashes
also matched the values above.

`tools/validate_godot_world.mjs` separately passed with `38` chunks, `739`
source rows, `729` physical objects, and generated content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
This read-only result does not promote any D5 packet or alter runtime state.

## Primary, official, and direct-observation sources

| ID | Source | What it supports | Boundary |
| --- | --- | --- | --- |
| `CITY-EAS` | [SF Enterprise Addressing System](https://data.sfgov.org/d/3mea-di5p) and [live API](https://data.sfgov.org/resource/3mea-di5p.json) | exact civic address rows, points, parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54` | an address row does not prove a building survives, is occupied, or retains a facade |
| `CITY-XWALK` | [SF Treasure Island Address Change database](https://data.sfgov.org/d/ghba-upwh) and [live API](https://data.sfgov.org/resource/ghba-upwh.json) | current-address crosswalks for 1301, 1303, and frozen 1230 to 1394; the source's Court/Avenue discrepancy is retained | a crosswalk is not appearance or occupancy evidence |
| `TIDA-JSCO-2026` | [TIDA/John Stewart Company agreement](https://media.api.sf.gov/documents/011426_6j_JSCO.pdf) | managed-premises list as of 2025-07-01 | inclusion or absence is not demolition, tenancy, or facade evidence |
| `NAVY-SITE12-2015` | [Navy Site 12 survey report, part 1](https://media.defense.gov/2022/Mar/22/2002960622/-1/-1/0/TI_2015_FINAL_SURVEY_COMPLETION_REPORT_RAD_SCOPING%20SURVEYS_OF_IR_SITE12_HOUSING_UNITS_PART_1OF_9.PDF) | Site 12 identity/history, including 1394 previously 1230 Gateview Court | no exact current opening, color, or condition schedule |
| `NAVY-5YR-2020` | [Navy Second Five-Year Review](https://media.defense.gov/2022/Mar/25/2002963837/-1/-1/0/TI_20200805_SECOND_FIVE_YEAR_REVIEW%20%282%29.PDF) | Site 12 lifecycle and redevelopment context | no per-building facade schedule or current survival claim |

Exterior descriptions come from direct Google-hosted panoramas. Each packet
records panorama ID, capture month, camera coordinate, heading, and a bounded
receiver-facing association. The research pass used temporary local screenshots
only for inspection and removed them afterward. The repository retains **only
written observations and provenance**: no panorama, screenshot, thumbnail, or
other third-party pixels are copied, embedded, or proposed as textures.

## Reusable families without identity collapse

- The 475 m² Sturgeon/Flounder/Halibut cohort supports a reusable low
  two-storey kit: projecting garage/end wings, central links, exterior stairs,
  shallow gable/hip roofs, sparse openings, garage banks, rails, and plinths.
  The kit is geometry and neutral-material infrastructure, not a common opening
  schedule. 1408's three-plus-three garage symmetry, 1431's right upper siding
  band, 1410's vehicle-obscured cadence, and 1402's partial-side evidence remain
  separate.
- The Gateview rows support a siding/canopy kit: tileable horizontal siding,
  white trim, shallow roofs, upper sliders, ground entries, deep gable canopies,
  fences, and pergola/carport components. Long-row dimensions and visible
  solid/void rhythms remain per entity. Blocked 1301 and 1314 receive no
  detailed schedule from ready 1303, 1308, 1316, or 1317.
- `w96215646` supports a distinct continuous flat-canopy module and slender-post
  rhythm; it should not be normalized into the gabled Gateview family. 1122's
  fenced NW component remains a separate Reeves-family seed, not a guessed
  front.
- Neutral siding, plaster, trim, roof, and low-frequency wear studies should
  target tileability. Imperfect early neutral-field tiling is not a prototype
  gate, but partial doors/windows at seams, high-contrast repeating dirt, and
  baked-in address-specific features are unacceptable. Doors, windows, stairs,
  garage banks, canopies, gables, fences, posts, and unique repairs stay
  complete local modules.

## Packet index

- [`w95934123` / 1308 Gateview Avenue](w95934123_1308_gateview_avenue.md)
- [`w95934124` / 1410 Flounder Court](w95934124_1410_flounder_court.md)
- [`w95934125` / 1317 Gateview Avenue](w95934125_1317_gateview_avenue.md)
- [`w95934126` / 1400 Sturgeon Street](w95934126_1400_sturgeon_street.md)
- [`w95934128` / 1406 Sturgeon Street](w95934128_1406_sturgeon_street.md)
- [`w95934130` / source-key-only housing footprint](w95934130_source_key_only.md)
- [`w95934132` / 1314 Gateview Avenue](w95934132_1314_gateview_avenue.md)
- [`w95934135` / 1431 Halibut Court](w95934135_1431_halibut_court.md)
- [`w95934136` / 1301 Gateview Avenue](w95934136_1301_gateview_avenue.md)
- [`w95934139` / 1303 Gateview Avenue](w95934139_1303_gateview_avenue.md)
- [`w95934140` / 1408 Sturgeon Street](w95934140_1408_sturgeon_street.md)
- [`w95934142` / 1402 Sturgeon Street](w95934142_1402_sturgeon_street.md)
- [`w96215645` / 1122 Reeves Court](w96215645_1122_reeves_court.md)
- [`w96215646` / frozen 1230, current 1394 Gateview](w96215646_1230_1394_gateview.md)
- [`w96215648` / 1316 Gateview Avenue](w96215648_1316_gateview_avenue.md)

## Owner-only dependency

There is **no exhausted owner-only dependency** for this batch. The ten
target-side and three component studies can proceed independently. The two
appearance-blocked targets need narrowly scoped source discovery:

- `w95934132`: a dated, rights-clear view/elevation that separates one exact
  1314 Gateview compass side from the neighboring rows.
- `w95934136`: a dated, rights-clear view/elevation that separates one exact
  1301 Gateview compass side from the nearer 1303 row.

Automated and public-record discovery remains available for both, so neither is
added to `HUMAN.md` and neither blocks the other 13 studies.
