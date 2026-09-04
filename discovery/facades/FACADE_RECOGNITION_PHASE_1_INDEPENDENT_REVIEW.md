# Facade recognition Phase 1 independent review

Checked: **2026-09-04**

Reviewer: `/root/building_inventory_audit`, independent of the Phase 1
catalog/compiler implementation.

## Verdict

**FAIL — the canonical 213-unit partition and fail-closed seed are correct, but
the emitted registry is not an exact-current runtime/package contract.**

Two material defects must be repaired before this batch is accepted as the
current generic integration seam:

1. Building 1 and its separately counted observation tower are represented with
   stale pre-hero runtime modes/assets.
2. The source/package-boundary check stops at registry strings and does not inspect
   the referenced runtime assets or their dependency closure.

The defects do not change the denominator and do not create an accidental
recognition verdict today. They do make the green validation report too strong and
would give a future generic loader inaccurate or authoring-bearing inputs.

## Reviewed artifacts and stable byte boundary

The following hashes remained unchanged between the beginning and end of the
review:

| Artifact | SHA-256 |
| --- | --- |
| `tools/build_facade_recognition_registry.mjs` | `d12e3f0afcd020a3db3b65a87934fd2d7ec5545c0a8c938cd88148cc7ee09a82` |
| `tools/test_facade_recognition_registry.mjs` | `3d018f8655e2552305aabd9220207f51d70aae1fa8bd4840233c1c11dc38bacc` |
| `discovery/facades/facade-recognition-catalog.schema.json` | `283bc254f6306b8fae7694f80e53801d66b6b4ea8e59e4a3875217e6bafbdd87` |
| `discovery/facades/facade-recognition-catalog.json` | `6e2967f489bdd849b08793b3063f346893808fcc56522c6303082e9c46026a96` |
| `discovery/facades/facade-recognition-validation-report.json` | `946ca010ef0d2c9b67fc0e0064e734213bde7d467519744d2b9bf34aff5e6c8e` |
| `game/resources/facades/facade-runtime-registry.json` | `0ebab22257be4eb7f6a3caffb39b42377c3cf51468a9695a665111f5b1899a24` |
| `discovery/facades/FACADE_RECOGNITION_INFRASTRUCTURE.md` | `ae7d7d1206be8e5ec18a699101d254a92695c1d54b04e5bc270aa15b169f0930` |
| `game/tests/headless_facade_recognition_registry_contract.gd` | `9e27b2558597b2376a422e4b683778243403790884994378aaecaa603ac52960` |

## Independently re-derived canonical baseline

This was derived from the source-inventory CSV, the facade receiver inventory,
and all 38 generated chunk JSON files rather than trusting report totals.

| Measure | Independent result | Verdict |
| --- | ---: | --- |
| Source-inventory rows / unique keys | `739 / 739` | PASS |
| Playable rows | `735` | PASS |
| `building` category members | `213` | PASS |
| `building_part` category members | `2` | PASS |
| Building/building-part overlap | `0` | PASS |
| Inventory source records / unique keys | `215 / 215` | PASS |
| Standalone physical units | `212` | PASS |
| Composite parents | `1` | PASS |
| Part records | `2` | PASS |
| Physical recognition units | `213` | PASS |
| Generated wall receivers / unique keys | `214 / 214` | PASS |
| Visible wall runs from chunk indices | `4,971` | PASS |

The denominator is therefore exactly **213 physical units**, not 215 buildings:
212 standalone units plus one Isle House composite. The two Isle House parts are
receiver-bearing source records inside that one physical unit.

### Isle House

Core membership is correct:

- parent `w1249412094` owns no direct receiver;
- high part `w1282547786` owns
  `building-composite:w1249412094:w1282547786:wall`, 13 runs, including three
  shared-above-lower runs;
- low part `w1282547787` owns
  `building-composite:w1249412094:w1282547787:wall`, 13 runs;
- all three source records occur once inside `physical-building:w1249412094`.

Only the high receiver has a legacy adapter. The lower-severity unit-mode defect
below concerns how this correct membership is summarized for a future loader.

### Building 1 tower

