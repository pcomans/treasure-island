# Pre-commit exact-current topology-oracle independent recheck

Date: 2026-09-04  
Independent reviewer: `/root/d8_reference_research`  
Implementation under review: `/root/d6_reference_research`  
Scope: independent recheck of `PRECOMMIT_TOPOLOGY_ORACLE_REPAIR.md`  
Verdict: **PASS for the scoped topology-oracle repair**

## Decision

The repair is independently accepted. The three active-current README surfaces,
the rendered capture static harness, and the five live receiver integration
contracts now agree on the accepted source-world topology:

`735 playable rows / 940 meshes / 954 surfaces / 64,118 triangles / 466 static bodies / 466 shapes`

The review found no weakening of target identity, exact receiver geometry,
facing-run partitions, collision ownership, navigation/spray exclusion, or
exactly-one ownership assertions. The only dependency-pin change within the
repair is the recomputed world-builder SHA-256 in the w34313564 contract:

`28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682`

Historical topology and capture-time pins remain historical. In particular,
the retained `111725` app's `1,278 / 1,288 / 55,067` tuple was not rewritten,
and no historical evidence contract was relaxed to make current runtime pass.

Two concurrently changing package-sanitization gates were red at the final
bounded recheck: Building 1 public-front config-byte identity and the registry
compiler's runtime-adapter count contract. They are outside the nine-file
topology repair, are not attributed to it, and do not reverse this scoped PASS.
They remain external release gates to reconcile and rerun after the authorized
package sanitization is sealed.

## Files independently inspected

- `README.md`
- `evidence/first-playable/README.md`
- `game/tests/README.md`
- `game/tests/rendered_visual_evidence_capture.gd`
- `game/tests/headless_w291196370_live_module_integration_contract.gd`
- `game/tests/headless_w34313515_live_module_integration_contract.gd`
- `game/tests/headless_w34313520_live_integration_contract.gd`
- `game/tests/headless_w34313525_live_integration_contract.gd`
- `game/tests/headless_w34313564_live_module_integration_contract.gd`

The current bytes of all nine files reproduce the repair receipt's exact
after-repair hashes:

| File | Independently reproduced SHA-256 |
| --- | --- |
| `README.md` | `a5bd666988f3d59cacf959f16c5e0c048b5a9261fd96634ef85fb95b02e62b03` |
| `evidence/first-playable/README.md` | `f350dafd4b4cb276a5c58d135154b36f853dfceeb327c786a1bdcdf2858d97e0` |
| `game/tests/README.md` | `b27269f2a75621788981c6db9d20b00d5c47f04d5d6e6c36f0291077f52ad115` |
| rendered harness | `3f6c7790837946cd5e5330d6f2786da9cb9fbf8d594a2613d40e46c5210d4f8e` |
| w291196370 live contract | `d42d1567f04bf51ee73e9a73644e91294581d6d91836948d4031c95fa89241d1` |
| w34313515 live contract | `3d1261ab0c3ab90187fc0a449a1ef8f788b2dbb6cd80431ec665ec35390d0a44` |
| w34313520 live contract | `b77ebe4a5a5c2208bf0482b0422819fffa889c217e18c8cd2a108d29c3b8bc7f` |
| w34313525 live contract | `8037cff8e4b95140f2b6dd97e7b06f6477fa7d24c0156d58f6cda873dcc182f9` |
| w34313564 live contract | `05d792186ea18c201f18e28826af468f60ed33bb7706205ad12c143b931f7069` |

## Static diff findings

### Active-current prose

The three README changes distinguish rather than conflate the three relevant
layers:

- frozen generated world: `729 / 739 / 48,389`;
- current physical records and record-owned runtime: `729` records with
  `725 / 735 / 48,825` meshes/surfaces/triangles;
- accepted loaded source world: `735 / 940 / 954 / 64,118 / 466 / 466`.

They retain the measured Building 1 `13 / 13 / 10,711`, Isle House Variant C
overlay `7 / 11 / 2,242`, and Building 3 `+766` record-owned triangle
explanations. They do not revise immutable evidence files or historical app
snapshots.

### Rendered harness

The active record-owned triangle oracle moves from `48,059` to `48,825`, and
the current runtime tuple moves from `931 / 941 / 59,778` to
`940 / 954 / 64,118`. Reconstructing those four prior numeric constants from
the current harness reproduces the receipt's exact pre-repair SHA-256
`6ef64a703f2db22595d5d5ab061c2c1125e14b1d2999855dc5b865b88aed6050`.
The existing `735 + 4` row, `729` record, `725 / 735` record mesh/surface, and
`466 / 466` physics checks remain present, as do capture, collision, and spray
boundaries.

