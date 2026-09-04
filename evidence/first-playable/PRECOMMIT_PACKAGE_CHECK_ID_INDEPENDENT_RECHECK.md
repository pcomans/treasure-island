# Pre-commit package validation check-ID independent recheck

Date: 2026-09-04  
Reviewer: `/root/d8_reference_research`  
Reviewed implementation: `/root/remote_runtime_auditor/ledger_recheck`  
Scope: bounded metadata repair recorded by
`PRECOMMIT_PACKAGE_CHECK_ID_REPAIR.md`  
Verdict: **CLOSED**

## Outcome

The P2 discrepancy recorded by the package-sanitization independent audit is
closed. The active generated report now contains exactly one passing check
with the truthful exact-current identifier:

`adapter_contract_8_ready_6_disabled_13_unique_projection_inputs`

The compiler derives the identifier from the same
`EXPECTED_ADAPTER_CONTRACTS` object that enforces eight package-safe plans,
six hard-disabled plans, and 13 unique pathless projection inputs. The Node
regression test requires the exact current identifier once and explicitly
rejects the stale identifier.

This recheck found no recognition, adapter, registry, topology, package,
visual, collision, spray, or gameplay change. The historical audit remains
immutable evidence of the defect that existed when that audit ran.

## Independent exact-diff reconstruction

The four pre-repair files were reconstructed independently in memory by
reversing only the changes claimed by the repair receipt. Every reconstructed
SHA-256 matches the receipt's declared before hash:

| File | Current SHA-256 | Independently reconstructed prior SHA-256 | Exact result |
| --- | --- | --- | --- |
| `tools/build_facade_recognition_registry.mjs` | `a145b9f60713b9027ae3c0a25692892088199dcb937325d29bb87cf3db82fbc7` | `81f69a4d4524412c8ce5c641e34642adab3dd80bd82b231061d5f1f1d3929d36` | derived constant/export replaced only the stale emitted literal |
| `tools/test_facade_recognition_registry.mjs` | `3a1fc971b1e5e6569d5d98a4d50f0cdbb865f8ffdbc4eb95c7fc2f003fc961aa` | `12875ed0361f427ff9452b79a1fc43696261cea8518bb7c949852d52d60e6e59` | constant import plus three exact regression assertions only |
| `discovery/facades/facade-recognition-validation-report.json` | `7d1562694c71e56976681f827421801f2c35e223230fe0543919dcaa1fcf26f7` | `075a9c55543e7146c97d35c14f86c59b48a116f8c652e67a35afce70655ef17e` | one check-ID string only; 52,089 bytes before and after |
| `evidence/first-playable/PRECOMMIT_PACKAGE_SANITIZATION.md` | `f65fd052a85612b698e2ee367767e92a5d10688e02aa3ae3fcf2006bad0750e0` | `39886303e67bec3204cf7829a566976ad988da552baa2a62a45aa12ff1de4c0a` | one validation-report SHA-256 repin only |

The active validation report has one current-ID occurrence with `status` set
to `pass` and zero stale-ID occurrences. The stale identifier remains only in
the regression test's negative assertion and the immutable historical audit.
The historical audit also retains its old report hash and contains neither the
new identifier nor the new report hash.

The historical audit is byte-identical at:

`361ba90a1835a6737caff5a598fd39d07e1bed96f8694558eeb6707d6965a3cb`

## Generated-artifact and receipt boundary

Independent comparison against the historical audit proves that the
validation report is the only generated compiler artifact whose hash changed:

| Artifact | Before | Current | Result |
| --- | --- | --- | --- |
| Recognition catalog | `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` | same | byte-identical |
| Runtime adapter contracts | `f1ffc7061a8d02bd7f78a1ec4457b36c4adc5618755f730638bfedfcc9d4437d` | same | byte-identical |
| Runtime registry | `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab` | same | byte-identical |
| Validation report | `075a9c55543e7146c97d35c14f86c59b48a116f8c652e67a35afce70655ef17e` | `7d1562694c71e56976681f827421801f2c35e223230fe0543919dcaa1fcf26f7` | sole generated change: one corrected string |

The package-sanitization receipt now pins the current validation-report hash
exactly once and no longer pins the old hash. Replacing only that pin recreates
the receipt's exact pre-repair hash, so the receipt migration is exact rather
than a broader editorial rewrite.

## Isolated compiler determinism

A media-light temporary repository copy first failed closed because its copy
policy had omitted runtime texture dependencies. No shared-repository file was
touched. After copying the complete `game/` dependency tree into that isolated
workspace, two consecutive compiler `--write` executions and a subsequent
`--check` all exited `0` and produced identical bytes:

- catalog:
  `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`;
- adapter contracts:
  `f1ffc7061a8d02bd7f78a1ec4457b36c4adc5618755f730638bfedfcc9d4437d`;
- runtime registry:
  `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`;
- validation report:
  `7d1562694c71e56976681f827421801f2c35e223230fe0543919dcaa1fcf26f7`.

Both writes and the check independently reported 213 physical units, 214
direct receivers, 215 source records, 4,971 visible wall runs, 14 adapter
plans, eight package-safe plans, six disabled plans, 13 sanitized projections,
and exact reference-recognizable metric `5/213`.

## Preserved runtime and package identities

The repair left the following current identities exact:

| Artifact/state | Exact current result |
| --- | --- |
| Runtime loader | `7a245be61167cf774f5f693944fe3adc6640b5dd7f7cb98fcb6425a7c82f7832` |
| Generated-world manifest | `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` |
| Generated-world content | `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164` |
| World chunk builder | `28be094c674108f42be040f2b3ae6d242838d15e2060f6cf4668b0a003f1a682` |
| Canonical PCK | `265635b899ae6674e44f673661af09a24ce61c977830cc137c6ea0efdee137c5`, 65,263,184 bytes |
| Recognition | exactly `5/213` accepted physical units |
| Runtime topology | `735/940/954/64118/466/466` playable rows / meshes / surfaces / triangles / bodies / shapes |

A fresh `macOS Private` export reproduced the canonical PCK byte-for-byte.
The mounted sanitization contract was invoked from outside the source checkout
and passed with seven current config hashes, zero runtime source locators,
zero private paths, and zero source pixels. The packaged app smoke passed at
38/38 chunks and the exact topology above, including movement and jetpack
behavior.

## Gates run independently

All final authoritative invocations exited `0`:

- Node syntax checks for the compiler and recognition test;
- shared-tree compiler `--check`;
- Node recognition-registry and runtime-loader contracts;
- isolated compiler `--write` twice followed by `--check`;
- Godot recognition-registry and runtime-loader contracts;
- source-mode package-sanitization contract;
- Building 1 hero and public-front believability contracts, including exact
  collision/spray/traversal preservation;
- full-runtime integration at exact `735/940/954/64118/466/466`;
- fresh canonical `macOS Private` export;
- direct-mounted package-sanitization contract from outside the checkout;
- exported-app `--mac-export-smoke`.

## Disposition

**CLOSED.** The prior audit's stale-check-ID discrepancy is repaired, guarded,
deterministic, and bounded to metadata and its exact receipt pin. There are no
blocking or new nonblocking discrepancies in this repair.

The historical audit's separate compiled-test metadata/footprint observation
remains truthful future cleanup for a stronger public-package policy. It was
not caused by this check-ID change and does not reopen this bounded closure.

## Audit write scope

This independent recheck changes only this document and an append-only
reviewer entry in `discovery/RETRO_LOG.md`. It does not modify production code,
generated artifacts, package configuration, provenance, evidence media,
historical reviews, the exported PCK, or Git state. No file was staged,
committed, pushed, or uploaded.