Tower semantics are also correct at the physical-unit/source layer. Frozen way
`w1222720021` has `building=yes`, `man_made=tower`, and
`tower:type=observation`. Although it is an inner member of Building 1 relation
`r16681702`, it is a distinct physical structure with its own wall and roof
records. The catalog correctly keeps `physical-building:w1222720021` separate
from `physical-building:r16681702`; combining them into one recognition unit
would game the denominator.

## Passing checks

- Every catalog identity, source membership, and receiver membership reproduced
  the immutable inventory derivation with zero differences.
- Every generated wall receiver is unique, world-solid, opaque, one isolated quad
  per run, and belongs to exactly one recognition unit.
- The Isle House source/receiver partition is `3 / 2 / 1` exactly.
- Buildings 2 and 3 retain frozen `ref:nrhp=08000081` provenance. Their separate
  NPS assertions correctly record `08000082` and `08000083`, respectively, with
  `currentness_claimed=false`; the runtime summaries contain no source URL/path.
- The catalog contains zero recognition cues, reference records, capture contracts,
  acceptance records, protected scopes, or human dependencies. All 213 units are
  `game_distinctive=not_evaluated`,
  `reference_recognizable=not_evaluated`, and
  `as_built_fidelity=unclaimed`. No whole-building acceptance was imported.
- All 12 emitted legacy adapters are claim-neutral: each has
  `recognition_claim_effect=none` and
  `whole_building_recognizability_imported=false`; all recorded run indices are
  in range and all listed asset hashes match their current files.
- `--check` proved byte-for-byte equality between a fresh compile and both emitted
  artifacts. A second in-memory compile produced the same registry bytes/hash.
- The packaged Godot contract passed against registry SHA-256
  `0ebab22257be4eb7f6a3caffb39b42377c3cf51468a9695a665111f5b1899a24`.
- Full runtime integration passed at the concurrent source-tree state:
  38 chunks, 729 records, `931 / 941 / 59,778` loaded
  meshes/surfaces/triangles, 466 bodies/shapes, clean fail-closed reload. The
  recognition registry is not consumed by that runtime, so this proves Phase 1
  caused no behavior change; it does not prove adapter parity.
- `git diff --check` passed. No canonical `generated/`, `data/`, `HUMAN.md`, or
  `AGENTS.md` file was modified by this batch.

Commands run:

```sh
node tools/build_facade_recognition_registry.mjs --check
node tools/test_facade_recognition_registry.mjs
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . \
  --script game/tests/headless_facade_recognition_registry_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . \
  --script game/tests/full_runtime_integration.gd
```

All four exited zero. Independent CSV/inventory/chunk and transitive-asset scans
were additional read-only checks.

## Ranked defects

### P1 — Building 1/tower adapter state is stale against the current runtime

The compiler derives adapter seeds exclusively from the inventory's accepted
attachment list. That list still names the old Building 1 placement registry and
`building_1_recognizable_facade.gd`. The emitted adapter consequently says that
old composition is existing active runtime content, while the tower unit says
`runtime_content_mode=generated_placeholder`.

The current source runtime does something different: `world_chunk_builder.gd`
preloads `building_1_hero_model.gd` and intercepts all four independently keyed
Building 1/tower wall and roof records before generic construction. The old
recognizable-facade call has been removed. The hero explicitly preserves the tower
as a separate recognition entity, but both its wall and the main building wall now
receive target-specific hero content.

Why the green checks miss it: they prove that the inventory-derived old assets
still exist and hash correctly. They do not compare adapter claims to active
runtime dispatch or the four intercepted record results.

Impact: a future generic loader following this registry could restore obsolete
Building 1 content and leave the active tower hero unrepresented. The registry's
`existing_*_runtime_content` wording is false at the reviewed tree state.

Minimal repair request:

1. Wait for the Building 1 hero review/lifecycle decision.
2. Reconcile `FACADE_RECEIVER_INVENTORY.json` to the exact active runtime without
   changing the 213-unit/215-source/214-receiver/4,971-run denominator.
3. Represent the main Building 1 wall and tower wall as two separate physical-unit
   runtime bindings to the current hero asset/config, with claim effect still
   `none` unless their independent recognition gates are separately satisfied.
4. Remove the obsolete Building 1 adapter assets from the emitted active set.
5. Add a focused negative test that replaces/removes an active runtime hook and
   proves registry compilation/parity fails rather than merely checking that an
   old file remains on disk.

