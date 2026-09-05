# D7 receiver-first reference packets

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
unit order and excluding the 106 unit IDs already covered by the P1, P2, P3,
D1, D2, D3, D4, D5, or D6 packet indexes. All 15 results are standalone direct
footprints with no part children.

| Order | Unit | Address / identity | Best target-bound evidence | Readiness |
| ---: | --- | --- | --- | --- |
| 1 | `w96215669` | 1238 Northpoint Drive | Mar 2025 NNE frontage | **target-side prototype-ready** |
| 2 | `w96215670` | frozen 1246 / current 1397 Gateview Court | Mar 2025 WNW family; exact civic crosswalk; point conflict retained | **target-side prototype-ready** |
| 3 | `w96215671` | 1244 Northpoint Drive | Mar 2025 ESE entry components; center tree-occluded | **component/entry-side study ready** |
| 4 | `w96215672` | 1201 Bayside Drive | Mar 2025 NE frontage | **target-side prototype-ready** |
| 5 | `w96215673` | 1232 Northpoint Drive | Mar 2025 W frontage/canopy | **target-side prototype-ready** |
| 6 | `w96215674` | 1241 Northpoint Drive | Mar 2025 WSW frontage/canopy | **target-side prototype-ready** |
| 7 | `w96215676` | 1143 Ozbourn Court | Apr 2019 SE frontage | **target-side historical prototype-ready** |
| 8 | `w96215677` | 1206 Mariner Drive | Mar 2025 N frontage | **target-side prototype-ready** |
| 9 | `w96215678` | 1205 Bayside Drive | Mar 2025 E frontage/awning | **target-side prototype-ready** |
| 10 | `w96215680` | 1219 Mariner Drive | Mar 2025 S frontage | **target-side prototype-ready** |
| 11 | `w96215682` | 1221 Mariner Drive | Mar 2025 S frontage/canopy | **target-side prototype-ready** |
| 12 | `w96215685` | 1226 Bayside Drive | Mar 2025 E frontage/shallow awnings | **target-side prototype-ready** |
| 13 | `w96215688` | 1240 Northpoint Drive | Mar 2025 ENE frontage/canopy | **target-side prototype-ready** |
| 14 | `w96215690` | 1141 Ozbourn Court | Apr 2019 NE component evidence; dense foliage | **component/entry-and-window study ready** |
| 15 | `w96215691` | 1204 Mariner Drive | Mar 2025 NNE frontage/segmented canopy | **target-side prototype-ready** |

Totals: **13 prototype-ready / 2 component-ready / 0 wholly
appearance-blocked**. The two component packets preserve useful target-bound
evidence while refusing to fill foliage-hidden long elevations from adjacent
rows. April 2019 imagery for 1141 and 1143 is explicitly historical; only 1143
exposes enough of one side for a dated prototype. A City address, management
exhibit, conversion-plan reference, or enforcement agenda is administrative
evidence only.

## Packet-time provenance and current authority

