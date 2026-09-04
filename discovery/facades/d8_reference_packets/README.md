# D8 receiver-first reference packets

Checked: **2026-09-04**

Scope: **the next 15 previously unpacketized standalone physical-building
entities in the stable 213-unit recognition-catalog order; bounded reference
research and reversible art handoff only**

This directory changes no source geometry, generated world, catalog, registry,
runtime material, prototype, or live receiver attachment. Child
`building_part` sources are not counted as physical entities. A ready packet
authorizes only a detached study of observed evidence; it does not establish
recognition, as-built fidelity, whole-building completion, current occupancy,
or acceptance.

## Frozen cohort and readiness

The cohort was derived mechanically by walking the stored catalog order and
excluding the 121 unique source IDs already covered by P1, P2, P3, and D1–D7.
All 15 results are standalone direct footprints with no part children.

| Order | Unit | Address / bounded identity | Best target-bound evidence | Readiness |
| ---: | --- | --- | --- | --- |
| 1 | [`w96215693`](w96215693_1208_mariner_drive.md) | 1208 Mariner Drive | Mar 2025 N frontage | **target-side prototype-ready** |
| 2 | [`w96215694`](w96215694_1251_exposition_drive.md) | frozen 1251 / official 1251 Exposition Drive | Sep 2025 ENE upper/rear fragments | **component/upper-and-rear study ready** |
| 3 | [`w96215698`](w96215698_1228_1390_gateview_court.md) | frozen 1228 / current 1390 Gateview Court | Mar 2025 E frontage and canopy | **target-side prototype-ready** |
| 4 | [`w96665883`](w96665883_building_33e_candidate.md) | source-key building; observed 33E candidate | Mar 2025 SSE school wing | **target-side prototype-ready with identity caveat** |
| 5 | [`w96665884`](w96665884_1145_ozbourn_court.md) | 1145 Ozbourn Court | Apr 2019 SE mass/upper openings | **component/historical mass-and-upper-window study ready** |
| 6 | [`w96665885`](w96665885_1118_hutchins_court.md) | 1118 Hutchins Court | Mar 2025 SSW rear/long side | **target-side prototype-ready** |
| 7 | [`w96665887`](w96665887_1115_keppler_court.md) | 1115 Keppler Court | Mar 2025 WNW side fragments | **component/side-material-and-window study ready** |
| 8 | [`w96665889`](w96665889_building_292_candidate.md) | source-key building; spatial B292 candidate | Sep 2025 gate/tree occlusion only | **appearance-blocked** |
| 9 | [`w96665890`](w96665890_1111_keppler_court.md) | 1111 Keppler Court | Apr 2019 WNW frontage | **target-side historical prototype-ready** |
| 10 | [`w96665892`](w96665892_1137_mason_court.md) | 1137 Mason Court | Jan 2023 SE rear fragments | **component/rear-side study ready** |
| 11 | [`w96665893`](w96665893_1210_mariner_drive.md) | 1210 Mariner Drive | Mar 2025 N frontage | **target-side prototype-ready** |
| 12 | [`w96665897`](w96665897_1112_hutchins_court.md) | 1112 Hutchins Court | Apr 2019 SSW frontage | **target-side historical prototype-ready** |
| 13 | [`w96665899`](w96665899_1108_halyburton_candidate.md) | source-key building; strong 1108 Halyburton candidate | Mar 2025 SSW boarded facade | **target-side prototype-ready with identity caveat** |
| 14 | [`w96665902`](w96665902_ship_shape_850_avenue_i.md) | Ship Shape Community Center, 850 Avenue I | Apr 2019 WSW entrance; official 2025 currentness | **target-side historical prototype-ready** |
| 15 | [`w96665903`](w96665903_1124_reeves_court.md) | 1124 Reeves Court | Apr 2019 NW frontage | **target-side historical prototype-ready** |

Totals: **10 prototype-ready / 4 component-ready / 1 appearance-blocked**.
The identity caveats on `w96665883`, `w96665889`, and `w96665899` are
deliberate: target-bound observation or strong spatial/official context does
not substitute for an explicit official OSM-way crosswalk. The two candidate
packets with usable target facades may proceed under source key; B292 may not.

## Packet-time provenance and exact-current authority

