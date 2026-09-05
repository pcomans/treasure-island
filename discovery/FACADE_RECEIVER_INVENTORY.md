# Facade receiver inventory

Checked: **2026-08-30**

Scope: frozen OSM and current generated/runtime world only; no live-currentness claim.

> **2026-09-05 B225 v8 current-authority notice:** this Markdown body and its
> companion JSON retain the earlier receiver/lifecycle inventory boundary and
> are not rewritten to impersonate the physical-unit recognition ledger. The
> coordinated authority is compiler `1.7.0`, catalog/runtime registry v8, and
> adapter contracts/loader v7: exactly `213` physical units, `214` direct wall
> receivers, and `8/213` independently accepted reference-recognizable units.
> Seven active adapters are fail-closed and provenance-only. B201 preserves
> `pre_b225_integration_live_parity` at `735/950/964/66,636/466/466`; B225 alone
> carries `current_integration_topology` at
> `735/952/967/67,716/466/466`. The B201 notice and numeric tables below are
> historical to their named boundaries unless a row explicitly says otherwise.

> **Historical B201 authority notice:** this Markdown body and its companion
> JSON retain the earlier receiver/lifecycle inventory boundary and are not
> rewritten to impersonate the later physical-unit recognition ledger. The
> current coordinated authority is
> `discovery/facades/facade-recognition-catalog.json` plus
> `game/resources/facades/facade-runtime-registry.json`: exactly `213`
> physical units, `214` direct wall receivers, and `7/213` independently
> accepted reference-recognizable units. Six active adapters are fail-closed
> and their review status is explicitly provenance-only; recognition derives
> from mapped physical-unit claims and independent receipts. Isle House and
> Navy Chapel preserve shared pre-B201 derived topology under
> `pre_b201_integration_live_parity`, while B201 alone carries
> `current_integration_topology` at exact current world
> `735/950/964/66,636/466/466`. Numeric tables below remain historical to this
> inventory's checked date unless a row explicitly says otherwise.

## Reconciliation

- **215 source entities**: 213 building footprints plus 2 building parts.
- **214 direct wall receivers** and **214 direct roof receivers**. The one-source exception is meshless Isle House parent `w1249412094`; parts `w1282547786` and `w1282547787` own its direct receivers.
- **4,971 visible wall runs**: 4,968 exterior-foundation runs plus 3 shared walls exposed above a lower part.
- Source joins, coverage, and direct-receiver uniqueness: **pass**.

## Runtime material lifecycle

The generated baseline remains `plaster_grey_04` on walls and `bitumen` on roofs. Target-specific runtime content exists on **12 independently accepted direct wall receivers**. Building 1's exact public-run ivory field and bounded recognizability composition are included with their documented limitations.