| Input | Version / SHA-256 | Role |
| --- | --- | --- |
| `data/osm/treasure-island-2026-08-27.osm` | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549` | frozen identity, lifecycle tags, addresses, and source geometry |
| `discovery/FACADE_RECEIVER_INVENTORY.json` | `ti.facade-receiver-inventory/1`; `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f` | exact geometry, receiver, material, and run contract |
| D7 packet-time catalog snapshot receipt (historical; bytes superseded) | `ti.facade-recognition-catalog/4`; `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` | immutable packet-time provenance only; validator verifies this recorded receipt, not current file bytes |
| D7 packet-time registry snapshot receipt (historical; bytes superseded) | `ti.facade-runtime-registry/4`; `c60e20fb625fa98809975f08357370d71c330443a7546d88fadfcd7df3584d19` | immutable packet-time provenance only; validator verifies this recorded receipt, not current file bytes |
| D7 packet-time recognition rollup | `5/213` | immutable five-unit acceptance state at the v4 authority boundary; not a claim about current compiler output |
| `discovery/facades/facade-recognition-catalog.json` (current checkout) | `ti.facade-recognition-catalog/6`; SHA-256 emitted by validator | used only to rederive the exact 15-ID cohort and order |
| `game/resources/facades/facade-runtime-registry.json` (current checkout) | `ti.facade-runtime-registry/6`; SHA-256 emitted by validator | used only to verify those 15 current direct bindings; global counts and recognition rollup remain compiler-owned |
| `generated/world/manifest.json` | `ti.godot-world/2`; `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` | generated chunk authority |

The `2b4579…` catalog, `c60e20…` registry, and `5/213` rollup are the genuine
D7 packet-time receipts. D7 does not duplicate those historical bytes, so the
validator checks the exact recorded receipts and historical labels rather than
comparing them with moving current paths. It separately loads and hashes the
current schema-v6 catalog and registry only to rederive the exact D7 cohort
order and verify those 15 direct bindings. Global current unit, receiver,
source-membership, acceptance, and recognition-rollup gates belong solely to
`tools/build_facade_recognition_registry.mjs --check`.

Compass groups in each packet are exact outward-normal partitions from the
generated wall record. A camera-to-group association identifies only an
observed side family; it does not turn a written visual observation into exact
module endpoints. Receiver-relative endpoint/module preflight remains required
before any live placement.

## Validation result

**D7 packet audit: PASS.** A fresh catalog walk reproduced the same 15 IDs
after 106 prior packet IDs. All 15 are unique standalone units with zero part
children and exactly one direct wall plus one direct roof. The audit recomputed
`45` hashes (chunk file, full wall record, and wall geometry), checked the
packet contract fields against sealed inventory/registry data, reproduced all
`60` exact facing-run partitions, resolved all `15` packet links, and
reproduced readiness totals `13 / 2 / 0`. The unchanged file-backed authorities
matched their hashes; the historical catalog, registry, and `5/213` receipts
remained explicit and immutable; and the current schema-v6 catalog/registry
reproduced the exact 15-ID order and direct bindings. Their moving SHA-256
values are emitted by each validator run and are not misrepresented as
packet-time receipts. No image or binary file exists in this directory.
All `25` distinct remote source/panorama links returned HTTP `200` or `206` in
a bounded read-only check on 2026-09-04; that dated availability check is not a
promise that a third-party endpoint will remain live.

`tools/validate_godot_world.mjs` separately passed with `38` chunks, `739`
source rows, `729` physical objects, and generated content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
This read-only result does not promote a D7 packet or alter runtime state.

## Primary, official, and direct-observation sources

| ID | Source | What it supports | Boundary |
| --- | --- | --- | --- |
| `CITY-EAS` | [SF Enterprise Addressing System](https://data.sfgov.org/d/3mea-di5p) and [live API](https://data.sfgov.org/resource/3mea-di5p.json) | exact civic address records/points, parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54` | an address record does not prove survival, occupancy, or an unchanged facade; the distant 1397 Gateview Avenue point is excluded from the frozen 1246/1397 Court footprint |
| `CITY-XWALK` | [SF Treasure Island Address Change database](https://data.sfgov.org/d/ghba-upwh) and [live API](https://data.sfgov.org/resource/ghba-upwh.json) | checked rows mapping 1246 Gateview Court to 1397 Gateview Ct Units A–H | a crosswalk is not appearance/currentness evidence |
| `NAVY-SITE12-2015` | [U.S. Navy Site 12 survey report, part 1](https://media.defense.gov/2022/Mar/22/2002960622/-1/-1/0/TI_2015_FINAL_SURVEY_COMPLETION_REPORT_RAD_SCOPING%20SURVEYS_OF_IR_SITE12_HOUSING_UNITS_PART_1OF_9.PDF) | dated address/provider table for all 15 frozen identities, including 1246→1397 | a 2015 provider list is not present tenancy, survival, or facade evidence |
| `TIDA-JSCO-2026` | [TIDA/John Stewart Company agreement](https://media.api.sf.gov/documents/011426_6j_JSCO.pdf) | agreement effective 2026-02-01 and managed-premises exhibit as of 2025-07-01 for 12 addresses | scope covers occupied, vacant, and offline units; inclusion/absence is not tenancy, survival, or facade evidence |
| `TIDA-CHP-2024` | [TIDA/Community Housing Partnership fourth amendment](https://media.api.sf.gov/documents/061224_Item_6b_CHP.pdf) | dated administrative inclusion of 1205 Bayside, effective 2024-07-01 | no present tenancy or appearance claim |
| `CITY-CONVERSION` | [City-hosted conversion-plan overview](https://media.api.sf.gov/documents/1_Conversion_Plan_Overview_Senator_Final_003_002.pdf) | dated program context for 1226 Bayside and 1395–1397 Gateview | program context is not exact footprint, occupancy, or appearance proof |
| `TIDA-DIRECTOR-2023` | [TIDA Director's Report](https://media.api.sf.gov/documents/071223_Directors_Report.pdf) | dated address-specific administrative reference for 1226 Bayside | not present lifecycle or facade evidence |
| `DBI-HEARING-2026` | [DBI code-enforcement hearing agenda](https://media.api.sf.gov/documents/DIR_Hearing_3-3-2026_Code_Enforcement.pdf) | dated 1397 Gateview Avenue administrative reference | does not resolve the 363 m civic-point conflict or prove the frozen Court footprint's facade |
| `GOOGLE-SV` | target-bound Google-hosted panoramas linked per packet | capture month, camera point, public-side visibility, and written appearance observation | direct observation only; adjacent/camera-side labels are not target identity |

Each packet records panorama ID, capture month, camera coordinate, heading,
distance, and a bounded receiver-facing association. Temporary local thumbnails
were used only for inspection and removed afterward. The repository retains
**only written observations and provenance**: no panorama, screenshot,
thumbnail, or other third-party pixels are copied, embedded, trained on, or
proposed as textures.

## Reusable families without identity collapse

- The 15 entities extend one restrained northern-housing material library:
  tileable pale blue-gray/warm-gray horizontal siding, quiet white trim, muted
  shallow-roof fields, neutral glass, doors, privacy panels, and low-frequency
  wear. Imperfect early neutral-field tiling is acceptable; partial openings
  at seams, repeating high-contrast dirt, and address-specific marks are not.
- Deep flat-canopy infrastructure can be shared by 1232 and 1241 Northpoint,
  1221 and 1204 Mariner, and 1240 Northpoint. Canopy extent/segmentation, post
  spacing, plane steps, lower occlusion, and entry/opening rhythm remain local.
- Canopy-free infrastructure can be shared by 1238 Northpoint, 1201 Bayside,
  1206 and 1219 Mariner. Their door colors, privacy breaks, steps, and opening
  schedules remain target-specific.
- 1205 and 1226 Bayside may share a shallow-awning structural family, but not
  exact lengths, roof treatment, plane steps, or opening/entry cadence.
- 1244's ochre recessed-entry strip is a local component. 1141/1143 may share
  quiet Ozbourn material components, but foliage-hidden 1141 receives no
  transferred schedule or 1143 color claims.
- Doors, windows, sliders, downspouts, canopies, fences, privacy boxes, local
  repairs, and wear remain complete modules. They are not baked into repeating
  siding textures, and no neighboring facade supplies a missing target schedule.

## Packet index

- [`w96215669` / 1238 Northpoint Drive](w96215669_1238_northpoint_drive.md)
- [`w96215670` / frozen 1246, current 1397 Gateview Court](w96215670_1246_1397_gateview_court.md)
- [`w96215671` / 1244 Northpoint Drive](w96215671_1244_northpoint_drive.md)
- [`w96215672` / 1201 Bayside Drive](w96215672_1201_bayside_drive.md)
- [`w96215673` / 1232 Northpoint Drive](w96215673_1232_northpoint_drive.md)
- [`w96215674` / 1241 Northpoint Drive](w96215674_1241_northpoint_drive.md)
- [`w96215676` / 1143 Ozbourn Court](w96215676_1143_ozbourn_court.md)
- [`w96215677` / 1206 Mariner Drive](w96215677_1206_mariner_drive.md)
- [`w96215678` / 1205 Bayside Drive](w96215678_1205_bayside_drive.md)
- [`w96215680` / 1219 Mariner Drive](w96215680_1219_mariner_drive.md)
- [`w96215682` / 1221 Mariner Drive](w96215682_1221_mariner_drive.md)
- [`w96215685` / 1226 Bayside Drive](w96215685_1226_bayside_drive.md)
- [`w96215688` / 1240 Northpoint Drive](w96215688_1240_northpoint_drive.md)
- [`w96215690` / 1141 Ozbourn Court](w96215690_1141_ozbourn_court.md)
- [`w96215691` / 1204 Mariner Drive](w96215691_1204_mariner_drive.md)

## Owner-only dependency

There is **no exhausted owner-only dependency** for D7. Thirteen detached
target-side studies and two bounded component studies can proceed now. Fuller
studies for 1244 and 1141 need dated rights-clear views that clear the central
foliage and resolve their long-side schedules. Public and automated source
discovery remains available, so neither is added to `HUMAN.md` and neither
blocks the other 13.
