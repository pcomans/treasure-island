# Pre-commit exact-current topology-oracle repair

Date: 2026-09-04  
Implementer: `/root/d6_reference_research`  
Scope: release-audit blocker 1 only  
Status: **implemented and self-verified; pending independent recheck**

## Outcome

The nine release-audit docs/oracles now describe and enforce the accepted
source-world topology:

`735 playable rows / 940 meshes / 954 surfaces / 64,118 triangles / 466 static bodies / 466 shapes`

All five formerly failing exact-receiver integration tests pass twice. The
rendered-capture static gate, startup, gameplay, full runtime, current
Building 1/Building 3/Isle House gates, registry compiler `--check`, generated-
world validator, and diff hygiene also pass.

This repair changes no runtime construction or visual. It does not change the
frozen generated `729 meshes / 739 surfaces / 48,389 triangles`, the `729`
physical record-node count, or any retained app/capture topology stated as
historical.

## Exact repair

### Active-current documents

- Root and evidence/test indexes now use `940 / 954 / 64,118` for the current
  loaded source project and `735` for playable-row coverage.
- Current explanatory prose distinguishes `735` playable rows from the still-
  exact `729` physical records.
- The current record-owned runtime is documented as `725 / 735 / 48,825` after
  Building 1 interception and the accepted congruent Building 3 replacement.
- The current accepted deltas are documented without rewriting old evidence:
  Building 1/tower `13 / 13 / 10,711`; Isle House Variant C overlay
  `7 / 11 / 2,242`; Building 3 contributes the already measured `+766`
  record-owned triangles.
- The retained `111725` app's `1,278 / 1,288 / 55,067` statement remains
  historical and unchanged.

### Executable oracles

- `rendered_visual_evidence_capture.gd` now expects active record-owned
  triangles `48,825` and exact runtime `940 / 954 / 64,118`. Its existing
  `735 + 4` row, `729` record, `725 / 735` record mesh/surface, and `466 / 466`
  physics assertions remain intact.
- Each of the five receiver tests now requires `735` playable plus `4` context
  rows and exact `940 / 954 / 64,118 / 466 / 466` runtime topology. Their
  exact target identity, run partitions, deterministic local geometry,
  materials, collision, navigation, spray, protected-receiver, and exactly-one
  ownership assertions were not changed.
- `headless_w34313564_live_module_integration_contract.gd` now pins the
  independently recomputed full SHA-256 of its declared
  `game/scripts/world/world_chunk_builder.gd` input:
  `28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682`.
  Its distinct live-helper hash remains unchanged.

No immutable evidence manifest, checksum ledger, source/provenance config,
package contract, PCK, AVI, D9 packet, catalog, registry, generated artifact,
world-builder byte, or visual was modified.

## File identity ledger

| File | Before repair SHA-256 | After repair SHA-256 |
| --- | --- | --- |
| `README.md` | `2e590c391f5337f8a6288b6fdf97bc75f6ca0a0824b9a5d5d9cffb98e49d2b92` | `a5bd666988f3d59cacf959f16c5e0c048b5a9261fd96634ef85fb95b02e62b03` |
| `evidence/first-playable/README.md` | `c7ac5da9437b5d67f420f198bd6f1ab4558b3b24e6a5d261f10246b69f2099be` | `f350dafd4b4cb276a5c58d135154b36f853dfceeb327c786a1bdcdf2858d97e0` |
| `game/tests/README.md` | `b3d6db3e675f37e4fde373db7c879299f27a86bde8e0e5203f9af2f889c7d712` | `b27269f2a75621788981c6db9d20b00d5c47f04d5d6e6c36f0291077f52ad115` |
| `game/tests/rendered_visual_evidence_capture.gd` | `6ef64a703f2db22595d5d5ab061c2c1125e14b1d2999855dc5b865b88aed6050` | `3f6c7790837946cd5e5330d6f2786da9cb9fbf8d594a2613d40e46c5210d4f8e` |
| `game/tests/headless_w291196370_live_module_integration_contract.gd` | `d873d508fb709c06861212c0d358bfc40da1d93a6b1d24e53b32dd4915732f7e` | `d42d1567f04bf51ee73e9a73644e91294581d6d91836948d4031c95fa89241d1` |
| `game/tests/headless_w34313515_live_module_integration_contract.gd` | `708029b125d4bc51abe7ea59c2b83d610aaff8a82c3a31355889ac2a1ca77feb` | `3d1261ab0c3ab90187fc0a449a1ef8f788b2dbb6cd80431ec665ec35390d0a44` |
| `game/tests/headless_w34313520_live_integration_contract.gd` | `ef05b4db57e767c0524076ef0cbee55bbbad04e3a41a39248a3580ef1b781631` | `b77ebe4a5a5c2208bf0482b0422819fffa889c217e18c8cd2a108d29c3b8bc7f` |
| `game/tests/headless_w34313525_live_integration_contract.gd` | `84a322d940ab045033baa1781a02903a3143efdbf6a4e44c9a27c3fe5e7db11e` | `8037cff8e4b95140f2b6dd97e7b06f6477fa7d24c0156d58f6cda873dcc182f9` |
| `game/tests/headless_w34313564_live_module_integration_contract.gd` | `eb4f04a2682eb530bbd05b4edf051b53b62536a085807a7c688abfbbf6532c24` | `05d792186ea18c201f18e28826af468f60ed33bb7706205ad12c143b931f7069` |