If this artifact is deliberately a pre-hero snapshot, rename and lifecycle-pin it
as such; do not publish it as the exact-current integration seam.

### P1 — Package-boundary validation is not transitive

The compiler's `runtimeAssets()` records only each asset path and hash. Its
`assertRuntimeBoundary()` then scans strings in the emitted registry object, not
the content or dependencies of those assets. The Node and Godot tests repeat the
same shallow boundary: path prefix, existence, hash, and registry-string scan.

An independent scan found **11 of the 40 unique referenced runtime assets** contain
`discovery/` paths, including:

- `game/resources/facades/building_1_recognizability_placements.json`;
- `game/resources/facades/w291196370_module_calibration.json`;
- `game/resources/facades/w34313515_module_calibration.json`;
- `game/resources/facades/w34313520_exact_receiver_calibration.json`;
- `game/resources/facades/w34313525_exact_receiver_calibration.json`;
- `game/resources/facades/w34313564_module_calibration.json`;
- the old Building 1 and four Batch 06 live-module scripts.

Several scripts address `res://discovery/...` during editor validation, and the
JSON resources carry review/provenance paths directly. The export preset excludes
the target discovery files, but authoring-path strings from these game resources
are present in the retained PCK. Therefore report scope text stating that evidence
and discovery paths remain source-only is not proven at package closure.

Impact: the registry can certify a supposedly package-safe adapter whose referenced
asset embeds or attempts to address source-only data. This is exactly the boundary
a future registry-driven runtime would trust.

Minimal repair request:

1. Emit/reference sanitized runtime projections containing only receiver/run,
   motif, material, transform, and truth-boundary fields needed at runtime.
2. Keep review paths, source URLs, provenance ledgers, and editor-only hash checks
   in source-side manifests or editor-only tooling, not shipped game assets.
3. Recursively scan every referenced runtime asset and dependency—not only registry
   strings—for `discovery/`, `evidence/`, URLs, and absolute paths; fail the Node
   and Godot/package checks on any unapproved occurrence.
4. Make the validation report distinguish “registry JSON clean” from “complete
   runtime dependency closure clean” and claim only the level actually tested.

### P2 — Isle House collapses a mixed receiver state into one unit mode

`buildRuntimeRegistry()` assigns unit-level `runtime_content_mode=legacy_adapter`
whenever any adapter ID exists. Isle House has two direct receivers, but only high
part `w1282547786` has an adapter; low part `w1282547787` remains the generated
placeholder. The adapter-to-receiver link is correct, and no recognition claim is
transferred, but the unit-level mode is overbroad.

Impact: a simple future loader can treat the entire composite as adapted and omit
or overwrite the low part.

Minimal repair request: make runtime content mode receiver-specific, or add a
`mixed_legacy_adapter_and_generated_placeholder` composite mode. Add a Godot test
that asserts high=adapter, low=placeholder, and whole Isle House recognition remains
unaccepted until both visible parts meet the unit gate.

### P2 — The declared JSON Schema is not actually applied

The compiler checks only that the schema file exists and records its hash. The
Node test reads it and inspects five top-level/version/reference fields, but neither
path validates the authoring catalog against Draft 2020-12. Manual compiler checks
currently cover the checked-in seed well, but the statement that the catalog is
“governed by” this JSON Schema is not an executable invariant; schema drift can be
hashed and reported as passing.

Minimal repair request: run a pinned Draft 2020-12 validator over the catalog in
both `--check` and the test suite, validate the schema itself, and add mutations
that violate nested `additionalProperties`, enums, cardinalities, and references.
Keep the existing semantic compiler checks because JSON Schema alone cannot prove
cross-file source/receiver ownership.

## Forward integration note

Compiler v1 deliberately rejects any nonzero game-distinctive,
reference-recognizable, or as-built acceptance at final runtime validation. That
is a strong Phase 1 seed gate and is why a synthetic otherwise-complete acceptance
probe failed with `Phase 1 must not import reference-recognizable acceptance`.
Before the first genuine recognition batch edits this catalog, make that versioned
upgrade explicit; the current compiler cannot be used unchanged to advance a unit.