| Receiver | Current runtime scope/status | Limitation |
|---|---|---|
| Hawkins `building:w1249412093:wall` | Accepted WSW/SE facade preserved; conservative Hawkins fields cover ENE runs `10–15`, NNW runs `16–19`, and the step | ENE/NNW/step are intentionally module-free; stepped massing remains an approximation |
| Building 3 `building:w34313540:wall` | Accepted ENE facade language | Generated massing still limits whole-building resemblance |
| Isle House high `building-composite:w1249412094:w1282547786:wall` | Podium/tower fields on exterior runs `0–9`; tower-only fields on shared runs `10–12`; modules only on `5–7` | Runs `0–4` and `8–12` are module-free; low part `w1282547787` remains untouched |
| Navy Chapel `building:w291189336:wall` | Warm-cream homogeneous field on runs `9–10`: **2 runs / 16.362 m** | Albedo/roughness only; substrate, relief, modules, massing, and whole object remain blocked |
| Dormitory 369 `building:w291189926:wall` | Smooth warm field on runs `0–5`: **6 runs / 49.124 m** | Albedo/roughness only; five-tier/default-`6 m` conflict, modules, and whole object remain blocked |
| Treasure Island Community YMCA `building:w34313547:wall` | **`Y-EXACT-01` ACCEPT_WITH_DOCUMENTED_LIMITATION:** corrected wall-tangent dark aggregate/background field live on runs `3–11`: **9 runs / 101.046 m** | Material field only; substrate/grain scale remains unmeasured. Openings, panel joints, entry, louver, service door, mural, low wing, WSW/NNW, modules, massing, other sides, and whole-building resemblance remain reference-blocked or untouched |
| `w34313564` `building:w34313564:wall` | **ACCEPT_WITH_LIMITATION:** tan field on runs `5–9` (**5 / 87.651 m / 438.255 m²**) plus pale field on `10–19` (**10 / 141.340 m / 706.700 m²**). **KEEP_WITH_DOCUMENTED_LIMITATION:** exactly five render-only modules: PDOOR `r7@47.5 m` SSE tan; HWIN `r8@68.0 m` SSE tan; HWIN `r12@18.0 m` ENE pale; PDOOR `r16@32.0 m` NNW pale; HWIN `r17@54.0 m` NNW pale. | The five modules are `stylized/reference-derived production inference`; coordinates, true count, cadence, and pane scale are not surveyed/proven. Runs `0–4`, plinth, every additional module, WSW, pipes/eave/access geometry, massing/detail ownership, and whole-object resemblance remain blocked or separate. Modules own zero collision/navigation/spray. |
| `w34313515` `building:w34313515:wall` | **ACCEPT_WITH_LIMITATION:** pale field on runs `0–8` and `43–47`: **14 runs / 165.100 m / 1,816.100 m²**. **KEEP_WITH_DOCUMENTED_LIMITATION:** exactly four independently accepted complete `W34313515-BAY` module-atlas exemplars are live render-only at WSW `r0@6.0 m ±1.2 m`, WSW `r6@71.5 m ±3.0 m`, NNW `r44@14.0 m ±3.0 m`, and NNW `r47@55.5 m ±3.0 m`. | All four placements remain stylized/reference-derived production inference, not surveyed coordinates/count/cadence. Runs `9–42` remain placeholder and own zero BAYs. `VRECESS`, lower/recess ownership, openings, ENE/SSE, physical scale, completed elevations, facade language, massing and whole-object resemblance remain unaccepted. Modules own zero field/backing/collision/navigation/spray. |
| `w291196370` `building:w291196370:wall` | **ACCEPT_WITH_LIMITATION:** siding field on runs `8–10` and `17–22`: **9 runs / 97.893 m / 587.358 m²**. **KEEP_WITH_DOCUMENTED_LIMITATION:** exactly three independently accepted render-only complete module-atlas exemplars: WINSTACK `r8@5.5 m ±2.0 m` SSE; ENTRY `r10@32.0 m ±3.0 m` SSE; SERVICE `r20@39.5 m ±4.0 m` ENE. | The three placements are stylized/reference-derived production inference; physical scale, coordinates, true count and cadence are not surveyed. Runs `0–7`, `11–16`, and `23–35` remain placeholder. Cross-side transfer, every additional module, course scale, trim/accent/openings, short/service/yard facets, other sides, completed SSE/ENE elevations, massing and whole-object resemblance remain unaccepted. Modules own zero field/backing/collision/navigation/spray. |
| `w34313520` `building:w34313520:wall` | **KEEP_WITH_DOCUMENTED_LIMITATION:** independently accepted `W34313520-MAT-PALE` only on SSE runs `6–10`: **5 runs / 68.156 m / 751.441 m²**, using reviewed `0.95 m × 0.29 m` wall-tangent world-metre projection with `0.0 m` join-phase delta. Exactly one independently accepted complete render-only `W34313520-BAY` is live at `CAL-SSE-BAY-01`, run `7` midpoint `15.894477 m`; its mechanical safe center domain is `4.750000–27.038953 m` (half-span `11.144477 m`). | Field scale and BAY dimensions/center/count/cadence remain stylized/reference-derived production inference, not surveyed. Other runs/sides, runs `20–21`, wing/recess/lower family/endpoints, a second BAY, completed SSE, and whole-building resemblance remain blocked. BAY owns zero field/backing/collision/navigation/spray. |
| `w34313525` `building:w34313525:wall` | **KEEP_WITH_DOCUMENTED_LIMITATION:** independently accepted `W34313525-MAT-PALE` is live only on SSE runs `8–12` (**5 / 75.310910 m / 377.392952 m²**) and NNW runs `26–27` (**2 / 15.936560 m / 80.510358 m²**) at reviewed `0.88 m × 0.31 m` world-tangent scales. Exactly four independently accepted complete render-only type exemplars are live at the registered run midpoints: ROLLUP-PALE `r9`, ROLLUP-GRAY `r10`, PERSONNEL `r26`, and opaque HIGH-GROUP `r27`. | The accepted exact scope remains production inference: scale/dimensions/coordinates/count/cadence/sequence and full uncertainty-envelope containment remain unproven. HIGH-GROUP remains an unresolved window-or-grille proxy. Every other run/side/module, completed SSE/NNW elevations, cross-side transfer, massing/detail ownership and whole-building resemblance remain blocked. Modules own zero field/backing/collision/navigation/spray. |
| Building 1 / Treasure Island Museum `building:r16681702:wall` | **KEEP_WITH_DOCUMENTED_LIMITATION:** `B1-MAT-IVORY` is independently accepted on exactly verified public runs `0..56,58,60,93..96`: **63 runs / 206.908708 m / 4,350.511117 m²**. Exactly **45 complete motifs** are independently accepted (`8 WING / 24 CENTRAL / 2 PAV / 6 BASE / 1 DOOR / 4 BAND`). | Field coverage, motif scale/count/cadence/coordinates/sequence, completed elevation, as-built fidelity, and whole-building resemblance remain unsurveyed production inference. Runs `57/59/61`, `62..92`, `97..109`, inner ring, separate tower, entrance/canopy/emblems, massing/roof/source geometry, terrain, collision/navigation/spray, generated data, other buildings, and `r133351` are protected. |