## Verification ledger

Godot version: `4.7.2.stable.official.ed1daf0bf`.

### Focused double pass

The following five tests each passed in two separate serialized rounds:

- `headless_w291196370_live_module_integration_contract.gd`
- `headless_w34313515_live_module_integration_contract.gd`
- `headless_w34313520_live_integration_contract.gd`
- `headless_w34313525_live_integration_contract.gd`
- `headless_w34313564_live_module_integration_contract.gd`

Every success line reported exact world
`735/940/954/64,118/466/466` while retaining its target-local identity and
module/collision/ownership result.

### Cross-cutting passes

- `rendered_visual_evidence_capture.gd --check-only`: PASS (parse/static gate;
  no images or manifest written).
- `headless_startup_configuration_contract.gd`: PASS at package-smoke oracle
  `940/954/64118`.
- `headless_gameplay_contract.gd`: PASS.
- `full_runtime_integration.gd`: PASS at reported
  `735/940/954/64118/466/466`, active record-owned `725/735/48825`, and exact
  Building 1/Building 3/Isle House runtime.
- Current Building 1 hero-model, public-front, live-field, and recognizability-
  live contracts: PASS.
- Current Building 3 hero-massing, facade, and immutable-evidence contracts:
  PASS.
- Current Isle House Variant C low-live integration, live-replacement evidence,
  and source-package contracts: PASS; the package contract reports exact
  `7/11/2242` overlay and `735/940/954/64118/466/466` world.
- `node tools/build_facade_recognition_registry.mjs --check`: PASS, registry
  `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`,
  catalog `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`,
  recognition `5/213`.
- `node tools/validate_godot_world.mjs`: PASS, 38 chunks, 739 source rows, 729
  physical objects, content
  `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
- Scoped `git diff --check`: PASS.

### Deliberately historical diagnostic

I also invoked the older
`headless_isle_house_low_live_evidence_contract.gd`. It exited nonzero at its
intentional capture-time world-builder pin (`9525ead8…`) with
`World builder drifted after capture.` That file is not the current Variant C
live evidence gate. Per the explicit scope, its immutable historical pin was
not rewritten and the diagnostic was not relabeled as a current-product
failure. The current Variant C evidence and package gates above pass.

## No-mutation receipts

The following pre/post identities remained exact:

| Protected artifact | SHA-256 |
| --- | --- |
| world builder | `28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682` |
| recognition catalog | `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` |
| runtime registry | `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af` |
| generated manifest | `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` |
| export preset | `6860fbd8409e5f74b7389da23707db9524fb843a9f3f41429556a3d5d2329294` |
| generated-world path/hash aggregate | `20782acbd59544ed50f47337c0521cea2dbb501be1a21490ffd1d02966dfb3a2` |
| all retained AVI path/hash aggregate | `47afedc5eb0134ce4f396d6cd8035cd32367e6872297d2166a37d6db3dbfcdf1` |

No commit or push was made. Independent review should inspect only this narrow
oracle/prose patch and rerun the five focused tests plus one full-runtime gate.

## Files changed by this repair

- `README.md`
- `evidence/first-playable/README.md`
- `game/tests/README.md`
- `game/tests/rendered_visual_evidence_capture.gd`
- `game/tests/headless_w291196370_live_module_integration_contract.gd`
- `game/tests/headless_w34313515_live_module_integration_contract.gd`
- `game/tests/headless_w34313520_live_integration_contract.gd`
- `game/tests/headless_w34313525_live_integration_contract.gd`
- `game/tests/headless_w34313564_live_module_integration_contract.gd`
- `evidence/first-playable/exact-current-recognition-reconciliation-independent-audit-2026-09-04/PRECOMMIT_TOPOLOGY_ORACLE_REPAIR.md`
- `discovery/RETRO_LOG.md` (append-only entry)
