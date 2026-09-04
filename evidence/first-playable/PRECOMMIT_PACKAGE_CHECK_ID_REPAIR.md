# Pre-commit package validation check-ID repair

Date: 2026-09-04  
Implementer: `/root/remote_runtime_auditor/ledger_recheck`  
Scope: package-audit P2 metadata discrepancy only  
Status: **implemented and technically verified; pending independent recheck**

## Outcome

The generated validation check identifier now truthfully describes the
already-enforced current adapter-plan state:

`adapter_contract_8_ready_6_disabled_13_unique_projection_inputs`

The compiler derives that identifier from the same
`EXPECTED_ADAPTER_CONTRACTS` values used by its executable invariants. The
Node recognition test now requires the exact current identifier exactly once
with passing status and rejects the stale identifier.

This is a metadata-only correction. It does not change adapter readiness,
projection data, package closure, runtime behavior, recognition acceptance,
topology, visuals, evidence media, export filters, or compiled-test footprint.
No report schema/version change is warranted because the JSON shape and check
semantics are unchanged.

## Exact change and dependency boundary

| File | Before SHA-256 | After SHA-256 | Change |
| --- | --- | --- | --- |
| `tools/build_facade_recognition_registry.mjs` | `81f69a4d4524412c8ce5c641e34642adab3dd80bd82b231061d5f1f1d3929d36` | `a145b9f60713b9027ae3c0a25692892088199dcb937325d29bb87cf3db82fbc7` | derive/export the check ID and emit it |
| `tools/test_facade_recognition_registry.mjs` | `12875ed0361f427ff9452b79a1fc43696261cea8518bb7c949852d52d60e6e59` | `3a1fc971b1e5e6569d5d98a4d50f0cdbb865f8ffdbc4eb95c7fc2f003fc961aa` | require exact current ID once; reject stale ID |
| `discovery/facades/facade-recognition-validation-report.json` | `075a9c55543e7146c97d35c14f86c59b48a116f8c652e67a35afce70655ef17e` | `7d1562694c71e56976681f827421801f2c35e223230fe0543919dcaa1fcf26f7` | generated check-ID value only; size remains 52,089 bytes |
| `evidence/first-playable/PRECOMMIT_PACKAGE_SANITIZATION.md` | `39886303e67bec3204cf7829a566976ad988da552baa2a62a45aa12ff1de4c0a` | `f65fd052a85612b698e2ee367767e92a5d10688e02aa3ae3fcf2006bad0750e0` | repin its declared final validation-report hash |

The historical independent package audit remains byte-unchanged at
`361ba90a1835a6737caff5a598fd39d07e1bed96f8694558eeb6707d6965a3cb`.
Its old identifier and old report hash record the discrepancy it found and
are not current source-of-truth claims. The old identifier otherwise remains
only in the regression test's explicit negative assertion.

No other checksum, manifest, inventory, contract, or receipt pins the old
report hash or identifier.

## Deterministic generation and invariant ledger

Two consecutive compiler `--write` executions produced the same identities:

| Artifact/state | Exact result |
| --- | --- |
| catalog | `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` (unchanged) |
| adapter contracts | `f1ffc7061a8d02bd7f78a1ec4457b36c4adc5618755f730638bfedfcc9d4437d` (unchanged) |
| runtime registry | `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab` (unchanged) |
| validation report | `7d1562694c71e56976681f827421801f2c35e223230fe0543919dcaa1fcf26f7` in both rounds |
| physical recognition metric | exactly `5/213` |
| receiver adapter plans | `14` |
| package-safe/ready plans | `8` |
| hard-disabled plans | `6` |
| disabled projection occurrences | `13` |
| unique pathless projection inputs | `13` |

Other exact compiler totals remain 213 physical recognition units, 214 direct
receivers, 215 source records, 4 active plus 10 legacy adapters, 4,971 visible
wall runs, two separated identity assertions, and 60 unresolved reference
dependencies.

## Verification ledger

All final authoritative invocations exited `0`:

- Node syntax checks for the compiler and recognition test;
- compiler `--check`, twice;
- Node recognition-registry contract;
- Node runtime-loader contract;
- Godot recognition-registry contract;
- Godot runtime-loader contract;
- source-mode pre-commit package-sanitization contract;
- Building 1 public-front believability contract;
- full-runtime integration at exact
  `735/940/954/64118/466/466`;
- one fresh canonical `macOS Private` export;
- direct-mounted pre-commit package-sanitization contract from outside the
  source checkout;
- exported app's bounded headless `--mac-export-smoke` at exact
  `38/38` chunks and `735/940/954/64118/466/466`.

The fresh PCK remains byte-identical to the accepted package:

- bytes: `65,263,184`;
- SHA-256:
  `265635b899ae6674e44f673661af09a24ce61c977830cc137c6ea0efdee137c5`.

An initial mounted-contract diagnostic was invoked from the source checkout,
so Godot overlaid the source project and correctly rejected it as not
`project.binary`-only. Re-running the same PCK from its outside-checkout export
directory passed. This was invocation-context error, not a package or product
failure; the exported PCK was not rebuilt between those invocations.

## Mutation boundary

No visual, geometry, world-builder, catalog, schema, adapter-contract JSON,
runtime-registry JSON, loader, Godot contract, generated-world artifact,
package filter, AVI/LFS state, research packet, or acceptance record changed.
The temporary exported app was removed after the mounted and smoke checks.
No file was staged, committed, pushed, or uploaded.

Independent recheck should inspect the four-file functional/hash boundary,
re-run the compiler check and Node recognition test, confirm the generated
report contains the new identifier exactly once, and verify the catalog,
adapter-contract, registry, 5/213 metric, and package PCK identities remain
unchanged.