The independently accepted exact-run set is exactly **9 target receivers / 11 homogeneous semantic field scopes / 130 exact runs / 1,024.828178 m / 10,476.046427 m²**. Six accepted receivers own **62 independently accepted live render-only module placements / 546 meshes / 546 surfaces / 6,552 triangles / 0 collision, navigation, or spray nodes**. Pending actual-world and recognizability review counts are zero. Runtime record-owned generated topology remains **729 records / 729 meshes / 739 surfaces / 48,389 triangles / 466 collider pairs**; loaded topology remains **729 / 1,278 / 1,288 / 55,067 / 466**. Raw generated source/data bytes remain unchanged.

Fire Station 48 `building:w764313741:wall` is **not live**. Its exact trial on runs `0,1,2,3,5,6,8,9,24,25` (**10 runs / 76.157 m**) was receiver-rejected and reverted. Runtime is one generated placeholder surface across all 26 runs; the prototype and rejection/removal evidence remain retained.

## Mutually exclusive lifecycle totals

These are exact mirrors of `facade_tracker_status.lifecycle_status` in the JSON inventory.

| Lifecycle | Sources | Direct receivers |
|---|---:|---:|
| Hawkins accepted facade + massing approximation | 1 | 1 |
| Building 3 accepted with limitation | 1 | 1 |
| Isle House high accepted all promised high-part sides | 1 | 1 |
| Accepted exact-run homogeneous material live with limitation | 9 | 9 |
| Isle House meshless parent | 1 | 0 |
| Isle House low untouched/unknown | 1 | 1 |
| Batch 02 standalone prototypes accepted, attachment-blocked | 4 | 4 |
| Oasis partial identity blocker | 1 | 1 |
| Personnel Support standalone prototype accepted, attachment-blocked | 1 | 1 |
| Building 600 corrected prototype rejected, no-live | 1 | 1 |
| Fire Station exact receiver rejected/reverted, zero-live | 1 | 1 |
| Research/spec evidence-blocked | 6 | 6 |
| 1212 Mariner prototypes accepted, no-live | 1 | 1 |
| 850 H, Bldg 461, and 1318 Gateview corrected prototypes accepted, no-live | 3 | 3 |
| Historical-reference prototypes, no current attachment | 2 | 2 |
| Batch 05 mapped material candidates, no prototype/live | 5 | 5 |
| Batch 05 historical-only/cleared, no prototype/live | 1 | 1 |
| Batch 05 ambiguous provenance, no prototype/live | 2 | 2 |
| Batch 06 queued for research | 3 | 3 |
| Not started | 170 | 170 |
| **Total** | **215** | **214** |

