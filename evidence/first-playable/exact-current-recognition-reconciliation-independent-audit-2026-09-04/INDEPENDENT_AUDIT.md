# Exact-current facade recognition reconciliation — independent audit

Date: 2026-09-04

Reviewer: `/root/d6_reference_research`

Scope: independent read-only audit of the sealed catalog, generated registry,
adapter contracts, runtime loader boundary, five acceptance receipts, and
current topology/test oracles. This audit did not edit production or generated
artifacts.

## Verdict

- **PASS — reconciliation correctness and authoritative metric.** The exact
  current reference-recognizable set is five physical entities out of 213.
  `5/213` is authoritative for this sealed state.
- **PASS — ledger partition, acceptance provenance, fail-closed adapter
  boundary, compiler determinism, runtime topology, and target-specific source
  and mounted-package behavior.**
- **FAIL — a blanket claim that every relevant checked-in focused regression is
  currently green.** Two older Building 1 regression tests still pin the
  superseded pre-public-front hero topology and fail against the accepted
  current hero. The current Building 1 hero contract and full-runtime contract
  pass, so this is test-oracle debt rather than a sixth/fewer accepted-unit
  discrepancy.
- **Overall: PASS_WITH_DISCREPANCIES.** The discrepancies are recorded below;
  none changes the `5/213` numerator or denominator.

## Independently recomputed population

The frozen receiver inventory contains 215 unique source records. Its
relationship partition is 212 standalone buildings, one composite parent, and
two `building_part` children. There are 214 unique direct wall receiver keys
and 4,971 visible wall runs.

The catalog correctly rolls that source population into 213 physical units:

| Dimension | Recomputed result |
| --- | ---: |
| Source-record memberships | 215 |
| Direct wall receivers | 214 |
| Standalone physical units | 212 |
| Composite physical units | 1 |
| Total physical recognition units | 213 |

The Isle House membership is exactly the parent source `w1249412094` plus part
sources `w1282547786` and `w1282547787`. The parent is counted once as
`physical-building:w1249412094`; neither part source has a physical-unit row.
Both part sources remain direct receiver records, which explains why receiver
and unit totals are different.

## Accepted set and receipt binding

Exactly these five units have `reference_recognizable=accepted`; no other unit
does:

| Physical unit | Acceptance receipt SHA-256 | Result |
| --- | --- | --- |
| `physical-building:r16681702` | `b12858438d6522b7f3cf42fa06392648d16ee3e0c418eb5e807a3ee1be770c2a` | Building 1 main accepted with limitation |
| `physical-building:w1222720021` | `fb952a31151805078d1e386117ed965aa0649ffddcd17874d13493b5dd4239bb` | Building 1 tower accepted with limitation; supersedes the first review's tower failure |
| `physical-building:w1249412093` | `9e4364eaf78412c58bfcac1bad1f4f35241f48a1b373976cdfa42638ce57b680` | Hawkins accepted |
| `physical-building:w34313540` | `1aee23943b3df4f600b9a4e4fce86d839b75ce575a924de4ca8b187bd9120046` | Building 3 accepted |
| `physical-building:w1249412094` | `37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8` | Isle House composite parent accepted once |

The corresponding evidence-manifest hashes are, in the same order:

- `ebeef887b37c6845c6c8fa3f25e06706351fe7c1dab0e1a3b0eaf47dfb773017`
- `dbe9745f5356b2309e820c2b47987ee4463518eaf4afd77fcd37df0edc8d437a`
- `e1ab8f526aed22a6234fff1d2fcc5eae5d2245df4260a25a5705cd37a158a921`
- `4b92b71df3c7f8f7dfbb285bd7566b3f422a32be45f810d532328e15d008f5be`
- `23fd6eff4ab8d9696af9d1ecc19bea50537cc824ecf3a7bebdf4fa191cd039d9`

The earlier P1 receipt's Building 3 and Isle failures are superseded only by
their later, target-specific independent receipts. They are not silently
treated as passes.

The four claim dimensions remain separate:

| Claim | Current distribution |
| --- | --- |
| Receiver complete | 213 verified; 0 failed |
| Reference recognizable | 5 accepted; 208 not evaluated; 0 rejected; 0 blocked |
| Game distinctive | 0 accepted; 213 not evaluated |
| As-built fidelity | 0 claimed; 0 limited; 213 unclaimed |

Therefore receiver completeness is not used as recognition evidence, and
recognizability does not imply either game distinctiveness or as-built
fidelity.

## Adapter and package boundary

The adapter arithmetic is exact and uses three distinct dimensions:

- 10 legacy plus 4 active receiver adapters = 14 plans.
- 6 plans are `package_safe_ready_for_integration`; all use
  `resolve_only_without_instantiation` and the loader reports
  `instantiated=false`.
- 8 plans are `hard_disabled_source_projection`; all use
  `deny_all_executable_resolution`, have no executable assets, and carry an
  exact disabled reason. The disabled set includes the Isle low receiver
  `building-composite:w1249412094:w1282547787:wall`.
- The disabled plans reference 15 unique projection descriptors through 17
  occurrences. The two extra occurrences are the Building 1 config and hero
  script, each shared by the main and tower plans; this is not a missing-plan
  discrepancy.

The runtime registry JSON and its 42 directly referenced runtime assets are
free of discovery/evidence/URL/absolute-path dependencies. The broader
source-side audit found 15 projected direct inputs and keeps every unsafe
execution path disabled. Unknown forward schema/API versions reject.