### Five focused live contracts

Each live contract now requires the same exact-current world tuple and still
executes its receiver-local assertions:

- w291196370: three exact isolated modules with SSE runs `8/10` and ENE run
  `20`, plus exact-one collision ownership;
- w34313515: four BAY modules on WSW runs `0/6` and NNW runs `44/47`, plus
  exact collision ownership;
- w34313520: exact SSE runs `6..10`, including the complete backing-free run
  `7` module;
- w34313525: exact MAT-pale SSE runs `8..12` and NNW runs `26..27`, two
  surfaces, and four transform-identical backing-free modules;
- w34313564: exact runs `7/8/12/16/17`, local `34 / 34 / 408`, and zero
  backing, collision, navigation, or spray ownership.

The w291 live-adapter pin and w34313564 live-helper pin visible in the broader
working-tree diff predate this repair and are identical in the repair
receipt's before/after boundary. They were not misclassified as topology-
oracle edits. Only the w34313564 current world-builder input pin changes
inside the scoped repair.

## Independent execution ledger

Godot: `4.7.2.stable.official.ed1daf0bf`.

The five focused tests were run exactly once in one serialized sequence. All
five exited zero and reported exact world
`735/940/954/64118/466/466` together with their receiver-local result:

- `headless_w291196370_live_module_integration_contract.gd`: PASS
- `headless_w34313515_live_module_integration_contract.gd`: PASS
- `headless_w34313520_live_integration_contract.gd`: PASS
- `headless_w34313525_live_integration_contract.gd`: PASS
- `headless_w34313564_live_module_integration_contract.gd`: PASS

Additional bounded gates:

| Gate | Result | Independent observation |
| --- | --- | --- |
| rendered visual harness `--check-only` | PASS | Parsed and checked without writing captures |
| startup configuration | PASS | Exact package-smoke `940/954/64118` |
| gameplay | PASS | Runtime gameplay contract remained green |
| full runtime integration | PASS | `735/940/954/64118/466/466`, record-owned `725/735/48825` |
| Building 1 hero model | PASS | Exact component topology and current world tuple |
| Building 1 live-field integration | PASS | Current receiver integration remained green |
| Building 1 recognizability-live | PASS | Current recognizability gate remained green |
| Building 1 public-front believability | **external pending** | Config bytes drifted during concurrent authorized package sanitization |
| Building 3 hero massing | PASS | Current hero massing gate remained green |
| Building 3 facade | PASS | Current facade gate remained green |
| Building 3 hero evidence | PASS | Evidence contract remained green |
| Isle House low-live integration | PASS | Receiver `8/12/2268`, overlay `7/11/2242`, current world tuple |
| Isle House Variant C live-replacement evidence | PASS | Current replacement evidence remained green |
| Isle House Variant C source package | PASS | Exact overlay/world topology and zero decorative ownership |
| generated-world validator | PASS | 38 chunks, 739 source rows, 729 physical objects |
| registry compiler `--check` | **external pending** | Runtime-adapter contract counts drifted during concurrent package sanitization |
| scoped `git diff --check` | PASS | No whitespace errors in the nine reviewed files |

The two external pending results must be rerun against the package owner's
sealed bytes. This reviewer made no attempt to update their hashes or counts.

## Protected identities and mutation boundary

At the completion of the scoped executions, the repair's nine after-hashes
still matched. The following protected identities also matched the repair
receipt:

| Protected artifact | SHA-256 |
| --- | --- |
| world builder | `28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682` |
| recognition catalog | `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` |
| runtime registry | `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af` |
| generated manifest | `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` |
| export preset | `6860fbd8409e5f74b7389da23707db9524fb843a9f3f41429556a3d5d2329294` |

This independent recheck changed only this report and appended its retrospective
entry. It made no production, generated, config, provenance, evidence-manifest,
AVI, registry, catalog, builder, package, or test-oracle edit. No commit or push
was made.

## Final disposition

**PASS — scoped topology-oracle repair accepted.** The repair updates only the
active-current topology expectations and the one recomputed current builder
pin, while preserving exact receiver-local and historical assertions. Release-
wide green status remains contingent on the package-sanitization owner
reconciling and rerunning the two explicitly external pending gates above.