## Batch 02–06 disposition

| Batch | Prototype / review state | Live state |
|---|---|---|
| 02 | 6 targets; all have standalone material acceptance with limitations after the YMCA correction. Building 2, 490 Avenue, Star View, and Maceo May remain attachment-blocked. | Chapel remains accepted on runs `9–10` / `16.362 m`; YMCA `Y-EXACT-01` is accepted with documented limitation and live only on runs `3–11` / `101.046 m`. The other four are zero-live. Oasis has no prototype. |
| 03 | 3 targets. Personnel Support standalone field accepted but attachment-blocked. Building 600 correction is rejected because it flattened the coarse-mineral identity. Fire Station standalone field is retained, but exact receiver failed. Five other researched targets remain evidence-blocked with no material. | **Zero live.** Fire Station is restored to one placeholder surface across all 26 runs. |
| 04 | 7 prototype targets / 17 fields; all 17 standalone fields are accepted with limitations after the 850 H, Bldg 461, and target-bound 1318 Gateview corrections. 449 H and 810 D remain historical-only; 850 H and Bldg 461 remain medium-confidence no-live; Gateview trim is unmapped; 1212 regions/scale remain blocked. | Dormitory 369 only: runs `0–5` / `49.124 m`. |
| 05 | 8 researched/mapped targets; 5 high-confidence material candidate scopes, 1 historical-only/cleared, 2 ambiguous provenance. | Zero prototypes and zero live attachments. |
| 06 | Eight targets mapped: five produced seven accepted-with-scale-limitation standalone fields and eleven accepted standalone module motif assets; `W34313515-VRECESS` remains reference-blocked. Three sources remain queued in the canonical lifecycle. | Including Building 1's later accepted composition, six receivers / eight exact field scopes / 113 runs / 858.296178 m / 9,108.268427 m² and 62 module placements are independently accepted live. Plinth, other complements, additional/cross-side modules, unmapped/protected runs, completed elevations, as-built fidelity and whole objects remain unaccepted. |

## Batch 06 local queue

Exact order and rationale: `discovery/facades/NEXT_FACADE_BATCH_06.md`.

| # | Source | Frozen identity evidence | Direct wall receiver | Runs / visible length |
|---:|---|---|---|---:|
| 1 | `w1222514695` | unnamed; `building=shelter`; no address | `building:w1222514695:wall` | 5 / 26.589 m |
| 2 | `w1222720021` | unnamed; observation-tower tags; no address | `building:w1222720021:wall` | 10 / 25.260 m |
| 3 | `w34313515` | unnamed; `building=yes`, `height=11`; no address | `building:w34313515:wall` | 48 / 546.656 m |
| 4 | `w34313520` | unnamed; `building=yes`, `height=11`; no address | `building:w34313520:wall` | 34 / 376.239 m |
| 5 | `w34313525` | unnamed; `building=yes`, `height=5`, one level; no address | `building:w34313525:wall` | 30 / 354.736 m |
| 6 | `w34313564` | unnamed; `building=yes`, `height=5`; no address | `building:w34313564:wall` | 20 / 282.680 m |
| 7 | `w291196370` | unnamed; `building=yes`, `height=6`; no address | `building:w291196370:wall` | 36 / 258.421 m |
| 8 | `r133351` | unnamed; `building=retail`, one level; no address | `building:r133351:wall` | 78 / 541.627 m |