| Input | Version / SHA-256 | Role |
| --- | --- | --- |
| `data/osm/treasure-island-2026-08-27.osm` | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549` | frozen identity, lifecycle tags, addresses, and source geometry |
| `discovery/FACADE_RECEIVER_INVENTORY.json` | `ti.facade-receiver-inventory/1`; `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f` | exact geometry, receiver, material, and run contract |
| `discovery/facades/facade-recognition-catalog.json` | `ti.facade-recognition-catalog/4`; `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` | sealed 213-unit order and claim state |
| D8 packet-time registry snapshot receipt (historical; bytes superseded) | `ti.facade-runtime-registry/4`; `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af` | immutable packet-time provenance only; validator verifies this recorded receipt, not current file bytes |
| `game/resources/facades/facade-runtime-registry.json` (current checkout) | `ti.facade-runtime-registry/4`; `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab` | exact-current direct binding and physical-unit recognition state, validated separately from the historical receipt |
| `generated/world/manifest.json` | `ti.godot-world/2`; `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` | generated chunk authority |

The `acc04a…` value is the genuine registry receipt captured when the D8
packet sealed. D8 does not duplicate those historical registry bytes, so the
validator checks that exact recorded receipt and its historical label rather
than comparing it with the moving current path. It separately hashes the
current registry as `dce268…` and verifies the unchanged catalog plus the
derived `213` physical units, `214` direct receivers, `215` source-record
memberships, and exact independently accepted `5/213` physical-unit rollup.
Neither Isle House part record is allowed to become a numerator unit.

Compass groups in each packet are exact outward-normal partitions recomputed
from the generated wall record. A camera-to-group statement identifies only a
visible side family; it does not turn written observation into exact module
endpoints. Receiver-relative endpoint/module preflight remains required before
live placement.

## Validation result

**D8 packet audit: PASS.** The validator re-walked catalog order after all 121 earlier packet IDs,
rejects part children, checks singular wall/roof bindings, recomputes chunk,
record, and wall-geometry hashes, reconstructs all facing-run partitions,
checks the individual packet fields and links, freezes readiness totals, and
rejects extra files (including images) in this directory. It reproduced all 15
IDs, recomputed `45` hashes, passed `300` exact field checks, reconstructed
`60` facing partitions, resolved all `15` packet links, and reproduced
readiness `10 / 4 / 1`. The historical registry receipt remained explicit and
immutable; the current catalog/registry separately matched `2b4579…` /
`dce268…` with exact `5/213` semantics. Run:

```sh
node discovery/facades/d8_reference_packets/validate_d8_packets.mjs
node tools/validate_godot_world.mjs
```

The generated-world validator separately passed with `38` chunks, `739` source
rows, `729` physical objects, and generated content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
In a bounded remote check, 26 of 28 distinct URLs returned HTTP `200`; the
direct Navy PDF and Navy catalog returned bot-facing `403` to curl while both
resolved through web search and the report's exact title/link remained indexed
by the official Navy site. The repository
retains no third-party pixels. Remote-source availability is a dated convenience
check, not a promise that an external endpoint will remain live or a grant of
texture rights.

## Primary, official, and direct-observation sources

| ID | Source | What it supports | Boundary |
| --- | --- | --- | --- |
| `CITY-EAS` | [SF Enterprise Addressing System](https://data.sfgov.org/d/3mea-di5p) and [live API](https://data.sfgov.org/resource/3mea-di5p.json) | exact civic address records/points, parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54` | address rows do not prove survival, occupancy, exact footprint binding, or unchanged facades |
| `CITY-XWALK` | [SF Updated Treasure Island Addresses and Building Numbers](https://data.sfgov.org/d/ghba-upwh) and [live API](https://data.sfgov.org/resource/ghba-upwh.json) | 1228→1390 Gateview Court, 1251 Exposition continuity, and Building 33 / Building 292 civic context | a crosswalk is not appearance/currentness evidence and does not name a frozen OSM way |
| `NAVY-SITE12-2015` | [U.S. Navy Site 12 survey report, part 1](https://media.defense.gov/2022/Mar/22/2002960622/-1/-1/0/TI_2015_FINAL_SURVEY_COMPLETION_REPORT_RAD_SCOPING%20SURVEYS_OF_IR_SITE12_HOUSING_UNITS_PART_1OF_9.PDF) and [official document catalog](https://www.bracpmo.navy.mil/BRAC-Bases/California/Former-Naval-Station-Treasure-Island/Documents/) | dated Site 12 address/provider table and housing-program context, including 1108 Halyburton | a 2015 provider table is not present tenancy, survival, or facade evidence; the direct PDF rejects automated curl while remaining listed in the Navy catalog |
| `CITY-HOUSING-2017` | [official housing building-area/unit table](https://sfgov.legistar.com/View.ashx?GUID=0D199683-D3E7-4244-86D7-5F99E90A89A9&ID=3271846&M=F) | reported gross floor area and unit count for the D8 housing addresses | administrative gross area does not replace the frozen footprint or prove present condition |
| `TIDA-JSCO-2026` | [TIDA/John Stewart Company agreement and eighth amendment](https://media.api.sf.gov/documents/011426_6j_JSCO.pdf) | managed-premises exhibit as of 2025-07-01 and the early-2026 removal of 1108 Halyburton | scope includes occupied, vacant, and offline units; inclusion/removal is not tenancy, facade, or demolition evidence |
| `TIDA-B33-2026` | [TIDA Building 33F lease material](https://media.api.sf.gov/documents/011426_6d_Aracely.pdf) | independent official context that Building 33 sub-identities belong to the former elementary-school compound | 33F context does not prove `w96665883` is 33E; the target's visible 33E mark remains direct observation |
| `TIDA-B292-2021` | [Treasure Island land/structures exhibit](https://sfgov.legistar.com/View.ashx?GUID=539832B2-4F13-490A-AA11-761C1EC0BB79&ID=9867738&M=F) | Building 292's SFPW on-island corporation-yard use | does not explicitly crosswalk B292 to `w96665889` and supplies no usable facade view |
| `TIDA-SHIP-SHAPE-2025` | [TIDA Director's Report / refresh announcement](https://media.api.sf.gov/documents/04.16.25_Directors_Report.pdf) and [City Capital Plan](https://onesanfrancisco.org/cap-plan-2026/economic-neighborhood-development-deferred-projects) | Ship Shape name, 850 Avenue I address, 2025 refresh, and current community-center role | current program evidence does not prove every 2019 surface or opening remained unchanged |
| `TIDA-DIRECTOR-2025` | [September 2025 TIDA Director's Report](https://media.api.sf.gov/documents/091025_Directors_Report.pdf) | dated address-specific report of broken windows at 1145 Ozbourn units | a service report is not a full facade survey or occupancy finding |
| `GOOGLE-SV` | target-bound Google-hosted panorama links in each packet | capture month, camera point, sightline, public-side visibility, and written appearance observation | direct observation only; provider labels and adjacent address labels are not target identity |

Each usable panorama packet records panorama ID, capture month, camera
coordinate, heading, distance, and a bounded facing-family association.
Temporary thumbnails were used only for inspection and removed afterward. The
repository retains **only written observations and provenance**: no panorama,
screenshot, thumbnail, or other third-party pixels are copied, embedded,
trained on, or proposed as textures.

## Reusable families without identity collapse

- Ten Site 12/northern-row entities can share a pragmatic tileable kit: pale
  gray/blue-gray horizontal siding, quiet white trim, shallow neutral roof,
  restrained glass, board-up panels, doors, privacy boxes, and low-frequency
  wear. Perfect seamlessness is not a gate for a first detached study, but
  repeating high-contrast dirt, clipped boards, and partial windows at seams
  are unacceptable.
- Canopies, gables, vents, doors, windows, sliders, downspouts, fences, privacy
  boxes, local repairs, and boarding stay complete geometry/decal modules.
  They are not baked into the repeating siding field.
- 1390 Gateview's continuous canopy/rust-post rhythm, 1210 Mariner's mixed
  doors, 1111 Keppler's yellow accents, 1112 Hutchins's blue accents, 1124
  Reeves's projecting center, and the 1108-candidate's boarded grid remain
  entity-specific cues even when base materials are shared.
- 1145 Ozbourn, 1115 Keppler, and 1137 Mason authorize only their observed
  components. No neighboring row supplies a tree/fence-hidden entry or opening
  schedule. 1251 Exposition similarly receives no invented lower facade.
- The Building 33E-candidate may share a school cream-panel/dark-window/red-
  spandrel system with other compound wings, while retaining its observed mark
  and cadence. The adjacent taller dark mass is excluded.
- Ship Shape needs a separate tileable tan ribbed-metal family plus modular
  dark beam/canopy, barred storefront, doors, sign, and landscape cues. The
  B292 candidate receives no generic warehouse or shed family until target-
  bound appearance evidence exists.

## Owner-only dependency

There is **no exhausted owner-only dependency** for D8. Ten detached prototypes
and four bounded component studies can proceed now. The B292 candidate remains
appearance-blocked, but public/official source discovery and future rights-clear
target capture are not inherently owner-only; it is therefore not added to
`HUMAN.md`. Its blocked packet is actionable as a precise do-not-invent boundary.