## Determinism and sealed hashes

Two independent `node tools/build_facade_recognition_registry.mjs --check`
runs passed. Both produced byte-identical results and left every checked hash
below unchanged:

| Artifact | Version, where applicable | SHA-256 |
| --- | --- | --- |
| Authoring catalog | `ti.facade-recognition-catalog/4` | `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` |
| Catalog schema | — | `0b7b433caed61c894cbdbdf53d112c06d6161bd0d14951fe795482b38af73e04` |
| Compiler | `1.3.0` | `734720fe1c09282ea09e8791e53d8a54933618ad7074b64f3893d797818bfb99` |
| Runtime registry | `ti.facade-runtime-registry/4` | `c60e20fb625fa98809975f08357370d71c330443a7546d88fadfcd7df3584d19` |
| Adapter contracts | `ti.facade-runtime-adapters/3` | `016f85579555d25170d42e71352938fef6bad102777bd909ab8fb01eef8d8d2e` |
| Validation report | `ti.facade-recognition-validation-report/3` | `34f2ee9350cc3cc966f1de675fc853ffb1e85c89bd6688a1c73200f350cd75b2` |
| Runtime loader | `ti.facade-runtime-registry-loader/3` | `1558224d21eeaef1b006e3e2c1e4ac833e8ecd291e8f9358b30401d9ebc58dbe` |
| Generated catalog content | — | `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164` |
| Generated manifest | — | `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` |
| Receiver inventory | — | `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f` |
| World chunk builder | — | `28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682` |

The world builder hash is pinned in the sealed report and remained unchanged
through both compiler passes. This audit therefore found no reconciliation
change to generated world construction, collision, navigation, or spray
ownership.

## Runtime and test evidence

The current full-runtime oracle passes at exactly:

`735 records / 940 meshes / 954 surfaces / 64,118 triangles / 466 static bodies / 466 shapes`

The following bounded gates passed in this audit:

- Node compiler/registry tests and runtime-loader contract tests.
- Godot project validation and loader `--check-only`.
- Godot recognition-registry and runtime-loader contracts.
- Startup configuration and gameplay contracts.
- Full runtime integration, accepted-material-run trials, and Batch 06 exact
  receiver trials at the current topology.
- Current Building 1 hero, Building 3 hero-massing and facade, Hawkins facade,
  and Isle low live-integration contracts.
- Isle Variant C source-package and fresh mounted-package contracts.

Two checked-in focused tests fail:

1. `game/tests/headless_building_1_live_field_integration_contract.gd` pins the
   old main-wall value `5/5/8026` and world value
   `735/931/941/59778/466/466`. The accepted current hero is six main-wall
   meshes/surfaces and the full world is
   `735/940/954/64118/466/466`.
2. `game/tests/headless_building_1_recognizability_live_contract.gd` pins the
   same old main-wall value and old whole-world topology. It fails for the
   current main wall, roof, and whole-island assertions.

The newer `headless_building_1_hero_model_contract.gd` and current full-runtime
integration pass. The two failures therefore expose obsolete regression
oracles; they do not invalidate the independently accepted Building 1 receipts
or alter the catalog metric. They must be reconciled before reporting an
unqualified all-focused-tests-green state.

## Export-remap seam

A fresh macOS PCK exported outside the repository was 65,372,872 bytes with
SHA-256
`b096f1a692ff48c48b114cb01139c5524fc8733647bf2e1ea6fea192c3af9ab1`.
From an empty external working directory, the target-specific mounted Isle
Variant C contract passed with exact overlay topology `7/11/2242`, exact low
receiver topology `8/12/2268`, and no evidence/discovery content, fallback,
stacking, or decorative collision/navigation/spray ownership.

The generic source-oriented registry and loader tests fail when run externally
against that PCK because exported Godot resources remap or omit their raw
`.gd`, `.tscn`, and `.tres` source paths. This reproduces the disclosed seam.
It is not evidence of weakened tests: source-checkout tests still require exact
raw-byte hashes and fail closed; the target-specific mounted behavior test
passes; and generic loader instantiation remains prohibited. Before generic
loader promotion in an exported build, an export-aware transformed-resource
integrity contract is still required.

## Discrepancies

1. **Stale Building 1 focused oracles (actionable):** the two tests named above
   still assert superseded topology and fail. Reconcile them against the
   independently accepted current hero without weakening their ownership or
   topology assertions.
2. **Stale Isle evidence checksum (historical-evidence bookkeeping):** the Isle
   live-replacement `CHECKSUMS.sha256` expects
   `e2c89f40994547e39f83435a1078738e6593c7a3f213578871f6e3f94c42c419`
   for `headless_isle_house_low_live_integration_contract.gd`; the current file
   is
   `7ed5cb806c6189a2fb8453a6e0636adf281e9eeaa188dab67e2aac4457f14743`.
   The current test itself passes and now pins Variant C plus current topology.
   The evidence README also describes the older global topology, so the old
   checksum ledger should be treated as capture-time evidence, not an
   exact-current all-file seal.
3. **Loader diagnostic typo (nonfunctional):** the loader correctly validates
   17 projection occurrences, but one error message says “not 14.” The passing
   positive and mutation tests exercise the actual 17-occurrence condition.

No other accepted unit, receiver, adapter, schema, hash, or topology
discrepancy was found in the defined audit gate.