All eight were `not_started` immediately before selection. This table preserves the deterministic historical queue order; after Batch 06 evidence and review, `w34313515`, `w34313520`, `w34313525`, `w34313564`, and `w291196370` have independently accepted exact-field outcomes. `w1222514695`, `w1222720021`, and `r133351` remain queued. Frozen queue evidence itself proves no facade appearance, present-day identity, public access, or Street View availability.

## Prototype and live counts

- Batches 02–04: **16 prototype targets / 26 controlled material fields**.
- Final standalone material verdict after five corrections and the Gateview provenance repair: **25 accepted-with-limitation fields / 1 rejected-correctable field / 0 reference-blocked fields**.
- Batch 05: **0 prototypes / 0 live attachments**.
- Batch 06 plus Building 1: **8 independently accepted live semantic field scopes on 6 receivers / 113 runs / 62 independently accepted live render-only module placements on 6 receivers / 0 pending actual-world or recognizability review**. `W34313564-MAT-PLINTH` stays standalone-only, and `W34313515-VRECESS` is reference-blocked/unbuilt.
- Across all runtime facade systems: **12 independently accepted target-specific wall receivers**.

## Authoritative lifecycle evidence

- `discovery/facades/BATCH_02_04_MATERIAL_ART_REVIEW.md`
- `discovery/facades/BATCH_02_04_MATERIAL_CORRECTION_REVIEW.md` — final C5 provenance repair and acceptance supersede the older interim reference-blocked wording in the master review.
- `discovery/facades/HAWKINS_ISLE_ALL_SIDE_ART_REVIEW.md`
- `discovery/facades/ACCEPTED_MATERIAL_RUN_TRIALS_ART_REVIEW.md`
- `discovery/facades/TREASURE_ISLAND_COMMUNITY_YMCA_EXACT_RUN_ART_REVIEW.md` — predecessor `REJECT_CORRECTABLE` and bounded `Y-EXACT-01` brief.
- `discovery/facades/TREASURE_ISLAND_COMMUNITY_YMCA_Y_EXACT_01_REVIEW_ADDENDUM.md` — final exact-field `ACCEPT_WITH_DOCUMENTED_LIMITATION`; SHA-256 `b768953109b62786920fe6594f39776898540c84597125ad65249ac428482cb8`.
- `evidence/first-playable/accepted-material-run-trials-2026-08-29/README.md`
- `evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29/README.md`
- `evidence/first-playable/ymca-exact-run-trial-2026-08-29/README.md`
- `evidence/first-playable/ymca-exact-run-correction-2026-08-29/README.md` and `capture-manifest.json` — corrected six-view evidence and runtime identity.
- `discovery/facades/BATCH_06_PROTOTYPE_SET_01_ART_REVIEW.md` — five standalone fields accepted with scale limitation; predecessor module rejection.
- `discovery/facades/BATCH_06_PROTOTYPE_SET_01_MODULE_CORRECTION_ART_REVIEW.md` — six corrected modules accepted only as standalone prototypes; SHA-256 `70f6a0e1e9ece07d162aa669aa89e4f4a9a8b19b1785eb7fb91efc0dc8f6aded`.
- `evidence/first-playable/batch-06-exact-receiver-trials-2026-08-30/README.md` and `capture-manifest.json` — exact field partitions and `729 / 736` runtime topology; manifest SHA-256 `034b6ef3ad0e85b81a2565a9443172bec3da9364ed29ab5b4cc6b34258e72449`.
- `discovery/facades/BATCH_06_EXACT_RECEIVER_FIELD_TRIALS_ART_REVIEW.md` — four exact homogeneous fields independently `ACCEPT_WITH_LIMITATION`; SHA-256 `ce213c3fb37529eeaefe01da1b555b44b4ea58ab10b36b2150002b8edf6d2bb7`.
- `discovery/facades/W34313564_EXACT_MODULE_CALIBRATION_ART_REVIEW.md` and `discovery/facades/W34313564_MODULE_CALIBRATION_CORRECTION_ART_REVIEW.md` — predecessor rejection plus corrected five-placement detached eligibility; final correction-review SHA-256 `a8f1396e2d126c0c38b37edf770df975c4fa95e25e34fb2c7c1e766630fd1591`.
- `evidence/first-playable/w34313564-live-modules-2026-08-30/README.md` and `capture-manifest.json` — exact five-placement loaded-world evidence and `729 / 763 / 770 / 48,797 / 466` topology; manifest SHA-256 `0775a926217634ee41879920278019e212c2901ce90a33ba07e46cce39821adb`.
- `discovery/facades/W34313564_LIVE_MODULES_ART_REVIEW.md` — exact live scope independently `KEEP_WITH_DOCUMENTED_LIMITATION`; SHA-256 `4e97439912870140d58e8ed877e195d64df3b758270c0c374c7838f9443d27f2`.
- `evidence/first-playable/batch-06-w34313515-bay-calibration-2026-08-30/README.md` and `capture-manifest.json` — detached four-placement WSW/NNW BAY calibration evidence; manifest SHA-256 `9b9e7e9d21539009cfc401f22017220bf3f2224061b57c0d48819325cab7f09b`.
- `discovery/facades/W34313515_BAY_CALIBRATION_ART_REVIEW.md` — all four fixed placement transforms independently `ACCEPT_WITH_DOCUMENTED_LIMITATION`; SHA-256 `894873141bc589e51bb8ec65e06455461e17a809a18608253db59c7e49e5fedd`.
- `evidence/first-playable/w34313515-live-modules-2026-08-30/README.md`, `capture-manifest.json`, and `asset-inventory.sha256` — actual loaded-world four-BAY evidence, `+84 / +84 / +1,008 / +0` delta and `729 / 847 / 854 / 49,805 / 466` loaded topology; manifest SHA-256 `27400a0162e049fbee11e1cb7de5d0177fdf8e6881cd6f390beb49d94647dd11`, current-state asset-ledger SHA-256 `46058f75a6232ba01b68a12f0f9e7051c29d3f61e08aaa12eaeb4f82e1263897`.
- `discovery/facades/W34313515_LIVE_MODULES_ART_REVIEW.md` — exact four-placement actual-world scope independently `KEEP_WITH_DOCUMENTED_LIMITATION`; SHA-256 `cebfe328ec5372f8c0d440fcf59bb0b9bae7a490998ed373d8f5c5e418b5b94e`.
- `evidence/first-playable/batch-06-w291196370-module-calibration-2026-08-30/README.md` and `capture-manifest.json` — detached three-motif SSE/ENE calibration evidence; manifest SHA-256 `5a92402a7a6742c5c67fa18e904c1af5055c9aaacf6e3001ebb20fb26e738df0`.
- `discovery/facades/W291196370_MODULE_CALIBRATION_ART_REVIEW.md` — all three fixed placement transforms independently `ACCEPT_WITH_DOCUMENTED_LIMITATION` for bounded live proof; SHA-256 `967ab07d109096a743be01fb0bce959280967f5eab65c82ac0652eb5dcd3023b`.
- `evidence/first-playable/w291196370-live-modules-2026-08-30/README.md`, `capture-manifest.json`, and `asset-inventory.sha256` — actual loaded-world three-motif evidence, `+24 / +24 / +288 / +0` delta and `729 / 871 / 878 / 50,093 / 466` loaded topology; manifest SHA-256 `323fab0ee444aae098a815ee22e2e72a0fac2c16bdfd867d6d9b9d0e74b599b3`, current-state asset-ledger SHA-256 `c3bb89b100cc14841f81719d4df1d463084aa679ea89ec2883193b7e12c68cac`.
- `discovery/facades/W291196370_LIVE_MODULES_ART_REVIEW.md` — exact three-placement actual-world scope independently `KEEP_WITH_DOCUMENTED_LIMITATION`; SHA-256 `410ffa891bdebe92d689155b4c7986f7e9a07bef1028900cd0dac00bcb8222ca`.
- `evidence/first-playable/batch-06-w34313520-standalone-prototypes-2026-08-30/README.md` and `discovery/facades/W34313520_STANDALONE_PROTOTYPE_ART_REVIEW.md` — accepted standalone pale field and complete BAY source assets.
- `evidence/first-playable/batch-06-w34313520-exact-receiver-calibration-2026-08-30/README.md` and `discovery/facades/W34313520_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md` — exact SSE runs `6..10` plus one run-7-midpoint BAY accepted for bounded live proof; review SHA-256 `555eb2fb3a397341cc6ed6412a627b9d84fe8c806de756c2ed4cbd8a3a652870`.
- `evidence/first-playable/w34313520-live-field-and-bay-2026-08-30/README.md`, `capture-manifest.json`, `evidence-correction-proof.json`, and `runtime-topology-delta.json` — 11-view native actual-loaded-world proof, including every field join, 56.834 m macro span, BAY close/oblique, ordinary/context, changed light, and whole island. Corrected manifest SHA-256 `939cb4a72a839d0ba5a841a3da5accf283acb0a97068093ea985c226f1a401be`; evidence-correction proof SHA-256 `2c98de67622494a75147b80d1d22d63b0abb9c0b0b20ee2d5c5f13e96591f173`.
- `discovery/facades/W34313520_LIVE_FIELD_AND_BAY_ART_REVIEW.md` and `discovery/facades/W34313520_LIVE_EVIDENCE_CORRECTION_ART_REVIEW.md` — predecessor correction request followed by corrected-evidence `ACCEPT` and exact lifecycle authorization for the one field scope and one BAY; final correction-review SHA-256 `958130a3cc09cf129186562a9e54f4157bbfad3f99846a695238c3ee4b6b1a46`.
- `discovery/facades/W34313525_STANDALONE_PROTOTYPE_ART_REVIEW.md` and `discovery/facades/W34313525_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md` — all five standalone assets and exactly two field scopes/four placement transforms accepted for bounded live proof; calibration-review SHA-256 `d19fdae403d11117b13ce1fe04476f0d62edfdd3adbc8238936845e481831de2`.
- `evidence/first-playable/w34313525-live-fields-and-modules-2026-08-30/README.md`, `capture-manifest.json`, `runtime-topology-delta.json`, and `asset-inventory.sha256` — 15-view actual loaded-world proof of all five joins, four complete motifs, both ordinary side scopes, multi-side context, changed light on both sides and whole island; loaded topology `729 / 924 / 934 / 50,729 / 466`, delta `+38 / +40 / +456 / +0`; current corrected manifest SHA-256 `bf97fc1df3b80e7d90cda9d9ca2cc3586681c7d3f3192cf76040835f51e49a1a`, current lifecycle ledger SHA-256 `88fec3d4bbabca5bfd0822db2e70b09e3f8d1608b00a5c29096a9adb7a159d86`.
- `discovery/facades/W34313525_LIVE_FIELDS_AND_MODULES_ART_REVIEW.md` — both exact field scopes and all four registered placements independently `KEEP_WITH_DOCUMENTED_LIMITATION`; lifecycle authorization SHA-256 `d11041e1abf41fc11843d2f2631e4c33da25f8fc565f93e6ee822589ad229f45`.
- `evidence/first-playable/hawkins-isle-all-side-coverage-2026-08-29/README.md`
- `discovery/facades/NEXT_FACADE_BATCH_06.md`

The detailed per-source identity, frozen geometry, massing, run orientation, receiver ownership, research paths, mappings, prototype paths, gaps, and untouched scopes remain authoritative in `discovery/FACADE_RECEIVER_INVENTORY.json`.
